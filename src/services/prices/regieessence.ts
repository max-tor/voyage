import type { MapStation, StationPriceData } from '@/types/prices'
import { distanceKm } from '@/services/overpass'

// Régie essence Québec — every gas station in Quebec is legally required
// (Article 67.1, Petroleum Products Act) to report current prices since
// April 1, 2026. The Régie de l'énergie publishes the entire dataset as a
// single gzipped GeoJSON file refreshed multiple times per day.
// No API key, no rate limits, public open data.

const DATA_URL = 'https://regieessencequebec.ca/stations.geojson.gz'
const CACHE_TTL_MS = 15 * 60 * 1000

interface RegieFeature {
  type: 'Feature'
  geometry: { type: 'Point'; coordinates: [number, number] }
  properties: {
    Name: string
    brand: string | null
    Status: string | null
    Address: string | null
    PostalCode: string | null
    Region: string | null
    Prices: Array<{
      GasType: string
      Price: string | null
      IsAvailable: boolean
    }>
  }
}

interface RegieGeoJson {
  type: 'FeatureCollection'
  metadata: { generated_at: string; total_stations: number }
  features: RegieFeature[]
}

interface CachedData {
  data: RegieGeoJson
  fetchedAt: number
}

let cache: CachedData | null = null
let inFlight: Promise<RegieGeoJson> | null = null

async function loadDataset(): Promise<RegieGeoJson> {
  const now = Date.now()
  if (cache && now - cache.fetchedAt < CACHE_TTL_MS) return cache.data
  if (inFlight) return inFlight

  inFlight = (async () => {
    // fetch decompresses gzip automatically when Content-Encoding is set.
    const res = await fetch(DATA_URL)
    if (!res.ok) throw new Error(`Régie essence HTTP ${res.status}`)
    const data = (await res.json()) as RegieGeoJson
    cache = { data, fetchedAt: Date.now() }
    return data
  })()

  try {
    return await inFlight
  } finally {
    inFlight = null
  }
}

function parsePriceCents(raw: string | null): number | null {
  if (!raw) return null
  // Format: "199.9¢" — price in cents per litre. We store $/L.
  const m = raw.match(/([0-9]+(?:[.,][0-9]+)?)/)
  if (!m) return null
  const cents = Number(m[1].replace(',', '.'))
  if (!Number.isFinite(cents)) return null
  return cents / 100
}

/**
 * Fetch fuel stations + prices around a Quebec location.
 * @param radiusKm — filter the full provincial dataset to this radius.
 */
export async function fetchRegieStations(
  lat: number,
  lng: number,
  radiusKm = 25,
): Promise<MapStation[]> {
  const dataset = await loadDataset()
  const reportedAt = dataset.metadata.generated_at

  const out: MapStation[] = []
  for (const f of dataset.features) {
    if (f.properties.Status && !/op[ée]ration/i.test(f.properties.Status)) continue
    const [lng2, lat2] = f.geometry.coordinates
    if (distanceKm(lat, lng, lat2, lng2) > radiusKm) continue

    const prices: StationPriceData = {
      currency: 'CAD',
      reportedAt,
      source: 'regieessencequebec.ca',
    }
    for (const p of f.properties.Prices ?? []) {
      if (!p.IsAvailable) continue
      const value = parsePriceCents(p.Price)
      if (value == null) continue
      if (/r[ée]gulier/i.test(p.GasType)) prices.e5 = value
      else if (/diesel/i.test(p.GasType)) prices.diesel = value
      // "Super" (premium 91+) is reported by stations but does not map to
      // our current FuelKind enum; ignored for now.
    }

    const hasPrice = prices.e5 != null || prices.diesel != null

    out.push({
      osm_id: `regie-${f.properties.PostalCode ?? ''}-${lat2}-${lng2}`,
      lat: lat2,
      lng: lng2,
      name: f.properties.Name || null,
      brand: f.properties.brand || null,
      operator: null,
      address: f.properties.Address || null,
      prices: hasPrice ? prices : undefined,
    })
  }

  return out
}
