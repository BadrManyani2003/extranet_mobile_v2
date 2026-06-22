<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { useI18n } from 'vue-i18n'
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table'
import { Building2, UserPlus, CheckCircle2, Link, X, MessageSquare, Edit, MailPlus } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { Badge } from '@/components/ui/badge'
import DataTableWrapper from '@/components/shared/DataTableWrapper.vue'
import UserLinkDialog from '@/components/shared/UserLinkDialog.vue'
import ConfirmModal from '@/components/shared/ConfirmModal.vue'
import ClientEmailsDialog from '@/components/shared/ClientEmailsDialog.vue'
import ClientParentDialog from '@/components/shared/ClientParentDialog.vue'
import { api } from '@/lib/api'
import { toast } from '@/components/ui/sonner'
import { useRole } from '@/composables/useRole'

const { t } = useI18n()
const { isAdmin, isCommercial } = useRole()

const clients = ref<any[]>([])
const loading = ref(true)
const linkDialogOpen = ref(false)
const unlinkConfirmOpen = ref(false)
const unlinking = ref(false)
const pendingUnlinkData = ref<{ clientId: number, userId: string } | null>(null)
const selectedClientId = ref<number | null>(null)

const emailsDialogOpen = ref(false)
const selectedClientForEmails = ref<any>(null)
const emailsSaving = ref(false)

const parentDialogOpen = ref(false)
const selectedClientForParent = ref<any>(null)
const parentSaving = ref(false)

const openParentDialog = (client: any) => {
  selectedClientForParent.value = client
  parentDialogOpen.value = true
}

const handleSaveParent = async (parentId: number | null) => {
  if (!selectedClientForParent.value) return
  parentSaving.value = true
  try {
    await api.admin.updateClientParent(selectedClientForParent.value.id, parentId)
    toast.success(t('clients.toast_parent_update_success'))
    parentDialogOpen.value = false
    fetchClients()
  } catch (e: any) {
    toast.error(e.message || t('clients.toast_parent_update_error'))
  } finally {
    parentSaving.value = false
  }
}

const openEmailsDialog = (client: any) => {
  selectedClientForEmails.value = client
  emailsDialogOpen.value = true
}

const handleSaveEmails = async (clientId: number, emailsString: string) => {
  emailsSaving.value = true
  try {
    await api.admin.updateClientEmails(clientId, emailsString)
    toast.success('Emails mis à jour avec succès')
    emailsDialogOpen.value = false
    fetchClients()
  } catch (e: any) {
    toast.error(e.message || 'Erreur lors de la mise à jour des emails')
  } finally {
    emailsSaving.value = false
  }
}

const fetchClients = async () => {
  loading.value = true
  try { clients.value = await api.admin.getClients() } 
  catch (e: any) { toast.error(e.message || t('clients.toast_load_error')) } 
  finally { loading.value = false }
}

const handleCreateUser = async (clientId: number) => {
  try {
    await api.admin.createUserFromClient(clientId)
    toast.success(t('clients.toast_create_success'))
    fetchClients()
  } catch (e: any) { toast.error(e.message) }
}

const openLinkDialog = (clientId: number) => {
  selectedClientId.value = clientId
  linkDialogOpen.value = true
}

const handleLinkUser = async (userId: number) => {
  if (!selectedClientId.value) return
  try {
    await api.admin.linkUserToClient(selectedClientId.value, userId)
    toast.success(t('clients.toast_link_success'))
    linkDialogOpen.value = false
    fetchClients()
  } catch (e: any) { toast.error(e.message) }
}

const openUnlinkConfirm = (clientId: number, userId: string) => {
  pendingUnlinkData.value = { clientId, userId }
  unlinkConfirmOpen.value = true
}

const confirmUnlinkUser = async () => {
  if (!pendingUnlinkData.value) return
  unlinking.value = true
  try {
    await api.admin.unlinkUserFromClient(pendingUnlinkData.value.clientId, parseInt(pendingUnlinkData.value.userId))
    toast.success(t('clients.toast_unlink_success'))
    fetchClients()
  } catch (e: any) {
    toast.error(e.message)
  } finally {
    unlinking.value = false
    unlinkConfirmOpen.value = false
    pendingUnlinkData.value = null
  }
}

const activeDropdownId = ref<number | null>(null)

const toggleDropdown = (clientId: number, event: MouseEvent) => {
  event.stopPropagation()
  if (activeDropdownId.value === clientId) {
    activeDropdownId.value = null
  } else {
    activeDropdownId.value = clientId
  }
}

const closeDropdowns = () => {
  activeDropdownId.value = null
}

