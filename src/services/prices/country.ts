// Lightweight country lookup via bounding box. Good enough to route between
// providers; for borderline points the provider itself decides if it has data.

type BBox = readonly [minLat: number, minLng: number, maxLat: number, maxLng: number]

const BBOXES: Record<string, BBox> = {
  DE: [47.27, 5.87, 55.06, 15.04],
  FR: [41.33, -5.14, 51.09, 9.56],
  AT: [46.37, 9.53, 49.02, 17.16],
  ES: [35.95, -9.39, 43.79, 4.33],
  IT: [35.49, 6.62, 47.09, 18.51],
  CH: [45.82, 5.96, 47.81, 10.49],
  BE: [49.5, 2.55, 51.51, 6.41],
  NL: [50.75, 3.36, 53.55, 7.23],
  GB: [49.96, -8.65, 60.85, 1.76],
  PL: [49.0, 14.12, 54.84, 24.15],
  CA: [41.68, -141.0, 83.11, -52.62],
}

export function detectCountry(lat: number, lng: number): string | null {
  for (const [code, [minLat, minLng, maxLat, maxLng]] of Object.entries(BBOXES)) {
    if (lat >= minLat && lat <= maxLat && lng >= minLng && lng <= maxLng) return code
  }
  return null
}
