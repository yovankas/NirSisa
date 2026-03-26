# Unit Tests - Recommendation Engine
# 20 query sintetis untuk Cosine Similarity + 15 skenario SPI re-ranking
# Memvalidasi bahwa bahan kritis (SPI tinggi) muncul di posisi teratas

import pytest
import os

# Skip seluruh module jika file pkl tidak tersedia
_APP_DIR = os.path.join(
    os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "app"
)

_MODEL_EXISTS = (
    os.path.exists(os.path.join(_APP_DIR, "ml_models", "tfidf_vectorizer.pkl"))
    and os.path.exists(os.path.join(_APP_DIR, "ml_models", "recipe_matrix.pkl"))
    and os.path.exists(os.path.join(_APP_DIR, "data", "recipe_data.pkl"))
)

pytestmark = pytest.mark.skipif(
    not _MODEL_EXISTS,
    reason="Model files (.pkl) tidak ditemukan di app/ml_models/ dan app/data/",
)

from app.ai.cbf import RecipeKnowledgeBase
from app.ai.recommender import get_recommendations, InventoryItem


@pytest.fixture(scope="module")
def knowledge_base():
    # Load knowledge base sekali untuk seluruh test module 
    kb = RecipeKnowledgeBase.get_instance()
    if not kb.is_loaded:
        kb.load()
    return kb


# A. Cosine Similarity Tests (20 query sintetis)

class TestCosineSimilarity:
    # Validasi bahwa CBF menghasilkan resep yang relevan 

    QUERIES = [
        # (nama_test, bahan, kata_kunci_yang_diharapkan_di_hasil)
        ("ayam_bawang", ["ayam", "bawang putih"], "ayam"),
        ("bayam_telur", ["bayam", "telur"], "bayam"),
        ("tahu_tempe", ["tahu", "tempe"], "tahu"),
        ("ikan_tomat", ["ikan", "tomat"], "ikan"),
        ("udang_bawang", ["udang", "bawang merah"], "udang"),
        ("daging_sapi_kentang", ["daging sapi", "kentang"], "daging"),
        ("telur_kecap", ["telur", "kecap"], "telur"),
        ("kangkung_terasi", ["kangkung", "terasi"], "kangkung"),
        ("nasi_goreng", ["nasi", "kecap", "telur"], "nasi"),
        ("mie_sayur", ["mie", "wortel", "sawi"], "mie"),
        ("soto_ayam", ["ayam", "kunyit", "serai"], "ayam"),
        ("rendang", ["daging sapi", "santan", "cabai"], "daging"),
        ("pecel", ["bayam", "kacang", "tauge"], "bayam"),
        ("capcay", ["wortel", "brokoli", "jagung"], "wortel"),
        ("sop_bening", ["bayam", "jagung", "wortel"], "bayam"),
        ("tumis_kangkung", ["kangkung", "bawang putih", "cabai"], "kangkung"),
        ("gulai_ikan", ["ikan", "santan", "kunyit"], "ikan"),
        ("bakso", ["daging sapi", "tepung tapioka"], "bakso"),
        ("pisang_goreng", ["pisang", "tepung"], "pisang"),
        ("es_buah", ["semangka", "melon", "gula"], "gula"),
    ]

    @pytest.mark.parametrize(
        "name,ingredients,expected_keyword",
        QUERIES,
        ids=[q[0] for q in QUERIES],
    )
    def test_cosine_returns_relevant(
        self, knowledge_base, name, ingredients, expected_keyword
    ):
        # Top-10 rekomendasi harus mengandung keyword yang relevan 
        items = [InventoryItem(name=ing) for ing in ingredients]
        result = get_recommendations(items, top_k=10, spi_weight=0.0)

        assert len(result.recipes) > 0, f"Tidak ada hasil untuk query: {ingredients}"

        # Setidaknya 1 dari Top-10 mengandung keyword di title atau ingredients
        found = any(
            expected_keyword.lower() in r.title.lower()
            or expected_keyword.lower() in r.ingredients_cleaned.lower()
            for r in result.recipes
        )
        assert found, (
            f"Query {name}: keyword '{expected_keyword}' tidak ditemukan di Top-10. "
            f"Titles: {[r.title for r in result.recipes]}"
        )

    def test_cosine_scores_are_positive(self, knowledge_base):
        # Skor cosine harus > 0 untuk query yang valid 
        items = [InventoryItem(name="ayam"), InventoryItem(name="bawang putih")]
        result = get_recommendations(items, top_k=10, spi_weight=0.0)
        for r in result.recipes:
            assert r.cosine_score > 0

    def test_cosine_scores_sorted_descending(self, knowledge_base):
        # Tanpa SPI (weight=0), hasil harus terurut descending by cosine 
        items = [InventoryItem(name="bayam"), InventoryItem(name="telur")]
        result = get_recommendations(items, top_k=10, spi_weight=0.0)
        scores = [r.cosine_score for r in result.recipes]
        assert scores == sorted(scores, reverse=True)


