<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useGarageStore } from '@/stores/garage'
import { useFillUpsStore } from '@/stores/fillups'
import {
  CURRENCIES,
  FUEL_TYPE_LABELS,
  type Currency,
  type FillUp,
  type FuelType,
} from '@/types/database'

const route = useRoute()
const router = useRouter()
const garage = useGarageStore()
const fillups = useFillUpsStore()

const isEdit = computed(() => typeof route.params.id === 'string' && route.params.id !== 'new')
const fillupId = computed(() => (isEdit.value ? (route.params.id as string) : null))

const carId = ref<string>('')
const odoInput = ref<number | null>(null)
const volume = ref<number | null>(null)
const fuelType = ref<FuelType>('gasoline')
const price = ref<number | null>(null)
const cost = ref<number | null>(null)
const currency = ref<Currency>('EUR')
const dateStr = ref(toLocalDate(new Date()))
const timeStr = ref(toLocalTime(new Date()))
const fullTank = ref(true)
const notes = ref<string>('')

const lastFillUp = ref<FillUp | null>(null)
const loading = ref(true)
const saving = ref(false)
const deleting = ref(false)
const error = ref<string | null>(null)

const editOrder = ref<('volume' | 'price' | 'cost')[]>([])

const fuelTypes = Object.entries(FUEL_TYPE_LABELS) as [FuelType, string][]
const car = computed(() => garage.findById(carId.value))
const distanceUnit = computed(() => car.value?.distance_unit ?? 'km')

const lastOdoHint = computed(() => {
  if (!lastFillUp.value) return null
  return `Last value: ${Number(lastFillUp.value.odometer).toFixed(1)} ${distanceUnit.value}`
})

watch(carId, async (newCarId, oldCarId) => {
  if (!newCarId || newCarId === oldCarId) return
  await loadLastFillUp(newCarId)
  if (car.value && !isEdit.value) {
    fuelType.value = car.value.fuel_type
  }
})

onMounted(async () => {
  loading.value = true
  try {
    if (garage.cars.length === 0) await garage.refresh()

    if (isEdit.value && fillupId.value) {
      const f = await fillups.fetchOne(fillupId.value)
      carId.value = f.car_id
      odoInput.value = Number(f.odometer)
      volume.value = Number(f.fuel_volume)
      fuelType.value = f.fuel_type
      price.value = f.fuel_price != null ? Number(f.fuel_price) : null
      cost.value = f.total_cost != null ? Number(f.total_cost) : null
      currency.value = (CURRENCIES as readonly string[]).includes(f.currency)
        ? (f.currency as Currency)
        : 'EUR'
      const d = new Date(f.date)
      dateStr.value = toLocalDate(d)
      timeStr.value = toLocalTime(d)
      fullTank.value = f.full_tank
      notes.value = f.notes ?? ''
      await loadLastFillUp(f.car_id, f.id)
    } else {
      const preselected = (route.query.carId as string | undefined) ?? garage.activeCar?.id
      if (preselected) carId.value = preselected
    }
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Failed to load'
  } finally {
    loading.value = false
  }
})

async function loadLastFillUp(theCarId: string, excludeId?: string) {
  const last = await fillups.getLastFor(theCarId)
  lastFillUp.value = last && last.id !== excludeId ? last : null
}

function pushEdit(field: 'volume' | 'price' | 'cost') {
  editOrder.value = [field, ...editOrder.value.filter((f) => f !== field)].slice(0, 2)
  recompute()
}

function setVolume(raw: string) {
  volume.value = parseNum(raw)
  pushEdit('volume')
}
function setPrice(raw: string) {
  price.value = parseNum(raw)
  pushEdit('price')
}
function setCost(raw: string) {
  cost.value = parseNum(raw)
  pushEdit('cost')
}

