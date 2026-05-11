<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const router = useRouter()

const email = ref('')
const password = ref('')
const loading = ref(false)
const error = ref<string | null>(null)
const info = ref<string | null>(null)

async function submit() {
  error.value = null
  info.value = null
  loading.value = true
  try {
    await auth.signUp(email.value, password.value)
    if (auth.isAuthenticated) {
      router.replace('/map')
    } else {
      info.value = 'Check your inbox to confirm your email, then sign in.'
    }
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Sign-up failed'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <div class="flex min-h-full items-center justify-center px-6 py-12">
    <div class="w-full max-w-sm">
      <h1 class="mb-1 text-2xl font-bold">Create your account</h1>
      <p class="mb-6 text-sm text-slate-500">Track fuel, find cheap stations nearby.</p>

      <form class="space-y-4" @submit.prevent="submit">
        <label class="block">
          <span class="text-sm font-medium text-slate-700">Email</span>
          <input
            v-model="email"
            type="email"
            required
            autocomplete="email"
            class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          />
        </label>

        <label class="block">
          <span class="text-sm font-medium text-slate-700">Password</span>
          <input
            v-model="password"
            type="password"
            required
            minlength="6"
            autocomplete="new-password"
            class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          />
        </label>

        <p v-if="error" class="text-sm text-red-600">{{ error }}</p>
        <p v-if="info" class="text-sm text-emerald-600">{{ info }}</p>

        <button
          type="submit"
          :disabled="loading"
          class="w-full rounded-md bg-brand-600 px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-brand-700 disabled:opacity-50"
        >
          {{ loading ? 'Creating…' : 'Create account' }}
        </button>
      </form>

      <p class="mt-6 text-center text-sm text-slate-600">
        Already have an account?
        <RouterLink to="/login" class="font-semibold text-brand-600 hover:underline"
          >Sign in</RouterLink
        >
      </p>
    </div>
  </div>
</template>
