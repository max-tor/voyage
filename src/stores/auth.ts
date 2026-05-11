import { defineStore } from 'pinia'
import type { Session, User } from '@supabase/supabase-js'
import { supabase } from '@/services/supabase'

interface AuthState {
  user: User | null
  session: Session | null
  ready: boolean
}

export const useAuthStore = defineStore('auth', {
  state: (): AuthState => ({
    user: null,
    session: null,
    ready: false,
  }),
  getters: {
    isAuthenticated: (s) => s.user !== null,
  },
  actions: {
    async init() {
      const { data } = await supabase.auth.getSession()
      this.session = data.session
      this.user = data.session?.user ?? null

      supabase.auth.onAuthStateChange((_event, session) => {
        this.session = session
        this.user = session?.user ?? null
      })

      this.ready = true
    },
    async signUp(email: string, password: string) {
      const { data, error } = await supabase.auth.signUp({ email, password })
      if (error) throw error
      this.session = data.session
      this.user = data.user
      return data
    },
    async signIn(email: string, password: string) {
      const { data, error } = await supabase.auth.signInWithPassword({ email, password })
      if (error) throw error
      this.session = data.session
      this.user = data.user
      return data
    },
    async signOut() {
      const { error } = await supabase.auth.signOut()
      if (error) throw error
      this.session = null
      this.user = null
    },
  },
})
