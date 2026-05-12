<script setup lang="ts">
import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import L, { type CircleMarker, type Map as LMap } from 'leaflet'
import 'leaflet/dist/leaflet.css'
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

const ranked = computed<MapStation[]>(() => {
  const here = location.value
  const items = [...stations.items]
  if (sort.value === 'price') {
    return items.sort((a, b) => {
      const pa = a.prices?.[fuel.value]
      const pb = b.prices?.[fuel.value]
      if (pa == null && pb == null) return 0
      if (pa == null) return 1
      if (pb == null) return -1
      return pa - pb
    })
  }
  if (!here) return items
  return items.sort(
    (a, b) =>
      distanceKm(here.lat, here.lng, a.lat, a.lng) -
      distanceKm(here.lat, here.lng, b.lat, b.lng),
  )
})

const cheapestPrice = computed<number | null>(() => {
  let min: number | null = null
  for (const s of stations.items) {
    const p = s.prices?.[fuel.value]
    if (p != null && (min == null || p < min)) min = p
  }
  return min
})

const cheapestStationId = computed<string | null>(() => {
  if (cheapestPrice.value == null) return null
  const hit = stations.items.find((s) => s.prices?.[fuel.value] === cheapestPrice.value)
  return hit?.osm_id ?? null
})

watch([() => stations.items, fuel, sort], renderStations, { deep: false })

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
  if (cheapestPrice.value != null && Math.abs(price - cheapestPrice.value) < 0.001)
    return '#16a34a' // green = cheapest
  return '#f59e0b' // amber = has price but not cheapest
}

function renderStations() {
  if (!map) return
  stationMarkers.forEach((m) => m.remove())
  stationMarkers = []
  for (const s of stations.items) {
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
        class="pointer-events-auto flex items-center justify-between gap-2 rounded-full bg-white/95 px-4 py-2 shadow-md backdrop-blur"
      >
        <h1 class="truncate text-sm font-semibold">
          {{ viewLabel ?? 'Stations nearby' }}
        </h1>
        <span v-if="stations.loading" class="text-xs text-slate-500">Loading…</span>
        <span v-else-if="stations.error" class="text-xs text-red-600">{{ stations.error }}</span>
        <span v-else class="shrink-0 text-xs text-slate-500">
          {{ stations.items.length }} found
          <template v-if="stations.source === 'dgeg'"> · live</template>
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

      <div
        v-if="cheapestPrice != null"
        class="pointer-events-auto inline-flex items-center gap-2 rounded-full bg-emerald-50 px-3 py-1 text-xs font-medium text-emerald-700 shadow-sm ring-1 ring-emerald-200"
      >
        Cheapest: {{ cheapestPrice.toFixed(3) }} €/l
      </div>
    </div>

    <button
      type="button"
      class="absolute bottom-4 right-3 z-10 rounded-full bg-white p-3 text-lg shadow-lg hover:bg-slate-50 disabled:opacity-60"
      :disabled="geoLoading"
      :aria-label="geoLoading ? 'Locating…' : 'Locate me'"
      @click="recenter"
    >
      {{ geoLoading ? '⏳' : '📍' }}
    </button>

    <p
      v-if="geoError"
      class="absolute inset-x-3 top-32 z-10 rounded-md bg-red-50 px-3 py-2 text-center text-sm text-red-700 shadow"
    >
      {{ geoError }}
    </p>

    <div
      v-if="selected"
      class="absolute inset-x-3 bottom-3 z-20 rounded-xl bg-white p-4 shadow-2xl ring-1 ring-slate-200"
    >
      <div class="flex items-start justify-between gap-3">
        <div class="min-w-0 flex-1">
          <p class="truncate font-semibold">
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
          class="text-slate-400 hover:text-slate-700"
          aria-label="Close"
          @click="selected = null"
        >
          ✕
        </button>
      </div>

      <dl v-if="selected.prices" class="mt-3 grid grid-cols-3 gap-2 text-center">
        <div class="rounded-md bg-slate-50 p-2">
          <dt class="text-[10px] font-medium uppercase tracking-wide text-slate-500">E5</dt>
          <dd class="text-sm font-semibold">
            {{ formatPrice(selected.prices.e5, selected.prices.currency) }}
          </dd>
        </div>
        <div class="rounded-md bg-slate-50 p-2">
          <dt class="text-[10px] font-medium uppercase tracking-wide text-slate-500">E10</dt>
          <dd class="text-sm font-semibold">
            {{ formatPrice(selected.prices.e10, selected.prices.currency) }}
          </dd>
        </div>
        <div class="rounded-md bg-slate-50 p-2">
          <dt class="text-[10px] font-medium uppercase tracking-wide text-slate-500">Diesel</dt>
          <dd class="text-sm font-semibold">
            {{ formatPrice(selected.prices.diesel, selected.prices.currency) }}
          </dd>
        </div>
      </dl>
      <p v-if="selected.prices" class="mt-1 text-[10px] text-slate-400">
        {{ relativeTime(selected.prices.reportedAt) }} · source: {{ selected.prices.source }}
      </p>
      <p v-else class="mt-2 text-xs text-slate-400">
        No price yet — log a fill-up to contribute.
      </p>

      <div class="mt-3 flex gap-2">
        <a
          :href="navigateLink(selected)"
          target="_blank"
          rel="noopener"
          class="flex-1 rounded-md bg-brand-600 px-3 py-2 text-center text-sm font-semibold text-white hover:bg-brand-700"
          >Navigate</a
        >
        <RouterLink
          :to="logFillupLink(selected)"
          class="flex-1 rounded-md border border-slate-300 bg-white px-3 py-2 text-center text-sm font-semibold text-slate-700 hover:bg-slate-50"
          >Log fill-up</RouterLink
        >
      </div>
    </div>
  </section>
</template>
