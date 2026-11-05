import httpx
from fastapi.testclient import TestClient

from app.api.routes.url_analysis import get_analyzer
from app.main import app
from app.models.url_analysis import AnalysisStatus
from app.services.heuristic_analyzer import (
    INSECURE_HTTP_REASON,
    IP_ADDRESS_HOST_REASON,
    SUSPICIOUS_KEYWORDS_REASON,
    UNICODE_OR_PUNYCODE_REASON,
    VERY_LONG_URL_REASON,
    HeuristicAnalyzer,
)
from app.services.safe_browsing import SafeBrowsingService
from app.services.url_analyzer import (
    DEMO_DANGEROUS_URL,
    DEMO_MODE_REASON,
    DEMO_SAFE_URL,
    DEMO_SUSPICIOUS_URL,
    UrlAnalyzerService,
)


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


def test_invalid_or_unsupported_urls_are_rejected() -> None:
    client = TestClient(app)

    assert client.post("/api/v1/urls/analyze", json={"url": "not a url"}).status_code == 422
    assert client.post("/api/v1/urls/analyze", json={"url": "ftp://example.com"}).status_code == 422


def test_http_adds_risk_without_declaring_phishing() -> None:
    result = HeuristicAnalyzer().analyze("http://example.com")

    assert result.score == 10
    assert result.reasons == [INSECURE_HTTP_REASON]


def test_ip_hostname_adds_risk() -> None:
    result = HeuristicAnalyzer().analyze("https://192.0.2.10")

    assert result.score == 25
    assert result.reasons == [IP_ADDRESS_HOST_REASON]


def test_combined_suspicious_signals() -> None:
    result = HeuristicAnalyzer().analyze("http://192.0.2.10/login")

    assert result.score == 40
    assert SUSPICIOUS_KEYWORDS_REASON in result.reasons


def test_long_url_adds_risk() -> None:
    result = HeuristicAnalyzer().analyze("https://example.com/" + "a" * 130)

    assert result.score == 10
    assert VERY_LONG_URL_REASON in result.reasons


def test_each_distinct_sensitive_keyword_adds_limited_risk() -> None:
    result = HeuristicAnalyzer().analyze(
        "https://example.com/login/verify/account/security/password"
    )

    assert result.score == 25
    assert result.reasons == [SUSPICIOUS_KEYWORDS_REASON]


def test_punycode_label_adds_explainable_risk() -> None:
    result = HeuristicAnalyzer().analyze("https://shop.xn--exampl-ova.com")

    assert result.score == 20
    assert result.reasons == [UNICODE_OR_PUNYCODE_REASON]


def test_controlled_demo_url_can_be_dangerous() -> None:
    url = (
        "http://verify@192.0.2.10/login/account/security/password/"
        "this-is-padding-for-a-controlled-academic-test-"
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    )

    result = HeuristicAnalyzer().analyze(url)

    assert result.score == 80
    assert UrlAnalyzerService.classify(result.score) is AnalysisStatus.DANGEROUS


def test_demo_urls_return_expected_api_classifications() -> None:
    dangerous_url = (
        "http://verify@192.0.2.10/login/account/security/password/"
        "this-is-padding-for-a-controlled-academic-test-"
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    )
    client = TestClient(app)

    suspicious = client.post(
        "/api/v1/urls/analyze",
        json={"url": "http://192.0.2.10/login"},
    )
    dangerous = client.post("/api/v1/urls/analyze", json={"url": dangerous_url})

    assert suspicious.status_code == 200
    assert suspicious.json()["status"] == "SUSPICIOUS"
    assert suspicious.json()["risk_score"] == 40
    assert dangerous.status_code == 200
    assert dangerous.json()["status"] == "DANGEROUS"
    assert dangerous.json()["risk_score"] == 80


def test_score_threshold_classification() -> None:
    assert UrlAnalyzerService.classify(0) is AnalysisStatus.SAFE
    assert UrlAnalyzerService.classify(29) is AnalysisStatus.SAFE
    assert UrlAnalyzerService.classify(30) is AnalysisStatus.SUSPICIOUS
    assert UrlAnalyzerService.classify(69) is AnalysisStatus.SUSPICIOUS
    assert UrlAnalyzerService.classify(70) is AnalysisStatus.DANGEROUS


async def test_demo_mode_is_explicit_and_deterministic() -> None:
    provider = FakeReputationProvider()
    service = UrlAnalyzerService(HeuristicAnalyzer(), provider, demo_mode=True)

    safe = await service.analyze(DEMO_SAFE_URL)
    suspicious = await service.analyze(DEMO_SUSPICIOUS_URL)
    dangerous = await service.analyze(DEMO_DANGEROUS_URL)

    assert (safe.status, safe.risk_score) == (AnalysisStatus.SAFE, 0)
    assert (suspicious.status, suspicious.risk_score) == (AnalysisStatus.SUSPICIOUS, 40)
    assert (dangerous.status, dangerous.risk_score) == (AnalysisStatus.DANGEROUS, 80)
    assert DEMO_MODE_REASON in dangerous.reasons
    assert provider.calls == []


async def test_demo_rule_is_disabled_by_default() -> None:
    service = UrlAnalyzerService(HeuristicAnalyzer(), FakeReputationProvider())

    result = await service.analyze(DEMO_DANGEROUS_URL)

    assert result.status is AnalysisStatus.SUSPICIOUS
    assert DEMO_MODE_REASON not in result.reasons


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


async def test_safe_browsing_failure_falls_back_without_error() -> None:
    transport = httpx.MockTransport(lambda _: httpx.Response(503))
    service = SafeBrowsingService(api_key="test-key", transport=transport)

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
