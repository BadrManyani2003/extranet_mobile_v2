const router = require('express').Router();

router.use('/auth',         require('./auth.routes'));
router.use('/data',         require('./data.routes'));
router.use('/reclamations', require('./reclamation.routes'));
router.use('/admin',        require('./admin.routes'));
router.use('/documents',    require('./document.routes'));
router.use('/sites',        require('./site.routes'));
router.use('/app-roles',    require('./siteRole.routes'));

module.exports = router;