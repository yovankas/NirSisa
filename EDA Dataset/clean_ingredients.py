"""
clean_ingredients.py
--------------------
Aggressive cleaning of Indonesian recipe ingredient data.
Reads raw "Ingredients" column, outputs fully normalized "Ingredients Cleaned".

Usage:  python clean_ingredients.py
"""

import re
import csv
import unicodedata

# ═══════════════════════════════════════════════════════════════════════════════
# EXPORTABLE CONSTANTS (reusable by normalizer.py)
# ═══════════════════════════════════════════════════════════════════════════════

ALIAS_MAP: dict[str, str] = {
    # chilli
    "cabe rawit merah": "cabai rawit",
    "cabe merah keriting": "cabai merah keriting",
    "cabai merah keriting": "cabai merah keriting",
    "cabai keriting": "cabai merah keriting",
    "cabe merah": "cabai merah",
    "cabe rawit": "cabai rawit",
    "cabe hijau": "cabai hijau",
    "cabe": "cabai",
    "lombok merah": "cabai merah",
    "lombok": "cabai",
    "rawit": "cabai rawit",
    "cabai setan": "cabai rawit",
    # egg
    "telor ayam": "telur ayam",
    "telor bebek": "telur bebek",
    "telor puyuh": "telur puyuh",
    "telor": "telur",
    "putih telor": "putih telur",
    "kuning telor": "kuning telur",
    # spices
    "laos": "lengkuas",
    "sereh": "serai",
    "sere": "serai",
    "jahe merah": "jahe",
    "merica": "lada",
    "merica bubuk": "lada bubuk",
    "lada hitam": "lada hitam",
    # onion
    "brambang": "bawang merah",
    "bawang bombai": "bawang bombay",
    "bawang bombay": "bawang bombay",
    "bawang p": "bawang putih",
    # vegetables
    "pete": "petai",
    "touge": "tauge",
    "toge": "tauge",
    "daun bawang": "daun bawang",
    # coconut
    "santen": "santan",
    "santan kental": "santan",
    "santan encer": "santan",
    "kelapa parut": "kelapa",
    # leaves
    "daun jeruk purut": "daun jeruk",
    "daun jeruk wangi": "daun jeruk",
    "jeruk purut": "daun jeruk",
    "daun salm": "daun salam",
    # sugar
    "gula jawa": "gula merah",
    "gula aren": "gula merah",
    "gula merah": "gula merah",
    # sauce
    "saos sambal": "saus sambal",
    "saos tomat": "saus tomat",
    "saos tiram": "saus tiram",
    "saos teriyaki": "saus teriyaki",
    "saos": "saus",
    "saus teriyaki": "saus teriyaki",
    # misc
    "penyedap rasa": "penyedap",
    "vetsin": "penyedap",
    "micin": "penyedap",
    "air matang": "air",
    "air mentah": "air",
    "air bersih": "air",
}

COMPOUND_WHITELIST: set[str] = {
    "minyak goreng", "bawang goreng", "nasi goreng", "mie goreng",
    "mi goreng", "kentang goreng", "tepung goreng", "tempe goreng",
    "tahu goreng", "ayam goreng", "ikan goreng", "udang goreng",
    "bawang merah goreng", "bawang putih goreng",
    "wortel korek api",  # will be normalized later to "wortel"
}

PREP_WORDS: list[str] = [
    # passive di- forms
    "digoreng", "direbus", "dikukus", "dibakar", "dipotong", "diiris",
    "dicincang", "dihaluskan", "digeprek", "dimemarkan", "dikupas",
    "diulek", "disangrai", "diparut", "dirajang", "diblender",
    "dimixer", "diaduk", "ditabur", "ditumis", "direndam", "diseduh",
    "dimasak", "dichopper", "dioven", "dipanggang", "dimarinasi",
    "dilumuri", "diungkep", "dipresto", "dibuang", "dibersihkan",
    "disuwir", "dipipihkan", "dipenyet", "difillet",
    # -kan forms
    "haluskan", "memarkan", "tumiskan", "campurkan",
    # base forms
    "sangrai", "bakar", "kukus", "goreng", "rebus",
    "rajang", "cincang", "geprek", "kupas", "cuci",
    "potong", "iris", "serong", "tipis", "kasar", "dadu",
    "halus", "parut", "ulek", "jari", "panggang",
    "tumis", "blender", "mixer", "oven", "presto",
    "suwir", "cacah", "sobek", "belah",
    # descriptors
    "kecil", "besar", "sedang", "utuh", "segar", "bersih", "bersihkan",
    "matang", "mentah", "empuk", "lembut", "wangi", "enak",
    "kating",  # bawang putih kating = just bawang putih
    "bersh", "bersiih", "bersihin", "bersihkan", "bersihkn",  # typos/variants of bersih
    "pengempuk",  # "pengempuk daging" = tenderizer
    "harum", "wanginya",
    # size/shape descriptors
    "korek api", "ukuran",
    # remnants
    "jumbo", "super", "original",
]

