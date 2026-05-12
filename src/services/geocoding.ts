export interface GeocodeResult {
  lat: number
  lng: number
  displayName: string
  type: string | null
  importance: number
}

interface NominatimRow {
  lat: string
  lon: string
  display_name: string
  type: string | null
  importance: number
}

const ENDPOINT = 'https://nominatim.openstreetmap.org/search'

/**
 * Forward-geocode a free-text query (city, address, landmark) via Nominatim.
 * Nominatim usage policy asks for ≤ 1 req/sec — callers should debounce.
 */
export async function geocodeSearch(query: string): Promise<GeocodeResult[]> {
  const q = query.trim()
  if (q.length < 2) return []

  const params = new URLSearchParams({
    q,
    format: 'json',
    limit: '6',
    'accept-language': 'en',
  })

  const res = await fetch(`${ENDPOINT}?${params}`)
  if (!res.ok) throw new Error(`Nominatim HTTP ${res.status}`)
  const rows = (await res.json()) as NominatimRow[]

  return rows
    .map((r) => ({
      lat: Number(r.lat),
      lng: Number(r.lon),
      displayName: r.display_name,
      type: r.type,
      importance: r.importance,
    }))
    .filter((r) => Number.isFinite(r.lat) && Number.isFinite(r.lng))
}
