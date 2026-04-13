from __future__ import annotations

import re
import logging
from datetime import date, timedelta
from difflib import get_close_matches

from app.core.supabase import get_supabase
from Sastrawi.Stemmer.StemmerFactory import StemmerFactory # Tambahkan ini

logger = logging.getLogger(__name__)

# Inisialisasi Stemmer sekali saja
_factory = StemmerFactory()
_stemmer = _factory.create_stemmer()

# ---------------------------------------------------------------------------
# Kamus alias diperluas
# ---------------------------------------------------------------------------
_ALIAS_MAP: dict[str, str] = {
    "baput": "bawang putih",
    "bamer": "bawang merah",
    "bawmer": "bawang merah",
    "bawput": "bawang putih",
    "bombay": "bawang bombay",
    "cabe": "cabai",
    "cabe merah": "cabai merah",
    "cabe rawit": "cabai rawit",
    "cabe hijau": "cabai hijau",
    "telor": "telur",
    "sawi hijau": "sawi",
    "sawi putih": "sawi",
    "saos": "saus",
    "tapioka": "tepung tapioka",
    "maizena": "tepung maizena",
    "minyak": "minyak goreng",
    "gula": "gula pasir",
    "lada": "lada bubuk",
    "merica": "lada bubuk",
    "kacang polong": "kacang polong",
    "kcg": "kacang",
    "kcg polng": "kacang polong",
    "kcg polong": "kacang polong",
}

_shelf_life_cache: dict[str, int] | None = None

def _clean_text(text: str) -> str:
    """Pembersihan teks mendalam dengan Stemming."""
    text = text.lower().strip()
    # Hapus karakter non-alfabet
    text = re.sub(r"[^a-z\s]", " ", text)
    # Stemming (Mengubah 'bawangan' -> 'bawang', 'sayuran' -> 'sayur')
    text = _stemmer.stem(text)
    # Hapus spasi ganda
    text = re.sub(r"\s+", " ", text).strip()
    return text

def normalize_ingredient_name(raw_name: str) -> str:
    # 1. Pembersihan dasar
    cleaned = raw_name.lower().strip()
    cleaned = re.sub(r"[^a-z\s]", " ", cleaned)
    cleaned = re.sub(r"\s+", " ", cleaned).strip()

    if not cleaned:
        return ""

    # 2. PRIORITAS 1: Exact Match di Alias Map (untuk singkatan utuh)
    if cleaned in _ALIAS_MAP:
        return _ALIAS_MAP[cleaned]

    # 3. PRIORITAS 2: Cek per kata untuk menangani singkatan (kcg -> kacang)
    words = cleaned.split()
    expanded_words = []
    for w in words:
        if w in _ALIAS_MAP:
            expanded_words.append(_ALIAS_MAP[w])
        else:
            expanded_words.append(w)
    
    # Gabungkan kembali (misal: "kcg polng" jadi "kacang polng")
    cleaned_expanded = " ".join(expanded_words)

    # 4. Bangun Kamus Referensi untuk Fuzzy Match
    shelf_life_db = _load_shelf_life_cache()
    master_dictionary = list(set(
        list(shelf_life_db.keys()) + 
        list(_get_default_shelf_life().keys()) + 
        list(_ALIAS_MAP.keys()) +
        list(_ALIAS_MAP.values())
    ))

    # 5. Fuzzy Match pada hasil yang sudah diekspansi
    # Gunakan cutoff 0.6 untuk mengakomodasi singkatan yang masih tersisa typo (polng -> polong)
    matches = get_close_matches(cleaned_expanded, master_dictionary, n=1, cutoff=0.6)

    if matches:
        matched_word = matches[0]
        # Jika hasil match adalah alias, ambil value aslinya
        return _ALIAS_MAP.get(matched_word, matched_word)

    # 6. Fallback terakhir: Stemming
    stemmed = _stemmer.stem(cleaned_expanded)
    if stemmed != cleaned_expanded:
        matches = get_close_matches(stemmed, master_dictionary, n=1, cutoff=0.6)
        if matches:
            return _ALIAS_MAP.get(matches[0], matches[0])

    return cleaned_expanded

def estimate_expiry_date(
    item_name: str,
    is_natural: bool = False,
    from_date: date | None = None,
) -> date | None:
    if not is_natural:
        return None

    shelf_life = _load_shelf_life_cache()
    # Gunakan nama yang sudah dinormalisasi untuk mencari masa simpan
    normalized = normalize_ingredient_name(item_name)
    
    # Cari di cache
    days = shelf_life.get(normalized)

    # Jika tidak ketemu, coba cari kata dasarnya saja (misal: "bawang merah" -> cek "bawang")
    if days is None and " " in normalized:
        first_word = normalized.split()[0]
        days = shelf_life.get(first_word)

    # Jika masih tidak ketemu, gunakan fuzzy match sangat ketat
    if days is None:
        candidates = get_close_matches(normalized, shelf_life.keys(), n=1, cutoff=0.8)
        if candidates:
            days = shelf_life[candidates[0]]

    # Fallback default 5 hari
    if days is None:
        days = 5
        logger.debug("Default 5 hari untuk: %s", normalized)

    base = from_date or date.today()
    return base + timedelta(days=days)

def _load_shelf_life_cache() -> dict[str, int]:
    global _shelf_life_cache
    if _shelf_life_cache is not None:
        return _shelf_life_cache
    
    # Load dari DB (sama seperti kode lama Anda)
    try:
        sb = get_supabase()
        result = sb.table("shelf_life_reference").select("*").execute()
        _shelf_life_cache = {row["ingredient_name"].lower(): row["shelf_life_days"] for row in result.data}
    except:
        _shelf_life_cache = _get_default_shelf_life()
    return _shelf_life_cache

def _get_default_shelf_life() -> dict[str, int]:
    # Tetap gunakan daftar default Anda sebelumnya
    return {
        "sayur": 3, "bayam": 2, "kangkung": 2, "sawi": 3, 
        "wortel": 7, "ayam": 2, "daging": 3, "telur": 21,
        "tempe": 2, "tahu": 3, "susu": 5, "cabai": 7
    }

def resolve_category_from_shelf_life(item_name: str) -> int | None:
    """Cari category_id dengan mencocokkan kata kunci."""
    try:
        sb = get_supabase()
        normalized = normalize_ingredient_name(item_name)
        # Ambil kata pertama sebagai keyword utama
        keyword = normalized.split()[0]
        
        result = (
            sb.table("shelf_life_reference")
            .select("category_id")
            .ilike("ingredient_name", f"%{keyword}%")
            .limit(1)
            .execute()
        )
        if result.data:
            return result.data[0]["category_id"]
    except:
        pass
    return None
