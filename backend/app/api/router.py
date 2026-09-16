from fastapi import APIRouter

from app.api.routes import health, url_analysis

api_router = APIRouter()
api_router.include_router(health.router)
api_router.include_router(url_analysis.router, prefix="/api/v1/urls", tags=["URLs"])
