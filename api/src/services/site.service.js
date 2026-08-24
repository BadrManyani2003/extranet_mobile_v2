const db = require('./db.service');
const qry = require('../sql/qryExtranet');

const getAllSites = async () => {
    const result = await db.execute(qry.getAllSites);
    return result[0];
};

const getSiteById = async (id) => {
    const result = await db.execute(qry.getSiteById, [id]);
    return result[0];
};

const createSite = async (data) => {
    const { Code, RaisonSociale, Adresse, Ville, Actif } = data;
    const result = await db.execute(qry.createSite, [Code || '', RaisonSociale, Adresse || '', Ville || '', Actif || 'O']);
    return result[0];
};

const updateSite = async (id, data) => {
    const { Code, RaisonSociale, Adresse, Ville, Actif } = data;
    await db.execute(qry.updateSite, [id, Code || '', RaisonSociale, Adresse || '', Ville || '', Actif || 'O']);
    return { success: true };
};

const deleteSite = async (id) => {
    await db.execute(qry.deleteSite, [id]);
    return { success: true };
};

const getUserSites = async (userId) => {
    const result = await db.execute(qry.getUserActiveSites, [userId]);
    return result[0];
};

module.exports = {
    getAllSites,
    getSiteById,
    createSite,
    updateSite,
    deleteSite,
    getUserSites
};
