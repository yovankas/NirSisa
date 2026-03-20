# NirSisa - Entity Relationship Diagram

## Relational Schema

```mermaid
erDiagram
    AUTH_USERS ||--|| PROFILES : "extends"
    PROFILES ||--o{ INVENTORY_STOCK : "owns"
    PROFILES ||--o{ CONSUMPTION_HISTORY : "cooks"
    PROFILES ||--o{ DEVICE_TOKENS : "has"
    PROFILES ||--o{ NOTIFICATION_LOG : "receives"

    RECIPE_CATEGORIES ||--o{ RECIPES : "categorizes"
    INGREDIENT_CATEGORIES ||--o{ SHELF_LIFE_REFERENCE : "categorizes"
    INGREDIENT_CATEGORIES ||--o{ INVENTORY_STOCK : "categorizes"

    RECIPES ||--o{ CONSUMPTION_HISTORY : "cooked_as"
    CONSUMPTION_HISTORY ||--o{ CONSUMPTION_HISTORY_ITEMS : "uses"
    INVENTORY_STOCK ||--o{ CONSUMPTION_HISTORY_ITEMS : "consumed_from"
    INVENTORY_STOCK ||--o{ NOTIFICATION_LOG : "triggers"

    AUTH_USERS {
        uuid id PK
        string email
        string encrypted_password
        jsonb raw_user_meta_data
    }

    PROFILES {
        uuid id PK_FK
        varchar display_name
        text avatar_url
        timestamptz created_at
        timestamptz updated_at
    }

    RECIPE_CATEGORIES {
        serial id PK
        varchar name UK "ayam ikan kambing sapi tahu telur tempe udang"
    }

    RECIPES {
        serial id PK
        varchar title
        varchar title_cleaned
        text ingredients
        text ingredients_cleaned "for TF-IDF"
        text steps
        smallint total_ingredients
        smallint total_steps
        integer loves
        text url
        integer category_id FK
        timestamptz created_at
    }

    RECIPE_TFIDF_CACHE {
        serial id PK
        varchar version UK
        bytea vectorizer_blob "joblib TfidfVectorizer"
        bytea tfidf_matrix_blob "joblib sparse matrix"
        jsonb recipe_id_order
        timestamptz fitted_at
    }

    INGREDIENT_CATEGORIES {
        serial id PK
        varchar name UK "sayur buah daging_sapi etc"
    }

    SHELF_LIFE_REFERENCE {
        serial id PK
        varchar ingredient_name
        integer category_id FK
        integer shelf_life_days
        varchar storage_condition "kulkas freezer suhu_ruang"
        varchar source
    }

    INVENTORY_STOCK {
        uuid id PK
        uuid user_id FK
        varchar item_name "raw input"
        varchar item_name_normalized "after fuzzy match"
        integer category_id FK
        decimal quantity
        varchar unit
        date expiry_date
        boolean is_natural
        timestamptz added_at
        timestamptz updated_at
    }

    CONSUMPTION_HISTORY {
        uuid id PK
        uuid user_id FK
        integer recipe_id FK
        varchar recipe_title
        timestamptz cooked_at
    }

    CONSUMPTION_HISTORY_ITEMS {
        uuid id PK
        uuid consumption_id FK
        uuid inventory_stock_id FK
        varchar item_name
        decimal quantity_used
        varchar unit
    }

    DEVICE_TOKENS {
        uuid id PK
        uuid user_id FK
        text fcm_token UK
        varchar device_info
        boolean is_active
        timestamptz created_at
        timestamptz updated_at
    }

    NOTIFICATION_LOG {
        uuid id PK
        uuid user_id FK
        uuid inventory_stock_id FK
        varchar notification_type "expiry_warning expiry_critical"
        varchar title
        text body
        timestamptz sent_at
        boolean delivered
    }
```

## Relational Mapping Summary

| Table | PK | Foreign Keys | Description |
|-------|----|--------------| ------------|
| `profiles` | `id` (UUID) | `auth.users.id` | User profile extension |
| `recipe_categories` | `id` (serial) | - | 8 protein categories |
| `recipes` | `id` (serial) | `recipe_categories.id` | 12,365 Indonesian recipes |
| `recipe_tfidf_cache` | `id` (serial) | - | Pre-computed TF-IDF vectors |
| `ingredient_categories` | `id` (serial) | - | 18 ingredient categories |
| `shelf_life_reference` | `id` (serial) | `ingredient_categories.id` | ~120 shelf-life entries |
| `inventory_stock` | `id` (UUID) | `profiles.id`, `ingredient_categories.id` | User's digital fridge |
| `consumption_history` | `id` (UUID) | `profiles.id`, `recipes.id` | Cooking log |
| `consumption_history_items` | `id` (UUID) | `consumption_history.id`, `inventory_stock.id` | Ingredients used per cook |
| `device_tokens` | `id` (UUID) | `profiles.id` | FCM push notification tokens |
| `notification_log` | `id` (UUID) | `profiles.id`, `inventory_stock.id` | Notification audit trail |

## Storage Layer Mapping (per Laporan BAB III)

| Laporan Component | Database Table(s) |
|---|---|
| User & Inventory Database | `profiles`, `inventory_stock` |
| Recipe Knowledge Base | `recipes`, `recipe_categories`, `recipe_tfidf_cache` |
| Shelf-life Reference | `ingredient_categories`, `shelf_life_reference` |
| Consumption History Log | `consumption_history`, `consumption_history_items` |

## Visual Alert Logic (computed in `inventory_with_spi` view)

| Color | Condition | SPI Behavior |
|-------|-----------|-------------|
| Merah (Critical) | `expiry_date - today <= 2` days | SPI >= 0.11 (high priority) |
| Kuning (Warning) | `2 < expiry_date - today <= 5` days | SPI moderate |
| Hijau (Fresh) | `expiry_date - today > 5` days | SPI low |
