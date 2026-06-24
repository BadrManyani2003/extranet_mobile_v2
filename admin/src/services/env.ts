/**
 * Charge la configuration depuis /config.json (servi par Apache comme fichier statique).
 * Ce fichier est dans public/ → copié dans dist/ par Vite automatiquement.
 * Pour changer la config sur le serveur : modifier dist/config.json directement, sans rebuild.
 */
export async function loadEnv(): Promise<void> {
  try {
    const response = await fetch(`/config.json?t=${Date.now()}`, { cache: 'no-store' });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const config = await response.json();
    (window as any).APP_ENV = config;
    console.log('✅ Configuration chargée depuis /config.json :', config);

  } catch (error) {
    // Fallback en dev (Vite sert aussi config.json via public/)
    console.warn('⚠️ Impossible de charger /config.json, fallback sur import.meta.env :', error);
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
