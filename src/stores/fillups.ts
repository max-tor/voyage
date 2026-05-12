import { defineStore } from 'pinia'
import {
  createFillUp,
  deleteFillUp,
  getFillUp,
  getLastFillUp,
  listFillUps,
  updateFillUp,
} from '@/services/fillups'
import type { FillUp, FillUpInsert, FillUpUpdate } from '@/types/database'
import { useAuthStore } from './auth'

interface FillUpsState {
  byCarId: Record<string, FillUp[]>
  loadingCarId: string | null
  error: string | null
}

export const useFillUpsStore = defineStore('fillups', {
  state: (): FillUpsState => ({
    byCarId: {},
    loadingCarId: null,
    error: null,
  }),
  getters: {
    forCar:
      (s) =>
      (carId: string): FillUp[] =>
        s.byCarId[carId] ?? [],
  },
  actions: {
    async refresh(carId: string) {
      this.loadingCarId = carId
      this.error = null
      try {
        this.byCarId[carId] = await listFillUps(carId)
      } catch (e) {
        this.error = e instanceof Error ? e.message : 'Failed to load fill-ups'
        throw e
      } finally {
        if (this.loadingCarId === carId) this.loadingCarId = null
      }
    },

    async fetchOne(id: string): Promise<FillUp> {
      for (const list of Object.values(this.byCarId)) {
        const found = list.find((f) => f.id === id)
        if (found) return found
      }
      return getFillUp(id)
    },

    async getLastFor(carId: string): Promise<FillUp | null> {
      return getLastFillUp(carId)
    },

    async create(input: FillUpInsert): Promise<FillUp> {
      const auth = useAuthStore()
      if (!auth.user) throw new Error('Not signed in')
      const created = await createFillUp(auth.user.id, input)
      await this.refresh(input.car_id)
      return created
    },

    async update(id: string, patch: FillUpUpdate, carId: string): Promise<FillUp> {
      const updated = await updateFillUp(id, patch)
      await this.refresh(carId)
      return updated
    },

    async remove(id: string, carId: string) {
      await deleteFillUp(id)
      await this.refresh(carId)
    },
  },
})
