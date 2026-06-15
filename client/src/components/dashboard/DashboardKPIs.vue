<script setup lang="ts">
import { Card } from '@/components/ui/card'
import { FileText } from 'lucide-vue-next'
import { formatKPIValue } from '@/lib/utils'

defineProps<{
  kpis: any
  yearRange: string
}>()
</script>

<template>
  <div class="bg-white rounded-[2rem] border border-slate-200/80 shadow-sm overflow-hidden transition-all duration-300">
    <div class="w-full bg-[#0d3880] px-6 py-4 md:px-8 md:py-5 flex items-center justify-between overflow-hidden relative">
      <div class="absolute inset-0 bg-gradient-to-r from-blue-900/10 via-transparent to-blue-900/5 pointer-events-none"></div>
      <div class="space-y-0.5 z-10">
        <h2 class="text-lg md:text-2xl font-black text-white uppercase tracking-wider">INDICATEURS CLÉS DE PERFORMANCE</h2>
      </div>
    </div>

    <!-- KPI cards grid inside container -->
    <div class="p-6 md:p-8 bg-slate-50/50">
      <div v-if="kpis" class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
        
        <!-- Card 1: Nb sinistres total (Blue theme) -->
        <Card class="bg-[#e6f0fa] border-[#cce0f5]/80 text-[#0d3880] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">Nb sinistres total</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.nbSinistresTotal, 'number') }}</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">{{ yearRange }}</p>
        </Card>

        <!-- Card 2: Coût total (Yellow theme) -->
        <Card class="bg-[#fffbe6] border-[#fef08a]/80 text-[#826a00] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">Coût total</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.coutTotal, 'currency') }}</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">charge globale</p>
        </Card>

        <!-- Card 3: Coût moyen / sinistre (Blue theme) -->
        <Card class="bg-[#e6f0fa] border-[#cce0f5]/80 text-[#0d3880] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">Coût moyen / sinistre</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.coutMoyen, 'currency') }}</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">par dossier</p>
        </Card>

        <!-- Card 4: Total jours ITT (Green theme) -->
        <Card class="bg-[#e6ffe6] border-[#d4fcd4]/80 text-[#006600] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">Total jours ITT</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.totalJoursITT, 'number') }} j</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">sur {{ formatKPIValue(kpis.nbSinistresWithITT, 'number') }} sinistre{{ kpis.nbSinistresWithITT > 1 ? 's' : '' }}</p>
        </Card>

        <!-- Card 5: Taux d'ITT (Red/Pink theme) -->
        <Card class="bg-[#ffebeb] border-[#fed7d7]/80 text-[#b30000] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">Taux d'ITT</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.tauxITT, 'percentage') }}</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">des sinistres</p>
        </Card>

        <!-- Card 6: Durée moy. ITT (Green theme) -->
        <Card class="bg-[#e6ffe6] border-[#d4fcd4]/80 text-[#006600] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">Durée moy. ITT</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.dureeMoyenneITT, 'number') }} jours</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">par cas ITT</p>
        </Card>

        <!-- Card 7: MNT ITT total (Yellow theme) -->
        <Card class="bg-[#fffbe6] border-[#fef08a]/80 text-[#826a00] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">MNT ITT total</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.mntITTTotal, 'currency') }}</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">indemnités versées</p>
        </Card>

        <!-- Card 8: Sinistres avec IPP (Red/Pink theme) -->
        <Card class="bg-[#ffebeb] border-[#fed7d7]/80 text-[#b30000] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
          <div class="space-y-1.5">
            <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">Sinistres avec IPP</p>
            <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.nbSinistresWithIPP, 'number') }}</h3>
          </div>
          <p class="text-xs font-bold opacity-60 mt-4">CCR: {{ formatKPIValue(kpis.ccrTotal, 'currency') }}</p>
        </Card>
      </div>
      
      <div v-else class="p-12 text-center bg-white rounded-[1.8rem] border border-slate-200/60 shadow-sm">
        <div class="w-16 h-16 bg-slate-100 rounded-full flex items-center justify-center mx-auto mb-4 text-slate-400">
          <FileText class="w-8 h-8" />
        </div>
        <h3 class="text-lg font-black text-slate-800 uppercase tracking-wider">Aucune statistique</h3>
      </div>
    </div>
  </div>
</template>
