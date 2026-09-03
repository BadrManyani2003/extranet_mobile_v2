<script setup lang="ts">
import { ref, watch } from 'vue'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Check } from 'lucide-vue-next'
import { AdminService } from '@/services/api/AdminService'
import { request } from '@/services/api/BaseClient'
import { toast } from '@/components/ui/sonner'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const props = defineProps<{
  open: boolean
  user: any
}>()

const emit = defineEmits(['close', 'saved'])

const processing = ref(false)
const selectedSites = ref<number[]>([])
const allSites = ref<any[]>([])

const fetchAllSites = async () => {
  try {
    const res = await request<any>('/sites/all', { method: 'GET' })
    allSites.value = res || []
  } catch (e: any) {
    console.error(t('users.sites.toast_load_sites_error'), e)
  }
}

watch(() => props.open, async (isOpen) => {
  if (isOpen && props.user) {
    selectedSites.value = []
    if (allSites.value.length === 0) {
      await fetchAllSites()
    }
    
    try {
      const sites = await AdminService.getUserSitesAdmin(props.user.id)
      selectedSites.value = sites.map((s: any) => s.Id || s.id)
    } catch (e: any) {
      toast.error(t('users.sites.toast_load_user_sites_error'))
    }
  }
})

const toggleSite = (siteId: number) => {
  if (selectedSites.value.includes(siteId)) {
    selectedSites.value = selectedSites.value.filter(id => id !== siteId)
  } else {
    selectedSites.value.push(siteId)
  }
}

const handleSaveSites = async () => {
  if (!props.user) return
  processing.value = true
  try {
    await AdminService.updateUserSites(props.user.id, selectedSites.value)
    toast.success(t('users.sites.toast_update_success'))
    emit('saved')
    emit('close')
  } catch (e: any) {
    toast.error(e.message || t('users.sites.toast_update_error'))
  } finally {
    processing.value = false
  }
}
</script>

<template>
  <Dialog :open="open" @update:open="emit('close')">
    <DialogContent class="w-[92%] sm:max-w-[480px] !flex !flex-col !gap-0 !p-0 rounded-[2rem] shadow-2xl overflow-hidden border-none font-['Outfit'] bg-white">
      <DialogHeader class="p-8 bg-emerald-600 text-white">
        <DialogTitle class="text-xl font-black tracking-tight text-white">{{ $t('users.sites.title') }}</DialogTitle>
        <DialogDescription class="text-emerald-100 text-xs">{{ $t('users.sites.desc', { name: user?.nom }) }}</DialogDescription>
      </DialogHeader>

      <div class="p-8 max-h-[360px] overflow-y-auto">
        <div class="grid gap-2">
          <button v-for="site in allSites" :key="site.Id"
            @click="toggleSite(site.Id)"
            class="flex items-center justify-between p-4 rounded-xl border transition-all text-left"
            :class="selectedSites.includes(site.Id) ? 'bg-emerald-600 border-emerald-600 text-white shadow-md' : 'bg-slate-50 border-slate-100 text-slate-600 hover:bg-slate-100'">
            <span class="text-xs font-black uppercase tracking-widest">{{ site.RaisonSociale }}</span>
            <Check v-if="selectedSites.includes(site.Id)" class="w-4 h-4 text-white" />
          </button>
          
          <div v-if="allSites.length === 0" class="text-center text-sm text-slate-500 py-4">
            {{ $t('users.sites.no_sites') }}
          </div>
        </div>
      </div>

      <DialogFooter class="p-8 bg-slate-50/50 border-t border-slate-100">
        <div class="flex gap-3 w-full">
          <Button variant="outline" class="flex-1 rounded-xl h-11 border-slate-200 text-slate-600" @click="emit('close')" :disabled="processing">
            {{ $t('commun.cancel') }}
          </Button>
          <Button class="flex-1 rounded-xl h-11 premium-button" @click="handleSaveSites" :disabled="processing">
            <span v-if="processing">{{ $t('commun.saving') }}</span>
            <span v-else>{{ $t('commun.save') }}</span>
          </Button>
        </div>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
