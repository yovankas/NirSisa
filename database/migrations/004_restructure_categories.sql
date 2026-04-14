-- ============================================================
-- NirSisa Migration 004: Restructure Ingredient Categories
-- Pecah bumbu_segar → 5 sub-tipe, sayur → 2 sub-tipe, tambah cabai
-- Tambah kolom default_unit di shelf_life_reference
-- ============================================================

-- ============================================================
-- STEP 1: Tambah kategori baru
-- ============================================================
INSERT INTO ingredient_categories (name) VALUES
    ('sayur_daun'),
    ('sayur_buah'),
    ('bumbu_bawangan'),
    ('bumbu_rimpang'),
    ('bumbu_batangan'),
    ('bumbu_daunan'),
    ('cabai')
ON CONFLICT (name) DO NOTHING;

-- ============================================================
-- STEP 2: Tambah kolom default_unit
-- ============================================================
ALTER TABLE shelf_life_reference ADD COLUMN IF NOT EXISTS default_unit VARCHAR(20);

-- ============================================================
-- STEP 3: Pindahkan bahan dari sayur → sayur_daun / sayur_buah
-- ============================================================

-- Sayur daun (satuan: ikat)
UPDATE shelf_life_reference
SET category_id = (SELECT id FROM ingredient_categories WHERE name = 'sayur_daun')
WHERE ingredient_name IN ('bayam', 'kangkung', 'sawi', 'tauge', 'kol', 'kacang panjang', 'buncis', 'jamur', 'daun bawang', 'seledri')
  AND category_id = (SELECT id FROM ingredient_categories WHERE name = 'sayur');

-- Sayur buah (satuan: buah)
UPDATE shelf_life_reference
SET category_id = (SELECT id FROM ingredient_categories WHERE name = 'sayur_buah')
WHERE ingredient_name IN ('wortel', 'kentang', 'tomat', 'terong', 'timun', 'pare', 'paprika', 'lobak', 'labu siam', 'jagung', 'brokoli', 'rebung')
  AND category_id = (SELECT id FROM ingredient_categories WHERE name = 'sayur');

-- ============================================================
-- STEP 4: Pindahkan bahan dari bumbu_segar → sub-kategori
-- ============================================================

-- Bumbu bawangan (satuan: siung)
UPDATE shelf_life_reference
SET category_id = (SELECT id FROM ingredient_categories WHERE name = 'bumbu_bawangan')
WHERE ingredient_name IN ('bawang merah', 'bawang putih', 'bawang bombay')
  AND category_id = (SELECT id FROM ingredient_categories WHERE name = 'bumbu_segar');

-- Bumbu rimpang (satuan: ruas)
UPDATE shelf_life_reference
SET category_id = (SELECT id FROM ingredient_categories WHERE name = 'bumbu_rimpang')
WHERE ingredient_name IN ('jahe', 'kunyit', 'lengkuas')
  AND category_id = (SELECT id FROM ingredient_categories WHERE name = 'bumbu_segar');

-- Bumbu batangan (satuan: batang)
UPDATE shelf_life_reference
SET category_id = (SELECT id FROM ingredient_categories WHERE name = 'bumbu_batangan')
WHERE ingredient_name IN ('serai')
  AND category_id = (SELECT id FROM ingredient_categories WHERE name = 'bumbu_segar');

-- Bumbu daunan (satuan: lembar)
UPDATE shelf_life_reference
SET category_id = (SELECT id FROM ingredient_categories WHERE name = 'bumbu_daunan')
WHERE ingredient_name IN ('daun salam', 'daun jeruk', 'kemangi', 'daun pandan', 'daun ketumbar')
  AND category_id = (SELECT id FROM ingredient_categories WHERE name = 'bumbu_segar');

-- ============================================================
-- STEP 5: Pindahkan cabai dari sayur → cabai
-- ============================================================
UPDATE shelf_life_reference
SET category_id = (SELECT id FROM ingredient_categories WHERE name = 'cabai')
WHERE ingredient_name IN ('cabai merah', 'cabai rawit', 'cabai hijau')
  AND category_id = (SELECT id FROM ingredient_categories WHERE name = 'sayur');

-- ============================================================
-- STEP 6: Hapus dairy dari shelf_life_reference
-- ============================================================
DELETE FROM shelf_life_reference
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'dairy');

-- ============================================================
-- STEP 7: Set default_unit untuk semua bahan
-- ============================================================

-- Sayur daun → ikat
UPDATE shelf_life_reference SET default_unit = 'ikat'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'sayur_daun');

-- Sayur buah → buah
UPDATE shelf_life_reference SET default_unit = 'buah'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'sayur_buah');

-- Buah → buah
UPDATE shelf_life_reference SET default_unit = 'buah'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'buah');

-- Daging → gram
UPDATE shelf_life_reference SET default_unit = 'gram'
WHERE category_id IN (
    SELECT id FROM ingredient_categories WHERE name IN ('daging_sapi', 'daging_ayam', 'daging_kambing')
);

-- Ikan → ekor
UPDATE shelf_life_reference SET default_unit = 'ekor'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'ikan_segar');

-- Udang → gram
UPDATE shelf_life_reference SET default_unit = 'gram'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'udang');

-- Telur → butir
UPDATE shelf_life_reference SET default_unit = 'butir'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'telur');

-- Tahu → buah
UPDATE shelf_life_reference SET default_unit = 'buah'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'tahu');

-- Tempe → bungkus
UPDATE shelf_life_reference SET default_unit = 'bungkus'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'tempe');

-- Bumbu bawangan → siung
UPDATE shelf_life_reference SET default_unit = 'siung'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'bumbu_bawangan');

-- Bumbu rimpang → ruas
UPDATE shelf_life_reference SET default_unit = 'ruas'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'bumbu_rimpang');

-- Bumbu batangan → batang
UPDATE shelf_life_reference SET default_unit = 'batang'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'bumbu_batangan');

-- Bumbu daunan → lembar
UPDATE shelf_life_reference SET default_unit = 'lembar'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'bumbu_daunan');

-- Cabai → buah
UPDATE shelf_life_reference SET default_unit = 'buah'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'cabai');

-- Bumbu kering → sdt
UPDATE shelf_life_reference SET default_unit = 'sdt'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'bumbu_kering');

-- Bahan olahan → bungkus
UPDATE shelf_life_reference SET default_unit = 'bungkus'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'bahan_olahan');

-- Minyak & lemak → sdm
UPDATE shelf_life_reference SET default_unit = 'sdm'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'minyak_lemak');

-- Tepung & kering → gram
UPDATE shelf_life_reference SET default_unit = 'gram'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'tepung_kering');

-- Kacang & biji → gram
UPDATE shelf_life_reference SET default_unit = 'gram'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'kacang_biji');

-- Roti & bakery → bungkus
UPDATE shelf_life_reference SET default_unit = 'bungkus'
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'roti_bakery');

-- ============================================================
-- STEP 8: Update inventory_stock yang masih pakai kategori lama
-- ============================================================

-- Inventory dengan kategori 'sayur' lama → set null (akan di-resolve ulang)
UPDATE inventory_stock
SET category_id = NULL
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'sayur');

UPDATE inventory_stock
SET category_id = NULL
WHERE category_id = (SELECT id FROM ingredient_categories WHERE name = 'bumbu_segar');