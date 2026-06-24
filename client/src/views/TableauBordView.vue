<script setup lang="ts">
import { ref, computed, watch, onMounted } from 'vue'
import PageContainer from '@/components/shared/PageContainer.vue'
import LoadingSkeleton from '@/components/shared/LoadingSkeleton.vue'
import { api } from '@/lib/api'
import { AlertCircle } from 'lucide-vue-next'
import { formatDate } from '@/lib/utils'
import { exportDashboardToPdf } from '@/utils/pdfExport'

// Sub-components
import DashboardFilters from '@/components/dashboard/DashboardFilters.vue'
import DashboardKPIs from '@/components/dashboard/DashboardKPIs.vue'
import DashboardEvolution from '@/components/dashboard/DashboardEvolution.vue'
import DashboardITTAnalysis from '@/components/dashboard/DashboardITTAnalysis.vue'
import DashboardRepartition from '@/components/dashboard/DashboardRepartition.vue'

const contrats = ref<any[]>([])
const loadingPolices = ref(false)
const selectedPoliceId = ref<number | string | null>(null)
const selectedClient = ref('')
const selectedBranch = ref('')

// Default date range: 2020-01-01 to 2026-06-10 (current system date)
const dateDu = ref('2020-01-01')
const dateAu = ref('2026-06-10')

// Stats KPI State
const kpis = ref<any>(null)
const loadingKPIs = ref(false)

// Stats Evolution State
const evolutionData = ref<any[] | null>(null)
const loadingEvolution = ref(false)

// Stats Top 5 ITT State
const top5ITTData = ref<any[] | null>(null)
const loadingTop5 = ref(false)

// Stats Repartition State
const repartitionData = ref<any[] | null>(null)
const loadingRepartition = ref(false)

// Stats Top 10 Victimes State
const top10VictimesData = ref<any[] | null>(null)
const loadingVictimes = ref(false)

const errorMsg = ref<string | null>(null)

// Format years for Card 1 subtitle (e.g. 2020 – 2026)
const yearRange = computed(() => {
  const startYear = dateDu.value ? dateDu.value.split('-')[0] : '2020'
  const endYear = dateAu.value ? dateAu.value.split('-')[0] : '2026'
  return `${startYear} – ${endYear}`
})

const uniqueClients = computed(() => {
  if (!contrats.value) return []
  const clients = (contrats.value as any[])
    .map((c: any) => c.client)
    .filter((clientName): clientName is string => !!clientName)
  return [...new Set(clients)].sort()
})

const uniqueBranches = computed(() => {
  if (!contrats.value) return []
  const branches = (contrats.value as any[])
    .map((c: any) => c.branche)
    .filter((b): b is string => !!b)
  return [...new Set(branches)].sort()
})

// Filter policies dynamically by selected client and selected branch
const displayPolices = computed(() => {
  if (!contrats.value || contrats.value.length === 0) return []
  return contrats.value.filter((c: any) => {
    const matchesClient = !selectedClient.value || c.client === selectedClient.value
    const matchesBranch = !selectedBranch.value || c.branche === selectedBranch.value
    return matchesClient && matchesBranch
  })
})

const currentPolice = computed(() => {
  if (selectedPoliceId.value === 'all') {
    return { police: 'Toutes les polices', branche: selectedBranch.value || 'Multi-branches' }
  }
  return contrats.value.find((c: any) => c.id === selectedPoliceId.value)
})

const isATBranch = computed(() => {
  const b = currentPolice.value?.branche?.toLowerCase() || ''
  return b === 'at' || b.includes('accident') || b.includes('travail')
})

const fetchPolices = async () => {
  loadingPolices.value = true
  try {
    const data = await api.data.getPolices()
    contrats.value = data || []
    
    // Auto-select first AT policy and set branch
    const atPols = data.filter((c: any) => 
      c.branche && (
        c.branche.toLowerCase() === 'at' || 
        c.branche.toLowerCase().includes('accident') || 
        c.branche.toLowerCase().includes('travail')
      )
    )
    if (atPols.length > 1) {
      selectedPoliceId.value = 'all'
      selectedBranch.value = atPols[0].branche || ''
    } else if (atPols.length > 0) {
      selectedPoliceId.value = atPols[0].id
      selectedBranch.value = atPols[0].branche || ''
    } else if (data.length > 1) {
      selectedPoliceId.value = 'all'
      selectedBranch.value = data[0].branche || ''
    } else if (data.length > 0) {
      selectedPoliceId.value = data[0].id
      selectedBranch.value = data[0].branche || ''
    }
  } catch (error: any) {
    console.error('Erreur chargement polices:', error)
    errorMsg.value = 'Impossible de charger la liste des polices.'
  } finally {
    loadingPolices.value = false
  }
}

