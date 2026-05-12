export type FuelType = 'gasoline' | 'diesel' | 'electric' | 'hybrid' | 'lpg' | 'cng'
export type DistanceUnit = 'km' | 'mi'
export type FuelUnit = 'l' | 'gal_us' | 'gal_uk'
export type ConsumptionUnit = 'l_100km' | 'mpg_us' | 'mpg_uk' | 'km_l'

export interface Car {
  id: string
  user_id: string
  name: string
  make: string | null
  model: string | null
  year: number | null
  description: string | null
  photo_path: string | null
  fuel_type: FuelType
  tank_capacity_l: number | null
  avg_consumption_l_100km: number | null
  distance_unit: DistanceUnit
  fuel_unit: FuelUnit
  consumption_unit: ConsumptionUnit
  is_active: boolean
  created_at: string
  updated_at: string
}

export type CarInsert = Omit<Car, 'id' | 'user_id' | 'created_at' | 'updated_at'>
export type CarUpdate = Partial<CarInsert>

export interface CarCatalogEntry {
  id: string
  make: string
  model: string
  default_tank_l: number | null
  default_consumption_l_100km: number | null
  default_fuel_type: FuelType | null
}

export const FUEL_TYPE_LABELS: Record<FuelType, string> = {
  gasoline: 'Gasoline',
  diesel: 'Diesel',
  electric: 'Electric',
  hybrid: 'Hybrid',
  lpg: 'LPG',
  cng: 'CNG',
}
