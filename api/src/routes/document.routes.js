const router = require('express').Router();
const auth   = require('../middleware/auth');
const ctrl   = require('../controllers/document.controller');
const { requirePermission } = require('../middleware/permissionHandler');

router.use(auth);

const allRoles   = auth.checkRole(['admin_cabinet', 'commercial_cabinet', 'client', 'adherent', 'expert']);
const adminOrCom = auth.checkRole(['admin_cabinet', 'commercial_cabinet']);

// Upload : accessible à tous les rôles authentifiés
router.post('/upload', allRoles, ctrl.uploadDocument);

// Liste des documents : contrôlée par documents:lire
router.post('/list',   adminOrCom, requirePermission('documents:lire'), ctrl.getDocuments);

// Suppression d'un document : contrôlée par documents:supprimer
router.post('/delete', adminOrCom, requirePermission('documents:supprimer'), ctrl.deleteDocument);

// Mise à jour du statut transféré : contrôlée par documents:modifier
router.post('/update-transfere', adminOrCom, requirePermission('documents:modifier'), ctrl.updateDocumentTransfere);

// Consultation d'un document : tous les rôles
router.post('/view',   allRoles, ctrl.getDocumentById);

module.exports = router;
