-- Voyage car_catalog: expanded coverage for popular EU + North America brands
-- Defaults are approximate combined-cycle averages across recent model years.

insert into public.car_catalog (make, model, default_tank_l, default_consumption_l_100km, default_fuel_type) values
  -- Audi (more)
  ('Audi', 'A1', 40, 5.2, 'gasoline'),
  ('Audi', 'A5', 58, 6.5, 'gasoline'),
  ('Audi', 'A7', 73, 6.7, 'diesel'),
  ('Audi', 'A8', 82, 7.2, 'diesel'),
  ('Audi', 'Q3', 60, 6.2, 'gasoline'),
  ('Audi', 'Q7', 75, 7.8, 'diesel'),
  ('Audi', 'Q8', 85, 8.0, 'diesel'),
  ('Audi', 'e-tron', 0, 0, 'electric'),
  ('Audi', 'Q4 e-tron', 0, 0, 'electric'),
  ('Audi', 'TT', 55, 6.5, 'gasoline'),
  ('Audi', 'RS6', 73, 11.5, 'gasoline'),

  -- BMW (more)
  ('BMW', '1 Series', 50, 5.5, 'gasoline'),
  ('BMW', '2 Series', 50, 5.8, 'gasoline'),
  ('BMW', '4 Series', 59, 6.0, 'gasoline'),
  ('BMW', '7 Series', 78, 7.0, 'gasoline'),
  ('BMW', '8 Series', 68, 7.5, 'gasoline'),
  ('BMW', 'X1', 51, 6.0, 'gasoline'),
  ('BMW', 'X2', 51, 6.2, 'gasoline'),
  ('BMW', 'X4', 65, 7.4, 'gasoline'),
  ('BMW', 'X6', 83, 8.6, 'gasoline'),
  ('BMW', 'X7', 83, 8.7, 'gasoline'),
  ('BMW', 'Z4', 52, 6.5, 'gasoline'),
  ('BMW', 'i4', 0, 0, 'electric'),
  ('BMW', 'iX', 0, 0, 'electric'),
  ('BMW', 'iX3', 0, 0, 'electric'),
  ('BMW', 'M2', 52, 9.5, 'gasoline'),
  ('BMW', 'M3', 59, 9.8, 'gasoline'),
  ('BMW', 'M4', 59, 9.8, 'gasoline'),

  -- BMW Motorrad
  ('BMW Motorrad', 'R 1250 GS', 20, 4.8, 'gasoline'),
  ('BMW Motorrad', 'S 1000 RR', 16.5, 6.5, 'gasoline'),
  ('BMW Motorrad', 'F 850 GS', 15, 4.5, 'gasoline'),
  ('BMW Motorrad', 'R nineT', 17, 5.5, 'gasoline'),
  ('BMW Motorrad', 'K 1600', 26.5, 6.0, 'gasoline'),

  -- Mercedes-Benz (more)
  ('Mercedes-Benz', 'B-Class', 50, 5.6, 'diesel'),
  ('Mercedes-Benz', 'CLA', 51, 5.7, 'gasoline'),
  ('Mercedes-Benz', 'CLS', 66, 6.5, 'diesel'),
  ('Mercedes-Benz', 'S-Class', 76, 7.5, 'diesel'),
  ('Mercedes-Benz', 'GLA', 56, 5.8, 'gasoline'),
  ('Mercedes-Benz', 'GLB', 60, 6.3, 'gasoline'),
  ('Mercedes-Benz', 'GLE', 85, 7.8, 'diesel'),
  ('Mercedes-Benz', 'GLS', 90, 8.5, 'diesel'),
  ('Mercedes-Benz', 'G-Class', 100, 11.0, 'gasoline'),
  ('Mercedes-Benz', 'EQE', 0, 0, 'electric'),
  ('Mercedes-Benz', 'EQS', 0, 0, 'electric'),
  ('Mercedes-Benz', 'EQA', 0, 0, 'electric'),
  ('Mercedes-Benz', 'EQB', 0, 0, 'electric'),
  ('Mercedes-Benz', 'Sprinter', 71, 8.5, 'diesel'),
  ('Mercedes-Benz', 'Vito', 70, 7.5, 'diesel'),
  ('Mercedes-Benz', 'V-Class', 70, 7.5, 'diesel'),

  -- Volkswagen (more)
  ('Volkswagen', 'T-Roc', 55, 6.0, 'gasoline'),
  ('Volkswagen', 'T-Cross', 40, 5.5, 'gasoline'),
  ('Volkswagen', 'Touareg', 75, 7.5, 'diesel'),
  ('Volkswagen', 'Touran', 60, 5.7, 'diesel'),
  ('Volkswagen', 'Sharan', 70, 6.8, 'diesel'),
  ('Volkswagen', 'Caddy', 60, 6.0, 'diesel'),
  ('Volkswagen', 'Transporter', 70, 7.5, 'diesel'),
  ('Volkswagen', 'Arteon', 66, 6.3, 'diesel'),
  ('Volkswagen', 'ID.3', 0, 0, 'electric'),
  ('Volkswagen', 'ID.4', 0, 0, 'electric'),
  ('Volkswagen', 'ID.5', 0, 0, 'electric'),
  ('Volkswagen', 'ID.7', 0, 0, 'electric'),
  ('Volkswagen', 'ID. Buzz', 0, 0, 'electric'),

  -- Volvo
  ('Volvo', 'XC40', 54, 6.7, 'gasoline'),
  ('Volvo', 'XC60', 71, 6.8, 'diesel'),
  ('Volvo', 'XC90', 71, 7.5, 'diesel'),
  ('Volvo', 'V60', 60, 5.5, 'diesel'),
  ('Volvo', 'V90', 60, 6.0, 'diesel'),
  ('Volvo', 'S60', 60, 6.2, 'gasoline'),
  ('Volvo', 'S90', 60, 6.5, 'diesel'),
  ('Volvo', 'EX30', 0, 0, 'electric'),
  ('Volvo', 'EX40', 0, 0, 'electric'),
  ('Volvo', 'EX90', 0, 0, 'electric'),
  ('Volvo', 'C40', 0, 0, 'electric'),

  -- Land Rover
  ('Land Rover', 'Defender', 90, 9.5, 'diesel'),
  ('Land Rover', 'Discovery', 89, 8.5, 'diesel'),
  ('Land Rover', 'Discovery Sport', 65, 7.0, 'diesel'),
  ('Land Rover', 'Range Rover', 90, 9.5, 'diesel'),
  ('Land Rover', 'Range Rover Sport', 80, 8.5, 'diesel'),
  ('Land Rover', 'Range Rover Evoque', 65, 7.0, 'diesel'),
  ('Land Rover', 'Range Rover Velar', 80, 7.5, 'diesel'),

  -- Jaguar
  ('Jaguar', 'XE', 63, 5.6, 'diesel'),
  ('Jaguar', 'XF', 66, 6.0, 'diesel'),
  ('Jaguar', 'F-Pace', 82, 7.0, 'diesel'),
  ('Jaguar', 'E-Pace', 65, 6.5, 'diesel'),
  ('Jaguar', 'I-Pace', 0, 0, 'electric'),
  ('Jaguar', 'F-Type', 70, 9.0, 'gasoline'),

  -- Porsche
  ('Porsche', '911', 67, 9.5, 'gasoline'),
  ('Porsche', 'Cayenne', 75, 9.5, 'gasoline'),
  ('Porsche', 'Macan', 75, 8.5, 'gasoline'),
  ('Porsche', 'Panamera', 80, 8.5, 'gasoline'),
  ('Porsche', 'Taycan', 0, 0, 'electric'),
  ('Porsche', 'Boxster', 64, 8.0, 'gasoline'),
  ('Porsche', 'Cayman', 64, 8.0, 'gasoline'),

  -- MINI
  ('MINI', 'Cooper', 44, 5.8, 'gasoline'),
  ('MINI', 'Countryman', 51, 6.5, 'gasoline'),
  ('MINI', 'Clubman', 44, 6.0, 'gasoline'),
  ('MINI', 'Aceman', 0, 0, 'electric'),

  -- Smart
  ('Smart', 'Fortwo', 28, 4.5, 'gasoline'),
  ('Smart', 'Forfour', 35, 4.8, 'gasoline'),
  ('Smart', '#1', 0, 0, 'electric'),

  -- Citroën
  ('Citroën', 'C1', 35, 4.4, 'gasoline'),
  ('Citroën', 'C3', 45, 5.0, 'gasoline'),
  ('Citroën', 'C4', 50, 5.4, 'gasoline'),
  ('Citroën', 'C5 Aircross', 53, 6.0, 'gasoline'),
  ('Citroën', 'C5 X', 52, 6.0, 'gasoline'),
  ('Citroën', 'Berlingo', 60, 5.5, 'diesel'),
  ('Citroën', 'Jumpy', 69, 6.5, 'diesel'),
  ('Citroën', 'Jumper', 90, 8.0, 'diesel'),
  ('Citroën', 'ë-C4', 0, 0, 'electric'),

  -- Opel / Vauxhall
  ('Opel', 'Corsa', 44, 5.1, 'gasoline'),
  ('Opel', 'Astra', 52, 5.3, 'gasoline'),
  ('Opel', 'Insignia', 62, 5.8, 'diesel'),
  ('Opel', 'Mokka', 44, 5.5, 'gasoline'),
  ('Opel', 'Crossland', 45, 5.4, 'gasoline'),
  ('Opel', 'Grandland', 53, 5.8, 'gasoline'),
  ('Opel', 'Combo', 50, 5.5, 'diesel'),
  ('Opel', 'Vivaro', 69, 6.5, 'diesel'),

  -- Seat
  ('Seat', 'Ibiza', 40, 5.0, 'gasoline'),
  ('Seat', 'Leon', 50, 5.2, 'gasoline'),
  ('Seat', 'Ateca', 55, 6.0, 'gasoline'),
  ('Seat', 'Tarraco', 58, 6.5, 'gasoline'),
  ('Seat', 'Arona', 40, 5.3, 'gasoline'),

  -- Cupra
  ('Cupra', 'Leon', 50, 6.0, 'gasoline'),
  ('Cupra', 'Formentor', 55, 6.5, 'gasoline'),
  ('Cupra', 'Born', 0, 0, 'electric'),
  ('Cupra', 'Tavascan', 0, 0, 'electric'),

  -- Subaru
  ('Subaru', 'Outback', 60, 7.5, 'gasoline'),
  ('Subaru', 'Forester', 63, 7.2, 'gasoline'),
  ('Subaru', 'Crosstrek', 63, 7.0, 'gasoline'),
  ('Subaru', 'Impreza', 50, 6.5, 'gasoline'),
  ('Subaru', 'WRX', 63, 9.5, 'gasoline'),
  ('Subaru', 'Ascent', 73, 9.0, 'gasoline'),
  ('Subaru', 'BRZ', 50, 7.5, 'gasoline'),

  -- Mitsubishi
  ('Mitsubishi', 'Outlander', 60, 7.5, 'gasoline'),
  ('Mitsubishi', 'ASX', 60, 6.5, 'gasoline'),
  ('Mitsubishi', 'L200', 75, 7.5, 'diesel'),
  ('Mitsubishi', 'Eclipse Cross', 63, 7.5, 'gasoline'),
  ('Mitsubishi', 'Pajero', 88, 9.5, 'diesel'),

  -- Suzuki
  ('Suzuki', 'Swift', 37, 4.6, 'gasoline'),
  ('Suzuki', 'Vitara', 47, 5.6, 'gasoline'),
  ('Suzuki', 'S-Cross', 47, 5.7, 'gasoline'),
  ('Suzuki', 'Jimny', 40, 6.5, 'gasoline'),
  ('Suzuki', 'Ignis', 32, 5.0, 'gasoline'),
  ('Suzuki', 'Across', 55, 1.0, 'hybrid'),

  -- Lexus
  ('Lexus', 'RX', 72, 6.5, 'hybrid'),
  ('Lexus', 'NX', 55, 5.8, 'hybrid'),
  ('Lexus', 'ES', 60, 5.5, 'hybrid'),
  ('Lexus', 'IS', 66, 6.5, 'gasoline'),
  ('Lexus', 'UX', 47, 5.0, 'hybrid'),
  ('Lexus', 'LX', 85, 12.5, 'gasoline'),
  ('Lexus', 'GX', 87, 12.0, 'gasoline'),
  ('Lexus', 'RZ', 0, 0, 'electric'),

  -- Acura
  ('Acura', 'MDX', 71, 10.5, 'gasoline'),
  ('Acura', 'RDX', 64, 9.5, 'gasoline'),
  ('Acura', 'TLX', 60, 9.0, 'gasoline'),
  ('Acura', 'Integra', 50, 7.5, 'gasoline'),

  -- Infiniti
  ('Infiniti', 'QX50', 60, 9.0, 'gasoline'),
  ('Infiniti', 'QX60', 75, 10.5, 'gasoline'),
  ('Infiniti', 'QX80', 100, 14.0, 'gasoline'),

  -- Cadillac
  ('Cadillac', 'Escalade', 90, 14.0, 'gasoline'),
  ('Cadillac', 'XT4', 56, 8.5, 'gasoline'),
  ('Cadillac', 'XT5', 68, 10.5, 'gasoline'),
  ('Cadillac', 'XT6', 83, 11.0, 'gasoline'),
  ('Cadillac', 'CT4', 64, 8.5, 'gasoline'),
  ('Cadillac', 'CT5', 65, 9.5, 'gasoline'),
  ('Cadillac', 'Lyriq', 0, 0, 'electric'),

  -- Chevrolet
  ('Chevrolet', 'Cruze', 52, 6.5, 'gasoline'),
  ('Chevrolet', 'Malibu', 60, 7.5, 'gasoline'),
  ('Chevrolet', 'Equinox', 56, 8.5, 'gasoline'),
  ('Chevrolet', 'Tahoe', 91, 13.0, 'gasoline'),
  ('Chevrolet', 'Suburban', 109, 13.5, 'gasoline'),
  ('Chevrolet', 'Silverado', 91, 12.5, 'gasoline'),
  ('Chevrolet', 'Colorado', 78, 11.0, 'gasoline'),
  ('Chevrolet', 'Trax', 47, 7.2, 'gasoline'),
  ('Chevrolet', 'Trailblazer', 50, 7.5, 'gasoline'),
  ('Chevrolet', 'Bolt EV', 0, 0, 'electric'),
  ('Chevrolet', 'Blazer EV', 0, 0, 'electric'),
  ('Chevrolet', 'Camaro', 72, 11.0, 'gasoline'),
  ('Chevrolet', 'Corvette', 70, 11.5, 'gasoline'),

  -- GMC
  ('GMC', 'Sierra', 91, 12.5, 'gasoline'),
  ('GMC', 'Yukon', 91, 13.0, 'gasoline'),
  ('GMC', 'Acadia', 83, 10.5, 'gasoline'),
  ('GMC', 'Terrain', 56, 8.5, 'gasoline'),
  ('GMC', 'Canyon', 78, 11.0, 'gasoline'),
  ('GMC', 'Hummer EV', 0, 0, 'electric'),

  -- Dodge
  ('Dodge', 'Charger', 70, 11.5, 'gasoline'),
  ('Dodge', 'Challenger', 70, 11.5, 'gasoline'),
  ('Dodge', 'Durango', 93, 13.0, 'gasoline'),
  ('Dodge', 'Hornet', 50, 8.5, 'gasoline'),

  -- Jeep
  ('Jeep', 'Wrangler', 81, 11.5, 'gasoline'),
  ('Jeep', 'Grand Cherokee', 91, 11.0, 'gasoline'),
  ('Jeep', 'Cherokee', 60, 9.5, 'gasoline'),
  ('Jeep', 'Compass', 60, 7.5, 'gasoline'),
  ('Jeep', 'Renegade', 48, 6.5, 'gasoline'),
  ('Jeep', 'Gladiator', 83, 12.5, 'gasoline'),
  ('Jeep', 'Wagoneer', 100, 14.0, 'gasoline'),
  ('Jeep', 'Avenger', 44, 5.5, 'gasoline'),

  -- Chrysler
  ('Chrysler', '300', 70, 11.0, 'gasoline'),
  ('Chrysler', 'Pacifica', 72, 10.5, 'gasoline'),

  -- Ram
  ('Ram', '1500', 98, 13.0, 'gasoline'),
  ('Ram', '2500', 117, 14.5, 'diesel'),
  ('Ram', '3500', 121, 15.0, 'diesel'),
  ('Ram', 'ProMaster', 90, 12.5, 'gasoline'),

  -- Lincoln
  ('Lincoln', 'Navigator', 87, 13.5, 'gasoline'),
  ('Lincoln', 'Nautilus', 70, 10.5, 'gasoline'),
  ('Lincoln', 'Aviator', 76, 11.5, 'gasoline'),
  ('Lincoln', 'Corsair', 65, 9.0, 'gasoline'),

  -- Buick
  ('Buick', 'Encore', 53, 7.5, 'gasoline'),
  ('Buick', 'Enclave', 83, 10.5, 'gasoline'),
  ('Buick', 'Envision', 60, 8.0, 'gasoline'),

  -- Dacia
  ('Dacia', 'Sandero', 50, 5.4, 'gasoline'),
  ('Dacia', 'Duster', 50, 6.0, 'gasoline'),
  ('Dacia', 'Logan', 50, 5.5, 'gasoline'),
  ('Dacia', 'Spring', 0, 0, 'electric'),
  ('Dacia', 'Jogger', 50, 5.7, 'gasoline'),

  -- Genesis
  ('Genesis', 'G70', 60, 9.0, 'gasoline'),
  ('Genesis', 'G80', 73, 9.5, 'gasoline'),
  ('Genesis', 'G90', 77, 10.0, 'gasoline'),
  ('Genesis', 'GV70', 66, 9.5, 'gasoline'),
  ('Genesis', 'GV80', 78, 10.5, 'gasoline'),
  ('Genesis', 'GV60', 0, 0, 'electric'),

  -- Polestar
  ('Polestar', '2', 0, 0, 'electric'),
  ('Polestar', '3', 0, 0, 'electric'),
  ('Polestar', '4', 0, 0, 'electric'),

  -- Rivian
  ('Rivian', 'R1T', 0, 0, 'electric'),
  ('Rivian', 'R1S', 0, 0, 'electric'),

  -- Lucid
  ('Lucid', 'Air', 0, 0, 'electric'),
  ('Lucid', 'Gravity', 0, 0, 'electric'),

  -- BYD
  ('BYD', 'Atto 3', 0, 0, 'electric'),
  ('BYD', 'Dolphin', 0, 0, 'electric'),
  ('BYD', 'Seal', 0, 0, 'electric'),
  ('BYD', 'Han', 0, 0, 'electric'),

  -- MG
  ('MG', 'MG4', 0, 0, 'electric'),
  ('MG', 'ZS', 48, 6.5, 'gasoline'),
  ('MG', 'ZS EV', 0, 0, 'electric'),
  ('MG', 'HS', 55, 7.0, 'gasoline'),
  ('MG', 'Marvel R', 0, 0, 'electric'),

  -- Alfa Romeo
  ('Alfa Romeo', 'Giulia', 58, 6.5, 'gasoline'),
  ('Alfa Romeo', 'Stelvio', 64, 7.0, 'gasoline'),
  ('Alfa Romeo', 'Tonale', 55, 6.0, 'hybrid'),
  ('Alfa Romeo', 'Junior', 44, 5.5, 'gasoline'),

  -- Maserati
  ('Maserati', 'Levante', 80, 11.0, 'gasoline'),
  ('Maserati', 'Ghibli', 80, 10.5, 'gasoline'),
  ('Maserati', 'Quattroporte', 80, 11.0, 'gasoline'),
  ('Maserati', 'Grecale', 64, 9.5, 'gasoline'),
  ('Maserati', 'MC20', 60, 11.5, 'gasoline'),

  -- Bentley
  ('Bentley', 'Continental GT', 90, 13.0, 'gasoline'),
  ('Bentley', 'Bentayga', 85, 13.5, 'gasoline'),
  ('Bentley', 'Flying Spur', 90, 13.0, 'gasoline'),

  -- Aston Martin
  ('Aston Martin', 'DB12', 78, 11.5, 'gasoline'),
  ('Aston Martin', 'DBX', 85, 12.5, 'gasoline'),
  ('Aston Martin', 'Vantage', 73, 11.0, 'gasoline'),

  -- Lotus
  ('Lotus', 'Emira', 56, 9.5, 'gasoline'),
  ('Lotus', 'Eletre', 0, 0, 'electric'),

  -- Ferrari
  ('Ferrari', 'Roma', 80, 11.5, 'gasoline'),
  ('Ferrari', '296', 65, 9.0, 'hybrid'),
  ('Ferrari', 'SF90', 68, 10.5, 'hybrid'),
  ('Ferrari', '12Cilindri', 92, 14.0, 'gasoline'),

  -- Lamborghini
  ('Lamborghini', 'Urus', 85, 12.5, 'gasoline'),
  ('Lamborghini', 'Huracán', 80, 13.5, 'gasoline'),
  ('Lamborghini', 'Revuelto', 80, 12.0, 'hybrid'),

  -- McLaren
  ('McLaren', '720S', 72, 11.5, 'gasoline'),
  ('McLaren', '750S', 72, 11.5, 'gasoline'),
  ('McLaren', 'Artura', 72, 8.5, 'hybrid'),

  -- Toyota (more)
  ('Toyota', 'Aygo', 35, 4.3, 'gasoline'),
  ('Toyota', 'C-HR', 43, 5.0, 'hybrid'),
  ('Toyota', 'Highlander', 68, 7.2, 'hybrid'),
  ('Toyota', '4Runner', 87, 12.5, 'gasoline'),
  ('Toyota', 'Tacoma', 80, 11.0, 'gasoline'),
  ('Toyota', 'Tundra', 121, 12.5, 'gasoline'),
  ('Toyota', 'Sienna', 68, 7.0, 'hybrid'),
  ('Toyota', 'Land Cruiser', 110, 9.5, 'diesel'),
  ('Toyota', 'bZ4X', 0, 0, 'electric'),
  ('Toyota', 'Hilux', 80, 8.5, 'diesel'),
  ('Toyota', 'Prius', 43, 4.0, 'hybrid'),
  ('Toyota', 'GR86', 50, 7.5, 'gasoline'),
  ('Toyota', 'Supra', 52, 7.5, 'gasoline'),

  -- Honda (more)
  ('Honda', 'Accord', 56, 5.8, 'hybrid'),
  ('Honda', 'HR-V', 40, 5.5, 'hybrid'),
  ('Honda', 'Pilot', 73, 10.5, 'gasoline'),
  ('Honda', 'Passport', 73, 11.0, 'gasoline'),
  ('Honda', 'Odyssey', 75, 10.0, 'gasoline'),
  ('Honda', 'Ridgeline', 73, 11.0, 'gasoline'),
  ('Honda', 'e:Ny1', 0, 0, 'electric'),
  ('Honda', 'Fit', 40, 4.8, 'gasoline'),

  -- Honda motorcycles
  ('Honda Motorcycles', 'CB650R', 15.4, 5.5, 'gasoline'),
  ('Honda Motorcycles', 'CBR650R', 15.4, 5.6, 'gasoline'),
  ('Honda Motorcycles', 'CBR1000RR', 16.1, 6.5, 'gasoline'),
  ('Honda Motorcycles', 'Africa Twin', 24.8, 5.0, 'gasoline'),
  ('Honda Motorcycles', 'Gold Wing', 21.1, 5.7, 'gasoline'),
  ('Honda Motorcycles', 'Rebel 500', 11.2, 3.8, 'gasoline'),
  ('Honda Motorcycles', 'NC750X', 14.1, 3.7, 'gasoline'),

  -- Ford (more)
  ('Ford', 'Mondeo', 64, 6.0, 'diesel'),
  ('Ford', 'Mustang', 61, 11.5, 'gasoline'),
  ('Ford', 'Edge', 68, 9.5, 'gasoline'),
  ('Ford', 'Escape', 65, 7.5, 'gasoline'),
  ('Ford', 'Explorer', 76, 10.5, 'gasoline'),
  ('Ford', 'Expedition', 87, 13.0, 'gasoline'),
  ('Ford', 'Bronco', 65, 11.5, 'gasoline'),
  ('Ford', 'Mustang Mach-E', 0, 0, 'electric'),
  ('Ford', 'Puma', 42, 5.4, 'gasoline'),
  ('Ford', 'Ranger', 80, 8.5, 'diesel'),
  ('Ford', 'Transit', 70, 8.5, 'diesel'),
  ('Ford', 'Maverick', 50, 7.5, 'hybrid'),

  -- Hyundai (more)
  ('Hyundai', 'i10', 36, 5.0, 'gasoline'),
  ('Hyundai', 'i20', 40, 5.3, 'gasoline'),
  ('Hyundai', 'Bayon', 40, 5.5, 'gasoline'),
  ('Hyundai', 'Kona', 50, 6.0, 'gasoline'),
  ('Hyundai', 'Santa Fe', 67, 7.5, 'gasoline'),
  ('Hyundai', 'Ioniq 5', 0, 0, 'electric'),
  ('Hyundai', 'Ioniq 6', 0, 0, 'electric'),
  ('Hyundai', 'Palisade', 71, 11.0, 'gasoline'),
  ('Hyundai', 'Elantra', 47, 5.8, 'gasoline'),

  -- Kia (more)
  ('Kia', 'Picanto', 35, 5.2, 'gasoline'),
  ('Kia', 'Stonic', 45, 5.5, 'gasoline'),
  ('Kia', 'Niro', 42, 4.5, 'hybrid'),
  ('Kia', 'Sorento', 67, 8.0, 'diesel'),
  ('Kia', 'EV6', 0, 0, 'electric'),
  ('Kia', 'EV9', 0, 0, 'electric'),
  ('Kia', 'XCeed', 50, 5.5, 'gasoline'),
  ('Kia', 'Rio', 45, 5.5, 'gasoline'),
  ('Kia', 'Soul', 50, 7.0, 'gasoline'),
  ('Kia', 'Telluride', 71, 11.5, 'gasoline'),

  -- Nissan (more)
  ('Nissan', 'Micra', 41, 5.2, 'gasoline'),
  ('Nissan', 'Juke', 46, 5.5, 'gasoline'),
  ('Nissan', 'X-Trail', 55, 6.5, 'hybrid'),
  ('Nissan', 'Pathfinder', 71, 10.5, 'gasoline'),
  ('Nissan', 'Frontier', 80, 11.5, 'gasoline'),
  ('Nissan', 'Titan', 98, 14.5, 'gasoline'),
  ('Nissan', 'Ariya', 0, 0, 'electric'),
  ('Nissan', 'Sentra', 50, 6.8, 'gasoline'),
  ('Nissan', 'Murano', 72, 10.5, 'gasoline'),
  ('Nissan', 'Rogue', 55, 7.5, 'gasoline'),

  -- Mazda (more)
  ('Mazda', '2', 44, 5.0, 'gasoline'),
  ('Mazda', '6', 62, 6.5, 'diesel'),
  ('Mazda', 'CX-3', 48, 5.8, 'gasoline'),
  ('Mazda', 'CX-30', 51, 6.0, 'gasoline'),
  ('Mazda', 'CX-50', 64, 7.5, 'gasoline'),
  ('Mazda', 'CX-60', 50, 5.5, 'hybrid'),
  ('Mazda', 'CX-90', 75, 10.0, 'gasoline'),
  ('Mazda', 'MX-5', 45, 6.5, 'gasoline'),
  ('Mazda', 'MX-30', 0, 0, 'electric'),

  -- Skoda (more)
  ('Skoda', 'Scala', 50, 5.4, 'gasoline'),
  ('Skoda', 'Karoq', 50, 6.0, 'gasoline'),
  ('Skoda', 'Superb', 66, 5.5, 'diesel'),
  ('Skoda', 'Enyaq', 0, 0, 'electric'),
  ('Skoda', 'Kamiq', 50, 5.6, 'gasoline'),

  -- Renault (more)
  ('Renault', 'Captur', 48, 5.5, 'gasoline'),
  ('Renault', 'Twingo', 40, 4.8, 'gasoline'),
  ('Renault', 'Kadjar', 55, 6.0, 'gasoline'),
  ('Renault', 'Scenic', 47, 5.5, 'diesel'),
  ('Renault', 'Espace', 58, 6.5, 'hybrid'),
  ('Renault', 'Kangoo', 54, 5.5, 'diesel'),
  ('Renault', 'Trafic', 80, 7.5, 'diesel'),
  ('Renault', 'Master', 100, 8.5, 'diesel'),
  ('Renault', 'Zoe', 0, 0, 'electric'),
  ('Renault', 'Megane E-Tech', 0, 0, 'electric'),
  ('Renault', 'Austral', 55, 5.5, 'hybrid'),

  -- Peugeot (more)
  ('Peugeot', '108', 35, 4.3, 'gasoline'),
  ('Peugeot', '2008', 44, 5.4, 'gasoline'),
  ('Peugeot', '3008', 53, 5.8, 'gasoline'),
  ('Peugeot', '5008', 53, 5.7, 'diesel'),
  ('Peugeot', '508', 62, 5.5, 'diesel'),
  ('Peugeot', '408', 53, 5.8, 'gasoline'),
  ('Peugeot', 'Rifter', 50, 5.5, 'diesel'),
  ('Peugeot', 'Partner', 50, 5.5, 'diesel'),
  ('Peugeot', 'Boxer', 90, 8.0, 'diesel'),
  ('Peugeot', 'e-208', 0, 0, 'electric'),
  ('Peugeot', 'e-2008', 0, 0, 'electric'),
  ('Peugeot', 'e-3008', 0, 0, 'electric'),

  -- Fiat (more)
  ('Fiat', '600', 44, 5.4, 'gasoline'),
  ('Fiat', '124 Spider', 45, 6.5, 'gasoline'),
  ('Fiat', 'Doblo', 50, 5.5, 'diesel'),

  -- Tesla (more)
  ('Tesla', 'Model S', 0, 0, 'electric'),
  ('Tesla', 'Model X', 0, 0, 'electric'),
  ('Tesla', 'Cybertruck', 0, 0, 'electric'),

  -- Yamaha
  ('Yamaha', 'MT-07', 14, 4.5, 'gasoline'),
  ('Yamaha', 'MT-09', 14, 5.5, 'gasoline'),
  ('Yamaha', 'MT-10', 17, 6.5, 'gasoline'),
  ('Yamaha', 'R1', 17, 6.5, 'gasoline'),
  ('Yamaha', 'R6', 17, 6.5, 'gasoline'),
  ('Yamaha', 'Ténéré 700', 16, 4.5, 'gasoline'),
  ('Yamaha', 'XSR700', 14, 4.5, 'gasoline'),
  ('Yamaha', 'Tracer 9', 18, 5.5, 'gasoline'),

  -- Kawasaki
  ('Kawasaki', 'Z650', 15, 4.6, 'gasoline'),
  ('Kawasaki', 'Z900', 17, 5.5, 'gasoline'),
  ('Kawasaki', 'Ninja 650', 15, 4.5, 'gasoline'),
  ('Kawasaki', 'Ninja ZX-6R', 17, 6.0, 'gasoline'),
  ('Kawasaki', 'Versys 650', 21, 4.7, 'gasoline'),
  ('Kawasaki', 'Versys 1000', 21, 5.5, 'gasoline'),
  ('Kawasaki', 'Vulcan S', 14, 4.5, 'gasoline'),

  -- Suzuki motorcycles
  ('Suzuki Motorcycles', 'GSX-R600', 17, 6.0, 'gasoline'),
  ('Suzuki Motorcycles', 'GSX-R750', 17, 6.2, 'gasoline'),
  ('Suzuki Motorcycles', 'GSX-R1000', 16, 6.5, 'gasoline'),
  ('Suzuki Motorcycles', 'V-Strom 650', 20, 4.5, 'gasoline'),
  ('Suzuki Motorcycles', 'V-Strom 1050', 20, 5.5, 'gasoline'),
  ('Suzuki Motorcycles', 'Hayabusa', 20, 6.5, 'gasoline'),
  ('Suzuki Motorcycles', 'SV650', 14, 4.5, 'gasoline'),

  -- Triumph
  ('Triumph', 'Tiger 900', 20, 5.0, 'gasoline'),
  ('Triumph', 'Tiger 1200', 20, 5.5, 'gasoline'),
  ('Triumph', 'Speed Twin', 14.5, 5.0, 'gasoline'),
  ('Triumph', 'Bonneville T120', 14.5, 4.8, 'gasoline'),
  ('Triumph', 'Street Triple', 17.4, 5.5, 'gasoline'),
  ('Triumph', 'Trident 660', 14, 4.7, 'gasoline'),
  ('Triumph', 'Rocket 3', 18, 6.5, 'gasoline'),

  -- KTM
  ('KTM', 'Duke 390', 13.4, 3.5, 'gasoline'),
  ('KTM', 'Duke 690', 14, 4.5, 'gasoline'),
  ('KTM', 'Duke 890', 14, 5.0, 'gasoline'),
  ('KTM', '1290 Super Duke', 17.5, 6.5, 'gasoline'),
  ('KTM', '390 Adventure', 14.5, 3.5, 'gasoline'),
  ('KTM', '890 Adventure', 20, 4.8, 'gasoline'),
  ('KTM', '1290 Super Adventure', 23, 5.5, 'gasoline'),

  -- Harley-Davidson
  ('Harley-Davidson', 'Sportster S', 11.8, 5.0, 'gasoline'),
  ('Harley-Davidson', 'Iron 883', 12.5, 5.5, 'gasoline'),
  ('Harley-Davidson', 'Street Glide', 22.7, 5.7, 'gasoline'),
  ('Harley-Davidson', 'Road Glide', 22.7, 5.7, 'gasoline'),
  ('Harley-Davidson', 'Fat Boy', 18.9, 5.5, 'gasoline'),
  ('Harley-Davidson', 'Pan America', 21.2, 5.5, 'gasoline'),

  -- Aprilia
  ('Aprilia', 'Tuono V4', 18.5, 6.5, 'gasoline'),
  ('Aprilia', 'RSV4', 18.5, 6.5, 'gasoline'),
  ('Aprilia', 'Tuareg 660', 18, 4.5, 'gasoline'),
  ('Aprilia', 'RS 660', 15, 4.5, 'gasoline'),

  -- MV Agusta
  ('MV Agusta', 'Brutale', 16.6, 6.0, 'gasoline'),
  ('MV Agusta', 'F3', 16.5, 6.0, 'gasoline'),

  -- Royal Enfield
  ('Royal Enfield', 'Classic 350', 13, 3.5, 'gasoline'),
  ('Royal Enfield', 'Himalayan', 15, 3.5, 'gasoline'),
  ('Royal Enfield', 'Interceptor 650', 13.7, 4.5, 'gasoline'),
  ('Royal Enfield', 'Continental GT 650', 12.5, 4.5, 'gasoline'),
  ('Royal Enfield', 'Meteor 350', 15, 3.5, 'gasoline'),

  -- Indian Motorcycle
  ('Indian Motorcycle', 'Scout', 12.5, 5.0, 'gasoline'),
  ('Indian Motorcycle', 'Chief', 15, 5.5, 'gasoline'),
  ('Indian Motorcycle', 'Roadmaster', 20.8, 5.5, 'gasoline'),

  -- Ducati (more)
  ('Ducati', 'Panigale V4', 16, 6.5, 'gasoline'),
  ('Ducati', 'Streetfighter V4', 16, 6.5, 'gasoline'),
  ('Ducati', 'Diavel', 17, 6.0, 'gasoline'),
  ('Ducati', 'DesertX', 21, 5.0, 'gasoline'),
  ('Ducati', 'Hypermotard', 14.5, 5.5, 'gasoline'),
  ('Ducati', 'Scrambler', 14, 5.0, 'gasoline');
