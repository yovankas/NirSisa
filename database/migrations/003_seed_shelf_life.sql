-- ============================================================
-- NirSisa Shelf-Life Reference Seed Data
-- Based on BPOM Indonesia & food science literature
-- Storage condition: kulkas (refrigerator ~4°C)
-- ============================================================

-- Ingredient Categories
INSERT INTO ingredient_categories (name) VALUES
    ('sayur'),
    ('buah'),
    ('daging_sapi'),
    ('daging_ayam'),
    ('daging_kambing'),
    ('ikan_segar'),
    ('udang'),
    ('telur'),
    ('tahu'),
    ('tempe'),
    ('dairy'),
    ('bumbu_segar'),
    ('bumbu_kering'),
    ('bahan_olahan'),
    ('minyak_lemak'),
    ('tepung_kering'),
    ('kacang_biji'),
    ('roti_bakery')
ON CONFLICT (name) DO NOTHING;

-- Recipe Categories (matching CSV)
INSERT INTO recipe_categories (name) VALUES
    ('ayam'),
    ('ikan'),
    ('kambing'),
    ('sapi'),
    ('tahu'),
    ('telur'),
    ('tempe'),
    ('udang')
ON CONFLICT (name) DO NOTHING;

-- ============================================================
-- Shelf-Life Reference Data (kulkas ~4°C)
-- ============================================================

