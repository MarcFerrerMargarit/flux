-- Migration: Add missing columns to services table (safeguard)
-- The push command failed previously, so we ensure the columns exist now.

DO $$ 
BEGIN 
    -- Check if description exists, if not add it
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='description') THEN
        ALTER TABLE public.services ADD COLUMN description TEXT;
    END IF;

    -- Check if is_active exists, if not add it
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='is_active') THEN
        ALTER TABLE public.services ADD COLUMN is_active BOOLEAN DEFAULT true;
    END IF;

    -- Check if max_participants exists, if not add it
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='services' AND column_name='max_participants') THEN
        ALTER TABLE public.services ADD COLUMN max_participants INTEGER DEFAULT 1;
    END IF;
END $$;
