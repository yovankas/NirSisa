"""
Pydantic schemas for inventory CRUD — validates JSON from mobile app.
"""

from datetime import date, datetime
from pydantic import BaseModel, Field


class InventoryItemCreate(BaseModel):
    item_name: str = Field(..., min_length=1, max_length=150)
    quantity: float = Field(default=1, gt=0)
    unit: str = Field(default="buah", max_length=30)
    expiry_date: date | None = None
    is_natural: bool = False  # True = no packaging, estimate from shelf_life


class InventoryItemUpdate(BaseModel):
    item_name: str | None = Field(default=None, max_length=150)
    quantity: float | None = Field(default=None, gt=0)
    unit: str | None = Field(default=None, max_length=30)
    expiry_date: date | None = None


class InventoryItemResponse(BaseModel):
    id: str
    item_name: str
    item_name_normalized: str | None
    category_id: int | None
    category_name: str | None = None
    quantity: float
    unit: str | None
    expiry_date: date | None
    is_natural: bool
    days_remaining: int | None = None
    spi_score: float | None = None
    freshness_status: str | None = None  # fresh, warning, critical, expired
    added_at: datetime
    updated_at: datetime
