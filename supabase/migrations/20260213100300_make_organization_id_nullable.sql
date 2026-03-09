-- Make organization_id nullable to support clients without organizations
ALTER TABLE public.profiles 
ALTER COLUMN organization_id DROP NOT NULL;
