<script setup lang="ts">
import { computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { Bar } from 'vue-chartjs'
import { 
  Chart as ChartJS, 
  Title, 
  Tooltip, 
  Legend, 
  BarElement, 
  CategoryScale, 
  LinearScale
} from 'chart.js'
import { formatKPIValue } from '@/lib/utils'

ChartJS.register(Title, Tooltip, Legend, BarElement, CategoryScale, LinearScale)

const props = defineProps<{
  evolutionData: any[] | null
  isATBranch: boolean
}>()

const evolutionChartData = computed(() => {
  const { t } = useI18n()
  const years = props.evolutionData ? props.evolutionData.map((item: any) => String(item.annee)) : []
  const nbSinistres = props.evolutionData ? props.evolutionData.map((item: any) => item.nbSinistres) : []
  const nbITT = props.evolutionData ? props.evolutionData.map((item: any) => item.nbITT) : []

  const datasets = [
    {
      label: t('tableau_bord.nb_claims'),
      backgroundColor: '#0d3880', // Premium deep blue
      borderRadius: 6,
      data: nbSinistres
    }
  ]

  if (props.isATBranch) {
    datasets.push({
      label: t('tableau_bord.nb_itt'),
      backgroundColor: '#ea580c', // Premium orange
      borderRadius: 6,
      data: nbITT
    })
  }

  return {
    labels: years,
    datasets
  }
})

const evolutionChartOptions = computed(() => {
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
        ticks: { font: { family: 'Outfit', size: 11 }, color: '#64748b', stepSize: 1 }
      }
    }
  }
})
</script>

<template>
  <div v-if="evolutionData && evolutionData.length > 0" class="bg-white rounded-[2rem] border border-slate-200/80 shadow-sm overflow-hidden transition-all duration-300">
    <div class="w-full bg-[#0d3880] px-6 py-4 md:px-8 md:py-5 flex items-center justify-between overflow-hidden relative">
      <div class="absolute inset-0 bg-gradient-to-r from-blue-900/10 via-transparent to-blue-900/5 pointer-events-none"></div>
      <div class="space-y-0.5 z-10">
        <h2 class="text-lg md:text-2xl font-black text-white uppercase tracking-wider">{{ $t('tableau_bord.annual_claims_evolution') }}</h2>
      </div>
    </div>

    <!-- Table & Chart Content -->
    <div class="p-6 md:p-8 space-y-8">
      <!-- Table -->
      <div class="overflow-x-auto rounded-[1.5rem] border border-slate-200/60 shadow-sm">
        <table class="w-full border-collapse">
          <thead>
            <tr class="bg-[#1e293b] text-white">
              <th class="px-6 py-4 font-black uppercase tracking-wider text-xs border-b border-slate-700 text-center">{{ $t('tableau_bord.year') }}</th>
              <th class="px-6 py-4 font-black uppercase tracking-wider text-xs border-b border-slate-700 text-center">{{ $t('tableau_bord.nb_claims') }}</th>
              <th class="px-6 py-4 font-black uppercase tracking-wider text-xs border-b border-slate-700 text-center">{{ $t('tableau_bord.total_cost_mad') }}</th>
              <th v-if="isATBranch" class="px-6 py-4 font-black uppercase tracking-wider text-xs border-b border-slate-700 text-center">{{ $t('tableau_bord.nb_itt') }}</th>
              <th v-if="isATBranch" class="px-6 py-4 font-black uppercase tracking-wider text-xs border-b border-slate-700 text-center">{{ $t('tableau_bord.itt_rate') }}</th>
              <th v-if="isATBranch" class="px-6 py-4 font-black uppercase tracking-wider text-xs border-b border-slate-700 text-center">{{ $t('tableau_bord.itt_days') }}</th>
              <th v-if="isATBranch" class="px-6 py-4 font-black uppercase tracking-wider text-xs border-b border-slate-700 text-center">{{ $t('tableau_bord.itt_amount_mad') }}</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr 
              v-for="row in evolutionData" 
              :key="row.annee"
              class="hover:bg-slate-50/50 transition-colors duration-150"
            >
              <td class="px-6 py-4 font-extrabold text-slate-800 text-sm text-center">{{ row.annee }}</td>
              <td class="px-6 py-4 font-bold text-slate-700 text-sm text-center">{{ formatKPIValue(row.nbSinistres, 'number') }}</td>
              <td class="px-6 py-4 font-bold text-slate-700 text-sm text-center">{{ formatKPIValue(row.coutTotal, 'number') }}</td>
              <td v-if="isATBranch" class="px-6 py-4 font-bold text-slate-700 text-sm text-center">{{ formatKPIValue(row.nbITT, 'number') }}</td>
              <td v-if="isATBranch" class="px-6 py-4 font-bold text-slate-700 text-sm text-center">{{ formatKPIValue(row.tauxITT, 'percentage') }}</td>
              <td v-if="isATBranch" class="px-6 py-4 font-bold text-slate-700 text-sm text-center">{{ formatKPIValue(row.joursITT, 'number') }}</td>
              <td v-if="isATBranch" class="px-6 py-4 font-bold text-slate-700 text-sm text-center">{{ formatKPIValue(row.mntITT, 'number') }}</td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Chart representation -->
      <div class="relative h-80 md:h-[400px] w-full pt-4">
        <Bar :data="evolutionChartData" :options="evolutionChartOptions" />
      </div>
    </div>
  </div>
</template>
