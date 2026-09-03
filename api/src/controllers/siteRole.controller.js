const siteRoleService = require('../services/siteRole.service');
const { success } = require('../common/response');
const asyncHandler = require('../middleware/asyncHandler');


const getSiteRoles = asyncHandler(async (req, res) => {
    // Peut être filtré par siteId si passé dans la requête
    const siteId = req.query.siteId || null;
    const roles = await siteRoleService.getSiteRoles(siteId);
    success(res, roles);
});

const createSiteRole = asyncHandler(async (req, res) => {
    const { name, description, siteId } = req.body;
    if (!name) throw new Error('Le nom du rôle est requis.');
    
    const newRoleId = await siteRoleService.createSiteRole(name, description, siteId);
    success(res, { id: newRoleId }, 'Le rôle a bien été créé.', 201);
});

const updateSiteRole = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const { name, description, siteId } = req.body;
    
    if (!name) throw new Error('Le nom du rôle est requis.');
    
    await siteRoleService.updateSiteRole(id, name, description, siteId);
    success(res, null, 'Le rôle a été mis à jour.');
});

const deleteSiteRole = asyncHandler(async (req, res) => {
    const { id } = req.params;
    await siteRoleService.deleteSiteRole(id);
    success(res, null, 'Le rôle a été supprimé.');
});


const getSitePermissions = asyncHandler(async (req, res) => {
    const permissions = await siteRoleService.getSitePermissions();
    success(res, permissions);
});


const getSiteRolePermissions = asyncHandler(async (req, res) => {
    const { id } = req.params; // roleId
    const permissions = await siteRoleService.getSiteRolePermissions(id);
    success(res, permissions);
});

const setSiteRolePermission = asyncHandler(async (req, res) => {
    const { id } = req.params; // roleId
    const { permissionId, isActive } = req.body;
    
    if (!permissionId) throw new Error('permissionId est requis.');
    if (isActive === undefined) throw new Error('isActive est requis.');
    
    await siteRoleService.setSiteRolePermission(id, permissionId, isActive);
    success(res, null, 'Les permissions ont été enregistrées.');
});


const getUserSiteRoles = asyncHandler(async (req, res) => {
    const { userId, siteId } = req.params;
    const roles = await siteRoleService.getUserSiteRoles(userId, siteId);
    success(res, roles);
});

const assignUserSiteRole = asyncHandler(async (req, res) => {
    const { userId, siteId } = req.params;
    const { roleId } = req.body;
    
    if (!roleId) throw new Error('roleId est requis.');
    
    await siteRoleService.assignUserSiteRole(userId, siteId, roleId);
    success(res, null, 'Le rôle a été attribué à l\'utilisateur.');
});

const removeUserSiteRole = asyncHandler(async (req, res) => {
    const { userId, siteId, roleId } = req.params;
    
    await siteRoleService.removeUserSiteRole(userId, siteId, roleId);
    success(res, null, 'Le rôle a été retiré de l\'utilisateur.');
});

const getUserPermissionsBySite = asyncHandler(async (req, res) => {
    const { userId, siteId } = req.params;
    const permissions = await siteRoleService.getUserPermissionsBySite(userId, siteId);
    success(res, permissions);
});

module.exports = {
    getSiteRoles,
    createSiteRole,
    updateSiteRole,
    deleteSiteRole,
    getSitePermissions,
    getSiteRolePermissions,
    setSiteRolePermission,
    getUserSiteRoles,
    assignUserSiteRole,
    removeUserSiteRole,
    getUserPermissionsBySite
};
