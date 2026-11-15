-- Free Cloud Stack Database Schema
-- Run via: supabase db push (local) or supabase migration up (cloud)

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Health check table
CREATE TABLE IF NOT EXISTS health_check (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  status TEXT NOT NULL DEFAULT 'ok',
  checked_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
INSERT INTO health_check (status) VALUES ('ok') ON CONFLICT DO NOTHING;

-- Example: Users table (Supabase Auth handles auth, this is profile data)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Example: File uploads metadata
CREATE TABLE IF NOT EXISTS uploads (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  r2_key TEXT NOT NULL,
  original_name TEXT NOT NULL,
  content_type TEXT NOT NULL,
  size_bytes BIGINT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- RLS policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE uploads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public profiles readable" ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can update own profile" ON profiles FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can view own uploads" ON uploads FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own uploads" ON uploads FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Storage bucket for avatars (create via Supabase dashboard or SQL)
-- INSERT INTO storage.buckets (id, name, public) VALUES ('avatars', 'avatars', true);