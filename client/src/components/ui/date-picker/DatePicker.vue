<script setup lang="ts">
import { computed, ref, watch } from 'vue'
import { VueDatePicker } from '@vuepic/vue-datepicker'
import '@vuepic/vue-datepicker/dist/main.css'
import { fr } from 'date-fns/locale'
import { CalendarDays } from 'lucide-vue-next'

const model = defineModel<string | null>()

const props = defineProps({
  label: {
    type: String,
    default: ''
  },
  placeholder: {
    type: String,
    default: 'jj/mm/aaaa'
  },
  expertType: {
    type: String,
    default: 'default', // 'from' | 'to' | 'default'
    validator: (v: string) => ['from', 'to', 'default'].includes(v)
  }
})

// Custom computed value to guarantee ONLY the date is displayed in French format (no time)
const displayValue = computed(() => {
  if (!model.value) return ''
  
  const str = String(model.value)
  
  // Format yyyy-MM-dd directly
  if (str.match(/^\d{4}-\d{2}-\d{2}$/)) {
    const [yyyy, mm, dd] = str.split('-')
    return `${dd}/${mm}/${yyyy}`
  }
  
  // Fallback for Date objects or ISO strings
  const d = new Date(str)
  if (!isNaN(d.getTime())) {
    const dd = String(d.getDate()).padStart(2, '0')
    const mm = String(d.getMonth() + 1).padStart(2, '0')
    const yyyy = d.getFullYear()
    return `${dd}/${mm}/${yyyy}`
  }
  
  return str
})

// Generate expert preset dates based on the picker's purpose (from / to / default)
const computedPresets = computed(() => {
  const today = new Date()
  const currentYear = today.getFullYear()
  
  if (props.expertType === 'from') {
    return [
      {
        label: "Début de l'année",
        value: new Date(currentYear, 0, 1)
      },
      {
        label: "Début année dernière",
        value: new Date(currentYear - 1, 0, 1)
      },
      {
        label: "Il y a 30 jours",
        value: (() => {
          const d = new Date()
          d.setDate(d.getDate() - 30)
          return d
        })()
      },
      {
        label: "Il y a 3 mois",
        value: (() => {
          const d = new Date()
          d.setMonth(d.getMonth() - 3)
          return d
        })()
      },
      {
        label: "Il y a 6 mois",
        value: (() => {
          const d = new Date()
          d.setMonth(d.getMonth() - 6)
          return d
        })()
      },
      {
        label: "Il y a 1 an",
        value: (() => {
          const d = new Date()
          d.setFullYear(d.getFullYear() - 1)
          return d
        })()
      },
      {
        label: "Il y a 5 ans",
        value: (() => {
          const d = new Date()
          d.setFullYear(d.getFullYear() - 5)
          return d
        })()
      }
    ]
  } else if (props.expertType === 'to') {
    return [
      {
        label: "Aujourd'hui",
        value: today
      },
      {
        label: "Hier",
        value: (() => {
          const d = new Date()
          d.setDate(d.getDate() - 1)
          return d
        })()
      },
      {
        label: "Fin de ce mois",
        value: new Date(currentYear, today.getMonth() + 1, 0)
      },
      {
        label: "Fin de l'année",
        value: new Date(currentYear, 11, 31)
      },
      {
        label: "Fin année dernière",
        value: new Date(currentYear - 1, 11, 31)
      }
    ]
  } else {
    // Default presets
    return [
      {
        label: "Aujourd'hui",
        value: today
      },
      {
        label: "Hier",
        value: (() => {
          const d = new Date()
          d.setDate(d.getDate() - 1)
          return d
        })()
      },
      {
        label: "Début de ce mois",
        value: new Date(currentYear, today.getMonth(), 1)
      },
      {
        label: "Début de l'année",
        value: new Date(currentYear, 0, 1)
      }
    ]
  }
})

// Input masking logic for keyboard entry format jj/mm/aaaa
const handleInput = (event: Event, onInput: (v: string) => void) => {
  const inputEl = event.target as HTMLInputElement
  const rawVal = inputEl.value
  
  // Strip non-digits
  let digits = rawVal.replace(/\D/g, '')
  if (digits.length > 8) {
    digits = digits.slice(0, 8)
  }
  
  let formatted = ''
  if (digits.length > 0) {
    formatted += digits.slice(0, 2)
  }
  if (digits.length > 2) {
    formatted += '/' + digits.slice(2, 4)
  }
  if (digits.length > 4) {
    formatted += '/' + digits.slice(4, 8)
  }
  
  // Set the element value directly to prevent cursor jumping and match formatting
  inputEl.value = formatted
  
  // Propagate format to datepicker handler
  onInput(formatted)
}
</script>

