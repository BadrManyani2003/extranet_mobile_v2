<script setup lang="ts">
import { LogOut, RotateCcw } from 'lucide-vue-next'
import { useRouter } from 'vue-router'
import keycloak from '@/services/keycloak'

const router = useRouter()

const handleRetry = () => {
  router.push('/')
}

const handleLogout = () => {
  keycloak.logout()
}
</script>

<template>
  <div class="min-h-screen bg-slate-50 flex items-center justify-center p-4 font-['Outfit']">
    <div class="max-w-md w-full bg-white rounded-[2.5rem] shadow-2xl shadow-slate-200/60 overflow-hidden border border-slate-100">
      <div class="p-10 text-center">
        <h1 class="text-3xl font-black text-slate-900 mb-8 tracking-tight">{{ $t('restricted.title') }}</h1>
        
        <div class="grid gap-4">
          <button 
            @click="handleRetry"
            class="flex items-center justify-center gap-3 w-full py-4 px-6 bg-blue-600 hover:bg-blue-700 text-white rounded-2xl font-bold transition-all duration-300 shadow-lg shadow-blue-100 hover:shadow-blue-200 group"
          >
            <RotateCcw class="w-5 h-5 group-hover:rotate-45 transition-transform" />
            Accéder à l'application
          </button>

          <button 
            @click="handleLogout"
            class="flex items-center justify-center gap-3 w-full py-4 px-6 bg-slate-100 hover:bg-red-50 text-slate-700 hover:text-red-600 rounded-2xl font-bold transition-all duration-300 group"
          >
            <LogOut class="w-5 h-5 group-hover:-translate-x-1 transition-transform" />
            {{ $t('restricted.logout') }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
</style>
