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
import DashboardMixedKPIs from '@/components/dashboard/DashboardMixedKPIs.vue'
import DashboardEvolution from '@/components/dashboard/DashboardEvolution.vue'
import DashboardITTAnalysis from '@/components/dashboard/DashboardITTAnalysis.vue'
import DashboardRepartition from '@/components/dashboard/DashboardRepartition.vue'
import DashboardTopRisques from '@/components/dashboard/DashboardTopRisques.vue'

const contrats = ref<any[]>([])
const loadingPolices = ref(false)
const selectedPoliceId = ref<number | string | null>('all')
const selectedClient = ref('')
const selectedBranch = ref('')

const today = new Date()
const currentYear = today.getFullYear()
const pastYear = currentYear - 5
const defaultDateDu = `${pastYear}-01-01`
const defaultDateAu = new Date(today.getTime() - today.getTimezoneOffset() * 60000).toISOString().split('T')[0]

const dateDu = ref(defaultDateDu)
const dateAu = ref(defaultDateAu)

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

// Stats Auto/IARD/Sante State
const nombreContratsFiltre = ref(0)
const nombreRisquesFiltre = ref(0)
const top10RisquesData = ref<any[] | null>(null)

// Stats Global (MIXED)
const mixedStats = ref({
  nombreContrats: 0,
  nombreVehicules: 0,
  nombreAdherents: 0,
  nombreSinistresEnCours: 0,
  policesParStatut: {} as Record<string, number>
})

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
  if (selectedPoliceId.value === 'all') {
    return displayPolices.value.length > 0 && displayPolices.value.every((p: any) => p.module === 'C')
  }
  return currentPolice.value?.module === 'C'
})

const currentModuleType = computed(() => {
  if (selectedPoliceId.value === 'all') {
    if (displayPolices.value.length === 0) return ''
    const firstModule = displayPolices.value[0].module
    const allSame = displayPolices.value.every((p: any) => p.module === firstModule)
    return allSame ? firstModule : 'MIXED'
  }
  return currentPolice.value?.module || ''
})

const fetchPolices = async () => {
  loadingPolices.value = true
  try {
    const data = await api.data.getPolices()
    contrats.value = data || []
    
    selectedPoliceId.value = 'all'
    selectedBranch.value = ''
    selectedClient.value = ''
  } catch (error: any) {
    console.error('Erreur chargement polices:', error)
    errorMsg.value = 'Impossible de charger la liste des polices.'
  } finally {
    loadingPolices.value = false
  }
}

