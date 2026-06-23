/**
 * Charge les variables d'environnement depuis window.APP_ENV
 * (injecté par /config.js au démarrage de l'app via index.html).
 *
 * En dev, window.APP_ENV n'existe pas → fallback sur import.meta.env (Vite).
 * En prod, config.js est généré par generate-config.cjs depuis .env.production.
 */
export async function loadEnv(): Promise<void> {
  const appEnv = (window as any).APP_ENV;

  if (appEnv && appEnv.VITE_KEYCLOAK_URL) {
    // Production : config.js a été chargé → rien à faire
    console.log('✅ Configuration chargée depuis window.APP_ENV (config.js) :', appEnv);
    return;
  }

  // Développement : pas de config.js → utiliser import.meta.env
  console.log('ℹ️ Pas de window.APP_ENV, utilisation des variables Vite (mode dev)');
  (window as any).APP_ENV = {
    VITE_API_URL:            import.meta.env.VITE_API_URL,
    VITE_KEYCLOAK_URL:       import.meta.env.VITE_KEYCLOAK_URL,
    VITE_KEYCLOAK_REALM:     import.meta.env.VITE_KEYCLOAK_REALM,
    VITE_KEYCLOAK_CLIENT_ID: import.meta.env.VITE_KEYCLOAK_CLIENT_ID,
    VITE_SOURCE:             import.meta.env.VITE_SOURCE,
  };
}

/**
 * Getter sécurisé pour les variables d'environnement.
 * Toujours lire via cette fonction, jamais directement via import.meta.env en prod.
 */
export function getEnv() {
  return (window as any).APP_ENV || {};
}
