<script setup lang="ts">
import { onBeforeUnmount, ref, watch } from 'vue'
import { geocodeSearch, type GeocodeResult } from '@/services/geocoding'

const emit = defineEmits<{ select: [GeocodeResult] }>()

const query = ref('')
const open = ref(false)
const loading = ref(false)
const results = ref<GeocodeResult[]>([])
const errorMsg = ref<string | null>(null)

let debounceHandle: ReturnType<typeof setTimeout> | null = null
let inFlight: AbortController | null = null

watch(query, (q) => {
  if (debounceHandle) clearTimeout(debounceHandle)
  if (inFlight) inFlight.abort()
  errorMsg.value = null

  if (q.trim().length < 2) {
    results.value = []
    loading.value = false
    return
  }

  debounceHandle = setTimeout(() => void run(q), 350)
})

async function run(q: string) {
  loading.value = true
  inFlight = new AbortController()
  try {
    results.value = await geocodeSearch(q)
  } catch (e) {
    if ((e as Error).name !== 'AbortError') {
      errorMsg.value = e instanceof Error ? e.message : 'Search failed'
      results.value = []
    }
  } finally {
    loading.value = false
  }
}

function pick(r: GeocodeResult) {
  emit('select', r)
  query.value = shortLabel(r.displayName)
  open.value = false
  results.value = []
}

function clear() {
  query.value = ''
  results.value = []
  open.value = false
}

function onBlur() {
  setTimeout(() => (open.value = false), 150)
}

function shortLabel(displayName: string): string {
  const parts = displayName.split(',').map((s) => s.trim())
  if (parts.length <= 2) return displayName
  return `${parts[0]}, ${parts[parts.length - 1]}`
}

onBeforeUnmount(() => {
  if (debounceHandle) clearTimeout(debounceHandle)
  if (inFlight) inFlight.abort()
})
</script>

<template>
  <div class="relative">
    <div class="flex items-center gap-2 rounded-full bg-white/95 px-4 py-2 shadow-md backdrop-blur">
      <span aria-hidden="true">🔎</span>
      <input
        v-model="query"
        type="search"
        placeholder="Search a city or address"
        class="flex-1 bg-transparent text-sm focus:outline-none"
        @focus="open = true"
        @blur="onBlur"
      />
      <span v-if="loading" class="text-xs text-slate-400">…</span>
      <button
        v-else-if="query"
        type="button"
        class="text-slate-400 hover:text-slate-700"
        aria-label="Clear"
        @click="clear"
      >
        ✕
      </button>
    </div>

    <div
      v-if="open && (results.length > 0 || errorMsg)"
      class="absolute inset-x-0 top-full z-30 mt-1 max-h-72 overflow-y-auto rounded-lg bg-white shadow-lg ring-1 ring-slate-200"
    >
      <p v-if="errorMsg" class="px-3 py-2 text-xs text-red-600">{{ errorMsg }}</p>
      <ul v-else>
        <li v-for="r in results" :key="`${r.lat}-${r.lng}-${r.displayName}`">
          <button
            type="button"
            class="block w-full px-3 py-2 text-left text-sm hover:bg-slate-50"
            @mousedown.prevent="pick(r)"
          >
            <span class="font-medium">{{ shortLabel(r.displayName) }}</span>
            <span class="block text-xs text-slate-400">{{ r.displayName }}</span>
          </button>
        </li>
      </ul>
    </div>
  </div>
</template>
