<script setup lang="ts">
import { ref } from 'vue'
import { CheckCircle2, Eye, EyeOff } from 'lucide-vue-next'
import { request } from '@/services/api/BaseClient'

const props = defineProps<{
  isOpen: boolean
}>()

const emit = defineEmits(['update:isOpen'])

const newPassword = ref('')
const confirmPassword = ref('')
const passwordError = ref('')
const passwordSuccess = ref(false)
const isSubmittingPassword = ref(false)

const showNewPassword = ref(false)
const showConfirmPassword = ref(false)

const closeModal = () => {
  emit('update:isOpen', false)
  // Reset fields after a slight delay to allow the animation to finish
  setTimeout(() => {
    newPassword.value = ''
    confirmPassword.value = ''
    passwordError.value = ''
    passwordSuccess.value = false
  }, 200)
}

const submitPasswordChange = async () => {
  if (newPassword.value.length < 8) {
    passwordError.value = 'Le mot de passe doit contenir au moins 8 caractères'
    return
  }
  if (newPassword.value !== confirmPassword.value) {
    passwordError.value = 'Les mots de passe ne correspondent pas'
    return
  }
  
  passwordError.value = ''
  isSubmittingPassword.value = true
  
  try {
    await request('/auth/password', {
      method: 'PUT',
      body: JSON.stringify({ 
        newPassword: newPassword.value 
      })
    })
    passwordSuccess.value = true
    setTimeout(() => {
      closeModal()
    }, 2500)
  } catch (err: any) {
    passwordError.value = err.message || 'Une erreur est survenue'
  } finally {
    isSubmittingPassword.value = false
  }
}
</script>

<template>
  <Teleport to="body">
    <transition
      enter-active-class="transition ease-out duration-200"
      enter-from-class="opacity-0"
      enter-to-class="opacity-100"
      leave-active-class="transition ease-in duration-150"
      leave-from-class="opacity-100"
      leave-to-class="opacity-0"
    >
      <div v-if="isOpen" class="fixed inset-0 z-[100] flex items-center justify-center bg-slate-900/50 backdrop-blur-sm px-4">
        <div class="bg-white p-6 sm:p-8 rounded-2xl w-full max-w-md shadow-2xl border border-slate-200">
          <h3 class="text-xl font-bold text-slate-900 mb-6">Changer le mot de passe</h3>
          
          <div v-if="passwordSuccess" class="flex flex-col items-center justify-center py-6 gap-3">
            <CheckCircle2 class="w-16 h-16 text-green-500" />
            <p class="text-lg font-medium text-slate-800">Mot de passe modifié !</p>
            <p class="text-sm text-slate-500 text-center">Votre mot de passe a été mis à jour avec succès.</p>
          </div>
          
          <div v-else>
            <div class="space-y-4 mb-6">
              <div>
                <label class="block text-sm font-medium text-slate-700 mb-1.5">Nouveau mot de passe</label>
                <div class="relative">
                  <input 
                    :type="showNewPassword ? 'text' : 'password'" 
                    v-model="newPassword" 
                    placeholder="Entrez le nouveau mot de passe" 
                    class="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all pr-12" 
                  />
                  <button type="button" @click="showNewPassword = !showNewPassword" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 focus:outline-none">
                    <Eye v-if="!showNewPassword" class="w-5 h-5" />
                    <EyeOff v-else class="w-5 h-5" />
                  </button>
                </div>
              </div>
              <div>
                <label class="block text-sm font-medium text-slate-700 mb-1.5">Confirmer le mot de passe</label>
                <div class="relative">
                  <input 
                    :type="showConfirmPassword ? 'text' : 'password'" 
                    v-model="confirmPassword" 
                    placeholder="Retapez le nouveau mot de passe" 
                    class="w-full px-4 py-2.5 bg-slate-50 border border-slate-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all pr-12" 
                  />
                  <button type="button" @click="showConfirmPassword = !showConfirmPassword" class="absolute right-3 top-1/2 -translate-y-1/2 text-slate-400 hover:text-slate-600 focus:outline-none">
                    <Eye v-if="!showConfirmPassword" class="w-5 h-5" />
                    <EyeOff v-else class="w-5 h-5" />
                  </button>
                </div>
              </div>
              <p v-if="passwordError" class="text-sm text-red-500 bg-red-50 p-3 rounded-lg">{{ passwordError }}</p>
            </div>
            
            <div class="flex justify-end gap-3 mt-8">
              <button 
                @click="closeModal" 
                class="px-5 py-2.5 text-sm font-medium text-slate-600 hover:bg-slate-100 rounded-xl transition-colors"
              >
                Annuler
              </button>
              <button 
                @click="submitPasswordChange" 
                :disabled="isSubmittingPassword"
                class="px-5 py-2.5 text-sm font-medium bg-primary text-primary-foreground rounded-xl shadow-md hover:bg-primary/90 transition-colors disabled:opacity-70 flex items-center gap-2"
              >
                <span v-if="isSubmittingPassword" class="w-4 h-4 border-2 border-white/30 border-t-white rounded-full animate-spin"></span>
                Enregistrer
              </button>
            </div>
          </div>
        </div>
      </div>
    </transition>
  </Teleport>
</template>
