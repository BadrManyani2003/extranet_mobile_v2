const router = require('express').Router();
const auth   = require('../middleware/auth');
const ctrl   = require('../controllers/document.controller');

router.use(auth);

const allRoles   = auth.checkRole(['admin_cabinet', 'commercial_cabinet', 'client', 'adherent', 'expert']);
const adminOnly  = auth.checkRole(['admin_cabinet']);

// Upload : accessible à tous les rôles authentifiés
router.post('/upload', allRoles, ctrl.uploadDocument);

// Liste des documents : admin uniquement
router.post('/list',   adminOnly, ctrl.getDocuments);

// Suppression d'un document : admin uniquement
router.post('/delete', adminOnly, ctrl.deleteDocument);

// Mise à jour du statut transféré : admin uniquement
router.post('/update-transfere', adminOnly, ctrl.updateDocumentTransfere);

// Consultation d'un document : tous les rôles
router.post('/view',   allRoles, ctrl.getDocumentById);

module.exports = router;
