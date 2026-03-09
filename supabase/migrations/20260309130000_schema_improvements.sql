-- 1. Add updated_at to profiles, organizations, services, appointments
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE organizations ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE services ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE appointments ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- Auto-update trigger check and creation
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$ BEGIN NEW.updated_at = NOW(); RETURN NEW; END; $$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS profiles_updated_at ON profiles;
CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS organizations_updated_at ON organizations;
CREATE TRIGGER organizations_updated_at BEFORE UPDATE ON organizations FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS services_updated_at ON services;
CREATE TRIGGER services_updated_at BEFORE UPDATE ON services FOR EACH ROW EXECUTE FUNCTION update_updated_at();

DROP TRIGGER IF EXISTS appointments_updated_at ON appointments;
CREATE TRIGGER appointments_updated_at BEFORE UPDATE ON appointments FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- 2. Add useful columns
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS avatar_url TEXT;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS email TEXT;

ALTER TABLE services ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE services ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true;
ALTER TABLE services ADD COLUMN IF NOT EXISTS max_participants INTEGER DEFAULT 1;

-- 3. RLS for services (org members can read, owners can write)
ALTER TABLE services ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Org members can view services" ON services;
CREATE POLICY "Org members can view services" ON services FOR SELECT TO authenticated
USING (organization_id IN (SELECT organization_id FROM user_organizations WHERE user_id = auth.uid()));

DROP POLICY IF EXISTS "Owners can manage services" ON services;
CREATE POLICY "Owners can manage services" ON services FOR ALL TO authenticated
USING (organization_id IN (SELECT organization_id FROM user_organizations WHERE user_id = auth.uid() AND role = 'OWNER'));

-- 4. RLS for appointments
ALTER TABLE appointments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own appointments" ON appointments;
CREATE POLICY "Users can view own appointments" ON appointments FOR SELECT TO authenticated
USING (client_id = auth.uid() OR staff_id = auth.uid());

DROP POLICY IF EXISTS "Org members can manage appointments" ON appointments;
CREATE POLICY "Org members can manage appointments" ON appointments FOR ALL TO authenticated
USING (organization_id IN (SELECT organization_id FROM user_organizations WHERE user_id = auth.uid()));

-- 5. Organizations read access for members
DROP POLICY IF EXISTS "Org members can view organization" ON organizations;
CREATE POLICY "Org members can view organization" ON organizations FOR SELECT TO authenticated
USING (id IN (SELECT organization_id FROM user_organizations WHERE user_id = auth.uid()));

-- 6. Staff schedules table
CREATE TABLE IF NOT EXISTS public.staff_schedules (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  day_of_week INTEGER NOT NULL CHECK (day_of_week BETWEEN 0 AND 6),
  start_time TIME NOT NULL,
  end_time TIME NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, organization_id, day_of_week)
);

DROP TRIGGER IF EXISTS staff_schedules_updated_at ON staff_schedules;
CREATE TRIGGER staff_schedules_updated_at BEFORE UPDATE ON staff_schedules FOR EACH ROW EXECUTE FUNCTION update_updated_at();
