<script setup lang="ts">
import { useRouter } from 'vue-router'
import { LogOut, User } from 'lucide-vue-next'
import { useAuthStore } from '@/stores/auth'

const auth = useAuthStore()
const router = useRouter()

async function signOut() {
  await auth.signOut()
  router.replace('/login')
}
</script>

<template>
  <section class="mx-auto max-w-2xl px-4 py-6">
    <header class="mb-6">
      <h1 class="text-2xl font-bold tracking-tight">Settings</h1>
      <p class="mt-0.5 text-sm text-slate-500">Account, units, currency.</p>
    </header>

    <div class="rounded-2xl bg-white p-4 shadow-soft ring-1 ring-slate-900/5">
      <div class="flex items-center gap-3">
        <div class="grid h-10 w-10 place-items-center rounded-xl bg-brand-50 text-brand-600">
          <User :size="18" />
        </div>
        <div class="min-w-0">
          <p class="text-xs font-medium uppercase tracking-wider text-slate-500">Signed in as</p>
          <p class="truncate text-sm font-semibold text-slate-900">{{ auth.user?.email ?? '—' }}</p>
        </div>
      </div>
    </div>

    <button
      type="button"
      class="mt-6 inline-flex w-full items-center justify-center gap-2 rounded-xl border border-red-200 bg-white px-4 py-2.5 text-sm font-semibold text-red-600 transition-all hover:bg-red-50 active:scale-[0.99]"
      @click="signOut"
    >
      <LogOut :size="14" />
      Sign out
    </button>
  </section>
</template>
