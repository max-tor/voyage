import { ref } from 'vue'

export interface UserLocation {
  lat: number
  lng: number
  accuracy: number
}

export function useGeolocation() {
  const location = ref<UserLocation | null>(null)
  const error = ref<string | null>(null)
  const loading = ref(false)

  async function locate(): Promise<UserLocation | null> {
    if (!('geolocation' in navigator)) {
      error.value = 'Geolocation is not supported by this browser'
      return null
    }
    loading.value = true
    error.value = null
    try {
      const pos = await new Promise<GeolocationPosition>((resolve, reject) => {
        navigator.geolocation.getCurrentPosition(resolve, reject, {
          enableHighAccuracy: true,
          timeout: 10000,
          maximumAge: 60000,
        })
      })
      const next: UserLocation = {
        lat: pos.coords.latitude,
        lng: pos.coords.longitude,
        accuracy: pos.coords.accuracy,
      }
      location.value = next
      return next
    } catch (e) {
      const err = e as GeolocationPositionError
      if (err.code === 1) error.value = 'Permission denied'
      else if (err.code === 2) error.value = 'Position unavailable'
      else if (err.code === 3) error.value = 'Timed out — try again'
      else error.value = 'Failed to get location'
      return null
    } finally {
      loading.value = false
    }
  }

  function setLocation(next: UserLocation) {
    location.value = next
    error.value = null
  }

  return { location, error, loading, locate, setLocation }
}
