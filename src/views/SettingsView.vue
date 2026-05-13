<script setup lang="ts">
import { useRouter } from 'vue-router'
import { LogOut, Monitor, Moon, Palette, Sun, User } from 'lucide-vue-next'
import { useAuthStore } from '@/stores/auth'
import { useThemeStore, type ThemePreference } from '@/stores/theme'

const auth = useAuthStore()
const theme = useThemeStore()
const router = useRouter()

const themeOptions: { value: ThemePreference; label: string; icon: typeof Sun }[] = [
  { value: 'light', label: 'Light', icon: Sun },
  { value: 'dark', label: 'Dark', icon: Moon },
  { value: 'system', label: 'System', icon: Monitor },
]

async function signOut() {
  await auth.signOut()
  router.replace('/login')
}
</script>

<template>
  <section class="mx-auto max-w-2xl px-4 py-6">
    <header class="mb-6">
      <h1 class="text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">Settings</h1>
    </header>

    <div
      class="rounded-2xl bg-white p-4 shadow-soft ring-1 ring-slate-900/5 dark:bg-slate-900 dark:ring-white/5"
    >
      <div class="flex items-center gap-3">
        <div
          class="grid h-10 w-10 place-items-center rounded-xl bg-brand-50 text-brand-600 dark:bg-brand-900/40 dark:text-brand-300"
        >
          <User :size="18" />
        </div>
        <div class="min-w-0">
          <p class="text-xs font-medium uppercase tracking-wider text-slate-500 dark:text-slate-400">
            Signed in as
          </p>
          <p class="truncate text-sm font-semibold text-slate-900 dark:text-slate-100">
            {{ auth.user?.email ?? '—' }}
          </p>
        </div>
      </div>
    </div>

    <div
      class="mt-4 rounded-2xl bg-white p-4 shadow-soft ring-1 ring-slate-900/5 dark:bg-slate-900 dark:ring-white/5"
    >
      <div class="flex items-center gap-3">
        <div
          class="grid h-10 w-10 place-items-center rounded-xl bg-brand-50 text-brand-600 dark:bg-brand-900/40 dark:text-brand-300"
        >
          <Palette :size="18" />
        </div>
        <div>
          <p class="text-xs font-medium uppercase tracking-wider text-slate-500 dark:text-slate-400">
            Appearance
          </p>
          <p class="text-sm font-semibold text-slate-900 dark:text-slate-100">Theme</p>
        </div>
      </div>

      <div
        class="mt-3 grid grid-cols-3 gap-1 rounded-xl bg-slate-100 p-1 dark:bg-slate-800/60"
      >
        <button
          v-for="opt in themeOptions"
          :key="opt.value"
          type="button"
          class="flex items-center justify-center gap-1.5 rounded-lg px-3 py-2 text-xs font-medium transition-all"
          :class="
            theme.preference === opt.value
              ? 'bg-white text-slate-900 shadow-soft dark:bg-slate-700 dark:text-slate-100'
              : 'text-slate-500 hover:text-slate-900 dark:text-slate-400 dark:hover:text-slate-100'
          "
          @click="theme.set(opt.value)"
        >
          <component :is="opt.icon" :size="14" />
          {{ opt.label }}
        </button>
      </div>
      <p class="mt-2 text-[11px] text-slate-400 dark:text-slate-500">
        <template v-if="theme.preference === 'system'">
          Following your device — currently {{ theme.resolved }}.
        </template>
        <template v-else> Always {{ theme.preference }}. </template>
      </p>
    </div>

    <button
      type="button"
      class="mt-6 inline-flex w-full items-center justify-center gap-2 rounded-xl border border-red-200 bg-white px-4 py-2.5 text-sm font-semibold text-red-600 transition-all hover:bg-red-50 active:scale-[0.99] dark:border-red-900/40 dark:bg-slate-900 dark:text-red-400 dark:hover:bg-red-950/40"
      @click="signOut"
    >
      <LogOut :size="14" />
      Sign out
    </button>
  </section>
</template>
