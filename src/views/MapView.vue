<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import L, { type CircleMarker, type Map as LMap } from 'leaflet'
import 'leaflet/dist/leaflet.css'
import { Loader2, LocateFixed, Navigation, Sparkles, X } from 'lucide-vue-next'
import CitySearch from '@/components/CitySearch.vue'
import PriceFilterBar from '@/components/PriceFilterBar.vue'
import { useGeolocation } from '@/composables/useGeolocation'
import { useStationsStore } from '@/stores/stations'
import { distanceKm } from '@/services/overpass'
import type { GeocodeResult } from '@/services/geocoding'
import type { FuelKind, MapStation, SortMode } from '@/types/prices'

const mapEl = ref<HTMLDivElement | null>(null)
let map: LMap | null = null
let userMarker: CircleMarker | null = null
let stationMarkers: CircleMarker[] = []

const {
  location,
  error: geoError,
  loading: geoLoading,
  locate,
  setLocation,
} = useGeolocation()
const viewLabel = ref<string | null>(null)
const stations = useStationsStore()
const selected = ref<MapStation | null>(null)
const fuel = ref<FuelKind>('e5')
const sort = ref<SortMode>('distance')

const DEFAULT_CENTER: [number, number] = [50.5, 10]
const DEFAULT_ZOOM = 4

/**
 * In "price" mode only stations with a price for the selected fuel are
 * shown. Falls back to all stations when nothing in the area has prices,
 * so the user isn't staring at an empty map.
 */
const visibleStations = computed<MapStation[]>(() => {
  if (sort.value !== 'price') return stations.items
  const withPrices = stations.items.filter((s) => s.prices?.[fuel.value] != null)
  return withPrices.length > 0 ? withPrices : stations.items
})

const sortedPrices = computed<number[]>(() =>
  stations.items
    .map((s) => s.prices?.[fuel.value])
    .filter((p): p is number => p != null)
    .sort((a, b) => a - b),
)

const cheapestPrice = computed<number | null>(() => sortedPrices.value[0] ?? null)

const cheapestStation = computed<MapStation | null>(() => {
  if (cheapestPrice.value == null) return null
  return (
    stations.items.find((s) => s.prices?.[fuel.value] === cheapestPrice.value) ?? null
  )
})

const cheapestStationId = computed<string | null>(() => cheapestStation.value?.osm_id ?? null)

function focusCheapest() {
  const s = cheapestStation.value
  if (!s || !map) return
  selected.value = s
  map.flyTo([s.lat, s.lng], 15, { duration: 0.6 })
}

watch([visibleStations, fuel, sort, cheapestStationId], renderStations, { deep: false })

onMounted(async () => {
  if (!mapEl.value) return

  map = L.map(mapEl.value, { zoomControl: false }).setView(DEFAULT_CENTER, DEFAULT_ZOOM)
  L.control.zoom({ position: 'topright' }).addTo(map)
  L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: '© OpenStreetMap',
    maxZoom: 19,
  }).addTo(map)

  const here = await locate()
  if (here && map) {
    map.setView([here.lat, here.lng], 13)
    addUserMarker(here.lat, here.lng)
    await stations.loadAround(here.lat, here.lng)
  }
})

onBeforeUnmount(() => {
  if (map) {
    map.remove()
    map = null
  }
  userMarker = null
  stationMarkers = []
})

function addUserMarker(lat: number, lng: number) {
  if (!map) return
  if (userMarker) userMarker.remove()
  userMarker = L.circleMarker([lat, lng], {
    radius: 8,
    color: '#ffffff',
    weight: 3,
    fillColor: '#2563eb',
    fillOpacity: 1,
  }).addTo(map)
}

function markerColorFor(s: MapStation): string {
  const price = s.prices?.[fuel.value]
  if (price == null) return '#94a3b8' // slate-400 = no price

  if (sort.value === 'price') {
    // Cheap mode: colour by price quartile so cheap stations stand out
    // and expensive ones look expensive.
    const sorted = sortedPrices.value
    if (sorted.length < 2) return '#16a34a'
    const idx = sorted.indexOf(price)
    const pct = idx / (sorted.length - 1)
    if (pct <= 0.33) return '#16a34a' // green — bottom third (cheap)
    if (pct <= 0.66) return '#f59e0b' // amber — middle third
    return '#dc2626' // red — top third (expensive)
  }

  // Near mode: only the single cheapest is highlighted; everything else
  // with a price is amber; missing prices stay slate.
  if (cheapestPrice.value != null && Math.abs(price - cheapestPrice.value) < 0.001) {
    return '#16a34a'
  }
  return '#f59e0b'
}

