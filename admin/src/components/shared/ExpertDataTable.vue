<script setup lang="ts">
import { ref, computed } from 'vue'
import { Search, ChevronLeft, ChevronRight, Plus } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Skeleton } from '@/components/ui/skeleton'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

export interface DataTableColumn {
  id: string
  label: string
  align?: 'left' | 'center' | 'right'
  className?: string
  cellClass?: string
  sortable?: boolean
}

const props = defineProps<{
  title: string
  description: string
  items: any[]
  columns: DataTableColumn[]
  loading: boolean
  searchPlaceholder?: string
  addButtonLabel?: string
}>()

const emit = defineEmits(['add', 'search'])

const searchQuery = ref('')
const currentPage = ref(1)
const itemsPerPage = 5

const filteredItems = computed(() => {
  if (!searchQuery.value) return props.items
  const q = searchQuery.value.toLowerCase()

  return props.items.filter(item => 
    Object.values(item).some(val => 
      String(val).toLowerCase().includes(q)
    )
  )
})

const totalPages = computed(() => Math.ceil(filteredItems.value.length / itemsPerPage))
const paginatedItems = computed(() => {
  const start = (currentPage.value - 1) * itemsPerPage
  return filteredItems.value.slice(start, start + itemsPerPage)
})

const handleSearch = () => {
  currentPage.value = 1
  emit('search', searchQuery.value)
}
</script>

<template>
  <div class="space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500 font-['Outfit']">

    <!-- Header Actions -->
    <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4">
      <div>
        <h2 class="text-3xl font-black tracking-tight text-slate-900">{{ title }}</h2>
      </div>
      <Button v-if="addButtonLabel" class="rounded-2xl h-12 px-6 gap-2 bg-primary hover:bg-primary/90 text-primary-foreground shadow-xl shadow-primary/20" @click="$emit('add')">
        <Plus class="w-5 h-5" /> {{ addButtonLabel }}
      </Button>
    </div>

    <!-- Search Bar -->
    <div class="flex items-center gap-4">
      <div class="relative flex-1 max-w-sm group">
        <Search class="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400 group-focus-within:text-primary transition-colors" />
        <input 
          v-model="searchQuery"
          type="text" 
          :placeholder="searchPlaceholder || t('commun.search')" 
          class="w-full bg-white border border-slate-200 rounded-2xl py-3.5 pl-12 pr-4 text-sm font-bold focus:ring-4 focus:ring-primary/5 focus:border-primary outline-none transition-all shadow-sm"
          @input="handleSearch"
        />
      </div>
      <!-- Add extra filters slot here if needed -->
      <slot name="filters"></slot>
    </div>

    <!-- Table Card -->
    <div class="border border-slate-200 rounded-[2rem] bg-white shadow-xl shadow-slate-200/50 overflow-hidden">
      <!-- Loading Skeleton -->
      <div v-if="loading" class="w-full">
        <table class="w-full text-sm text-left">
          <thead class="bg-slate-50/50 border-b border-slate-100">
            <tr>
              <th v-for="col in columns" :key="'skel-h-' + col.id" class="px-6 py-4">
                <Skeleton class="h-4 w-24 rounded" />
              </th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="row in 5" :key="row" class="border-b border-slate-50 last:border-0">
              <td v-for="col in columns" :key="'skel-c-' + col.id" class="px-6 py-4">
                <Skeleton class="h-4 w-full max-w-[200px] rounded" :class="{ 'w-3/4': col.id === columns[0].id, 'w-1/2': col.id === columns[1]?.id }" />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
      
      <!-- Actual Data Table -->
      <template v-else>
        <div class="overflow-x-auto w-full min-h-[14rem]">
          <Table class="border-t border-slate-100 w-full min-w-[1000px]">
            <TableHeader class="bg-slate-50/50">
              <TableRow>
                <TableHead 
                  v-for="col in columns" 
                  :key="col.id" 
                  :class="[
                    'table-header-text', 
                    col.align === 'right' ? 'text-right' : col.align === 'center' ? 'text-center' : '',
                    col.className
                  ]"
                >
                  <slot :name="`header-${col.id}`" :column="col">
                    {{ col.label }}
                  </slot>
                </TableHead>
              </TableRow>
            </TableHeader>
            
            <TableBody>
              <TableRow 
                v-for="(item, index) in paginatedItems" 
                :key="item.id || item.Id || index" 
                class="group hover:bg-slate-50/50 transition-colors border-b border-slate-50"
              >
                <TableCell 
                  v-for="col in columns" 
                  :key="col.id" 
                  :class="[
                    col.align === 'right' ? 'text-right' : col.align === 'center' ? 'text-center' : '',
                    col.cellClass
                  ]"
                >
                  <slot 
                    :name="`cell-${col.id}`" 
                    :item="item" 
                    :index="index" 
                    :items="paginatedItems"
                    :column="col"
                  >
                    {{ item[col.id] }}
                  </slot>
                </TableCell>
              </TableRow>
              
              <TableRow v-if="filteredItems.length === 0">
                <TableCell :colspan="columns.length" class="h-24 text-center text-slate-500 font-medium">
                  {{ $t('commun.no_data') }}
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>

        <!-- Pagination Footer -->
        <div class="border-t border-slate-100 p-6 flex items-center justify-between bg-slate-50/30">
          <p class="text-xs text-slate-400 font-black uppercase tracking-widest">
            {{ $t('commun.total', { count: filteredItems.length }) }}
          </p>
          <div class="flex items-center gap-3">
            <Button variant="outline" size="sm" :disabled="currentPage === 1" class="rounded-xl h-10 w-10 border-slate-200" @click="currentPage--">
              <ChevronLeft class="w-5 h-5" />
            </Button>
            <div class="flex items-center px-4 h-10 bg-white border border-slate-200 rounded-xl text-sm font-black text-slate-900 shadow-sm">
              {{ currentPage }} <span class="mx-2 text-slate-200">/</span> {{ totalPages || 1 }}
            </div>
            <Button variant="outline" size="sm" :disabled="currentPage === totalPages || totalPages === 0" class="rounded-xl h-10 w-10 border-slate-200" @click="currentPage++">
              <ChevronRight class="w-5 h-5" />
            </Button>
          </div>
        </div>
      </template>
    </div>
  </div>
</template>