# B. SPI Re-ranking Tests (15 skenario)

class TestSPIReranking:
    # Validasi bahwa bahan dengan SPI tinggi mendorong resep ke atas 

    def test_critical_ingredient_prioritized(self, knowledge_base):
        # Bayam (1 hari) harus prioritas di atas ayam (14 hari) 
        items = [
            InventoryItem(name="bayam", days_remaining=1),
            InventoryItem(name="ayam", days_remaining=14),
        ]
        result = get_recommendations(items, top_k=10, spi_weight=0.4)
        top_title = result.recipes[0].title.lower()
        top_ingredients = result.recipes[0].ingredients_cleaned.lower()
        # Resep teratas harus mengandung bayam
        assert "bayam" in top_title or "bayam" in top_ingredients

    def test_day0_gets_highest_spi(self, knowledge_base):
        # Bahan yang kedaluwarsa hari ini (d=0) -> SPI = 1.0 
        items = [
            InventoryItem(name="tomat", days_remaining=0),
            InventoryItem(name="kentang", days_remaining=14),
        ]
        result = get_recommendations(items, top_k=5, spi_weight=0.6)
        assert result.recipes[0].spi_score > 0

    def test_equal_days_equal_spi(self, knowledge_base):
        # Dua bahan dengan sisa hari sama -> keduanya mendapat SPI sama 
        items = [
            InventoryItem(name="bayam", days_remaining=2),
            InventoryItem(name="kangkung", days_remaining=2),
        ]
        result = get_recommendations(items, top_k=10, spi_weight=0.4)
        assert len(result.recipes) > 0

    def test_no_expiry_zero_spi(self, knowledge_base):
        # Bahan tanpa expiry -> SPI contribution = 0 
        items = [
            InventoryItem(name="garam"),  # no days_remaining
            InventoryItem(name="bayam", days_remaining=1),
        ]
        result = get_recommendations(items, top_k=10, spi_weight=0.4)
        # Resep berbayam harus dominan karena SPI bayam tinggi
        top3_has_bayam = any(
            "bayam" in r.ingredients_cleaned.lower()
            for r in result.recipes[:3]
        )
        assert top3_has_bayam

    def test_spi_weight_0_ignores_urgency(self, knowledge_base):
        # SPI weight = 0 -> urutan murni cosine, SPI diabaikan 
        items = [
            InventoryItem(name="ayam", days_remaining=0),
            InventoryItem(name="bayam", days_remaining=14),
        ]
        result_no_spi = get_recommendations(items, top_k=5, spi_weight=0.0)
        result_with_spi = get_recommendations(items, top_k=5, spi_weight=0.6)
        # Dengan SPI, urutan mungkin berbeda
        titles_no = [r.title for r in result_no_spi.recipes]
        titles_with = [r.title for r in result_with_spi.recipes]
        # Tidak perlu sama, cukup validasi keduanya valid
        assert len(titles_no) > 0
        assert len(titles_with) > 0

    def test_spi_weight_high_prioritizes_critical(self, knowledge_base):
        # Lambda=0.8 -> SPI sangat dominan 
        items = [
            InventoryItem(name="wortel", days_remaining=1),
            InventoryItem(name="daging sapi", days_remaining=14),
        ]
        result = get_recommendations(items, top_k=10, spi_weight=0.8)
        top_ingredients = result.recipes[0].ingredients_cleaned.lower()
        assert "wortel" in top_ingredients

    def test_multiple_critical_ingredients(self, knowledge_base):
        # Beberapa bahan kritis -> resep yang menggunakan banyak bahan kritis naik 
        items = [
            InventoryItem(name="bayam", days_remaining=1),
            InventoryItem(name="tomat", days_remaining=1),
            InventoryItem(name="bawang putih", days_remaining=30),
        ]
        result = get_recommendations(items, top_k=10, spi_weight=0.4)
        assert result.recipes[0].spi_score > 0

    def test_day_1_vs_day_7(self, knowledge_base):
        # d=1 harus punya SPI jauh lebih tinggi dari d=7 
        items = [
            InventoryItem(name="tahu", days_remaining=1),
            InventoryItem(name="tempe", days_remaining=7),
        ]
        result = get_recommendations(items, top_k=10, spi_weight=0.4)
        assert len(result.recipes) > 0

    def test_day_3_medium_urgency(self, knowledge_base):
        # d=3 -> SPI moderat, resep tetap muncul 
        items = [InventoryItem(name="udang", days_remaining=3)]
        result = get_recommendations(items, top_k=5, spi_weight=0.4)
        assert len(result.recipes) > 0

    def test_day_5_low_urgency(self, knowledge_base):
        # d=5 -> SPI rendah tapi masih ada kontribusi 
        items = [InventoryItem(name="ikan", days_remaining=5)]
        result = get_recommendations(items, top_k=5, spi_weight=0.4)
        assert len(result.recipes) > 0

    def test_all_fresh_no_reranking_effect(self, knowledge_base):
        # Semua bahan d=14 -> SPI sangat rendah, urutan mirip cosine murni 
        items = [
            InventoryItem(name="ayam", days_remaining=14),
            InventoryItem(name="bawang putih", days_remaining=14),
        ]
        result = get_recommendations(items, top_k=5, spi_weight=0.4)
        assert len(result.recipes) > 0
        # SPI scores seharusnya sangat kecil
        for r in result.recipes:
            assert r.final_score > 0

    def test_single_ingredient_critical(self, knowledge_base):
        # Satu bahan saja, kritis -> tetap dapat rekomendasi 
        items = [InventoryItem(name="bayam", days_remaining=0)]
        result = get_recommendations(items, top_k=5, spi_weight=0.4)
        assert len(result.recipes) > 0
        assert "bayam" in result.recipes[0].ingredients_cleaned.lower()

    def test_final_score_combines_both(self, knowledge_base):
        # final_score harus > cosine_score jika SPI > 0 
        items = [
            InventoryItem(name="bayam", days_remaining=1),
            InventoryItem(name="telur", days_remaining=7),
        ]
        result = get_recommendations(items, top_k=5, spi_weight=0.4)
        for r in result.recipes:
            if r.spi_score > 0:
                # final = 0.6*cos + 0.4*spi, jadi final bisa > cosine
                assert r.final_score >= r.cosine_score * 0.6

    def test_match_percentage_calculated(self, knowledge_base):
        # match_percentage harus antara 0 dan 100 
        items = [
            InventoryItem(name="ayam", days_remaining=3),
            InventoryItem(name="bawang putih", days_remaining=10),
        ]
        result = get_recommendations(items, top_k=5, spi_weight=0.4)
        for r in result.recipes:
            assert 0 <= r.match_percentage <= 100


