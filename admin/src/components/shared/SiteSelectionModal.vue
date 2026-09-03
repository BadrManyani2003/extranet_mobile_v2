<script setup lang="ts">
import { useSiteStore } from '@/store/site'
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from '@/components/ui/dialog'
import { Globe, ArrowRight } from 'lucide-vue-next'

const siteStore = useSiteStore()

const handleSiteSelect = (siteId: number) => {
  siteStore.setSite(siteId)
}
</script>

<template>
  <Dialog :open="siteStore.needsSiteSelection">
    <DialogContent 
      class="sm:max-w-[500px] [&>button]:hidden font-['Outfit']" 
      @interactOutside="(e) => e.preventDefault()"
      @escapeKeyDown="(e) => e.preventDefault()"
    >
      <DialogHeader>
        <DialogTitle class="text-xl font-bold flex items-center gap-2">
          <Globe class="h-6 w-6 text-primary" />
          {{ $t('sites.current_site_title') }}
        </DialogTitle>
        <DialogDescription class="text-base text-slate-500 mt-1">
          {{ $t('sites.choose_site_desc') }}
        </DialogDescription>
      </DialogHeader>

      <div class="grid gap-3 py-4 max-h-[60vh] overflow-y-auto pr-2">
        <button
          v-for="site in siteStore.availableSites"
          :key="site.Id"
          @click="handleSiteSelect(site.Id)"
          class="flex items-center justify-between p-4 border border-slate-200 rounded-xl hover:border-primary hover:bg-primary/5 transition-all group text-left"
        >
          <div>
            <h3 class="font-semibold text-slate-900 group-hover:text-primary transition-colors">
              {{ site.RaisonSociale }}
            </h3>
            <p class="text-sm text-slate-500 mt-1">
              {{ site.Code }} - {{ site.Ville }}
            </p>
          </div>
          <ArrowRight class="h-5 w-5 text-slate-300 group-hover:text-primary transition-colors group-hover:translate-x-1" />
        </button>
      </div>
    </DialogContent>
  </Dialog>
</template>
