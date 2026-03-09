-- Trigger function to automatically create profile and organization after user signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger AS $$
DECLARE
  new_organization_id UUID;
  user_role TEXT;
  full_name TEXT;
  phone TEXT;
  organization_name TEXT;
  invite_code_str TEXT;
BEGIN
  -- Extract variables from raw_user_meta_data
  user_role := NEW.raw_user_meta_data->>'role';
  full_name := NEW.raw_user_meta_data->>'full_name';
  phone := NEW.raw_user_meta_data->>'phone';
  organization_name := NEW.raw_user_meta_data->>'organization_name';

  -- If the user is an OWNER, create their organization first
  IF user_role = 'OWNER' AND organization_name IS NOT NULL THEN
    -- Generate simple invite code
    invite_code_str := UPPER(SUBSTRING(REGEXP_REPLACE(organization_name, '[^a-zA-Z]', '', 'g'), 1, 4)) || '-' || LPAD(CAST(MOD(CAST(EXTRACT(EPOCH FROM NOW()) * 1000 AS BIGINT), 10000) AS TEXT), 4, '0');
    
    INSERT INTO public.organizations (name, invite_code)
    VALUES (organization_name, invite_code_str)
    RETURNING id INTO new_organization_id;

    -- Insert profile linked to new organization
    INSERT INTO public.profiles (id, organization_id, role, full_name, phone)
    VALUES (NEW.id, new_organization_id, 'OWNER', full_name, phone);

    -- Insert into user_organizations
    INSERT INTO public.user_organizations (user_id, organization_id, role, is_primary)
    VALUES (NEW.id, new_organization_id, 'OWNER', true);
    
  ELSE
    -- For CLIENT or other roles, just insert profile without organization
    INSERT INTO public.profiles (id, role, full_name, phone)
    VALUES (NEW.id, COALESCE(user_role, 'CLIENT'), full_name, phone);
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger definition
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
