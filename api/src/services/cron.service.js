const db = require('./db.service');
const emailService = require('./email.service');
const { getReclamationEmailHtml } = require('../templates/reclamation.template');

const processReclamationEmails = async () => {
    try {
        const qry = `EXEC dbo.sp_GetRecNotificationMail`;
        const result = await db.execute(qry);
        const pendingEmails = result[0] || [];

        for (const record of pendingEmails) {
            const { 
                DetailId, ReclamationId, Sujet, ReclamationNature, 
                MessageNature, Message, DateMessage, ClientName, 
                EmailChargeCompte, SenderType, ClientUserId
            } = record;

            let recipients = [];
            let emailSubject = `Nouvelle notification de réclamation - MyASK`;
            let emailIntro = '';

            const natureMap = {
                'S': 'Sinistre',
                'C': 'Comptabilité',
                'I': "Demande d'information",
                'D': "Demande de correction"
            };
            const natureComplet = natureMap[ReclamationNature] || ReclamationNature;

            if (SenderType === 'CABINET') {
                // Si le dernier message vient du cabinet, envoyer au client (sur son user)
                // On utilise la proc stockée existante pour avoir l'email du client (comme avant)
                const qryClientEmails = `EXEC dbo.sp_GetClientEmailsByUser @0`;
                const clientDbResult = await db.execute(qryClientEmails, [ClientUserId]);
                const clients = clientDbResult[0] || [];
                if (clients.length > 0 && clients[0].emails) {
                    recipients = clients[0].emails.split(/[,/]/).map(e => e.trim()).filter(e => e.length > 0);
                }
                emailIntro = `Le cabinet a répondu à votre réclamation concernant le sujet "${Sujet}".`;
            } else {
                // Si le dernier message vient du client, envoyer au chargé de compte
                if (EmailChargeCompte) {
                    recipients = EmailChargeCompte.split(/[,/]/).map(e => e.trim()).filter(e => e.length > 0);
                }
                emailIntro = `Le client ${ClientName} a envoyé un nouveau message sur la réclamation "${Sujet}".`;
            }

            if (recipients.length > 0) {
                const emailText = `${emailIntro}\nSujet: ${Sujet}\nNature: ${natureComplet}\nDate: ${new Date(DateMessage).toLocaleDateString('fr-FR')}\nMessage: ${Message}`;
                
                const emailHtml = getReclamationEmailHtml({ emailIntro, ClientName, Sujet, natureComplet, Message });

                // Mettre en file d'attente pour chaque destinataire
                recipients.forEach(email => {
                    emailService.enqueueEmail(email, emailSubject, emailText, emailHtml);
                });
            }

            // Marquer comme envoyé dans tous les cas (même si pas de destinataire, pour ne pas re-boucler)
            await db.execute(`EXEC dbo.sp_MarkReclamationEmailSent @0`, [DetailId]);
        }
    } catch (err) {
        console.error('[CronService] Erreur lors du traitement des emails de réclamation:', err.message);
    }
};

const startCron = () => {
    // Exécuter toutes les minutes (60000 ms)
    setInterval(processReclamationEmails, 60 * 1000);
    console.log('[CronService] Service de notifications retardées démarré (intervalle: 1 minute).');
};

module.exports = {
    startCron,
    processReclamationEmails
};