# Abbreviation → expansion (applied as substring replacement)
ABBREV_MAP: dict[str, str] = {
    # multi-char abbreviations (longest first is enforced at runtime)
    "sckpnya": "secukupnya",
    "scukupnya": "secukupnya",
    "scukupx": "secukupnya",
    "scukup": "secukupnya",
    "sckpny": "secukupnya",
    "lmbr": "lembar",
    "btng": "batang",
    "ptng": "potong",
    "bwng": "bawang",
    "bwg": "bawang",
    "bgian": "bagian",
    "russ": "ruas",
    "slera": "selera",
    "ekr": "ekor",
    "negri": "negeri",
    "sdh": "sudah",
    "blm": "belum",
    "smpe": "sampai",
    "tmbh": "tambah",
    "dtmbh": "ditambah",
    "tmbhn": "tambahan",
    "bbrp": "beberapa",
    "diptng": "dipotong",
    "hihihii": "",
    "hihi": "",
    "hehe": "",
    "bwg": "bawang",
    "kya": "seperti",
    # short abbreviations
    "dgn": "dengan",
    "krn": "karena",
    "pke": "pakai",
    "blh": "boleh",
    "trs": "terus",
    "klo": "kalau",
    "utk": "untuk",
    "tdk": "tidak",
    "nggak": "tidak",
}

# Single-letter noise: standalone "m", "n", "d", "g", "p", "q", "x", "uk" before/after spaces
# These are remnants of broken abbreviations
# Match standalone single letters AND "uk" but NOT inside words
# Use lookbehind/ahead for spaces or string boundaries
SINGLE_LETTER_NOISE = re.compile(r"(?:^|\s)[mndgpqx](?:\s|$)")
UK_NOISE = re.compile(r"(?<!\w)uk(?!\w)")

VAGUE_QTY: list[str] = [
    "secukupnya", "sesuai selera", "sejumput", "segenggam",
    "kira-kira", "secukup nya", "kurang lebih", "munjung",
    "sedikit", "sebanyaknya",
]

PERSONAL_COMMENT_PHRASES: list[str] = [
    "saya pakai", "saya pake", "aku pakai", "aku pake", "aku suka",
    "suami saya", "anak saya", "kalau saya", "menurut saya",
    "sy pake", "sy pakai", "q pake",
    "bisa diganti", "bisa ditambah", "bisa dikurangi", "bisa di ganti",
    "bisa di tambah", "bisa diskip", "bisa di lewat", "bisa di sesuai",
    "bisa disesuaikan", "bisa pakai", "bisa pake", "boleh pakai",
    "boleh pake", "boleh tidak", "boleh kurang", "boleh lebih",
    "kalo gak ada", "kalau ada", "kalo pengen", "kalau kurang",
    "kalo mau", "kalau mau", "kalo emang", "kalau ga", "kalau tidak",
    "kalo ga", "kalo suka", "kalau suka",
    "jika ingin", "jika suka", "jika mau", "jika tidak", "jika tdak",
    "optional", "opsional", "note:", "nb:", "note ",
    "sesuaikan rasa", "sesuaikan", "disesuaikan",
    "ambil bagian", "ambil bag", "ambil dagingnya", "ambil putihnya",
    "bagian putihnya", "bagian putih",
    "hanya supaya", "supaya", "lumuri", "atau lebih",
    "d fillet", "di fillet",
    "jangan", "lebih enak", "lebih gurih", "lebih nikmat",
    "tergantung", "terserah",
]

SECTION_HEADERS: set[str] = {
    "bumbu halus", "bumbu", "bahan", "pelengkap", "bumbu pelengkap",
    "bumbu dihaluskan", "tambahan", "bahan pelengkap",
    "topping", "hiasan", "garnish", "sesuaikan",
    "sambal", "olesan", "cocolan", "adonan", "isian",
}

SECTION_HEADER_PATTERNS: list[str] = [
    "bumbu", "bahan", "pelengkap", "tambahan", "topping", "hiasan",
    "olesan", "sambal", "cocolan", "kuah", "saos", "saus",
    "rempah", "toping", "garnish", "isian", "adonan",
    "air untuk", "untuk merebus", "untuk menggoreng",
    "untuk saos", "untuk saus", "untuk olesan", "untuk cocol",
    "untuk makan", "untuk penyajian",
]

