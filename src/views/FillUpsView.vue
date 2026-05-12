<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { useGarageStore } from '@/stores/garage'
import { useFillUpsStore } from '@/stores/fillups'
import { calculateConsumption } from '@/composables/useConsumption'

const garage = useGarageStore()
const fillups = useFillUpsStore()

const selectedCarId = ref<string>('')

const fillUpList = computed(() => fillups.forCar(selectedCarId.value))
const consumption = computed(() => calculateConsumption(fillUpList.value))
const car = computed(() => garage.findById(selectedCarId.value))

onMounted(async () => {
  if (garage.cars.length === 0) {
    try {
      await garage.refresh()
    } catch {
      // surface via store
    }
  }
  selectedCarId.value = garage.activeCar?.id ?? garage.cars[0]?.id ?? ''
})

watch(selectedCarId, async (id) => {
  if (!id) return
  try {
    await fillups.refresh(id)
  } catch {
    // surface via store
  }
})

function formatDate(iso: string): string {
  const d = new Date(iso)
  return d.toLocaleDateString(undefined, { day: '2-digit', month: 'short', year: 'numeric' })
}

function formatCost(amount: number | null, currency: string): string {
  if (amount == null) return '—'
  try {
    return new Intl.NumberFormat(undefined, { style: 'currency', currency }).format(amount)
  } catch {
    return `${amount.toFixed(2)} ${currency}`
  }
}
</script>

<template>
  <section class="px-4 py-6">
    <header class="mb-4 flex items-center justify-between gap-3">
      <h1 class="text-2xl font-bold">Fill-ups</h1>
      <RouterLink
        :to="{ path: '/fillups/new', query: selectedCarId ? { carId: selectedCarId } : {} }"
        class="rounded-md bg-brand-600 px-3 py-1.5 text-sm font-semibold text-white hover:bg-brand-700"
      >
        + Add
      </RouterLink>
    </header>

    <div
      v-if="garage.cars.length === 0"
      class="rounded-lg border border-dashed border-slate-300 bg-slate-50 px-6 py-12 text-center"
    >
      <p class="mb-3 text-sm text-slate-500">Add a car first.</p>
      <RouterLink
        to="/garage/new"
        class="rounded-md bg-brand-600 px-4 py-2 text-sm font-semibold text-white hover:bg-brand-700"
        >Go to Garage</RouterLink
      >
    </div>

    <template v-else>
      <label v-if="garage.cars.length > 1" class="mb-4 block">
        <span class="text-sm font-medium text-slate-700">Car</span>
        <select
          v-model="selectedCarId"
          class="mt-1 w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm focus:border-brand-500 focus:outline-none focus:ring-1 focus:ring-brand-500"
        >
          <option v-for="c in garage.cars" :key="c.id" :value="c.id">{{ c.name }}</option>
        </select>
      </label>

      <p
        v-if="fillups.error"
        class="mb-4 rounded-md bg-red-50 px-3 py-2 text-sm text-red-700"
      >
        {{ fillups.error }}
      </p>

      <div v-if="fillups.loadingCarId === selectedCarId" class="text-sm text-slate-500">
        Loading…
      </div>

      <div
        v-else-if="fillUpList.length === 0"
        class="rounded-lg border border-dashed border-slate-300 bg-slate-50 px-6 py-12 text-center text-sm text-slate-500"
      >
        No fill-ups yet for this car.
      </div>

      <ul v-else class="space-y-3">
        <li
          v-for="f in fillUpList"
          :key="f.id"
          class="rounded-lg bg-white p-3 ring-1 ring-slate-200"
        >
          <RouterLink :to="`/fillups/${f.id}`" class="flex items-center gap-3">
            <div class="flex-1 min-w-0">
              <div class="flex items-center justify-between gap-2">
                <p class="text-sm font-semibold">{{ formatDate(f.date) }}</p>
                <p class="text-sm font-semibold text-slate-900">
                  {{ formatCost(f.total_cost, f.currency) }}
                </p>
              </div>
              <p class="mt-0.5 text-xs text-slate-500">
                {{ Number(f.odometer).toFixed(1) }} {{ car?.distance_unit ?? 'km' }}
                · {{ Number(f.fuel_volume).toFixed(2) }} l
                <span v-if="f.fuel_price"> · {{ Number(f.fuel_price).toFixed(3) }}/l</span>
                <span v-if="!f.full_tank" class="ml-1 text-amber-600">· partial</span>
              </p>
              <p
                v-if="consumption[f.id]"
                class="mt-0.5 text-xs font-medium text-brand-600"
              >
                {{ consumption[f.id]!.l_100km.toFixed(2) }} l/100km
                <span class="text-slate-400">
                  over {{ consumption[f.id]!.distance.toFixed(0) }} km
                </span>
              </p>
            </div>
            <span class="text-slate-300">›</span>
          </RouterLink>
        </li>
      </ul>
    </template>
  </section>
</template>