-- SAYUR (vegetables)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('bayam', (SELECT id FROM ingredient_categories WHERE name='sayur'), 3, 'kulkas', 'BPOM/Literatur'),
    ('kangkung', (SELECT id FROM ingredient_categories WHERE name='sayur'), 3, 'kulkas', 'BPOM/Literatur'),
    ('sawi', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'BPOM/Literatur'),
    ('wortel', (SELECT id FROM ingredient_categories WHERE name='sayur'), 14, 'kulkas', 'BPOM/Literatur'),
    ('kentang', (SELECT id FROM ingredient_categories WHERE name='sayur'), 21, 'kulkas', 'BPOM/Literatur'),
    ('brokoli', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'BPOM/Literatur'),
    ('kol', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'BPOM/Literatur'),
    ('tomat', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'BPOM/Literatur'),
    ('terong', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'BPOM/Literatur'),
    ('cabai merah', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'BPOM/Literatur'),
    ('cabai rawit', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'BPOM/Literatur'),
    ('cabai hijau', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'BPOM/Literatur'),
    ('labu siam', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'BPOM/Literatur'),
    ('jagung', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'BPOM/Literatur'),
    ('kacang panjang', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'BPOM/Literatur'),
    ('buncis', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'BPOM/Literatur'),
    ('tauge', (SELECT id FROM ingredient_categories WHERE name='sayur'), 2, 'kulkas', 'BPOM/Literatur'),
    ('jamur', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'BPOM/Literatur'),
    ('daun bawang', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'BPOM/Literatur'),
    ('seledri', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'BPOM/Literatur'),
    ('timun', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'BPOM/Literatur'),
    ('pare', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'BPOM/Literatur'),
    ('paprika', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'BPOM/Literatur'),
    ('lobak', (SELECT id FROM ingredient_categories WHERE name='sayur'), 14, 'kulkas', 'BPOM/Literatur'),
    ('rebung', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- BUAH (fruits)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('pisang', (SELECT id FROM ingredient_categories WHERE name='buah'), 5, 'kulkas', 'BPOM/Literatur'),
    ('apel', (SELECT id FROM ingredient_categories WHERE name='buah'), 21, 'kulkas', 'BPOM/Literatur'),
    ('jeruk', (SELECT id FROM ingredient_categories WHERE name='buah'), 14, 'kulkas', 'BPOM/Literatur'),
    ('mangga', (SELECT id FROM ingredient_categories WHERE name='buah'), 7, 'kulkas', 'BPOM/Literatur'),
    ('pepaya', (SELECT id FROM ingredient_categories WHERE name='buah'), 5, 'kulkas', 'BPOM/Literatur'),
    ('nanas', (SELECT id FROM ingredient_categories WHERE name='buah'), 5, 'kulkas', 'BPOM/Literatur'),
    ('semangka', (SELECT id FROM ingredient_categories WHERE name='buah'), 5, 'kulkas', 'BPOM/Literatur'),
    ('melon', (SELECT id FROM ingredient_categories WHERE name='buah'), 5, 'kulkas', 'BPOM/Literatur'),
    ('alpukat', (SELECT id FROM ingredient_categories WHERE name='buah'), 5, 'kulkas', 'BPOM/Literatur'),
    ('kelapa', (SELECT id FROM ingredient_categories WHERE name='buah'), 7, 'kulkas', 'BPOM/Literatur'),
    ('lemon', (SELECT id FROM ingredient_categories WHERE name='buah'), 21, 'kulkas', 'BPOM/Literatur'),
    ('jeruk nipis', (SELECT id FROM ingredient_categories WHERE name='buah'), 14, 'kulkas', 'BPOM/Literatur'),
    ('strawberry', (SELECT id FROM ingredient_categories WHERE name='buah'), 3, 'kulkas', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- DAGING SAPI (beef)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('daging sapi', (SELECT id FROM ingredient_categories WHERE name='daging_sapi'), 3, 'kulkas', 'BPOM/Literatur'),
    ('daging sapi giling', (SELECT id FROM ingredient_categories WHERE name='daging_sapi'), 2, 'kulkas', 'BPOM/Literatur'),
    ('iga sapi', (SELECT id FROM ingredient_categories WHERE name='daging_sapi'), 3, 'kulkas', 'BPOM/Literatur'),
    ('hati sapi', (SELECT id FROM ingredient_categories WHERE name='daging_sapi'), 2, 'kulkas', 'BPOM/Literatur'),
    ('bakso sapi', (SELECT id FROM ingredient_categories WHERE name='daging_sapi'), 3, 'kulkas', 'BPOM/Literatur'),
    ('sosis sapi', (SELECT id FROM ingredient_categories WHERE name='bahan_olahan'), 7, 'kulkas', 'BPOM/Literatur'),
    ('kornet sapi', (SELECT id FROM ingredient_categories WHERE name='bahan_olahan'), 3, 'kulkas', 'BPOM/Literatur'),
    ('daging sapi', (SELECT id FROM ingredient_categories WHERE name='daging_sapi'), 90, 'freezer', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- DAGING AYAM (chicken)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('ayam utuh', (SELECT id FROM ingredient_categories WHERE name='daging_ayam'), 2, 'kulkas', 'BPOM/Literatur'),
    ('dada ayam', (SELECT id FROM ingredient_categories WHERE name='daging_ayam'), 2, 'kulkas', 'BPOM/Literatur'),
    ('paha ayam', (SELECT id FROM ingredient_categories WHERE name='daging_ayam'), 2, 'kulkas', 'BPOM/Literatur'),
    ('sayap ayam', (SELECT id FROM ingredient_categories WHERE name='daging_ayam'), 2, 'kulkas', 'BPOM/Literatur'),
    ('ayam giling', (SELECT id FROM ingredient_categories WHERE name='daging_ayam'), 1, 'kulkas', 'BPOM/Literatur'),
    ('hati ayam', (SELECT id FROM ingredient_categories WHERE name='daging_ayam'), 2, 'kulkas', 'BPOM/Literatur'),
    ('ayam utuh', (SELECT id FROM ingredient_categories WHERE name='daging_ayam'), 90, 'freezer', 'BPOM/Literatur'),
    ('nugget ayam', (SELECT id FROM ingredient_categories WHERE name='bahan_olahan'), 7, 'kulkas', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- DAGING KAMBING (goat/lamb)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('daging kambing', (SELECT id FROM ingredient_categories WHERE name='daging_kambing'), 3, 'kulkas', 'BPOM/Literatur'),
    ('kambing giling', (SELECT id FROM ingredient_categories WHERE name='daging_kambing'), 2, 'kulkas', 'BPOM/Literatur'),
    ('daging kambing', (SELECT id FROM ingredient_categories WHERE name='daging_kambing'), 90, 'freezer', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- IKAN (fish)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('ikan segar', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'BPOM/Literatur'),
    ('ikan tuna', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'BPOM/Literatur'),
    ('ikan salmon', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'BPOM/Literatur'),
    ('ikan lele', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'BPOM/Literatur'),
    ('ikan nila', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'BPOM/Literatur'),
    ('ikan mas', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'BPOM/Literatur'),
    ('ikan bandeng', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'BPOM/Literatur'),
    ('ikan tongkol', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'BPOM/Literatur'),
    ('ikan patin', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'BPOM/Literatur'),
    ('ikan teri', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 3, 'kulkas', 'BPOM/Literatur'),
    ('ikan asin', (SELECT id FROM ingredient_categories WHERE name='bahan_olahan'), 30, 'kulkas', 'BPOM/Literatur'),
    ('ikan segar', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 90, 'freezer', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- UDANG (shrimp)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('udang segar', (SELECT id FROM ingredient_categories WHERE name='udang'), 2, 'kulkas', 'BPOM/Literatur'),
    ('udang kupas', (SELECT id FROM ingredient_categories WHERE name='udang'), 2, 'kulkas', 'BPOM/Literatur'),
    ('udang beku', (SELECT id FROM ingredient_categories WHERE name='udang'), 90, 'freezer', 'BPOM/Literatur'),
    ('cumi segar', (SELECT id FROM ingredient_categories WHERE name='udang'), 2, 'kulkas', 'BPOM/Literatur'),
    ('kerang', (SELECT id FROM ingredient_categories WHERE name='udang'), 2, 'kulkas', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- TELUR (eggs)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('telur ayam', (SELECT id FROM ingredient_categories WHERE name='telur'), 21, 'kulkas', 'BPOM/Literatur'),
    ('telur bebek', (SELECT id FROM ingredient_categories WHERE name='telur'), 21, 'kulkas', 'BPOM/Literatur'),
    ('telur puyuh', (SELECT id FROM ingredient_categories WHERE name='telur'), 14, 'kulkas', 'BPOM/Literatur'),
    ('telur asin', (SELECT id FROM ingredient_categories WHERE name='telur'), 30, 'kulkas', 'BPOM/Literatur'),
    ('putih telur', (SELECT id FROM ingredient_categories WHERE name='telur'), 3, 'kulkas', 'BPOM/Literatur'),
    ('kuning telur', (SELECT id FROM ingredient_categories WHERE name='telur'), 2, 'kulkas', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- TAHU
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('tahu putih', (SELECT id FROM ingredient_categories WHERE name='tahu'), 3, 'kulkas', 'BPOM/Literatur'),
    ('tahu sutra', (SELECT id FROM ingredient_categories WHERE name='tahu'), 3, 'kulkas', 'BPOM/Literatur'),
    ('tahu kuning', (SELECT id FROM ingredient_categories WHERE name='tahu'), 3, 'kulkas', 'BPOM/Literatur'),
    ('tahu pong', (SELECT id FROM ingredient_categories WHERE name='tahu'), 5, 'kulkas', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- TEMPE
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('tempe', (SELECT id FROM ingredient_categories WHERE name='tempe'), 3, 'kulkas', 'BPOM/Literatur'),
    ('tempe gembus', (SELECT id FROM ingredient_categories WHERE name='tempe'), 2, 'kulkas', 'BPOM/Literatur'),
    ('tempe', (SELECT id FROM ingredient_categories WHERE name='tempe'), 30, 'freezer', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- DAIRY (susu, keju, dll)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('susu segar', (SELECT id FROM ingredient_categories WHERE name='dairy'), 5, 'kulkas', 'BPOM/Literatur'),
    ('susu UHT (terbuka)', (SELECT id FROM ingredient_categories WHERE name='dairy'), 5, 'kulkas', 'BPOM/Literatur'),
    ('keju', (SELECT id FROM ingredient_categories WHERE name='dairy'), 21, 'kulkas', 'BPOM/Literatur'),
    ('yoghurt', (SELECT id FROM ingredient_categories WHERE name='dairy'), 14, 'kulkas', 'BPOM/Literatur'),
    ('mentega', (SELECT id FROM ingredient_categories WHERE name='dairy'), 30, 'kulkas', 'BPOM/Literatur'),
    ('whipping cream', (SELECT id FROM ingredient_categories WHERE name='dairy'), 7, 'kulkas', 'BPOM/Literatur'),
    ('santan segar', (SELECT id FROM ingredient_categories WHERE name='dairy'), 2, 'kulkas', 'BPOM/Literatur'),
    ('santan kemasan (terbuka)', (SELECT id FROM ingredient_categories WHERE name='dairy'), 3, 'kulkas', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- BUMBU SEGAR (fresh spices)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('bawang merah', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 14, 'kulkas', 'BPOM/Literatur'),
    ('bawang putih', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 14, 'kulkas', 'BPOM/Literatur'),
    ('bawang bombay', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 14, 'kulkas', 'BPOM/Literatur'),
    ('jahe', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 21, 'kulkas', 'BPOM/Literatur'),
    ('kunyit', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 14, 'kulkas', 'BPOM/Literatur'),
    ('lengkuas', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 14, 'kulkas', 'BPOM/Literatur'),
    ('serai', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 14, 'kulkas', 'BPOM/Literatur'),
    ('daun salam', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 7, 'kulkas', 'BPOM/Literatur'),
    ('daun jeruk', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 7, 'kulkas', 'BPOM/Literatur'),
    ('kemangi', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 5, 'kulkas', 'BPOM/Literatur'),
    ('daun pandan', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 7, 'kulkas', 'BPOM/Literatur'),
    ('daun ketumbar', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 5, 'kulkas', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- BUMBU KERING (dry spices) - longer shelf life
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('garam', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 365, 'suhu_ruang', 'BPOM/Literatur'),
    ('gula pasir', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 365, 'suhu_ruang', 'BPOM/Literatur'),
    ('merica bubuk', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 180, 'suhu_ruang', 'BPOM/Literatur'),
    ('ketumbar bubuk', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 180, 'suhu_ruang', 'BPOM/Literatur'),
    ('pala bubuk', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 180, 'suhu_ruang', 'BPOM/Literatur'),
    ('kayu manis', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 180, 'suhu_ruang', 'BPOM/Literatur'),
    ('cengkeh', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 180, 'suhu_ruang', 'BPOM/Literatur'),
    ('kemiri', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 90, 'suhu_ruang', 'BPOM/Literatur'),
    ('kecap manis', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 90, 'kulkas', 'BPOM/Literatur'),
    ('kecap asin', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 90, 'kulkas', 'BPOM/Literatur'),
    ('saus tiram', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 90, 'kulkas', 'BPOM/Literatur'),
    ('saus sambal', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 90, 'kulkas', 'BPOM/Literatur'),
    ('terasi', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 180, 'suhu_ruang', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- TEPUNG & BAHAN KERING
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('tepung terigu', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 180, 'suhu_ruang', 'BPOM/Literatur'),
    ('tepung tapioka', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 180, 'suhu_ruang', 'BPOM/Literatur'),
    ('tepung beras', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 180, 'suhu_ruang', 'BPOM/Literatur'),
    ('tepung maizena', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 180, 'suhu_ruang', 'BPOM/Literatur'),
    ('tepung panir', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 90, 'suhu_ruang', 'BPOM/Literatur'),
    ('beras', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 180, 'suhu_ruang', 'BPOM/Literatur'),
    ('mie instan', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 180, 'suhu_ruang', 'BPOM/Literatur'),
    ('bihun', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 180, 'suhu_ruang', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- MINYAK & LEMAK
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('minyak goreng', (SELECT id FROM ingredient_categories WHERE name='minyak_lemak'), 180, 'suhu_ruang', 'BPOM/Literatur'),
    ('minyak wijen', (SELECT id FROM ingredient_categories WHERE name='minyak_lemak'), 180, 'suhu_ruang', 'BPOM/Literatur'),
    ('margarine', (SELECT id FROM ingredient_categories WHERE name='minyak_lemak'), 60, 'kulkas', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- ROTI & BAKERY
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('roti tawar', (SELECT id FROM ingredient_categories WHERE name='roti_bakery'), 5, 'suhu_ruang', 'BPOM/Literatur'),
    ('roti tawar', (SELECT id FROM ingredient_categories WHERE name='roti_bakery'), 14, 'kulkas', 'BPOM/Literatur'),
    ('kulit lumpia', (SELECT id FROM ingredient_categories WHERE name='roti_bakery'), 7, 'kulkas', 'BPOM/Literatur'),
    ('kulit pangsit', (SELECT id FROM ingredient_categories WHERE name='roti_bakery'), 7, 'kulkas', 'BPOM/Literatur'),
    ('puff pastry', (SELECT id FROM ingredient_categories WHERE name='roti_bakery'), 3, 'kulkas', 'BPOM/Literatur')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;