function renderStations() {
  if (!map) return
  stationMarkers.forEach((m) => m.remove())
  stationMarkers = []
  for (const s of visibleStations.value) {
    const isCheapest = s.osm_id === cheapestStationId.value
    const m = L.circleMarker([s.lat, s.lng], {
      radius: isCheapest ? 10 : 7,
      color: '#ffffff',
      weight: 2,
      fillColor: markerColorFor(s),
      fillOpacity: 0.95,
    })
      .on('click', () => (selected.value = s))
      .addTo(map!)
    stationMarkers.push(m)
  }
}

async function recenter() {
  const here = await locate()
  if (here && map) {
    viewLabel.value = null
    map.setView([here.lat, here.lng], 14)
    addUserMarker(here.lat, here.lng)
    await stations.loadAround(here.lat, here.lng)
  }
}

async function gotoCity(result: GeocodeResult) {
  if (!map) return
  setLocation({ lat: result.lat, lng: result.lng, accuracy: 0 })
  viewLabel.value = result.displayName.split(',')[0].trim()
  map.setView([result.lat, result.lng], 13)
  addUserMarker(result.lat, result.lng)
  await stations.loadAround(result.lat, result.lng)
}

function distanceTo(s: MapStation): string {
  if (!location.value) return ''
  const km = distanceKm(location.value.lat, location.value.lng, s.lat, s.lng)
  return km < 1 ? `${(km * 1000).toFixed(0)} m` : `${km.toFixed(1)} km`
}

function formatPrice(price: number | undefined, currency: string): string {
  if (price == null) return '—'
  return `${price.toFixed(3)} ${currency}/l`
}

function navigateLink(s: MapStation): string {
  return `https://www.google.com/maps/dir/?api=1&destination=${s.lat},${s.lng}`
}

function logFillupLink(s: MapStation) {
  return {
    path: '/fillups/new',
    query: {
      osmId: s.osm_id,
      lat: String(s.lat),
      lng: String(s.lng),
      name: s.name ?? '',
      brand: s.brand ?? '',
      address: s.address ?? '',
    },
  }
}

function relativeTime(iso: string): string {
  const ms = Date.now() - new Date(iso).getTime()
  const minutes = Math.round(ms / 60000)
  if (minutes < 1) return 'just now'
  if (minutes < 60) return `${minutes} min ago`
  const hours = Math.round(minutes / 60)
  if (hours < 24) return `${hours}h ago`
  const days = Math.round(hours / 24)
  return `${days}d ago`
}
</script>

