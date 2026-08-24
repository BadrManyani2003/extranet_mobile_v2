<script setup lang="ts">
import { computed } from 'vue'

const props = defineProps<{
  modelValue: string
  options: string[]
  loading?: boolean
  loadingText?: string
  defaultText?: string
  icon?: any
  widthClass?: string
}>()

const emit = defineEmits(['update:modelValue'])

const selectedValue = computed({
  get: () => props.modelValue,
  set: (val) => emit('update:modelValue', val)
})
</script>

<template>
  <div v-if="loading || options.length > 1" :class="['relative', widthClass || 'w-full']">
    <component :is="icon" v-if="icon" class="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-slate-400" />
    <select 
      v-model="selectedValue"
      class="h-11 rounded-xl bg-white border-none shadow-sm font-bold text-sm text-slate-800 focus:outline-none appearance-none pr-10 cursor-pointer transition-all duration-200 w-full"
      :class="icon ? 'pl-10' : 'pl-4'"
      :disabled="loading"
    >
      <option v-if="loading" value="" disabled>{{ loadingText || 'Chargement...' }}</option>
      <option v-else value="">{{ defaultText || 'Tous' }}</option>
      <option v-for="option in options" :key="option" :value="option">
        {{ option }}
      </option>
    </select>
    <div class="pointer-events-none absolute inset-y-0 right-4 flex items-center text-slate-400">
      <svg class="h-4 w-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M19 9l-7 7-7-7" />
      </svg>
    </div>
  </div>
</template>
