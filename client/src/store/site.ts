import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { request } from '../services/api/BaseClient';

function setCookie(name: string, value: string, days = 30) {
    const date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    document.cookie = `${name}=${value}; expires=${date.toUTCString()}; path=/; SameSite=Lax`;
}

export interface Site {
    Id: number;
    Code: string;
    RaisonSociale: string;
    Adresse: string;
    Ville: string;
    Actif: string;
}

export const useSiteStore = defineStore('site', () => {
    const sites = ref<Site[]>([]);
    const selectedSiteId = ref<number | null>(null);
    const isLoading = ref(false);

    const selectedSite = computed(() => sites.value.find(s => s.Id === selectedSiteId.value) || null);
    const hasMultipleSites = computed(() => sites.value.length > 1);

    async function fetchSites() {
        isLoading.value = true;
        try {
            const response = await request<any>('/sites', { method: 'GET' });
            if (response) {
                sites.value = Array.isArray(response) ? response : (response.data || []);
                
                // Le client est toujours affecté à un seul site, on force la sélection
                if (sites.value.length > 0) {
                    selectedSiteId.value = sites.value[0].Id;
                    setCookie('currentSiteId', sites.value[0].Id.toString());
                } else {
                    selectedSiteId.value = null;
                    document.cookie = "currentSiteId=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
                }
            }
        } catch (error) {
            console.error("Erreur lors du chargement des sites", error);
        } finally {
            isLoading.value = false;
        }
    }

    function setSelectedSite(siteId: number | null) {
        if (selectedSiteId.value === siteId) return;
        
        selectedSiteId.value = siteId;
        if (siteId) {
            setCookie('currentSiteId', siteId.toString());
        } else {
            document.cookie = "currentSiteId=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
        }
        window.location.reload();
    }

    return {
        sites,
        selectedSiteId,
        isLoading,
        selectedSite,
        hasMultipleSites,
        fetchSites,
        setSelectedSite
    };
});
