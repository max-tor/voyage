<script setup lang="ts">
import { computed, onMounted, ref, watch } from 'vue'
import { RouterLink } from 'vue-router'
import { ChevronRight, Fuel, Plus } from 'lucide-vue-next'
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
  <section class="mx-auto max-w-2xl px-4 py-6">
    <header class="mb-6 flex items-center justify-between gap-3">
      <div>
        <h1 class="text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">
          Fill-ups
        </h1>
        <p class="mt-0.5 text-sm text-slate-500 dark:text-slate-400">
          Your fuel log and consumption.
        </p>
      </div>
      <RouterLink
        :to="{ path: '/fillups/new', query: selectedCarId ? { carId: selectedCarId } : {} }"
        class="inline-flex items-center gap-1 rounded-xl bg-brand-600 px-3 py-2 text-sm font-semibold text-white shadow-glow-brand transition-all hover:bg-brand-700 active:scale-[0.98]"
      >
        <Plus :size="14" />
        Add
      </RouterLink>
    </header>

    <div
      v-if="garage.cars.length === 0"
      class="flex flex-col items-center gap-4 rounded-2xl border border-dashed border-slate-200 bg-white/60 px-6 py-16 text-center dark:border-slate-800 dark:bg-slate-900/40"
    >
      <div
        class="grid h-12 w-12 place-items-center rounded-2xl bg-brand-50 text-brand-600 dark:bg-brand-900/40 dark:text-brand-300"
      >
        <Fuel :size="22" />
      </div>
      <p class="text-sm text-slate-500 dark:text-slate-400">Add a car first.</p>
      <RouterLink
        to="/garage/new"
        class="rounded-xl bg-brand-600 px-4 py-2.5 text-sm font-semibold text-white shadow-glow-brand transition-all hover:bg-brand-700 active:scale-[0.98]"
        >Go to Garage</RouterLink
      >
    </div>

    <template v-else>
      <label v-if="garage.cars.length > 1" class="mb-4 block">
        <span class="text-sm font-medium text-slate-700 dark:text-slate-300">Car</span>
        <select
          v-model="selectedCarId"
          class="mt-1.5 w-full rounded-xl border border-slate-200 bg-white px-3 py-2.5 text-sm shadow-soft focus:border-brand-500 focus:outline-none focus:ring-2 focus:ring-brand-500/30 dark:border-slate-700 dark:bg-slate-900 dark:text-slate-100"
        >
          <option v-for="c in garage.cars" :key="c.id" :value="c.id">{{ c.name }}</option>
        </select>
      </label>

      <p
        v-if="fillups.error"
        class="mb-4 rounded-xl bg-red-50 px-3 py-2 text-sm text-red-700 dark:bg-red-950/40 dark:text-red-300"
      >
        {{ fillups.error }}
      </p>

      <div
        v-if="fillups.loadingCarId === selectedCarId"
        class="text-sm text-slate-500 dark:text-slate-400"
      >
        Loading…
      </div>

      <div
        v-else-if="fillUpList.length === 0"
        class="flex flex-col items-center gap-3 rounded-2xl border border-dashed border-slate-200 bg-white/60 px-6 py-16 text-center dark:border-slate-800 dark:bg-slate-900/40"
      >
        <div
          class="grid h-12 w-12 place-items-center rounded-2xl bg-brand-50 text-brand-600 dark:bg-brand-900/40 dark:text-brand-300"
        >
          <Fuel :size="22" />
        </div>
        <p class="text-sm text-slate-500 dark:text-slate-400">No fill-ups yet for this car.</p>
      </div>

      <ul v-else class="space-y-3">
        <li
          v-for="f in fillUpList"
          :key="f.id"
          class="rounded-2xl bg-white p-3.5 shadow-soft ring-1 ring-slate-900/5 transition-shadow hover:shadow-soft-md dark:bg-slate-900 dark:ring-white/10"
        >
          <RouterLink :to="`/fillups/${f.id}`" class="flex items-center gap-3">
            <div class="flex-1 min-w-0">
              <div class="flex items-center justify-between gap-2">
                <p class="text-sm font-semibold text-slate-900 dark:text-slate-100">
                  {{ formatDate(f.date) }}
                </p>
                <p class="text-sm font-semibold text-slate-900 dark:text-slate-100">
                  {{ formatCost(f.total_cost, f.currency) }}
                </p>
              </div>
              <p class="mt-1 text-xs text-slate-500 dark:text-slate-400">
                {{ Number(f.odometer).toFixed(1) }} {{ car?.distance_unit ?? 'km' }}
                · {{ Number(f.fuel_volume).toFixed(2) }} l
                <span v-if="f.fuel_price"> · {{ Number(f.fuel_price).toFixed(3) }}/l</span>
                <span
                  v-if="!f.full_tank"
                  class="ml-1 rounded-full bg-amber-100 px-1.5 py-0.5 text-[10px] font-semibold text-amber-700 dark:bg-amber-500/15 dark:text-amber-300"
                  >Partial</span
                >
              </p>
              <p
                v-if="consumption[f.id]"
                class="mt-1 text-xs font-semibold text-brand-600 dark:text-brand-300"
              >
                {{ consumption[f.id]!.l_100km.toFixed(2) }} l/100km
                <span class="font-normal text-slate-400 dark:text-slate-500">
                  over {{ consumption[f.id]!.distance.toFixed(0) }} km
                </span>
              </p>
            </div>
            <ChevronRight :size="16" class="shrink-0 text-slate-300 dark:text-slate-600" />
          </RouterLink>
        </li>
      </ul>
    </template>
  </section>
</template>
