<script setup lang="ts">
import { ref, watch } from 'vue'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Button } from '@/components/ui/button'

const props = defineProps<{
  open: boolean
  site: any
  processing?: boolean
}>()

const emit = defineEmits(['close', 'save'])

const activeSite = ref<any>({})

watch(() => props.open, (newVal) => {
  if (newVal && props.site) {
    activeSite.value = { ...props.site }
  } else {
    activeSite.value = { Id: null, Code: '', RaisonSociale: '', Adresse: '', Ville: '', Actif: 'O' }
  }
})

const save = () => {
  emit('save', activeSite.value)
}
</script>

<template>
  <Dialog :open="open" @update:open="emit('close')">
    <DialogContent class="sm:max-w-[425px]">
      <DialogHeader>
        <DialogTitle>{{ activeSite.Id ? 'Modifier le site' : 'Nouveau site' }}</DialogTitle>
      </DialogHeader>
      
      <div class="grid gap-4 py-4">
        <div class="grid gap-2">
          <Label for="code">Code</Label>
          <Input id="code" v-model="activeSite.Code" placeholder="ex: CAS-01" />
        </div>
        <div class="grid gap-2">
          <Label for="raison">Raison Sociale <span class="text-red-500">*</span></Label>
          <Input id="raison" v-model="activeSite.RaisonSociale" placeholder="Nom de l'agence" />
        </div>
        <div class="grid gap-2">
          <Label for="ville">Ville</Label>
          <Input id="ville" v-model="activeSite.Ville" />
        </div>
        <div class="grid gap-2">
          <Label for="adresse">Adresse</Label>
          <Input id="adresse" v-model="activeSite.Adresse" />
        </div>
        <div class="grid gap-2 mt-2">
          <Label>Statut</Label>
          <select v-model="activeSite.Actif" class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50">
            <option value="O">Actif</option>
            <option value="N">Inactif</option>
          </select>
        </div>
      </div>

      <DialogFooter>
        <Button variant="outline" @click="emit('close')" :disabled="processing">Annuler</Button>
        <Button @click="save" :disabled="processing || !activeSite.RaisonSociale">
          {{ processing ? 'Enregistrement...' : 'Enregistrer' }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