const fetchAllStats = async () => {
  if (!selectedPoliceId.value || !isATBranch.value) {
    kpis.value = null
    evolutionData.value = null
    top5ITTData.value = null
    repartitionData.value = null
    return
  }
  loadingKPIs.value = true
  loadingEvolution.value = true
  loadingTop5.value = true
  loadingRepartition.value = true
  errorMsg.value = null
  try {
    if (selectedPoliceId.value === 'all') {
      const policyIds = displayPolices.value.map(p => p.id)
      if (policyIds.length === 0) {
        kpis.value = null
        evolutionData.value = null
        top5ITTData.value = null
        repartitionData.value = null
        return
      }

      // Fetch all stats in batches to avoid rate limits and connection pooling issues
      const allKpis = []
      const allEvolution = []
      const allTop5 = []
      const allRepartition = []
      const allTop10 = []

      const chunkSize = 5
      for (let i = 0; i < policyIds.length; i += chunkSize) {
        const batchIds = policyIds.slice(i, i + chunkSize)
        
        const [batchKpis, batchEvolution, batchTop5, batchRepartition, batchTop10Result] = await Promise.all([
          Promise.all(batchIds.map(id => api.data.getStatsKPIs(id, dateDu.value, dateAu.value))),
          Promise.all(batchIds.map(id => api.data.getStatsEvolutionAnnuelle(id, dateDu.value, dateAu.value))),
          Promise.all(batchIds.map(id => api.data.getStatsTop5ITT(id, dateDu.value, dateAu.value))),
          Promise.all(batchIds.map(id => api.data.getStatsRepartition(id, dateDu.value, dateAu.value))),
          Promise.all(batchIds.map(id => api.data.getStatsTop10Victimes(id, dateDu.value, dateAu.value)))
        ])

        allKpis.push(...batchKpis)
        allEvolution.push(...batchEvolution)
        allTop5.push(...batchTop5)
        allRepartition.push(...batchRepartition)
        allTop10.push(...batchTop10Result)
      }

      // 1. Aggregate KPIs
      let nbSinistresTotal = 0
      let coutTotal = 0
      let totalJoursITT = 0
      let nbSinistresWithITT = 0
      let mntITTTotal = 0
      let nbSinistresWithIPP = 0
      let ccrTotal = 0

      allKpis.forEach(k => {
        if (!k) return
        nbSinistresTotal += k.nbSinistresTotal || 0
        coutTotal += k.coutTotal || 0
        totalJoursITT += k.totalJoursITT || 0
        nbSinistresWithITT += k.nbSinistresWithITT || 0
        mntITTTotal += k.mntITTTotal || 0
        nbSinistresWithIPP += k.nbSinistresWithIPP || 0
        ccrTotal += k.ccrTotal || 0
      })

      kpis.value = {
        nbSinistresTotal,
        coutTotal,
        coutMoyen: nbSinistresTotal > 0 ? coutTotal / nbSinistresTotal : 0,
        totalJoursITT,
        nbSinistresWithITT,
        tauxITT: nbSinistresTotal > 0 ? (nbSinistresWithITT / nbSinistresTotal) * 100 : 0,
        dureeMoyenneITT: nbSinistresWithITT > 0 ? totalJoursITT / nbSinistresWithITT : 0,
        mntITTTotal,
        nbSinistresWithIPP,
        ccrTotal
      }

      // 2. Aggregate Evolution
      const evolutionMap: Record<number, any> = {}
      allEvolution.forEach(arr => {
        if (!Array.isArray(arr)) return
        arr.forEach((item: any) => {
          const y = item.annee
          if (!evolutionMap[y]) {
            evolutionMap[y] = { annee: y, nbSinistres: 0, coutTotal: 0, nbITT: 0, joursITT: 0, mntITT: 0 }
          }
          evolutionMap[y].nbSinistres += item.nbSinistres || 0
          evolutionMap[y].coutTotal += item.coutTotal || 0
          evolutionMap[y].nbITT += item.nbITT || 0
          evolutionMap[y].joursITT += item.joursITT || 0
          evolutionMap[y].mntITT += item.mntITT || 0
        })
      })
      const finalEvolution = Object.values(evolutionMap).map((item: any) => {
        item.tauxITT = item.nbSinistres > 0 ? (item.nbITT / item.nbSinistres) * 100 : 0
        return item
      }).sort((a: any, b: any) => a.annee - b.annee)
      evolutionData.value = finalEvolution.length > 0 ? finalEvolution : null

      // 3. Aggregate Top 5
      const mergedTop5: any[] = []
      allTop5.forEach(arr => {
        if (Array.isArray(arr)) {
          mergedTop5.push(...arr)
        }
      })
      mergedTop5.sort((a, b) => (b.joursITT || 0) - (a.joursITT || 0))
      top5ITTData.value = mergedTop5.slice(0, 5)

      // 4. Aggregate Repartition
      const circonstancesMap: Record<string, number> = {}
      const lesionsMap: Record<string, number> = {}
      const typesMap: Record<string, { countVal: number }> = {}

      allRepartition.forEach(rep => {
        if (!rep || !Array.isArray(rep)) return
        if (Array.isArray(rep[0])) {
          rep[0].forEach((item: any) => {
            circonstancesMap[item.categorie] = (circonstancesMap[item.categorie] || 0) + (item.countVal || 0)
          })
        }
        if (Array.isArray(rep[1])) {
          rep[1].forEach((item: any) => {
            lesionsMap[item.categorie] = (lesionsMap[item.categorie] || 0) + (item.countVal || 0)
          })
        }
        if (Array.isArray(rep[2])) {
          rep[2].forEach((item: any) => {
            if (!typesMap[item.categorie]) {
              typesMap[item.categorie] = { countVal: 0 }
            }
            typesMap[item.categorie].countVal += item.countVal || 0
          })
        }
      })

      const circonstancesList = Object.entries(circonstancesMap).map(([categorie, countVal]) => ({ categorie, countVal })).sort((a, b) => b.countVal - a.countVal)
      const lesionsList = Object.entries(lesionsMap).map(([categorie, countVal]) => ({ categorie, countVal })).sort((a, b) => b.countVal - a.countVal)
      
      const typeTotal = Object.values(typesMap).reduce((acc, curr) => acc + curr.countVal, 0)
      const typesList = Object.entries(typesMap).map(([categorie, data]) => {
        const countVal = data.countVal
        const pourcentage = typeTotal > 0 ? (countVal / typeTotal) * 100 : 0
        return { categorie, countVal, pourcentage }
      }).sort((a, b) => b.countVal - a.countVal)

      repartitionData.value = [circonstancesList, lesionsList, typesList]

      // 5. Aggregate Top 10 Victimes (Multiple Sinistres)
      const victimeCount: Record<string, number> = {}
      allTop10.forEach(arr => {
        if (!Array.isArray(arr)) return
        arr.forEach((item: any) => {
          if (item.nom) {
            victimeCount[item.nom] = (victimeCount[item.nom] || 0) + (item.count || 0)
          }
        })
      })
      const top10 = Object.entries(victimeCount)
        .map(([nom, count]) => ({ nom, count }))
        .sort((a, b) => b.count - a.count)
        .slice(0, 10)
      top10VictimesData.value = top10.length > 0 ? top10 : null

    } else {
      const [kpiResult, evolutionResult, top5Result, repartitionResult, top10Result] = await Promise.all([
        api.data.getStatsKPIs(Number(selectedPoliceId.value), dateDu.value, dateAu.value),
        api.data.getStatsEvolutionAnnuelle(Number(selectedPoliceId.value), dateDu.value, dateAu.value),
        api.data.getStatsTop5ITT(Number(selectedPoliceId.value), dateDu.value, dateAu.value),
        api.data.getStatsRepartition(Number(selectedPoliceId.value), dateDu.value, dateAu.value),
        api.data.getStatsTop10Victimes(Number(selectedPoliceId.value), dateDu.value, dateAu.value)
      ])
      kpis.value = kpiResult || null
      evolutionData.value = evolutionResult || null
      top5ITTData.value = top5Result || null
      repartitionData.value = repartitionResult || null
      top10VictimesData.value = top10Result && Array.isArray(top10Result) && top10Result.length > 0 ? top10Result : null
    }
  } catch (error: any) {
    console.error('Erreur chargement statistiques:', error)
    errorMsg.value = error.message || 'Erreur lors du chargement des statistiques.'
  } finally {
    loadingKPIs.value = false
    loadingEvolution.value = false
    loadingTop5.value = false
    loadingRepartition.value = false
  }
}

