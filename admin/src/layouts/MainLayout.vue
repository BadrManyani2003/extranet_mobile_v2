<script setup lang="ts">
import { ref, computed } from 'vue'
import { Users, Building2, Contact, LifeBuoy, FolderOpen, Network, ShieldCheck } from 'lucide-vue-next'
import Sidebar from './Sidebar.vue'
import Header from './Header.vue'
import SiteSelectionModal from '@/components/shared/SiteSelectionModal.vue'

import { usePermissions } from '@/composables/usePermissions'

const { hasPermission } = usePermissions()

const isMenuOpen = ref(false)
const toggleMenu = () => { isMenuOpen.value = !isMenuOpen.value }

// isAdmin was removed because it's no longer needed

// Navigation filtrée selon le rôle
const navItems = computed(() => {
  const items: any[] = []

  // Menu principal pour Admin et Commercial, mais on filtre finement selon les permissions
  
  if (hasPermission('utilisateurs:lire') || hasPermission('clients:lire') || hasPermission('adherents:lire')) {
    items.push({ section: 'navigation.sections.admin' })
    if (hasPermission('utilisateurs:lire')) items.push({ nom: 'navigation.users', chemin: '/users', icone: Users })
    if (hasPermission('clients:lire')) items.push({ nom: 'navigation.clients', chemin: '/clients', icone: Building2 })
    if (hasPermission('adherents:lire')) items.push({ nom: 'navigation.adherents', chemin: '/adherents', icone: Contact })
  }

  if (hasPermission('reclamations:lire')) {
    items.push({ section: 'navigation.sections.support' })
    items.push({ nom: 'navigation.reclamations', chemin: '/reclamations', icone: LifeBuoy })
  }

  if (hasPermission('documents:lire')) {
    items.push({ section: 'navigation.sections.documents' })
    items.push({ nom: 'navigation.documents', chemin: '/documents', icone: FolderOpen })
  }

  if (hasPermission('sites:lire') || hasPermission('roles:lire')) {
    items.push({ section: 'navigation.sections.settings' })
    if (hasPermission('sites:lire')) items.push({ nom: 'navigation.sites', chemin: '/sites', icone: Network })
    if (hasPermission('roles:lire')) items.push({ nom: 'navigation.roles', chemin: '/roles', icone: ShieldCheck })
  }

  return items
})
</script>

<template>
  <div class="h-screen bg-slate-50 flex overflow-hidden font-['Outfit']">
    <div 
      v-if="isMenuOpen" 
      class="fixed inset-0 bg-slate-900/40 backdrop-blur-sm z-40 lg:hidden transition-opacity duration-300"
      @click="isMenuOpen = false"
    ></div>

    <Sidebar 
      :isSidebarOpen="isMenuOpen" 
      :navItems="navItems"
      @close="isMenuOpen = false"
      @toggle="toggleMenu"
    />

    <main class="flex-1 flex flex-col min-w-0 h-screen overflow-hidden">
      <Header 
        :isSidebarOpen="isMenuOpen" 
        @toggle="toggleMenu"
      />

      <div class="flex-1 overflow-y-auto bg-slate-50/30">
        <div class="mx-auto py-10 px-6 sm:px-12 w-full">
          <router-view />
        </div>
      </div>
    </main>
    <SiteSelectionModal />
  </div>
</template>
