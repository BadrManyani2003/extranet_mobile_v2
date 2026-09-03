import { createRouter, createWebHistory } from 'vue-router'
import keycloak from '../services/keycloak'
import { useUserStore } from '../store/user'
import { useSiteStore } from '../store/site'
import { usePermissions } from '../composables/usePermissions'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/restricted',
      name: 'restricted',
      component: () => import('../views/RestrictedView.vue')
    },
    {
      path: '/',
      component: () => import('../layouts/MainLayout.vue'),
      children: [
        { path: '', name: 'home', component: { render: () => null } },
        // Application des permissions aux routes
        { path: 'users', name: 'users', component: () => import('../views/UsersView.vue'), meta: { permission: 'utilisateurs:lire' } },
        { path: 'adherents', name: 'adherents', component: () => import('../views/AdherentsView.vue'), meta: { permission: 'adherents:lire' } },
        { path: 'documents', name: 'documents', component: () => import('../views/DocumentsView.vue'), meta: { permission: 'documents:lire' } },
        { path: 'clients', name: 'clients', component: () => import('../views/ClientsView.vue'), meta: { permission: 'clients:lire' } },
        { path: 'reclamations', name: 'reclamations', component: () => import('../views/ReclamationsView.vue'), meta: { permission: 'reclamations:lire' } },
        { path: 'sites', name: 'sites', component: () => import('../views/SitesView.vue'), meta: { permission: 'sites:lire' } },
        { path: 'roles', name: 'roles', component: () => import('../views/SiteRolesView.vue'), meta: { permission: 'roles:lire' } },
      ]
    }
  ]
})

router.beforeEach(async (to) => {
  // 1. Vérification de base (Authentification Keycloak)
  const isAdmin = keycloak.hasRole('admin_cabinet')
  const isCommercial = keycloak.hasRole('commercial_cabinet')
  const hasAdminRole = isAdmin || isCommercial

  if (!hasAdminRole) {
    if (to.name !== 'restricted') return { name: 'restricted' }
    return true
  }

  // 2. Chargement asynchrone des informations utilisateur et des sites
  const userStore = useUserStore()
  const siteStore = useSiteStore()
  try {
    if (!userStore.user) {
      await userStore.fetchUser()
    }
    if (siteStore.availableSites.length === 0) {
      await siteStore.fetchSites()
    }
  } catch (error) {
    console.error('Failed to fetch user or sites in Admin Guard:', error)
  }

  const { hasPermission } = usePermissions()

  // Helper pour trouver la première route autorisée pour l'utilisateur
  const getFirstAuthorizedRoute = () => {
    if (hasPermission('utilisateurs:lire')) return 'users'
    if (hasPermission('clients:lire')) return 'clients'
    if (hasPermission('reclamations:lire')) return 'reclamations'
    if (hasPermission('adherents:lire')) return 'adherents'
    if (hasPermission('documents:lire')) return 'documents'
    if (hasPermission('sites:lire')) return 'sites'
    if (hasPermission('roles:lire')) return 'roles'
    return null
  }

  // 3. Si l'utilisateur est sur 'restricted' mais possède des permissions valides, le rediriger
  if (to.name === 'restricted') {
    const firstRoute = getFirstAuthorizedRoute()
    if (firstRoute) {
      return { name: firstRoute }
    }
    return true
  }

  // 4. Redirection automatique depuis la racine ('/' ou 'home') vers la 1ère page autorisée
  if (to.name === 'home' || to.path === '/') {
    const firstRoute = getFirstAuthorizedRoute()
    return firstRoute ? { name: firstRoute } : { name: 'restricted' }
  }

  // 5. Vérification des permissions spécifiques de la route demandée
  if (to.meta?.permission) {
    if (!hasPermission(to.meta.permission as string)) {
      const firstRoute = getFirstAuthorizedRoute()
      return firstRoute ? { name: firstRoute } : { name: 'restricted' }
    }
  }

  if (siteStore.needsSiteSelection && to.name !== 'select-site') {
    // Rediriger vers la modale/page de sélection si un seul site n'est pas sélectionné
  }

  return true
})

export default router