<script setup lang="ts">
import { ref, watch } from 'vue'
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from '@/components/ui/dialog'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Plus, Trash2 } from 'lucide-vue-next'

const props = defineProps<{
  open: boolean
  clientId: number | null
  clientName: string
  initialEmails: string
  loading?: boolean
}>()

const emit = defineEmits<{
  (e: 'update:open', value: boolean): void
  (e: 'save', clientId: number, emailsString: string): void
}>()

const emailList = ref<string[]>([])
const newEmail = ref('')

watch(() => props.open, (isOpen) => {
  if (isOpen) {
    if (props.initialEmails) {
      emailList.value = props.initialEmails.split(/[,/]/).map(e => e.trim()).filter(e => e.length > 0)
    } else {
      emailList.value = []
    }
    newEmail.value = ''
  }
})

const addEmail = () => {
  const email = newEmail.value.trim()
  if (email && !emailList.value.includes(email)) {
    emailList.value.push(email)
    newEmail.value = ''
  }
}

const removeEmail = (index: number) => {
  emailList.value.splice(index, 1)
}

const handleSave = () => {
  if (props.clientId) {
    emit('save', props.clientId, emailList.value.join(', '))
  }
}
</script>

<template>
  <Dialog :open="open" @update:open="$emit('update:open', $event)">
    <DialogContent class="sm:max-w-[800px] rounded-3xl p-0 overflow-hidden border-0 shadow-2xl">
      <div class="bg-gradient-to-br from-slate-50 to-white p-6 md:p-8">
        <DialogHeader class="mb-6">
          <DialogTitle class="text-xl font-bold text-slate-800 flex items-center gap-2">
            Emails Chargés de Compte
          </DialogTitle>
          <DialogDescription class="text-sm font-medium text-slate-500">
            {{ clientName }}
          </DialogDescription>
        </DialogHeader>

        <div class="space-y-4">
          <div class="flex gap-2">
            <Input 
              v-model="newEmail" 
              type="email" 
              placeholder="Ex: charge@domaine.com"
              class="flex-1 rounded-xl bg-white border-slate-200 focus-visible:ring-primary"
              @keyup.enter="addEmail"
            />
            <Button @click="addEmail" class="rounded-xl premium-button gap-2 bg-emerald-500 hover:bg-emerald-600 text-white border-0">
              <Plus class="w-4 h-4" /> Ajouter
            </Button>
          </div>

          <div class="max-h-[400px] overflow-y-auto pr-2 space-y-2 mt-4">
            <div v-if="emailList.length === 0" class="text-center py-6 text-slate-400 text-sm font-medium border border-dashed border-slate-200 rounded-xl">
              Aucun email trouvé
            </div>
            <div 
              v-for="(email, idx) in emailList" 
              :key="idx" 
              class="flex items-center justify-between p-3 rounded-xl border border-slate-100 bg-white hover:border-slate-300 hover:shadow-sm transition-all"
            >
              <span class="text-sm font-bold text-slate-700">{{ email }}</span>
              <Button variant="ghost" size="sm" class="text-red-500 hover:text-red-700 hover:bg-red-50 h-8 w-8 p-0 rounded-lg" @click="removeEmail(idx)">
                <Trash2 class="w-4 h-4" />
              </Button>
            </div>
          </div>
        </div>

        <DialogFooter class="mt-8 gap-3 sm:gap-0">
          <Button variant="outline" class="rounded-xl border-slate-200 text-slate-600 font-bold w-full sm:w-auto mr-2" @click="$emit('update:open', false)">
            Annuler
          </Button>
          <Button class="rounded-xl premium-button font-bold w-full sm:w-auto" :disabled="loading" @click="handleSave">
            <span v-if="loading">{{ $t('commun.saving') }}</span>
            <span v-else>{{ $t('commun.save') }}</span>
          </Button>
        </DialogFooter>
      </div>
    </DialogContent>
  </Dialog>
</template>
