import { computed } from 'vue'
import { useUserStore } from '@/store/user'
import { useSiteStore } from '@/store/site'

export function usePermissions() {
  const userStore = useUserStore()
  const siteStore = useSiteStore()

  // permissions is an array of { Code: string, SiteId: number | null }
  const permissions = computed(() => userStore.permissions || [])

  const hasPermission = (code: string, targetSiteId?: number | null) => {
    // Contexte du site actif
    const currentSiteId = targetSiteId !== undefined ? targetSiteId : siteStore.selectedSiteId

    return permissions.value.some((perm: any) => {
      // Doit correspondre au code de permission demandé
      const permCode = perm.Code || perm.code || perm.CODE
      if (permCode !== code) return false

      const permSiteId = perm.SiteId ?? perm.siteId ?? perm.SITEID

      // Si la permission est globale (SiteId est null), elle s'applique à tous les sites
      if (permSiteId === null || permSiteId === undefined) return true

      // Si un site est sélectionné, vérifie la correspondance
      if (currentSiteId !== null && currentSiteId !== undefined) {
        return Number(permSiteId) === Number(currentSiteId)
      }

      // Si aucun site n'est encore sélectionné (ex: écran de sélection multi-site),
      // autoriser si la permission existe sur au moins un site
      return true
    })
  }

  return {
    permissions,
    hasPermission
  }
}
