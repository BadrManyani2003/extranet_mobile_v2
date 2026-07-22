/**
 * Charge la configuration depuis /config.json (servi par Apache comme fichier statique).
 * Ce fichier est dans public/ → copié dans dist/ par Vite automatiquement.
 * Pour changer la config sur le serveur : modifier dist/config.json directement, sans rebuild.
 */
export async function loadEnv(): Promise<void> {
  // config.js is loaded synchronously in index.html, so window.APP_ENV is already set.
  if (!(window as any).APP_ENV) {
    console.warn('⚠️ config.js non chargé, fallback sur import.meta.env');
    (window as any).APP_ENV = {
      VITE_API_URL:            import.meta.env.VITE_API_URL,
      VITE_KEYCLOAK_URL:       import.meta.env.VITE_KEYCLOAK_URL,
      VITE_KEYCLOAK_REALM:     import.meta.env.VITE_KEYCLOAK_REALM,
      VITE_KEYCLOAK_CLIENT_ID: import.meta.env.VITE_KEYCLOAK_CLIENT_ID,
      VITE_SOURCE:             import.meta.env.VITE_SOURCE,
    };
  }
}

/**
 * Getter pour lire les variables de configuration au runtime.
 */
export function getEnv(): Record<string, string> {
  return (window as any).APP_ENV || {};
}
