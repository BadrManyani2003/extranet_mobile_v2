<script setup lang="ts">
import { Card } from '@/components/ui/card'
import { FileSignature, Car, HeartPulse, ShieldAlert, Activity, CheckCircle2, XCircle } from 'lucide-vue-next'
import { formatKPIValue } from '@/lib/utils'

const props = defineProps<{
  kpis: any
  yearRange: string
  mixedStats: {
    nombreContrats: number
    nombreVehicules: number
    nombreAdherents: number
    nombreSinistresEnCours: number
    policesParStatut: Record<string, number>
  }
}>()
</script>

<template>
  <div v-if="kpis" class="pdf-avoid-break mb-12 space-y-6">
    <div class="flex items-center gap-4">
      <div class="w-1.5 h-8 bg-[#0d3880] rounded-full"></div>
      <h2 class="text-xl md:text-2xl font-black text-slate-800 uppercase tracking-wider">{{ $t('tableau_bord.mixed.global_stats') }}</h2>
    </div>

    <!-- Main Global Metrics Grid -->
    <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-5 gap-6">
      
      <!-- Contrats Total -->
      <Card class="bg-[#f0f9ff] border-[#bae6fd]/80 text-[#0369a1] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
        <div class="space-y-1.5">
          <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">{{ $t('tableau_bord.mixed.total_contracts') }}</p>
          <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(mixedStats.nombreContrats, 'number') }}</h3>
        </div>
        <div class="flex items-center gap-2 mt-4">
          <FileSignature class="w-4 h-4 opacity-60" />
          <p class="text-xs font-bold opacity-60">{{ $t('tableau_bord.mixed.all_policies') }}</p>
        </div>
      </Card>

      <!-- Vehicules (Auto) -->
      <Card class="bg-[#f0fdf4] border-[#bbf7d0]/80 text-[#15803d] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
        <div class="space-y-1.5">
          <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">{{ $t('tableau_bord.mixed.auto_fleet') }}</p>
          <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(mixedStats.nombreVehicules, 'number') }}</h3>
        </div>
        <div class="flex items-center gap-2 mt-4">
          <Car class="w-4 h-4 opacity-60" />
          <p class="text-xs font-bold opacity-60">{{ $t('tableau_bord.mixed.insured_vehicles') }}</p>
        </div>
      </Card>

      <!-- Adherents (Sante) -->
      <Card class="bg-[#fff1f2] border-[#fecdd3]/80 text-[#be123c] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
        <div class="space-y-1.5">
          <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">{{ $t('tableau_bord.mixed.total_adherents') }}</p>
          <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(mixedStats.nombreAdherents, 'number') }}</h3>
        </div>
        <div class="flex items-center gap-2 mt-4">
          <HeartPulse class="w-4 h-4 opacity-60" />
          <p class="text-xs font-bold opacity-60">{{ $t('tableau_bord.mixed.health_insurance') }}</p>
        </div>
      </Card>

      <!-- Total Sinistres -->
      <Card class="bg-[#fefce8] border-[#fef08a]/80 text-[#826a00] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
        <div class="space-y-1.5">
          <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">{{ $t('tableau_bord.mixed.total_claims') }}</p>
          <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(kpis.nbSinistresTotal, 'number') }}</h3>
        </div>
        <div class="flex items-center gap-2 mt-4">
          <ShieldAlert class="w-4 h-4 opacity-60" />
          <p class="text-xs font-bold opacity-60">{{ yearRange }}</p>
        </div>
      </Card>

      <!-- Sinistres En Cours -->
      <Card class="bg-[#fff7ed] border-[#fed7aa]/80 text-[#c2410c] rounded-[1.8rem] p-6 shadow-sm flex flex-col justify-between min-h-[140px] transition-all duration-300 hover:-translate-y-1 hover:shadow-md">
        <div class="space-y-1.5">
          <p class="text-[13px] font-extrabold uppercase tracking-wide opacity-80">{{ $t('tableau_bord.mixed.ongoing_claims') }}</p>
          <h3 class="text-3xl font-black tracking-tight mt-1">{{ formatKPIValue(mixedStats.nombreSinistresEnCours, 'number') }}</h3>
        </div>
        <div class="flex items-center gap-2 mt-4">
          <Activity class="w-4 h-4 opacity-60" />
          <p class="text-xs font-bold opacity-60">{{ $t('tableau_bord.mixed.open_files') }}</p>
        </div>
      </Card>

    </div>

    <!-- Secondary Grid: Status -->
    <div class="mt-6">
      <!-- Police status breakdown -->
      <div class="bg-white rounded-[2rem] p-8 border border-slate-200/60 shadow-sm">
        <h3 class="text-sm font-black text-slate-500 uppercase tracking-widest mb-6">{{ $t('tableau_bord.mixed.status_distribution') }}</h3>
        <div class="space-y-4">
          <div v-for="(count, status) in mixedStats.policesParStatut" :key="status" class="flex items-center justify-between p-4 rounded-xl bg-slate-50">
            <div class="flex items-center gap-3">
              <CheckCircle2 v-if="status === 'En cours' || status === 'Active'" class="w-5 h-5 text-green-500" />
              <XCircle v-else-if="status === 'Résiliée' || status === 'Echue'" class="w-5 h-5 text-red-400" />
              <Activity v-else class="w-5 h-5 text-blue-400" />
              <span class="font-bold text-slate-700">{{ status || $t('tableau_bord.mixed.not_specified') }}</span>
            </div>
            <span class="font-black text-lg text-slate-900">{{ count }}</span>
          </div>
          <div v-if="Object.keys(mixedStats.policesParStatut).length === 0" class="text-slate-400 text-sm italic py-4">
            {{ $t('tableau_bord.mixed.no_status_data') }}
          </div>
        </div>
      </div>

    </div>
  </div>
</template>
