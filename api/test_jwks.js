const http = require('http');
const https = require('https');
const dotenv = require('dotenv');
const path = require('path');

// Charger le fichier .env
dotenv.config({ path: path.join(__dirname, '.env') });

const realm = process.env.KEYCLOAK_REALM;
const serverUrl = process.env.KEYCLOAK_AUTH_SERVER_URL;

console.log('=== DIAGNOSTIC CONFIGURATION KEYCLOAK ===');
console.log(`KEYCLOAK_REALM : "${realm}"`);
console.log(`KEYCLOAK_AUTH_SERVER_URL : "${serverUrl}"`);

if (!realm || !serverUrl) {
    console.error("❌ Erreur : Les variables KEYCLOAK_REALM ou KEYCLOAK_AUTH_SERVER_URL ne sont pas définies dans le .env !");
    process.exit(1);
}

const jwksUri = `${serverUrl}/realms/${realm}/protocol/openid-connect/certs`;
console.log(`URL JWKS ciblée : ${jwksUri}\n`);

console.log('📡 Envoi de la requête de test...');

const client = serverUrl.startsWith('https') ? https : http;

client.get(jwksUri, (res) => {
    console.log(`Statut HTTP reçu : ${res.statusCode} ${res.statusMessage}`);
    console.log(`Content-Type : ${res.headers['content-type']}`);
    
    let data = '';
    res.on('data', (chunk) => { data += chunk; });
    res.on('end', () => {
        console.log('\n--- RÉPONSE DU SERVEUR ---');
        try {
            const parsed = JSON.parse(data);
            console.log(JSON.stringify(parsed, null, 2));
            if (parsed.keys && Array.isArray(parsed.keys) && parsed.keys.length > 0) {
                console.log(`\n✅ SUCCÈS ! L'endpoint a renvoyé ${parsed.keys.length} clé(s) de signature.`);
            } else {
                console.log(`\n❌ ÉCHEC : La réponse ne contient pas de clés de signature (keys) valides.`);
            }
        } catch (e) {
            console.log(`❌ ÉCHEC : La réponse n'est pas du JSON valide (probablement une page d'erreur HTML ou redirection).`);
            console.log('Extrait de la réponse reçue :');
            console.log(data.substring(0, 500));
        }
    });
}).on('error', (err) => {
    console.error(`\n❌ ERREUR DE CONNEXION : Impossible de joindre Keycloak.`);
    console.error(`Détails : ${err.message}`);
});
