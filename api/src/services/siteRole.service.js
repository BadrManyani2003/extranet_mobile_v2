const db = require('./db.service');
const qry = require('../sql/qryExtranet');


const getSiteRoles = async (siteId) => {
    // Si siteId est fourni, on ramène les rôles globaux (NULL) et ceux spécifiques au site
    // Sinon on ne ramène que les globaux ou tous, selon la requête (ici la requête gère le paramètre @0)
    const result = await db.execute(qry.getSiteRoles, [siteId || null]);
    return result[0] || [];
};

const createSiteRole = async (name, description, siteId) => {
    const result = await db.execute(qry.createSiteRole, [name, description, siteId || null]);
    return result[0]?.[0]?.Id;
};

const updateSiteRole = async (id, name, description, siteId) => {
    await db.execute(qry.updateSiteRole, [id, name, description, siteId || null]);
    return true;
};

const deleteSiteRole = async (id) => {
    await db.execute(qry.deleteSiteRole, [id]);
    return true;
};


const getSitePermissions = async () => {
    const result = await db.execute(qry.getSitePermissions, []);
    return result[0] || [];
};


const getSiteRolePermissions = async (siteRoleId) => {
    const result = await db.execute(qry.getSiteRolePermissions, [siteRoleId]);
    return result[0] || [];
};

const setSiteRolePermission = async (siteRoleId, sitePermissionId, isActive) => {
    await db.execute(qry.setSiteRolePermission, [siteRoleId, sitePermissionId, isActive ? 'O' : 'N']);
    return true;
};


const getUserSiteRoles = async (userId, siteId) => {
    const result = await db.execute(qry.getUserSiteRoles, [userId, siteId]);
    return result[0] || [];
};

const assignUserSiteRole = async (userId, siteId, siteRoleId) => {
    await db.execute(qry.assignUserSiteRole, [userId, siteId, siteRoleId]);
    return true;
};

const removeUserSiteRole = async (userId, siteId, siteRoleId) => {
    await db.execute(qry.removeUserSiteRole, [userId, siteId, siteRoleId]);
    return true;
};

const getUserPermissionsBySite = async (userId, siteId) => {
    const result = await db.execute(qry.getUserPermissionsBySite, [userId, siteId]);
    // On retourne juste un tableau de strings contenant les codes des permissions
    return (result[0] || []).map(row => row.Code);
};

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
