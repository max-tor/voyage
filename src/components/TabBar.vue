<script setup lang="ts">
import { RouterLink, useRoute } from 'vue-router'
import { computed } from 'vue'
import { Car, Fuel, Map, Settings } from 'lucide-vue-next'

const route = useRoute()

const tabs = [
  { name: 'map', label: 'Map', to: '/map', icon: Map },
  { name: 'fillups', label: 'Fill-ups', to: '/fillups', icon: Fuel },
  { name: 'garage', label: 'Garage', to: '/garage', icon: Car },
  { name: 'settings', label: 'Settings', to: '/settings', icon: Settings },
] as const

const active = computed(() => String(route.name ?? ''))
function isActive(name: string) {
  return active.value === name || active.value.startsWith(`${name}-`)
}
</script>

<template>
  <nav
    class="fixed inset-x-0 bottom-0 z-40 border-t border-slate-900/5 bg-white/85 pb-safe backdrop-blur-xl dark:border-white/5 dark:bg-slate-950/80"
    aria-label="Primary"
  >
    <ul class="mx-auto flex max-w-md justify-around px-2 py-2">
      <li v-for="tab in tabs" :key="tab.name" class="flex-1">
        <RouterLink
          :to="tab.to"
          class="group flex flex-col items-center gap-1 rounded-xl px-2 py-1.5 transition-colors"
          :class="
            isActive(tab.name)
              ? 'text-brand-600 dark:text-brand-300'
              : 'text-slate-500 hover:text-slate-900 dark:text-slate-400 dark:hover:text-slate-100'
          "
        >
          <component
            :is="tab.icon"
            :size="20"
            :stroke-width="isActive(tab.name) ? 2.4 : 1.8"
            class="transition-all"
            aria-hidden="true"
          />
          <span
            class="text-[11px] tracking-tight transition-all"
            :class="isActive(tab.name) ? 'font-semibold' : 'font-medium'"
            >{{ tab.label }}</span
          >
        </RouterLink>
      </li>
    </ul>
  </nav>
</template>
