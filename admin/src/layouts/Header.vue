<script setup lang="ts">
import { Menu, X, User, LogOut } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { useI18n } from 'vue-i18n'
import keycloak from '@/services/keycloak'
import { useUserStore } from '@/store/user'
import { useSiteStore } from '@/store/site'

const { locale } = useI18n()
const userStore = useUserStore()
const siteStore = useSiteStore()

defineProps<{
  isSidebarOpen: boolean
}>()

const emit = defineEmits(['toggle'])

const handleLogout = () => {
  userStore.clearUser()
  keycloak.logout()
}

const handleSiteChange = (event: Event) => {
  const target = event.target as HTMLSelectElement
  if (target) {
    siteStore.setSite(Number(target.value))
  }
}
</script>

<template>
  <header class="h-20 bg-white/80 backdrop-blur-md border-b border-slate-200 flex items-center justify-between px-6 sm:px-10 sticky top-0 z-30 font-['Outfit']">
    <div class="flex items-center gap-4">
      <Button variant="ghost" size="icon" @click="emit('toggle')" class="rounded-xl text-slate-500 bg-slate-50 hover:bg-slate-100">
        <Menu v-if="!isSidebarOpen" class="w-5 h-5" />
        <X v-else class="w-5 h-5" />
      </Button>
      <div class="lg:hidden font-bold text-lg text-slate-900 flex items-center gap-2">
        <span class="tracking-tight">MyAsk</span>
      </div>
    </div>
    
    <div class="flex items-center gap-3 sm:gap-6">
      
      <!-- Selecteur de Site -->
      <div v-if="siteStore.availableSites.length > 1" class="hidden sm:flex items-center">
        <select 
          :value="siteStore.currentSiteId" 
          @change="handleSiteChange"
          class="bg-white border border-slate-200 text-slate-700 text-sm rounded-lg focus:ring-primary focus:border-primary block w-full p-2.5 font-medium shadow-sm hover:border-slate-300 transition-colors cursor-pointer outline-none"
        >
          <option v-for="site in siteStore.availableSites" :key="site.Id" :value="site.Id">
            {{ site.RaisonSociale }}
          </option>
        </select>
      </div>

      <div class="flex items-center gap-3">
        <div class="flex items-center gap-3 bg-slate-50 px-4 py-2 rounded-xl border border-slate-100 shadow-sm">
          <div class="hidden sm:flex flex-col items-end gap-0.5">
            <span class="text-base font-bold text-slate-700 leading-none">{{ userStore.userName }}</span>
            <!-- Badge rôle -->
            <span 
              class="text-[10px] font-black uppercase tracking-widest px-1.5 py-0.5 rounded-md leading-none"
              :class="userStore.isAdmin 
                ? 'bg-primary/10 text-primary' 
                : 'bg-emerald-50 text-emerald-600'"
            >
              {{ userStore.isAdmin ? 'Admin Cabinet' : 'Commercial' }}
            </span>
          </div>
          <div class="w-10 h-10 rounded-full flex items-center justify-center shadow-md transition-colors"
            :class="userStore.isAdmin ? 'bg-primary text-primary-foreground shadow-primary/20' : 'bg-emerald-500 text-white shadow-emerald-200'">
            <User class="w-4 h-4" />
          </div>
        </div>
        
        <button 
          @click="handleLogout"
          class="w-10 h-10 rounded-xl bg-slate-100 text-slate-600 flex items-center justify-center hover:bg-red-50 hover:text-red-600 transition-all border border-slate-200/50 group"
          :title="$t('commun.logout')"
        >
          <LogOut class="w-5 h-5 group-hover:rotate-12 transition-transform" />
        </button>
      </div>
    </div>
  </header>
</template>