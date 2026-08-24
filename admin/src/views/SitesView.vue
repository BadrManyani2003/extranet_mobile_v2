<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Button } from '@/components/ui/button'
import { Edit, Plus, Globe, Trash2 } from 'lucide-vue-next'
import { Badge } from '@/components/ui/badge'
import DataTableWrapper from '@/components/shared/DataTableWrapper.vue'
import ConfirmModal from '@/components/shared/ConfirmModal.vue'
import SiteFormDialog from '@/components/shared/SiteFormDialog.vue'
import { AdminService } from '@/services/api/AdminService'
import { toast } from '@/components/ui/sonner'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

// -- States
const sites = ref<any[]>([])
const loading = ref(true)
const processing = ref(false)
const dialogOpen = ref(false)

const deleteSiteOpen = ref(false)
const siteToDelete = ref<any>(null)
const processingDelete = ref(false)

const activeSite = ref<any>({
  Id: null,
  Code: '',
  RaisonSociale: '',
  Adresse: '',
  Ville: '',
  Actif: 'O'
})

// -- Actions
const fetchSites = async () => {
  loading.value = true
  try { sites.value = await AdminService.getAllSites() } 
  catch (e: any) { toast.error(e.message || t('sites.toast_load_error')) } 
  finally { loading.value = false }
}

const openCreate = () => {
  activeSite.value = { Id: null, Code: '', RaisonSociale: '', Adresse: '', Ville: '', Actif: 'O' }
  dialogOpen.value = true
}

const openEdit = (site: any) => {
  activeSite.value = { ...site }
  dialogOpen.value = true
}

const saveSite = async (siteToSave: any) => {
  if (!siteToSave.RaisonSociale) return toast.error(t('sites.validation_raison_sociale'))
  
  processing.value = true
  try {
    if (siteToSave.Id) {
      await AdminService.updateSite(siteToSave.Id, siteToSave)
      toast.success(t('sites.toast_save_success'))
    } else {
      await AdminService.createSite(siteToSave)
      toast.success(t('sites.toast_create_success'))
    }
    dialogOpen.value = false
    fetchSites()
  } catch (e: any) {
    toast.error(e.message || t('sites.toast_save_error'))
  } finally {
    processing.value = false
  }
}

const confirmDelete = (site: any) => {
  siteToDelete.value = site
  deleteSiteOpen.value = true
}

const handleDelete = async () => {
  if (!siteToDelete.value) return
  processingDelete.value = true
  try {
    await AdminService.deleteSite(siteToDelete.value.Id)
    toast.success(t('sites.toast_delete_success'))
    deleteSiteOpen.value = false
    fetchSites()
  } catch (e: any) {
    toast.error(e.message || t('sites.toast_delete_error'))
  } finally {
    processingDelete.value = false
  }
}

onMounted(() => {
  fetchSites()
})
</script>

<template>
  <div class="space-y-6">
    <DataTableWrapper 
      :title="$t('sites.title')"
      :description="$t('sites.description')"
      :items="sites"
      :loading="loading"
      :add-button-label="$t('sites.add_button')"
      @add="openCreate"
    >
      <template #default="{ items: paginatedSites }">
        <Table>
        <TableHeader>
          <TableRow class="bg-slate-50/50 hover:bg-slate-50/50 border-b-slate-100">
            <TableHead class="w-[100px] font-semibold text-slate-600">ID</TableHead>
            <TableHead class="font-semibold text-slate-600">Code</TableHead>
            <TableHead class="font-semibold text-slate-600">Raison Sociale</TableHead>
            <TableHead class="font-semibold text-slate-600 hidden md:table-cell">Ville</TableHead>
            <TableHead class="font-semibold text-slate-600 text-center">Statut</TableHead>
            <TableHead class="text-right font-semibold text-slate-600">Actions</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="site in paginatedSites" :key="site.Id" class="group transition-colors hover:bg-slate-50/80">
            <TableCell class="font-medium text-slate-900">{{ site.Id }}</TableCell>
            <TableCell class="text-slate-600">{{ site.Code }}</TableCell>
            <TableCell class="font-medium text-slate-900">{{ site.RaisonSociale }}</TableCell>
            <TableCell class="text-slate-500 hidden md:table-cell">{{ site.Ville }}</TableCell>
            <TableCell class="text-center">
              <Badge :variant="site.Actif === 'O' ? 'default' : 'secondary'"
                     :class="site.Actif === 'O' ? 'bg-emerald-100 text-emerald-700 hover:bg-emerald-100' : 'bg-slate-100 text-slate-600 hover:bg-slate-100'">
                {{ site.Actif === 'O' ? 'Actif' : 'Inactif' }}
              </Badge>
            </TableCell>
            <TableCell class="text-right">
              <div class="flex items-center justify-end gap-2">
                <Button variant="ghost" size="icon" @click="openEdit(site)"
                        class="text-slate-400 hover:text-primary hover:bg-primary/5 h-8 w-8 rounded-lg transition-colors">
                  <Edit class="w-4 h-4" />
                </Button>
                <Button variant="ghost" size="icon" @click="confirmDelete(site)"
                        class="text-slate-400 hover:text-red-600 hover:bg-red-50 h-8 w-8 rounded-lg transition-colors">
                  <Trash2 class="w-4 h-4" />
                </Button>
              </div>
            </TableCell>
          </TableRow>
        </TableBody>
        </Table>
      </template>
    </DataTableWrapper>

    <!-- Dialog Create/Edit -->
    <SiteFormDialog 
      :open="dialogOpen"
      :site="activeSite"
      :processing="processing"
      @close="dialogOpen = false"
      @save="saveSite"
    />

    <!-- Delete Confirmation Modal -->
    <ConfirmModal 
      :open="deleteSiteOpen"
      :title="$t('sites.delete_title')"
      :description="$t('sites.delete_desc', { name: siteToDelete?.RaisonSociale })"
      variant="danger"
      :loading="processingDelete"
      @close="deleteSiteOpen = false"
      @confirm="handleDelete"
    />
  </div>
</template>
