-- Voyage Phase 3: Fill-ups
-- One row per fuel purchase. Consumption is calculated between consecutive
-- full-tank rows. Odometer is the authoritative distance reading; the form
-- offers a trip-mode input that the client converts to an odometer value
-- before insert.

create table public.fill_ups (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  car_id uuid not null references public.cars(id) on delete cascade,

  date timestamptz not null default now(),

  odometer numeric(10, 1) not null,
  fuel_volume numeric(8, 2) not null,
  fuel_type fuel_type not null,
  fuel_price numeric(8, 3),
  total_cost numeric(10, 2),
  currency text not null default 'EUR',

  full_tank boolean not null default true,

  station_id uuid,
  lat numeric(9, 6),
  lng numeric(9, 6),

  notes text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index fill_ups_car_id_date_idx on public.fill_ups (car_id, date desc);
create index fill_ups_user_id_idx on public.fill_ups (user_id);

create trigger fill_ups_touch_updated_at
  before update on public.fill_ups
  for each row execute function public.touch_updated_at();

alter table public.fill_ups enable row level security;

create policy "Users can read their own fill-ups"
  on public.fill_ups for select
  using (auth.uid() = user_id);

create policy "Users can insert their own fill-ups"
  on public.fill_ups for insert
  with check (auth.uid() = user_id);

create policy "Users can update their own fill-ups"
  on public.fill_ups for update
  using (auth.uid() = user_id);

create policy "Users can delete their own fill-ups"
  on public.fill_ups for delete
  using (auth.uid() = user_id);
