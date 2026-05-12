-- Voyage car_catalog seed
-- Approximate tank capacity (L) and combined-cycle consumption (l/100km)
-- Values are rounded averages across recent model years; users can override.

insert into public.car_catalog (make, model, default_tank_l, default_consumption_l_100km, default_fuel_type) values
  ('Audi', 'A3', 50, 5.5, 'gasoline'),
  ('Audi', 'A4', 54, 6.2, 'diesel'),
  ('Audi', 'A6', 73, 6.4, 'diesel'),
  ('Audi', 'Q5', 70, 7.5, 'gasoline'),

  ('BMW', '3 Series', 59, 5.8, 'diesel'),
  ('BMW', '5 Series', 68, 6.2, 'diesel'),
  ('BMW', 'X3', 65, 7.4, 'gasoline'),
  ('BMW', 'X5', 83, 8.5, 'gasoline'),

  ('Mercedes-Benz', 'A-Class', 43, 5.5, 'gasoline'),
  ('Mercedes-Benz', 'C-Class', 66, 5.8, 'diesel'),
  ('Mercedes-Benz', 'E-Class', 66, 6.0, 'diesel'),
  ('Mercedes-Benz', 'GLC', 66, 7.5, 'gasoline'),

  ('Volkswagen', 'Golf', 50, 5.2, 'gasoline'),
  ('Volkswagen', 'Passat', 66, 5.5, 'diesel'),
  ('Volkswagen', 'Tiguan', 58, 6.8, 'gasoline'),
  ('Volkswagen', 'Polo', 40, 5.0, 'gasoline'),

  ('Toyota', 'Corolla', 50, 4.8, 'hybrid'),
  ('Toyota', 'RAV4', 55, 5.8, 'hybrid'),
  ('Toyota', 'Yaris', 40, 4.2, 'hybrid'),
  ('Toyota', 'Camry', 60, 4.7, 'hybrid'),

  ('Honda', 'Civic', 47, 5.3, 'gasoline'),
  ('Honda', 'CR-V', 57, 7.0, 'gasoline'),
  ('Honda', 'Jazz', 40, 4.5, 'hybrid'),

  ('Ford', 'Focus', 52, 5.4, 'gasoline'),
  ('Ford', 'Fiesta', 42, 5.0, 'gasoline'),
  ('Ford', 'Kuga', 54, 6.5, 'gasoline'),
  ('Ford', 'F-150', 98, 12.5, 'gasoline'),

  ('Skoda', 'Octavia', 50, 5.0, 'diesel'),
  ('Skoda', 'Fabia', 50, 5.1, 'gasoline'),
  ('Skoda', 'Kodiaq', 60, 6.7, 'diesel'),

  ('Renault', 'Clio', 42, 5.0, 'gasoline'),
  ('Renault', 'Megane', 50, 5.2, 'diesel'),

  ('Peugeot', '208', 44, 5.1, 'gasoline'),
  ('Peugeot', '308', 53, 5.0, 'diesel'),

  ('Fiat', '500', 35, 5.0, 'gasoline'),
  ('Fiat', 'Panda', 37, 5.3, 'gasoline'),
  ('Fiat', 'Tipo', 50, 5.2, 'gasoline'),
  ('Fiat', 'Ducato', 75, 9.5, 'diesel'),

  ('Hyundai', 'i30', 50, 5.4, 'gasoline'),
  ('Hyundai', 'Tucson', 54, 6.4, 'gasoline'),

  ('Kia', 'Ceed', 50, 5.3, 'gasoline'),
  ('Kia', 'Sportage', 54, 6.4, 'gasoline'),

  ('Tesla', 'Model 3', 0, 0, 'electric'),
  ('Tesla', 'Model Y', 0, 0, 'electric'),

  ('Nissan', 'Qashqai', 55, 5.8, 'gasoline'),
  ('Nissan', 'Leaf', 0, 0, 'electric'),

  ('Mazda', 'CX-5', 56, 6.5, 'gasoline'),
  ('Mazda', '3', 51, 5.5, 'gasoline'),

  ('Ducati', 'Monster', 14, 5.2, 'gasoline'),
  ('Ducati', 'Multistrada', 20, 6.0, 'gasoline');
