-- Voyage Phase 2: Garage
-- Tables: car_catalog (seed), cars (user-owned)
-- Storage: car-photos bucket with per-user write access, public read

-- =========================================================================
-- Enums
-- =========================================================================
create type fuel_type as enum ('gasoline', 'diesel', 'electric', 'hybrid', 'lpg', 'cng');
create type distance_unit as enum ('km', 'mi');
create type fuel_unit as enum ('l', 'gal_us', 'gal_uk');
create type consumption_unit as enum ('l_100km', 'mpg_us', 'mpg_uk', 'km_l');

-- =========================================================================
-- car_catalog: public read, seed-only
-- =========================================================================
create table public.car_catalog (
  id uuid primary key default gen_random_uuid(),
  make text not null,
  model text not null,
  default_tank_l numeric(5, 1),
  default_consumption_l_100km numeric(4, 1),
  default_fuel_type fuel_type,
  unique (make, model)
);

alter table public.car_catalog enable row level security;

create policy "car_catalog is readable by anyone"
  on public.car_catalog for select
  using (true);

-- =========================================================================
-- cars: user-owned, RLS-protected
-- =========================================================================
create table public.cars (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  make text,
  model text,
  year int,
  description text,
  photo_path text,
  fuel_type fuel_type not null default 'gasoline',
  tank_capacity_l numeric(5, 1),
  avg_consumption_l_100km numeric(4, 1),
  distance_unit distance_unit not null default 'km',
  fuel_unit fuel_unit not null default 'l',
  consumption_unit consumption_unit not null default 'l_100km',
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index cars_user_id_idx on public.cars (user_id);

alter table public.cars enable row level security;

create policy "Users can read their own cars"
  on public.cars for select
  using (auth.uid() = user_id);

create policy "Users can insert their own cars"
  on public.cars for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own cars"
  on public.cars for update
  using (auth.uid() = user_id);

create policy "Users can delete their own cars"
  on public.cars for delete
  using (auth.uid() = user_id);

-- Touch updated_at on every update
create or replace function public.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger cars_touch_updated_at
  before update on public.cars
  for each row execute function public.touch_updated_at();

-- Enforce single active car per user
create unique index cars_one_active_per_user
  on public.cars (user_id)
  where is_active;

-- =========================================================================
-- Storage: car-photos bucket
-- =========================================================================
insert into storage.buckets (id, name, public)
values ('car-photos', 'car-photos', true)
on conflict (id) do nothing;

create policy "Public can read car-photos"
  on storage.objects for select
  using (bucket_id = 'car-photos');

create policy "Users can upload to their own folder in car-photos"
  on storage.objects for insert
  with check (
    bucket_id = 'car-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users can update their own car-photos"
  on storage.objects for update
  using (
    bucket_id = 'car-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );

create policy "Users can delete their own car-photos"
  on storage.objects for delete
  using (
    bucket_id = 'car-photos'
    and auth.uid()::text = (storage.foldername(name))[1]
  );
