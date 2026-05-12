import { supabase } from './supabase'
import type { FuelType } from '@/types/database'
import type { MapStation, StationPriceData } from '@/types/prices'

interface StationRow {
  id: string
  osm_id: string | null
  name: string | null
  brand: string | null
  address: string | null
  lat: number
  lng: number
}

interface StationPriceRow {
  station_id: string
  fuel_type: FuelType
  price: number
  currency: string
  reported_at: string
  source: string
}

/**
 * Upsert a station discovered from a map source (OSM or TankerKönig). Returns
 * the internal stations.id used by station_prices.
 */
export async function upsertStation(input: {
  osm_id: string
  name: string | null
  brand: string | null
  address: string | null
  lat: number
  lng: number
  country_code?: string | null
}): Promise<string> {
  const { data, error } = await supabase
    .from('stations')
    .upsert(
      {
        osm_id: input.osm_id,
        name: input.name,
        brand: input.brand,
        address: input.address,
        lat: input.lat,
        lng: input.lng,
        country_code: input.country_code ?? null,
      },
      { onConflict: 'osm_id' },
    )
    .select('id')
    .single()
  if (error) throw error
  return (data as { id: string }).id
}

/**
 * Insert a crowdsourced price report.
 */
export async function recordStationPrice(input: {
  stationId: string
  fuelType: FuelType
  price: number
  currency: string
  userId: string
  source?: string
}): Promise<void> {
  const { error } = await supabase.from('station_prices').insert({
    station_id: input.stationId,
    fuel_type: input.fuelType,
    price: input.price,
    currency: input.currency,
    source: input.source ?? 'user',
    user_id: input.userId,
  })
  if (error) throw error
}

/**
 * For a set of osm_ids that we resolved from a map source, fetch the latest
 * crowdsourced price (per fuel_type) from station_prices. Returns a map keyed
 * by osm_id.
 */
export async function loadCrowdsourcedPrices(
  osmIds: string[],
): Promise<Record<string, StationPriceData>> {
  if (osmIds.length === 0) return {}

  const { data: stationRows, error: stationErr } = await supabase
    .from('stations')
    .select('id, osm_id')
    .in('osm_id', osmIds)
  if (stationErr) throw stationErr
  const stations = (stationRows ?? []) as Pick<StationRow, 'id' | 'osm_id'>[]
  if (stations.length === 0) return {}

  const stationIds = stations.map((s) => s.id)
  const { data: priceRows, error: priceErr } = await supabase
    .from('station_prices')
    .select('station_id, fuel_type, price, currency, reported_at, source')
    .in('station_id', stationIds)
    .order('reported_at', { ascending: false })
  if (priceErr) throw priceErr
  const prices = (priceRows ?? []) as StationPriceRow[]

  const byStation: Record<string, StationPriceRow[]> = {}
  for (const row of prices) {
    ;(byStation[row.station_id] ??= []).push(row)
  }

  const result: Record<string, StationPriceData> = {}
  for (const station of stations) {
    if (!station.osm_id) continue
    const rows = byStation[station.id] ?? []
    if (rows.length === 0) continue

    const latestByFuel: Partial<Record<FuelType, StationPriceRow>> = {}
    for (const row of rows) {
      if (!latestByFuel[row.fuel_type]) latestByFuel[row.fuel_type] = row
    }

    const data: StationPriceData = {
      currency: rows[0].currency,
      reportedAt: rows[0].reported_at,
      source: 'voyage',
    }
    if (latestByFuel.gasoline) data.e5 = Number(latestByFuel.gasoline.price)
    if (latestByFuel.diesel) data.diesel = Number(latestByFuel.diesel.price)
    result[station.osm_id] = data
  }

  return result
}
