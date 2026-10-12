-- ============================================================
-- SocFir (SocialFire) — Supabase SQL Schema
-- Run this in your Supabase SQL editor
-- ============================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── USERS ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.socfir_users (
  id            UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username      TEXT UNIQUE NOT NULL,
  display_name  TEXT,
  email         TEXT NOT NULL,
  avatar_url    TEXT,
  bio           TEXT DEFAULT '',
  age           INT,
  education     TEXT DEFAULT '',
  jobs          TEXT[] DEFAULT '{}',
  hobbies       TEXT[] DEFAULT '{}',
  projects      TEXT[] DEFAULT '{}',
  followers_count INT DEFAULT 0,
  following_count INT DEFAULT 0,
  posts_count   INT DEFAULT 0,
  likes_count   INT DEFAULT 0,
  views_count   INT DEFAULT 0,
  leaderboard_score FLOAT DEFAULT 0,
  leaderboard_rank  INT DEFAULT 0,
  is_onboarded  BOOLEAN DEFAULT FALSE,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ─── FOLLOWS ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.follows (
  follower_id   UUID REFERENCES public.socfir_users(id) ON DELETE CASCADE,
  following_id  UUID REFERENCES public.socfir_users(id) ON DELETE CASCADE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id)
);

-- ─── POSTS ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.posts (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id       UUID REFERENCES public.socfir_users(id) ON DELETE CASCADE,
  type          TEXT NOT NULL CHECK (type IN ('text','image','card','video','gif','link','repost','shitpost')),
  content       TEXT DEFAULT '',
  media_urls    TEXT[] DEFAULT '{}',
  link_url      TEXT,
  link_title    TEXT,
  link_image    TEXT,
  visibility    TEXT DEFAULT 'public' CHECK (visibility IN ('public','friends','community')),
  community_id  UUID,
  repost_of     UUID REFERENCES public.posts(id) ON DELETE SET NULL,
  is_sensitive  BOOLEAN DEFAULT FALSE,
  likes_count   INT DEFAULT 0,
  comments_count INT DEFAULT 0,
  reposts_count INT DEFAULT 0,
  views_count   INT DEFAULT 0,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

-- ─── REACTIONS ────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.reactions (
  id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id   UUID REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id   UUID REFERENCES public.socfir_users(id) ON DELETE CASCADE,
  type      TEXT DEFAULT 'like',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(post_id, user_id)
);

-- ─── COMMENTS ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.comments (
  id        UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  post_id   UUID REFERENCES public.posts(id) ON DELETE CASCADE,
  user_id   UUID REFERENCES public.socfir_users(id) ON DELETE CASCADE,
  content   TEXT NOT NULL,
  parent_id UUID REFERENCES public.comments(id) ON DELETE CASCADE,
  likes_count INT DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── COMMUNITIES ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.communities (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name            TEXT NOT NULL,
  description     TEXT DEFAULT '',
  avatar_url      TEXT,
  banner_url      TEXT,
  creator_id      UUID REFERENCES public.socfir_users(id) ON DELETE SET NULL,
  age_restriction TEXT DEFAULT 'all' CHECK (age_restriction IN ('all','13plus','18plus')),
  is_private      BOOLEAN DEFAULT FALSE,
  members_count   INT DEFAULT 0,
  posts_count     INT DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ─── COMMUNITY MEMBERS ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.community_members (
  community_id UUID REFERENCES public.communities(id) ON DELETE CASCADE,
  user_id      UUID REFERENCES public.socfir_users(id) ON DELETE CASCADE,
  role         TEXT DEFAULT 'member' CHECK (role IN ('member','mod','admin')),
  joined_at    TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (community_id, user_id)
);

-- ─── CHATS ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.chats (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  type         TEXT DEFAULT 'dm' CHECK (type IN ('dm','group')),
  name         TEXT,
  avatar_url   TEXT,
  community_id UUID REFERENCES public.communities(id) ON DELETE CASCADE,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- ─── CHAT MEMBERS ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.chat_members (
  chat_id  UUID REFERENCES public.chats(id) ON DELETE CASCADE,
  user_id  UUID REFERENCES public.socfir_users(id) ON DELETE CASCADE,
  PRIMARY KEY (chat_id, user_id)
);

-- ─── MESSAGES ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.messages (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  chat_id    UUID REFERENCES public.chats(id) ON DELETE CASCADE,
  sender_id  UUID REFERENCES public.socfir_users(id) ON DELETE SET NULL,
  content    TEXT DEFAULT '',
  type       TEXT DEFAULT 'text' CHECK (type IN ('text','image','gif')),
  media_url  TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── NOTIFICATIONS ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.notifications (
  id         UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id    UUID REFERENCES public.socfir_users(id) ON DELETE CASCADE,
  type       TEXT CHECK (type IN ('like','comment','follow','repost','mention','dm')),
  actor_id   UUID REFERENCES public.socfir_users(id) ON DELETE CASCADE,
  post_id    UUID REFERENCES public.posts(id) ON DELETE CASCADE,
  message    TEXT,
  is_read    BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ─── SAVED POSTS ──────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.saved_posts (
  user_id  UUID REFERENCES public.socfir_users(id) ON DELETE CASCADE,
  post_id  UUID REFERENCES public.posts(id) ON DELETE CASCADE,
  saved_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, post_id)
);

-- ─── ROW LEVEL SECURITY ───────────────────────────────────────
ALTER TABLE public.socfir_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.communities ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.community_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_posts ENABLE ROW LEVEL SECURITY;

-- Basic public read policies
CREATE POLICY "Public profiles" ON public.socfir_users FOR SELECT USING (true);
CREATE POLICY "Public posts" ON public.posts FOR SELECT USING (visibility = 'public');
CREATE POLICY "Public communities" ON public.communities FOR SELECT USING (true);

-- Authenticated write policies
CREATE POLICY "Own profile update" ON public.socfir_users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Insert own post" ON public.posts FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Own reaction" ON public.reactions FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Own comment" ON public.comments FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "Own follow" ON public.follows FOR ALL USING (auth.uid() = follower_id);
CREATE POLICY "Own notifications" ON public.notifications FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Chat member messages" ON public.messages FOR SELECT USING (
  EXISTS (SELECT 1 FROM public.chat_members WHERE chat_id = messages.chat_id AND user_id = auth.uid())
);
CREATE POLICY "Send messages" ON public.messages FOR INSERT WITH CHECK (auth.uid() = sender_id);

-- ─── LEADERBOARD SCORE FUNCTION ───────────────────────────────
CREATE OR REPLACE FUNCTION update_leaderboard_scores()
RETURNS void LANGUAGE plpgsql AS $$
BEGIN
  UPDATE public.socfir_users
  SET leaderboard_score = (
    followers_count * 3.0 +
    likes_count * 1.0 +
    views_count * 0.1 +
    posts_count * 0.5
  );

  WITH ranked AS (
    SELECT id, ROW_NUMBER() OVER (ORDER BY leaderboard_score DESC) AS rk
    FROM public.socfir_users
  )
  UPDATE public.socfir_users u
  SET leaderboard_rank = r.rk
  FROM ranked r WHERE u.id = r.id;
END;
$$;

-- Enable Realtime for messages and notifications
ALTER PUBLICATION supabase_realtime ADD TABLE public.messages;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
