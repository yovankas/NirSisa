# Unit Tests - Data Normalizer
# Validasi normalisasi nama bahan, fuzzy matching, dan estimasi shelf-life

import pytest
from datetime import date, timedelta
from unittest.mock import patch

from app.services.normalizer import (
    normalize_ingredient_name,
    estimate_expiry_date,
    _clean_text,
    _get_default_shelf_life,
)


class TestCleanText:
    def test_lowercase(self):
        assert _clean_text("BAYAM") == "bayam"

    def test_strip_whitespace(self):
        assert _clean_text("  bayam  ") == "bayam"

    def test_remove_special_chars(self):
        assert _clean_text("bayam123!!") == "bayam"

    def test_collapse_spaces(self):
        assert _clean_text("bawang   putih") == "bawang putih"


class TestNormalizeIngredientName:
    def test_exact_alias(self):
        assert normalize_ingredient_name("baput") == "bawang putih"
        assert normalize_ingredient_name("bamer") == "bawang merah"
        assert normalize_ingredient_name("micin") == "penyedap rasa"
        assert normalize_ingredient_name("telor") == "telur"
        assert normalize_ingredient_name("cabe") == "cabai"

    def test_case_insensitive(self):
        assert normalize_ingredient_name("BAPUT") == "bawang putih"
        assert normalize_ingredient_name("Telor") == "telur"

    def test_already_standard(self):
        # Nama yang sudah standar tapi tidak ada di alias map -> dikembalikan apa adanya 
        result = normalize_ingredient_name("bayam")
        assert result == "bayam"

    def test_unknown_returns_cleaned(self):
        # Bahan tidak dikenal -> kembalikan versi cleaned 
        result = normalize_ingredient_name("xyz bahan aneh")
        assert result == "xyz bahan aneh"

    def test_fuzzy_match_close(self):
        # Typo ringan harus tetap ter-resolve via fuzzy matching 
        result = normalize_ingredient_name("bawput")
        assert result == "bawang putih"


class TestEstimateExpiryDate:
    # Test estimasi expiry menggunakan default shelf-life (mock DB) 

    @pytest.fixture(autouse=True)
    def _reset_cache(self):
        # Reset shelf-life cache sebelum setiap test agar pakai default lokal 
        import app.services.normalizer as mod
        mod._shelf_life_cache = None  # force reload
        # Patch _load_shelf_life_cache agar selalu return default dict (skip DB)
        with patch.object(mod, "_load_shelf_life_cache", return_value=_get_default_shelf_life()):
            yield

    def test_natural_bayam(self):
        # Bayam segar -> 2 hari dari hari ini 
        base = date(2026, 3, 26)
        result = estimate_expiry_date("bayam", is_natural=True, from_date=base)
        assert result == base + timedelta(days=2)

    def test_natural_ayam(self):
        # Ayam segar -> 2 hari 
        base = date(2026, 3, 26)
        result = estimate_expiry_date("ayam", is_natural=True, from_date=base)
        assert result == base + timedelta(days=2)

    def test_natural_telur(self):
        # Telur -> 21 hari 
        base = date(2026, 3, 26)
        result = estimate_expiry_date("telur", is_natural=True, from_date=base)
        assert result == base + timedelta(days=21)

    def test_not_natural_returns_none(self):
        # Bahan non-alami -> None 
        result = estimate_expiry_date("indomie", is_natural=False)
        assert result is None

    def test_unknown_ingredient_uses_default(self):
        # Bahan alami yang tidak dikenal -> fallback 5 hari 
        base = date(2026, 3, 26)
        result = estimate_expiry_date("bahan langka", is_natural=True, from_date=base)
        assert result == base + timedelta(days=5)


class TestDefaultShelfLife:
    def test_contains_common_items(self):
        shelf_life = _get_default_shelf_life()
        assert "bayam" in shelf_life
        assert "ayam" in shelf_life
        assert "telur" in shelf_life
        assert "tomat" in shelf_life

    def test_values_are_positive(self):
        for name, days in _get_default_shelf_life().items():
            assert days > 0, f"Shelf-life untuk '{name}' harus positif"