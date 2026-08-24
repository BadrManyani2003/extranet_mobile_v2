import { createRouter, createWebHistory } from 'vue-router'
import MainLayout   from '../layouts/MainLayout.vue'
import UsersView    from '../views/UsersView.vue'
import ClientsView  from '../views/ClientsView.vue'
import AdherentsView from '../views/AdherentsView.vue'
import keycloak     from '../services/keycloak'
import { useUserStore } from '../store/user'
import { useSiteStore } from '../store/site'

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
      component: MainLayout,
      children: [
        // Redirection selon le rôle : admin → /users, commercial → /clients
        { path: '', name: 'home', redirect: () => {
            return keycloak.hasRole('admin_cabinet') ? '/users' : '/clients'
          }
        },
        // Routes admin_cabinet uniquement
        { path: 'users',     name: 'users',     component: UsersView },
        { path: 'adherents', name: 'adherents', component: AdherentsView },
        { path: 'documents', name: 'documents', component: () => import('../views/DocumentsView.vue'), meta: { adminOnly: true } },
        // Routes accessibles aux deux rôles
        { path: 'clients',      name: 'clients',      component: ClientsView },
        { path: 'reclamations', name: 'reclamations', component: () => import('../views/ReclamationsView.vue') },
        { path: 'sites',        name: 'sites',        component: () => import('../views/SitesView.vue'), meta: { adminOnly: true } },
      ]
    }
  ]
})

router.beforeEach(async (to) => {
  if (to.name === 'restricted') return true

  const isAdmin      = keycloak.hasRole('admin_cabinet')
  const isCommercial = keycloak.hasRole('commercial_cabinet')
  const hasAdminRole = isAdmin || isCommercial

  // Pas de rôle admin/commercial → accès refusé
  if (!hasAdminRole) return { name: 'restricted' }

  // Route admin uniquement mais l'utilisateur est commercial → rediriger
  if (to.meta?.adminOnly && !isAdmin) {
    return { name: 'clients' }
  }

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

  if (siteStore.needsSiteSelection && to.name !== 'select-site') {
    // Rediriger vers la modale/page de sélection si un seul site n'est pas sélectionné
    // Pour l'instant, la modale pourrait bloquer l'accès. On peut laisser passer et afficher un modal au niveau de App.vue.
  }

  return true
})

export default router