<script setup lang="ts">
import { onMounted } from 'vue'
import { RouterLink } from 'vue-router'
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
  <section class="px-4 py-6">
    <header class="mb-4 flex items-center justify-between">
      <h1 class="text-2xl font-bold">Garage</h1>
      <RouterLink
        to="/garage/new"
        class="rounded-md bg-brand-600 px-3 py-1.5 text-sm font-semibold text-white hover:bg-brand-700"
      >
        + Add car
      </RouterLink>
    </header>

    <p v-if="garage.error" class="mb-4 rounded-md bg-red-50 px-3 py-2 text-sm text-red-700">
      {{ garage.error }}
    </p>

    <div v-if="garage.loading" class="text-sm text-slate-500">Loading…</div>

    <div
      v-else-if="garage.cars.length === 0"
      class="flex flex-col items-center gap-3 rounded-lg border border-dashed border-slate-300 bg-slate-50 px-6 py-12 text-center"
    >
      <p class="text-sm text-slate-500">No cars yet.</p>
      <RouterLink
        to="/garage/new"
        class="rounded-md bg-brand-600 px-4 py-2 text-sm font-semibold text-white hover:bg-brand-700"
      >
        Add your first car
      </RouterLink>
    </div>

    <ul v-else class="space-y-3">
      <li
        v-for="car in garage.cars"
        :key="car.id"
        class="flex items-center gap-3 rounded-lg bg-white p-3 ring-1"
        :class="car.is_active ? 'ring-brand-500' : 'ring-slate-200'"
      >
        <div class="h-14 w-14 shrink-0 overflow-hidden rounded-md bg-slate-100">
          <img
            v-if="car.photo_path"
            :src="getCarPhotoUrl(car.photo_path) ?? ''"
            alt=""
            class="h-full w-full object-cover"
          />
          <div
            v-else
            class="flex h-full w-full items-center justify-center text-xl text-slate-400"
          >
            🚗
          </div>
        </div>

        <div class="min-w-0 flex-1">
          <div class="flex items-center gap-2">
            <p class="truncate font-semibold">{{ car.name }}</p>
            <span
              v-if="car.is_active"
              class="rounded-full bg-brand-100 px-2 py-0.5 text-xs font-medium text-brand-700"
              >Active</span
            >
          </div>
          <p class="truncate text-xs text-slate-500">
            <span v-if="car.make || car.model">{{ car.make }} {{ car.model }} · </span>
            {{ FUEL_TYPE_LABELS[car.fuel_type] }}
            <span v-if="car.tank_capacity_l"> · {{ car.tank_capacity_l }} L tank</span>
          </p>
        </div>

        <div class="flex flex-col items-end gap-1">
          <RouterLink
            :to="`/garage/${car.id}`"
            class="text-xs font-medium text-brand-600 hover:underline"
            >Edit</RouterLink
          >
          <button
            v-if="!car.is_active"
            type="button"
            class="text-xs text-slate-500 hover:text-slate-800"
            @click="makeActive(car.id)"
          >
            Set active
          </button>
        </div>
      </li>
    </ul>
  </section>
</template>
