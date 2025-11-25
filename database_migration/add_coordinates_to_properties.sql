-- Migration: Add latitude and longitude columns to properties table
-- This enables location-based distance searches

-- Add coordinate columns
ALTER TABLE properties
ADD COLUMN latitude DECIMAL(10, 8) NULL AFTER postal_code,
ADD COLUMN longitude DECIMAL(11, 8) NULL AFTER latitude;

-- Add indexes for better geospatial query performance
CREATE INDEX idx_latitude ON properties(latitude);
CREATE INDEX idx_longitude ON properties(longitude);
CREATE INDEX idx_coordinates ON properties(latitude, longitude);

-- Note: Existing properties will have NULL coordinates
-- You can populate them by geocoding the addresses using the OSM integration
-- or by updating them when properties are edited

