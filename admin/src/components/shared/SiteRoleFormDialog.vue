<script setup lang="ts">
import { ref, watch, onMounted } from 'vue'
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from '@/components/ui/dialog'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Button } from '@/components/ui/button'
import { AdminService } from '@/services/api/AdminService'

const props = defineProps<{
  open: boolean
  role: any
  processing?: boolean
}>()

const emit = defineEmits(['close', 'save'])

const activeRole = ref<any>({})
const sites = ref<any[]>([])

onMounted(async () => {
  try {
    sites.value = await AdminService.getAllSites()
  } catch (e) {
    console.error('Failed to load sites for role form', e)
  }
})

watch(() => props.open, (newVal) => {
  if (newVal && props.role) {
    activeRole.value = { ...props.role }
  } else {
    activeRole.value = { Id: null, Name: '', Description: '', SiteId: null }
  }
})

const save = () => {
  emit('save', activeRole.value)
}
</script>

<template>
  <Dialog :open="open" @update:open="emit('close')">
    <DialogContent class="sm:max-w-[425px]">
      <DialogHeader>
        <DialogTitle>{{ activeRole.Id ? $t('roles.edit_role') : $t('roles.add_button') }}</DialogTitle>
      </DialogHeader>
      
      <div class="grid gap-4 py-4">
        <div class="grid gap-2">
          <Label for="name">{{ $t('roles.form.name') }} <span class="text-red-500">*</span></Label>
          <Input id="name" v-model="activeRole.Name" :placeholder="$t('roles.form.name_placeholder')" />
        </div>
        <div class="grid gap-2">
          <Label for="description">{{ $t('roles.form.description') }}</Label>
          <Input id="description" v-model="activeRole.Description" :placeholder="$t('roles.form.description_placeholder')" />
        </div>
        <div class="grid gap-2 mt-2">
          <Label for="site">{{ $t('roles.form.site') }}</Label>
          <select id="site" v-model="activeRole.SiteId" class="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50">
            <option :value="null">{{ $t('roles.form.global_role') }}</option>
            <option v-for="site in sites" :key="site.Id" :value="site.Id">
              {{ site.RaisonSociale }}
            </option>
          </select>
        </div>
      </div>

      <DialogFooter>
        <Button variant="outline" @click="emit('close')" :disabled="processing">{{ $t('roles.form.cancel') }}</Button>
        <Button @click="save" :disabled="processing || !activeRole.Name">
          {{ processing ? '...' : $t('roles.form.save') }}
        </Button>
      </DialogFooter>
    </DialogContent>
  </Dialog>
</template>
