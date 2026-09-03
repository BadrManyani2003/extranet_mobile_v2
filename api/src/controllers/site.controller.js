const siteService = require('../services/site.service');
const { success } = require('../common/response');
const asyncHandler = require('../middleware/asyncHandler');

// Only allow global admins to do CRUD on sites
const getAllSites = asyncHandler(async (req, res) => {
    const result = await siteService.getAllSites();
    success(res, result);
});

const getSiteById = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const result = await siteService.getSiteById(id);
    success(res, result[0]);
});

const createSite = asyncHandler(async (req, res) => {
    const data = req.body;
    const result = await siteService.createSite(data);
    success(res, result);
});

const updateSite = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const data = req.body;
    const result = await siteService.updateSite(id, data);
    success(res, result);
});

// For any user to list their allowed sites
const getUserSites = asyncHandler(async (req, res) => {
    const userId = req.user.id;
    const result = await siteService.getUserSites(userId);
    success(res, result);
});
const deleteSite = asyncHandler(async (req, res) => {
    const { id } = req.params;
    const result = await siteService.deleteSite(id);
    success(res, result, 'Le site a été supprimé.');
});

module.exports = {
    getAllSites,
    getSiteById,
    createSite,
    updateSite,
    deleteSite,
    getUserSites
};
