import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { api } from '../lib/api'
import keycloak from '../services/keycloak'

export const useUserStore = defineStore('user', () => {
  const user = ref<any>(null)
  const loading = ref(false)  
  const error = ref<string | null>(null)

  const isAuthenticated = computed(() => !!user.value)
  const userName = computed(() => {
    if (!user.value) return '...'
    return user.value.nom || user.value.Nom || user.value.name || user.value.username || 'Admin'
  })

  // Rôles basés sur Keycloak
  const isAdmin = computed(() => keycloak.hasRole('admin_cabinet'))
  const isCommercial = computed(() => keycloak.hasRole('commercial_cabinet') && !keycloak.hasRole('admin_cabinet'))

  async function fetchUser() {
    loading.value = true
    error.value = null
    try {
      console.log('--- Appel API  ---')
      const userData = await api.admin.getMe()
      console.log('--- Réponse API getMe() ---', userData)
      user.value = userData
      return userData
    } catch (e: any) {
      console.error('--- Erreur API getMe() ---', e)
      error.value = e.message
      user.value = null
      throw e
    } finally {
      loading.value = false
    }
  }

  function setUser(data: any) {
    user.value = data
  }

  function clearUser() {
    user.value = null
  }

  return {
    user,
    loading,
    error,
    isAuthenticated,
    userName,
    isAdmin,
    isCommercial,
    fetchUser,
    setUser,
    clearUser
  }
})
