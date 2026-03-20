"""
Generate NirSisa ERD diagram as a PNG image.

Usage:
    pip install matplotlib
    python generate_erd_image.py
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches

def draw_table(ax, x, y, name, columns, pk_color='#4A90D9', header_color='#2C5F8A', width=2.8, row_height=0.28):
    """Draw a database table box."""
    total_height = (len(columns) + 1) * row_height

    # Header
    header = mpatches.FancyBboxPatch(
        (x, y - row_height), width, row_height,
        boxstyle="round,pad=0.02", facecolor=header_color, edgecolor='#1a1a2e', linewidth=1.2
    )
    ax.add_patch(header)
    ax.text(x + width/2, y - row_height/2, name, ha='center', va='center',
            fontsize=7.5, fontweight='bold', color='white', fontfamily='monospace')

    # Columns
    for i, (col_name, col_type, is_pk, is_fk) in enumerate(columns):
        cy = y - (i + 2) * row_height
        bg_color = '#E8F0FE' if i % 2 == 0 else '#F5F8FF'
        if is_pk:
            bg_color = '#FFF3CD'

        rect = mpatches.FancyBboxPatch(
            (x, cy), width, row_height,
            boxstyle="round,pad=0.01", facecolor=bg_color, edgecolor='#ccc', linewidth=0.5
        )
        ax.add_patch(rect)

        prefix = ""
        if is_pk:
            prefix = "PK "
        if is_fk:
            prefix += "FK "

        label = f"{prefix}{col_name}"
        ax.text(x + 0.08, cy + row_height/2, label, ha='left', va='center',
                fontsize=5.5, fontfamily='monospace',
                fontweight='bold' if is_pk else 'normal',
                color='#B8860B' if is_pk else ('#0066CC' if is_fk else '#333'))
        ax.text(x + width - 0.08, cy + row_height/2, col_type, ha='right', va='center',
                fontsize=5, fontfamily='monospace', color='#888')

    # Border
    border = mpatches.FancyBboxPatch(
        (x, y - total_height), width, total_height,
        boxstyle="round,pad=0.02", facecolor='none', edgecolor='#1a1a2e', linewidth=1.2
    )
    ax.add_patch(border)

    return x, y, width, total_height


def draw_relation(ax, x1, y1, x2, y2, label='', style='->'):
    """Draw a relationship line between tables."""
    ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                arrowprops=dict(arrowstyle=style, color='#666', lw=1, connectionstyle='arc3,rad=0.1'))
    if label:
        mx, my = (x1+x2)/2, (y1+y2)/2
        ax.text(mx, my + 0.12, label, ha='center', va='center', fontsize=5, color='#666', style='italic')


fig, ax = plt.subplots(1, 1, figsize=(22, 14))
ax.set_xlim(-1, 21)
ax.set_ylim(-12, 1.5)
ax.set_aspect('equal')
ax.axis('off')

# Title
ax.text(10, 1.2, 'NirSisa - Entity Relationship Diagram', ha='center', va='center',
        fontsize=16, fontweight='bold', color='#1a1a2e')
ax.text(10, 0.8, 'PostgreSQL (Supabase) | Adaptive Food Recipe Recommendation System', ha='center', va='center',
        fontsize=9, color='#666')

# ============================================================
# TABLE DEFINITIONS
# (col_name, type, is_pk, is_fk)
# ============================================================

# Row 1: Auth & User domain
draw_table(ax, 0, 0, 'auth.users (Supabase)', [
    ('id', 'UUID', True, False),
    ('email', 'VARCHAR', False, False),
    ('encrypted_password', 'TEXT', False, False),
    ('raw_user_meta_data', 'JSONB', False, False),
], header_color='#6B5B95')

draw_table(ax, 3.5, 0, 'profiles', [
    ('id', 'UUID', True, True),
    ('display_name', 'VARCHAR(100)', False, False),
    ('avatar_url', 'TEXT', False, False),
    ('created_at', 'TIMESTAMPTZ', False, False),
    ('updated_at', 'TIMESTAMPTZ', False, False),
])

draw_table(ax, 7.2, 0, 'device_tokens', [
    ('id', 'UUID', True, False),
    ('user_id', 'UUID', False, True),
    ('fcm_token', 'TEXT UK', False, False),
    ('device_info', 'VARCHAR', False, False),
    ('is_active', 'BOOLEAN', False, False),
    ('created_at', 'TIMESTAMPTZ', False, False),
])

draw_table(ax, 10.8, 0, 'notification_log', [
    ('id', 'UUID', True, False),
    ('user_id', 'UUID', False, True),
    ('inventory_stock_id', 'UUID', False, True),
    ('notification_type', 'VARCHAR(50)', False, False),
    ('title', 'VARCHAR(255)', False, False),
    ('body', 'TEXT', False, False),
    ('sent_at', 'TIMESTAMPTZ', False, False),
    ('delivered', 'BOOLEAN', False, False),
])

# Row 2: Inventory domain
draw_table(ax, 0.5, -3.5, 'inventory_stock', [
    ('id', 'UUID', True, False),
    ('user_id', 'UUID', False, True),
    ('item_name', 'VARCHAR(150)', False, False),
    ('item_name_normalized', 'VARCHAR(150)', False, False),
    ('category_id', 'INT', False, True),
    ('quantity', 'DECIMAL(10,2)', False, False),
    ('unit', 'VARCHAR(30)', False, False),
    ('expiry_date', 'DATE', False, False),
    ('is_natural', 'BOOLEAN', False, False),
    ('added_at', 'TIMESTAMPTZ', False, False),
    ('updated_at', 'TIMESTAMPTZ', False, False),
])

draw_table(ax, 4.5, -3.5, 'ingredient_categories', [
    ('id', 'SERIAL', True, False),
    ('name', 'VARCHAR(100) UK', False, False),
], header_color='#5B8C5A')

draw_table(ax, 7.8, -3.5, 'shelf_life_reference', [
    ('id', 'SERIAL', True, False),
    ('ingredient_name', 'VARCHAR(150)', False, False),
    ('category_id', 'INT', False, True),
    ('shelf_life_days', 'INT', False, False),
    ('storage_condition', 'VARCHAR(50)', False, False),
    ('source', 'VARCHAR(255)', False, False),
], header_color='#5B8C5A')

# Row 2 right: Consumption domain
draw_table(ax, 11.5, -3.5, 'consumption_history', [
    ('id', 'UUID', True, False),
    ('user_id', 'UUID', False, True),
    ('recipe_id', 'INT', False, True),
    ('recipe_title', 'VARCHAR(255)', False, False),
    ('cooked_at', 'TIMESTAMPTZ', False, False),
])

draw_table(ax, 15, -3.5, 'consumption_history_items', [
    ('id', 'UUID', True, False),
    ('consumption_id', 'UUID', False, True),
    ('inventory_stock_id', 'UUID', False, True),
    ('item_name', 'VARCHAR(150)', False, False),
    ('quantity_used', 'DECIMAL(10,2)', False, False),
    ('unit', 'VARCHAR(30)', False, False),
])

# Row 3: Recipe domain
draw_table(ax, 7, -7.5, 'recipe_categories', [
    ('id', 'SERIAL', True, False),
    ('name', 'VARCHAR(50) UK', False, False),
], header_color='#D4726A')

draw_table(ax, 10.5, -7.5, 'recipes', [
    ('id', 'SERIAL', True, False),
    ('title', 'VARCHAR(255)', False, False),
    ('title_cleaned', 'VARCHAR(255)', False, False),
    ('ingredients', 'TEXT', False, False),
    ('ingredients_cleaned', 'TEXT', False, False),
    ('steps', 'TEXT', False, False),
    ('total_ingredients', 'SMALLINT', False, False),
    ('total_steps', 'SMALLINT', False, False),
    ('loves', 'INT', False, False),
    ('url', 'TEXT', False, False),
    ('category_id', 'INT', False, True),
    ('created_at', 'TIMESTAMPTZ', False, False),
])

draw_table(ax, 15, -7.5, 'recipe_tfidf_cache', [
    ('id', 'SERIAL', True, False),
    ('version', 'VARCHAR(20) UK', False, False),
    ('vectorizer_blob', 'BYTEA', False, False),
    ('tfidf_matrix_blob', 'BYTEA', False, False),
    ('recipe_id_order', 'JSONB', False, False),
    ('fitted_at', 'TIMESTAMPTZ', False, False),
], header_color='#D4726A')

# ============================================================
# RELATIONSHIPS (arrows)
# ============================================================

# auth.users -> profiles (1:1)
draw_relation(ax, 2.8, -0.14, 3.5, -0.14, '1:1')

# profiles -> device_tokens
draw_relation(ax, 6.3, -0.42, 7.2, -0.42, '1:N')

# profiles -> notification_log
draw_relation(ax, 6.3, -0.7, 10.8, -0.7, '1:N')

# profiles -> inventory_stock
draw_relation(ax, 4.9, -1.68, 2.0, -3.5, '1:N')

# profiles -> consumption_history
draw_relation(ax, 6.3, -1.4, 12.5, -3.5, '1:N')

# ingredient_categories -> inventory_stock
draw_relation(ax, 4.5, -4.06, 3.3, -4.9, '1:N')

# ingredient_categories -> shelf_life_reference
draw_relation(ax, 7.3, -4.06, 7.8, -4.34, '1:N')

# consumption_history -> consumption_history_items
draw_relation(ax, 14.3, -4.9, 15.0, -4.34, '1:N')

# inventory_stock -> consumption_history_items
draw_relation(ax, 3.3, -6.58, 15.5, -5.18, '0:N')

# inventory_stock -> notification_log
draw_relation(ax, 2.0, -3.5, 12.0, -2.52, '0:N')

# recipe_categories -> recipes
draw_relation(ax, 9.8, -8.06, 10.5, -8.06, '1:N')

# recipes -> consumption_history
draw_relation(ax, 12.0, -7.5, 12.8, -5.22, '0:N')

# ============================================================
# LEGEND
# ============================================================
legend_x, legend_y = 0, -10.5
ax.text(legend_x, legend_y, 'Legend:', fontsize=8, fontweight='bold', color='#333')

legend_items = [
    ('#2C5F8A', 'User/Auth Domain'),
    ('#5B8C5A', 'Ingredient/Shelf-life Domain'),
    ('#D4726A', 'Recipe Domain'),
    ('#FFF3CD', 'Primary Key (PK)'),
]
for i, (color, label) in enumerate(legend_items):
    rect = mpatches.FancyBboxPatch(
        (legend_x + 1.2 + i*3.5, legend_y - 0.15), 0.4, 0.25,
        boxstyle="round,pad=0.02", facecolor=color, edgecolor='#333', linewidth=0.8
    )
    ax.add_patch(rect)
    ax.text(legend_x + 1.75 + i*3.5, legend_y - 0.02, label, fontsize=6, va='center', color='#333')

# FK legend
ax.text(legend_x, legend_y - 0.6, 'FK = Foreign Key  |  UK = Unique  |  PK = Primary Key  |  Arrows: 1:N (one-to-many), 0:N (optional)',
        fontsize=6, color='#666')

# Save
output_path = 'D:/PPT/NirSisa/database/erd_nirsisa.png'
plt.savefig(output_path, dpi=200, bbox_inches='tight', facecolor='white', edgecolor='none')
plt.close()
print(f"ERD saved to {output_path}")
