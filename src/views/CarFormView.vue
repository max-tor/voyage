<script setup lang="ts">
import { computed, onMounted, reactive, ref } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import CarSearch from '@/components/CarSearch.vue'
import PhotoPicker from '@/components/PhotoPicker.vue'
import { useGarageStore } from '@/stores/garage'
import { getCarPhotoUrl } from '@/services/cars'
import { FUEL_TYPE_LABELS, type CarCatalogEntry, type CarInsert } from '@/types/database'

const route = useRoute()
const router = useRouter()
const garage = useGarageStore()

const isEdit = computed(() => typeof route.params.id === 'string' && route.params.id !== 'new')
const carId = computed(() => (isEdit.value ? (route.params.id as string) : null))

const form = reactive<CarInsert>({
  name: '',
  make: null,
  model: null,
  year: null,
  description: null,
  photo_path: null,
  fuel_type: 'gasoline',
  tank_capacity_l: null,
  avg_consumption_l_100km: null,
  distance_unit: 'km',
  fuel_unit: 'l',
  consumption_unit: 'l_100km',
  is_active: false,
})

const photoFile = ref<File | null>(null)
const existingPhotoUrl = ref<string | null>(null)
const loading = ref(false)
const saving = ref(false)
const deleting = ref(false)
const error = ref<string | null>(null)

const fuelTypes = Object.entries(FUEL_TYPE_LABELS) as [keyof typeof FUEL_TYPE_LABELS, string][]

onMounted(async () => {
  loading.value = true
  try {
    await garage.loadCatalog()
    if (isEdit.value && carId.value) {
      const car = await garage.fetchOne(carId.value)
      Object.assign(form, {
        name: car.name,
        make: car.make,
        model: car.model,
        year: car.year,
        description: car.description,
        photo_path: car.photo_path,
        fuel_type: car.fuel_type,
        tank_capacity_l: car.tank_capacity_l,
        avg_consumption_l_100km: car.avg_consumption_l_100km,
        distance_unit: car.distance_unit,
        fuel_unit: car.fuel_unit,
        consumption_unit: car.consumption_unit,
        is_active: car.is_active,
      })
      existingPhotoUrl.value = getCarPhotoUrl(car.photo_path)
    }
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load'
  } finally {
    loading.value = false
  }
})

function applyCatalogEntry(entry: CarCatalogEntry) {
  form.make = entry.make
  form.model = entry.model
  if (entry.default_tank_l != null) form.tank_capacity_l = entry.default_tank_l
  if (entry.default_consumption_l_100km != null)
    form.avg_consumption_l_100km = entry.default_consumption_l_100km
  if (entry.default_fuel_type) form.fuel_type = entry.default_fuel_type
  if (!form.name) form.name = `${entry.make} ${entry.model}`
}

async function save() {
  error.value = null
  saving.value = true
  try {
    if (isEdit.value && carId.value) {
      await garage.update(carId.value, form, photoFile.value)
    } else {
      await garage.create(form, photoFile.value)
    }
    router.replace('/garage')
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Save failed'
  } finally {
    saving.value = false
  }
}

async function remove() {
  if (!carId.value) return
  if (!confirm('Delete this car? Fill-ups will remain but lose their car link.')) return
  deleting.value = true
  try {
    await garage.remove(carId.value)
    router.replace('/garage')
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Delete failed'
  } finally {
    deleting.value = false
  }
}
</script>