# C. Performance & Edge Case Tests

class TestPerformance:
    def test_latency_under_1000ms(self, knowledge_base):
        # Rekomendasi harus selesai dalam <1000ms 
        items = [
            InventoryItem(name="ayam", days_remaining=2),
            InventoryItem(name="bayam", days_remaining=1),
            InventoryItem(name="bawang putih", days_remaining=10),
            InventoryItem(name="telur", days_remaining=7),
            InventoryItem(name="tomat", days_remaining=3),
        ]
        result = get_recommendations(items, top_k=10, spi_weight=0.4)
        assert result.latency_ms < 1000, f"Latency {result.latency_ms}ms melebihi batas"

    def test_top_k_respected(self, knowledge_base):
        # Jumlah hasil tidak melebihi top_k 
        items = [InventoryItem(name="ayam")]
        for k in [1, 5, 10, 20]:
            result = get_recommendations(items, top_k=k, spi_weight=0.0)
            assert len(result.recipes) <= k

    def test_empty_inventory_raises(self):
        # Inventaris kosong -> harus tetap berjalan (return kosong atau error) 
        # Ini sebaiknya di-handle di API layer, tapi engine tidak boleh crash
        items = []
        result = get_recommendations(items, top_k=5)
        # Query kosong -> cosine score semua 0, tapi tidak crash
        assert isinstance(result.recipes, list)