const documentService = require('../services/document.service');
const { success }     = require('../common/response');
const asyncHandler    = require('../middleware/asyncHandler');
const db              = require('../services/db.service');
const emailService    = require('../services/email.service');
const { getDocumentEmailHtml } = require('../templates/document.template');

const getContext = (req) => ({
    userId: req.user.id,
    token:  req.user.token,
    source: req.headers['x-source'] || 'E',
    siteId: req.siteId || null
});

/**
 * POST /api/documents/upload
 * Corps : { nature, identifiant, type, fileBase64, fileName }
 * Accessible à tous les rôles authentifiés (client, adherent, expert, admin).
 */
const uploadDocument = asyncHandler(async (req, res) => {
    const { userId, token, siteId: contextSiteId } = getContext(req);
    const { nature, identifiant, type, fileBase64, siteId: bodySiteId } = req.body;

    const finalSiteId = bodySiteId || contextSiteId;

    if (!finalSiteId) {
        throw new Error("L'identifiant du site (siteId) est manquant. Veuillez sélectionner un site.");
    }

    if (!nature || !identifiant || !type || !fileBase64) {
        throw new Error('Paramètres manquants : nature, identifiant, type et fileBase64 sont requis.');
    }

    // Décoder le base64 en Buffer binaire
    const documentBuffer = Buffer.from(fileBase64, 'base64');

    // Limiter la taille à 20 Mo
    if (documentBuffer.length > 20 * 1024 * 1024) {
        throw new Error('Le fichier dépasse la taille maximale autorisée (20 Mo).');
    }

    let result;
    try {
        result = await documentService.upload(userId, token, finalSiteId, nature, parseInt(identifiant), type, documentBuffer);
    } catch (err) {
        console.error("ERREUR SQL UPLOAD DOCUMENT:", err);
        throw err;
    }

    // -- Début de l'envoi d'email asynchrone --
    try {
        const qryEmails = `EXEC dbo.sp_GetClientEmailsByUser @0`;
        const dbResult = await db.execute(qryEmails, [userId]);
        const clients = dbResult[0] || [];

        if (clients.length > 0) {
            const clientName = clients[0].clientName;
            const emailString = clients[0].emails;
            
            const rawEmails = emailString.split(/[,/]/).map(e => e.trim()).filter(e => e.length > 0);
            
            if (rawEmails.length > 0) {
                const emailSubject = `Nouveau document chargé - MyASK`;
                const emailText = `Le client ${clientName} a chargé un nouveau document.\nNature : ${nature}\nType : ${type}\nIdentifiant : ${identifiant}\nDate : ${new Date().toLocaleDateString('fr-FR')}`;
                
                const emailHtml = getDocumentEmailHtml({ 
                    clientName: clientName, 
                    nature: nature, 
                    type: type, 
                    identifiant: identifiant, 
                    dateStr: new Date().toLocaleDateString('fr-FR') 
                });
                
                rawEmails.forEach(email => {
                    emailService.enqueueEmail(email, emailSubject, emailText, emailHtml);
                });
            }
        }
    } catch (err) {
        console.error("[Document] Erreur lors de la préparation de l'envoi d'emails :", err.message);
    }
    // -- Fin de l'envoi d'email --

    success(res, result[0]?.[0] || {}, 'Document chargé avec succès');
});

/**
 * POST /api/documents/list
 * Corps : { nature?, identifiant?, dateFrom?, dateTo? }
 * Accessible aux rôles admin_cabinet et commercial_cabinet uniquement.
 */
const getDocuments = asyncHandler(async (req, res) => {
    const { userId, token, source } = getContext(req);
    const { nature, identifiant, dateFrom, dateTo } = req.body;

    const result = await documentService.getDocuments(userId, token, source, nature, identifiant, dateFrom, dateTo);
    success(res, result[0] || []);
});

/**
 * POST /api/documents/view
 * Corps : { documentId }
 * Retourne le contenu binaire encodé en base64 pour l'affichage frontend.
 */
const getDocumentById = asyncHandler(async (req, res) => {
    const { userId, token, source } = getContext(req);
    const { documentId } = req.body;

    if (!documentId) throw new Error('documentId manquant.');

    const result = await documentService.getDocumentById(userId, token, source, documentId);
    const doc = result[0]?.[0];

    if (!doc) throw new Error('Document introuvable.');

    // Convertir le Buffer VARBINARY en base64 pour le frontend
    const docWithBase64 = {
        ...doc,
        document: doc.document ? doc.document.toString('base64') : null
    };

    success(res, docWithBase64);
});

/**
 * POST /api/documents/delete
 * Corps : { documentId }
 * Accessible aux rôles admin_cabinet et commercial_cabinet uniquement.
 */
const deleteDocument = asyncHandler(async (req, res) => {
    const { userId, token, source, siteId } = getContext(req);
    const { documentId } = req.body;

    if (!documentId) throw new Error('documentId manquant.');

    await documentService.deleteDocument(userId, token, source, siteId, documentId);
    success(res, null, 'Document supprimé avec succès');
});

/**
 * POST /api/documents/update-transfere
 * Corps : { documentId, transfere }
 * Accessible aux rôles admin_cabinet et commercial_cabinet uniquement.
 */
const updateDocumentTransfere = asyncHandler(async (req, res) => {
    const { userId, token, source, siteId } = getContext(req);
    const { documentId, transfere } = req.body;

    if (!documentId) throw new Error('documentId manquant.');
    if (!transfere || (transfere !== 'O' && transfere !== 'N')) {
        throw new Error("Paramètre 'transfere' invalide ou manquant (doit être 'O' ou 'N').");
    }

    await documentService.updateDocumentTransfere(userId, token, source, siteId, documentId, transfere);
    success(res, null, 'Statut de transfert mis à jour avec succès');
});

module.exports = { uploadDocument, getDocuments, getDocumentById, deleteDocument, updateDocumentTransfere };
