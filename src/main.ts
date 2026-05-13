import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import { useThemeStore } from './stores/theme'

import './style.css'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

// Apply the theme synchronously before mount to avoid a flash of the wrong
// palette on hard refresh.
useThemeStore().init()

router.isReady().then(() => {
  app.mount('#app')
})
