<script setup lang="ts">
import { computed, ref } from 'vue'
import type { CarCatalogEntry } from '@/types/database'

const props = defineProps<{ catalog: CarCatalogEntry[] }>()
const emit = defineEmits<{ select: [CarCatalogEntry] }>()

const query = ref('')
const open = ref(false)

const results = computed(() => {
  const q = query.value.trim().toLowerCase()
  if (!q) return []
  return props.catalog
    .filter((c) => `${c.make} ${c.model}`.toLowerCase().includes(q))
    .slice(0, 8)
})

function pick(entry: CarCatalogEntry) {
  emit('select', entry)
  query.value = `${entry.make} ${entry.model}`
  open.value = false
}

function onBlur() {
  setTimeout(() => (open.value = false), 150)
}
</script>

<template>
  <div class="relative">
    <label class="block">
      <span class="text-sm font-medium text-slate-700">Find your car (optional)</span>
      <input
        v-model="query"
        type="text"
        placeholder="e.g. VW Golf"
        class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
        @focus="open = true"
        @blur="onBlur"
      />
    </label>
    <ul
      v-if="open && results.length > 0"
      class="absolute z-10 mt-1 max-h-72 w-full overflow-y-auto rounded-md border border-slate-200 bg-white shadow-lg"
    >
      <li v-for="entry in results" :key="entry.id">
        <button
          type="button"
          class="block w-full px-3 py-2 text-left text-sm hover:bg-slate-50"
          @mousedown.prevent="pick(entry)"
        >
          <span class="font-medium">{{ entry.make }}</span>
          <span class="text-slate-700"> {{ entry.model }}</span>
          <span v-if="entry.default_tank_l" class="ml-2 text-xs text-slate-400">
            {{ entry.default_tank_l }} L · {{ entry.default_consumption_l_100km }} l/100km
          </span>
        </button>
      </li>
    </ul>
  </div>
</template>
