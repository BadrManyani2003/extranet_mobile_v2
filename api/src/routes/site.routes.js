const express    = require('express');
const router     = express.Router();
const siteController = require('../controllers/site.controller');
const auth       = require('../middleware/auth');
const { requirePermission } = require('../middleware/permissionHandler');

router.use(auth);

// Rôles pour les opérations d'administration des sites
const adminOnly = auth.checkRole(['admin_cabinet']);
const adminOrCom = auth.checkRole(['admin_cabinet', 'commercial_cabinet']);

// Route accessible à tout utilisateur authentifié pour récupérer ses sites autorisés
router.get('/', siteController.getUserSites);

// Routes d'administration des sites (protégées par les permissions granulaires)
router.get('/all',   adminOrCom, requirePermission('sites:lire'), siteController.getAllSites);
router.get('/:id',   adminOrCom, requirePermission('sites:lire'), siteController.getSiteById);
router.post('/',     adminOrCom, requirePermission('sites:creer'), siteController.createSite);
router.put('/:id',   adminOrCom, requirePermission('sites:modifier'), siteController.updateSite);
router.delete('/:id',adminOrCom, requirePermission('sites:supprimer'), siteController.deleteSite);

module.exports = router;
