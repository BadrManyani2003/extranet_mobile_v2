const getDocumentEmailHtml = ({ clientName, nature, type, identifiant, dateStr }) => {
    return `
    <div style="font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; max-width: 600px; margin: 0 auto; background-color: #ffffff; border: 1px solid #e0e0e0; border-radius: 8px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
        <div style="background-color: #0056b3; color: #ffffff; padding: 20px; text-align: center;">
            <h2 style="margin: 0; font-size: 24px; font-weight: 600;">Nouveau Document</h2>
            <p style="margin: 5px 0 0 0; font-size: 14px; opacity: 0.9;">MyASK</p>
        </div>
        
        <div style="padding: 30px 20px;">
            <p style="font-size: 16px; color: #333333; margin-top: 0;">Bonjour,</p>
            <p style="font-size: 15px; color: #555555; line-height: 1.6;">Un nouveau document a été chargé par un client. Voici les détails :</p>
            
            <div style="background-color: #f8f9fa; border-radius: 6px; padding: 15px; margin: 20px 0;">
                <table style="width: 100%; border-collapse: collapse;">
                    <tr>
                        <td style="padding: 8px 0; color: #666666; font-size: 14px; font-weight: 600; width: 35%; border-bottom: 1px solid #eeeeee;">Client</td>
                        <td style="padding: 8px 0; color: #333333; font-size: 15px; font-weight: bold; border-bottom: 1px solid #eeeeee;">${clientName}</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #666666; font-size: 14px; font-weight: 600; border-bottom: 1px solid #eeeeee;">Nature</td>
                        <td style="padding: 8px 0; color: #333333; font-size: 15px; border-bottom: 1px solid #eeeeee;">${nature}</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #666666; font-size: 14px; font-weight: 600; border-bottom: 1px solid #eeeeee;">Type</td>
                        <td style="padding: 8px 0; color: #333333; font-size: 15px; border-bottom: 1px solid #eeeeee;">${type}</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #666666; font-size: 14px; font-weight: 600; border-bottom: 1px solid #eeeeee;">Identifiant</td>
                        <td style="padding: 8px 0; color: #333333; font-size: 15px; border-bottom: 1px solid #eeeeee;">${identifiant}</td>
                    </tr>
                    <tr>
                        <td style="padding: 8px 0; color: #666666; font-size: 14px; font-weight: 600;">Date</td>
                        <td style="padding: 8px 0; color: #333333; font-size: 15px;">${dateStr}</td>
                    </tr>
                </table>
            </div>
        </div>
        
        <div style="background-color: #f1f1f1; padding: 15px; text-align: center; border-top: 1px solid #e0e0e0;">
            <p style="margin: 0; font-size: 12px; color: #888888;">Cet email a été généré automatiquement par l'application MyASK.</p>
            <p style="margin: 5px 0 0 0; font-size: 12px; color: #888888;">Merci de ne pas répondre à ce message.</p>
        </div>
    </div>
    `;
};

module.exports = { getDocumentEmailHtml };
