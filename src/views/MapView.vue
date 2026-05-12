<script setup lang="ts">
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { RouterLink } from 'vue-router'
import L, { type CircleMarker, type Map as LMap } from 'leaflet'
import 'leaflet/dist/leaflet.css'
import { useGeolocation } from '@/composables/useGeolocation'
import { useStationsStore } from '@/stores/stations'
import { distanceKm, type OverpassStation } from '@/services/overpass'

const mapEl = ref<HTMLDivElement | null>(null)
let map: LMap | null = null
let userMarker: CircleMarker | null = null
let stationMarkers: CircleMarker[] = []

const { location, error: geoError, loading: geoLoading, locate } = useGeolocation()
const stations = useStationsStore()
const selected = ref<OverpassStation | null>(null)

const DEFAULT_CENTER: [number, number] = [50.5, 10] // Central Europe
const DEFAULT_ZOOM = 4
const NEARBY_RADIUS_M = 25_000

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
    await loadAndRenderStations(here.lat, here.lng)
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

async function loadAndRenderStations(lat: number, lng: number) {
  await stations.loadAround(lat, lng, NEARBY_RADIUS_M)
  renderStations()
}

function renderStations() {
  if (!map) return
  stationMarkers.forEach((m) => m.remove())
  stationMarkers = []
  for (const s of stations.items) {
    const m = L.circleMarker([s.lat, s.lng], {
      radius: 7,
      color: '#ffffff',
      weight: 2,
      fillColor: '#16a34a',
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
    map.setView([here.lat, here.lng], 14)
    addUserMarker(here.lat, here.lng)
    await loadAndRenderStations(here.lat, here.lng)
  }
}

function distanceTo(s: OverpassStation): string {
  if (!location.value) return ''
  const km = distanceKm(location.value.lat, location.value.lng, s.lat, s.lng)
  return km < 1 ? `${(km * 1000).toFixed(0)} m` : `${km.toFixed(1)} km`
}

function navigateLink(s: OverpassStation): string {
  return `https://www.google.com/maps/dir/?api=1&destination=${s.lat},${s.lng}`
}
</script>

<template>
  <section class="relative h-[calc(100dvh-5rem)] w-full overflow-hidden">
    <div ref="mapEl" class="absolute inset-0 z-0"></div>

    <div class="pointer-events-none absolute inset-x-0 top-0 z-10 p-3">
      <div
        class="pointer-events-auto flex items-center justify-between gap-2 rounded-full bg-white/95 px-4 py-2 shadow-md backdrop-blur"
      >
        <h1 class="text-sm font-semibold">Stations nearby</h1>
        <span v-if="stations.loading" class="text-xs text-slate-500">Loading…</span>
        <span v-else-if="stations.error" class="text-xs text-red-600">{{ stations.error }}</span>
        <span v-else class="text-xs text-slate-500">{{ stations.items.length }} found</span>
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
      class="absolute inset-x-3 top-16 z-10 rounded-md bg-red-50 px-3 py-2 text-center text-sm text-red-700 shadow"
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
      <div class="mt-3 flex gap-2">
        <a
          :href="navigateLink(selected)"
          target="_blank"
          rel="noopener"
          class="flex-1 rounded-md bg-brand-600 px-3 py-2 text-center text-sm font-semibold text-white hover:bg-brand-700"
          >Navigate</a
        >
        <RouterLink
          to="/fillups/new"
          class="flex-1 rounded-md border border-slate-300 bg-white px-3 py-2 text-center text-sm font-semibold text-slate-700 hover:bg-slate-50"
          >Log fill-up</RouterLink
        >
      </div>
    </div>
  </section>
</template>
