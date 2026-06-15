import keycloak from '@/services/keycloak'
import { computed } from 'vue'

/**
 * Composable pour vérifier le rôle de l'utilisateur connecté.
 * Source de vérité : Keycloak realm roles.
 */
export function useRole() {
  const isAdmin = computed(() => keycloak.hasRole('admin_cabinet'))
  const isCommercial = computed(() => keycloak.hasRole('commercial_cabinet') && !keycloak.hasRole('admin_cabinet'))

  return { isAdmin, isCommercial }
}
