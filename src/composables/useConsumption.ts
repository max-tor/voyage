import type { FillUp } from '@/types/database'

export interface ConsumptionMetrics {
  l_100km: number
  distance: number
  volume: number
}

/**
 * Calculate l/100km between consecutive full tanks.
 *
 * Convention: for a full-tank fill-up F preceded by a previous full-tank P,
 * consumption = (sum of fuel_volume from fill-ups strictly after P up to and
 * including F) / (F.odometer - P.odometer) * 100. Partial fills between P and
 * F contribute their volume, not their own consumption value. Returns a map
 * from fill-up id to metrics; rows without enough history return nothing.
 */
export function calculateConsumption(
  fillups: FillUp[],
): Record<string, ConsumptionMetrics | undefined> {
  const sorted = [...fillups].sort((a, b) => a.date.localeCompare(b.date))
  const result: Record<string, ConsumptionMetrics | undefined> = {}

  let prevFullIdx = -1
  let volumeBetween = 0

  for (let i = 0; i < sorted.length; i++) {
    const row = sorted[i]
    if (!row.full_tank) {
      volumeBetween += Number(row.fuel_volume) || 0
      continue
    }
    if (prevFullIdx >= 0) {
      const prev = sorted[prevFullIdx]
      const distance = Number(row.odometer) - Number(prev.odometer)
      const totalVolume = volumeBetween + (Number(row.fuel_volume) || 0)
      if (distance > 0) {
        result[row.id] = {
          l_100km: (totalVolume / distance) * 100,
          distance,
          volume: totalVolume,
        }
      }
    }
    prevFullIdx = i
    volumeBetween = 0
  }

  return result
}
