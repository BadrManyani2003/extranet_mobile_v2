const reclamationService = require('../services/reclamation.service');
const { success } = require('../common/response');
const asyncHandler = require('../middleware/asyncHandler');

const getContext = (req) => ({
    userId: req.user.id,
    token:  req.user.token,
    source: req.headers['x-source'] || 'E',
    siteId: req.siteId || null,
    role:   (req.user.roles || []).includes('admin_cabinet') ? 'admin_cabinet' : 'commercial_cabinet'
});

const getReclamations = asyncHandler(async (req, res) => {
    const { userId, source, token, role, siteId } = getContext(req);
    const roles = req.user.roles || [];
    const isAdmin = roles.includes('admin_cabinet');
    const isCommercial = roles.includes('commercial_cabinet');

    if (isAdmin || isCommercial) {
        const result = await reclamationService.getAdminReclamations(userId, source, token, role, siteId);
        success(res, result[0] || []);
    } else {
        const result = await reclamationService.getReclamations(userId, source, token, siteId);
        success(res, result[0] || []);
    }
});

const getReclamationDetails = asyncHandler(async (req, res) => {
    const { userId, source, token, siteId } = getContext(req);
    const { reclamationId } = req.body;
    const result = await reclamationService.getReclamationDetails(userId, source, token, reclamationId, siteId);
    success(res, result[0] || []);
});

const createReclamation = asyncHandler(async (req, res) => {
    const { userId, source, token, siteId } = getContext(req);
    const { sujet, nature, message } = req.body;
    const result = await reclamationService.createReclamation(userId, source, token, sujet, nature, message, siteId);
    success(res, result[0]?.[0] || {}, 'Votre réclamation a bien été envoyée.');
});

const addMessage = asyncHandler(async (req, res) => {
    const { userId, source, token, siteId } = getContext(req);
    const { reclamationId, nature, message } = req.body;
    await reclamationService.addMessage(userId, source, token, reclamationId, nature, message, siteId);
    success(res, null, 'Votre message a été envoyé.');
});

const updateStatus = asyncHandler(async (req, res) => {
    const { userId, source, token, siteId } = getContext(req);
    const { reclamationId, status, statut } = req.body;
    await reclamationService.updateStatus(userId, source, token, reclamationId, status || statut, siteId);
    success(res, null, 'Le statut a été mis à jour.');
});

const deleteReclamation = asyncHandler(async (req, res) => {
    const { userId, source, token, siteId } = getContext(req);
    const roles = req.user.roles || [];

    if (roles.includes('commercial_cabinet') && !roles.includes('admin_cabinet')) {
        res.status(403);
        throw new Error("Action non autorisée.");
    }

    const { reclamationId } = req.body;
    await reclamationService.deleteReclamation(userId, source, token, reclamationId, siteId);
    success(res, null, 'La réclamation a été supprimée.');
});

const deleteMessage = asyncHandler(async (req, res) => {
    const { userId, token, siteId } = getContext(req);
    const { messageId } = req.body;
    await reclamationService.deleteMessage(userId, token, messageId, siteId);
    success(res, null, 'Le message a été supprimé.');
});

module.exports = {
    getReclamations,
    getReclamationDetails,
    createReclamation,
    addMessage,
    updateStatus,
    deleteReclamation,
    deleteMessage
};