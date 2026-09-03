<script setup lang="ts">
import { computed } from 'vue'
import { Doughnut } from 'vue-chartjs'
import {
  Chart as ChartJS,
  Title,
  Tooltip,
  Legend,
  ArcElement
} from 'chart.js'
import { Card } from '@/components/ui/card'
import { formatKPIValue } from '@/lib/utils'
import { useI18n } from 'vue-i18n'

ChartJS.register(Title, Tooltip, Legend, ArcElement)

const { t } = useI18n()

const props = defineProps<{
  repartitionData: any[] | null
}>()

// 4. Repartition Datasets & Charts Configuration (Phase 4)
const circumstancesDataList = computed(() => props.repartitionData?.[0] || [])
const lesionsDataList = computed(() => props.repartitionData?.[1] || [])
const typeAccidentDataList = computed(() => props.repartitionData?.[2] || [])

// Type of Accident Cards configuration with database percentages
const typeAccidentCards = computed(() => {
  const list = typeAccidentDataList.value

  const siteItem = list.find((item: any) => !item.categorie.toLowerCase().includes('trajet'))
  const trajetItem = list.find((item: any) => item.categorie.toLowerCase().includes('trajet'))

  const siteCount = siteItem ? siteItem.countVal : 0
  const trajetCount = trajetItem ? trajetItem.countVal : 0
  const total = siteCount + trajetCount

  const sitePct = siteItem && siteItem.pourcentage !== undefined ? siteItem.pourcentage : (total > 0 ? (siteCount / total) * 100.0 : 0)
  const trajetPct = trajetItem && trajetItem.pourcentage !== undefined ? trajetItem.pourcentage : (total > 0 ? (trajetCount / total) * 100.0 : 0)

  return [
    {
      categorie: t('tableau_bord.on_site_accident'),
      countVal: siteCount,
      pourcentage: sitePct,
      classes: 'bg-[#e6f0fa] border-[#cce0f5]/80 text-[#0d3880]'
    },
    {
      categorie: t('tableau_bord.commuting_accident'),
      countVal: trajetCount,
      pourcentage: trajetPct,
      classes: 'bg-[#fffbe6] border-[#fef08a]/80 text-[#826a00]'
    }
  ]
})

const circumstancesChartData = computed(() => {
  const list = circumstancesDataList.value
  const labels = list.map((item: any) => item.categorie)
  const data = list.map((item: any) => item.countVal)

  return {
    labels,
    datasets: [
      {
        data,
        backgroundColor: ['#0d3880', '#ea580c', '#f43f5e', '#6366f1', '#10b981', '#94a3b8', '#8b5cf6', '#ec4899'],
        borderWidth: 2,
        borderColor: '#ffffff'
      }
    ]
  }
})

const lesionsChartData = computed(() => {
  const list = lesionsDataList.value
  const labels = list.map((item: any) => item.categorie)
  const data = list.map((item: any) => item.countVal)

  return {
    labels,
    datasets: [
      {
        data,
        backgroundColor: ['#0d3880', '#ea580c', '#f43f5e', '#6366f1', '#10b981', '#ec4899', '#84cc16', '#a855f7'],
        borderWidth: 2,
        borderColor: '#ffffff'
      }
    ]
  }
})

const doughnutChartOptions = computed(() => {
  return {
    responsive: true,
    maintainAspectRatio: false,
    plugins: {
      legend: {
        position: 'bottom' as const,
        labels: {
          font: { family: 'Outfit', weight: 'bold' as const, size: 11 },
          color: '#475569',
          boxWidth: 12,
          padding: 15
        }
      },
      tooltip: {
        titleFont: { family: 'Outfit', weight: 'bold' as const, size: 12 },
        bodyFont: { family: 'Outfit', size: 11 },
        padding: 10,
        cornerRadius: 8,
        backgroundColor: 'rgba(15, 23, 42, 0.95)',
        callbacks: {
          label: function (context: any) {
            const dataset = context.dataset
            const total = dataset.data.reduce((acc: number, val: number) => acc + val, 0)
            const value = dataset.data[context.dataIndex]
            const percentage = total > 0 ? ((value / total) * 100).toFixed(1) : 0
            return ` ${context.label}: ${value} (${percentage}%)`
          }
        }
      }
    },
    cutout: '60%'
  }
})
</script>

<template>
  <div v-if="repartitionData && circumstancesDataList.length > 0" class="pdf-page-break mb-12 space-y-6">

    <div class="pdf-avoid-break space-y-6">
      <div class="flex items-center gap-4">
        <div class="w-1.5 h-8 bg-[#0d3880] rounded-full"></div>
        <h2 class="text-xl md:text-2xl font-black text-slate-800 uppercase tracking-wider">{{
          $t('tableau_bord.repartition_circumstance_lesion') }}</h2>
      </div>

      <!-- Doughnut Charts -->
      <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">

        <!-- Circumstances Doughnut -->
        <div class="bg-white rounded-[1.8rem] border border-slate-200/60 p-6 md:p-8 space-y-4 shadow-sm">
          <h3 class="font-extrabold text-slate-900 text-sm md:text-base tracking-tight text-center uppercase">
            {{ $t('tableau_bord.accident_circumstances') }}
          </h3>
          <div class="relative h-72 w-full">
            <Doughnut :data="circumstancesChartData" :options="doughnutChartOptions" />
          </div>
        </div>

        <!-- Lesions Doughnut -->
        <div class="bg-white rounded-[1.8rem] border border-slate-200/60 p-6 md:p-8 space-y-4 shadow-sm">
          <h3 class="font-extrabold text-slate-900 text-sm md:text-base tracking-tight text-center uppercase">
            {{ $t('tableau_bord.nature_of_lesions') }}
          </h3>
          <div class="relative h-72 w-full">
            <Doughnut :data="lesionsChartData" :options="doughnutChartOptions" />
          </div>
        </div>
      </div>

      <!-- Type of Accident Sub-Section -->
      <div class="bg-white border border-slate-200/60 rounded-[1.5rem] overflow-hidden shadow-sm pdf-avoid-break">
        <div class="bg-[#1e293b] px-6 py-4 text-white text-center">
          <h3 class="text-sm md:text-base font-black uppercase tracking-wider">
            {{ $t('tableau_bord.accident_type') }}
          </h3>
        </div>

        <div class="p-6 md:p-8 bg-slate-50/30">
          <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
            <Card v-for="card in typeAccidentCards" :key="card.categorie" :class="card.classes"
              class="rounded-[1.8rem] p-6 shadow-sm flex items-center justify-center min-h-[90px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
              <p class="text-base md:text-lg font-black tracking-wide text-center">
                {{ card.categorie }} — {{ card.countVal }} {{ $t('tableau_bord.claims_short') }} ({{ formatKPIValue(card.pourcentage, 'percentage') }})
              </p>
            </Card>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
