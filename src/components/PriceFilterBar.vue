<script setup lang="ts">
import { ChevronDown } from 'lucide-vue-next'
import { FUEL_KIND_LABELS, type FuelKind, type SortMode } from '@/types/prices'

defineProps<{
  fuel: FuelKind
  sort: SortMode
}>()
defineEmits<{
  'update:fuel': [FuelKind]
  'update:sort': [SortMode]
}>()

const fuels = Object.entries(FUEL_KIND_LABELS) as [FuelKind, string][]
</script>

<template>
  <div class="flex items-center gap-2">
    <div
      class="relative flex items-center gap-1 rounded-full bg-white/90 px-3 py-1.5 text-xs font-medium text-slate-700 shadow-soft ring-1 ring-slate-900/5 backdrop-blur-xl dark:bg-slate-900/80 dark:text-slate-200 dark:ring-white/10"
    >
      <select
        :value="fuel"
        class="appearance-none bg-transparent pr-4 focus:outline-none"
        @change="$emit('update:fuel', ($event.target as HTMLSelectElement).value as FuelKind)"
      >
        <option v-for="[v, label] in fuels" :key="v" :value="v">{{ label }}</option>
      </select>
      <ChevronDown
        :size="12"
        class="pointer-events-none absolute right-2 text-slate-400 dark:text-slate-500"
      />
    </div>

    <div
      class="flex overflow-hidden rounded-full bg-white/70 p-0.5 text-xs shadow-soft ring-1 ring-slate-900/5 backdrop-blur-xl dark:bg-slate-900/70 dark:ring-white/10"
    >
      <button
        type="button"
        class="rounded-full px-3 py-1 transition-colors"
        :class="
          sort === 'distance'
            ? 'bg-brand-600 text-white shadow-sm'
            : 'text-slate-600 hover:text-slate-900 dark:text-slate-400 dark:hover:text-slate-100'
        "
        @click="$emit('update:sort', 'distance')"
      >
        Near
      </button>
      <button
        type="button"
        class="rounded-full px-3 py-1 transition-colors"
        :class="
          sort === 'price'
            ? 'bg-brand-600 text-white shadow-sm'
            : 'text-slate-600 hover:text-slate-900 dark:text-slate-400 dark:hover:text-slate-100'
        "
        @click="$emit('update:sort', 'price')"
      >
        Cheap
      </button>
    </div>
  </div>
</template>
