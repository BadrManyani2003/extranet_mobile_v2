const jwt = require('jsonwebtoken');
const jwksClient = require('jwks-rsa');
const { promisify } = require('util');
const { error } = require('../common/response');
const keycloakConfig = require('../config/keycloak');
const authService = require('../services/auth.service');
const keycloakService = require('../services/keycloak.service');
const asyncLocalStorage = require('../common/context');
const { timeEnd } = require('console');

let formattedPublicKey = null;
if (keycloakConfig.publicKey) {
    const rawKey = keycloakConfig.publicKey.trim();
    if (!rawKey.includes('-----BEGIN PUBLIC KEY-----')) {
        const lines = rawKey.replace(/\s+/g, '').match(/.{1,64}/g) || [];
        formattedPublicKey = `-----BEGIN PUBLIC KEY-----\n${lines.join('\n')}\n-----END PUBLIC KEY-----`;
    } else {
        formattedPublicKey = rawKey.replace(/\\n/g, '\n');
    }
    console.log('[Auth Init] Mode Cle Publique Statique active pour la verification des tokens.');
} else {
    console.log(`[Auth Init] URL JWKS configuree pour le backend : ${keycloakConfig.jwksUri}`);
}

const client = keycloakConfig.publicKey ? null : jwksClient({
    jwksUri: keycloakConfig.jwksUri,
    cache: true,
    cacheMaxEntries: 5,
    cacheMaxAge: 600000,
    rateLimit: true,
    jwksRequestsPerMinute: 10,
    handleSigningKeyError: (err) => {
        console.error('❌ [JWKS-RSA] Erreur lors de la recuperation de la cle de signature:', err.message);
    }
});

function getKey(header, callback) {
    if (formattedPublicKey) {
        return callback(null, formattedPublicKey);
    }

    if (!header || !header.kid) {
        console.error("❌ [Auth Middleware] Le token JWT ne contient pas de 'kid' dans son en-tete.");
        return callback(new Error("Le token JWT ne contient pas de parametre 'kid' dans son en-tete."));
    }

    client.getSigningKey(header.kid, (err, key) => {
        if (err) {
            console.error(`❌ [JWKS-RSA] Echec de la recuperation de la cle pour le kid "${header.kid}":`, err.message);
            return callback(err);
        }
        callback(null, key.getPublicKey());
    });
}


const verifyToken = promisify(jwt.verify);

const userCache = new Map();
const CACHE_TTL_MS = 5 * 60 * 1000;

async function getCachedUser(authId) {
    const cached = userCache.get(authId);
    if (cached && (Date.now() - cached.timestamp < CACHE_TTL_MS)) {
        return cached.user;
    }
    const result = await authService.getUserByAuthId(authId);
    const dbUser = result[0]?.[0];
    if (dbUser) {
        if (userCache.size >= 500) {
            const now = Date.now();
            for (const [key, val] of userCache.entries()) {
                if (now - val.timestamp >= CACHE_TTL_MS) {
                    userCache.delete(key);
                }
            }
            if (userCache.size >= 500) {
                userCache.clear();
            }
        }
        userCache.set(authId, { user: dbUser, timestamp: Date.now() });
    }
    return dbUser;
}

