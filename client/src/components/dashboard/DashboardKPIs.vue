<script setup lang="ts">
import { Card } from '@/components/ui/card'
import { FileText } from 'lucide-vue-next'
import { formatKPIValue } from '@/lib/utils'

defineProps<{
  kpis: any
  yearRange: string
  isATBranch: boolean
}>()
</script>

<template>
  <div v-if="kpis" class="bg-white rounded-[2rem] border border-slate-200/80 shadow-sm overflow-hidden transition-all duration-300">
    <div class="w-full bg-[#0d3880] px-6 py-4 md:px-8 md:py-5 flex items-center justify-between overflow-hidden relative">
      <div class="absolute inset-0 bg-gradient-to-r from-blue-900/10 via-transparent to-blue-900/5 pointer-events-none"></div>
      <div class="space-y-0.5 z-10">
        <h2 class="text-lg md:text-2xl font-black text-white uppercase tracking-wider">{{ $t('tableau_bord.kpi') }}</h2>
      </div>
    </div>

    <!-- KPI cards grid inside container -->
    <div class="p-6 md:p-8 bg-slate-50/50">
      <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        
        <!-- Card 1: {{ $t('tableau_bord.total_nb_claims') }} (Blue theme) -->
        <Card class="bg-[#e6f0fa] border-[#cce0f5]/80 text-[#0d3880] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">{{ $t('tableau_bord.total_nb_claims') }}</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.nbSinistresTotal, 'number') }}</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">{{ yearRange }}</p>
        </Card>

        <!-- Card 2: Coût total (Yellow theme) -->
        <Card class="bg-[#fffbe6] border-[#fef08a]/80 text-[#826a00] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">{{ $t('tableau_bord.total_cost') }}</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.coutTotal, 'currency') }}</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">{{ $t('tableau_bord.global_charge') }}</p>
        </Card>

        <!-- Card 3: {{ $t('tableau_bord.avg_cost_per_claim') }} (Blue theme) -->
        <Card class="bg-[#e6f0fa] border-[#cce0f5]/80 text-[#0d3880] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">{{ $t('tableau_bord.avg_cost_per_claim') }}</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.coutMoyen, 'currency') }}</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">{{ $t('tableau_bord.per_file') }}</p>
        </Card>

        <!-- Card 4: {{ $t('tableau_bord.total_itt_days') }} (Green theme) -->
        <Card v-if="isATBranch" class="bg-[#e6ffe6] border-[#d4fcd4]/80 text-[#006600] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">{{ $t('tableau_bord.total_itt_days') }}</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.totalJoursITT, 'number') }} j</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">{{ $t('tableau_bord.sur_n_sinistres', { n: kpis.nbSinistresWithITT }, kpis.nbSinistresWithITT) }}</p>
        </Card>

        <!-- Card 5: Taux d'ITT (Red/Pink theme) -->
        <Card v-if="isATBranch" class="bg-[#ffebeb] border-[#fed7d7]/80 text-[#b30000] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">{{ $t('tableau_bord.itt_rate_label') }}</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.tauxITT, 'percentage') }}</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">{{ $t('tableau_bord.of_claims') }}</p>
        </Card>

        <!-- Card 6: {{ $t('tableau_bord.avg_itt_duration') }} (Green theme) -->
        <Card v-if="isATBranch" class="bg-[#e6ffe6] border-[#d4fcd4]/80 text-[#006600] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">{{ $t('tableau_bord.avg_itt_duration') }}</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.dureeMoyenneITT, 'number') }} jours</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">{{ $t('tableau_bord.per_itt_case') }}</p>
        </Card>

        <!-- Card 7: {{ $t('tableau_bord.total_itt_amount') }} (Yellow theme) -->
        <Card v-if="isATBranch" class="bg-[#fffbe6] border-[#fef08a]/80 text-[#826a00] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">{{ $t('tableau_bord.total_itt_amount') }}</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.mntITTTotal, 'currency') }}</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">{{ $t('tableau_bord.paid_indemnities') }}</p>
        </Card>

        <!-- Card 8: {{ $t('tableau_bord.claims_with_ipp') }} (Red/Pink theme) -->
        <Card v-if="isATBranch" class="bg-[#ffebeb] border-[#fed7d7]/80 text-[#b30000] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">{{ $t('tableau_bord.claims_with_ipp') }}</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.nbSinistresWithIPP, 'number') }}</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">CCR: {{ formatKPIValue(kpis.ccrTotal, 'currency') }}</p>
        </Card>
      </div>
    </div>
  </div>
  
  <div v-else class="p-12 text-center bg-white rounded-[2rem] border border-slate-200/60 shadow-sm">
    <div class="w-16 h-16 bg-slate-100 rounded-full flex items-center justify-center mx-auto mb-4 text-slate-400">
      <FileText class="w-8 h-8" />
    </div>
    <h3 class="text-lg font-black text-slate-800 uppercase tracking-wider">{{ $t('tableau_bord.no_statistics') }}</h3>
  </div>
</template>
