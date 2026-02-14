-- Create a function to handle profile creation with elevated privileges
-- This function can be called by authenticated users to create their own profile

CREATE OR REPLACE FUNCTION public.create_user_profile(
  user_id UUID,
  user_role TEXT,
  user_full_name TEXT,
  user_phone TEXT DEFAULT NULL,
  user_organization_id UUID DEFAULT NULL
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER -- Run with the privileges of the function owner (bypasses RLS)
SET search_path = public
AS $$
BEGIN
  -- Only allow users to create their own profile
  IF auth.uid() != user_id THEN
    RAISE EXCEPTION 'You can only create your own profile';
  END IF;

  -- Insert the profile
  INSERT INTO public.profiles (id, organization_id, role, full_name, phone)
  VALUES (user_id, user_organization_id, user_role, user_full_name, user_phone);
END;
$$;

-- Grant execute permission to authenticated users
GRANT EXECUTE ON FUNCTION public.create_user_profile TO authenticated;
