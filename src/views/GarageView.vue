<script setup lang="ts">
import { onMounted } from 'vue'
import { RouterLink } from 'vue-router'
import { Car, ChevronRight, Plus } from 'lucide-vue-next'
import { useGarageStore } from '@/stores/garage'
import { getCarPhotoUrl } from '@/services/cars'
import { FUEL_TYPE_LABELS } from '@/types/database'

const garage = useGarageStore()

onMounted(async () => {
  try {
    await garage.refresh()
  } catch {
    // error surfaced via garage.error
  }
})

async function makeActive(id: string) {
  try {
    await garage.makeActive(id)
  } catch {
    // surface via store error
  }
}
</script>

<template>
  <section class="mx-auto max-w-2xl px-4 py-6">
    <header class="mb-6 flex items-center justify-between">
      <div>
        <h1 class="text-2xl font-bold tracking-tight text-slate-900 dark:text-slate-100">Garage</h1>
        <p class="mt-0.5 text-sm text-slate-500 dark:text-slate-400">
          Your vehicles, ready to track.
        </p>
      </div>
      <RouterLink
        to="/garage/new"
        class="inline-flex items-center gap-1 rounded-xl bg-brand-600 px-3 py-2 text-sm font-semibold text-white shadow-glow-brand transition-all hover:bg-brand-700 active:scale-[0.98]"
      >
        <Plus :size="14" />
        Add car
      </RouterLink>
    </header>

    <p
      v-if="garage.error"
      class="mb-4 rounded-xl bg-red-50 px-3 py-2 text-sm text-red-700 dark:bg-red-950/40 dark:text-red-300"
    >
      {{ garage.error }}
    </p>

    <div v-if="garage.loading" class="text-sm text-slate-500 dark:text-slate-400">Loading…</div>

    <div
      v-else-if="garage.cars.length === 0"
      class="flex flex-col items-center gap-4 rounded-2xl border border-dashed border-slate-200 bg-white/60 px-6 py-16 text-center dark:border-slate-800 dark:bg-slate-900/40"
    >
      <div
        class="grid h-12 w-12 place-items-center rounded-2xl bg-brand-50 text-brand-600 dark:bg-brand-900/40 dark:text-brand-300"
      >
        <Car :size="24" />
      </div>
      <div>
        <p class="font-semibold text-slate-900 dark:text-slate-100">No cars yet</p>
        <p class="mt-1 text-sm text-slate-500 dark:text-slate-400">
          Add one to start logging fill-ups.
        </p>
      </div>
      <RouterLink
        to="/garage/new"
        class="rounded-xl bg-brand-600 px-4 py-2.5 text-sm font-semibold text-white shadow-glow-brand transition-all hover:bg-brand-700 active:scale-[0.98]"
      >
        Add your first car
      </RouterLink>
    </div>

    <ul v-else class="space-y-3">
      <li
        v-for="car in garage.cars"
        :key="car.id"
        class="flex items-center gap-3 rounded-2xl bg-white p-3 shadow-soft ring-1 transition-shadow hover:shadow-soft-md dark:bg-slate-900"
        :class="
          car.is_active
            ? 'ring-brand-500/40 dark:ring-brand-400/40'
            : 'ring-slate-900/5 dark:ring-white/10'
        "
      >
        <div
          class="h-14 w-14 shrink-0 overflow-hidden rounded-xl bg-slate-100 dark:bg-slate-800"
        >
          <img
            v-if="car.photo_path"
            :src="getCarPhotoUrl(car.photo_path) ?? ''"
            alt=""
            class="h-full w-full object-cover"
          />
          <div
            v-else
            class="flex h-full w-full items-center justify-center text-slate-300 dark:text-slate-600"
          >
            <Car :size="22" />
          </div>
        </div>

        <div class="min-w-0 flex-1">
          <div class="flex items-center gap-2">
            <p class="truncate font-semibold text-slate-900 dark:text-slate-100">{{ car.name }}</p>
            <span
              v-if="car.is_active"
              class="rounded-full bg-brand-50 px-2 py-0.5 text-[10px] font-semibold uppercase tracking-wider text-brand-700 dark:bg-brand-900/40 dark:text-brand-300"
              >Active</span
            >
          </div>
          <p class="truncate text-xs text-slate-500 dark:text-slate-400">
            <span v-if="car.make || car.model">{{ car.make }} {{ car.model }} · </span>
            {{ FUEL_TYPE_LABELS[car.fuel_type] }}
            <span v-if="car.tank_capacity_l"> · {{ car.tank_capacity_l }} L tank</span>
          </p>
        </div>

        <div class="flex flex-col items-end gap-1.5">
          <RouterLink
            :to="`/garage/${car.id}`"
            class="inline-flex items-center gap-0.5 text-xs font-semibold text-brand-600 hover:text-brand-700 dark:text-brand-300 dark:hover:text-brand-200"
          >
            Edit
            <ChevronRight :size="12" />
          </RouterLink>
          <button
            v-if="!car.is_active"
            type="button"
            class="text-xs text-slate-500 hover:text-slate-900 dark:text-slate-400 dark:hover:text-slate-100"
            @click="makeActive(car.id)"
          >
            Set active
          </button>
        </div>
      </li>
    </ul>
  </section>
</template>