const toggleClientOption = async (client: any, optionKey: 'recClt' | 'recAdh') => {
  const newRecClt = optionKey === 'recClt' ? (client.recClt === 'O' ? 'N' : 'O') : client.recClt
  const newRecAdh = optionKey === 'recAdh' ? (client.recAdh === 'O' ? 'N' : 'O') : client.recAdh
  
  try {
    await api.admin.updateClientOptions(client.id, newRecClt, newRecAdh)
    toast.success(t('clients.toast_options_update_success'))
    client[optionKey] = client[optionKey] === 'O' ? 'N' : 'O'
  } catch (e: any) {
    toast.error(e.message || t('clients.toast_options_update_error'))
  }
}

onMounted(() => {
  fetchClients()
  window.addEventListener('click', closeDropdowns)
})

onUnmounted(() => {
  window.removeEventListener('click', closeDropdowns)
})
</script>

<template>
  <DataTableWrapper 
    :title="$t('clients.title')" 
    :description="isCommercial ? $t('clients.subtitle_commercial') : $t('clients.subtitle')"
    :items="clients"
    :loading="loading"
    :search-placeholder="$t('clients.search_placeholder')"
  >
    <template #default="{ items }">
      <Table class="border-t border-slate-100 w-full min-w-[1000px]">
        <TableHeader class="bg-slate-50/50">
          <TableRow>
            <TableHead class="table-header-text py-6">{{ $t('clients.table.name') }}</TableHead>
            <TableHead class="table-header-text">{{ $t('clients.table.type') }}</TableHead>
            <TableHead class="table-header-text">{{ $t('clients.table.parent') }}</TableHead>
            <TableHead class="table-header-text">{{ $t('clients.table.linked_users') }}</TableHead>
            <TableHead class="text-right table-header-text">{{ $t('clients.table.actions') }}</TableHead>
          </TableRow>
        </TableHeader>
        <TableBody>
          <TableRow v-for="client in items" :key="client.id" class="group hover:bg-slate-50/50 transition-colors border-b border-slate-50">
            <TableCell class="py-4">
              <div class="flex items-center gap-3">
                <div class="w-9 h-9 rounded-lg bg-slate-100 flex items-center justify-center text-slate-400 group-hover:bg-primary group-hover:text-primary-foreground transition-all shadow-sm">
                  <Building2 class="w-5 h-5" />
                </div>
                <span class="font-bold text-slate-900 tracking-tight">{{ client.raisonSociale }}</span>
              </div>
            </TableCell>
            <TableCell>
              <Badge :variant="client.particulier === 'O' ? 'default' : 'secondary'" class="rounded-lg text-[14px] font-black uppercase tracking-widest px-2 py-1">
                {{ client.particulier === 'O' ? $t('clients.type.individual') : $t('clients.type.company') }}
              </Badge>
            </TableCell>
            <TableCell>
              <div class="flex items-center gap-2">
                <span class="text-sm font-medium text-slate-500">{{ client.parentClient || '-' }}</span>
                <Button 
                  v-if="isAdmin || isCommercial"
                  variant="ghost" 
                  size="sm" 
                  class="h-7 w-7 p-0 rounded-lg text-slate-400 hover:text-slate-600 hover:bg-slate-100" 
                  @click="openParentDialog(client)"
                >
                  <Edit class="w-3.5 h-3.5" />
                </Button>
              </div>
            </TableCell>
            <TableCell>
              <div v-if="client.fkUserId" class="flex flex-wrap gap-2">
                <div v-for="(user, idx) in client.userNom.split(', ')" :key="user" class="group/badge relative flex items-center gap-1 bg-emerald-50 text-emerald-600 border border-emerald-100 text-[14px] font-black uppercase tracking-widest px-2 py-1 rounded-lg">
                   <CheckCircle2 class="w-2.5 h-2.5" /> 
                   {{ user }}
                   <!-- Délier : admin + commercial -->
                   <button v-if="isAdmin || isCommercial" @click="openUnlinkConfirm(client.id, client.fkUserId.split(', ')[idx])" class="ml-1 hover:text-red-600 transition-colors">
                     <X class="w-3 h-3" />
                   </button>
                </div>
              </div>
              <span v-else class="text-slate-300 font-black text-[14px] uppercase tracking-widest italic">( - )</span>
            </TableCell>
            <TableCell class="text-right">
              <div class="flex justify-end gap-1 items-center">
                <!-- Créer utilisateur : admin + commercial -->
                <Button 
                  v-if="!client.fkUserId && (isAdmin || isCommercial)"
                  variant="ghost" size="sm" class="h-9 gap-2 premium-button text-slate-600 hover:bg-primary hover:text-primary-foreground" 
                  @click="handleCreateUser(client.id)"
                >
                  <UserPlus class="w-4 h-4" /> {{ $t('users.add_button') }}
                </Button>

                <!-- Lier utilisateur : admin + commercial -->
                <Button variant="ghost" size="sm" class="h-9 gap-2 premium-button text-emerald-600 hover:bg-emerald-50" @click="openLinkDialog(client.id)">
                  <Link class="w-4 h-4" /> {{ $t('commun.link') }}
                </Button>

                <!-- Gérer les emails chargés de compte -->
                <Button variant="ghost" size="sm" class="h-9 w-9 p-0 premium-button text-blue-600 hover:bg-blue-50" @click="openEmailsDialog(client)">
                  <MailPlus class="w-4 h-4" />
                </Button>
                
                <!-- Options réclamation : admin + commercial -->
                <div class="relative inline-block text-left">
                  <Button variant="ghost" size="sm" class="h-9 w-9 p-0 premium-button text-slate-600 hover:bg-slate-100" @click.stop="toggleDropdown(client.id, $event)">
                    <MessageSquare class="w-4 h-4" />
                  </Button>
                  
                  <div v-if="activeDropdownId === client.id" @click.stop class="absolute right-0 mt-2 w-64 origin-top-right rounded-2xl bg-white border border-slate-100 shadow-2xl p-4 z-50 space-y-3">
                    <div class="text-left font-black text-[10px] uppercase tracking-widest text-slate-400 pb-2 border-b border-slate-100">
                      {{ $t('clients.options_title') }}
                    </div>
                    
                    <div class="flex items-center justify-between gap-3 py-1">
                      <div class="flex flex-col text-left">
                        <span class="text-xs font-bold text-slate-800">{{ $t('clients.support_client') }}</span>
                        <span class="text-[10px] font-medium text-slate-400">{{ $t('clients.support_client_desc') }}</span>
                      </div>
                      <button 
                        @click="toggleClientOption(client, 'recClt')"
                        :class="['w-9 h-5 rounded-full p-0.5 transition-all duration-300 relative outline-none', client.recClt === 'O' ? 'bg-emerald-500' : 'bg-slate-200']"
                      >
                        <span :class="['w-4 h-4 rounded-full bg-white shadow-md block transition-transform duration-300', client.recClt === 'O' ? 'translate-x-4' : 'translate-x-0']"></span>
                      </button>
                    </div>

                    <div class="flex items-center justify-between gap-3 py-1">
                      <div class="flex flex-col text-left">
                        <span class="text-xs font-bold text-slate-800">{{ $t('clients.support_adherent') }}</span>
                        <span class="text-[10px] font-medium text-slate-400">{{ $t('clients.support_adherent_desc') }}</span>
                      </div>
                      <button 
                        @click="toggleClientOption(client, 'recAdh')"
                        :class="['w-9 h-5 rounded-full p-0.5 transition-all duration-300 relative outline-none', client.recAdh === 'O' ? 'bg-emerald-500' : 'bg-slate-200']"
                      >
                        <span :class="['w-4 h-4 rounded-full bg-white shadow-md block transition-transform duration-300', client.recAdh === 'O' ? 'translate-x-4' : 'translate-x-0']"></span>
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </TableCell>
          </TableRow>
        </TableBody>
      </Table>
    </template>
  </DataTableWrapper>

  <UserLinkDialog 
    :open="linkDialogOpen"
    :title="$t('users.link_dialog_title')"
    :description="$t('users.link_dialog_desc_client')"
    @close="linkDialogOpen = false"
    @select="handleLinkUser"
  />

  <ConfirmModal
    :open="unlinkConfirmOpen"
    :title="$t('clients.unlink_confirm_title')"
    :description="$t('clients.unlink_confirm_desc')"
    variant="danger"
    :loading="unlinking"
    @close="unlinkConfirmOpen = false"
    @confirm="confirmUnlinkUser"
  />

  <ClientEmailsDialog
    :open="emailsDialogOpen"
    :client-id="selectedClientForEmails?.id || null"
    :client-name="selectedClientForEmails?.raisonSociale || ''"
    :initial-emails="selectedClientForEmails?.emailChargeCompte || ''"
    :loading="emailsSaving"
    @update:open="emailsDialogOpen = $event"
    @save="handleSaveEmails"
  />

  <ClientParentDialog
    :open="parentDialogOpen"
    :client-id="selectedClientForParent?.id || null"
    :client-name="selectedClientForParent?.raisonSociale || ''"
    @close="parentDialogOpen = false"
    @select="handleSaveParent"
  />
</template>
