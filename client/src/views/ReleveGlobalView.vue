<script setup lang="ts">
import { onMounted, ref, computed, watch } from 'vue'
import { useI18n } from 'vue-i18n'
import { FileDown, Building2, Tag } from 'lucide-vue-next'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import DataTableWrapper from '@/components/shared/DataTableWrapper.vue'
import DatePicker from '@/components/ui/date-picker/DatePicker.vue'
import { api } from '@/lib/api'
import { formatCurrency, formatDate } from '@/lib/utils'
import * as XLSX from 'xlsx-js-style'

const { t } = useI18n()
const quittances = ref<any[]>([])
const loading = ref(true)

// Filtres
const selectedClient = ref('')
const selectedBranche = ref('')
const selectedPolice = ref('')
const dateDu = ref('')
const dateAu = ref('')

const uniqueClients = computed(() => {
  const clients = quittances.value.map(q => q.client).filter(Boolean)
  return [...new Set(clients)].sort()
})

const uniqueBranches = computed(() => {
  const branches = quittances.value.map(q => q.branche).filter(Boolean)
  return [...new Set(branches)].sort()
})

const uniquePolices = computed(() => {
  let list = quittances.value
  if (selectedClient.value) {
    list = list.filter(q => q.client === selectedClient.value)
  }
  if (selectedBranche.value) {
    list = list.filter(q => q.branche === selectedBranche.value)
  }
  const polices = list.map(q => q.numPolice).filter(Boolean)
  return [...new Set(polices)].sort()
})

watch([selectedClient, selectedBranche], () => {
  selectedPolice.value = ''
})