<template>
  <div class="extranet-datepicker-wrapper relative flex-1 sm:flex-initial min-w-[160px]">
    <VueDatePicker 
      v-model="model" 
      format="dd/MM/yyyy"
      model-type="yyyy-MM-dd"
      :enable-time-picker="false"
      text-input
      :text-input-options="{
        format: 'dd/MM/yyyy',
        enterSubmit: true,
        tabSubmit: true,
        applyOnBlur: true
      }"
      :locale="fr"
      :placeholder="placeholder"
      class="extranet-datepicker"
      auto-apply
      :clearable="true"
      :preset-dates="computedPresets"
      :teleport="true"
    >
      <!-- Custom input slot to handle layout and manual typing mask -->
      <template #dp-input="{ onInput, onEnter, onTab, onBlur, onFocus }">
        <div class="relative w-full">
          <!-- Label or Calendar Icon inside input -->
          <div v-if="label" class="pl-4 flex items-center pointer-events-none absolute h-full z-10 select-none">
            <span class="text-xs font-black text-slate-400 uppercase tracking-wider">{{ label }}</span>
          </div>
          <div v-else class="pl-4 flex items-center pointer-events-none absolute h-full z-10 select-none">
            <CalendarDays class="w-4.5 h-4.5 text-slate-400" />
          </div>
          
          <input
            :value="displayValue"
            @input="handleInput($event, onInput)"
            @keydown.enter="onEnter"
            @keydown.tab="onTab"
            @blur="onBlur"
            @focus="onFocus"
            class="extranet-datepicker-input"
            :class="label ? 'has-label' : 'has-icon'"
            :placeholder="placeholder"
          />
        </div>
      </template>
      
      <!-- Custom styling or wording for presets inside popup -->
      <template #preset-date="{ preset, label, text, value, select }">
        <button 
          type="button"
          class="extranet-preset-btn" 
          @click="select(value)"
        >
          {{ label }}
        </button>
      </template>
    </VueDatePicker>
  </div>
</template>

<style>
/* Override default vue-datepicker styles to match the design system */
.extranet-datepicker-wrapper {
  --dp-font-family: 'Outfit', sans-serif;
  --dp-border-radius: 1rem;
  --dp-primary-color: hsl(199 89% 48%); /* primary: light blue */
  --dp-primary-text-color: #fff;
  --dp-icon-color: rgb(148 163 184); /* slate-400 */
  --dp-background-color: #ffffff;
}

/* Custom Input Styling */
.extranet-datepicker-input {
  background-color: white;
  border: 1px solid rgb(226 232 240); /* slate-200 */
  border-radius: 1rem; /* rounded-2xl */
  padding-right: 2.5rem;
  padding-top: 0.875rem; /* py-3.5 = 14px */
  padding-bottom: 0.875rem;
  width: 100%;
  font-family: 'Outfit', sans-serif;
  font-size: 0.875rem; /* text-sm */
  font-weight: 700; /* font-bold */
  color: rgb(30 41 59); /* slate-800 */
  box-shadow: 0 1px 2px 0 rgb(0 0 0 / 0.05); /* shadow-sm */
  transition: all 150ms cubic-bezier(0.4, 0, 0.2, 1);
  height: 50px; /* Force consistent height for main filters */
  box-sizing: border-box;
}

.extranet-datepicker-input.has-label {
  padding-left: 3.5rem;
}

.extranet-datepicker-input.has-icon {
  padding-left: 2.75rem;
}

.extranet-datepicker-input:hover {
  border-color: rgb(203 213 225); /* slate-300 */
}

.extranet-datepicker-input:focus {
  outline: none;
  border-color: hsl(199 89% 48%); /* primary */
  box-shadow: 0 0 0 4px rgba(14, 165, 233, 0.15); /* focus ring */
}

.extranet-datepicker-input::placeholder {
  color: rgb(148 163 184); /* slate-400 */
  font-weight: 500;
}

/* Adapt styles for glass-card inputs (Dashboard Filters) */
.glass-card .extranet-datepicker-input {
  background-color: rgb(248 250 252); /* slate-50 */
  border-color: rgba(226, 232, 240, 0.8);
  padding-top: 0.75rem; /* py-3 = 12px */
  padding-bottom: 0.75rem;
  height: 46px; /* Match other inputs in DashboardFilters */
}

/* Clear icon styling */
.extranet-datepicker .dp__clear_icon {
  right: 0.875rem;
}

/* Preset Options Layout */
.extranet-datepicker .dp__menu {
  border: 1px solid rgb(241 245 249);
  box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
  border-radius: 1.25rem;
  overflow: hidden;
  font-family: 'Outfit', sans-serif;
}

/* Sidebar with presets styling */
.extranet-datepicker .dp__sidebar_left {
  border-right: 1px solid rgb(241 245 249);
  padding: 0.75rem;
  display: flex;
  flex-direction: column;
  gap: 0.375rem;
  min-width: 160px;
  background-color: rgb(248 250 252); /* slate-50 */
}

.extranet-preset-btn {
  text-align: left;
  background-color: white;
  border: 1px solid rgb(226 232 240);
  border-radius: 0.5rem;
  padding: 0.5rem 0.75rem;
  font-family: 'Outfit', sans-serif;
  font-size: 0.75rem;
  font-weight: 700;
  color: rgb(71 85 105); /* slate-600 */
  cursor: pointer;
  transition: all 150ms ease;
  width: 100%;
}

.extranet-preset-btn:hover {
  background-color: hsl(199 89% 48%); /* primary */
  color: white;
  border-color: hsl(199 89% 48%);
  transform: translateY(-1px);
}

.extranet-preset-btn:active {
  transform: translateY(0);
}
</style>
