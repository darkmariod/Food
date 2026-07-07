-- Conversation state for the WhatsApp bot (one row per customer phone).
-- Run this in the Supabase SQL editor (schema.sql was already applied).
CREATE TABLE IF NOT EXISTS conversation_state (
  phone TEXT PRIMARY KEY,
  state TEXT NOT NULL DEFAULT 'idle',
  data JSONB NOT NULL DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- No public policy on purpose: only the bot (service_role) reads/writes this table.
ALTER TABLE conversation_state ENABLE ROW LEVEL SECURITY;
