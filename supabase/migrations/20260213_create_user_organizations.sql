-- Create user_organizations junction table for multi-organization support
CREATE TABLE public.user_organizations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  organization_id UUID NOT NULL REFERENCES organizations(id) ON DELETE CASCADE,
  role TEXT NOT NULL CHECK (role IN ('OWNER', 'PRO', 'CLIENT')),
  is_primary BOOLEAN DEFAULT false,
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, organization_id)
);

-- Create indexes for faster queries
CREATE INDEX idx_user_organizations_user_id ON user_organizations(user_id);
CREATE INDEX idx_user_organizations_organization_id ON user_organizations(organization_id);
CREATE INDEX idx_user_organizations_primary ON user_organizations(user_id, is_primary);

-- Enable RLS
ALTER TABLE user_organizations ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can view their own organization memberships"
ON user_organizations
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own organization memberships"
ON user_organizations
FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own organization memberships"
ON user_organizations
FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own organization memberships"
ON user_organizations
FOR DELETE
TO authenticated
USING (auth.uid() = user_id);

-- Migrate existing data from profiles to user_organizations
INSERT INTO user_organizations (user_id, organization_id, role, is_primary)
SELECT id, organization_id, role, true
FROM profiles
WHERE organization_id IS NOT NULL;
