import type { OverpassStation } from '@/services/overpass'

/** Fuel grades supported in price lookups + filters. */
export type FuelKind = 'e5' | 'e10' | 'diesel'

export const FUEL_KIND_LABELS: Record<FuelKind, string> = {
  e5: 'Super (E5)',
  e10: 'Super (E10)',
  diesel: 'Diesel',
}

export interface StationPriceData {
  e5?: number
  e10?: number
  diesel?: number
  currency: string
  reportedAt: string
  source: string
}

export interface MapStation extends OverpassStation {
  prices?: StationPriceData
}

export type SortMode = 'distance' | 'price'
