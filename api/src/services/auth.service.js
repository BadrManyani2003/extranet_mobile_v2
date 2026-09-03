const db = require('./db.service');
const qry = require('../sql/qryExtranet');

const getUserByAuthId = (authId) => db.execute(qry.getUserByAuthId, [authId]);
const getUserById = (id) => db.execute(qry.getUserById, [id]);

const getUserInfoByAuthId = (authId) => db.execute(qry.getUserInfoByAuthId, [authId]);

const updateToken = (token, authId) => db.execute(qry.updateToken, [token, authId]);
const updateTokenById = (token, id) => db.execute(qry.updateTokenById, [token, id]);

const checkSimulationPermission = async (adminId, targetUserId) => {
    const result = await db.execute(qry.checkSimulationPermission, [adminId, targetUserId]);
    return result[0]?.length > 0;
};

const getUserSites = async (userId) => {
    if (!userId || userId === 0) return [];
    const result = await db.execute(qry.getUserActiveSites, [userId]);
    return result[0] || [];
};

const getUserPermissions = async (userId) => {
    if (!userId) return [];
    const result = await db.execute(qry.getUserPermissions, [userId]);
    return result[0] || [];
};

module.exports = {
    getUserByAuthId,
    getUserById,
    getUserInfoByAuthId,
    updateToken,
    updateTokenById,
    checkSimulationPermission,
    getUserSites,
    getUserPermissions
};