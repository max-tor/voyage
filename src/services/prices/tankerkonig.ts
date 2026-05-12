import type { MapStation, StationPriceData } from '@/types/prices'

const ENDPOINT = 'https://creativecommons.tankerkoenig.de/json/list.php'

interface TankerkonigStation {
  id: string
  name: string
  brand: string
  street: string
  place: string
  lat: number
  lng: number
  dist: number
  e5?: number | false
  e10?: number | false
  diesel?: number | false
  isOpen: boolean
}

interface TankerkonigResponse {
  ok: boolean
  message?: string
  stations: TankerkonigStation[]
}

/**
 * Fetch German fuel stations with live prices.
 * Radius is in kilometres, capped to 25 by the API.
 */
export async function fetchTankerkonigStations(
  lat: number,
  lng: number,
  radiusKm: number,
  apiKey: string,
): Promise<MapStation[]> {
  const r = Math.min(Math.max(radiusKm, 1), 25)
  const url = `${ENDPOINT}?lat=${lat}&lng=${lng}&rad=${r}&sort=dist&type=all&apikey=${apiKey}`
  const res = await fetch(url)
  if (!res.ok) throw new Error(`TankerKönig HTTP ${res.status}`)
  const data = (await res.json()) as TankerkonigResponse
  if (!data.ok) throw new Error(data.message ?? 'TankerKönig error')

  const reportedAt = new Date().toISOString()

  return data.stations.map((s) => {
    const price: StationPriceData = {
      currency: 'EUR',
      reportedAt,
      source: 'tankerkoenig.de',
    }
    if (typeof s.e5 === 'number') price.e5 = s.e5
    if (typeof s.e10 === 'number') price.e10 = s.e10
    if (typeof s.diesel === 'number') price.diesel = s.diesel

    return {
      osm_id: `tk-${s.id}`,
      lat: s.lat,
      lng: s.lng,
      name: s.name || null,
      brand: s.brand || null,
      operator: null,
      address: [s.street, s.place].filter(Boolean).join(', ') || null,
      prices: price.e5 != null || price.e10 != null || price.diesel != null ? price : undefined,
    }
  })
}
