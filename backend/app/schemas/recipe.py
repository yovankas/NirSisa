"""
Pydantic schemas for recipes — read-only from the API perspective.
"""

from pydantic import BaseModel


class RecipeResponse(BaseModel):
    id: int
    title: str
    title_cleaned: str
    ingredients: str
    steps: str
    total_ingredients: int
    total_steps: int
    loves: int
    url: str | None
    category_name: str | None = None


class RecommendationResponse(BaseModel):
    """Response from the recommendation engine.
    AI Engineer: populate similarity_score, spi_score, final_score in recommender.py
    """
    recipe: RecipeResponse
    similarity_score: float
    spi_score: float
    final_score: float
