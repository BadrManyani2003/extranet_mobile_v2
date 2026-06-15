const reclamationService = require('../services/reclamation.service');
const { success } = require('../common/response');
const asyncHandler = require('../middleware/asyncHandler');

const getContext = (req) => ({
    userId: req.user.id,
    token:  req.user.token,
    source: req.headers['x-source'] || 'M',
    // Détermine le rôle actif pour le filtrage (admin vs commercial)
    role:   (req.user.roles || []).includes('admin_cabinet') ? 'admin_cabinet' : 'commercial_cabinet'
});

// Route admin/commercial — résultats filtrés par rôle
const getAdminReclamations = asyncHandler(async (req, res) => {
    const { userId, source, token, role } = getContext(req);
    const result = await reclamationService.getAdminReclamations(userId, source, token, role);
    success(res, result[0] || []);
});

const getReclamations = asyncHandler(async (req, res) => {
    const { userId, source, token, role } = getContext(req);
    const roles = req.user.roles || [];
    const isAdmin = roles.includes('admin_cabinet');
    const isCommercial = roles.includes('commercial_cabinet');

    if (isAdmin || isCommercial) {
        const result = await reclamationService.getAdminReclamations(userId, source, token, role);
        success(res, result[0] || []);
    } else {
        const result = await reclamationService.getReclamations(userId, source, token);
        success(res, result[0] || []);
    }
});

const getReclamationDetails = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { reclamationId } = req.body;
    const result = await reclamationService.getReclamationDetails(userId, source, token, reclamationId);
    success(res, result[0] || []);
});

const createReclamation = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { sujet, nature, message } = req.body;
    const result = await reclamationService.createReclamation(userId, source, token, sujet, nature, message);
    success(res, result[0]?.[0] || {}, 'Réclamation créée avec succès');
});

const addMessage = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { reclamationId, nature, message } = req.body;
    await reclamationService.addMessage(userId, source, token, reclamationId, nature, message);
    success(res, null, 'Message ajouté');
});

const updateStatus = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { reclamationId, status, statut } = req.body;
    await reclamationService.updateStatus(userId, source, token, reclamationId, status || statut);
    success(res, null, 'Statut mis à jour');
});

const deleteReclamation = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { reclamationId } = req.body;
    await reclamationService.deleteReclamation(userId, source, token, reclamationId);
    success(res, null, 'Réclamation supprimée');
});

const deleteMessage = asyncHandler(async (req, res) => {
    const { userId, token } = getContext(req);
    const { messageId } = req.body;
    await reclamationService.deleteMessage(userId, token, messageId);
    success(res, null, 'Message supprimé');
});

module.exports = {
    getAdminReclamations,
    getReclamations,
    getReclamationDetails,
    createReclamation,
    addMessage,
    updateStatus,
    deleteReclamation,
    deleteMessage
};