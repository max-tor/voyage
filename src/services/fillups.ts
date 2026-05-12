import { supabase } from './supabase'
import type { FillUp, FillUpInsert, FillUpUpdate } from '@/types/database'

export async function listFillUps(carId: string): Promise<FillUp[]> {
  const { data, error } = await supabase
    .from('fill_ups')
    .select('*')
    .eq('car_id', carId)
    .order('date', { ascending: false })
  if (error) throw error
  return data as FillUp[]
}

export async function getFillUp(id: string): Promise<FillUp> {
  const { data, error } = await supabase.from('fill_ups').select('*').eq('id', id).single()
  if (error) throw error
  return data as FillUp
}

export async function getLastFillUp(carId: string): Promise<FillUp | null> {
  const { data, error } = await supabase
    .from('fill_ups')
    .select('*')
    .eq('car_id', carId)
    .order('date', { ascending: false })
    .limit(1)
    .maybeSingle()
  if (error) throw error
  return (data as FillUp) ?? null
}

export async function createFillUp(userId: string, input: FillUpInsert): Promise<FillUp> {
  const { data, error } = await supabase
    .from('fill_ups')
    .insert({ ...input, user_id: userId })
    .select('*')
    .single()
  if (error) throw error
  return data as FillUp
}

export async function updateFillUp(id: string, patch: FillUpUpdate): Promise<FillUp> {
  const { data, error } = await supabase
    .from('fill_ups')
    .update(patch)
    .eq('id', id)
    .select('*')
    .single()
  if (error) throw error
  return data as FillUp
}

export async function deleteFillUp(id: string): Promise<void> {
  const { error } = await supabase.from('fill_ups').delete().eq('id', id)
  if (error) throw error
}
