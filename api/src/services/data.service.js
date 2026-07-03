const db = require('./db.service');
const qry = require('../sql/qryExtranet');

const getPolices = (userId, source, token) => db.execute(qry.getPolices, [userId, source, token]);

const getSinistres = (userId, source, token, policeId) => db.execute(qry.getSinistres, [userId, source, token, policeId]);

const getSinistresEnCours = (userId, source, token, policeId) => db.execute(qry.getSinistresEnCours, [userId, source, token, policeId]);

const getRisques = (userId, source, token, policeId) => db.execute(qry.getRisques, [userId, source, token, policeId]);

const getGaranties = (userId, source, token, risqueId) => db.execute(qry.getGarantiesByRisque, [userId, source, token, risqueId]);

const getQuittances = (userId, source, token, policeId) => db.execute(qry.getQuittances, [userId, source, token, policeId]);

const getImpayes = (userId, source, token, policeId, enCour) => db.execute(qry.getImpayes, [userId, source, token, policeId, enCour]);

const getAdherents = (userId, source, token, policeId) => db.execute(qry.getAdherents, [userId, source, token, policeId]);

const getPersACharge = (userId, source, token, adherentId) => db.execute(qry.getPersACharge, [userId, source, token, adherentId]);

const getStats = (userId, source, token) => db.execute(qry.getStats, [userId, source, token]);
const getStatsKPIs = (userId, source, token, policeId, dateDu, dateAu) => db.execute(qry.getStatsKPIs, [userId, source, token, policeId, dateDu, dateAu]);
const getStatsEvolutionAnnuelle = (userId, source, token, policeId, dateDu, dateAu) => db.execute(qry.getStatsEvolutionAnnuelle, [userId, source, token, policeId, dateDu, dateAu]);
const getStatsTop5ITT = (userId, source, token, policeId, dateDu, dateAu) => db.execute(qry.getStatsTop5ITT, [userId, source, token, policeId, dateDu, dateAu]);
const getStatsTop10Victimes = (userId, source, token, policeId, dateDu, dateAu) => db.execute(qry.getStatsTop10Victimes, [userId, source, token, policeId, dateDu, dateAu]);
const getStatsRepartition = (userId, source, token, policeId, dateDu, dateAu) => db.execute(qry.getStatsRepartition, [userId, source, token, policeId, dateDu, dateAu]);

const getStatsByPolice = (userId, source, token, policeId) => db.execute(qry.getStatsByPolice, [userId, token, source, policeId]);
const getDocumentsByPolice = (userId, source, token, policeId) => db.execute(qry.getDocumentsByPolice, [userId, source, token, policeId]);
const getSyntheseSinistresAT = (policeId) => db.execute(qry.getSyntheseSinistresAT, [policeId]);

module.exports = {
    getPolices,
    getSinistres,
    getSinistresEnCours,
    getRisques,
    getGaranties,
    getQuittances,
    getImpayes,
    getAdherents,
    getPersACharge,
    getStats,
    getStatsKPIs,
    getStatsEvolutionAnnuelle,
    getStatsTop5ITT,
    getStatsTop10Victimes,
    getStatsRepartition,
    getStatsByPolice,
    getDocumentsByPolice,
    getSyntheseSinistresAT
};
