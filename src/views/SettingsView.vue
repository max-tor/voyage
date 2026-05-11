<script setup lang="ts">
import { useRouter } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const router = useRouter()

async function signOut() {
  await auth.signOut()
  router.replace('/login')
}
</script>

<template>
  <section class="px-4 py-6">
    <header class="mb-4">
      <h1 class="text-2xl font-bold">Settings</h1>
      <p class="text-sm text-slate-500">Account, units, currency.</p>
    </header>

    <dl class="space-y-3 rounded-lg border border-slate-200 bg-white p-4 text-sm">
      <div class="flex justify-between">
        <dt class="text-slate-500">Signed in as</dt>
        <dd class="font-medium">{{ auth.user?.email ?? '—' }}</dd>
      </div>
    </dl>

    <button
      type="button"
      class="mt-6 w-full rounded-md border border-red-200 bg-white px-4 py-2 text-sm font-semibold text-red-600 hover:bg-red-50"
      @click="signOut"
    >
      Sign out
    </button>
  </section>
</template>
