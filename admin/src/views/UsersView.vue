<script setup lang="ts">
import { ref, onMounted } from 'vue'

import { Button } from '@/components/ui/button'
import { Edit, Trash2, RefreshCcw, ShieldCheck, UserCircle, Users, Globe, MoreVertical } from 'lucide-vue-next'
import { Badge } from '@/components/ui/badge'
import ExpertDataTable, { type DataTableColumn } from '@/components/shared/ExpertDataTable.vue'
import ConfirmModal from '@/components/shared/ConfirmModal.vue'
import UserFormDialog from '@/components/shared/UserFormDialog.vue'
import UserRolesDialog from '@/components/shared/UserRolesDialog.vue'
import UserSimulationsDialog from '@/components/shared/UserSimulationsDialog.vue'
import UserSitesDialog from '@/components/shared/UserSitesDialog.vue'
import UserSiteRolesDialog from '@/components/shared/UserSiteRolesDialog.vue'
import { api } from '@/lib/api'
import { toast } from '@/components/ui/sonner'
import { useI18n } from 'vue-i18n'
import { usePermissions } from '@/composables/usePermissions'

const { t } = useI18n()
const { hasPermission } = usePermissions()
import { computed } from 'vue'

const tableColumns = computed<DataTableColumn[]>(() => {
  const cols: DataTableColumn[] = [
    { id: 'nom', label: t('users.table.name'), className: 'min-w-[260px]' },
    { id: 'email', label: t('users.table.email') },
    { id: 'nature', label: t('users.table.nature') },
    { id: 'roles', label: t('users.table.roles') },
    { id: 'status', label: t('users.table.status') }
  ]
  if (hasPermission('simulations:lire') || hasPermission('utilisateurs:gerer_sites') || hasPermission('utilisateurs:gerer_permissions_sites') || hasPermission('utilisateurs:gerer_roles') || hasPermission('utilisateurs:modifier') || hasPermission('utilisateurs:supprimer')) {
    cols.push({ id: 'actions', label: t('users.table.actions'), align: 'right', className: 'pr-8', cellClass: 'pr-8' })
  }
  return cols
})

const users = ref<any[]>([])
const loading = ref(true)
const processing = ref(false)
const activeDropdown = ref<number | null>(null)

const dialogs = ref({
  edit: false,
  roles: false,
  delete: false,
  sync: false,
  simulations: false,
  sites: false,
  siteRoles: false
})

const activeUser = ref<any>(null)

onMounted(() => {
  document.addEventListener('click', () => {
    activeDropdown.value = null
  })
  fetchUsers()
})

const fetchUsers = async () => {
  loading.value = true
  try { users.value = await api.admin.getUsers() } 
  catch (e: any) { toast.error(e.message || t('users.toast_load_error')) } 
  finally { loading.value = false }
}

const openEdit = (user: any = null) => {
  activeUser.value = user
  dialogs.value.edit = true
}

const openRoles = (user: any) => {
  activeUser.value = user
  dialogs.value.roles = true
}

const handleSync = async () => {
  if (!activeUser.value) return
  processing.value = true
  try {
    await api.admin.syncKeycloak(activeUser.value.id)
    toast.success(t('users.toast_sync_success'))
    dialogs.value.sync = false
    fetchUsers()
  } catch (e: any) { toast.error(e.message) }
  finally { processing.value = false }
}

const handleDelete = async () => {
  if (!activeUser.value) return
  processing.value = true
  try {
    await api.admin.deleteUser(activeUser.value.id)
    toast.success(t('users.toast_delete_success'))
    dialogs.value.delete = false
    fetchUsers()
  } catch (e: any) { toast.error(e.message) }
  finally { processing.value = false }
}

const openSimulations = (user: any) => {
  activeUser.value = user
  dialogs.value.simulations = true
}

const openSites = (user: any) => {
  activeUser.value = user
  dialogs.value.sites = true
}

const openSiteRoles = (user: any) => {
  activeUser.value = user
  dialogs.value.siteRoles = true
}
</script>

