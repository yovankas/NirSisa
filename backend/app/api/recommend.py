"""
Recommendation endpoint — STUB for AI Engineer.

This file defines the API contract. The AI Engineer implements the actual
logic in app/ai/ and this endpoint calls it.
"""

from fastapi import APIRouter, Depends, HTTPException

from app.core.auth import get_current_user_id
from app.core.config import get_settings
from app.schemas.recipe import RecommendationResponse

router = APIRouter(prefix="/recommend", tags=["Recommendations"])


@router.get("", response_model=list[RecommendationResponse])
async def get_recommendations(
    user_id: str = Depends(get_current_user_id),
):
    """
    Get recipe recommendations based on user's current inventory.

    AI Engineer: implement this by:
    1. Fetch user's inventory from inventory_with_spi view
    2. Preprocess ingredients → TF-IDF vector
    3. Compute cosine similarity against recipe matrix
    4. Calculate SPI re-ranking: final = (1-λ)*cosine + λ*SPI
    5. Return top-K results

    Wire it up by importing from app.ai.recommender
    """
    # TODO (AI Engineer): replace this stub with actual recommendation logic
    # Example integration:
    #
    # from app.ai.recommender import get_recommendations_for_user
    # settings = get_settings()
    # results = await get_recommendations_for_user(
    #     user_id=user_id,
    #     top_k=settings.TOP_K_RECOMMENDATIONS,
    #     cosine_threshold=settings.COSINE_THRESHOLD,
    #     spi_weight=settings.SPI_WEIGHT,
    #     spi_alpha=settings.SPI_DECAY_FACTOR,
    # )
    # return results

    raise HTTPException(
        status_code=501,
        detail="Recommendation engine not yet implemented. AI Engineer: see app/ai/",
    )
