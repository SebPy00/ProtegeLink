from urllib.parse import urlsplit

from app.models.url_analysis import AnalysisStatus
from app.schemas.url_analysis import UrlAnalysisResponse
from app.services.heuristic_analyzer import (
    INSECURE_HTTP_REASON,
    IP_ADDRESS_HOST_REASON,
    SUSPICIOUS_KEYWORDS_REASON,
    TOO_MANY_SUBDOMAINS_REASON,
    HeuristicAnalyzer,
)
from app.services.safe_browsing import ReputationProvider

SAFE_MAX_SCORE = 29
SUSPICIOUS_MAX_SCORE = 69
EXTERNAL_THREAT_SCORE = 100
SAFE_BROWSING_MATCH_REASON = "safe_browsing_match"
DEMO_MODE_REASON = "demo_mode_case"

DEMO_SAFE_URL = "https://safe.demo.protegelink.test"
DEMO_SUSPICIOUS_URL = "http://login.account.verify.demo.protegelink.test"
DEMO_DANGEROUS_URL = "http://192.0.2.1/login/verify/account/security/password"

DEMO_RESULTS: dict[str, tuple[int, list[str]]] = {
    DEMO_SAFE_URL: (0, [DEMO_MODE_REASON]),
    DEMO_SUSPICIOUS_URL: (
        40,
        [
            INSECURE_HTTP_REASON,
            TOO_MANY_SUBDOMAINS_REASON,
            SUSPICIOUS_KEYWORDS_REASON,
            DEMO_MODE_REASON,
        ],
    ),
    DEMO_DANGEROUS_URL: (
        80,
        [
            INSECURE_HTTP_REASON,
            IP_ADDRESS_HOST_REASON,
            SUSPICIOUS_KEYWORDS_REASON,
            DEMO_MODE_REASON,
        ],
    ),
}


class UrlAnalyzerService:
    def __init__(
        self,
        heuristic_analyzer: HeuristicAnalyzer,
        reputation_provider: ReputationProvider,
        *,
        demo_mode: bool = False,
    ) -> None:
        self._heuristics = heuristic_analyzer
        self._reputation = reputation_provider
        self._demo_mode = demo_mode

    async def analyze(self, url: str) -> UrlAnalysisResponse:
        demo_result = DEMO_RESULTS.get(url) if self._demo_mode else None
        if demo_result is not None:
            score, reasons = demo_result
            return self._response(url, score, list(reasons))

        heuristic = self._heuristics.analyze(url)
        score = heuristic.score
        reasons = list(heuristic.reasons)

        if await self._reputation.is_dangerous(url):
            score = EXTERNAL_THREAT_SCORE
            reasons.append(SAFE_BROWSING_MATCH_REASON)

        return self._response(url, score, reasons)

    def _response(self, url: str, score: int, reasons: list[str]) -> UrlAnalysisResponse:
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
