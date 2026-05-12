-- Supabase Schema for Campus Mart

-- Users Table
CREATE TABLE public.users (
  uid UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  "photoUrl" TEXT,
  college TEXT,
  "createdAt" TIMESTAMPTZ DEFAULT NOW(),
  wishlist TEXT[] DEFAULT '{}'
);

-- Listings Table
CREATE TABLE public.listings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  price REAL NOT NULL,
  category TEXT NOT NULL,
  images TEXT[] DEFAULT '{}',
  "sellerId" UUID REFERENCES public.users(uid) ON DELETE CASCADE,
  "sellerName" TEXT NOT NULL,
  "sellerPhoto" TEXT,
  location TEXT NOT NULL,
  "isActive" BOOLEAN DEFAULT TRUE,
  "isForRent" BOOLEAN DEFAULT FALSE,
  "rentPeriod" TEXT, -- 'day', 'week', 'month'
  views INTEGER DEFAULT 0,
  "createdAt" TIMESTAMPTZ DEFAULT NOW()
);

-- Chats Table
CREATE TABLE public.chats (
  id TEXT PRIMARY KEY,
  participants UUID[] NOT NULL,
  "listingId" UUID REFERENCES public.listings(id) ON DELETE CASCADE,
  "listingTitle" TEXT,
  "listingImage" TEXT,
  "lastMessage" TEXT,
  "lastMessageTime" TIMESTAMPTZ,
  "createdAt" TIMESTAMPTZ DEFAULT NOW()
);

-- Messages Table
CREATE TABLE public.messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "chatId" TEXT REFERENCES public.chats(id) ON DELETE CASCADE,
  "senderId" UUID REFERENCES public.users(uid) ON DELETE CASCADE,
  "senderName" TEXT,
  text TEXT NOT NULL,
  type TEXT DEFAULT 'text', -- 'text' or 'bid'
  "bidAmount" REAL,
  "bidStatus" TEXT DEFAULT 'pending', -- 'pending', 'accepted', 'rejected'
  "createdAt" TIMESTAMPTZ DEFAULT NOW()
);

-- Note: Ensure to enable Realtime for tables: listings, chats, and messages in the Supabase Dashboard.

-- PROFILE SYNC TRIGGER
-- Automatically create a profile in public.users when a new user signs up via Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (uid, name, email, phone, "photoUrl")
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'name', 'User'),
    COALESCE(NEW.email, ''),
    COALESCE(NEW.phone, ''),
    COALESCE(NEW.raw_user_meta_data->>'avatar_url', '')
  )
  ON CONFLICT (uid) DO NOTHING;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