<template>
  <ExpertDataTable 
    :title="$t('users.title')" 
    :description="$t('users.description')"
    :items="users"
    :columns="tableColumns"
    :loading="loading"
    :add-button-label="hasPermission('utilisateurs:creer') ? $t('users.add') : undefined"
    :search-placeholder="$t('users.search')"
    @add="openEdit()"
  >
    <template #cell-nom="{ item }">
      <div class="flex items-center gap-3">
        <div class="w-10 h-10 rounded-xl bg-slate-100 flex items-center justify-center text-slate-400 group-hover:bg-primary group-hover:text-primary-foreground transition-all shadow-sm">
          <UserCircle class="w-6 h-6" />
        </div>
        <div>
          <div class="font-bold text-slate-900 tracking-tight text-base">{{ item.nom }}</div>
        </div>
      </div>
    </template>

    <template #cell-email="{ item }">
      <div class="flex flex-col">
        <span class="text-sm font-bold text-slate-700">{{ item.email }}</span>
        <span class="text-[14px] text-slate-400 font-medium mt-0.5">{{ item.telephone || '---' }}</span>
      </div>
    </template>

    <template #cell-nature="{ item }">
      <Badge v-if="item.nature === 'C'" variant="secondary" class="bg-emerald-50 text-emerald-600 border-emerald-100 text-[14px] font-black uppercase tracking-widest px-2 py-0.5 rounded-lg">{{ $t('users.natures.client') }}</Badge>
      <Badge v-else-if="item.nature === 'A'" variant="secondary" class="bg-orange-50 text-orange-600 border-orange-100 text-[14px] font-black uppercase tracking-widest px-2 py-0.5 rounded-lg">{{ $t('users.natures.cabinet') }}</Badge>
      <span v-else class="text-slate-300 italic text-[14px]">{{ item.nature || '-' }}</span>
    </template>

    <template #cell-roles="{ item }">
      <div class="flex flex-wrap gap-1 max-w-[280px]">
        <Badge v-for="role in (item.roles?.split(', ') || [])" :key="role" 
          class="bg-white border border-slate-100 text-slate-500 text-[14px] font-black uppercase tracking-tight py-0.5 px-1.5 shadow-sm">
          {{ role }}
        </Badge>
        <span v-if="!item.roles" class="text-[14px] text-slate-300 font-bold uppercase tracking-widest italic">( - )</span>
      </div>
    </template>

    <template #cell-status="{ item }">
      <div class="flex flex-col gap-1.5">
        <div v-if="item.idAuth" class="flex items-center gap-2">
          <div class="w-1.5 h-1.5 rounded-full bg-emerald-500"></div>
          <span class="text-emerald-600 text-[14px] font-black uppercase tracking-widest">{{ $t('statuts.actif') }}</span>
        </div>
        <Button v-else-if="item.canManage !== 0 && hasPermission('utilisateurs:synchroniser')" variant="ghost" size="sm" class="h-8 gap-2 text-[14px] text-orange-600 font-black hover:bg-orange-50 rounded-xl px-2" @click="activeUser = item; dialogs.sync = true">
          <RefreshCcw class="w-3 h-3" /> {{ $t('statuts.sync') }}
        </Button>
        <div v-else class="flex items-center gap-2">
          <div class="w-1.5 h-1.5 rounded-full bg-slate-300"></div>
          <span class="text-slate-400 text-[14px] font-black uppercase tracking-widest">{{ $t('statuts.inactif') }}</span>
        </div>
      </div>
    </template>

    <template #cell-actions="{ item, index, items }">
      <div class="flex justify-end gap-1 items-center relative">
        <!-- Dropdown for secondary actions -->
        <div class="relative" @click.stop v-if="(hasPermission('simulations:lire') && (item.nature === 'A' || item.roles?.toLowerCase().includes('admin') || item.roles?.toLowerCase().includes('commercial'))) || (hasPermission('utilisateurs:gerer_sites') && item.nature === 'A') || (hasPermission('utilisateurs:gerer_permissions_sites') && item.nature === 'A') || (hasPermission('utilisateurs:gerer_roles') && item.idAuth)">
          <Button variant="ghost" size="icon" class="h-9 w-9 rounded-xl hover:bg-slate-200 text-slate-500" @click="activeDropdown = activeDropdown === item.id ? null : item.id">
            <MoreVertical class="w-4 h-4" />
          </Button>
          
          <!-- Menu panel -->
          <div v-if="activeDropdown === item.id" :class="[
            'absolute right-0 w-48 bg-white rounded-xl shadow-[0_4px_20px_-4px_rgba(0,0,0,0.1)] border border-slate-100 py-1.5 z-50 flex flex-col overflow-hidden',
            index >= items.length - 2 && index > 0 ? 'bottom-full mb-2' : 'top-full mt-1'
          ]">
            <button v-if="hasPermission('simulations:lire') && (item.nature === 'A' || item.roles?.toLowerCase().includes('admin') || item.roles?.toLowerCase().includes('commercial'))" @click="openSimulations(item); activeDropdown = null" class="flex items-center px-3 py-2 text-sm font-medium text-slate-600 hover:bg-slate-50 hover:text-primary w-full text-left transition-colors">
              <Users class="w-4 h-4 mr-2" /> {{ $t('statuts.simulations') }}
            </button>

            <button v-if="hasPermission('utilisateurs:gerer_sites') && item.nature === 'A'" @click="openSites(item); activeDropdown = null" class="flex items-center px-3 py-2 text-sm font-medium text-slate-600 hover:bg-slate-50 hover:text-primary w-full text-left transition-colors">
              <Globe class="w-4 h-4 mr-2" /> {{ $t('users.manage_sites') }}
            </button>

            <button v-if="hasPermission('utilisateurs:gerer_permissions_sites') && item.nature === 'A'" @click="openSiteRoles(item); activeDropdown = null" class="flex items-center px-3 py-2 text-sm font-medium text-slate-600 hover:bg-indigo-50 hover:text-indigo-600 w-full text-left transition-colors">
              <ShieldCheck class="w-4 h-4 mr-2" /> {{ $t('users.manage_site_permissions') }}
            </button>

            <button v-if="hasPermission('utilisateurs:gerer_roles') && item.idAuth" @click="openRoles(item); activeDropdown = null" class="flex items-center px-3 py-2 text-sm font-medium text-slate-600 hover:bg-indigo-50 hover:text-indigo-600 w-full text-left transition-colors">
              <ShieldCheck class="w-4 h-4 mr-2" /> {{ $t('users.table.roles') }}
            </button>
          </div>
        </div>

        <Button v-if="item.canManage !== 0 && hasPermission('utilisateurs:modifier')" variant="ghost" size="icon" class="h-9 w-9 rounded-xl hover:bg-slate-200" @click="openEdit(item)"><Edit class="w-4 h-4 text-slate-600" /></Button>
        <Button v-if="item.canManage !== 0 && hasPermission('utilisateurs:supprimer')" variant="ghost" size="icon" class="h-9 w-9 rounded-xl hover:bg-red-50 text-red-500" @click="activeUser = item; dialogs.delete = true"><Trash2 class="w-4 h-4" /></Button>
      </div>
    </template>
  </ExpertDataTable>

  <!-- Modals -->
  <ConfirmModal 
    :open="dialogs.sync" 
    :title="$t('commun.sync') + ' ?'" 
    :description="$t('users.sync_desc')"
    :confirm-text="$t('commun.sync')"
    variant="warning"
    :loading="processing"
    @close="dialogs.sync = false"
    @confirm="handleSync"
  />

  <ConfirmModal 
    :open="dialogs.delete" 
    :title="$t('commun.delete') + ' ?'" 
    :description="$t('users.delete_desc')"
    :confirm-text="$t('commun.delete')"
    variant="danger"
    :loading="processing"
    @close="dialogs.delete = false"
    @confirm="handleDelete"
  />

  <!-- Form Dialog -->
  <UserFormDialog
    :open="dialogs.edit"
    :user="activeUser"
    @saved="fetchUsers"
    @close="dialogs.edit = false"
  />

  <!-- Roles Dialog -->
  <UserRolesDialog
    :open="dialogs.roles"
    :user="activeUser"
    @saved="fetchUsers"
    @close="dialogs.roles = false"
  />

  <!-- Simulations Dialog -->
  <UserSimulationsDialog
    :open="dialogs.simulations"
    :user="activeUser"
    @close="dialogs.simulations = false"
  />

  <!-- Sites Dialog -->
  <UserSitesDialog
    :open="dialogs.sites"
    :user="activeUser"
    @close="dialogs.sites = false; activeUser = null"
    @saved="fetchUsers"
  />

  <UserSiteRolesDialog
    :open="dialogs.siteRoles"
    :user="activeUser"
    @close="dialogs.siteRoles = false; activeUser = null"
  />
</template>
