from typing import Annotated

from fastapi import APIRouter, Depends

from app.core.config import Settings, get_settings
from app.schemas.url_analysis import UrlAnalysisRequest, UrlAnalysisResponse
from app.services.heuristic_analyzer import HeuristicAnalyzer
from app.services.safe_browsing import SafeBrowsingService
from app.services.url_analyzer import UrlAnalyzerService

router = APIRouter()


SettingsDependency = Annotated[Settings, Depends(get_settings)]


def get_analyzer(settings: SettingsDependency) -> UrlAnalyzerService:
    reputation = SafeBrowsingService(api_key=settings.google_safe_browsing_api_key)
    return UrlAnalyzerService(HeuristicAnalyzer(), reputation)


@router.post("/analyze", response_model=UrlAnalysisResponse)
async def analyze_url(
    request: UrlAnalysisRequest,
    analyzer: Annotated[UrlAnalyzerService, Depends(get_analyzer)],
) -> UrlAnalysisResponse:
    return await analyzer.analyze(request.url)
