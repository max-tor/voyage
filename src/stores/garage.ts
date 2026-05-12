import { defineStore } from 'pinia'
import {
  createCar,
  deleteCar,
  getCar,
  listCarCatalog,
  listCars,
  setActiveCar,
  updateCar,
  uploadCarPhoto,
} from '@/services/cars'
import type { Car, CarCatalogEntry, CarInsert, CarUpdate } from '@/types/database'
import { useAuthStore } from './auth'

interface GarageState {
  cars: Car[]
  catalog: CarCatalogEntry[]
  loading: boolean
  catalogLoaded: boolean
  error: string | null
}

export const useGarageStore = defineStore('garage', {
  state: (): GarageState => ({
    cars: [],
    catalog: [],
    loading: false,
    catalogLoaded: false,
    error: null,
  }),
  getters: {
    activeCar: (s): Car | null => s.cars.find((c) => c.is_active) ?? null,
    findById: (s) => (id: string) => s.cars.find((c) => c.id === id) ?? null,
  },
  actions: {
    async refresh() {
      this.loading = true
      this.error = null
      try {
        this.cars = await listCars()
      } catch (e) {
        this.error = e instanceof Error ? e.message : 'Failed to load cars'
        throw e
      } finally {
        this.loading = false
      }
    },

    async loadCatalog() {
      if (this.catalogLoaded) return
      this.catalog = await listCarCatalog()
      this.catalogLoaded = true
    },

    async fetchOne(id: string): Promise<Car> {
      const existing = this.findById(id)
      if (existing) return existing
      return getCar(id)
    },

    async create(input: CarInsert, photo: File | null): Promise<Car> {
      const auth = useAuthStore()
      if (!auth.user) throw new Error('Not signed in')

      const isFirstCar = this.cars.length === 0
      const created = await createCar(auth.user.id, { ...input, is_active: isFirstCar })

      if (photo) {
        const path = await uploadCarPhoto(auth.user.id, created.id, photo)
        const updated = await updateCar(created.id, { photo_path: path })
        await this.refresh()
        return updated
      }

      await this.refresh()
      return created
    },

    async update(id: string, patch: CarUpdate, photo: File | null): Promise<Car> {
      const auth = useAuthStore()
      if (!auth.user) throw new Error('Not signed in')

      let updated = await updateCar(id, patch)
      if (photo) {
        const path = await uploadCarPhoto(auth.user.id, id, photo)
        updated = await updateCar(id, { photo_path: path })
      }
      await this.refresh()
      return updated
    },

    async remove(id: string) {
      await deleteCar(id)
      await this.refresh()
    },

    async makeActive(id: string) {
      const auth = useAuthStore()
      if (!auth.user) throw new Error('Not signed in')
      await setActiveCar(auth.user.id, id)
      await this.refresh()
    },
  },
})
