<script setup lang="ts">
import { onBeforeUnmount, ref, watch } from 'vue'
import { Loader2, Search, X } from 'lucide-vue-next'
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
    <div
      class="flex items-center gap-2.5 rounded-full bg-white/90 px-4 py-2.5 shadow-soft-md ring-1 ring-slate-900/5 backdrop-blur-xl transition-shadow focus-within:shadow-soft-lg focus-within:ring-brand-500/30 dark:bg-slate-900/80 dark:ring-white/10 dark:focus-within:ring-brand-400/40"
    >
      <Search :size="16" class="shrink-0 text-slate-400 dark:text-slate-500" aria-hidden="true" />
      <input
        v-model="query"
        type="search"
        placeholder="Search a city or address"
        class="flex-1 bg-transparent text-sm text-slate-900 placeholder:text-slate-400 focus:outline-none dark:text-slate-100 dark:placeholder:text-slate-500"
        @focus="open = true"
        @blur="onBlur"
      />
      <Loader2
        v-if="loading"
        :size="14"
        class="shrink-0 animate-spin text-slate-400 dark:text-slate-500"
        aria-hidden="true"
      />
      <button
        v-else-if="query"
        type="button"
        class="grid h-5 w-5 shrink-0 place-items-center rounded-full bg-slate-200 text-slate-600 transition-colors hover:bg-slate-300 dark:bg-slate-700 dark:text-slate-300 dark:hover:bg-slate-600"
        aria-label="Clear"
        @click="clear"
      >
        <X :size="12" />
      </button>
    </div>

    <div
      v-if="open && (results.length > 0 || errorMsg)"
      class="absolute inset-x-0 top-full z-30 mt-1.5 max-h-72 overflow-y-auto rounded-2xl bg-white shadow-soft-lg ring-1 ring-slate-900/5 dark:bg-slate-900 dark:ring-white/10"
    >
      <p v-if="errorMsg" class="px-3 py-2 text-xs text-red-600 dark:text-red-400">{{ errorMsg }}</p>
      <ul v-else class="py-1">
        <li v-for="r in results" :key="`${r.lat}-${r.lng}-${r.displayName}`">
          <button
            type="button"
            class="block w-full px-3 py-2 text-left text-sm transition-colors hover:bg-slate-50 dark:hover:bg-slate-800"
            @mousedown.prevent="pick(r)"
          >
            <span class="block font-medium text-slate-900 dark:text-slate-100">{{
              shortLabel(r.displayName)
            }}</span>
            <span class="mt-0.5 block truncate text-xs text-slate-500 dark:text-slate-400">{{
              r.displayName
            }}</span>
          </button>
        </li>
      </ul>
    </div>
  </div>
</template>