BRAND_MAP: dict[str, str] = {
    "santan kara": "santan", "santan instant": "santan",
    "kecap bango": "kecap manis", "kecap abc": "kecap manis",
    "ro*co": "", "m***ko": "", "r*y*o": "",
    "royco": "", "masako": "", "royko": "",
    "kara": "santan", "bango": "kecap manis", "abc": "kecap manis",
    "saori": "saus tiram", "sajiku": "", "ladaku": "lada",
    "sasa": "", "indofood": "", "maggi": "", "maggy": "",
    "sariwangi": "", "tropicana slim": "", "tropicana": "",
}

UNITS: list[str] = [
    "ekor", "buah", "sdm", "sdt", "siung", "ruas", "lembar", "batang",
    "butir", "gram", "gr", "kg", "ml", "liter", "cm", "bh", "biji",
    "sendok", "bungkus", "papan", "sachet", "bks", "potong", "iris",
    "ikat", "gelas", "cup", "ons", "helai", "tangkai", "genggam",
    "jumput", "lbr", "btg", "btr", "jari", "pcs", "pieces",
    "pasang", "kaleng", "kotak", "sisir", "bonggol",
]

NOISE_ONLY_WORDS: set[str] = {
    "untuk", "dengan", "karena", "terus", "sudah", "yang", "atau",
    "juga", "sedikit", "banyak", "agak", "lebih", "cukup",
    "deh", "sih", "aja", "ajah", "nih", "tuh", "dong", "donk",
    "yaa", "ya", "yah", "bgt", "banget", "kok", "lho", "loh",
    "pcs", "pieces", "pasang", "lagi", "kembali", "lain",
    "sampai", "hingga", "kemudian", "setelah", "sebelum",
    "tidak", "belum", "sudah", "ada", "ini", "itu",
    "boleh", "bisa", "suka", "mau", "pakai", "pake",
    "tambah", "tambahkan", "campur", "campurkan",
    "menjadi", "jadi", "dari", "ke", "di",
    "pedas", "asin", "manis", "gurih", "asam",
}

# Post-cleaning normalizations: ingredient → canonical name
# Applied at the very end to standardize common outputs
POST_NORMALIZE: dict[str, str] = {
    "wortel korek api": "wortel",
    "air matang": "air",
    "air mentah": "air",
    "air panas": "air",
    "air es": "air",
    "air bersih": "air",
    "kepala ayam": "ayam",
    "ceker ayam": "ceker ayam",
    "sayap ayam": "sayap ayam",
    "paha ayam": "paha ayam",
    "dada ayam": "dada ayam",
    "fillet ayam": "dada ayam",
    "daging ayam": "ayam",
    "kulit ayam": "kulit ayam",
    "teh celup sariwangi": "teh celup",
    "teh celup": "teh celup",
    "bubuk pengempuk daging": "pengempuk daging",
    "pengempuk daging": "pengempuk daging",
    "es batu": "es batu",
}

# ═══════════════════════════════════════════════════════════════════════════════
# COMPILED REGEXES
# ═══════════════════════════════════════════════════════════════════════════════

_RE_PARENS = re.compile(r"\([^)]*\)")
_RE_BRACKETS = re.compile(r"\[[^\]]*\]")
_RE_SPECIAL_CHARS = re.compile(r"[#>*★✿❤♥•·\-–—|/\\&@!~`\+=%\^]+")
_RE_DOTS = re.compile(r"\.+")

_UNITS_PATTERN = "|".join(re.escape(u) for u in sorted(UNITS, key=len, reverse=True))
_RE_LEADING_QTY = re.compile(
    r"^[\d\s./,]*"
    r"(?:\d+\s*[/]\s*\d+\s*)?"
    r"(?:" + _UNITS_PATTERN + r")?\s*",
    re.IGNORECASE,
)

def _make_phrase_re(phrases: list[str], flags: int = re.IGNORECASE) -> re.Pattern:
    sorted_phrases = sorted(phrases, key=len, reverse=True)
    escaped = [re.escape(p) for p in sorted_phrases]
    return re.compile(r"\b(?:" + "|".join(escaped) + r")\b", flags)

_RE_VAGUE = _make_phrase_re(VAGUE_QTY)
_RE_PREP = _make_phrase_re(PREP_WORDS)