watch(displayPolices, (newPolices) => {
  if (newPolices.length === 0) {
    selectedPoliceId.value = null
  } else {
    if (newPolices.length > 1) {
      selectedPoliceId.value = 'all'
    } else if (!newPolices.some(p => p.id === selectedPoliceId.value)) {
      selectedPoliceId.value = newPolices[0].id
    }
  }
})

watch([selectedPoliceId, dateDu, dateAu], () => {
  fetchAllStats()
})

const exportToPdf = () => {
  exportDashboardToPdf({
    elementId: 'dashboard-content',
    filename: `Statistiques_${new Date().toISOString().split('T')[0]}.pdf`,
    onError: (err) => {
      errorMsg.value = 'Erreur lors de la génération du PDF.'
    }
  })
}

onMounted(async () => {
  await fetchPolices()
  await fetchAllStats()
})
</script>

<template>
  <PageContainer :title="$t('tableau_bord.statistics')" :subtitle="$t('tableau_bord.subtitle')">
    
    <!-- Filtres -->
    <DashboardFilters 
      v-model:selectedPoliceId="selectedPoliceId"
      v-model:selectedClient="selectedClient"
      v-model:selectedBranch="selectedBranch"
      v-model:dateDu="dateDu"
      v-model:dateAu="dateAu"
      :displayPolices="displayPolices"
      :uniqueClients="uniqueClients"
      :uniqueBranches="uniqueBranches"
      :loadingPolices="loadingPolices"
      :loadingState="loadingKPIs || loadingEvolution || loadingTop5 || loadingRepartition"
      @refresh="fetchAllStats"
      @exportPdf="exportToPdf"
      class="mb-6"
    />

    <!-- Error State -->
    <div v-if="errorMsg" class="bg-red-50 border border-red-200/60 rounded-3xl p-6 text-red-800 flex items-start gap-4">
      <AlertCircle class="w-6 h-6 text-red-500 shrink-0 mt-0.5" />
      <div>
        <h4 class="font-bold text-red-900 mb-1">{{ $t('tableau_bord.loading_error') }}</h4>
        <p class="text-sm text-red-700 font-medium">{{ errorMsg }}</p>
      </div>
    </div>

    <!-- Main Loading State (Skeletons) -->
    <div v-if="loadingKPIs || loadingEvolution || loadingTop5 || loadingRepartition" class="space-y-6">
      <div class="w-full h-16 bg-slate-200 rounded-[2rem] animate-pulse"></div>
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        <LoadingSkeleton v-for="i in 8" :key="i" height="h-36" class="rounded-[2rem]" />
      </div>
      <div class="w-full h-96 bg-slate-200 rounded-[2.5rem] animate-pulse"></div>
    </div>

    <!-- Main Dashboard Container -->
    <div v-else id="dashboard-content" class="space-y-12 bg-white p-6 md:p-8 rounded-[2.5rem] border border-slate-100 shadow-sm">
      
      <!-- PDF Only Header -->
      <div class="pdf-header border-b-2 border-slate-200 pb-4 mb-6">
        <h1 class="text-3xl font-black text-slate-900 tracking-tight" style="font-size: 28px !important; line-height: 1.2;">{{ $t('tableau_bord.statistics') }}</h1>
        <div class="grid grid-cols-2 gap-4 mt-4 bg-slate-50 p-4 rounded-2xl text-xs font-bold text-slate-600 border border-slate-100">
          <div>
            <p class="text-slate-400 uppercase text-[10px] tracking-wider mb-0.5">{{ $t('tableau_bord.client_subsidiary') }}</p>
            <p class="text-slate-800 text-sm font-black">{{ selectedClient || $t('contrats.all_clients') }}</p>
          </div>
          <div>
            <p class="text-slate-400 uppercase text-[10px] tracking-wider mb-0.5">{{ $t('tableau_bord.branch') }}</p>
            <p class="text-slate-800 text-sm font-black">{{ selectedBranch || $t('contrats.all_branches') }}</p>
          </div>
          <div>
            <p class="text-slate-400 uppercase text-[10px] tracking-wider mb-0.5">{{ $t('tableau_bord.policy') }}</p>
            <p class="text-slate-800 text-sm font-black">{{ selectedPoliceId === 'all' ? $t('contrats.all_policies') : currentPolice?.police || 'N/A' }}</p>
          </div>
          <div>
            <p class="text-slate-400 uppercase text-[10px] tracking-wider mb-0.5">{{ $t('tableau_bord.report_period') }}</p>
            <p class="text-slate-800 text-sm font-black">{{ $t('commun.date_from') }} {{ formatDate(dateDu) }} {{ $t('commun.date_to').toLowerCase() }} {{ formatDate(dateAu) }}</p>
          </div>
        </div>
      </div>
      
      <!-- 1. KPIs Section -->
      <DashboardKPIs 
        :kpis="kpis"
        :yearRange="yearRange"
        :isATBranch="isATBranch"
      />
      
      <DashboardEvolution 
        :evolutionData="evolutionData"
        :isATBranch="isATBranch"
      />

      <DashboardITTAnalysis 
        v-if="isATBranch"
        :evolutionData="evolutionData"
        :top5ITTData="top5ITTData"
        :top10VictimesData="top10VictimesData"
      />
      
      <DashboardRepartition 
        v-if="isATBranch"
        :repartitionData="repartitionData"
      />


    </div>
  </PageContainer>
</template>
