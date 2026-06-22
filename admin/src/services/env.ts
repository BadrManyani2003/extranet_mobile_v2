/**
 * Initialise l'environnement global à partir des variables d'environnement (Vite).
 * Le chargement dynamique du .env a été retiré pour des raisons de sécurité.
 */
export async function loadEnv(): Promise<void> {
  // Injection dans l'objet global window
  (window as any).APP_ENV = {
    VITE_API_URL: import.meta.env.VITE_API_URL,
    VITE_KEYCLOAK_URL: import.meta.env.VITE_KEYCLOAK_URL,
    VITE_KEYCLOAK_REALM: import.meta.env.VITE_KEYCLOAK_REALM,
    VITE_KEYCLOAK_CLIENT_ID: import.meta.env.VITE_KEYCLOAK_CLIENT_ID,
  };
}