module.exports = async (req, res, next) => {
    const authHeader = req.headers.authorization;

    if (!authHeader?.startsWith('Bearer ')) {
        return error(res, 'Authentification requise. Format: Bearer <token>', 401);
    }

    const token = authHeader.split(' ')[1];

    try {
        const decoded = await verifyToken(token, getKey, {
            algorithms: ['RS256'],
            clockTolerance: 30
        });

        const source = req.headers['x-source'] || 'E';
        const dbUser = await getCachedUser(decoded.sub);

        req.user = {
            ...decoded,
            id:     dbUser?.id || 0,
            token,
            roles:  decoded.realm_access?.roles || [],
            source
        };

        const impersonation = req.headers['x-impersonation'] === 'true';
        const impUserId = req.headers['x-impersonated-user-id'];

        if (impersonation && impUserId) {
            const isAdmin = req.user.roles.includes('admin_cabinet') || req.user.roles.includes('commercial_cabinet');
            if (isAdmin) {
                // Vérifier si l'admin/commercial est explicitement autorisé à simuler cet utilisateur
                const isAuthorized = await authService.checkSimulationPermission(req.user.id, impUserId);
                if (!isAuthorized) {
                    console.warn(`[Impersonation Blocked] Admin/Commercial user "${req.user.id}" attempted unauthorized simulation of user "${impUserId}"`);
                    return error(res, 'Non autorise a simuler cet utilisateur.', 403);
                }

                const impResult = await authService.getUserById(impUserId);
                const impUser = impResult[0]?.[0];
                
                if (impUser) {
                    req.adminUser = { ...req.user };
                    req.user.id = impUser.Id || impUser.id;
                    req.user.source = 'E'; 
                    // Utiliser le token actif de l'admin pour passer les contrôles SQL
                    req.user.token = req.adminUser.token; 
                    
                    if (impUser.Id_Auth && impUser.Id_Auth.trim()) {
                        try {
                            const roles = await keycloakService.getUserRoles(impUser.Id_Auth);
                            req.user.roles = roles.map(r => r.name);
                        } catch (e) {
                            console.error('Echec de la recuperation des roles de l\'utilisateur simule:', e.message);
                        }
                    } else {
                        // Rôles par défaut si le compte Keycloak n'est pas encore synchronisé
                        req.user.roles = impUser.Mobile === 'O' || impUser.mobile === 'O' ? ['adherent'] : ['client'];
                    }

                    // Synchroniser le token BDD de l'utilisateur simulé avec le token admin actif par ID local
                    try {
                        await authService.updateTokenById(req.user.token, req.user.id);
                    } catch (err) {
                        console.error('❌ Echec de la mise a jour du token de l\'utilisateur simule en BDD:', err.message);
                    }
                }
            }
        }

        if (dbUser && dbUser.token !== token && !impersonation) {
            try {
                await authService.updateToken(token, decoded.sub);
                dbUser.token = token; // Update cache
                userCache.set(decoded.sub, { user: dbUser, timestamp: Date.now() });
            } catch (err) {
                console.error('❌ Echec de la mise a jour du token en BDD:', err.message);
            }
        }

        const siteIdHeader = req.headers['x-site-id'];
        if (siteIdHeader) {
            const siteId = parseInt(siteIdHeader, 10);
            // Validation de l'acces au site
            const sites = await authService.getUserSites(req.user.id);
            const hasAccess = sites.some(s => s.Id === siteId);
            if (!hasAccess) {
                return error(res, 'Acces non autorise a ce site.', 403);
            }
            req.siteId = siteId;
        } else {
            const bypassRoutes = ['/api/sites', '/api/auth/me', '/api/auth/password'];
            const needsSite = !bypassRoutes.some(route => req.originalUrl.startsWith(route));
            
            if (needsSite) {
                return error(res, 'Le header x-site-id est obligatoire.', 400);
            } timeEnd
        }

        asyncLocalStorage.run({ siteId: req.siteId }, () => {
            next();
        });

    } catch (err) {
        console.error('❌ [Auth Middleware] Echec de validation du token:', err.message);
        let message = 'Token invalide.';
        if (err.name === 'TokenExpiredError') message = 'Session expiree.';
        if (err.name === 'JsonWebTokenError') message = `Erreur de signature: ${err.message}`;
        return error(res, message, 401);
    }
};

module.exports.checkRole = (roles) => {
    return (req, res, next) => {
        if (!req.user) return error(res, 'Utilisateur non authentifie.', 401);

        // Si c'est une simulation par un admin/commercial, on autorise l'accès
        if (req.adminUser) {
            const adminRoles = req.adminUser.roles || [];
            if (adminRoles.includes('admin_cabinet') || adminRoles.includes('commercial_cabinet')) {
                return next();
            }
        }

        const allowedRoles = Array.isArray(roles) ? roles : [roles];
        const hasRole = allowedRoles.some(role => (req.user.roles || []).includes(role));

        if (!hasRole) return error(res, 'Acces refuse : permissions insuffisantes.', 403);
        next();
    };
};