<script setup lang="ts">
import { ref, computed } from 'vue'
import { Users, Building2, UserCheck, MessageSquare, FolderOpen } from 'lucide-vue-next'
import Sidebar from './Sidebar.vue'
import Header from './Header.vue'
import keycloak from '@/services/keycloak'

const isMenuOpen = ref(false)
const toggleMenu = () => { isMenuOpen.value = !isMenuOpen.value }

const isAdmin = computed(() => keycloak.hasRole('admin_cabinet'))

// Navigation filtrée selon le rôle
const navItems = computed(() => {
  const items: any[] = []

  if (isAdmin.value) {
    // Admin : toutes les sections
    items.push(
      { section: 'navigation.sections.admin' },
      { nom: 'navigation.users',    chemin: '/users',    icone: Users },
      { nom: 'navigation.clients',  chemin: '/clients',  icone: Building2 },
      { nom: 'navigation.adherents',chemin: '/adherents',icone: UserCheck },
      { section: 'navigation.sections.support' },
      { nom: 'navigation.reclamations', chemin: '/reclamations', icone: MessageSquare },
      { section: 'navigation.sections.documents' },
      { nom: 'navigation.documents', chemin: '/documents', icone: FolderOpen },
      { section: 'Paramétrage' },
      { nom: 'Sites', chemin: '/sites', icone: Building2 }
    )
  } else {
    // Commercial : utilisateurs + clients + adhérents + réclamations
    items.push(
      { section: 'navigation.sections.commercial' },
      { nom: 'navigation.users',        chemin: '/users',        icone: Users },
      { nom: 'navigation.clients',      chemin: '/clients',      icone: Building2 },
      { nom: 'navigation.adherents',    chemin: '/adherents',    icone: UserCheck },
      { section: 'navigation.sections.support' },
      { nom: 'navigation.reclamations', chemin: '/reclamations', icone: MessageSquare }
    )
  }

  return items
})
</script>

<template>
  <div class="min-h-screen bg-slate-50 flex font-['Outfit']">
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
  </div>
</template>