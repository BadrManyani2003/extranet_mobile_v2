import { request } from './BaseClient'

export const DataService = {
  getUserInfo: () => request<any>('/auth/me', { method: 'GET' }),
  getPolices: () => request<any[]>('/data/polices', { method: 'GET' }),
  getRisques: (policeId: number) => request<any[]>('/data/risques', { method: 'GET', body: JSON.stringify({ policeId }) }),
  getSinistres: (policeId: number) => request<any[]>('/data/sinistres', { method: 'GET', body: JSON.stringify({ policeId }) }),
  getSinistresEnCours: (policeId: number) => request<any[]>('/data/sinistres/en-cours', { method: 'GET', body: JSON.stringify({ policeId }) }),
  getQuittances: (policeId: number) => request<any[]>('/data/quittances', { method: 'GET', body: JSON.stringify({ policeId }) }),
  getImpayes: (policeId?: number, enCour: 'O' | 'N' = 'O') => request<any[]>('/data/quittances/impayes', { method: 'GET', body: JSON.stringify({ policeId: policeId || '', enCour }) }),
  getStatsByPolice: (policeId: number) => request<any>('/data/stats/police', { method: 'GET', body: JSON.stringify({ policeId }) }),
  getStatsKPIs: (policeId: number, dateDu: string, dateAu: string) => request<any>('/data/stats/kpis', { method: 'GET', body: JSON.stringify({ policeId, dateDu, dateAu }) }),
  getStatsEvolutionAnnuelle: (policeId: number, dateDu: string, dateAu: string) => request<any[]>('/data/stats/evolution-annuelle', { method: 'GET', body: JSON.stringify({ policeId, dateDu, dateAu }) }),
  getStatsTop5ITT: (policeId: number, dateDu: string, dateAu: string) => request<any[]>('/data/stats/top5-itt', { method: 'GET', body: JSON.stringify({ policeId, dateDu, dateAu }) }),
  getStatsTop10Victimes: (policeId: number, dateDu: string, dateAu: string) => request<any[]>('/data/stats/top10-victimes', { method: 'GET', body: JSON.stringify({ policeId, dateDu, dateAu }) }),
  getStatsRepartition: (policeId: number, dateDu: string, dateAu: string) => request<any[]>('/data/stats/repartition', { method: 'GET', body: JSON.stringify({ policeId, dateDu, dateAu }) }),
  getAdherents: (policeId: number) => request<any[]>('/data/adherents', { method: 'GET', body: JSON.stringify({ policeId }) }),
  getGaranties: (risqueId: number) => request<any[]>('/data/garanties', { method: 'GET', body: JSON.stringify({ risqueId }) }),
  getPersACharge: (adherentId: number) => request<any[]>('/data/adherents/famille', { method: 'GET', body: JSON.stringify({ adherentId }) }),
  getStats: () => request<any[]>('/data/stats', { method: 'GET' }),
  getDocuments: (policeId: number) => request<any[]>('/data/documents', { method: 'GET', body: JSON.stringify({ policeId }) }),
  getSyntheseSinistresAT: (policeId: number | 'all') => request<any[]>('/data/sinistres/synthese/at', { method: 'GET', body: JSON.stringify({ policeId }) }),
  getDashboardBatchStats: (payload: any) => request<any>('/data/stats/dashboard-batch', { method: 'POST', body: JSON.stringify(payload) }),
}