const toDateStr = (dateVal: any) => {
  if (!dateVal) return ''
  const d = new Date(dateVal)
  if (isNaN(d.getTime())) {
    const s = String(dateVal)
    if (s.includes('T')) return s.split('T')[0]
    return s
  }
  const year = d.getFullYear()
  const month = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

const filteredQuittances = computed(() => {
  return quittances.value.filter(item => {
    if (selectedClient.value && item.client !== selectedClient.value) {
      return false
    }
    if (selectedBranche.value && item.branche !== selectedBranche.value) {
      return false
    }
    if (selectedPolice.value && item.numPolice !== selectedPolice.value) {
      return false
    }
    if (dateDu.value) {
      const start = toDateStr(item.dateDebut)
      if (start < dateDu.value) return false
    }
    if (dateAu.value) {
      const start = toDateStr(item.dateDebut)
      if (start > dateAu.value) return false
    }
    return true
  })
})



const fetchAllQuittances = async () => {
  try {
    loading.value = true
    const res = await api.data.getImpayes(undefined, 'N')
    quittances.value = res
  } catch (e) {
    console.error(e)
  } finally {
    loading.value = false
  }
}

const exportToExcel = () => {
  if (!filteredQuittances.value.length) return

  const headers = [
    t('quittances.num'), t('contrats.num'), t('contrats.branche'), t('quittances.from'), t('quittances.to'), t('quittances.total'), t('quittances.unpaid')
  ]

  const headerStyle = {
    font: { bold: true, color: { rgb: "000000" } },
    fill: { fgColor: { rgb: "F1F5F9" } }, // Gris clair (slate-100)
    border: {
      top: { style: "thin" },
      bottom: { style: "thin" },
      left: { style: "thin" },
      right: { style: "thin" }
    },
    alignment: { horizontal: "center", vertical: "center" }
  }

  const cellStyle = {
    border: {
      top: { style: "thin" },
      bottom: { style: "thin" },
      left: { style: "thin" },
      right: { style: "thin" }
    },
    alignment: { vertical: "center" }
  }

  // 2. Création de la matrice de données
  const data = [
    headers.map(h => ({ v: h, s: headerStyle })), // Ligne d'en-tête
    ...filteredQuittances.value.map(item => [
      { v: item.numero, s: cellStyle },
      { v: item.numPolice, s: cellStyle },
      { v: item.branche, s: cellStyle },
      { v: formatDate(item.dateDebut), s: cellStyle },
      { v: formatDate(item.dateFin), s: cellStyle },
      { v: item.montantTotal, s: { ...cellStyle, alignment: { horizontal: "right" } }, t: 'n', z: '#,##0.00' },
      { v: item.montantImpaye, s: { ...cellStyle, alignment: { horizontal: "right" }, font: { color: { rgb: item.montantImpaye > 0 ? "DC2626" : "059669" } } }, t: 'n', z: '#,##0.00' }
    ])
  ]

  // 3. Création de la feuille
  const ws = XLSX.utils.aoa_to_sheet(data)
  
  // Ajustement des largeurs
  ws['!cols'] = [
    { wch: 18 }, { wch: 15 }, { wch: 20 }, { wch: 12 }, { wch: 12 }, { wch: 15 }, { wch: 15 }
  ]

  const wb = XLSX.utils.book_new()
  XLSX.utils.book_append_sheet(wb, ws, t('vue_releve_global.title'))

  XLSX.writeFile(wb, `Releve_Global_${new Date().toISOString().split('T')[0]}.xlsx`)
}

onMounted(() => {
  fetchAllQuittances()
})
</script>

<template>
  <DataTableWrapper 
    :title="$t('vue_releve_global.title')" 
    :description="$t('vue_releve_global.subtitle')"
    :items="filteredQuittances" 
    :loading="loading" 
    :search-placeholder="$t('vue_releve_global.search')"
  >
    <template #extra-actions>
      <Button 
        variant="outline" 
        class="rounded-2xl h-12 px-6 gap-2 border-slate-200 bg-white hover:bg-slate-50 text-slate-900 font-black shadow-sm"
        @click="exportToExcel"
        :disabled="!filteredQuittances.length"
      >
        <FileDown class="w-5 h-5 text-slate-900" />
        {{ $t('commun.download') }}
      </Button>
    </template>

    <template #filters>
      <div class="flex flex-wrap items-center gap-3 lg:w-auto mt-2 sm:mt-0 flex-1 lg:flex-initial">
        <!-- Client Filter -->
        <div class="relative min-w-[160px] flex-1 sm:flex-initial">
          <Building2 class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 pointer-events-none" />
          <select 
            v-model="selectedClient"
            class="w-full bg-white border border-slate-200 rounded-2xl pl-10 pr-8 py-3.5 font-bold text-sm text-slate-800 focus:outline-none focus:ring-4 focus:ring-primary/5 focus:border-primary appearance-none transition-all shadow-sm cursor-pointer"
          >
            <option value="">{{ $t('contrats.all_clients') }}</option>
            <option v-for="cName in uniqueClients" :key="cName" :value="cName">
              {{ cName }}
            </option>
          </select>
          <div class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-slate-400">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </div>

        <!-- Branche Filter -->
        <div class="relative min-w-[160px] flex-1 sm:flex-initial">
          <Tag class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 pointer-events-none" />
          <select 
            v-model="selectedBranche"
            class="w-full bg-white border border-slate-200 rounded-2xl pl-10 pr-8 py-3.5 font-bold text-sm text-slate-800 focus:outline-none focus:ring-4 focus:ring-primary/5 focus:border-primary appearance-none transition-all shadow-sm cursor-pointer"
          >
            <option value="">{{ $t('contrats.all_branches') }}</option>
            <option v-for="bName in uniqueBranches" :key="bName" :value="bName">
              {{ bName }}
            </option>
          </select>
          <div class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-slate-400">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </div>

        <!-- Police Filter -->
        <div class="relative min-w-[160px] flex-1 sm:flex-initial">
          <FileText class="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400 pointer-events-none" />
          <select 
            v-model="selectedPolice"
            class="w-full bg-white border border-slate-200 rounded-2xl pl-10 pr-8 py-3.5 font-bold text-sm text-slate-800 focus:outline-none focus:ring-4 focus:ring-primary/5 focus:border-primary appearance-none transition-all shadow-sm cursor-pointer"
          >
            <option value="">{{ $t('contrats.all_policies') }}</option>
            <option v-for="pNum in uniquePolices" :key="pNum" :value="pNum">
              {{ pNum }}
            </option>
          </select>
          <div class="pointer-events-none absolute inset-y-0 right-3 flex items-center text-slate-400">
            <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7" />
            </svg>
          </div>
        </div>

        <!-- Date Du -->
        <DatePicker 
          v-model="dateDu" 
          :label="$t('commun.date_from')" 
          expert-type="from"
        />

        <!-- Date Au -->
        <DatePicker 
          v-model="dateAu" 
          :label="$t('commun.date_to')" 
          expert-type="to"
        />
      </div>
    </template>

    <template #default="{ items }">
      <div class="border border-slate-100 rounded-2xl overflow-hidden bg-white shadow-sm">
        <Table class="w-full min-w-[1000px]">
          <TableHeader class="bg-slate-50/50">
            <TableRow>
              <TableHead class="font-black text-slate-900 uppercase tracking-widest text-[14px] py-4 px-6">{{ $t('quittances.num') }}</TableHead>
              <TableHead class="font-black text-slate-900 uppercase tracking-widest text-[14px] py-4">{{ $t('contrats.num') }}</TableHead>
              <TableHead class="font-black text-slate-900 uppercase tracking-widest text-[14px] py-4">{{ $t('contrats.branche') }}</TableHead>
              <TableHead class="font-black text-slate-900 uppercase tracking-widest text-[14px] py-4">{{ $t('quittances.from') }}</TableHead>
              <TableHead class="font-black text-slate-900 uppercase tracking-widest text-[14px] py-4">{{ $t('quittances.to') }}</TableHead>
              <TableHead class="text-right font-black text-slate-900 uppercase tracking-widest text-[14px] py-4">{{ $t('quittances.total') }}</TableHead>
              <TableHead class="text-right font-black text-slate-900 uppercase tracking-widest text-[14px] py-4 px-6">{{ $t('quittances.unpaid') }}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            <TableRow v-for="item in items" :key="item.id" class="hover:bg-slate-50/80 transition-colors border-b border-slate-50 last:border-0">
              <TableCell class="py-4 px-6 font-black text-slate-900 text-sm">
                {{ item.numero }}
              </TableCell>
              
              <TableCell class="text-sm text-slate-600 font-bold">
                {{ item.numPolice }}
              </TableCell>

              <TableCell class="text-sm text-slate-500 font-medium">
                {{ item.branche }}
              </TableCell>

              <TableCell class="text-sm text-slate-600 font-bold">
                {{ formatDate(item.dateDebut) }}
              </TableCell>

              <TableCell class="text-sm text-slate-600 font-bold">
                {{ formatDate(item.dateFin) }}
              </TableCell>

              <TableCell class="text-right text-sm font-black text-slate-900">
                {{ formatCurrency(item.montantTotal) }}
              </TableCell>

              <TableCell class="text-right py-4 px-6">
                <span :class="item.montantImpaye > 0 ? 'text-red-600 font-black' : 'text-emerald-600 font-bold'" class="text-sm">
                  {{ formatCurrency(item.montantImpaye) }}
                </span>
              </TableCell>
            </TableRow>
          </TableBody>
        </Table>
      </div>
    </template>
  </DataTableWrapper>
</template>


