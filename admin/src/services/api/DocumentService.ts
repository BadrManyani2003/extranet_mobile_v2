import { request } from './BaseClient'

export const DocumentService = {
  /**
   * Récupère la liste de tous les documents chargés (admin uniquement).
   */
  getDocuments: (filters: { nature?: string; identifiant?: number; dateFrom?: string; dateTo?: string } = {}) =>
    request<any[]>('/documents/list', { method: 'POST', body: JSON.stringify(filters) }),

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

  /**
   * Retourne le contenu d'un document par son Id (base64).
   */
  getDocumentById: (documentId: number) =>
    request<any>('/documents/view', { method: 'POST', body: JSON.stringify({ documentId }) }),

  /**
   * Supprime un document par son Id.
   */
  deleteDocument: (documentId: number) =>
    request<any>('/documents/delete', { method: 'POST', body: JSON.stringify({ documentId }) }),

  /**
   * Met à jour le statut transféré d'un document.
   */
  updateDocumentTransfere: (documentId: number, transfere: 'O' | 'N') =>
    request<any>('/documents/update-transfere', { method: 'POST', body: JSON.stringify({ documentId, transfere }) }),
}
