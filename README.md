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

### Optional: live fuel prices in Germany

Voyage will use the free TankerKönig API if you provide a key. Register at
https://creativecommons.tankerkoenig.de/api/ and add it to your `.env`:

```
VITE_TANKERKONIG_API_KEY=your-key-here
```

Restart `npm run dev` after editing `.env`. Without a key, German station
prices fall back to crowdsourced data (same as every other country).

## Scripts

| Script | What it does |
|---|---|
| `npm run dev` | Start dev server on http://localhost:5173/voyage/ |
| `npm run build` | Type-check + production build to `dist/` |
| `npm run preview` | Preview production build locally |
| `npm run lint` | Run ESLint |
| `npm run format` | Run Prettier |
