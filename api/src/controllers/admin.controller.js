const adminService = require('../services/admin.service');
const { success } = require('../common/response');
const asyncHandler = require('../middleware/asyncHandler');

const getContext = (req) => ({
    userId: req.user.id,
    token:  req.user.token,
    source: req.headers['x-source'] || 'A',
    siteId: req.siteId || null,
    // Détermine le rôle actif (admin_cabinet prioritaire)
    role:   (req.user.roles || []).includes('admin_cabinet') ? 'admin_cabinet' : 'commercial_cabinet'
});

const getUsers = asyncHandler(async (req, res) => {
    const { userId, source, token, siteId } = getContext(req);
    const result = await adminService.getUsers(userId, token, source, siteId);
    success(res, result[0] || []);
});

const getSimulationUsers = asyncHandler(async (req, res) => {
    const { userId, source, token, siteId } = getContext(req);
    const result = await adminService.getSimulationList(userId, token, source, siteId);
    success(res, result[0] || []);
});

const getUserSimulationClients = asyncHandler(async (req, res) => {
    const { userId, source, token, siteId } = getContext(req);
    const { targetUserId } = req.body;
    if (!targetUserId) throw new Error('ID utilisateur cible manquant.');
    const result = await adminService.getUserSimulationClients(userId, token, source, targetUserId, siteId);
    success(res, result[0] || []);
});

const addUserSimulationClient = asyncHandler(async (req, res) => {
    const { userId, source, token, siteId } = getContext(req);
    const { targetUserId, clientId } = req.body;
    if (!targetUserId || !clientId) throw new Error('Paramètres manquants.');
    await adminService.addUserSimulationClient(userId, token, source, siteId, targetUserId, clientId);
    success(res, null, 'Client ajouté aux simulations');
});

const deleteUserSimulationClient = asyncHandler(async (req, res) => {
    const { userId, source, token, siteId } = getContext(req);
    const { targetUserId, clientId } = req.body;
    if (!targetUserId || !clientId) throw new Error('Paramètres manquants.');
    await adminService.deleteUserSimulationClient(userId, token, source, siteId, targetUserId, clientId);
    success(res, null, 'Client supprimé des simulations');
});

const saveUser = asyncHandler(async (req, res) => {
    const { userId, source, token, siteId } = getContext(req);
    const { id, targetId, idAuth, nom, telephone, email, nature, extranet, mobile } = req.body;
    const finalTargetId = id || targetId || 0;
    const result = await adminService.saveUser(userId, token, source, siteId, finalTargetId, idAuth, nom, telephone, email, nature, extranet, mobile);
    success(res, result[0]?.[0] || {}, 'Utilisateur enregistré');
});

const deleteUser = asyncHandler(async (req, res) => {
    const { userId, source, token, siteId } = getContext(req);
    const { deleteId, userId: idToDelete } = req.body;
    const targetId = deleteId || idToDelete;
    
    if (!targetId) throw new Error('ID utilisateur manquant.');

    await adminService.deleteUser(userId, token, source, siteId, targetId);
    success(res, null, 'Utilisateur supprimé');
});

const getClients = asyncHandler(async (req, res) => {
    const { userId, source, token, role, siteId } = getContext(req);
    const result = await adminService.getClients(userId, token, source, role, siteId);
    success(res, result[0] || []);
});

const createUserFromClient = asyncHandler(async (req, res) => {
    const { userId, source, token, siteId } = getContext(req);
    const { clientId } = req.body;
    const result = await adminService.createUserFromClient(userId, token, source, siteId, clientId);
    success(res, result[0]?.[0] || {}, 'Utilisateur créé depuis le client');
});

const getAdherents = asyncHandler(async (req, res) => {
    const { userId, source, token, siteId } = getContext(req);
    const { policeId = 0 } = req.body;
    const result = await adminService.getAdherents(userId, source, token, policeId, siteId);
    success(res, result[0] || []);
});

const createUserFromAdherent = asyncHandler(async (req, res) => {
    const { userId, source, token, siteId } = getContext(req);
    const { adherentId } = req.body;
    const result = await adminService.createUserFromAdherent(userId, token, source, siteId, adherentId);
    success(res, result[0]?.[0] || {}, 'Utilisateur créé depuis l\'adhérent');
});

const syncKeycloak = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { id } = req.body;
    await adminService.syncKeycloak(userId, token, source, id);
    success(res, null, 'Synchronisation réussie');
});

const linkUserToClient = asyncHandler(async (req, res) => {
    const { userId, source, token, role, siteId } = getContext(req);
    const { targetUserId, clientId } = req.body;
    await adminService.linkUserToClient(userId, token, source, siteId, targetUserId, clientId, role);
    success(res, null, 'Liaison réussie');
});

const unlinkUserFromClient = asyncHandler(async (req, res) => {
    const { userId, source, token, role, siteId } = getContext(req);
    const { targetUserId, clientId } = req.body;
    await adminService.unlinkUserFromClient(userId, token, source, siteId, targetUserId, clientId, role);
    success(res, null, 'Liaison supprimée');
});

const linkUserToAdherent = asyncHandler(async (req, res) => {
    const { userId, source, token, role, siteId } = getContext(req);
    const { targetUserId, adherentId } = req.body;
    await adminService.linkUserToAdherent(userId, token, source, siteId, targetUserId, adherentId, role);
    success(res, null, 'Liaison réussie');
});

const getAvailableRoles = asyncHandler(async (req, res) => {
    const result = await adminService.getAvailableRoles();
    success(res, result);
});

const updateUserRoles = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { targetUserId, authId, roles } = req.body;
    await adminService.updateUserRoles(userId, token, source, targetUserId, authId, roles);
    success(res, null, 'Rôles mis à jour');
});

const updateClientOptions = asyncHandler(async (req, res) => {
    const { userId, source, token, role, siteId } = getContext(req);
    const { clientId, recClt, recAdh } = req.body;
    
    if (!clientId) throw new Error('ID client manquant.');
    if (!recClt || !recAdh) throw new Error('Options de reclamation manquantes.');

    await adminService.updateClientOptions(userId, token, source, siteId, clientId, recClt, recAdh, role);
    success(res, null, 'Options client mises a jour');
});

const updateClientEmails = asyncHandler(async (req, res) => {
    const { userId, source, token, role, siteId } = getContext(req);
    const { clientId, emails } = req.body;
    
    if (!clientId) throw new Error('ID client manquant.');

    await adminService.updateClientEmails(userId, token, source, siteId, clientId, emails || '', role);
    success(res, null, 'Emails mis à jour');
});

const updateClientParent = asyncHandler(async (req, res) => {
    const { userId, source, token, role, siteId } = getContext(req);
    const { clientId, parentId } = req.body;
    await adminService.updateClientParent(userId, token, source, siteId, clientId, parentId, role);
    success(res, null, 'Société mère mise à jour avec succès');
});

const getUserSitesAdmin = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const result = await adminService.getUserSitesAdmin(id);
    success(res, result[0] || []);
});

const updateUserSites = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const { siteIds } = req.body; // array of IDs
    const siteIdsString = Array.isArray(siteIds) ? siteIds.join(',') : '';
    await adminService.updateUserSites(id, siteIdsString);
    success(res, null, 'Sites utilisateur mis à jour avec succès');
});

module.exports = {
    getUsers,
    getSimulationUsers,
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