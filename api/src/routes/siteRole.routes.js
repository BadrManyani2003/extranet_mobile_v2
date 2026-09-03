const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const siteRoleController = require('../controllers/siteRole.controller');

// Ces routes devraient idéalement être protégées par un rôle d'administration globale

// Lister les rôles (avec ou sans siteId en query param)
router.get('/roles', auth, siteRoleController.getSiteRoles);

// Créer un rôle
router.post('/roles', auth, siteRoleController.createSiteRole);

// Mettre à jour un rôle
router.put('/roles/:id', auth, siteRoleController.updateSiteRole);

// Supprimer un rôle
router.delete('/roles/:id', auth, siteRoleController.deleteSiteRole);

// Lister toutes les permissions possibles
router.get('/permissions', auth, siteRoleController.getSitePermissions);


// Voir les permissions d'un rôle
router.get('/roles/:id/permissions', auth, siteRoleController.getSiteRolePermissions);

// Mettre à jour une permission pour un rôle (activer/désactiver)
router.post('/roles/:id/permissions', auth, siteRoleController.setSiteRolePermission);


// Récupérer les rôles d'un utilisateur sur un site
router.get('/users/:userId/sites/:siteId/roles', auth, siteRoleController.getUserSiteRoles);

// Assigner un rôle à un utilisateur sur un site
router.post('/users/:userId/sites/:siteId/roles', auth, siteRoleController.assignUserSiteRole);

// Retirer un rôle à un utilisateur sur un site
router.delete('/users/:userId/sites/:siteId/roles/:roleId', auth, siteRoleController.removeUserSiteRole);

// Récupérer les permissions effectives d'un utilisateur sur un site
router.get('/users/:userId/sites/:siteId/permissions', auth, siteRoleController.getUserPermissionsBySite);

module.exports = router;
