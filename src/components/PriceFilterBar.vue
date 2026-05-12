<script setup lang="ts">
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
    <select
      :value="fuel"
      class="rounded-full border border-slate-200 bg-white px-3 py-1.5 text-xs font-medium focus:outline-none focus:ring-1 focus:ring-brand-500"
      @change="$emit('update:fuel', ($event.target as HTMLSelectElement).value as FuelKind)"
    >
      <option v-for="[v, label] in fuels" :key="v" :value="v">{{ label }}</option>
    </select>

    <div class="flex overflow-hidden rounded-full bg-slate-100 text-xs">
      <button
        type="button"
        class="px-3 py-1.5 transition-colors"
        :class="sort === 'distance' ? 'bg-white font-semibold shadow-sm' : 'text-slate-500'"
        @click="$emit('update:sort', 'distance')"
      >
        Near
      </button>
      <button
        type="button"
        class="px-3 py-1.5 transition-colors"
        :class="sort === 'price' ? 'bg-white font-semibold shadow-sm' : 'text-slate-500'"
        @click="$emit('update:sort', 'price')"
      >
        Cheap
      </button>
    </div>
  </div>
</template>
