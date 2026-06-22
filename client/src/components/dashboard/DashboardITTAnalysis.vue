<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { Bar, Line } from 'vue-chartjs'
import { 
  Chart as ChartJS, 
  Title, 
  Tooltip, 
  Legend, 
  BarElement, 
  CategoryScale, 
  LinearScale,
  PointElement,
  LineElement
} from 'chart.js'
import { formatKPIValue } from '@/lib/utils'

ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale, PointElement, LineElement)

const props = defineProps<{
  evolutionData: any[] | null
  top5ITTData: any[] | null
  top10VictimesData: any[] | null
}>()

const { t } = useI18n()

// ----------------------------------------------------
// 2. Chart 2: ITT Rate and Avg ITT Days (Line)
// ----------------------------------------------------
const lineChartData = computed(() => {
  const years = props.evolutionData ? props.evolutionData.map((item: any) => String(item.annee)) : []
  const tauxITT = props.evolutionData ? props.evolutionData.map((item: any) => item.tauxITT) : []
  const moyJoursITT = props.evolutionData ? props.evolutionData.map((item: any) => 
    item.nbITT > 0 ? Math.round(item.joursITT / item.nbITT) : 0
  ) : []

  return {
    labels: years,
    datasets: [
      {
        label: t('tableau_bord.itt_rate'),
        borderColor: '#ea580c', // Orange
        backgroundColor: '#ea580c',
        data: tauxITT,
        tension: 0.3,
        fill: false,
        pointRadius: 4,
        pointHoverRadius: 6
      },
      {
        label: 'Moy. jours ITT',
        borderColor: '#0d3880', // Deep Blue
        backgroundColor: '#0d3880',
        data: moyJoursITT,
        tension: 0.3,
        fill: false,
        pointRadius: 4,
        pointHoverRadius: 6
      }
    ]
  }
})

const lineChartOptions = computed(() => {
  return {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'bottom' as const,
        labels: {
          font: { family: 'Outfit', weight: 'bold' as const, size: 12 },
          color: '#334155',
          boxWidth: 15,
          padding: 20
        }
      },
      tooltip: {
        titleFont: { family: 'Outfit', weight: 'bold' as const, size: 13 },
        bodyFont: { family: 'Outfit', size: 12 },
        padding: 12,
        cornerRadius: 12,
        backgroundColor: 'rgba(15, 23, 42, 0.9)'
      }
    },
    scales: {
      x: {
        grid: { display: false },
        ticks: { font: { family: 'Outfit', weight: 'bold' as const, size: 11 }, color: '#64748b' }
      },
      y: {
        grid: { color: '#f1f5f9' },
        ticks: { font: { family: 'Outfit', size: 11 }, color: '#64748b' }
      }
    }
  }
})

// ----------------------------------------------------
// 3. Chart 3: Montant ITT per Year (Bar)
// ----------------------------------------------------
const barMntChartData = computed(() => {
  const years = props.evolutionData ? props.evolutionData.map((item: any) => String(item.annee)) : []
  const mntITT = props.evolutionData ? props.evolutionData.map((item: any) => item.mntITT) : []

  return {
    labels: years,
    datasets: [
      {
        label: t('tableau_bord.itt_amount_mad'),
        backgroundColor: '#ea580c', // Orange
        borderRadius: 6,
        data: mntITT
      }
    ]
  }
})

const barMntChartOptions = computed(() => {
  return {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'bottom' as const,
        labels: {
          font: { family: 'Outfit', weight: 'bold' as const, size: 12 },
          color: '#334155',
          boxWidth: 15,
          padding: 20
        }
      },
      tooltip: {
        titleFont: { family: 'Outfit', weight: 'bold' as const, size: 13 },
        bodyFont: { family: 'Outfit', size: 12 },
        padding: 12,
        cornerRadius: 12,
        backgroundColor: 'rgba(15, 23, 42, 0.9)'
      }
    },
    scales: {
      x: {
        grid: { display: false },
        ticks: { font: { family: 'Outfit', weight: 'bold' as const, size: 11 }, color: '#64748b' }
      },
      y: {
        grid: { color: '#f1f5f9' },
        ticks: { font: { family: 'Outfit', size: 11 }, color: '#64748b' }
      }
    }
  }
})
</script>

