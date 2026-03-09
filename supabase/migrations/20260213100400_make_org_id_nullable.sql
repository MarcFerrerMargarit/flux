-- Make organization_id nullable in profiles table
-- This allows users to be created without immediately belonging to an organization

ALTER TABLE public.profiles 
ALTER COLUMN organization_id DROP NOT NULL;
