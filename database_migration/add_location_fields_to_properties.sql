-- Migration: Add specific location fields to properties table
-- This allows for more precise location filtering and searching

-- Add new location fields
ALTER TABLE properties
ADD COLUMN street VARCHAR(255) NULL AFTER address,
ADD COLUMN barangay VARCHAR(100) NULL AFTER street,
ADD COLUMN postal_code VARCHAR(20) NULL AFTER province;

-- Add indexes for better search performance
CREATE INDEX idx_barangay ON properties(barangay);
CREATE INDEX idx_street ON properties(street);
CREATE INDEX idx_city_barangay ON properties(city, barangay);

-- Optional: Update existing records if address contains structured data
-- This is a basic example - you may need to adjust based on your data format
-- UPDATE properties 
-- SET street = SUBSTRING_INDEX(SUBSTRING_INDEX(address, ',', 1), ',', -1),
--     barangay = CASE 
--         WHEN address LIKE '%,%' THEN SUBSTRING_INDEX(SUBSTRING_INDEX(address, ',', 2), ',', -1)
--         ELSE NULL
--     END
-- WHERE street IS NULL AND address IS NOT NULL;

-- Note: The UPDATE above is commented out because address formats may vary
-- You should manually review and update existing records, or create a script
-- to parse addresses based on your specific data format

