const db = require('./db.service');
const qry = require('../sql/qryExtranet');

// Réclamations pour clients/adhérents (sans filtrage rôle)
const getReclamations = (userId, source, token) => db.execute(qry.getReclamations, [userId, source, token]);

// Réclamations pour admin/commercial — filtrées par rôle dans le SP
const getAdminReclamations = (userId, source, token, role = 'admin_cabinet') =>
    db.execute(qry.getAdminReclamations, [userId, source, token, role]);

const getReclamationDetails = (userId, source, token, reclamationId) => db.execute(qry.getReclamationDetails, [userId, source, token, reclamationId]);

const createReclamation = (userId, source, token, siteId, sujet, nature, message) => db.execute(qry.createReclamation, [userId, source, token, siteId, sujet, nature, message]);

const addMessage = (userId, source, token, siteId, reclamationId, nature, message) => db.execute(qry.addMessageReclamation, [userId, source, token, siteId, reclamationId, nature, message]);

const updateStatus = (userId, source, token, siteId, reclamationId, status) => db.execute(qry.updateReclamationStatut, [userId, source, token, siteId, reclamationId, status]);

const deleteReclamation = (userId, source, token, siteId, reclamationId) => db.execute(qry.deleteReclamation, [userId, source, token, siteId, reclamationId]);

const deleteMessage = (userId, token, siteId, messageId) => db.execute(qry.deleteMessageReclamation, [userId, token, siteId, messageId]);

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
