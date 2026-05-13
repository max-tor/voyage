import { defineStore } from 'pinia'

export type ThemePreference = 'light' | 'dark' | 'system'

const STORAGE_KEY = 'voyage:theme'

interface ThemeState {
  preference: ThemePreference
  systemDark: boolean
}

function readPreference(): ThemePreference {
  if (typeof localStorage === 'undefined') return 'system'
  const raw = localStorage.getItem(STORAGE_KEY)
  if (raw === 'light' || raw === 'dark' || raw === 'system') return raw
  return 'system'
}

function readSystemDark(): boolean {
  if (typeof window === 'undefined' || !window.matchMedia) return false
  return window.matchMedia('(prefers-color-scheme: dark)').matches
}

export const useThemeStore = defineStore('theme', {
  state: (): ThemeState => ({
    preference: readPreference(),
    systemDark: readSystemDark(),
  }),
  getters: {
    /** What the user actually sees right now — resolves "system". */
    resolved: (s): 'light' | 'dark' =>
      s.preference === 'system' ? (s.systemDark ? 'dark' : 'light') : s.preference,
  },
  actions: {
    init() {
      this.apply()
      if (typeof window !== 'undefined' && window.matchMedia) {
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
          this.systemDark = e.matches
          this.apply()
        })
      }
    },
    set(pref: ThemePreference) {
      this.preference = pref
      if (typeof localStorage !== 'undefined') localStorage.setItem(STORAGE_KEY, pref)
      this.apply()
    },
    apply() {
      if (typeof document === 'undefined') return
      document.documentElement.classList.toggle('dark', this.resolved === 'dark')
    },
  },
})
