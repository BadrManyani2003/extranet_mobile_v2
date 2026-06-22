<script setup lang="ts">
import { ref, watch } from 'vue'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogDescription, DialogFooter } from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Building2, Search, X } from 'lucide-vue-next'
import { Input } from '@/components/ui/input'
import { api } from '@/lib/api'
import { toast } from '@/components/ui/sonner'

const props = defineProps<{
  open: boolean
  clientId: number | null
  clientName: string
}>()

const emit = defineEmits(['close', 'select'])

const clientsList = ref<any[]>([])
const loading = ref(false)
const searchQuery = ref('')

const fetchClients = async () => {
  loading.value = true
  try {
    const rawClients = await api.admin.getClients()
    // Filtrer le client lui-même pour éviter l'auto-référence
    clientsList.value = rawClients.filter((c: any) => c.id !== props.clientId)
  } catch (e: any) {
    toast.error(e.message || 'Erreur lors du chargement des clients')
  } finally {
    loading.value = false
  }
}

const filteredClients = () => {
  if (!searchQuery.value) return clientsList.value
  const q = searchQuery.value.toLowerCase()
  return clientsList.value.filter(c => 
    c.raisonSociale?.toLowerCase().includes(q) || 
    c.email?.toLowerCase().includes(q)
  )
}

const handleSelect = (parent: any) => {
  emit('select', parent ? parent.id : null)
}

watch(() => props.open, (isOpen) => {
  if (isOpen) {
    searchQuery.value = ''
    fetchClients()
  }
})
</script>

<template>
  <Dialog :open="open" @update:open="emit('close')">
    <DialogContent class="w-[92%] sm:max-w-2xl max-h-[85vh] rounded-[2rem] shadow-2xl p-0 overflow-hidden border-none font-['Outfit'] flex flex-col bg-white">
      <DialogHeader class="p-8 bg-slate-50/50 border-b border-slate-100 shrink-0">
        <DialogTitle class="text-xl font-black text-slate-900">
          {{ $t('clients.parent_dialog_title') }}
        </DialogTitle>
        <DialogDescription class="text-slate-500 font-medium mt-1">
          {{ $t('clients.parent_dialog_desc', { name: clientName }) }}
        </DialogDescription>
      </DialogHeader>

      <div class="p-8 flex-1 flex flex-col min-h-0">
        <!-- Barre de recherche et bouton Supprimer le parent -->
        <div class="flex flex-col sm:flex-row gap-3 mb-4 shrink-0">
          <div class="relative flex-1">
            <Search class="absolute left-4 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
            <Input 
              v-model="searchQuery" 
              :placeholder="$t('clients.search_placeholder')" 
              class="pl-11 h-12 bg-slate-50 border-slate-200 rounded-xl focus-visible:ring-primary shadow-sm"
            />
          </div>
          <Button 
            variant="outline" 
            class="h-12 px-6 rounded-xl border-red-100 hover:border-red-200 hover:bg-red-50 text-red-600 font-bold transition-all shrink-0 gap-2"
            @click="handleSelect(null)"
          >
            <X class="w-4 h-4" /> {{ $t('clients.no_parent') }}
          </Button>
        </div>

        <div class="flex-1 overflow-y-auto border rounded-2xl border-slate-100 min-h-0 bg-white shadow-sm scrollbar-thin scrollbar-thumb-slate-200">
          <Table>
            <TableHeader class="bg-slate-50 sticky top-0 z-10 shadow-sm">
              <TableRow>
                <TableHead class="font-black text-slate-900 uppercase tracking-widest text-[13px] py-4 pl-6">
                  {{ $t('clients.table.name') }}
                </TableHead>
                <TableHead class="font-black text-slate-900 uppercase tracking-widest text-[13px] py-4">
                  {{ $t('clients.table.type') }}
                </TableHead>
                <TableHead class="text-right font-black text-slate-900 uppercase tracking-widest text-[13px] py-4 pr-6">
                  {{ $t('clients.table.actions') }}
                </TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              <TableRow v-if="loading" v-for="i in 3" :key="i">
                <TableCell colspan="3" class="h-14 animate-pulse bg-slate-50/50"></TableCell>
              </TableRow>
              <TableRow v-else v-for="c in filteredClients()" :key="c.id" class="hover:bg-slate-50/80 transition-colors border-b border-slate-50">
                <TableCell class="py-4 pl-6">
                  <div class="flex items-center gap-3">
                    <div class="w-9 h-9 rounded-xl bg-slate-100 flex items-center justify-center text-slate-400 shadow-sm">
                      <Building2 class="w-4 h-4" />
                    </div>
                    <span class="font-bold text-slate-900">{{ c.raisonSociale }}</span>
                  </div>
                </TableCell>
                <TableCell class="py-4 text-sm font-medium text-slate-500">
                  {{ c.particulier === 'O' ? $t('clients.type.individual') : $t('clients.type.company') }}
                </TableCell>
                <TableCell class="py-4 pr-6 text-right">
                  <Button 
                    variant="outline" 
                    size="sm" 
                    class="rounded-xl h-8 font-black text-[13px] uppercase tracking-widest border-slate-200 hover:bg-primary/5 hover:text-primary hover:border-primary/20 shadow-sm transition-all"
                    @click="handleSelect(c)"
                  >
                    {{ $t('commun.select') }}
                  </Button>
                </TableCell>
              </TableRow>
              <TableRow v-if="!loading && filteredClients().length === 0">
                <TableCell colspan="3" class="h-32 text-center text-slate-400 font-medium italic">
                  {{ $t('commun.no_results') }}
                </TableCell>
              </TableRow>
            </TableBody>
          </Table>
        </div>
      </div>

      <DialogFooter class="p-8 bg-slate-50/50 border-t border-slate-100 shrink-0">
        <Button variant="ghost" class="w-full h-12 rounded-xl font-bold border-slate-200 text-slate-700 hover:bg-slate-100" @click="emit('close')">
          {{ $t('commun.cancel') }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
