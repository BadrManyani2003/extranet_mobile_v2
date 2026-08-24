import { defineStore } from 'pinia';
import { ref, computed } from 'vue';
import { request } from '../services/api/BaseClient';

function setCookie(name: string, value: string, days = 30) {
    const date = new Date();
    date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
    document.cookie = `${name}=${value}; expires=${date.toUTCString()}; path=/; SameSite=Lax`;
}

function getCookie(name: string): string | null {
    const nameEQ = name + "=";
    const ca = document.cookie.split(';');
    for (let i = 0; i < ca.length; i++) {
        let c = ca[i];
        while (c.charAt(0) === ' ') c = c.substring(1, c.length);
        if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
    }
    return null;
}

export interface Site {
    Id: number;
    Code: string;
    RaisonSociale: string;
    Adresse: string;
    Ville: string;
    Actif?: string;
}

export const useSiteStore = defineStore('site', () => {
    const currentSiteId = ref<number | null>(null);
    const availableSites = ref<Site[]>([]);
    const needsSiteSelection = ref(false);

    // Computed aliases for component compatibility
    const sites = computed(() => availableSites.value);
    const selectedSiteId = computed(() => currentSiteId.value);
    const hasMultipleSites = computed(() => availableSites.value.length > 1);

    function setSite(siteId: number) {
        if (currentSiteId.value === siteId) return;
        currentSiteId.value = siteId;
        needsSiteSelection.value = false;
        setCookie('currentSiteId', siteId.toString());
        // Force reload so all components fetch data for the new site
        window.location.reload();
    }

    function setSelectedSite(siteId: number) {
        setSite(siteId);
    }

    function setAvailableSites(siteList: Site[]) {
        availableSites.value = siteList;
        const stored = getCookie('currentSiteId') || localStorage.getItem('currentSiteId');
        
        if (stored && siteList.some(s => s.Id === Number(stored))) {
            currentSiteId.value = Number(stored);
            needsSiteSelection.value = false;
        } else if (siteList.length === 1) {
            currentSiteId.value = siteList[0].Id;
            setCookie('currentSiteId', siteList[0].Id.toString());
            needsSiteSelection.value = false;
        } else if (siteList.length > 1) {
            // Auto-select first if nothing stored
            currentSiteId.value = siteList[0].Id;
            setCookie('currentSiteId', siteList[0].Id.toString());
            needsSiteSelection.value = false;
        } else {
            currentSiteId.value = null;
            document.cookie = "currentSiteId=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;";
            needsSiteSelection.value = false;
        }
    }

    async function fetchSites() {
        try {
            const siteList = await request<Site[]>('/sites');
            setAvailableSites(siteList || []);
        } catch (e) {
            console.error('Failed to fetch sites', e);
            setAvailableSites([]);
        }
    }

    return {
        currentSiteId,
        availableSites,
        sites,
        selectedSiteId,
        hasMultipleSites,
        needsSiteSelection,
        setSite,
        setSelectedSite,
        setAvailableSites,
        fetchSites
    };
});