function recompute() {
  const recent = editOrder.value
  if (recent.length < 2) return
  const has = (f: string) => recent.includes(f as 'volume' | 'price' | 'cost')

  if (has('volume') && has('price')) {
    if (volume.value != null && price.value != null) {
      cost.value = round(volume.value * price.value, 2)
    }
  } else if (has('volume') && has('cost')) {
    if (volume.value && cost.value != null) {
      price.value = round(cost.value / volume.value, 3)
    }
  } else if (has('price') && has('cost')) {
    if (price.value && cost.value != null) {
      volume.value = round(cost.value / price.value, 2)
    }
  }
}

function parseNum(raw: string): number | null {
  const cleaned = raw.replace(',', '.').trim()
  if (!cleaned) return null
  const n = Number(cleaned)
  return Number.isFinite(n) ? n : null
}

function round(n: number, digits: number): number {
  const f = Math.pow(10, digits)
  return Math.round(n * f) / f
}

function toLocalDate(d: Date): string {
  const y = d.getFullYear()
  const m = String(d.getMonth() + 1).padStart(2, '0')
  const day = String(d.getDate()).padStart(2, '0')
  return `${y}-${m}-${day}`
}
function toLocalTime(d: Date): string {
  const h = String(d.getHours()).padStart(2, '0')
  const min = String(d.getMinutes()).padStart(2, '0')
  return `${h}:${min}`
}

function composeDate(): string {
  const [y, m, d] = dateStr.value.split('-').map(Number)
  const [hh, mm] = timeStr.value.split(':').map(Number)
  return new Date(y, m - 1, d, hh, mm).toISOString()
}

async function save() {
  error.value = null
  if (!carId.value) {
    error.value = 'Pick a car first'
    return
  }
  if (odoInput.value == null) {
    error.value = 'Enter the odometer value'
    return
  }
  const odometer = odoInput.value
  if (volume.value == null || volume.value <= 0) {
    error.value = 'Enter the fuel volume'
    return
  }

  const payload = {
    car_id: carId.value,
    date: composeDate(),
    odometer,
    fuel_volume: volume.value,
    fuel_type: fuelType.value,
    fuel_price: price.value,
    total_cost: cost.value,
    currency: currency.value,
    full_tank: fullTank.value,
    station_id: null,
    lat: null,
    lng: null,
    notes: notes.value || null,
  }

  saving.value = true
  try {
    if (isEdit.value && fillupId.value) {
      await fillups.update(fillupId.value, payload, carId.value)
    } else {
      await fillups.create(payload)
    }
    router.replace('/fillups')
  } catch (e) {
    error.value = e instanceof Error ? e.message : 'Save failed'
  } finally {
    saving.value = false
  }
}

