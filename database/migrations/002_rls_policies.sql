-- ============================================================
-- NirSisa Row Level Security (RLS) Policies
-- Supabase Auth integration
-- Run this AFTER 001_schema.sql
-- ============================================================

-- Enable RLS on all user-facing tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_stock ENABLE ROW LEVEL SECURITY;
ALTER TABLE consumption_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE consumption_history_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE device_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE notification_log ENABLE ROW LEVEL SECURITY;

-- Recipes & reference tables: public read, no user writes
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE ingredient_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE shelf_life_reference ENABLE ROW LEVEL SECURITY;
ALTER TABLE recipe_tfidf_cache ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- PROFILES
-- ============================================================
CREATE POLICY "Users can view own profile"
    ON profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- ============================================================
-- INVENTORY_STOCK
-- ============================================================
CREATE POLICY "Users can view own inventory"
    ON inventory_stock FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own inventory"
    ON inventory_stock FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own inventory"
    ON inventory_stock FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own inventory"
    ON inventory_stock FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================
-- CONSUMPTION_HISTORY
-- ============================================================
CREATE POLICY "Users can view own consumption history"
    ON consumption_history FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own consumption history"
    ON consumption_history FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- CONSUMPTION_HISTORY_ITEMS
-- ============================================================
CREATE POLICY "Users can view own consumption items"
    ON consumption_history_items FOR SELECT
    USING (
        consumption_id IN (
            SELECT id FROM consumption_history WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert own consumption items"
    ON consumption_history_items FOR INSERT
    WITH CHECK (
        consumption_id IN (
            SELECT id FROM consumption_history WHERE user_id = auth.uid()
        )
    );

-- ============================================================
-- DEVICE_TOKENS
-- ============================================================
CREATE POLICY "Users can view own device tokens"
    ON device_tokens FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own device tokens"
    ON device_tokens FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own device tokens"
    ON device_tokens FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own device tokens"
    ON device_tokens FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================
-- NOTIFICATION_LOG
-- ============================================================
CREATE POLICY "Users can view own notifications"
    ON notification_log FOR SELECT
    USING (auth.uid() = user_id);

-- ============================================================
-- PUBLIC READ-ONLY TABLES (recipes, categories, shelf-life)
-- ============================================================
CREATE POLICY "Anyone authenticated can read recipes"
    ON recipes FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Anyone authenticated can read recipe categories"
    ON recipe_categories FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Anyone authenticated can read ingredient categories"
    ON ingredient_categories FOR SELECT
    USING (auth.role() = 'authenticated');

CREATE POLICY "Anyone authenticated can read shelf life reference"
    ON shelf_life_reference FOR SELECT
    USING (auth.role() = 'authenticated');

-- TF-IDF cache: only service role can write, authenticated can read
CREATE POLICY "Authenticated users can read tfidf cache"
    ON recipe_tfidf_cache FOR SELECT
    USING (auth.role() = 'authenticated');
