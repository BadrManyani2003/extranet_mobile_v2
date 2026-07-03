<script setup lang="ts">
import { computed } from 'vue'
import { Car, Shield, HeartPulse, User } from 'lucide-vue-next'
import { useI18n } from 'vue-i18n'

const props = defineProps<{
  top10RisquesData: any[] | null
  moduleType: string
}>()

const iconComponent = computed(() => {
  if (props.moduleType === 'A') return Car
  if (props.moduleType === 'D') return HeartPulse
  return Shield
})

const { t } = useI18n()

const title = computed(() => {
  if (props.moduleType === 'A') return t('tableau_bord.top_10.vehicles')
  if (props.moduleType === 'D') return t('tableau_bord.top_10.adherents')
  return t('tableau_bord.top_10.risks')
})

const columnHeader = computed(() => {
  if (props.moduleType === 'A') return t('tableau_bord.top_10.col_vehicle')
  if (props.moduleType === 'D') return t('tableau_bord.top_10.col_adherent')
  return t('tableau_bord.top_10.col_risk')
})
</script>

<template>
  <div v-if="top10RisquesData && top10RisquesData.length > 0" class="pdf-page-break mb-12 space-y-6">
    <div class="pdf-avoid-break space-y-6">
      <div class="flex items-center gap-4">
        <div class="w-1.5 h-8 bg-[#0d3880] rounded-full"></div>
        <h2 class="text-xl md:text-2xl font-black text-slate-800 uppercase tracking-wider">{{ title }}</h2>
      </div>

      <div class="bg-white rounded-[1.5rem] border border-slate-200/60 shadow-sm overflow-hidden">
        <table class="w-full text-left border-collapse">
          <thead>
            <tr class="bg-[#1e293b] text-white">
              <th class="px-6 py-4 font-black uppercase tracking-wider text-xs border-b border-slate-700">{{ columnHeader }}</th>
              <th class="px-6 py-4 font-black uppercase tracking-wider text-xs border-b border-slate-700 text-right">{{ $t('tableau_bord.top_10.col_nb_claims') }}</th>
            </tr>
          </thead>
          <tbody class="divide-y divide-slate-100">
            <tr 
              v-for="(item, index) in top10RisquesData" 
              :key="item.nom"
              class="hover:bg-slate-50 transition-colors duration-150"
            >
              <td class="px-6 py-4">
                <div class="flex items-center gap-3">
                  <div class="w-8 h-8 rounded-lg bg-slate-100 text-slate-500 flex items-center justify-center font-black text-xs shrink-0">
                    #{{ index + 1 }}
                  </div>
                  <div class="flex items-center gap-2">
                    <component :is="iconComponent" class="w-4 h-4 text-slate-400" />
                    <span class="font-extrabold text-slate-800 text-sm">{{ item.nom }}</span>
                  </div>
                </div>
              </td>
              <td class="px-6 py-4 font-black text-slate-900 text-right text-sm">
                {{ item.count }}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>
