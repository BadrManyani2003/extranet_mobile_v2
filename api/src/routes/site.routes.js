const express    = require('express');
const router     = express.Router();
const siteController = require('../controllers/site.controller');
const auth       = require('../middleware/auth');

router.use(auth);

// Rôles pour les opérations d'administration des sites
const adminOnly = auth.checkRole(['admin_cabinet']);

// Route accessible à tout utilisateur authentifié pour récupérer ses sites autorisés
router.get('/', siteController.getUserSites);

// Routes réservées aux admins uniquement (CRUD complet des sites)
router.get('/all',   adminOnly, siteController.getAllSites);
router.get('/:id',   adminOnly, siteController.getSiteById);
router.post('/',     adminOnly, siteController.createSite);
router.put('/:id',   adminOnly, siteController.updateSite);
router.delete('/:id',adminOnly, siteController.deleteSite);

module.exports = router;
