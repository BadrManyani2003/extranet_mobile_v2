<script setup lang="ts">
import { computed } from 'vue'
import { CalendarDays, RefreshCw, Building2, Tag, FileText, FileDown } from 'lucide-vue-next'
import DatePicker from '@/components/ui/date-picker/DatePicker.vue'

const selectedPoliceId = defineModel<number | string | null>('selectedPoliceId', { required: true })
const selectedClient = defineModel<string>('selectedClient', { required: true })
const selectedBranch = defineModel<string>('selectedBranch', { required: true })
const dateDu = defineModel<string>('dateDu', { required: true })
const dateAu = defineModel<string>('dateAu', { required: true })

defineProps<{
  displayPolices: any[]
  uniqueClients: string[]
  uniqueBranches: string[]
  loadingPolices: boolean
  loadingState: boolean
}>()

defineEmits<{
  (e: 'refresh'): void
  (e: 'exportPdf'): void
}>()

// Native date inputs format their display internally according to browser locale
</script>

<template>
  <div class="glass-card p-6 md:p-8 bg-white/95 backdrop-blur-md relative overflow-hidden transition-all duration-300 no-print">
    <div class="absolute -right-16 -top-16 w-32 h-32 bg-primary/5 rounded-full blur-2xl"></div>
    
    <h2 class="font-black text-slate-900 uppercase tracking-widest text-xs mb-6 flex items-center gap-2">
      <CalendarDays class="w-4 h-4 text-primary" />
      {{ $t('tableau_bord.search_filters') }}
    </h2>
    
    <div class="grid grid-cols-1 md:grid-cols-3 gap-6 items-end">
      <!-- Client select -->
      <div class="space-y-2">
        <label class="text-xs font-bold text-slate-500 uppercase tracking-wider">{{ $t('contrats.filter_client') }}</label>
        <div class="relative">
          <Building2 class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <select 
            v-model="selectedClient"
            class="w-full bg-slate-50 border border-slate-200/80 rounded-2xl pl-10 pr-10 py-3 font-bold text-sm text-slate-800 focus:outline-none focus:ring-2 focus:ring-primary/20 appearance-none transition-all duration-200 cursor-pointer shadow-sm"
            :disabled="loadingPolices"
          >
            <option value="">{{ $t('contrats.all_clients') }}</option>
            <option v-for="cName in uniqueClients" :key="cName" :value="cName">
              {{ cName }}
            </option>
          </select>
          <div class="pointer-events-none absolute inset-y-0 right-4 flex items-center text-slate-400">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Branch select -->
      <div class="space-y-2">
        <label class="text-xs font-bold text-slate-500 uppercase tracking-wider">{{ $t('contrats.branche') }}</label>
        <div class="relative">
          <Tag class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <select 
            v-model="selectedBranch"
            class="w-full bg-slate-50 border border-slate-200/80 rounded-2xl pl-10 pr-10 py-3 font-bold text-sm text-slate-800 focus:outline-none focus:ring-2 focus:ring-primary/20 appearance-none transition-all duration-200 cursor-pointer shadow-sm"
            :disabled="loadingPolices"
          >
            <option value="">{{ $t('contrats.all_branches') }}</option>
            <option v-for="bName in uniqueBranches" :key="bName" :value="bName">
              {{ bName }}
            </option>
          </select>
          <div class="pointer-events-none absolute inset-y-0 right-4 flex items-center text-slate-400">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Police select -->
      <div class="space-y-2">
        <label class="text-xs font-bold text-slate-500 uppercase tracking-wider">{{ $t('contrats.num') }}</label>
        <div class="relative">
          <FileText class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <select 
            v-model="selectedPoliceId"
            class="w-full bg-slate-50 border border-slate-200/80 rounded-2xl pl-10 pr-10 py-3 font-bold text-sm text-slate-800 focus:outline-none focus:ring-2 focus:ring-primary/20 appearance-none transition-all duration-200 cursor-pointer shadow-sm"
            :disabled="loadingPolices"
          >
            <option v-if="loadingPolices" value="" disabled>{{ $t('contrats.loading_clients') }}</option>
            <option v-else-if="displayPolices.length === 0" value="" disabled>{{ $t('tableau_bord.no_contract_available') }}</option>
            <option v-if="!loadingPolices && displayPolices.length > 1" value="all">{{ $t('contrats.all_policies') }}</option>
            <option 
              v-for="p in displayPolices" 
              :key="p.id" 
              :value="p.id"
            >
              {{ p.police }} ({{ p.compagnie || p.branche || 'AT' }}{{ p.statut ? ' - ' + p.statut : '' }})
            </option>
          </select>
          <div class="pointer-events-none absolute inset-y-0 right-4 flex items-center text-slate-400">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </div>
      </div>

      <!-- Date Du -->
      <div class="space-y-2">
        <label class="text-xs font-bold text-slate-500 uppercase tracking-wider">{{ $t('commun.date_from') }}</label>
        <DatePicker 
          v-model="dateDu" 
          expert-type="from"
          placeholder="jj/mm/aaaa"
        />
      </div>

      <!-- Date Au -->
      <div class="space-y-2">
        <label class="text-xs font-bold text-slate-500 uppercase tracking-wider">{{ $t('commun.date_to') }}</label>
        <div class="flex gap-2 items-center">
          <DatePicker 
            v-model="dateAu" 
            expert-type="to"
            placeholder="jj/mm/aaaa"
            class="flex-1"
          />
          <button 
            @click="$emit('refresh')"
            class="p-3 bg-slate-100 hover:bg-slate-200/70 text-slate-600 rounded-2xl transition-all duration-200 shadow-sm shrink-0 flex items-center justify-center hover:scale-105 h-[46px] w-[46px]"
            title="Rafraîchir"
          >
            <RefreshCw class="w-5 h-5" :class="{ 'animate-spin': loadingState }" />
          </button>
        </div>
      </div>

      <!-- PDF Export Button -->
      <div class="space-y-2">
        <label class="text-xs font-bold invisible block md:block">Export</label>
        <button 
          @click="$emit('exportPdf')"
          class="w-full py-3 bg-primary hover:bg-primary/90 text-white font-black rounded-2xl transition-all duration-200 shadow-md shrink-0 flex items-center justify-center gap-2 hover:scale-[1.02] active:scale-[0.98]"
        >
          <FileDown class="w-5 h-5" />
          {{ $t('contrats.export_pdf') }}
        </button>
      </div>
    </div>
  </div>
</template>

<style scoped>
select, input {
  font-family: 'Outfit', sans-serif;
  transition: all 0.2s ease-in-out;
}
</style>
