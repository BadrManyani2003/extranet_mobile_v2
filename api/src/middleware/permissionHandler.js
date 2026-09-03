const siteRoleService = require('../services/siteRole.service');
const authService = require('../services/auth.service');

/**
 * Middleware pour vérifier si un utilisateur possède une permission spécifique sur le site courant ou globalement.
 * Suppose que req.user.id est défini (par exemple via le middleware auth).
 * 
 * @param {string} requiredPermissionCode - Le code de la permission requise (ex: 'delete_client')
 */
const requirePermission = (requiredPermissionCode) => {
    return async (req, res, next) => {
        try {
            const userId = req.user?.id;
            const siteId = req.siteId || req.params.siteId || req.body.siteId;

            if (!userId) {
                return res.status(401).json({ success: false, message: 'Non autorisé: Utilisateur manquant' });
            }

            // 0. Super Admin : admin_cabinet a tous les droits
            if (req.user?.roles?.includes('admin_cabinet')) {
                return next();
            }

            // 1. Vérification des permissions globales
            const globalPermissions = await authService.getUserPermissions(userId);
            const hasGlobal = globalPermissions.some(p => 
                (p.Code === requiredPermissionCode || p.code === requiredPermissionCode || p.CODE === requiredPermissionCode) && 
                (p.SiteId === null || p.siteId === null || p.SITEID === null)
            );

            if (hasGlobal) {
                return next();
            }

            // 2. Vérification par site s'il y a un siteId
            if (siteId) {
                const sitePermissions = await siteRoleService.getUserPermissionsBySite(userId, siteId);
                if (sitePermissions.includes(requiredPermissionCode)) {
                    return next();
                }
            }

            // 3. Pas de permission trouvée
            return res.status(403).json({ success: false, message: `Accès refusé: Permission requise -> ${requiredPermissionCode}` });
        } catch (error) {
            console.error('[Permission Middleware] Erreur:', error);
            return res.status(500).json({ success: false, message: 'Erreur lors de la vérification des permissions' });
        }
    };
};

module.exports = {
    requirePermission
};
