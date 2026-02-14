-- Add invite_code column to organizations table
ALTER TABLE public.organizations 
ADD COLUMN invite_code TEXT UNIQUE;

-- Create index for faster lookups
CREATE INDEX idx_organizations_invite_code ON organizations(invite_code);

-- Function to generate random invite code
CREATE OR REPLACE FUNCTION generate_invite_code()
RETURNS TEXT AS $$
DECLARE
  code TEXT;
  exists BOOLEAN;
BEGIN
  LOOP
    -- Generate 6-character alphanumeric code
    code := upper(substring(md5(random()::text) from 1 for 6));
    
    -- Check if code already exists
    SELECT EXISTS(SELECT 1 FROM organizations WHERE invite_code = code) INTO exists;
    
    EXIT WHEN NOT exists;
  END LOOP;
  
  RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Generate invite codes for existing organizations
UPDATE organizations 
SET invite_code = generate_invite_code() 
WHERE invite_code IS NULL;
