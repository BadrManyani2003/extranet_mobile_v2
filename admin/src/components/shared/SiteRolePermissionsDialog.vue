<script setup lang="ts">
import { ref, watch, computed } from 'vue'
import { Dialog, DialogContent, DialogHeader, DialogTitle } from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Search } from 'lucide-vue-next'
import { useI18n } from 'vue-i18n'
import { SiteRoleService } from '@/services/api/SiteRoleService'
import { toast } from '@/components/ui/sonner'

const { t } = useI18n()

const props = defineProps<{
  open: boolean
  role: any
}>()

const emit = defineEmits(['close'])

const permissions = ref<any[]>([])
const loading = ref(false)
const searchQuery = ref('')

watch(() => props.open, async (newVal) => {
  if (newVal && props.role && props.role.Id) {
    loading.value = true
    searchQuery.value = ''
    try {
      permissions.value = (await SiteRoleService.getSiteRolePermissions(props.role.Id)).map((p: any) => ({
        ...p,
        IsActive: p.Actif === 'O'
      }))
    } catch (e: any) {
      toast.error(e.message || t('roles.permissions.toast_load_error'))
    } finally {
      loading.value = false
    }
  } else {
    permissions.value = []
  }
})

const filteredPermissions = computed(() => {
  let result = permissions.value
  
  if (searchQuery.value) {
    const q = searchQuery.value.toLowerCase()
    result = result.filter(p => p.Code.toLowerCase().includes(q) || p.Description.toLowerCase().includes(q))
  }
  
  return result.sort((a, b) => a.Code.localeCompare(b.Code))
})

const togglePermission = async (permission: any) => {
  const newStatus = !permission.IsActive
  try {
    await SiteRoleService.setSiteRolePermission(props.role.Id, permission.Id, newStatus)
    permission.IsActive = newStatus
    toast.success(t('roles.toast_perm_success'))
  } catch (e: any) {
    toast.error(e.message || t('roles.permissions.toast_update_error'))
  }
}
</script>

<template>
  <Dialog :open="open" @update:open="emit('close')">
    <DialogContent class="sm:max-w-[600px] max-h-[85vh] flex flex-col overflow-hidden">
      <DialogHeader>
        <DialogTitle>{{ $t('roles.permissions.title', { name: role?.Name }) }}</DialogTitle>
      </DialogHeader>
      
      <div class="px-1 pt-2 pb-2">
        <div class="relative">
          <Search class="absolute left-2.5 top-2.5 h-4 w-4 text-slate-500" />
          <Input 
            v-model="searchQuery" 
            :placeholder="$t('roles.permissions.search_placeholder')" 
            class="pl-9"
          />
        </div>
      </div>
      
      <div class="flex-1 overflow-y-auto py-2 pr-2">
        <div v-if="loading" class="text-center text-slate-500 py-4">{{ $t('reclamations.loading') }}</div>
        <div v-else-if="permissions.length === 0" class="text-center text-slate-500 py-4">{{ $t('roles.permissions.no_permissions') }}</div>
        <div v-else-if="filteredPermissions.length === 0" class="text-center text-slate-500 py-4">{{ $t('roles.permissions.no_results') }}</div>
        <div v-else class="space-y-3">
          <div v-for="perm in filteredPermissions" :key="perm.Id" class="flex items-center justify-between p-3 border rounded-lg bg-slate-50/50">
            <div>
              <p class="font-medium text-slate-900">{{ perm.Code }}</p>
              <p class="text-sm text-slate-500">{{ perm.Description }}</p>
            </div>
            <label class="relative inline-flex items-center cursor-pointer">
              <input type="checkbox" :checked="perm.IsActive" @change="togglePermission(perm)" class="sr-only peer">
              <div class="w-11 h-6 bg-slate-200 peer-focus:outline-none rounded-full peer peer-checked:after:translate-x-full peer-checked:after:border-white after:content-[''] after:absolute after:top-[2px] after:left-[2px] after:bg-white after:border-slate-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-emerald-500"></div>
            </label>
          </div>
        </div>
      </div>

    </DialogContent>
  </Dialog>
</template>
