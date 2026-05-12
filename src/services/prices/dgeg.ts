import type { MapStation, StationPriceData } from '@/types/prices'
import { distanceKm } from '@/services/overpass'

// Portugal — Direção-Geral de Energia e Geologia (DGEG)
// Official open data behind precoscombustiveis.dgeg.gov.pt.
// API queries stations by district, not radius — we pick the closest few
// districts to the user, fetch in parallel for the fuel kinds we care about,
// then haversine-filter to the requested radius.

const ENDPOINT = 'https://precoscombustiveis.dgeg.gov.pt/api/PrecoComb/PesquisarPostos'

const FUEL_TYPE_IDS = {
  e5: 3201, // Gasolina simples 95 — closest match for E5
  diesel: 2101, // Gasóleo simples
  // Portugal mostly skips E10; no DGEG id for it
} as const

interface DistrictCentroid {
  id: number
  name: string
  lat: number
  lng: number
}

const MAINLAND_DISTRICTS: DistrictCentroid[] = [
  { id: 1, name: 'Aveiro', lat: 40.6, lng: -8.6 },
  { id: 2, name: 'Beja', lat: 37.9, lng: -7.9 },
  { id: 3, name: 'Braga', lat: 41.5, lng: -8.4 },
  { id: 4, name: 'Bragança', lat: 41.8, lng: -6.8 },
  { id: 5, name: 'Castelo Branco', lat: 39.8, lng: -7.5 },
  { id: 6, name: 'Coimbra', lat: 40.2, lng: -8.4 },
  { id: 7, name: 'Évora', lat: 38.6, lng: -7.9 },
  { id: 8, name: 'Faro', lat: 37.1, lng: -8.0 },
  { id: 9, name: 'Guarda', lat: 40.5, lng: -7.3 },
  { id: 10, name: 'Leiria', lat: 39.7, lng: -8.8 },
  { id: 11, name: 'Lisboa', lat: 38.8, lng: -9.1 },
  { id: 12, name: 'Portalegre', lat: 39.3, lng: -7.4 },
  { id: 13, name: 'Porto', lat: 41.2, lng: -8.5 },
  { id: 14, name: 'Santarém', lat: 39.3, lng: -8.7 },
  { id: 15, name: 'Setúbal', lat: 38.4, lng: -8.7 },
  { id: 16, name: 'Viana do Castelo', lat: 41.7, lng: -8.7 },
  { id: 17, name: 'Vila Real', lat: 41.3, lng: -7.7 },
  { id: 18, name: 'Viseu', lat: 40.7, lng: -7.9 },
]

interface DGEGStationRow {
  Id: number
  Nome: string
  Marca: string | null
  TipoPosto: string | null
  Municipio: string | null
  Distrito: string | null
  Morada: string | null
  Localidade: string | null
  CodPostal: string | null
  Latitude: number
  Longitude: number
  Preco: string
  Combustivel: string
  DataAtualizacao: string | null
}

interface DGEGResponse {
  status: boolean
  mensagem: string | null
  resultado: DGEGStationRow[] | null
}

function nearestDistrictIds(lat: number, lng: number, n = 3): number[] {
  return [...MAINLAND_DISTRICTS]
    .sort((a, b) => distanceKm(lat, lng, a.lat, a.lng) - distanceKm(lat, lng, b.lat, b.lng))
    .slice(0, n)
    .map((d) => d.id)
}

function parsePrice(raw: string): number | null {
  // Format: "1,819 €" — Portuguese decimal comma
  const m = raw.match(/([0-9]+[.,][0-9]+)/)
  if (!m) return null
  const num = Number(m[1].replace(',', '.'))
  return Number.isFinite(num) ? num : null
}

function parseDate(raw: string | null): string {
  if (!raw) return new Date().toISOString()
  // Format: "2026-05-12 17:00" — treat as local Portugal time (Atlantic/Lisbon)
  // We don't have tz info; treat as already-ISO-ish, replacing space with T.
  const iso = raw.replace(' ', 'T') + ':00'
  const d = new Date(iso)
  return Number.isFinite(d.getTime()) ? d.toISOString() : new Date().toISOString()
}

async function fetchOnePage(districtId: number, fuelId: number): Promise<DGEGStationRow[]> {
  const url = `${ENDPOINT}?idsTiposComb=${fuelId}&idMarca=&idTipoPosto=&idDistrito=${districtId}&idsMunicipios=&qtdPorPagina=500&pagina=1`
  const res = await fetch(url)
  if (!res.ok) throw new Error(`DGEG HTTP ${res.status}`)
  const data = (await res.json()) as DGEGResponse
  if (!data.status) throw new Error(data.mensagem ?? 'DGEG error')
  return data.resultado ?? []
}

/**
 * Fetch fuel stations + prices around a Portuguese location.
 * @param radiusKm — filter results down to this radius from the user.
 */
export async function fetchDgegStations(
  lat: number,
  lng: number,
  radiusKm = 25,
): Promise<MapStation[]> {
  const districts = nearestDistrictIds(lat, lng, 3)
  const fuelIds = Object.values(FUEL_TYPE_IDS)

  const settled = await Promise.allSettled(
    districts.flatMap((d) => fuelIds.map((f) => fetchOnePage(d, f))),
  )

  const rows = settled.flatMap((r) => (r.status === 'fulfilled' ? r.value : []))

  // Merge per station — one row per (station, fuel kind).
  const byId = new Map<number, MapStation & { _row: DGEGStationRow }>()
  for (const row of rows) {
    if (distanceKm(lat, lng, row.Latitude, row.Longitude) > radiusKm) continue

    const existing = byId.get(row.Id)
    const price = parsePrice(row.Preco)
    const fuelKind: keyof typeof FUEL_TYPE_IDS | null = row.Combustivel
      .toLowerCase()
      .includes('gasóleo')
      ? 'diesel'
      : row.Combustivel.toLowerCase().includes('gasolina simples 95')
        ? 'e5'
        : null

    if (existing) {
      if (fuelKind && price != null && existing.prices) {
        existing.prices[fuelKind] = price
      }
      continue
    }

    const prices: StationPriceData = {
      currency: 'EUR',
      reportedAt: parseDate(row.DataAtualizacao),
      source: 'dgeg.gov.pt',
    }
    if (fuelKind && price != null) prices[fuelKind] = price

    byId.set(row.Id, {
      _row: row,
      osm_id: `dgeg-${row.Id}`,
      lat: row.Latitude,
      lng: row.Longitude,
      name: row.Nome || null,
      brand: row.Marca || null,
      operator: null,
      address: [row.Morada, row.Localidade].filter(Boolean).join(', ') || null,
      prices: prices.e5 != null || prices.diesel != null ? prices : undefined,
    })
  }

  return [...byId.values()].map(({ _row: _unused, ...rest }) => rest)
}
