import { defineStore } from 'pinia'
import { fetchStationsAround } from '@/services/overpass'
import { detectCountry } from '@/services/prices/country'
import { fetchDgegStations } from '@/services/prices/dgeg'
import { loadCrowdsourcedPrices } from '@/services/stations-db'
import type { MapStation } from '@/types/prices'

interface StationsState {
  items: MapStation[]
  loading: boolean
  error: string | null
  source: 'dgeg' | 'osm' | null
  country: string | null
}

const OVERPASS_RADIUS_M = 25_000
const DGEG_RADIUS_KM = 25

export const useStationsStore = defineStore('stations', {
  state: (): StationsState => ({
    items: [],
    loading: false,
    error: null,
    source: null,
    country: null,
  }),
  getters: {
    withPrices: (s) => s.items.filter((st) => st.prices != null),
  },
  actions: {
    async loadAround(lat: number, lng: number) {
      this.loading = true
      this.error = null
      this.country = detectCountry(lat, lng)

      try {
        let items: MapStation[]

        if (this.country === 'PT') {
          items = await fetchDgegStations(lat, lng, DGEG_RADIUS_KM)
          this.source = 'dgeg'
        } else {
          items = await fetchStationsAround(lat, lng, OVERPASS_RADIUS_M)
          this.source = 'osm'

          try {
            const crowd = await loadCrowdsourcedPrices(items.map((s) => s.osm_id))
            items = items.map((s) =>
              crowd[s.osm_id] != null ? { ...s, prices: crowd[s.osm_id] } : s,
            )
          } catch {
            // Crowdsourced enrichment is best-effort; keep stations.
          }
        }

        this.items = items
      } catch (e) {
        this.error = e instanceof Error ? e.message : 'Failed to load stations'
      } finally {
        this.loading = false
      }
    },
  },
})
