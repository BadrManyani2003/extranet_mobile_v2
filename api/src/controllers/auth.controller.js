const authService = require('../services/auth.service');
const { success, error } = require('../common/response');
const asyncHandler = require('../middleware/asyncHandler');

const keycloakService = require('../services/keycloak.service');

const getMe = asyncHandler(async (req, res) => {
    const authId = req.user.sub;
    const source = req.headers['x-source'] || 'E';
    const result = await authService.getUserInfoByAuthId(authId);
    
    if (!result[0] || result[0].length === 0) {
        return error(res, 'Utilisateur introuvable dans la base locale.', 404);
    }

    const user = result[0][0];

    success(res, {
        ...user,
        roles: req.user.roles || []
    });
});

const changePassword = asyncHandler(async (req, res) => {
    const { newPassword } = req.body;
    
    if (!newPassword) return error(res, 'Le nouveau mot de passe est requis', 400);
    
    try {
        await keycloakService.changePassword(req.user.sub, newPassword);
        success(res, 'Mot de passe modifié avec succès');
    } catch (err) {
        error(res, err.message || 'Erreur lors de la modification du mot de passe', 500);
    }
});

module.exports = {
    getMe,
    changePassword
};