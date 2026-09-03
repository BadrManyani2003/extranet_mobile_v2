<script setup lang="ts">
import { ref, onMounted } from 'vue'

import { Button } from '@/components/ui/button'
import { Edit, Trash2, ShieldCheck, MoreVertical } from 'lucide-vue-next'
import { Badge } from '@/components/ui/badge'
import ExpertDataTable, { type DataTableColumn } from '@/components/shared/ExpertDataTable.vue'
import ConfirmModal from '@/components/shared/ConfirmModal.vue'
import SiteRoleFormDialog from '@/components/shared/SiteRoleFormDialog.vue'
import SiteRolePermissionsDialog from '@/components/shared/SiteRolePermissionsDialog.vue'
import { SiteRoleService } from '@/services/api/SiteRoleService'
import { AdminService } from '@/services/api/AdminService'
import { toast } from '@/components/ui/sonner'
import { useI18n } from 'vue-i18n'
import { usePermissions } from '@/composables/usePermissions'

const { t } = useI18n()
const { hasPermission } = usePermissions()
import { computed } from 'vue'

const tableColumns = computed<DataTableColumn[]>(() => {
  const cols: DataTableColumn[] = [
    { id: 'Id', label: t('roles.table.id'), className: 'w-[100px]' },
    { id: 'Name', label: t('roles.table.name') },
    { id: 'Description', label: t('roles.table.description') },
    { id: 'SiteId', label: t('roles.table.scope') }
  ]
  if (hasPermission('roles:gerer_permissions') || hasPermission('roles:modifier') || hasPermission('roles:supprimer')) {
    cols.push({ id: 'actions', label: t('roles.table.actions'), align: 'right' })
  }
  return cols
})

const roles = ref<any[]>([])
const sites = ref<any[]>([])
const loading = ref(true)
const processing = ref(false)

const dialogOpen = ref(false)
const permissionsDialogOpen = ref(false)
const deleteRoleOpen = ref(false)
const activeDropdown = ref<number | null>(null)

const activeRole = ref<any>(null)
const roleToDelete = ref<any>(null)
const processingDelete = ref(false)

const loadData = async () => {
  loading.value = true
  try {
    const [rolesData, sitesData] = await Promise.all([
      SiteRoleService.getSiteRoles(),
      AdminService.getAllSites()
    ])
    roles.value = rolesData
    sites.value = sitesData
  } catch (e: any) {
    toast.error(e.message || t('roles.toast_load_error'))
  } finally {
    loading.value = false
  }
}

const getSiteName = (siteId: number | null) => {
  if (!siteId) return t('roles.global_all')
  const site = sites.value.find(s => s.Id === siteId)
  return site ? site.RaisonSociale : t('roles.site_prefix', { id: siteId })
}

const openCreate = () => {
  activeRole.value = null
  dialogOpen.value = true
}

const openEdit = (role: any) => {
  activeRole.value = role
  dialogOpen.value = true
}

const openPermissions = (role: any) => {
  activeRole.value = role
  permissionsDialogOpen.value = true
}

const saveRole = async (roleToSave: any) => {
  processing.value = true
  try {
    const payload = {
      name: roleToSave.Name,
      description: roleToSave.Description,
      siteId: roleToSave.SiteId
    }

    if (roleToSave.Id) {
      await SiteRoleService.updateSiteRole(roleToSave.Id, payload)
      toast.success(t('roles.toast_save_success'))
    } else {
      await SiteRoleService.createSiteRole(payload)
      toast.success(t('roles.toast_create_success'))
    }
    dialogOpen.value = false
    loadData()
  } catch (e: any) {
    toast.error(e.message || t('roles.toast_save_error'))
  } finally {
    processing.value = false
  }
}

const confirmDelete = (role: any) => {
  roleToDelete.value = role
  deleteRoleOpen.value = true
}

const handleDelete = async () => {
  if (!roleToDelete.value) return
  processingDelete.value = true
  try {
    await SiteRoleService.deleteSiteRole(roleToDelete.value.Id)
    toast.success(t('roles.toast_delete_success'))
    deleteRoleOpen.value = false
    loadData()
  } catch (e: any) {
    toast.error(e.message || t('roles.toast_delete_error'))
  } finally {
    processingDelete.value = false
  }
}

