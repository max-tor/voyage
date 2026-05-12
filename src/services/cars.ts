import { supabase } from './supabase'
import type { Car, CarCatalogEntry, CarInsert, CarUpdate } from '@/types/database'

const CAR_PHOTOS_BUCKET = 'car-photos'

export async function listCars(): Promise<Car[]> {
  const { data, error } = await supabase
    .from('cars')
    .select('*')
    .order('is_active', { ascending: false })
    .order('created_at', { ascending: false })
  if (error) throw error
  return data as Car[]
}

export async function getCar(id: string): Promise<Car> {
  const { data, error } = await supabase.from('cars').select('*').eq('id', id).single()
  if (error) throw error
  return data as Car
}

export async function createCar(userId: string, input: CarInsert): Promise<Car> {
  const { data, error } = await supabase
    .from('cars')
    .insert({ ...input, user_id: userId })
    .select('*')
    .single()
  if (error) throw error
  return data as Car
}

export async function updateCar(id: string, patch: CarUpdate): Promise<Car> {
  const { data, error } = await supabase
    .from('cars')
    .update(patch)
    .eq('id', id)
    .select('*')
    .single()
  if (error) throw error
  return data as Car
}

export async function deleteCar(id: string): Promise<void> {
  const { error } = await supabase.from('cars').delete().eq('id', id)
  if (error) throw error
}

export async function setActiveCar(userId: string, carId: string): Promise<void> {
  const { error: clearError } = await supabase
    .from('cars')
    .update({ is_active: false })
    .eq('user_id', userId)
    .eq('is_active', true)
  if (clearError) throw clearError

  const { error: setError } = await supabase
    .from('cars')
    .update({ is_active: true })
    .eq('id', carId)
  if (setError) throw setError
}

export async function listCarCatalog(): Promise<CarCatalogEntry[]> {
  const { data, error } = await supabase
    .from('car_catalog')
    .select('*')
    .order('make')
    .order('model')
  if (error) throw error
  return data as CarCatalogEntry[]
}

export async function uploadCarPhoto(
  userId: string,
  carId: string,
  file: File,
): Promise<string> {
  const blob = await resizeImage(file, 1024, 0.85)
  const path = `${userId}/${carId}.jpg`
  const { error } = await supabase.storage
    .from(CAR_PHOTOS_BUCKET)
    .upload(path, blob, { upsert: true, contentType: 'image/jpeg' })
  if (error) throw error
  return path
}

export function getCarPhotoUrl(path: string | null): string | null {
  if (!path) return null
  const { data } = supabase.storage.from(CAR_PHOTOS_BUCKET).getPublicUrl(path)
  return `${data.publicUrl}?t=${Date.now()}`
}

async function resizeImage(file: File, maxDim: number, quality: number): Promise<Blob> {
  const dataUrl = await readAsDataURL(file)
  const img = await loadImage(dataUrl)

  let { width, height } = img
  if (width > height && width > maxDim) {
    height = Math.round((height * maxDim) / width)
    width = maxDim
  } else if (height > maxDim) {
    width = Math.round((width * maxDim) / height)
    height = maxDim
  }

  const canvas = document.createElement('canvas')
  canvas.width = width
  canvas.height = height
  const ctx = canvas.getContext('2d')
  if (!ctx) throw new Error('Canvas 2D context unavailable')
  ctx.drawImage(img, 0, 0, width, height)

  return new Promise<Blob>((resolve, reject) => {
    canvas.toBlob(
      (blob) => (blob ? resolve(blob) : reject(new Error('Image encode failed'))),
      'image/jpeg',
      quality,
    )
  })
}

function readAsDataURL(file: File): Promise<string> {
  return new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => resolve(reader.result as string)
    reader.onerror = () => reject(reader.error)
    reader.readAsDataURL(file)
  })
}

function loadImage(src: string): Promise<HTMLImageElement> {
  return new Promise((resolve, reject) => {
    const img = new Image()
    img.onload = () => resolve(img)
    img.onerror = reject
    img.src = src
  })
}
