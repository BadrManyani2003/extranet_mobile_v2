import { request } from './BaseClient'

export const DocumentService = {
  /**
   * Charge un document lié à une entité (ex: sinistre).
   * @param nature       Nature de l'entité ('Sinistre', 'Contrat', etc.)
   * @param identifiant  Id de l'entité concernée
   * @param type         Description libre du type de document
   * @param fileBase64   Contenu du fichier encodé en base64
   * @param fk_site_id       Id du site optionnel
   */
  uploadDocument: (nature: string, identifiant: number, type: string, fileBase64: string, fk_site_id?: number) => {
    // S'il n'est pas fourni par le composant, on tente de le récupérer depuis le cookie/localStorage
    if (!fk_site_id) {
      function getCookie(name: string): string | null {
        const nameEQ = name + "=";
        const ca = document.cookie.split(';');
        for (let i = 0; i < ca.length; i++) {
            let c = ca[i];
            while (c.charAt(0) === ' ') c = c.substring(1, c.length);
            if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
        }
        return null;
      }
      const stored = getCookie('currentSiteId') || localStorage.getItem('currentSiteId');
      if (stored) fk_site_id = Number(stored);
    }

    return request<any>('/documents/upload', {
      method: 'POST',
      body: JSON.stringify({ nature, identifiant, type, fileBase64, fk_site_id })
    });
  },
}