onMounted(() => {
  loadData()
})
</script>

<template>
  <div class="space-y-6">
    <ExpertDataTable 
      :title="$t('roles.title')"
      :description="$t('roles.description')"
      :items="roles"
      :columns="tableColumns"
      :loading="loading"
      :add-button-label="hasPermission('roles:creer') ? $t('roles.add_button') : undefined"
      @add="openCreate"
    >
      <template #cell-Id="{ item }">
        <span class="font-medium text-slate-900">{{ item.Id }}</span>
      </template>

      <template #cell-Name="{ item }">
        <span class="text-slate-600 font-medium">{{ item.Name }}</span>
      </template>

      <template #cell-Description="{ item }">
        <span class="text-slate-500">{{ item.Description || '-' }}</span>
      </template>

      <template #cell-SiteId="{ item }">
        <Badge :variant="item.SiteId ? 'secondary' : 'default'"
               :class="item.SiteId ? 'bg-indigo-50 text-indigo-700 hover:bg-indigo-50' : 'bg-emerald-100 text-emerald-700 hover:bg-emerald-100'">
          {{ getSiteName(item.SiteId) }}
        </Badge>
      </template>

      <template #cell-actions="{ item, index, items }">
        <div class="flex items-center justify-end gap-2 relative">
          <div class="relative" @click.stop v-if="hasPermission('roles:gerer_permissions')">
            <Button variant="ghost" size="icon" class="h-8 w-8 rounded-lg hover:bg-slate-200 text-slate-500 transition-colors" @click="activeDropdown = activeDropdown === (item.Id || item.id) ? null : (item.Id || item.id)">
              <MoreVertical class="w-4 h-4" />
            </Button>
            
            <div v-if="activeDropdown === (item.Id || item.id)" :class="[
              'absolute right-0 w-48 bg-white rounded-xl shadow-[0_4px_20px_-4px_rgba(0,0,0,0.1)] border border-slate-100 py-1.5 z-50 flex flex-col overflow-hidden',
              index >= items.length - 2 && index > 0 ? 'bottom-full mb-2' : 'top-full mt-1'
            ]">
              <button v-if="hasPermission('roles:gerer_permissions')" @click="openPermissions(item); activeDropdown = null" class="flex items-center px-3 py-2 text-sm font-medium text-slate-600 hover:bg-indigo-50 hover:text-indigo-600 w-full text-left transition-colors">
                <ShieldCheck class="w-4 h-4 mr-2" /> {{ $t('roles.manage_permissions') }}
              </button>
            </div>
          </div>

          <Button v-if="hasPermission('roles:modifier')" variant="ghost" size="icon" @click="openEdit(item)" :title="$t('roles.edit_role')"
                  class="text-slate-400 hover:text-primary hover:bg-primary/5 h-8 w-8 rounded-lg transition-colors">
            <Edit class="w-4 h-4" />
          </Button>
          <Button v-if="hasPermission('roles:supprimer')" variant="ghost" size="icon" @click="confirmDelete(item)" :title="$t('roles.delete_title')"
                  class="text-slate-400 hover:text-red-600 hover:bg-red-50 h-8 w-8 rounded-lg transition-colors">
            <Trash2 class="w-4 h-4" />
          </Button>
        </div>
      </template>
    </ExpertDataTable>

    <!-- Dialog Create/Edit -->
    <SiteRoleFormDialog 
      :open="dialogOpen"
      :role="activeRole"
      :processing="processing"
      @close="dialogOpen = false"
      @save="saveRole"
    />

    <!-- Dialog Permissions -->
    <SiteRolePermissionsDialog 
      :open="permissionsDialogOpen"
      :role="activeRole"
      @close="permissionsDialogOpen = false"
    />

    <!-- Delete Confirmation Modal -->
    <ConfirmModal 
      :open="deleteRoleOpen"
      :title="$t('roles.delete_title')"
      :description="$t('roles.delete_desc', { name: roleToDelete?.Name })"
      variant="danger"
      :loading="processingDelete"
      @close="deleteRoleOpen = false"
      @confirm="handleDelete"
    />
  </div>
</template>
