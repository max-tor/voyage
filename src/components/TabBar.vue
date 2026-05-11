<script setup lang="ts">
import { RouterLink, useRoute } from 'vue-router'
import { computed } from 'vue'

const route = useRoute()

const tabs = [
  { name: 'map', label: 'Map', to: '/map', icon: 'map' },
  { name: 'fillups', label: 'Fill-ups', to: '/fillups', icon: 'fuel' },
  { name: 'garage', label: 'Garage', to: '/garage', icon: 'car' },
  { name: 'settings', label: 'Settings', to: '/settings', icon: 'cog' },
] as const

const active = computed(() => route.name)
</script>

<template>
  <nav
    class="fixed inset-x-0 bottom-0 z-40 border-t border-slate-200 bg-white/95 backdrop-blur"
    aria-label="Primary"
  >
    <ul class="mx-auto flex max-w-md justify-around px-2 py-2">
      <li v-for="tab in tabs" :key="tab.name" class="flex-1">
        <RouterLink
          :to="tab.to"
          class="flex flex-col items-center gap-1 rounded-lg px-2 py-1.5 text-xs transition-colors"
          :class="
            active === tab.name
              ? 'text-brand-600 font-semibold'
              : 'text-slate-500 hover:text-slate-800'
          "
        >
          <span class="text-base">
            <span v-if="tab.icon === 'map'">🗺️</span>
            <span v-else-if="tab.icon === 'fuel'">⛽</span>
            <span v-else-if="tab.icon === 'car'">🚗</span>
            <span v-else>⚙️</span>
          </span>
          {{ tab.label }}
        </RouterLink>
      </li>
    </ul>
  </nav>
</template>
