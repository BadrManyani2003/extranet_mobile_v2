const db = require('./db.service');
const qry = require('../sql/qryExtranet');

// Réclamations pour clients/adhérents (sans filtrage rôle)
const getReclamations = (userId, source, token, siteId) => db.execute(qry.getReclamations, [userId, source, token, siteId]);

// Réclamations pour admin/commercial — filtrées par rôle dans le SP
const getAdminReclamations = (userId, source, token, role = 'admin_cabinet', siteId) =>
    db.execute(qry.getAdminReclamations, [userId, source, token, role, siteId]);

const getReclamationDetails = (userId, source, token, reclamationId, siteId) => db.execute(qry.getReclamationDetails, [userId, source, token, reclamationId, siteId]);

const createReclamation = (userId, source, token, sujet, nature, message, siteId) => db.execute(qry.createReclamation, [userId, source, token, sujet, nature, message, siteId]);

const addMessage = (userId, source, token, reclamationId, nature, message, siteId) => db.execute(qry.addMessageReclamation, [userId, source, token, reclamationId, nature, message, siteId]);

const updateStatus = (userId, source, token, reclamationId, status, siteId) => db.execute(qry.updateReclamationStatut, [userId, source, token, reclamationId, status, siteId]);

const deleteReclamation = (userId, source, token, reclamationId, siteId) => db.execute(qry.deleteReclamation, [userId, source, token, reclamationId, siteId]);

const deleteMessage = (userId, token, messageId, siteId) => db.execute(qry.deleteMessageReclamation, [userId, token, messageId, siteId]);

module.exports = {
    getReclamations,
    getAdminReclamations,
    getReclamationDetails,
    createReclamation,
    addMessage,
    updateStatus,
    deleteReclamation,
    deleteMessage
};
