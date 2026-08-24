const db             = require('./db.service');
const qry            = require('../sql/qryExtranet');
const keycloakService = require('./keycloak.service');

const getUsers  = (userId, token, source) => db.execute(qry.getUsers, [userId, token, source]);
const getSimulationList = (userId, token, source) => db.execute(qry.getSimulationList, [userId, token, source]);
const getUserSimulationClients = (userId, token, source, targetUserId) => db.execute(qry.getUserSimulationClients, [userId, token, source, targetUserId]);
const addUserSimulationClient = (userId, token, source, siteId, targetUserId, clientId) => db.execute(qry.addUserSimulationClient, [userId, token, source, siteId, targetUserId, clientId]);
const deleteUserSimulationClient = (userId, token, source, siteId, targetUserId, clientId) => db.execute(qry.deleteUserSimulationClient, [userId, token, source, siteId, targetUserId, clientId]);
const saveUser  = (userId, token, source, siteId, targetId, authId, nom, tel, email, nature, extranet, mobile) =>
    db.execute(qry.saveUser, [userId, token, source, siteId, targetId, authId, nom, tel, email, nature, extranet, mobile]);

const deleteUser = async (userId, token, source, siteId, deleteId) => {
    const userResult = await db.execute(qry.getUserById, [deleteId]);
    const user = userResult[0]?.[0];

    await db.execute(qry.deleteUser, [userId, token, source, siteId, deleteId]);

    if (user?.Id_Auth?.trim()) {
        try {
            await keycloakService.deleteUser(user.Id_Auth);
        } catch (err) {
            console.error(`[Keycloak] Erreur suppression utilisateur ${user.Id_Auth}:`, err.message);
        }
    }
};

// Clients — filtrés selon le rôle (admin_cabinet = tous, commercial = ses clients simulation)
const getClients = (userId, token, source, role = 'admin_cabinet') =>
    db.execute(qry.getClients, [userId, token, source, role]);

const createUserFromClient = (userId, token, source, siteId, clientId) => db.execute(qry.createUserFromClient, [userId, token, source, siteId, clientId]);
const getAdherents         = (userId, source, token, policeId) => db.execute(qry.getAdherents, [userId, source, token, policeId]);
const createUserFromAdherent = (userId, token, source, siteId, adherentId) => db.execute(qry.createUserFromAdherent, [userId, token, source, siteId, adherentId]);

const resolveOrCreateKeycloakUser = async (Nom, Email, idToSync = null) => {
    const existing = await keycloakService.findUserByEmail(Email);
    if (existing?.length > 0) return existing[0].id;

    const nameParts = Nom.trim().split(/\s+/);
    const id = await keycloakService.createUser({
        email:     Email,
        username:  Email,
        firstName: nameParts[0] || '',
        lastName:  nameParts.slice(1).join(' ') || ''
    });
    try {
        let targetClientId = 'client_extranet';
        let redirectUri = process.env.EXTRANET_APP_URL;
        
        if (idToSync) {
            const rolesResult = await db.execute('SELECT Role FROM Roles WHERE FK_User_Id = @0', [idToSync]);
            const roleNames = rolesResult[0]?.map(r => r.Role) || [];
            if (roleNames.includes('admin_cabinet') || roleNames.includes('commercial_cabinet')) {
                targetClientId = 'client_admin';
                redirectUri = process.env.ADMIN_APP_URL;
            }
        }
        await keycloakService.sendOnboardingEmail(id, targetClientId, redirectUri);
    } catch (err) {
        console.error("[Keycloak] Impossible d'envoyer l'email d'activation:", err.message);
    }
    return id;
};

