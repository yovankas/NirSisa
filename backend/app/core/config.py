"""
Application configuration — loaded from environment variables.
"""

from pydantic_settings import BaseSettings
from functools import lru_cache


class Settings(BaseSettings):
    # Supabase
    SUPABASE_URL: str
    SUPABASE_SERVICE_ROLE_KEY: str
    SUPABASE_JWT_SECRET: str

    # App
    APP_NAME: str = "NirSisa API"
    APP_VERSION: str = "0.1.0"
    DEBUG: bool = False

    # CORS (frontend origins)
    CORS_ORIGINS: list[str] = ["*"]

    # AI config (from laporan Tabel 4.5)
    TFIDF_MODEL_VERSION: str = "v1.1"
    SPI_DECAY_FACTOR: float = 2.0
    SPI_WEIGHT: float = 0.4
    COSINE_THRESHOLD: float = 0.5
    TOP_K_RECOMMENDATIONS: int = 10
    NOTIFICATION_THRESHOLD_DAYS: int = 2
    CACHE_TTL_SECONDS: int = 3600

    model_config = {"env_file": ".env", "extra": "ignore"}


@lru_cache
def get_settings() -> Settings:
    return Settings()
