<script setup lang="ts">
import { ref, watch } from 'vue'

const props = defineProps<{ initialUrl?: string | null }>()
const emit = defineEmits<{ change: [File | null] }>()

const fileInput = ref<HTMLInputElement | null>(null)
const previewUrl = ref<string | null>(props.initialUrl ?? null)
const objectUrl = ref<string | null>(null)

watch(
  () => props.initialUrl,
  (url) => {
    if (!objectUrl.value) previewUrl.value = url ?? null
  },
)

function open() {
  fileInput.value?.click()
}

function onPick(e: Event) {
  const file = (e.target as HTMLInputElement).files?.[0] ?? null
  if (objectUrl.value) {
    URL.revokeObjectURL(objectUrl.value)
    objectUrl.value = null
  }
  if (file) {
    objectUrl.value = URL.createObjectURL(file)
    previewUrl.value = objectUrl.value
  } else {
    previewUrl.value = props.initialUrl ?? null
  }
  emit('change', file)
}

function clear() {
  if (objectUrl.value) URL.revokeObjectURL(objectUrl.value)
  objectUrl.value = null
  previewUrl.value = props.initialUrl ?? null
  if (fileInput.value) fileInput.value.value = ''
  emit('change', null)
}
</script>

<template>
  <div class="flex items-center gap-4">
    <div
      class="flex h-24 w-24 shrink-0 items-center justify-center overflow-hidden rounded-lg border border-slate-200 bg-slate-100 text-xs text-slate-400"
    >
      <img v-if="previewUrl" :src="previewUrl" alt="Car photo" class="h-full w-full object-cover" />
      <span v-else>No photo</span>
    </div>
    <div class="flex flex-col gap-2">
      <button
        type="button"
        class="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm font-medium hover:bg-slate-50"
        @click="open"
      >
        {{ previewUrl ? 'Change photo' : 'Add photo' }}
      </button>
      <button
        v-if="objectUrl"
        type="button"
        class="text-left text-xs text-slate-500 underline hover:text-slate-700"
        @click="clear"
      >
        Remove selected
      </button>
    </div>
    <input
      ref="fileInput"
      type="file"
      accept="image/*"
      capture="environment"
      class="hidden"
      @change="onPick"
    />
  </div>
</template>
