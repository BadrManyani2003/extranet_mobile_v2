const dataService = require('../services/data.service');
const { success } = require('../common/response');
const asyncHandler = require('../middleware/asyncHandler');

const getContext = (req) => ({
    userId: req.user.id,
    token:  req.user.token,
    source: req.headers['x-source'] || 'E'
});

const getPolices = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const result = await dataService.getPolices(userId, source, token);
    success(res, result[0] || []);
});

const getSinistres = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { policeId } = req.query;
    const result = await dataService.getSinistres(userId, source, token, policeId);
    success(res, result[0] || []);
});

const getSinistresEnCours = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { policeId } = req.query;
    const result = await dataService.getSinistresEnCours(userId, source, token, policeId);
    success(res, result[0] || []);
});

const getRisques = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { policeId } = req.query;
    const result = await dataService.getRisques(userId, source, token, policeId);
    success(res, result[0] || []);
});

const getGaranties = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { risqueId } = req.query;
    const result = await dataService.getGaranties(userId, source, token, risqueId);
    success(res, result[0] || []);
});

const getQuittances = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { policeId } = req.query;
    const result = await dataService.getQuittances(userId, source, token, policeId);
    success(res, result[0] || []);
});

const getImpayes = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { policeId, enCour } = req.query;
    const result = await dataService.getImpayes(userId, source, token, policeId, enCour);
    success(res, result[0] || []);
});

const getAdherents = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { policeId } = req.query;
    const result = await dataService.getAdherents(userId, source, token, policeId);
    success(res, result[0] || []);
});

const getPersACharge = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { adherentId } = req.query;
    const result = await dataService.getPersACharge(userId, source, token, adherentId);
    success(res, result[0] || []);
});

const getStats = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const result = await dataService.getStats(userId, source, token);
    if (source === 'M') {
        success(res, result[0]?.[0] || {});
    } else {
        success(res, result || []);
    }
});

const getStatsByPolice = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { policeId } = req.query;
    const result = await dataService.getStatsByPolice(userId, source, token, policeId);
    success(res, result[0]?.[0] || {});
});

const getStatsKPIs = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { policeId, dateDu, dateAu } = req.query;
    const result = await dataService.getStatsKPIs(userId, source, token, policeId, dateDu, dateAu);
    success(res, result[0]?.[0] || {});
});

const getStatsEvolutionAnnuelle = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { policeId, dateDu, dateAu } = req.query;
    const result = await dataService.getStatsEvolutionAnnuelle(userId, source, token, policeId, dateDu, dateAu);
    success(res, result[0] || []);
});

const getStatsTop5ITT = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { policeId, dateDu, dateAu } = req.query;
    const result = await dataService.getStatsTop5ITT(userId, source, token, policeId, dateDu, dateAu);
    success(res, result[0] || []);
});

const getStatsTop10Victimes = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { policeId, dateDu, dateAu } = req.query;
    const result = await dataService.getStatsTop10Victimes(userId, source, token, policeId, dateDu, dateAu);
    success(res, result[0] || []);
});

const getStatsRepartition = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { policeId, dateDu, dateAu } = req.query;
    const result = await dataService.getStatsRepartition(userId, source, token, policeId, dateDu, dateAu);
    success(res, result || []);
});

const getDocumentsByPolice = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { policeId } = req.query;
    const result = await dataService.getDocumentsByPolice(userId, source, token, policeId);
    success(res, result[0] || []);
});

const getSyntheseSinistresAT = asyncHandler(async (req, res) => {
    const { policeId } = req.query;
    // We pass policeId, or -1 if all polices (if policeId is not provided or 'all')
    const pid = (!policeId || policeId === 'all') ? -1 : parseInt(policeId, 10);
    const result = await dataService.getSyntheseSinistresAT(pid);
    success(res, result[0] || []);
});