<template>
  <section class="px-4 py-6">
    <header class="mb-6 flex items-center justify-between">
      <h1 class="text-2xl font-bold">{{ isEdit ? 'Edit car' : 'Add car' }}</h1>
      <button
        type="button"
        class="text-sm text-slate-500 hover:text-slate-800"
        @click="router.back()"
      >
        Cancel
      </button>
    </header>

    <div v-if="loading" class="text-sm text-slate-500">Loading…</div>

    <form v-else class="space-y-6" @submit.prevent="save">
      <CarSearch :catalog="garage.catalog" @select="applyCatalogEntry" />

      <PhotoPicker :initial-url="existingPhotoUrl" @change="(f) => (photoFile = f)" />

      <fieldset class="space-y-4 rounded-lg bg-white p-4 ring-1 ring-slate-200">
        <label class="block">
          <span class="text-sm font-medium text-slate-700">Name</span>
          <input
            v-model="form.name"
            required
            type="text"
            class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          />
        </label>

        <div class="grid grid-cols-2 gap-3">
          <label class="block">
            <span class="text-sm font-medium text-slate-700">Make</span>
            <input
              v-model="form.make"
              type="text"
              class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            />
          </label>
          <label class="block">
            <span class="text-sm font-medium text-slate-700">Model</span>
            <input
              v-model="form.model"
              type="text"
              class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            />
          </label>
        </div>

        <label class="block">
          <span class="text-sm font-medium text-slate-700">Description</span>
          <input
            v-model="form.description"
            type="text"
            class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          />
        </label>
      </fieldset>

      <fieldset class="space-y-4 rounded-lg bg-white p-4 ring-1 ring-slate-200">
        <legend class="text-sm font-semibold text-slate-700">Units</legend>

        <div>
          <span class="text-sm font-medium text-slate-700">Distance unit</span>
          <div class="mt-2 flex overflow-hidden rounded-md ring-1 ring-slate-200">
            <button
              type="button"
              class="flex-1 px-3 py-2 text-sm"
              :class="
                form.distance_unit === 'km'
                  ? 'bg-white font-semibold'
                  : 'bg-slate-100 text-slate-500'
              "
              @click="form.distance_unit = 'km'"
            >
              Kilometres
            </button>
            <button
              type="button"
              class="flex-1 px-3 py-2 text-sm"
              :class="
                form.distance_unit === 'mi'
                  ? 'bg-white font-semibold'
                  : 'bg-slate-100 text-slate-500'
              "
              @click="form.distance_unit = 'mi'"
            >
              Miles
            </button>
          </div>
        </div>
      </fieldset>

      <fieldset class="space-y-4 rounded-lg bg-white p-4 ring-1 ring-slate-200">
        <legend class="text-sm font-semibold text-slate-700">Fuel</legend>

        <label class="block">
          <span class="text-sm font-medium text-slate-700">Fuel type</span>
          <select
            v-model="form.fuel_type"
            class="mt-1 w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          >
            <option v-for="[value, label] in fuelTypes" :key="value" :value="value">
              {{ label }}
            </option>
          </select>
        </label>

        <div class="grid grid-cols-2 gap-3">
          <label class="block">
            <span class="text-sm font-medium text-slate-700">Tank capacity (L)</span>
            <input
              v-model.number="form.tank_capacity_l"
              type="number"
              min="0"
              step="0.1"
              class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            />
          </label>
          <label class="block">
            <span class="text-sm font-medium text-slate-700">Avg consumption (l/100km)</span>
            <input
              v-model.number="form.avg_consumption_l_100km"
              type="number"
              min="0"
              step="0.1"
              class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            />
          </label>
        </div>
      </fieldset>

      <p v-if="error" class="text-sm text-red-600">{{ error }}</p>

      <div class="flex gap-3">
        <button
          type="submit"
          :disabled="saving"
          class="flex-1 rounded-md bg-brand-600 px-4 py-2 text-sm font-semibold text-white shadow-sm transition hover:bg-brand-700 disabled:opacity-50"
        >
          {{ saving ? 'Saving…' : 'Save' }}
        </button>
        <button
          v-if="isEdit"
          type="button"
          :disabled="deleting"
          class="rounded-md border border-red-200 bg-white px-4 py-2 text-sm font-semibold text-red-600 hover:bg-red-50 disabled:opacity-50"
          @click="remove"
        >
          {{ deleting ? 'Deleting…' : 'Delete' }}
        </button>
      </div>
    </form>
  </section>
</template>
