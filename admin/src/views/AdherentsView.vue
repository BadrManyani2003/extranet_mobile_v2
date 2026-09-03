<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useI18n } from 'vue-i18n'
import { User, UserPlus, CheckCircle2, Link, MoreVertical, Building2 } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import ExpertDataTable, { type DataTableColumn } from '@/components/shared/ExpertDataTable.vue'
import UserLinkDialog from '@/components/shared/UserLinkDialog.vue'
import { api } from '@/lib/api'
import { toast } from '@/components/ui/sonner'
import { formatDate } from '@/lib/utils'
import { usePermissions } from '@/composables/usePermissions'

const { t } = useI18n()
const { hasPermission } = usePermissions()

const adherents = ref<any[]>([])
const loading = ref(true)
const linkDialogOpen = ref(false)
const selectedAdherentId = ref<number | null>(null)
const activeDropdown = ref<number | null>(null)

const tableColumns = computed<DataTableColumn[]>(() => {
  const cols: DataTableColumn[] = [
    { id: 'matricule', label: t('adherents.table.id') },
    { id: 'nom', label: t('adherents.table.name') },
    { id: 'clientNom', label: t('adherents.table.client') },
    { id: 'dateAdhesion', label: t('adherents.table.membership_date') },
    { id: 'userNom', label: t('adherents.table.linked_user') }
  ]
  if (hasPermission('adherents:creer_utilisateur') || hasPermission('adherents:lier')) {
    cols.push({ id: 'actions', label: t('adherents.table.actions'), align: 'right' })
  }
  return cols
})

const fetchAdherents = async () => {
  loading.value = true
  try { adherents.value = await api.admin.getAdherents() } 
  catch (e: any) { toast.error(e.message || t('adherents.toast_load_error')) } 
  finally { loading.value = false }
}

const handleCreateUser = async (adherentId: number) => {
  try {
    await api.admin.createUserFromAdherent(adherentId)
    toast.success(t('adherents.toast_create_success'))
    fetchAdherents()
  } catch (e: any) { toast.error(e.message) }
}

const openLinkDialog = (adherentId: number) => {
  selectedAdherentId.value = adherentId
  linkDialogOpen.value = true
}

const handleLinkUser = async (userId: number) => {
  if (!selectedAdherentId.value) return
  try {
    await api.admin.linkUserToAdherent(selectedAdherentId.value, userId)
    toast.success(t('adherents.toast_link_success'))
    linkDialogOpen.value = false
    fetchAdherents()
  } catch (e: any) { toast.error(e.message) }
}

onMounted(fetchAdherents)
</script>

<template>
  <ExpertDataTable 
    :title="$t('adherents.title')" 
    :description="$t('adherents.subtitle')"
    :items="adherents"
    :columns="tableColumns"
    :loading="loading"
    :search-placeholder="$t('adherents.search_placeholder')"
  >
    <template #cell-matricule="{ item }">
      <span class="font-bold text-slate-400 py-4">{{ item.matricule || '-' }}</span>
    </template>
    
    <template #cell-nom="{ item }">
      <div class="flex items-center gap-3">
        <div class="w-9 h-9 rounded-xl bg-slate-100 flex items-center justify-center text-slate-400 group-hover:bg-primary group-hover:text-primary-foreground transition-all shadow-sm">
          <User class="w-5 h-5" />
        </div>
        <span class="font-bold text-slate-900 tracking-tight">{{ item.nom }}</span>
      </div>
    </template>

    <template #cell-clientNom="{ item }">
      <div v-if="item.clientNom" class="flex items-center gap-2.5">
        <div class="w-8 h-8 rounded-xl bg-blue-50/80 border border-blue-100 flex items-center justify-center text-blue-600 shrink-0 shadow-xs">
          <Building2 class="w-4 h-4" />
        </div>
        <span class="font-bold text-slate-800 text-sm tracking-tight">{{ item.clientNom }}</span>
      </div>
      <span v-else class="text-slate-300 font-bold text-sm italic">-</span>
    </template>

    <template #cell-dateAdhesion="{ item }">
      <span class="text-sm font-medium text-slate-600">{{ formatDate(item.dateAdhesion) }}</span>
    </template>

    <template #cell-userNom="{ item }">
      <div v-if="item.fkUserId" class="flex items-center gap-2 text-emerald-600 font-bold text-[14px] uppercase tracking-widest bg-emerald-50 px-3 py-1.5 rounded-lg w-fit">
        <CheckCircle2 class="w-3.5 h-3.5" />
        {{ item.userNom }}
      </div>
      <span v-else class="text-slate-300 font-black text-[14px] uppercase tracking-widest italic">( - )</span>
    </template>

    <template #cell-actions="{ item, index, items }">
      <div v-if="!item.fkUserId" class="flex justify-end gap-1 items-center relative">
        <div class="relative" @click.stop v-if="hasPermission('adherents:creer_utilisateur') || hasPermission('adherents:lier')">
          <Button variant="ghost" size="icon" class="h-9 w-9 rounded-xl hover:bg-slate-200 text-slate-500" @click="activeDropdown = activeDropdown === item.id ? null : item.id">
            <MoreVertical class="w-4 h-4" />
          </Button>
          
          <div v-if="activeDropdown === item.id" :class="[
            'absolute right-0 w-48 bg-white rounded-xl shadow-[0_4px_20px_-4px_rgba(0,0,0,0.1)] border border-slate-100 py-1.5 z-50 flex flex-col overflow-hidden',
            index >= items.length - 2 && index > 0 ? 'bottom-full mb-2' : 'top-full mt-1'
          ]">
            <button v-if="hasPermission('adherents:creer_utilisateur')" @click="handleCreateUser(item.id); activeDropdown = null" class="flex items-center px-3 py-2 text-sm font-medium text-slate-600 hover:bg-primary hover:text-primary-foreground w-full text-left transition-colors">
              <UserPlus class="w-4 h-4 mr-2" /> {{ $t('users.add_button') }}
            </button>
            <button v-if="hasPermission('adherents:lier')" @click="openLinkDialog(item.id); activeDropdown = null" class="flex items-center px-3 py-2 text-sm font-medium text-slate-600 hover:bg-emerald-50 hover:text-emerald-600 w-full text-left transition-colors">
              <Link class="w-4 h-4 mr-2" /> {{ $t('commun.link') }}
            </button>
          </div>
        </div>
      </div>
      <div v-else class="text-emerald-500 pr-4">
        <CheckCircle2 class="w-5 h-5 ml-auto" />
      </div>
    </template>
  </ExpertDataTable>

  <UserLinkDialog 
    :open="linkDialogOpen"
    :title="$t('users.link_dialog_title')"
    :description="$t('users.link_dialog_desc_adherent')"
    @close="linkDialogOpen = false"
    @select="handleLinkUser"
  />
</template>
