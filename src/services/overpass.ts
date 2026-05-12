export interface OverpassStation {
  osm_id: string
  lat: number
  lng: number
  name: string | null
  brand: string | null
  operator: string | null
  address: string | null
}

interface OverpassResponse {
  elements: Array<{
    type: 'node' | 'way' | 'relation'
    id: number
    lat?: number
    lon?: number
    center?: { lat: number; lon: number }
    tags?: Record<string, string>
  }>
}

const ENDPOINT = 'https://overpass-api.de/api/interpreter'

/**
 * Fetch amenity=fuel POIs around a point.
 * @param lat   Latitude in decimal degrees
 * @param lng   Longitude in decimal degrees
 * @param radiusMeters Max radius to query
 */
export async function fetchStationsAround(
  lat: number,
  lng: number,
  radiusMeters = 50000,
): Promise<OverpassStation[]> {
  const query = `[out:json][timeout:25];
(
  node["amenity"="fuel"](around:${radiusMeters},${lat},${lng});
  way["amenity"="fuel"](around:${radiusMeters},${lat},${lng});
);
out center tags;`

  const res = await fetch(ENDPOINT, {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: `data=${encodeURIComponent(query)}`,
  })

  if (!res.ok) throw new Error(`Overpass error ${res.status}`)
  const json = (await res.json()) as OverpassResponse

  return json.elements.flatMap((el) => {
    const point = el.type === 'node' ? { lat: el.lat, lng: el.lon } : el.center
      ? { lat: el.center.lat, lng: el.center.lon }
      : null
    if (!point || point.lat == null || point.lng == null) return []

    const tags = el.tags ?? {}
    const addressParts = [
      tags['addr:housenumber'],
      tags['addr:street'],
      tags['addr:postcode'],
      tags['addr:city'],
    ].filter(Boolean)

    return [
      {
        osm_id: `${el.type[0]}${el.id}`,
        lat: point.lat,
        lng: point.lng,
        name: tags.name ?? null,
        brand: tags.brand ?? tags['brand:wikidata'] ?? null,
        operator: tags.operator ?? null,
        address: addressParts.length > 0 ? addressParts.join(', ') : null,
      },
    ]
  })
}

export function distanceKm(
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number,
): number {
  const R = 6371
  const toRad = (d: number) => (d * Math.PI) / 180
  const dLat = toRad(lat2 - lat1)
  const dLng = toRad(lng2 - lng1)
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2
  return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
}
