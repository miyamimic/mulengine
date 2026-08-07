/*
# Create roleplay engine tables (single-tenant, no auth)

1. New Tables
- `rp_sessions`: stores one conversation session. Columns:
  - id (uuid, pk)
  - character_id (text, not null) — which character the user is talking to
  - emotion (jsonb) — six-dimensional emotion vector (anger/fear/joy/sadness/desire/warmth)
  - background_threads (jsonb) — active background thoughts with remaining turns
  - triggered_anchors (jsonb) — memory anchors triggered during the conversation
  - created_at (timestamptz)
  - updated_at (timestamptz)
- `rp_messages`: stores messages within a session. Columns:
  - id (uuid, pk)
  - session_id (uuid, fk to rp_sessions, cascade delete)
  - role (text: 'user' or 'character')
  - content (text)
  - segments (jsonb) — parsed message segments (speech/action/thought)
  - character_id (text, nullable) — for character messages, which character
  - created_at (timestamptz)

2. Security
- Enable RLS on both tables.
- Allow anon + authenticated full CRUD because the data is intentionally shared/public (no sign-in screen).
*/

CREATE TABLE IF NOT EXISTS rp_sessions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  character_id text NOT NULL,
  emotion jsonb NOT NULL DEFAULT '{}'::jsonb,
  background_threads jsonb NOT NULL DEFAULT '[]'::jsonb,
  triggered_anchors jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS rp_messages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  session_id uuid NOT NULL REFERENCES rp_sessions(id) ON DELETE CASCADE,
  role text NOT NULL,
  content text NOT NULL DEFAULT '',
  segments jsonb NOT NULL DEFAULT '[]'::jsonb,
  character_id text,
  created_at timestamptz DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_rp_messages_session_id ON rp_messages(session_id);

ALTER TABLE rp_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE rp_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "anon_select_rp_sessions" ON rp_sessions;
CREATE POLICY "anon_select_rp_sessions" ON rp_sessions FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_rp_sessions" ON rp_sessions;
CREATE POLICY "anon_insert_rp_sessions" ON rp_sessions FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_rp_sessions" ON rp_sessions;
CREATE POLICY "anon_update_rp_sessions" ON rp_sessions FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_rp_sessions" ON rp_sessions;
CREATE POLICY "anon_delete_rp_sessions" ON rp_sessions FOR DELETE
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_select_rp_messages" ON rp_messages;
CREATE POLICY "anon_select_rp_messages" ON rp_messages FOR SELECT
  TO anon, authenticated USING (true);

DROP POLICY IF EXISTS "anon_insert_rp_messages" ON rp_messages;
CREATE POLICY "anon_insert_rp_messages" ON rp_messages FOR INSERT
  TO anon, authenticated WITH CHECK (true);

DROP POLICY IF EXISTS "anon_update_rp_messages" ON rp_messages;
CREATE POLICY "anon_update_rp_messages" ON rp_messages FOR UPDATE
  TO anon, authenticated USING (true) WITH CHECK (true);

DROP POLICY IF EXISTS "anon_delete_rp_messages" ON rp_messages;
CREATE POLICY "anon_delete_rp_messages" ON rp_messages FOR DELETE
  TO anon, authenticated USING (true);