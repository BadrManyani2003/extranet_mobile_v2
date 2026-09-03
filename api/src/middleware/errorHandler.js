const { error } = require('../common/response');

module.exports = (err, req, res, next) => {
    let status = err.status || 500;
    const message = err.message || "Oups, une erreur inattendue s'est produite. Veuillez réessayer.";

    if (
        err.name === 'RequestError' ||
        err.code === 'EREQUEST' ||
        message.includes('Impossible de supprimer') ||
        message.includes('deja utilise') ||
        message.includes('expiree') ||
        message.includes('manquant') ||
        message.includes('non autorise')
    ) {
        status = 400;
    }

    if (status >= 500) {
        console.error(`[Erreur] ${req.method} ${req.path}:`, err.stack || err);
    }

    error(res, message, status);
};
