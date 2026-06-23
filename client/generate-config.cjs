/**
 * generate-config.cjs
 * Génère dist/config.js avec les variables d'environnement de production
 * et l'injecte dans dist/index.html avant le chargement de l'app.
 *
 * Priorité : .env.production > .env
 */

const fs = require('fs');
const path = require('path');

// --- 1. Lire le bon fichier .env ---
const envFile = fs.existsSync('.env.production') ? '.env.production' : '.env';
const envContent = fs.readFileSync(envFile, 'utf-8');
console.log(`\n📄 Lecture de : ${envFile}`);

// --- 2. Parser les variables VITE_* ---
const env = {};
for (const line of envContent.split('\n')) {
  const trimmed = line.trim();
  if (!trimmed || trimmed.startsWith('#')) continue;
  const idx = trimmed.indexOf('=');
  if (idx === -1) continue;
  const key = trimmed.substring(0, idx).trim();
  let val = trimmed.substring(idx + 1).trim();
  if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
    val = val.slice(1, -1);
  }
  if (key.startsWith('VITE_')) {
    env[key] = val;
  }
}

// --- 3. Générer dist/config.js ---
const configJs = `// Auto-généré par generate-config.cjs — NE PAS MODIFIER MANUELLEMENT
window.APP_ENV = ${JSON.stringify(env, null, 2)};
`;

fs.writeFileSync(path.join('dist', 'config.js'), configJs, 'utf-8');
console.log('✅ dist/config.js généré avec :');
console.log(JSON.stringify(env, null, 2));

// --- 4. Injecter <script src="/config.js"> dans dist/index.html ---
const indexPath = path.join('dist', 'index.html');
let html = fs.readFileSync(indexPath, 'utf-8');

if (!html.includes('config.js')) {
  html = html.replace('<head>', '<head>\n    <script src="/config.js"></script>');
  fs.writeFileSync(indexPath, html, 'utf-8');
  console.log('✅ dist/index.html mis à jour : <script src="/config.js"> injecté');
} else {
  console.log('ℹ️  dist/index.html contient déjà config.js');
}