const fetchAllStats = async () => {
  if (!selectedPoliceId.value) {
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

      const payload = {
        policyIds,
        dateDu: dateDu.value,
        dateAu: dateAu.value,
        isATBranch: isATBranch.value,
        currentModuleType: currentModuleType.value,
        policiesMetadata: displayPolices.value.map((p: any) => ({
          id: p.id,
          module: p.module,
          statut: p.statut,
          dateEffet: p.dateEffet
        }))
      }

      const result = await api.data.getDashboardBatchStats(payload)
      
      if (result) {
        kpis.value = result.kpis || null
        evolutionData.value = result.evolutionData || null
        top5ITTData.value = result.top5ITTData || null
        repartitionData.value = result.repartitionData || null
        top10VictimesData.value = result.top10VictimesData || null
        if (currentModuleType.value === 'MIXED' && result.mixedStats) {
          mixedStats.value = result.mixedStats
        }
        if (!isATBranch.value && currentModuleType.value !== 'MIXED') {
          nombreContratsFiltre.value = result.nombreContratsFiltre || 0
          nombreRisquesFiltre.value = result.nombreRisquesFiltre || 0
          top10RisquesData.value = result.top10RisquesData || null
        }
      }
    } else {
      const [kpiResult, evolutionResult, top5Result, repartitionResult, top10Result] = await Promise.all([
        api.data.getStatsKPIs(Number(selectedPoliceId.value), dateDu.value, dateAu.value),
        api.data.getStatsEvolutionAnnuelle(Number(selectedPoliceId.value), dateDu.value, dateAu.value),
        isATBranch.value ? api.data.getStatsTop5ITT(Number(selectedPoliceId.value), dateDu.value, dateAu.value) : Promise.resolve(null),
        isATBranch.value ? api.data.getStatsRepartition(Number(selectedPoliceId.value), dateDu.value, dateAu.value) : Promise.resolve(null),
        isATBranch.value ? api.data.getStatsTop10Victimes(Number(selectedPoliceId.value), dateDu.value, dateAu.value) : Promise.resolve(null)
      ])
      kpis.value = kpiResult || null
      evolutionData.value = evolutionResult || null
      top5ITTData.value = top5Result || null
      repartitionData.value = repartitionResult || null
      top10VictimesData.value = top10Result && Array.isArray(top10Result) && top10Result.length > 0 ? top10Result : null

      // Generic stats for non-AT branches (Single Mode)
      if (!isATBranch.value) {
        let showContract = true
        if (currentPolice.value?.dateEffet && (dateDu.value || dateAu.value)) {
          const pDate = currentPolice.value.dateEffet.substring(0, 10)
          const dDu = dateDu.value ? dateDu.value.substring(0, 10) : null
          const dAu = dateAu.value ? dateAu.value.substring(0, 10) : null
          if ((dDu && pDate < dDu) || (dAu && pDate > dAu)) {
            showContract = false
          }
        }
        nombreContratsFiltre.value = showContract ? 1 : 0
        
        const fetchRisques = currentPolice.value?.module === 'D'
          ? api.data.getAdherents(Number(selectedPoliceId.value))
          : api.data.getRisques(Number(selectedPoliceId.value))
          
        const [risques, sinistres] = await Promise.all([
          fetchRisques,
          api.data.getSinistres(Number(selectedPoliceId.value))
        ])
        
        let filteredRisquesCount = 0
        if (Array.isArray(risques)) {
          risques.forEach(r => {
            const dateField = r.dateAdhesion || r.dateMiseEnCirculation
            if (!dateField) {
              filteredRisquesCount++
              return
            }
            const rDate = dateField.substring(0, 10)
            const dDu = dateDu.value ? dateDu.value.substring(0, 10) : null
            const dAu = dateAu.value ? dateAu.value.substring(0, 10) : null
            if ((!dDu || rDate >= dDu) && (!dAu || rDate <= dAu)) {
              filteredRisquesCount++
            }
          })
        }
        nombreRisquesFiltre.value = filteredRisquesCount
        
        const countMap: Record<string, number> = {}
        if (Array.isArray(sinistres)) {
          sinistres.forEach(sin => {
            const obj = sin.objet
            if (obj) countMap[obj] = (countMap[obj] || 0) + 1
          })
        }
        
        const top10List = Object.entries(countMap)
          .filter(([_, count]) => count > 1)
          .map(([nom, count]) => ({ nom, count }))
          .sort((a, b) => b.count - a.count)
          .slice(0, 10)
          
        top10RisquesData.value = top10List.length > 0 ? top10List : null
      }
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

watch([selectedPoliceId, dateDu, dateAu, selectedClient, selectedBranch], () => {
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
      <DashboardMixedKPIs 
        v-if="currentModuleType === 'MIXED'"
        :kpis="kpis"
        :yearRange="yearRange"
        :mixedStats="mixedStats"
      />
      <DashboardKPIs 
        v-else
        :kpis="kpis"
        :yearRange="yearRange"
        :isATBranch="isATBranch"
        :moduleType="currentModuleType"
        :nombreContratsFiltre="nombreContratsFiltre"
        :nombreRisquesFiltre="nombreRisquesFiltre"
      />
      
      <!-- 2. Évolution Annuelle -->
      <DashboardEvolution 
        v-if="currentModuleType !== 'MIXED'"
        :evolutionData="evolutionData"
        :isATBranch="isATBranch"
      />

      <DashboardITTAnalysis 
        v-if="isATBranch"
        :evolutionData="evolutionData"
        :top5ITTData="top5ITTData"
        :top10VictimesData="top10VictimesData"
      />
      
      <DashboardTopRisques 
        v-if="!isATBranch && currentModuleType !== 'MIXED'"
        :moduleType="currentModuleType"
        :top10RisquesData="top10RisquesData"
      />
      
      <DashboardRepartition 
        v-if="isATBranch"
        :repartitionData="repartitionData"
      />


    </div>
  </PageContainer>
</template>