# Sentence triggers: if found after ingredient text, truncate there
_SENTENCE_TRIGGERS = [
    "untuk ", "supaya ", "agar ", "biar ", "karena ",
    "yang sudah", "yang telah", "yang di", "yang ",
    "kalau ", "kalo ", "jika ", "bila ",
    "sampai ", "hingga ", "setelah ", "sebelum ",
    "jangan ", "buat ", "atau bisa", "atau pake",
    "lalu ", "kemudian ", "cuci ", "seperti ",
]

def _remove_emojis(text: str) -> str:
    result = []
    for ch in text:
        if ord(ch) > 0xFFFF:
            continue
        if unicodedata.category(ch).startswith("So"):
            continue
        result.append(ch)
    return "".join(result)


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN CLEANING FUNCTION
# ═══════════════════════════════════════════════════════════════════════════════

def clean_single_ingredient(raw: str) -> str:
    text = raw

    # 1. Remove parenthetical and bracket content
    text = _RE_PARENS.sub("", text)
    text = _RE_BRACKETS.sub("", text)

    # 2. Remove emojis and special characters
    text = _remove_emojis(text)
    text = _RE_SPECIAL_CHARS.sub(" ", text)
    text = _RE_DOTS.sub(" ", text)

    # 3. Lowercase
    text = text.lower().strip()

    # 4. Truncate at semicolon
    if ";" in text:
        text = text.split(";")[0].strip()

    # 5. Check section headers with colon
    if ":" in text:
        for pattern in SECTION_HEADER_PATTERNS:
            if pattern in text:
                return ""
        text = text.split(":")[0].strip()

    # 6. Truncate at inner comma (keeps only first item)
    if "," in text:
        text = text.split(",")[0].strip()

    # 7. Expand abbreviations (longest first)
    for abbr in sorted(ABBREV_MAP.keys(), key=len, reverse=True):
        if abbr in text:
            text = text.replace(abbr, ABBREV_MAP[abbr])

    # 7b. Fix digits merged with words: "80yg" → "80 yg", "2pasang" → "2 pasang"
    text = re.sub(r"(\d)([a-z])", r"\1 \2", text)
    text = re.sub(r"([a-z])(\d)", r"\1 \2", text)

    # 8. Handle reduplikasi: potong2→potong, kecil2→kecil, sobek2→sobek
    text = re.sub(r"(\w+)2", r"\1", text)

    # 9. Remove ALL single-letter tokens — no exceptions
    text = re.sub(r"\b[a-z]\b", "", text)

    # 9b. Remove short abbreviation noise (2-letter)
    for short in ["yg","uk","jd","dr","dl","bs","sm","aj","sy","tp","lg","dg","kl","ga","gk","bt","cb","hr","tr"]:
        text = re.sub(r"\b" + short + r"\b", "", text)

    # 9c. Remove informal/spoken words
    for slang in ["jgn","aja","ajah","deh","sih","dong","donk","nih","tuh","yaa","yah",
                   "ya","kok","lho","loh","bgt","banget","hgg","ter","kpg"]:
        text = re.sub(r"\b" + re.escape(slang) + r"\b", "", text)

    # 9d. Remove "nya" suffix words (>4 chars): "wanginya"→"", "enaknya"→""
    text = re.sub(r"\b\w{3,}nya\b", "", text)
    # Remove repeated letters: "lembuttttt"→"lembut", "enakkk"→"enak"
    text = re.sub(r"(.)\1{2,}", r"\1", text)

    # 9e. Remove typos/broken fragments
    for typo in ["sebentr","dbersihan","dbersih","bersihkn","bersihin","bersh","negri",
                  "sambl","hgg"]:
        text = re.sub(r"\b" + re.escape(typo) + r"\b", "", text)

    # 10. Remove personal comment phrases (truncate from match to end)
    for phrase in sorted(PERSONAL_COMMENT_PHRASES, key=len, reverse=True):
        idx = text.find(phrase)
        if idx != -1:
            text = text[:idx].strip()

    # 11. Truncate at sentence triggers
    for trigger in _SENTENCE_TRIGGERS:
        idx = text.find(trigger)
        if idx > 0:
            text = text[:idx].strip()

    # 12. Remove vague quantities
    text = _RE_VAGUE.sub("", text)

    # 13. Remove leading numbers and units
    text = _RE_LEADING_QTY.sub("", text).strip()
    text = re.sub(r"^\d[\d\s./,]*\s*", "", text).strip()
    # Trailing numbers: "sayap ayam 2" → "sayap ayam"
    text = re.sub(r"\s+\d+\s*$", "", text).strip()
    # Numbers embedded in text: "ayam 1 2 kg" → "ayam", "fillet ayam 1 4 kg" → "fillet ayam"
    text = re.sub(r"\s+\d[\d\s./]*\s*(?:" + _UNITS_PATTERN + r")?\s*", " ", text, flags=re.IGNORECASE).strip()
    # Any remaining standalone numbers between words
    text = re.sub(r"\b\d+\b", "", text).strip()

    # 14. Normalise brand names
    for brand in sorted(BRAND_MAP.keys(), key=len, reverse=True):
        replacement = BRAND_MAP[brand]
        text = re.sub(r"\b" + re.escape(brand) + r"\b", replacement, text, flags=re.IGNORECASE)

    # 15. Remove prep/cooking words (protect compound whitelist)
    if text not in COMPOUND_WHITELIST:
        text = _RE_PREP.sub("", text)

    # 16. Normalise spelling via alias map
    for alias in sorted(ALIAS_MAP.keys(), key=len, reverse=True):
        canonical = ALIAS_MAP[alias]
        text = re.sub(r"\b" + re.escape(alias) + r"\b", canonical, text, flags=re.IGNORECASE)

    # 17. Post-normalize known compound ingredient names
    text_stripped = re.sub(r"\s+", " ", text).strip()
    if text_stripped in POST_NORMALIZE:
        text_stripped = POST_NORMALIZE[text_stripped]
    text = text_stripped

    # 18. Final cleanup
    text = re.sub(r"\s{2,}", " ", text).strip()
    text = re.sub(r",+", "", text)
    text = text.strip(".,;:!? ")

    # 19. Discard rules
    if not text:
        return ""
    if re.fullmatch(r"[\d\s./,\-]+", text):
        return ""
    if text in SECTION_HEADERS:
        return ""
    if len(text) > 35:
        return ""
    if len(text) < 2:
        return ""
    words = set(text.split())
    if words.issubset(NOISE_ONLY_WORDS):
        return ""
    if text == "air":
        return ""

    # 20. FINAL VALIDATION PASS — catch any remaining noise
    # Remove any single-letter tokens that survived
    text = re.sub(r"\b[a-z]\b", "", text).strip()
    text = re.sub(r"\s{2,}", " ", text).strip()

    # Final discard checks
    if not text or len(text) < 2:
        return ""
    words = set(text.split())
    if words.issubset(NOISE_ONLY_WORDS):
        return ""

    return text