const syncKeycloak = async (userId, token, source, id) => {
    const userResult = await db.execute(qry.getUserById, [id]);
    const userToSync = userResult[0]?.[0];

    if (!userToSync) throw new Error("Utilisateur local introuvable.");

    const { Nom, Email, Id_Auth } = userToSync;
    if (!Email) throw new Error("L'utilisateur n'a pas d'adresse e-mail configuree.");

    let keycloakUserId = Id_Auth;

    if (!keycloakUserId?.trim()) {
        keycloakUserId = await resolveOrCreateKeycloakUser(Nom, Email, id);
    } else {
        try {
            const kcUser = await keycloakService.getUserById(keycloakUserId);
            if (!kcUser) {
                keycloakUserId = await resolveOrCreateKeycloakUser(Nom, Email, id);
            }
        } catch {
            const found = await keycloakService.findUserByEmail(Email);
            if (found?.length > 0) keycloakUserId = found[0].id;
        }
    }

    await db.execute(qry.syncKeycloak, [userId, token, source, id, keycloakUserId]);
    return { success: true, keycloakUserId };
};

// Lier/délier client — vérification que le commercial n'agit que sur ses propres clients (le SP gère le filtrage)
const linkUserToClient     = (userId, token, source, siteId, targetUserId, clientId, role = 'admin_cabinet')  =>
    db.execute(qry.linkUserToClient, [userId, token, source, siteId, targetUserId, clientId, role]);

const unlinkUserFromClient = (userId, token, source, siteId, targetUserId, clientId, role = 'admin_cabinet')  =>
    db.execute(qry.unlinkUserFromClient, [userId, token, source, siteId, targetUserId, clientId, role]);

const linkUserToAdherent   = (userId, token, source, siteId, targetUserId, adherentId, role = 'admin_cabinet') =>
    db.execute(qry.linkUserToAdherent, [userId, token, source, siteId, targetUserId, adherentId, role]);

const updateClientOptions  = (userId, token, source, siteId, clientId, recClt, recAdh, role = 'admin_cabinet') =>
    db.execute(qry.updateClientOptions, [userId, token, source, siteId, clientId, recClt, recAdh, role]);

const updateClientEmails   = (userId, token, source, siteId, clientId, emails, role = 'admin_cabinet') =>
    db.execute(qry.updateClientEmails, [userId, token, source, siteId, clientId, emails, role]);

const updateClientParent   = (userId, token, source, siteId, clientId, parentId, role = 'admin_cabinet') =>
    db.execute(qry.updateClientParent, [userId, token, source, siteId, clientId, parentId, role]);

const getUserSitesAdmin = (targetUserId) => db.execute('EXEC dbo.sp_GetUserSites @0', [targetUserId]);

const updateUserSites = (targetUserId, siteIdsString) => 
    db.execute('EXEC dbo.ps_UpdateUserSites @0, @1', [targetUserId, siteIdsString]);

const getAvailableRoles = () => keycloakService.getAvailableRoles();

const updateUserRoles = async (userId, token, source, targetUserId, authId, roles) => {
    let activeAuthId = authId;

    if (!activeAuthId?.trim()) {
        const syncResult = await syncKeycloak(userId, token, source, targetUserId);
        activeAuthId = syncResult.keycloakUserId;
    }

    const currentRoles = await keycloakService.getUserRoles(activeAuthId);
    if (currentRoles.length > 0) await keycloakService.removeUserRoles(activeAuthId, currentRoles);
    if (roles.length > 0)        await keycloakService.assignUserRoles(activeAuthId, roles);

    const rolesCSV = roles.map(r => r.name).join(',');
    return db.execute(qry.updateUserRoles, [userId, token, source, targetUserId, rolesCSV]);
};

module.exports = {
    getUsers,
    getSimulationList,
    getUserSimulationClients,
    addUserSimulationClient,
    deleteUserSimulationClient,
    saveUser,
    deleteUser,
    getClients,
    createUserFromClient,
    getAdherents,
    createUserFromAdherent,
    syncKeycloak,
    linkUserToClient,
    unlinkUserFromClient,
    linkUserToAdherent,
    getAvailableRoles,
    updateUserRoles,
    updateClientOptions,
    updateClientEmails,
    updateClientParent,
    getUserSitesAdmin,
    updateUserSites
};
