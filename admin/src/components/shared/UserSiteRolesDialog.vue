<script setup lang="ts">
import { ref, watch } from 'vue'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogFooter,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Check, Loader2 } from 'lucide-vue-next'
import { AdminService } from '@/services/api/AdminService'
import { SiteRoleService } from '@/services/api/SiteRoleService'
import { toast } from '@/components/ui/sonner'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const props = defineProps<{
  open: boolean
  user: any
}>()

const emit = defineEmits(['close', 'saved'])

const processing = ref(false)
const loading = ref(false)
const userSites = ref<any[]>([])
const selectedSiteId = ref<number | null>(null)

const availableRoles = ref<any[]>([])
const assignedRoleIds = ref<number[]>([])

const fetchUserSites = async () => {
  if (!props.user) return
  loading.value = true
  try {
    userSites.value = await AdminService.getUserSitesAdmin(props.user.id)
    if (userSites.value.length > 0) {
      selectedSiteId.value = userSites.value[0].Id || userSites.value[0].id
      await loadRolesForSite()
    } else {
      selectedSiteId.value = null
      availableRoles.value = []
      assignedRoleIds.value = []
    }
  } catch (e: any) {
    console.error(e)
    toast.error(t('users.site_roles.toast_load_sites_error'))
  } finally {
    loading.value = false
  }
}

const loadRolesForSite = async () => {
  if (!props.user || !selectedSiteId.value) return
  loading.value = true
  try {
    const roles = await SiteRoleService.getSiteRoles(selectedSiteId.value)
    availableRoles.value = roles

    const assigned = await SiteRoleService.getUserSiteRoles(props.user.id, selectedSiteId.value)
    assignedRoleIds.value = assigned.map((r: any) => r.Id || r.id)
  } catch (e: any) {
    console.error(e)
    toast.error(t('users.site_roles.toast_load_roles_error'))
  } finally {
    loading.value = false
  }
}

watch(() => props.open, (isOpen) => {
  if (isOpen) {
    fetchUserSites()
  } else {
    userSites.value = []
    availableRoles.value = []
    assignedRoleIds.value = []
    selectedSiteId.value = null
  }
})

watch(selectedSiteId, (newId) => {
  if (newId) {
    loadRolesForSite()
  }
})

const toggleRole = (roleId: number) => {
  const index = assignedRoleIds.value.indexOf(roleId)
  if (index >= 0) {
    assignedRoleIds.value.splice(index, 1)
  } else {
    assignedRoleIds.value.push(roleId)
  }
}

const save = async () => {
  if (!props.user || !selectedSiteId.value) return
  
  processing.value = true
  try {
    const current = await SiteRoleService.getUserSiteRoles(props.user.id, selectedSiteId.value)
    const currentIds = current.map((r: any) => r.Id || r.id)
    
    const toAdd = assignedRoleIds.value.filter(id => !currentIds.includes(id))
    const toRemove = currentIds.filter(id => !assignedRoleIds.value.includes(id))
    
    for (const id of toRemove) {
      await SiteRoleService.removeUserSiteRole(props.user.id, selectedSiteId.value, id)
    }
    for (const id of toAdd) {
      await SiteRoleService.assignUserSiteRole(props.user.id, selectedSiteId.value, id)
    }
    
    toast.success(t('users.site_roles.toast_permissions_updated'))
  } catch (e: any) {
    console.error(e)
    toast.error(t('users.site_roles.toast_save_error'))
  } finally {
    processing.value = false
  }
}
</script>

<template>
  <Dialog :open="open" @update:open="$emit('close')">
    <DialogContent class="sm:max-w-[500px]">
      <DialogHeader>
        <DialogTitle>{{ $t('users.site_roles.manage_permissions') }}</DialogTitle>
      </DialogHeader>


      <div class="py-4 space-y-6">
        <div v-if="loading && userSites.length === 0" class="flex justify-center p-8">
          <Loader2 class="w-8 h-8 animate-spin text-primary" />
        </div>
        
        <template v-else-if="userSites.length > 0">
          <!-- Sélection du site -->
          <div class="space-y-2">
            <label class="text-sm font-bold text-slate-700">{{ $t('users.site_roles.select_site') }}</label>
            <select v-model="selectedSiteId" class="w-full bg-white border border-slate-200 rounded-xl px-4 py-2.5 text-sm font-medium focus:ring-4 focus:ring-primary/5 focus:border-primary outline-none transition-all">
              <option v-for="site in userSites" :key="site.Id || site.id" :value="site.Id || site.id">
                {{ site.RaisonSociale }}
              </option>
            </select>
          </div>

          <!-- Liste des rôles applicatifs -->
          <div class="space-y-2">
            <label class="text-sm font-bold text-slate-700">{{ $t('users.site_roles.roles') }}</label>
            <div v-if="loading" class="flex justify-center p-8">
              <Loader2 class="w-6 h-6 animate-spin text-slate-300" />
            </div>
            <div v-else-if="availableRoles.length === 0" class="text-center p-6 bg-slate-50 rounded-xl">
              <p class="text-sm text-slate-500">{{ $t('users.site_roles.no_roles_site') }}</p>
            </div>
            <div v-else class="grid gap-2 max-h-[300px] overflow-y-auto pr-2 custom-scrollbar">
              <div 
                v-for="role in availableRoles" 
                :key="role.Id || role.id"
                class="flex items-center justify-between p-3 rounded-xl border transition-all cursor-pointer"
                :class="assignedRoleIds.includes(role.Id || role.id) ? 'bg-primary/5 border-primary/20 shadow-sm' : 'bg-white border-slate-100 hover:border-slate-300 hover:shadow-sm'"
                @click="toggleRole(role.Id || role.id)"
              >
                <div>
                  <div class="font-bold text-sm text-slate-900">{{ role.Name }}</div>
                  <div class="text-xs text-slate-500 mt-0.5 line-clamp-1">{{ role.Description }}</div>
                </div>
                <div class="w-5 h-5 rounded border flex items-center justify-center transition-colors"
                     :class="assignedRoleIds.includes(role.Id || role.id) ? 'bg-primary border-primary text-white' : 'border-slate-300 text-transparent'">
                  <Check class="w-3.5 h-3.5" />
                </div>
              </div>
            </div>
          </div>
        </template>
        
        <div v-else class="text-center p-8 bg-slate-50 rounded-2xl border border-slate-100">
          <p class="text-slate-500 font-medium">{{ $t('users.site_roles.no_site_attached') }}</p>
          <p class="text-sm text-slate-400 mt-1">{{ $t('users.site_roles.please_attach_site') }}</p>
        </div>
      </div>

      <DialogFooter>
        <Button variant="outline" class="rounded-xl px-6" @click="$emit('close')">
          {{ $t('commun.close') }}
        </Button>
        <Button v-if="userSites.length > 0" class="rounded-xl px-6 premium-button" :disabled="processing || loading" @click="save">
          <Loader2 v-if="processing" class="w-4 h-4 mr-2 animate-spin" />
          {{ $t('users.site_roles.save_for_site') }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