const getDashboardBatchStats = asyncHandler(async (req, res) => {
    const { userId, source, token } = getContext(req);
    const { policyIds, dateDu, dateAu, isATBranch, currentModuleType, policiesMetadata } = req.body;
    
    if (!policyIds || policyIds.length === 0) {
        return success(res, null);
    }
    
    const allKpis = [];
    const allEvolution = [];
    const allTop5 = [];
    const allRepartition = [];
    const allTop10 = [];

    const chunkSize = 5;
    for (let i = 0; i < policyIds.length; i += chunkSize) {
        const batchIds = policyIds.slice(i, i + chunkSize);
        
        const [batchKpis, batchEvolution, batchTop5, batchRepartition, batchTop10Result] = await Promise.all([
            Promise.all(batchIds.map(id => dataService.getStatsKPIs(userId, source, token, id, dateDu, dateAu).then(r => r[0]?.[0]))),
            Promise.all(batchIds.map(id => dataService.getStatsEvolutionAnnuelle(userId, source, token, id, dateDu, dateAu).then(r => r[0]))),
            isATBranch ? Promise.all(batchIds.map(id => dataService.getStatsTop5ITT(userId, source, token, id, dateDu, dateAu).then(r => r[0]))) : Promise.resolve([]),
            isATBranch ? Promise.all(batchIds.map(id => dataService.getStatsRepartition(userId, source, token, id, dateDu, dateAu).then(r => r))) : Promise.resolve([]),
            isATBranch ? Promise.all(batchIds.map(id => dataService.getStatsTop10Victimes(userId, source, token, id, dateDu, dateAu).then(r => r[0]))) : Promise.resolve([])
        ]);

        allKpis.push(...batchKpis);
        allEvolution.push(...batchEvolution);
        allTop5.push(...batchTop5);
        allRepartition.push(...batchRepartition);
        allTop10.push(...batchTop10Result);
    }

    // 1. Aggregate KPIs
    let nbSinistresTotal = 0; let coutTotal = 0; let totalJoursITT = 0; let nbSinistresWithITT = 0; let mntITTTotal = 0; let nbSinistresWithIPP = 0; let ccrTotal = 0;
    allKpis.forEach(k => {
        if (!k) return;
        nbSinistresTotal += k.nbSinistresTotal || 0; coutTotal += k.coutTotal || 0; totalJoursITT += k.totalJoursITT || 0;
        nbSinistresWithITT += k.nbSinistresWithITT || 0; mntITTTotal += k.mntITTTotal || 0; nbSinistresWithIPP += k.nbSinistresWithIPP || 0; ccrTotal += k.ccrTotal || 0;
    });

    const kpis = {
        nbSinistresTotal, coutTotal, coutMoyen: nbSinistresTotal > 0 ? coutTotal / nbSinistresTotal : 0,
        totalJoursITT, nbSinistresWithITT, tauxITT: nbSinistresTotal > 0 ? (nbSinistresWithITT / nbSinistresTotal) * 100 : 0,
        dureeMoyenneITT: nbSinistresWithITT > 0 ? totalJoursITT / nbSinistresWithITT : 0,
        mntITTTotal, nbSinistresWithIPP, ccrTotal
    };

    // 2. Aggregate Evolution
    const evolutionMap = {};
    allEvolution.forEach(arr => {
        if (!Array.isArray(arr)) return;
        arr.forEach(item => {
            const y = item.annee;
            if (!evolutionMap[y]) evolutionMap[y] = { annee: y, nbSinistres: 0, coutTotal: 0, nbITT: 0, joursITT: 0, mntITT: 0 };
            evolutionMap[y].nbSinistres += item.nbSinistres || 0; evolutionMap[y].coutTotal += item.coutTotal || 0;
            evolutionMap[y].nbITT += item.nbITT || 0; evolutionMap[y].joursITT += item.joursITT || 0; evolutionMap[y].mntITT += item.mntITT || 0;
        });
    });
    const finalEvolution = Object.values(evolutionMap).map(item => {
        item.tauxITT = item.nbSinistres > 0 ? (item.nbITT / item.nbSinistres) * 100 : 0; return item;
    }).sort((a, b) => a.annee - b.annee);
    const evolutionData = finalEvolution.length > 0 ? finalEvolution : null;

    // 3. Aggregate Top 5
    const mergedTop5 = [];
    allTop5.forEach(arr => { if (Array.isArray(arr)) mergedTop5.push(...arr); });
    mergedTop5.sort((a, b) => (b.joursITT || 0) - (a.joursITT || 0));
    const top5ITTData = mergedTop5.slice(0, 5);

    // 4. Aggregate Repartition
    const circonstancesMap = {}; const lesionsMap = {}; const typesMap = {};
    allRepartition.forEach(rep => {
        if (!rep || !Array.isArray(rep)) return;
        if (Array.isArray(rep[0])) rep[0].forEach(item => circonstancesMap[item.categorie] = (circonstancesMap[item.categorie] || 0) + (item.countVal || 0));
        if (Array.isArray(rep[1])) rep[1].forEach(item => lesionsMap[item.categorie] = (lesionsMap[item.categorie] || 0) + (item.countVal || 0));
        if (Array.isArray(rep[2])) rep[2].forEach(item => {
            if (!typesMap[item.categorie]) typesMap[item.categorie] = { countVal: 0 };
            typesMap[item.categorie].countVal += item.countVal || 0;
        });
    });
    const circonstancesList = Object.entries(circonstancesMap).map(([categorie, countVal]) => ({ categorie, countVal })).sort((a, b) => b.countVal - a.countVal);
    const lesionsList = Object.entries(lesionsMap).map(([categorie, countVal]) => ({ categorie, countVal })).sort((a, b) => b.countVal - a.countVal);
    const typeTotal = Object.values(typesMap).reduce((acc, curr) => acc + curr.countVal, 0);
    const typesList = Object.entries(typesMap).map(([categorie, data]) => ({
        categorie, countVal: data.countVal, pourcentage: typeTotal > 0 ? (data.countVal / typeTotal) * 100 : 0
    })).sort((a, b) => b.countVal - a.countVal);
    const repartitionData = [circonstancesList, lesionsList, typesList];

    // 5. Aggregate Top 10 Victimes
    const victimeCount = {};
    allTop10.forEach(arr => {
        if (!Array.isArray(arr)) return;
        arr.forEach(item => { if (item.nom) victimeCount[item.nom] = (victimeCount[item.nom] || 0) + (item.count || 0); });
    });
    const top10 = Object.entries(victimeCount).map(([nom, count]) => ({ nom, count })).sort((a, b) => b.count - a.count).slice(0, 10);
    const top10VictimesData = top10.length > 0 ? top10 : null;

    const filterByDateRange = (dateStr, du, au) => {
        if (!dateStr) return true;
        const dStr = typeof dateStr === 'string' 
            ? dateStr.substring(0, 10) 
            : new Date(dateStr).toISOString().substring(0, 10);
        if (du && dStr < du) return false;
        if (au && dStr > au) return false;
        return true;
    };

    let mixedStats = null; let nombreContratsFiltre = 0; let nombreRisquesFiltre = 0; let top10RisquesData = null;

    if (currentModuleType === 'MIXED') {
        const filteredPoliciesForCount = policiesMetadata.filter(p => filterByDateRange(p.dateEffet, dateDu, dateAu));
        mixedStats = { nombreContrats: filteredPoliciesForCount.length, nombreVehicules: 0, nombreAdherents: 0, nombreSinistresEnCours: 0, policesParStatut: {} };
        filteredPoliciesForCount.forEach(p => { const s = p.statut || 'Non renseigné'; mixedStats.policesParStatut[s] = (mixedStats.policesParStatut[s] || 0) + 1; });

        for (let i = 0; i < policyIds.length; i += chunkSize) {
            const batchIds = policyIds.slice(i, i + chunkSize);
            const [batchRisques, batchSinistres] = await Promise.all([
                Promise.all(batchIds.map(id => {
                    const p = policiesMetadata.find(pol => pol.id === id);
                    return p?.module === 'D' ? dataService.getAdherents(userId, source, token, id).then(r => r[0]) : dataService.getRisques(userId, source, token, id).then(r => r[0]);
                })),
                Promise.all(batchIds.map(id => dataService.getSinistres(userId, source, token, id).then(r => r[0])))
            ]);
            batchIds.forEach((id, index) => {
                const p = policiesMetadata.find(pol => pol.id === id); const rData = batchRisques[index];
                if (Array.isArray(rData)) { 
                    if (p?.module === 'A') {
                        mixedStats.nombreVehicules += rData.filter(r => filterByDateRange(r.dateMiseEnCirculation, dateDu, dateAu)).length;
                    } else if (p?.module === 'D') {
                        mixedStats.nombreAdherents += rData.filter(a => filterByDateRange(a.dateAdhesion, dateDu, dateAu)).length;
                    }
                }
            });
            batchSinistres.forEach(arr => { 
                if (Array.isArray(arr)) {
                    mixedStats.nombreSinistresEnCours += arr.filter(s => 
                        (s.statut === 'En cours' || s.statut === 'E') && 
                        filterByDateRange(s.date, dateDu, dateAu)
                    ).length; 
                }
            });
        }
    } else if (!isATBranch) {
        const filteredPoliciesForCount = policiesMetadata.filter(p => filterByDateRange(p.dateEffet, dateDu, dateAu));
        nombreContratsFiltre = filteredPoliciesForCount.length;
        
        const allRisques = []; const allSinistres = [];
        for (let i = 0; i < policyIds.length; i += chunkSize) {
            const batchIds = policyIds.slice(i, i + chunkSize);
            const [batchRisques, batchSinistres] = await Promise.all([
                Promise.all(batchIds.map(id => {
                    const p = policiesMetadata.find(pol => pol.id === id);
                    return p?.module === 'D' ? dataService.getAdherents(userId, source, token, id).then(r => r[0]) : dataService.getRisques(userId, source, token, id).then(r => r[0]);
                })),
                Promise.all(batchIds.map(id => dataService.getSinistres(userId, source, token, id).then(r => r[0])))
            ]);
            batchRisques.forEach(arr => { if (Array.isArray(arr)) allRisques.push(...arr); });
            batchSinistres.forEach(arr => { if (Array.isArray(arr)) allSinistres.push(...arr); });
        }
        
        nombreRisquesFiltre = allRisques.filter(r => {
            const dateField = r.dateAdhesion || r.dateMiseEnCirculation;
            return filterByDateRange(dateField, dateDu, dateAu);
        }).length;
        
        const countMap = {};
        allSinistres.forEach(sin => { const obj = sin.objet; if (obj) countMap[obj] = (countMap[obj] || 0) + 1; });
        const top10List = Object.entries(countMap).filter(([_, count]) => count > 1).map(([nom, count]) => ({ nom, count })).sort((a, b) => b.count - a.count).slice(0, 10);
        top10RisquesData = top10List.length > 0 ? top10List : null;
    }

    success(res, { kpis, evolutionData, top5ITTData, repartitionData, top10VictimesData, mixedStats, nombreContratsFiltre, nombreRisquesFiltre, top10RisquesData });
});

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
    getSyntheseSinistresAT,
    getDashboardBatchStats
};
