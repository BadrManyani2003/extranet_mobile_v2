const router = require('express').Router();
const auth   = require('../middleware/auth');
const ctrl   = require('../controllers/admin.controller');
const { requirePermission } = require('../middleware/permissionHandler');

// Authentification obligatoire sur toutes les routes admin
router.use(auth);

const adminOnly  = auth.checkRole(['admin_cabinet']);
const adminOrCom = auth.checkRole(['admin_cabinet', 'commercial_cabinet']);

router.post('/users',               adminOrCom, ctrl.getUsers);
router.post('/users/save',          adminOrCom, ctrl.saveUser); // Gère création et modification
router.post('/users/delete',        adminOrCom, requirePermission('utilisateurs:supprimer'), ctrl.deleteUser);
router.post('/users/sync-keycloak', adminOrCom, requirePermission('utilisateurs:synchroniser'), ctrl.syncKeycloak);
router.get ('/roles',               adminOrCom, requirePermission('utilisateurs:gerer_roles'), ctrl.getAvailableRoles);
router.post('/users/roles',         adminOrCom, requirePermission('utilisateurs:gerer_roles'), ctrl.updateUserRoles);
router.get ('/users/:id/sites',     adminOrCom, requirePermission('utilisateurs:gerer_sites'), ctrl.getUserSitesAdmin);
router.post('/users/:id/sites',     adminOrCom, requirePermission('utilisateurs:gerer_sites'), ctrl.updateUserSites);

router.post('/simulation-users',                 adminOrCom, ctrl.getSimulationUsers);
router.post('/users/simulation-clients',         adminOrCom, requirePermission('simulations:lire'), ctrl.getUserSimulationClients);
router.post('/users/simulation-clients/add',     adminOrCom, requirePermission('simulations:modifier'), ctrl.addUserSimulationClient);
router.post('/users/simulation-clients/delete',  adminOrCom, requirePermission('simulations:modifier'), ctrl.deleteUserSimulationClient);

router.post('/clients',              adminOrCom, ctrl.getClients);
router.post('/clients/link-user',    adminOrCom, requirePermission('clients:lier'), ctrl.linkUserToClient);
router.post('/clients/unlink-user',  adminOrCom, requirePermission('clients:delier'), ctrl.unlinkUserFromClient);
router.post('/clients/options',      adminOrCom, requirePermission('clients:gerer_options'), ctrl.updateClientOptions);
router.post('/clients/emails',       adminOrCom, requirePermission('clients:gerer_emails'), ctrl.updateClientEmails);
router.post('/clients/parent',       adminOrCom, requirePermission('clients:modifier_parent'), ctrl.updateClientParent);

router.post('/clients/create-user',  adminOrCom, requirePermission('clients:creer_utilisateur'), ctrl.createUserFromClient);

router.post('/adherents',             adminOrCom, ctrl.getAdherents);
router.post('/adherents/create-user', adminOrCom, requirePermission('adherents:creer_utilisateur'), ctrl.createUserFromAdherent);
router.post('/adherents/link-user',   adminOrCom, requirePermission('adherents:lier'), ctrl.linkUserToAdherent);

module.exports = router;