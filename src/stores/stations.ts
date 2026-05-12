import { defineStore } from 'pinia'
import { fetchStationsAround } from '@/services/overpass'
import { detectCountry } from '@/services/prices/country'
import { fetchTankerkonigStations } from '@/services/prices/tankerkonig'
import { loadCrowdsourcedPrices } from '@/services/stations-db'
import type { MapStation } from '@/types/prices'

interface StationsState {
  items: MapStation[]
  loading: boolean
  error: string | null
  source: 'tankerkonig' | 'osm' | null
  country: string | null
}

const OVERPASS_RADIUS_M = 25_000
const TANKERKONIG_RADIUS_KM = 25

export const useStationsStore = defineStore('stations', {
  state: (): StationsState => ({
    items: [],
    loading: false,
    error: null,
    source: null,
    country: null,
  }),
  getters: {
    /** Stations that carry at least one known price. */
    withPrices: (s) => s.items.filter((st) => st.prices != null),
  },
  actions: {
    async loadAround(lat: number, lng: number) {
      this.loading = true
      this.error = null
      this.country = detectCountry(lat, lng)

      try {
        const tankerkonigKey = import.meta.env.VITE_TANKERKONIG_API_KEY
        let items: MapStation[] = []

        if (this.country === 'DE' && tankerkonigKey) {
          items = await fetchTankerkonigStations(lat, lng, TANKERKONIG_RADIUS_KM, tankerkonigKey)
          this.source = 'tankerkonig'
        } else {
          items = await fetchStationsAround(lat, lng, OVERPASS_RADIUS_M)
          this.source = 'osm'
        }

        if (this.source === 'osm') {
          try {
            const crowd = await loadCrowdsourcedPrices(items.map((s) => s.osm_id))
            items = items.map((s) =>
              crowd[s.osm_id] != null ? { ...s, prices: crowd[s.osm_id] } : s,
            )
          } catch {
            // Crowdsourced prices are best-effort; don't fail the whole load.
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