<template>
  <section class="relative h-[calc(100dvh-5rem)] w-full overflow-hidden">
    <div ref="mapEl" class="absolute inset-0 z-0"></div>

    <div class="pointer-events-none absolute inset-x-0 top-0 z-10 space-y-2 p-3">
      <div class="pointer-events-auto">
        <CitySearch @select="gotoCity" />
      </div>

      <div
        class="pointer-events-auto flex items-center justify-between gap-2 rounded-full bg-white/90 px-4 py-2 shadow-soft-md ring-1 ring-slate-900/5 backdrop-blur-xl"
      >
        <h1 class="truncate text-sm font-semibold text-slate-900">
          {{ viewLabel ?? 'Stations nearby' }}
        </h1>
        <span
          v-if="stations.loading"
          class="flex shrink-0 items-center gap-1 text-xs text-slate-500"
        >
          <Loader2 :size="12" class="animate-spin" />
          Loading
        </span>
        <span v-else-if="stations.error" class="text-xs text-red-600">{{ stations.error }}</span>
        <span v-else class="flex shrink-0 items-center gap-1.5 text-xs text-slate-500">
          {{ stations.items.length }} found
          <span
            v-if="stations.source === 'dgeg' || stations.source === 'regieessence'"
            class="flex items-center gap-1 rounded-full bg-emerald-100 px-1.5 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-emerald-700"
          >
            <span class="h-1.5 w-1.5 rounded-full bg-emerald-500"></span>
            Live
          </span>
        </span>
      </div>

      <div class="pointer-events-auto inline-flex">
        <PriceFilterBar
          :fuel="fuel"
          :sort="sort"
          @update:fuel="fuel = $event"
          @update:sort="sort = $event"
        />
      </div>

      <button
        v-if="cheapestPrice != null"
        type="button"
        class="pointer-events-auto inline-flex items-center gap-1.5 rounded-full bg-emerald-50 px-3 py-1.5 text-xs font-semibold text-emerald-700 shadow-soft ring-1 ring-emerald-500/20 backdrop-blur-xl transition-all hover:bg-emerald-100 hover:shadow-soft-md active:scale-[0.98]"
        :aria-label="`Open cheapest station at ${cheapestPrice.toFixed(3)} ${stations.currency} per litre`"
        @click="focusCheapest"
      >
        <Sparkles :size="12" />
        Cheapest {{ cheapestPrice.toFixed(3) }} {{ stations.currency }}/l
      </button>
    </div>

    <button
      type="button"
      class="absolute bottom-4 right-3 z-10 grid h-12 w-12 place-items-center rounded-full bg-white text-slate-700 shadow-soft-lg ring-1 ring-slate-900/5 transition-all hover:bg-slate-50 active:scale-95 disabled:opacity-60"
      :disabled="geoLoading"
      :aria-label="geoLoading ? 'Locating…' : 'Locate me'"
      @click="recenter"
    >
      <Loader2 v-if="geoLoading" :size="20" class="animate-spin" />
      <LocateFixed v-else :size="20" />
    </button>

    <p
      v-if="geoError"
      class="absolute inset-x-3 top-32 z-10 rounded-md bg-red-50 px-3 py-2 text-center text-sm text-red-700 shadow"
    >
      {{ geoError }}
    </p>

    <div
      v-if="selected"
      class="absolute inset-x-3 bottom-3 z-20 rounded-2xl bg-white p-4 shadow-soft-lg ring-1 ring-slate-900/5"
    >
      <div class="flex items-start justify-between gap-3">
        <div class="min-w-0 flex-1">
          <p class="truncate font-semibold text-slate-900">
            {{ selected.name ?? selected.brand ?? 'Fuel station' }}
          </p>
          <p
            v-if="selected.brand && selected.brand !== selected.name"
            class="truncate text-sm text-slate-500"
          >
            {{ selected.brand }}
          </p>
          <p v-if="selected.address" class="truncate text-xs text-slate-500">
            {{ selected.address }}
          </p>
          <p v-if="location" class="mt-1 text-xs text-slate-400">{{ distanceTo(selected) }} away</p>
        </div>
        <button
          type="button"
          class="grid h-7 w-7 shrink-0 place-items-center rounded-full bg-slate-100 text-slate-500 transition-colors hover:bg-slate-200"
          aria-label="Close"
          @click="selected = null"
        >
          <X :size="14" />
        </button>
      </div>

      <dl v-if="selected.prices" class="mt-3 grid grid-cols-3 gap-2 text-center">
        <div class="rounded-xl bg-slate-50 p-2">
          <dt class="text-[10px] font-semibold uppercase tracking-wider text-slate-500">E5</dt>
          <dd class="mt-0.5 text-sm font-semibold text-slate-900">
            {{ formatPrice(selected.prices.e5, selected.prices.currency) }}
          </dd>
        </div>
        <div class="rounded-xl bg-slate-50 p-2">
          <dt class="text-[10px] font-semibold uppercase tracking-wider text-slate-500">E10</dt>
          <dd class="mt-0.5 text-sm font-semibold text-slate-900">
            {{ formatPrice(selected.prices.e10, selected.prices.currency) }}
          </dd>
        </div>
        <div class="rounded-xl bg-slate-50 p-2">
          <dt class="text-[10px] font-semibold uppercase tracking-wider text-slate-500">Diesel</dt>
          <dd class="mt-0.5 text-sm font-semibold text-slate-900">
            {{ formatPrice(selected.prices.diesel, selected.prices.currency) }}
          </dd>
        </div>
      </dl>
      <p v-if="selected.prices" class="mt-2 text-[10px] text-slate-400">
        Updated {{ relativeTime(selected.prices.reportedAt) }} · source {{ selected.prices.source }}
      </p>
      <p v-else class="mt-3 text-xs text-slate-500">
        No price yet — log a fill-up to contribute one.
      </p>

      <div class="mt-3 flex gap-2">
        <a
          :href="navigateLink(selected)"
          target="_blank"
          rel="noopener"
          class="flex flex-1 items-center justify-center gap-1.5 rounded-xl bg-brand-600 px-3 py-2.5 text-sm font-semibold text-white shadow-glow-brand transition-all hover:bg-brand-700 active:scale-[0.98]"
        >
          <Navigation :size="14" />
          Navigate
        </a>
        <RouterLink
          :to="logFillupLink(selected)"
          class="flex-1 rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-center text-sm font-semibold text-slate-700 transition-all hover:bg-slate-50 active:scale-[0.98]"
          >Log fill-up</RouterLink
        >
      </div>
    </div>
  </section>
</template>