<template>
  <div v-if="evolutionData && evolutionData.length > 0" class="bg-white rounded-[2rem] border border-slate-200/80 shadow-sm overflow-hidden transition-all duration-300">
    <div class="w-full bg-[#ea580c] px-6 py-4 md:px-8 md:py-5 flex items-center justify-between overflow-hidden relative">
      <div class="absolute inset-0 bg-gradient-to-r from-orange-950/10 via-transparent to-orange-950/5 pointer-events-none"></div>
      <div class="space-y-0.5 z-10">
        <h2 class="text-lg md:text-2xl font-black text-white uppercase tracking-wider">{{ $t('tableau_bord.itt_analysis') }}</h2>
      </div>
    </div>

    <!-- Content Body -->
    <div class="p-6 md:p-8 bg-slate-50/50 space-y-8">
      <!-- Side-by-side Charts -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
        
        <!-- Line Chart: Taux ITT & Durée moyenne -->
        <div class="bg-white rounded-[1.8rem] border border-slate-200/60 p-6 md:p-8 space-y-4 shadow-sm">
          <h3 class="font-extrabold text-slate-900 text-sm md:text-base tracking-tight text-center uppercase">
            {{ $t('tableau_bord.itt_rate_and_avg_duration') }}
          </h3>
          <div class="relative h-72 w-full">
            <Line :data="lineChartData" :options="lineChartOptions" />
          </div>
        </div>

        <!-- Bar Chart: {{ $t('tableau_bord.itt_amount_per_year') }} -->
        <div class="bg-white rounded-[1.8rem] border border-slate-200/60 p-6 md:p-8 space-y-4 shadow-sm">
          <h3 class="font-extrabold text-slate-900 text-sm md:text-base tracking-tight text-center uppercase">
            {{ $t('tableau_bord.itt_amount_per_year') }}
          </h3>
          <div class="relative h-72 w-full">
            <Bar :data="barMntChartData" :options="barMntChartOptions" />
          </div>
        </div>
      </div>

      <!-- Top 5 Longest ITT claims table -->
      <div v-if="top5ITTData && top5ITTData.length > 0" class="bg-white border border-slate-200/60 rounded-[1.5rem] overflow-hidden shadow-sm">
        <div class="bg-[#1e293b] px-6 py-4 text-white">
          <h3 class="text-sm md:text-base font-black uppercase tracking-wider text-center md:text-left">
            TOP 5 — SINISTRES ITT LES PLUS LONGS
          </h3>
        </div>
        
        <div class="p-4 md:p-6 overflow-x-auto">
          <table class="w-full border-collapse">
            <thead>
              <tr class="bg-[#1e293b] text-white">
                <th class="px-6 py-3.5 font-black uppercase tracking-wider text-xs border-b border-slate-700 text-center">{{ $t('tableau_bord.year') }}</th>
                <th class="px-6 py-3.5 font-black uppercase tracking-wider text-xs border-b border-slate-700 text-left">{{ $t('tableau_bord.victim') }}</th>
                <th class="px-6 py-3.5 font-black uppercase tracking-wider text-xs border-b border-slate-700 text-center">{{ $t('tableau_bord.itt_days') }}</th>
                <th class="px-6 py-3.5 font-black uppercase tracking-wider text-xs border-b border-slate-700 text-center">{{ $t('tableau_bord.itt_amount_mad') }}</th>
                <th class="px-6 py-3.5 font-black uppercase tracking-wider text-xs border-b border-slate-700 text-center">{{ $t('tableau_bord.total_cost_mad') }}</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr 
                v-for="row in top5ITTData" 
                :key="row.joursITT + '-' + row.victime"
                class="hover:bg-slate-50/50 transition-colors duration-150"
              >
                <td class="px-6 py-3.5 font-extrabold text-slate-800 text-sm text-center">{{ row.annee }}</td>
                <td class="px-6 py-3.5 font-bold text-slate-700 text-sm text-left">{{ row.victime }}</td>
                <td class="px-6 py-3.5 font-black text-[#b30000] text-sm text-center">{{ formatKPIValue(row.joursITT, 'number') }}</td>
                <td class="px-6 py-3.5 font-bold text-slate-700 text-sm text-center">{{ formatKPIValue(row.mntITT, 'number') }}</td>
                <td class="px-6 py-3.5 font-bold text-slate-700 text-sm text-center">{{ formatKPIValue(row.coutTotal, 'number') }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Top 10 Victimes (Multiple Sinistres) table -->
      <div v-if="top10VictimesData && top10VictimesData.length > 0" class="bg-white border border-slate-200/60 rounded-[1.5rem] overflow-hidden shadow-sm mt-8">
        <div class="bg-[#ea580c] px-6 py-4 text-white">
          <h3 class="text-sm md:text-base font-black uppercase tracking-wider text-center md:text-left">
            TOP 10 — sinistre récidives
          </h3>
        </div>
        
        <div class="p-4 md:p-6 overflow-x-auto">
          <table class="w-full border-collapse">
            <thead>
              <tr class="bg-orange-50 text-orange-950">
                <th class="px-6 py-3.5 font-black uppercase tracking-wider text-xs border-b border-orange-200/50 text-center w-16">#</th>
                <th class="px-6 py-3.5 font-black uppercase tracking-wider text-xs border-b border-orange-200/50 text-left">{{ $t('tableau_bord.victim_name') }}</th>
                <th class="px-6 py-3.5 font-black uppercase tracking-wider text-xs border-b border-orange-200/50 text-center">{{ $t('tableau_bord.nb_claims_full') }}</th>
              </tr>
            </thead>
            <tbody class="divide-y divide-slate-100">
              <tr 
                v-for="(row, index) in top10VictimesData" 
                :key="row.nom"
                class="hover:bg-slate-50/50 transition-colors duration-150"
              >
                <td class="px-6 py-3.5 font-extrabold text-slate-400 text-sm text-center">{{ index + 1 }}</td>
                <td class="px-6 py-3.5 font-bold text-slate-800 text-sm text-left">{{ row.nom }}</td>
                <td class="px-6 py-3.5 font-black text-[#ea580c] text-base text-center">{{ row.count }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>
