<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { Menu, X, User, Languages, LogOut, KeyRound, ChevronDown } from 'lucide-vue-next'
import { Button } from '@/components/ui/button'
import { useI18n } from 'vue-i18n'
import keycloak from '@/services/keycloak'
import { useUserStore } from '@/store/user'
import { useSiteStore } from '@/store/site'
import ChangePasswordModal from '@/components/ChangePasswordModal.vue'

const { locale } = useI18n()
const userStore = useUserStore()
const siteStore = useSiteStore()
const isDropdownOpen = ref(false)
const dropdownRef = ref<HTMLElement | null>(null)

const showPasswordModal = ref(false)

defineProps<{
  isSidebarOpen: boolean
}>()

const emit = defineEmits(['toggle'])

const toggleLanguage = () => {
  locale.value = locale.value === 'fr' ? 'en' : 'fr'
}

const handleLogout = () => {
  userStore.clearUser()
  keycloak.logout()
}

const handleChangePassword = () => {
  isDropdownOpen.value = false
  showPasswordModal.value = true
}

const handleSiteChange = (event: Event) => {
  const target = event.target as HTMLSelectElement
  if (target) {
    siteStore.setSelectedSite(Number(target.value))
  }
}

const closeDropdown = (e: MouseEvent) => {
  if (dropdownRef.value && !dropdownRef.value.contains(e.target as Node)) {
    isDropdownOpen.value = false
  }
}

onMounted(() => {
  document.addEventListener('click', closeDropdown)
})

onUnmounted(() => {
  document.removeEventListener('click', closeDropdown)
})
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
      <!-- <button 
        @click="toggleLanguage"
        class="flex items-center gap-2 px-3 py-2 bg-slate-50 hover:bg-slate-100 rounded-xl border border-slate-100 transition-all group"
      >
        <Languages class="w-4 h-4 text-slate-400 group-hover:text-slate-900 transition-colors" />
        <span class="text-sm font-black uppercase tracking-widest text-slate-600">{{ locale }}</span>
      </button> -->

      <!-- Selecteur de Site -->
      <div v-if="siteStore.hasMultipleSites" class="hidden sm:flex items-center">
        <select 
          :value="siteStore.selectedSiteId" 
          @change="handleSiteChange"
          class="bg-white/50 border border-slate-200 text-slate-700 text-sm rounded-xl focus:ring-primary focus:border-primary block w-full px-3 py-2 font-medium shadow-sm hover:border-slate-300 transition-colors cursor-pointer outline-none"
        >
          <option v-for="site in siteStore.sites" :key="site.Id" :value="site.Id">
            {{ site.RaisonSociale }}
          </option>
        </select>
      </div>

      <div class="flex items-center gap-3 relative" ref="dropdownRef">
        <button 
          @click="isDropdownOpen = !isDropdownOpen"
          class="flex items-center gap-2 sm:gap-3 bg-background/50 px-3 sm:px-4 py-2 rounded-xl border border-slate-100 shadow-sm hover:bg-slate-50 transition-colors"
        >
          <span class="hidden sm:inline text-base font-bold text-slate-700">{{ userStore.userName }}</span>
          <div class="w-8 h-8 sm:w-10 sm:h-10 rounded-full bg-primary text-primary-foreground flex items-center justify-center shadow-md shadow-primary/20">
            <User class="w-4 h-4" />
          </div>
          <ChevronDown class="w-4 h-4 text-slate-400" />
        </button>
        
        <!-- Dropdown Menu -->
        <transition
          enter-active-class="transition ease-out duration-200"
          enter-from-class="opacity-0 translate-y-1"
          enter-to-class="opacity-100 translate-y-0"
          leave-active-class="transition ease-in duration-150"
          leave-from-class="opacity-100 translate-y-0"
          leave-to-class="opacity-0 translate-y-1"
        >
          <div 
            v-if="isDropdownOpen"
            class="absolute top-full mt-2 right-0 w-64 bg-white rounded-xl shadow-lg border border-slate-200 py-2 z-50"
          >
            <div class="px-4 py-2 mb-2 border-b border-slate-100">
              <p class="text-sm font-medium text-slate-900 truncate">{{ userStore.userName }}</p>
              <p class="text-xs text-slate-500 truncate" v-if="userStore.user?.email">{{ userStore.user.email }}</p>
            </div>

            <button 
              @click="handleChangePassword"
              class="w-full px-4 py-2.5 text-left flex items-center gap-3 hover:bg-slate-50 text-slate-700 transition-colors"
            >
              <KeyRound class="w-4 h-4 text-slate-400" />
              <span class="text-sm font-medium">{{ $t('commun.change_password') || 'Changer le mot de passe' }}</span>
            </button>
            
            <div class="h-px bg-slate-100 my-1"></div>
            
            <button 
              @click="handleLogout"
              class="w-full px-4 py-2.5 text-left flex items-center gap-3 hover:bg-red-50 text-red-600 transition-colors group"
            >
              <LogOut class="w-4 h-4 text-red-400 group-hover:text-red-500 transition-colors" />
              <span class="text-sm font-medium">{{ $t('commun.logout') || 'Se déconnecter' }}</span>
            </button>
          </div>
        </transition>
      </div>
    </div>

    <!-- Password Modal -->
    <ChangePasswordModal 
      :isOpen="showPasswordModal" 
      @update:isOpen="showPasswordModal = $event" 
    />

  </header>
</template>