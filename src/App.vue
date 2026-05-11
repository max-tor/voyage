<script setup lang="ts">
import { computed } from 'vue'
import { useRoute } from 'vue-router'
import TabBar from '@/components/TabBar.vue'
import { useAuthStore } from '@/stores/auth'

const route = useRoute()
const auth = useAuthStore()

const showTabs = computed(() => auth.isAuthenticated && !route.meta.hideTabs)
</script>

<template>
  <div class="flex h-full flex-col">
    <main class="flex-1 overflow-y-auto pb-20">
      <RouterView />
    </main>
    <TabBar v-if="showTabs" />
  </div>
</template>
