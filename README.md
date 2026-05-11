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

## Scripts

| Script | What it does |
|---|---|
| `npm run dev` | Start dev server on http://localhost:5173/voyage/ |
| `npm run build` | Type-check + production build to `dist/` |
| `npm run preview` | Preview production build locally |
| `npm run lint` | Run ESLint |
| `npm run format` | Run Prettier |
