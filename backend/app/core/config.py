from functools import lru_cache

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_name: str = "ProtegeLink API"
    google_safe_browsing_api_key: str | None = None
    cors_origins: list[str] = ["http://localhost", "http://127.0.0.1"]

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")


@lru_cache
def get_settings() -> Settings:
    return Settings()
