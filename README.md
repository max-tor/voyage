# Voyage

Map-first fuel tracker for drivers. Log fill-ups, track consumption, and find the cheapest nearby station.

Target markets: Europe + Canada. UI: English only.

## Stack

- Vue 3 + TypeScript + Vite
- Tailwind CSS v4
- Pinia (state) + Vue Router 4
- Supabase (auth, Postgres, storage)
- Leaflet + OpenStreetMap (Phase 4)
- Capacitor (later, for native iOS/Android)

## Deployment

Deploys to `https://toropov.one/voyage` via a Vercel rewrite from the parent Next.js site. Vite is configured with `base: '/voyage/'`.

## Local setup

```bash
cp .env.example .env       # add your Supabase URL + anon key
npm install
npm run dev
```

### How prices work

There is no single fuel-price API that covers all of Europe + Canada — the
data is fragmented across national open-data sources, and Canada has no
free real-time API at all. Voyage uses a per-country provider pattern:

- **🇵🇹 Portugal** — DGEG official API (`precoscombustiveis.dgeg.gov.pt`), no
  key required, returns E5 + Diesel prices.
- **Everywhere else** — stations come from OpenStreetMap (free Overpass
  API); prices come from your `station_prices` table, which is fed every
  time a user logs a fill-up at a station tapped from the map.

To extend coverage, add a new file under `src/services/prices/` that exports
a function matching `fetchDgegStations`'s signature, then wire it into the
country branch in `src/stores/stations.ts`. Candidates with free open data:
🇫🇷 prix-carburants.gouv.fr, 🇦🇹 spritpreisrechner.at, 🇪🇸 geoportalgasolineras.es,
🇮🇹 MIMIT, 🇩🇪 TankerKönig.

## Scripts

| Script | What it does |
|---|---|
| `npm run dev` | Start dev server on http://localhost:5173/voyage/ |
| `npm run build` | Type-check + production build to `dist/` |
| `npm run preview` | Preview production build locally |
| `npm run lint` | Run ESLint |
| `npm run format` | Run Prettier |
