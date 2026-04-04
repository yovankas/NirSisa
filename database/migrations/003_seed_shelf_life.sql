-- ============================================================
-- NirSisa Shelf-Life Reference Seed Data
-- Based on FDA Refrigerator & Freezer Storage Chart, Virginia Tech Pub. 348-960,
-- USDA FSIS Refrigeration & Food Safety Guidelines, dan PerKa BPOM No. 5/2015
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
    ('bayam', (SELECT id FROM ingredient_categories WHERE name='sayur'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kangkung', (SELECT id FROM ingredient_categories WHERE name='sayur'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('sawi', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('wortel', (SELECT id FROM ingredient_categories WHERE name='sayur'), 14, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kentang', (SELECT id FROM ingredient_categories WHERE name='sayur'), 21, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('brokoli', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kol', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('tomat', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('terong', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('cabai merah', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('cabai rawit', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('cabai hijau', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('labu siam', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('jagung', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kacang panjang', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('buncis', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('tauge', (SELECT id FROM ingredient_categories WHERE name='sayur'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('jamur', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('daun bawang', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('seledri', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('timun', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('pare', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('paprika', (SELECT id FROM ingredient_categories WHERE name='sayur'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('lobak', (SELECT id FROM ingredient_categories WHERE name='sayur'), 14, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('rebung', (SELECT id FROM ingredient_categories WHERE name='sayur'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- BUAH (fruits)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('pisang', (SELECT id FROM ingredient_categories WHERE name='buah'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('apel', (SELECT id FROM ingredient_categories WHERE name='buah'), 21, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('jeruk', (SELECT id FROM ingredient_categories WHERE name='buah'), 14, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('mangga', (SELECT id FROM ingredient_categories WHERE name='buah'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('pepaya', (SELECT id FROM ingredient_categories WHERE name='buah'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('nanas', (SELECT id FROM ingredient_categories WHERE name='buah'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('semangka', (SELECT id FROM ingredient_categories WHERE name='buah'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('melon', (SELECT id FROM ingredient_categories WHERE name='buah'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('alpukat', (SELECT id FROM ingredient_categories WHERE name='buah'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kelapa', (SELECT id FROM ingredient_categories WHERE name='buah'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('lemon', (SELECT id FROM ingredient_categories WHERE name='buah'), 21, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('jeruk nipis', (SELECT id FROM ingredient_categories WHERE name='buah'), 14, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('strawberry', (SELECT id FROM ingredient_categories WHERE name='buah'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- DAGING SAPI (beef)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('daging sapi', (SELECT id FROM ingredient_categories WHERE name='daging_sapi'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('daging sapi giling', (SELECT id FROM ingredient_categories WHERE name='daging_sapi'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('iga sapi', (SELECT id FROM ingredient_categories WHERE name='daging_sapi'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('hati sapi', (SELECT id FROM ingredient_categories WHERE name='daging_sapi'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('bakso sapi', (SELECT id FROM ingredient_categories WHERE name='daging_sapi'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('sosis sapi', (SELECT id FROM ingredient_categories WHERE name='bahan_olahan'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kornet sapi', (SELECT id FROM ingredient_categories WHERE name='bahan_olahan'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('daging sapi', (SELECT id FROM ingredient_categories WHERE name='daging_sapi'), 90, 'freezer', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- DAGING AYAM (chicken)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('ayam utuh', (SELECT id FROM ingredient_categories WHERE name='daging_ayam'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('dada ayam', (SELECT id FROM ingredient_categories WHERE name='daging_ayam'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('paha ayam', (SELECT id FROM ingredient_categories WHERE name='daging_ayam'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('sayap ayam', (SELECT id FROM ingredient_categories WHERE name='daging_ayam'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('ayam giling', (SELECT id FROM ingredient_categories WHERE name='daging_ayam'), 1, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('hati ayam', (SELECT id FROM ingredient_categories WHERE name='daging_ayam'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('ayam utuh', (SELECT id FROM ingredient_categories WHERE name='daging_ayam'), 90, 'freezer', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('nugget ayam', (SELECT id FROM ingredient_categories WHERE name='bahan_olahan'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- DAGING KAMBING (goat/lamb)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('daging kambing', (SELECT id FROM ingredient_categories WHERE name='daging_kambing'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kambing giling', (SELECT id FROM ingredient_categories WHERE name='daging_kambing'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('daging kambing', (SELECT id FROM ingredient_categories WHERE name='daging_kambing'), 90, 'freezer', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- IKAN (fish)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('ikan segar', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('ikan tuna', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('ikan salmon', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('ikan lele', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('ikan nila', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('ikan mas', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('ikan bandeng', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('ikan tongkol', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('ikan patin', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('ikan teri', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('ikan asin', (SELECT id FROM ingredient_categories WHERE name='bahan_olahan'), 30, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('ikan segar', (SELECT id FROM ingredient_categories WHERE name='ikan_segar'), 90, 'freezer', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- UDANG (shrimp)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('udang segar', (SELECT id FROM ingredient_categories WHERE name='udang'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('udang kupas', (SELECT id FROM ingredient_categories WHERE name='udang'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('udang beku', (SELECT id FROM ingredient_categories WHERE name='udang'), 90, 'freezer', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('cumi segar', (SELECT id FROM ingredient_categories WHERE name='udang'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kerang', (SELECT id FROM ingredient_categories WHERE name='udang'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- TELUR (eggs)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('telur ayam', (SELECT id FROM ingredient_categories WHERE name='telur'), 21, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('telur bebek', (SELECT id FROM ingredient_categories WHERE name='telur'), 21, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('telur puyuh', (SELECT id FROM ingredient_categories WHERE name='telur'), 14, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('telur asin', (SELECT id FROM ingredient_categories WHERE name='telur'), 30, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('putih telur', (SELECT id FROM ingredient_categories WHERE name='telur'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kuning telur', (SELECT id FROM ingredient_categories WHERE name='telur'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- TAHU
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('tahu putih', (SELECT id FROM ingredient_categories WHERE name='tahu'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('tahu sutra', (SELECT id FROM ingredient_categories WHERE name='tahu'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('tahu kuning', (SELECT id FROM ingredient_categories WHERE name='tahu'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('tahu pong', (SELECT id FROM ingredient_categories WHERE name='tahu'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- TEMPE
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('tempe', (SELECT id FROM ingredient_categories WHERE name='tempe'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('tempe gembus', (SELECT id FROM ingredient_categories WHERE name='tempe'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('tempe', (SELECT id FROM ingredient_categories WHERE name='tempe'), 30, 'freezer', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- DAIRY (susu, keju, dll)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('susu segar', (SELECT id FROM ingredient_categories WHERE name='dairy'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('susu UHT (terbuka)', (SELECT id FROM ingredient_categories WHERE name='dairy'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('keju', (SELECT id FROM ingredient_categories WHERE name='dairy'), 21, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('yoghurt', (SELECT id FROM ingredient_categories WHERE name='dairy'), 14, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('mentega', (SELECT id FROM ingredient_categories WHERE name='dairy'), 30, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('whipping cream', (SELECT id FROM ingredient_categories WHERE name='dairy'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('santan segar', (SELECT id FROM ingredient_categories WHERE name='dairy'), 2, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('santan kemasan (terbuka)', (SELECT id FROM ingredient_categories WHERE name='dairy'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- BUMBU SEGAR (fresh spices)
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('bawang merah', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 14, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('bawang putih', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 14, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('bawang bombay', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 14, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('jahe', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 21, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kunyit', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 14, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('lengkuas', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 14, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('serai', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 14, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('daun salam', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('daun jeruk', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kemangi', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('daun pandan', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('daun ketumbar', (SELECT id FROM ingredient_categories WHERE name='bumbu_segar'), 5, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- BUMBU KERING (dry spices) - longer shelf life
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('garam', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 365, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('gula pasir', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 365, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('merica bubuk', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 180, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('ketumbar bubuk', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 180, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('pala bubuk', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 180, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kayu manis', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 180, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('cengkeh', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 180, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kemiri', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 90, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kecap manis', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 90, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kecap asin', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 90, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('saus tiram', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 90, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('saus sambal', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 90, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('terasi', (SELECT id FROM ingredient_categories WHERE name='bumbu_kering'), 180, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- TEPUNG & BAHAN KERING
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('tepung terigu', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 180, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('tepung tapioka', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 180, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('tepung beras', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 180, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('tepung maizena', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 180, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('tepung panir', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 90, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('beras', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 180, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('mie instan', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 180, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('bihun', (SELECT id FROM ingredient_categories WHERE name='tepung_kering'), 180, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- MINYAK & LEMAK
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('minyak goreng', (SELECT id FROM ingredient_categories WHERE name='minyak_lemak'), 180, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('minyak wijen', (SELECT id FROM ingredient_categories WHERE name='minyak_lemak'), 180, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('margarine', (SELECT id FROM ingredient_categories WHERE name='minyak_lemak'), 60, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;

-- ROTI & BAKERY
INSERT INTO shelf_life_reference (ingredient_name, category_id, shelf_life_days, storage_condition, source) VALUES
    ('roti tawar', (SELECT id FROM ingredient_categories WHERE name='roti_bakery'), 5, 'suhu_ruang', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('roti tawar', (SELECT id FROM ingredient_categories WHERE name='roti_bakery'), 14, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kulit lumpia', (SELECT id FROM ingredient_categories WHERE name='roti_bakery'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('kulit pangsit', (SELECT id FROM ingredient_categories WHERE name='roti_bakery'), 7, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines'),
    ('puff pastry', (SELECT id FROM ingredient_categories WHERE name='roti_bakery'), 3, 'kulkas', 'FDA Refrigerator Storage Chart; Virginia Tech Pub. 348-960; USDA FSIS Refrigeration Guidelines')
ON CONFLICT (ingredient_name, storage_condition) DO NOTHING;
