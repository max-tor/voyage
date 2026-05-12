-- Voyage Phase 4: Stations
-- Stations are imported from external sources (OpenStreetMap via Overpass)
-- or contributed by users. station_prices is the time-series table that
-- will be fed by Phase 5 (TankerKönig, government feeds, crowdsourced
-- submissions from fill-ups). For Phase 4 the map fetches stations live
-- from Overpass without writing to these tables yet.

create table public.stations (
  id uuid primary key default gen_random_uuid(),
  osm_id text unique,
  name text,
  brand text,
  address text,
  country_code text,
  lat numeric(9, 6) not null,
  lng numeric(9, 6) not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index stations_lat_lng_idx on public.stations (lat, lng);

alter table public.stations enable row level security;

create policy "Anyone can read stations"
  on public.stations for select
  using (true);

create trigger stations_touch_updated_at
  before update on public.stations
  for each row execute function public.touch_updated_at();

create table public.station_prices (
  id uuid primary key default gen_random_uuid(),
  station_id uuid not null references public.stations(id) on delete cascade,
  fuel_type fuel_type not null,
  price numeric(8, 3) not null,
  currency text not null,
  reported_at timestamptz not null default now(),
  source text not null,
  user_id uuid references auth.users(id) on delete set null
);

create index station_prices_station_id_reported_idx
  on public.station_prices (station_id, reported_at desc);

alter table public.station_prices enable row level security;

create policy "Anyone can read station_prices"
  on public.station_prices for select
  using (true);

create policy "Authenticated users can submit prices"
  on public.station_prices for insert
  with check (auth.uid() is not null and (user_id is null or auth.uid() = user_id));
