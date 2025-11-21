-- SQL script to create the globe_daily_data table in Supabase
-- Run this in your Supabase SQL Editor before deploying the scraper

-- Create the table for daily scraped product data
CREATE TABLE IF NOT EXISTS public.globe_daily_data (
    id BIGSERIAL PRIMARY KEY,
    url TEXT,
    product_name TEXT,
    product_code TEXT,
    sku TEXT,
    price TEXT,
    availability TEXT,
    product_quantity TEXT,
    description TEXT,
    status TEXT,
    scraped_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes for common queries
CREATE INDEX IF NOT EXISTS idx_globe_daily_data_scraped_at ON public.globe_daily_data(scraped_at DESC);
CREATE INDEX IF NOT EXISTS idx_globe_daily_data_product_name ON public.globe_daily_data(product_name);
CREATE INDEX IF NOT EXISTS idx_globe_daily_data_sku ON public.globe_daily_data(sku) WHERE sku IS NOT NULL;

-- Add comments to table and columns
COMMENT ON TABLE public.globe_daily_data IS 'Daily scraped product data from Globe Pest Solutions website';
COMMENT ON COLUMN public.globe_daily_data.url IS 'Product page URL';
COMMENT ON COLUMN public.globe_daily_data.product_name IS 'Product name/title';
COMMENT ON COLUMN public.globe_daily_data.product_code IS 'Product code (if different from SKU)';
COMMENT ON COLUMN public.globe_daily_data.sku IS 'Stock Keeping Unit identifier';
COMMENT ON COLUMN public.globe_daily_data.price IS 'Product price as text (includes currency symbol)';
COMMENT ON COLUMN public.globe_daily_data.availability IS 'Stock availability status';
COMMENT ON COLUMN public.globe_daily_data.product_quantity IS 'Product quantity (if available)';
COMMENT ON COLUMN public.globe_daily_data.description IS 'Product description (first 200 characters)';
COMMENT ON COLUMN public.globe_daily_data.status IS 'Scraping status (success or error message)';
COMMENT ON COLUMN public.globe_daily_data.scraped_at IS 'Timestamp when data was scraped';
COMMENT ON COLUMN public.globe_daily_data.created_at IS 'Timestamp when record was inserted into database';

-- Grant permissions (adjust as needed for your security requirements)
-- This allows the service role to insert data
ALTER TABLE public.globe_daily_data ENABLE ROW LEVEL SECURITY;

-- Create policy for service role (allows the scraper to insert data)
CREATE POLICY "Enable insert for service role" ON public.globe_daily_data
    FOR INSERT
    WITH CHECK (true);

-- Create policy to allow authenticated users to read data
CREATE POLICY "Enable read for authenticated users" ON public.globe_daily_data
    FOR SELECT
    USING (true);

-- Verify table creation
SELECT 
    table_name, 
    column_name, 
    data_type, 
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
    AND table_name = 'globe_daily_data'
ORDER BY ordinal_position;
