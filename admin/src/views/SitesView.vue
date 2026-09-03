<script setup lang="ts">
import { ref, onMounted } from 'vue'

import { Button } from '@/components/ui/button'
import { Edit, Trash2 } from 'lucide-vue-next'
import { Badge } from '@/components/ui/badge'
import ExpertDataTable, { type DataTableColumn } from '@/components/shared/ExpertDataTable.vue'
import ConfirmModal from '@/components/shared/ConfirmModal.vue'
import SiteFormDialog from '@/components/shared/SiteFormDialog.vue'
import { AdminService } from '@/services/api/AdminService'
import { toast } from '@/components/ui/sonner'
import { useI18n } from 'vue-i18n'
import { usePermissions } from '@/composables/usePermissions'

const { t } = useI18n()
const { hasPermission } = usePermissions()
import { computed } from 'vue'

const tableColumns = computed<DataTableColumn[]>(() => {
  const cols: DataTableColumn[] = [
    { id: 'Id', label: t('sites.table.id'), className: 'w-[100px]' },
    { id: 'Code', label: t('sites.table.code') },
    { id: 'RaisonSociale', label: t('sites.table.raison_sociale') },
    { id: 'Ville', label: t('sites.table.ville'), className: 'hidden md:table-cell', cellClass: 'hidden md:table-cell' },
    { id: 'Actif', label: t('sites.table.status'), align: 'center' }
  ]
  if (hasPermission('sites:modifier') || hasPermission('sites:supprimer')) {
    cols.push({ id: 'actions', label: t('sites.table.actions'), align: 'right' })
  }
  return cols
})
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
    <ExpertDataTable 
      :title="$t('sites.title')"
      :description="$t('sites.description')"
      :items="sites"
      :columns="tableColumns"
      :loading="loading"
      :add-button-label="hasPermission('sites:creer') ? $t('sites.add_button') : undefined"
      @add="openCreate"
    >
      <template #cell-Id="{ item }">
        <span class="font-medium text-slate-900">{{ item.Id }}</span>
      </template>

      <template #cell-Code="{ item }">
        <span class="text-slate-600">{{ item.Code }}</span>
      </template>

      <template #cell-RaisonSociale="{ item }">
        <span class="font-medium text-slate-900">{{ item.RaisonSociale }}</span>
      </template>

      <template #cell-Ville="{ item }">
        <span class="text-slate-500">{{ item.Ville }}</span>
      </template>

      <template #cell-Actif="{ item }">
        <Badge :variant="item.Actif === 'O' ? 'default' : 'secondary'"
               :class="item.Actif === 'O' ? 'bg-emerald-100 text-emerald-700 hover:bg-emerald-100' : 'bg-slate-100 text-slate-600 hover:bg-slate-100'">
          {{ item.Actif === 'O' ? $t('statuts.actif') : $t('statuts.inactif') }}
        </Badge>
      </template>

      <template #cell-actions="{ item }">
        <div class="flex items-center justify-end gap-2">
          <Button v-if="hasPermission('sites:modifier')" variant="ghost" size="icon" @click="openEdit(item)"
                  class="text-slate-400 hover:text-primary hover:bg-primary/5 h-8 w-8 rounded-lg transition-colors">
            <Edit class="w-4 h-4" />
          </Button>
          <Button v-if="hasPermission('sites:supprimer')" variant="ghost" size="icon" @click="confirmDelete(item)"
                  class="text-slate-400 hover:text-red-600 hover:bg-red-50 h-8 w-8 rounded-lg transition-colors">
            <Trash2 class="w-4 h-4" />
          </Button>
        </div>
      </template>
    </ExpertDataTable>

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
