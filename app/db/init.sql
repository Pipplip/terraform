CREATE TABLE IF NOT EXISTS uploads (
   id          SERIAL PRIMARY KEY,
   key         TEXT        NOT NULL,
   filename    TEXT,
   uploaded_at TIMESTAMPTZ DEFAULT NOW()
);