def clean_ingredients_cell(raw_cell: str) -> tuple[list[str], int]:
    raw_parts = [p.strip() for p in raw_cell.split("--") if p.strip()]
    cleaned = []
    seen = set()
    for part in raw_parts:
        result = clean_single_ingredient(part)
        if not result:
            continue
        sub_items = re.split(r"\s+dan\s+|\s+and\s+", result)
        for sub in sub_items:
            sub = sub.strip().strip(",").strip()
            if sub and sub not in SECTION_HEADERS and sub != "air" and sub not in seen:
                seen.add(sub)
                cleaned.append(sub)
    return cleaned, len(cleaned)


# ═══════════════════════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════════════════════

def main() -> None:
    input_path = r"D:\PPT\NirSisa\EDA Dataset\Indonesian_Food_Recipes.csv"
    output_path = r"D:\PPT\NirSisa\EDA Dataset\Indonesian_Food_Recipes_Cleaned_v2.csv"

    print("Reading:", input_path)

    rows_in: list[dict] = []
    with open(input_path, encoding="utf-8", newline="") as f:
        reader = csv.DictReader(f)
        fieldnames = reader.fieldnames or []
        for row in reader:
            rows_in.append(row)

    print(f"Total rows: {len(rows_in)}")

    total_raw = 0
    total_clean = 0

    rows_out: list[dict] = []
    for i, row in enumerate(rows_in):
        raw_cell = row.get("Ingredients", "")
        raw_count = len([p for p in raw_cell.split("--") if p.strip()])
        total_raw += raw_count

        cleaned_list, clean_count = clean_ingredients_cell(raw_cell)
        total_clean += clean_count

        new_row = dict(row)
        new_row["Ingredients Cleaned"] = ", ".join(cleaned_list)
        new_row["Total Ingredients"] = clean_count
        rows_out.append(new_row)

    print("Writing:", output_path)
    with open(output_path, "w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows_out)

    removed = total_raw - total_clean
    pct = removed / total_raw * 100 if total_raw else 0
    print(f"\nTotal ingredients (raw)  : {total_raw}")
    print(f"Total ingredients (clean): {total_clean}")
    print(f"Removed                  : {removed} ({pct:.1f}%)")
    print("\nDone:", output_path)


if __name__ == "__main__":
    main()
