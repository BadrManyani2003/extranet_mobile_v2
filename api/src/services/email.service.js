const nodemailer = require('nodemailer');

const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS
    }
});

const sendQueue = [];
let isSending = false;

const processQueue = async () => {
    if (isSending || sendQueue.length === 0) return;
    isSending = true;

    while (sendQueue.length > 0) {
        const { to, subject, text, html } = sendQueue.shift();
        
        try {
            const mailOptions = {
                from: process.env.SMTP_USER,
                to,
                subject,
                text
            };
            if (html) {
                mailOptions.html = html;
            }
            await transporter.sendMail(mailOptions);
            console.log(`[EmailService] Email envoye avec succes a : ${to}`);
        } catch (error) {
            console.error(`[EmailService] Erreur lors de l'envoi a ${to}:`, error.message);
        }
        
        // Attente aléatoire entre 2 et 5 secondes (2000 à 5000 ms)
        const delay = Math.floor(Math.random() * 3000) + 2000;
        await new Promise(resolve => setTimeout(resolve, delay));
    }

    isSending = false;
};

const enqueueEmail = (to, subject, text, html) => {
    if (!process.env.SMTP_USER || !process.env.SMTP_PASS) {
        console.warn("[EmailService] Impossible de mettre en file d'attente : identifiants SMTP manquants dans le .env.");
        return;
    }
    
    sendQueue.push({ to, subject, text, html });
    console.log(`[EmailService] Email ajoute a la file d'attente pour : ${to}`);
    processQueue();
};

module.exports = { enqueueEmail };
