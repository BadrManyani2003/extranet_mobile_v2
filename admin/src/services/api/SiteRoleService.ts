import { request } from './BaseClient'

export const SiteRoleService = {
  getSiteRoles: (siteId?: number) => {
    let url = '/app-roles/roles'
    if (siteId) url += `?siteId=${siteId}`
    return request<any[]>(url, { method: 'GET' })
  },

  createSiteRole: (data: { name: string, description?: string, siteId?: number }) =>
    request<any>('/app-roles/roles', { method: 'POST', body: JSON.stringify(data) }),

  updateSiteRole: (id: number, data: { name: string, description?: string, siteId?: number }) =>
    request<any>(`/app-roles/roles/${id}`, { method: 'PUT', body: JSON.stringify(data) }),

  deleteSiteRole: (id: number) =>
    request<any>(`/app-roles/roles/${id}`, { method: 'DELETE' }),

  getSitePermissions: () =>
    request<any[]>('/app-roles/permissions', { method: 'GET' }),

  getSiteRolePermissions: (roleId: number) =>
    request<any[]>(`/app-roles/roles/${roleId}/permissions`, { method: 'GET' }),

  setSiteRolePermission: (roleId: number, permissionId: number, isActive: boolean) =>
    request<any>(`/app-roles/roles/${roleId}/permissions`, { 
      method: 'POST', 
      body: JSON.stringify({ permissionId, isActive }) 
    }),

  getUserSiteRoles: (userId: number, siteId: number) =>
    request<any[]>(`/app-roles/users/${userId}/sites/${siteId}/roles`, { method: 'GET' }),

  assignUserSiteRole: (userId: number, siteId: number, roleId: number) =>
    request<any>(`/app-roles/users/${userId}/sites/${siteId}/roles`, { method: 'POST', body: JSON.stringify({ roleId }) }),

  removeUserSiteRole: (userId: number, siteId: number, roleId: number) =>
    request<any>(`/app-roles/users/${userId}/sites/${siteId}/roles/${roleId}`, { method: 'DELETE' }),
}
