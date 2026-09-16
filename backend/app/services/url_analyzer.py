from urllib.parse import urlsplit

from app.models.url_analysis import AnalysisStatus
from app.schemas.url_analysis import UrlAnalysisResponse
from app.services.heuristic_analyzer import HeuristicAnalyzer
from app.services.safe_browsing import ReputationProvider

SAFE_MAX_SCORE = 29
SUSPICIOUS_MAX_SCORE = 69
EXTERNAL_THREAT_SCORE = 100


class UrlAnalyzerService:
    def __init__(
        self,
        heuristic_analyzer: HeuristicAnalyzer,
        reputation_provider: ReputationProvider,
    ) -> None:
        self._heuristics = heuristic_analyzer
        self._reputation = reputation_provider

    async def analyze(self, url: str) -> UrlAnalysisResponse:
        heuristic = self._heuristics.analyze(url)
        score = heuristic.score
        reasons = list(heuristic.reasons)

        if await self._reputation.is_dangerous(url):
            score = EXTERNAL_THREAT_SCORE
            reasons.append("Google Safe Browsing reportó este enlace como peligroso.")

        return UrlAnalysisResponse(
            url=url,
            domain=urlsplit(url).hostname or "",
            status=self.classify(score),
            risk_score=score,
            reasons=reasons,
        )

    @staticmethod
    def classify(score: int) -> AnalysisStatus:
        if score <= SAFE_MAX_SCORE:
            return AnalysisStatus.SAFE
        if score <= SUSPICIOUS_MAX_SCORE:
            return AnalysisStatus.SUSPICIOUS
        return AnalysisStatus.DANGEROUS
