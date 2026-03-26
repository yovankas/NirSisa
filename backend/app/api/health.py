from fastapi import APIRouter
from app.core.supabase import get_supabase
from app.ai.cbf import RecipeKnowledgeBase

router = APIRouter(tags=["Health"])


@router.get("/health")
async def health_check():
    # Database check
    try:
        sb = get_supabase()
        result = sb.table("recipe_categories").select("id").limit(1).execute()
        db_ok = len(result.data) > 0
    except Exception:
        db_ok = False

    # AI Engine check
    kb = RecipeKnowledgeBase.get_instance()

    return {
        "status": "healthy" if db_ok else "degraded",
        "database": "connected" if db_ok else "unreachable",
        "ai_engine_loaded": kb.is_loaded,
        "total_recipes": len(kb.df_recipes) if kb.is_loaded else 0,
    }