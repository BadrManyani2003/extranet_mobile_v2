<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import PageContainer from '@/components/shared/PageContainer.vue'
import ContratItem from '@/components/contrats/ContratItem.vue'
import LoadingSkeleton from '@/components/shared/LoadingSkeleton.vue'
import EmptyState from '@/components/shared/EmptyState.vue'
import { Input } from '@/components/ui/input'
import { Accordion } from '@/components/ui/accordion'
import { Search, Building2, Tag } from 'lucide-vue-next'
import { api } from '@/lib/api'
import { useFetch } from '@/composables/useFetch'

const { data: contrats, loading: chargementEnCours, execute: fetchContrats } = useFetch(api.data.getPolices)
const search = ref('')
const selectedClient = ref('')
const selectedBranch = ref('')
const detailedSearchQueries = ref<Record<string, string>>({})

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
    .filter((branchName): branchName is string => !!branchName)
  return [...new Set(branches)].sort()
})

const filteredContrats = computed(() => {
  if (!contrats.value) return []
  
  let result = contrats.value as any[]
  
  if (selectedClient.value) {
    result = result.filter((c: any) => c.client === selectedClient.value)
  }
  
  if (selectedBranch.value) {
    result = result.filter((c: any) => c.branche === selectedBranch.value)
  }
  
  if (search.value) {
    const q = search.value.toLowerCase()
    result = result.filter((c: any) => 
      String(c.police || '').toLowerCase().includes(q) || 
      String(c.branche || '').toLowerCase().includes(q) ||
      String(c.client || '').toLowerCase().includes(q)
    )
  }
  
  return result
})

const getStatusBadge = (statut: string) => {
  return statut === 'Actif' ? 'default' : 'outline'
}

const handleDetailedSearch = ({ policeId, onglet, requete }: any) => {
  detailedSearchQueries.value[`${policeId}-${onglet}`] = requete
}

onMounted(fetchContrats)
</script>

<template>
  <PageContainer :title="$t('contrats.title')" :subtitle="$t('contrats.subtitle')">
    <template #actions>
      <div class="hidden md:flex items-center gap-3">
        <!-- Client Filter Dropdown -->
        <div v-if="chargementEnCours || uniqueClients.length > 1" class="relative w-64">
          <Building2 class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <select 
            v-model="selectedClient"
            class="w-full h-11 rounded-xl bg-white border-none shadow-sm font-bold text-sm text-slate-800 focus:outline-none appearance-none pl-10 pr-10 cursor-pointer transition-all duration-200"
            :disabled="chargementEnCours"
          >
            <option v-if="chargementEnCours" value="" disabled>{{ $t('contrats.loading_clients') }}</option>
            <option v-else value="">{{ $t('contrats.all_clients') }}</option>
            <option v-for="clientName in uniqueClients" :key="clientName" :value="clientName">
              {{ clientName }}
            </option>
          </select>
          <div class="pointer-events-none absolute inset-y-0 right-4 flex items-center text-slate-400">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </div>
        <!-- Branch Filter Dropdown -->
        <div v-if="chargementEnCours || uniqueBranches.length > 1" class="relative w-64">
          <Tag class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <select 
            v-model="selectedBranch"
            class="w-full h-11 rounded-xl bg-white border-none shadow-sm font-bold text-sm text-slate-800 focus:outline-none appearance-none pl-10 pr-10 cursor-pointer transition-all duration-200"
            :disabled="chargementEnCours"
          >
            <option v-if="chargementEnCours" value="" disabled>{{ $t('contrats.loading_branches') || 'Chargement...' }}</option>
            <option v-else value="">{{ $t('contrats.all_branches') }}</option>
            <option v-for="branch in uniqueBranches" :key="branch" :value="branch">
              {{ branch }}
            </option>
          </select>
          <div class="pointer-events-none absolute inset-y-0 right-4 flex items-center text-slate-400">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </div>
        <!-- Search bar -->
        <div class="relative w-64">
          <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <Input v-model="search" :placeholder="$t('contrats.search_placeholder')" class="pl-10 h-11 rounded-xl bg-white border-none shadow-sm font-bold text-sm" />
        </div>
      </div>
    </template>

    <div class="space-y-4">
      <div class="md:hidden flex flex-col gap-3 mb-4">
        <!-- Client Filter Dropdown (mobile) -->
        <div v-if="chargementEnCours || uniqueClients.length > 1" class="relative w-full">
          <Building2 class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <select 
            v-model="selectedClient"
            class="w-full h-11 rounded-xl bg-white border-none shadow-sm font-bold text-sm text-slate-800 focus:outline-none appearance-none pl-10 pr-10 cursor-pointer transition-all duration-200"
            :disabled="chargementEnCours"
          >
            <option v-if="chargementEnCours" value="" disabled>{{ $t('contrats.loading_clients') }}</option>
            <option v-else value="">{{ $t('contrats.all_clients') }}</option>
            <option v-for="clientName in uniqueClients" :key="clientName" :value="clientName">
              {{ clientName }}
            </option>
          </select>
          <div class="pointer-events-none absolute inset-y-0 right-4 flex items-center text-slate-400">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </div>
        <div v-if="chargementEnCours || uniqueBranches.length > 1" class="relative w-full">
          <Tag class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <select 
            v-model="selectedBranch"
            class="w-full h-11 rounded-xl bg-white border-none shadow-sm font-bold text-sm text-slate-800 focus:outline-none appearance-none pl-10 pr-10 cursor-pointer transition-all duration-200"
            :disabled="chargementEnCours"
          >
            <option v-if="chargementEnCours" value="" disabled>{{ $t('contrats.loading_branches') || 'Chargement...' }}</option>
            <option v-else value="">{{ $t('contrats.all_branches') }}</option>
            <option v-for="branch in uniqueBranches" :key="branch" :value="branch">
              {{ branch }}
            </option>
          </select>
          <div class="pointer-events-none absolute inset-y-0 right-4 flex items-center text-slate-400">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </div>

        <!-- Search input (mobile) -->
        <div class="relative w-full">
          <Search class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
          <Input v-model="search" :placeholder="$t('commun.search')" class="pl-10 h-11 rounded-xl bg-white border-none shadow-sm font-bold text-sm" />
        </div>
      </div>

      <LoadingSkeleton v-if="chargementEnCours" :count="4" height="h-24" class="rounded-2xl" />
      
      <Accordion v-else-if="filteredContrats.length > 0" type="single" collapsible class="space-y-4">
        <ContratItem 
          v-for="contrat in filteredContrats" 
          :key="contrat.id" 
          :police="contrat"
          :getStatusBadge="getStatusBadge"
          :detailedSearchQueries="detailedSearchQueries"
          @update:searchQuery="handleDetailedSearch"
        />
      </Accordion>

      <EmptyState v-else :description="$t('commun.no_results')" class="bg-white rounded-[2rem] border-none shadow-sm" />
    </div>
  </PageContainer>
</template>