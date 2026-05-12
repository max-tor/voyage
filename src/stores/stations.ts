import { defineStore } from 'pinia'
import { fetchStationsAround, type OverpassStation } from '@/services/overpass'

interface StationsState {
  items: OverpassStation[]
  loading: boolean
  error: string | null
  lastFetch: { lat: number; lng: number; radius: number } | null
}

export const useStationsStore = defineStore('stations', {
  state: (): StationsState => ({
    items: [],
    loading: false,
    error: null,
    lastFetch: null,
  }),
  actions: {
    async loadAround(lat: number, lng: number, radiusMeters = 50000) {
      this.loading = true
      this.error = null
      try {
        this.items = await fetchStationsAround(lat, lng, radiusMeters)
        this.lastFetch = { lat, lng, radius: radiusMeters }
      } catch (e) {
        this.error = e instanceof Error ? e.message : 'Failed to load stations'
      } finally {
        this.loading = false
      }
    },
  },
})