async function remove() {
  if (!fillupId.value || !carId.value) return
  if (!confirm('Delete this fill-up?')) return
  deleting.value = true
  try {
    await fillups.remove(fillupId.value, carId.value)
    router.replace('/fillups')
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
      <h1 class="text-2xl font-bold">{{ isEdit ? 'Edit fill-up' : 'Add fill-up' }}</h1>
      <button type="button" class="text-sm text-slate-500 hover:text-slate-800" @click="router.back()">
        Cancel
      </button>
    </header>

    <div v-if="loading" class="text-sm text-slate-500">Loading…</div>

    <div
      v-else-if="garage.cars.length === 0"
      class="rounded-lg border border-dashed border-slate-300 bg-slate-50 px-6 py-8 text-center text-sm text-slate-500"
    >
      <p>Add a car in your Garage before logging a fill-up.</p>
      <RouterLink
        to="/garage/new"
        class="mt-3 inline-block rounded-md bg-brand-600 px-4 py-2 text-sm font-semibold text-white hover:bg-brand-700"
        >Go to Garage</RouterLink
      >
    </div>

    <form v-else class="space-y-6" @submit.prevent="save">
      <fieldset class="space-y-4 rounded-lg bg-white p-4 ring-1 ring-slate-200">
        <label class="block">
          <span class="text-sm font-medium text-slate-700">Car</span>
          <select
            v-model="carId"
            class="mt-1 w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          >
            <option v-for="c in garage.cars" :key="c.id" :value="c.id">{{ c.name }}</option>
          </select>
        </label>
      </fieldset>

      <fieldset class="space-y-4 rounded-lg bg-white p-4 ring-1 ring-slate-200">
        <label class="block">
          <span class="text-sm font-medium text-slate-700"
            >Odo counter ({{ distanceUnit }})</span
          >
          <input
            v-model.number="odoInput"
            type="number"
            min="0"
            step="0.1"
            inputmode="decimal"
            class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          />
          <span v-if="lastOdoHint" class="mt-1 block text-xs text-slate-400">{{ lastOdoHint }}</span>
        </label>

        <div class="grid grid-cols-2 gap-3">
          <label class="block">
            <span class="text-sm font-medium text-slate-700">Fuel (l)</span>
            <input
              :value="volume ?? ''"
              type="number"
              min="0"
              step="0.01"
              inputmode="decimal"
              class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
              @input="setVolume(($event.target as HTMLInputElement).value)"
            />
          </label>
          <label class="block">
            <span class="text-sm font-medium text-slate-700">Fuel type</span>
            <select
              v-model="fuelType"
              class="mt-1 w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
            >
              <option v-for="[value, label] in fuelTypes" :key="value" :value="value">
                {{ label }}
              </option>
            </select>
          </label>
        </div>

        <div class="grid grid-cols-2 gap-3">
          <label class="block">
            <span class="text-sm font-medium text-slate-700">Fuel price</span>
            <input
              :value="price ?? ''"
              type="number"
              min="0"
              step="0.001"
              inputmode="decimal"
              class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
              @input="setPrice(($event.target as HTMLInputElement).value)"
            />
          </label>
          <label class="block">
            <span class="text-sm font-medium text-slate-700">Total cost</span>
            <input
              :value="cost ?? ''"
              type="number"
              min="0"
              step="0.01"
              inputmode="decimal"
              class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
              @input="setCost(($event.target as HTMLInputElement).value)"
            />
          </label>
        </div>
        <p class="text-xs text-slate-400">
          Enter any two of volume, price, total — the third is calculated.
        </p>
      </fieldset>

      <fieldset class="rounded-lg bg-white p-4 ring-1 ring-slate-200">
        <label class="block">
          <span class="text-sm font-medium text-slate-700">Currency</span>
          <select
            v-model="currency"
            class="mt-1 w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          >
            <option v-for="c in CURRENCIES" :key="c" :value="c">{{ c }}</option>
          </select>
        </label>
      </fieldset>

      <fieldset class="rounded-lg bg-white p-4 ring-1 ring-slate-200">
        <legend class="text-sm font-semibold text-slate-700">Date</legend>
        <div class="mt-3 flex gap-3">
          <input
            v-model="dateStr"
            type="date"
            class="flex-1 rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          />
          <input
            v-model="timeStr"
            type="time"
            class="w-32 rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          />
        </div>
      </fieldset>

      <fieldset class="rounded-lg bg-white p-4 ring-1 ring-slate-200">
        <label class="flex items-center justify-between">
          <span class="text-sm font-medium text-slate-700">Full tank</span>
          <span class="relative inline-flex items-center">
            <input v-model="fullTank" type="checkbox" class="peer sr-only" />
            <span
              class="h-6 w-11 rounded-full bg-slate-300 transition-colors peer-checked:bg-emerald-500"
            ></span>
            <span
              class="absolute left-0.5 top-0.5 h-5 w-5 rounded-full bg-white shadow transition-transform peer-checked:translate-x-5"
            ></span>
          </span>
        </label>
      </fieldset>

      <fieldset class="rounded-lg bg-white p-4 ring-1 ring-slate-200">
        <label class="block">
          <span class="text-sm font-medium text-slate-700">Notes</span>
          <input
            v-model="notes"
            type="text"
            placeholder="Optional"
            class="mt-1 w-full rounded-md border border-slate-300 px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
          />
        </label>
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
