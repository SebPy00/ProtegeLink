from fastapi.testclient import TestClient

from app.api.routes.url_analysis import get_analyzer
from app.main import app
from app.models.url_analysis import AnalysisStatus
from app.services.heuristic_analyzer import HeuristicAnalyzer
from app.services.safe_browsing import SafeBrowsingService
from app.services.url_analyzer import UrlAnalyzerService


class FakeReputationProvider:
    def __init__(self, dangerous: bool = False) -> None:
        self.dangerous = dangerous
        self.calls: list[str] = []

    async def is_dangerous(self, url: str) -> bool:
        self.calls.append(url)
        return self.dangerous


def test_normal_https_url_is_safe() -> None:
    response = TestClient(app).post("/api/v1/urls/analyze", json={"url": "https://example.com"})

    assert response.status_code == 200
    assert response.json() == {
        "url": "https://example.com",
        "domain": "example.com",
        "status": "SAFE",
        "risk_score": 0,
        "reasons": [],
    }


def test_http_adds_risk_without_declaring_phishing() -> None:
    result = HeuristicAnalyzer().analyze("http://example.com")

    assert result.score == 10
    assert any("HTTP" in reason for reason in result.reasons)


def test_ip_hostname_adds_risk() -> None:
    result = HeuristicAnalyzer().analyze("https://192.0.2.10")

    assert result.score == 25
    assert any("dirección IP" in reason for reason in result.reasons)


def test_combined_suspicious_signals() -> None:
    result = HeuristicAnalyzer().analyze("http://192.0.2.10/login")

    assert result.score == 40


def test_score_threshold_classification() -> None:
    assert UrlAnalyzerService.classify(0) is AnalysisStatus.SAFE
    assert UrlAnalyzerService.classify(29) is AnalysisStatus.SAFE
    assert UrlAnalyzerService.classify(30) is AnalysisStatus.SUSPICIOUS
    assert UrlAnalyzerService.classify(69) is AnalysisStatus.SUSPICIOUS
    assert UrlAnalyzerService.classify(70) is AnalysisStatus.DANGEROUS


async def test_safe_browsing_positive_overrides_score() -> None:
    provider = FakeReputationProvider(dangerous=True)
    service = UrlAnalyzerService(HeuristicAnalyzer(), provider)

    response = await service.analyze("https://example.com")

    assert response.status is AnalysisStatus.DANGEROUS
    assert response.risk_score == 100
    assert provider.calls == ["https://example.com"]


async def test_missing_api_key_disables_safe_browsing_without_error() -> None:
    service = SafeBrowsingService(api_key=None)

    assert service.enabled is False
    assert await service.is_dangerous("https://example.com") is False


def test_api_can_use_mocked_safe_browsing() -> None:
    app.dependency_overrides[get_analyzer] = lambda: UrlAnalyzerService(
        HeuristicAnalyzer(), FakeReputationProvider(dangerous=True)
    )
    try:
        response = TestClient(app).post("/api/v1/urls/analyze", json={"url": "https://example.com"})
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert response.json()["status"] == "DANGEROUS"
