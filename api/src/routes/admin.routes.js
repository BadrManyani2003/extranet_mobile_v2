const router = require('express').Router();
const auth   = require('../middleware/auth');
const ctrl   = require('../controllers/admin.controller');

// Authentification obligatoire sur toutes les routes admin
router.use(auth);

const adminOnly  = auth.checkRole(['admin_cabinet']);
const adminOrCom = auth.checkRole(['admin_cabinet', 'commercial_cabinet']);

// ── Utilisateurs (admin + commercial) ──────────────────────────────────────────
router.post('/users',               adminOrCom, ctrl.getUsers);
router.post('/users/save',          adminOrCom, ctrl.saveUser);
router.post('/users/delete',        adminOrCom, ctrl.deleteUser);
router.post('/users/sync-keycloak', adminOrCom, ctrl.syncKeycloak);
router.get ('/roles',               adminOnly,  ctrl.getAvailableRoles);
router.post('/users/roles',         adminOnly,  ctrl.updateUserRoles);

// ── Simulations (admin + commercial) ─────────────────────────────────────────
router.post('/simulation-users',                 adminOrCom, ctrl.getSimulationUsers);
router.post('/users/simulation-clients',         adminOrCom, ctrl.getUserSimulationClients);
router.post('/users/simulation-clients/add',     adminOrCom, ctrl.addUserSimulationClient);
router.post('/users/simulation-clients/delete',  adminOrCom, ctrl.deleteUserSimulationClient);

// ── Clients (admin + commercial, résultats filtrés par rôle) ─────────────────
router.post('/clients',              adminOrCom, ctrl.getClients);
router.post('/clients/link-user',    adminOrCom, ctrl.linkUserToClient);
router.post('/clients/unlink-user',  adminOrCom, ctrl.unlinkUserFromClient);
router.post('/clients/options',      adminOrCom, ctrl.updateClientOptions);
router.post('/clients/emails',       adminOrCom, ctrl.updateClientEmails);
router.post('/clients/parent',       adminOrCom, ctrl.updateClientParent);

// ── Clients — actions admin + commercial ───────────────────────────────────────
router.post('/clients/create-user',  adminOrCom, ctrl.createUserFromClient);

// ── Adhérents (admin + commercial) ─────────────────────────────────────────────
router.post('/adherents',             adminOrCom, ctrl.getAdherents);
router.post('/adherents/create-user', adminOrCom, ctrl.createUserFromAdherent);
router.post('/adherents/link-user',   adminOrCom, ctrl.linkUserToAdherent);

module.exports = router;