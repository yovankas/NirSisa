"""
Data Normalizer
================
Modul normalisasi teks input pengguna:
1. Lowercasing & pembersihan karakter
2. Fuzzy matching ke kategori standar
3. Estimasi kedaluwarsa otomatis dari shelf-life reference (untuk bahan alami)
"""

from __future__ import annotations

import re
import logging
from datetime import date, timedelta
from difflib import get_close_matches

from app.core.supabase import get_supabase

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Kamus alias umum → nama standar (di-expand seiring waktu)
# ---------------------------------------------------------------------------
_ALIAS_MAP: dict[str, str] = {
    # Singkatan umum
    "baput": "bawang putih",
    "bamer": "bawang merah",
    "bawmer": "bawang merah",
    "bawput": "bawang putih",
    "bombay": "bawang bombay",
    "cabe": "cabai",
    "cabe merah": "cabai merah",
    "cabe rawit": "cabai rawit",
    "cabe hijau": "cabai hijau",
    "micin": "penyedap rasa",
    "vetsin": "penyedap rasa",
    "msg": "penyedap rasa",
    "masako": "penyedap rasa",
    "royco": "penyedap rasa",
    "telor": "telur",
    "daun bawang": "daun bawang",
    "daunbawang": "daun bawang",
    "saos": "saus",
    "saos tiram": "saus tiram",
    "kecap": "kecap manis",
    "tapioka": "tepung tapioka",
    "maizena": "tepung maizena",
    "santan": "santan kelapa",
    "susu": "susu cair",
    "keju": "keju",
    "mentega": "mentega",
    "margarin": "margarin",
    "minyak": "minyak goreng",
    "gula": "gula pasir",
    "garam": "garam",
    "lada": "lada bubuk",
    "merica": "lada bubuk",
}

# Cache shelf-life reference dari DB
_shelf_life_cache: dict[str, int] | None = None


def _clean_text(text: str) -> str:
    """Bersihkan teks: lowercase, hapus karakter non-alfabet kecuali spasi."""
    text = text.lower().strip()
    text = re.sub(r"[^a-z\s]", "", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def normalize_ingredient_name(raw_name: str) -> str:
    """Normalisasi nama bahan ke bentuk standar.

    Pipeline:
      1. Clean text
      2. Cek alias map (exact)
      3. Fuzzy match ke alias map keys (cutoff 0.7)
      4. Jika tidak ditemukan, kembalikan cleaned text apa adanya
    """
    cleaned = _clean_text(raw_name)

    # Exact match di alias
    if cleaned in _ALIAS_MAP:
        return _ALIAS_MAP[cleaned]

    # Fuzzy match
    candidates = get_close_matches(cleaned, _ALIAS_MAP.keys(), n=1, cutoff=0.7)
    if candidates:
        matched_key = candidates[0]
        logger.debug("Fuzzy match: '%s' → '%s' → '%s'", raw_name, matched_key, _ALIAS_MAP[matched_key])
        return _ALIAS_MAP[matched_key]

    return cleaned


def _load_shelf_life_cache() -> dict[str, int]:
    """Load shelf-life reference dari Supabase, return dict nama_kategori → hari."""
    global _shelf_life_cache
    if _shelf_life_cache is not None:
        return _shelf_life_cache

    try:
        sb = get_supabase()
        result = sb.table("shelf_life_reference").select("*").execute()
        _shelf_life_cache = {}
        for row in result.data:
            # Asumsi kolom: category_name, default_shelf_life_days
            name = str(row.get("category_name", "")).lower().strip()
            days = int(row.get("default_shelf_life_days", 7))
            _shelf_life_cache[name] = days
        logger.info("Shelf-life reference loaded: %d entries", len(_shelf_life_cache))
    except Exception as e:
        logger.warning("Gagal load shelf-life reference: %s. Menggunakan default.", e)
        _shelf_life_cache = _get_default_shelf_life()

    return _shelf_life_cache


def _get_default_shelf_life() -> dict[str, int]:
    """Fallback shelf-life jika tabel DB belum tersedia."""
    return {
        # Sayuran
        "sayur": 3,
        "sayuran": 3,
        "bayam": 2,
        "kangkung": 2,
        "sawi": 3,
        "wortel": 7,
        "kentang": 14,
        "tomat": 5,
        "brokoli": 4,
        "kol": 7,
        "selada": 3,
        "terong": 5,
        "timun": 5,
        "jagung": 3,
        "buncis": 4,
        "labu": 7,
        "cabai": 7,
        "cabai merah": 7,
        "cabai rawit": 7,
        "cabai hijau": 7,
        # Protein hewani
        "daging": 3,
        "daging sapi": 3,
        "daging ayam": 2,
        "ayam": 2,
        "ikan": 2,
        "udang": 2,
        "cumi": 2,
        "telur": 21,
        "seafood": 2,
        # Olahan susu
        "susu": 5,
        "susu cair": 5,
        "keju": 14,
        "yoghurt": 7,
        "mentega": 30,
        "margarin": 30,
        # Tahu & tempe
        "tahu": 3,
        "tempe": 2,
        # Buah
        "buah": 5,
        "pisang": 4,
        "apel": 14,
        "jeruk": 10,
        "mangga": 5,
        "pepaya": 4,
        "semangka": 3,
        # Bumbu dapur (cenderung tahan lama)
        "bawang putih": 30,
        "bawang merah": 14,
        "bawang bombay": 14,
        "jahe": 21,
        "kunyit": 21,
        "lengkuas": 14,
        "serai": 14,
        "daun bawang": 5,
        "daun salam": 14,
    }


def estimate_expiry_date(
    item_name: str,
    is_natural: bool = False,
    from_date: date | None = None,
) -> date | None:
    """Estimasi tanggal kedaluwarsa untuk bahan alami.

    Jika is_natural=True, cari di shelf-life reference.
    Jika nama tidak ditemukan, gunakan default 5 hari (sayur generik).

    Returns:
        Estimated expiry date, atau None jika bukan bahan alami.
    """
    if not is_natural:
        return None

    shelf_life = _load_shelf_life_cache()
    cleaned = _clean_text(item_name)

    # Exact match
    days = shelf_life.get(cleaned)

    # Fuzzy match ke shelf-life keys
    if days is None:
        candidates = get_close_matches(cleaned, shelf_life.keys(), n=1, cutoff=0.6)
        if candidates:
            days = shelf_life[candidates[0]]

    # Fallback generik
    if days is None:
        days = 5
        logger.debug("Shelf-life tidak ditemukan untuk '%s', gunakan default %d hari", cleaned, days)

    base = from_date or date.today()
    return base + timedelta(days=days)


def resolve_category_from_shelf_life(item_name: str) -> int | None:
    """Coba cari category_id berdasarkan nama bahan di shelf_life_reference.

    Returns:
        category_id atau None jika tidak ditemukan.
    """
    try:
        sb = get_supabase()
        cleaned = _clean_text(item_name)
        result = (
            sb.table("shelf_life_reference")
            .select("id")
            .ilike("category_name", f"%{cleaned}%")
            .limit(1)
            .execute()
        )
        if result.data:
            return result.data[0]["id"]
    except Exception as e:
        logger.debug("resolve_category gagal: %s", e)
    return None
