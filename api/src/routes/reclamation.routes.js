const router = require('express').Router();
const auth   = require('../middleware/auth');
const ctrl   = require('../controllers/reclamation.controller');

router.use(auth);

const adminOrCom  = auth.checkRole(['admin_cabinet', 'commercial_cabinet']);
const allRoles    = auth.checkRole(['admin_cabinet', 'commercial_cabinet', 'client', 'adherent']);

// Réclamations (admin/commercial ou client/adhérent)
router.post('/list',           allRoles, ctrl.getReclamations);

// Réclamations client/adhérent
router.post('/detail',         allRoles, ctrl.getReclamationDetails);
router.post('/create',         allRoles, ctrl.createReclamation);
router.post('/add-message',    allRoles, ctrl.addMessage);

// Mise à jour statut & suppression : admin + commercial (leurs clients)
router.post('/update-statut',  adminOrCom, ctrl.updateStatus);
router.post('/delete',         allRoles, ctrl.deleteReclamation);
router.post('/delete-message', adminOrCom, ctrl.deleteMessage);

module.exports = router;