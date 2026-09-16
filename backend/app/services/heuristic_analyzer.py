import ipaddress
from dataclasses import dataclass
from urllib.parse import urlsplit

HTTP_WITHOUT_TLS_WEIGHT = 10
IP_HOST_WEIGHT = 25
LONG_URL_WEIGHT = 10
MANY_SUBDOMAINS_WEIGHT = 10
SUSPICIOUS_CHARACTER_WEIGHT = 10
SENSITIVE_KEYWORD_WEIGHT = 5

LONG_URL_LENGTH = 120
MAX_SUBDOMAINS = 3
SENSITIVE_KEYWORDS = ("login", "verify", "account", "security", "password")


@dataclass(frozen=True)
class HeuristicResult:
    score: int
    reasons: list[str]


class HeuristicAnalyzer:
    def analyze(self, url: str) -> HeuristicResult:
        parsed = urlsplit(url)
        hostname = parsed.hostname or ""
        score = 0
        reasons: list[str] = []

        if parsed.scheme.lower() == "http":
            score += HTTP_WITHOUT_TLS_WEIGHT
            reasons.append("El enlace usa HTTP sin una conexión cifrada.")

        if self._is_ip(hostname):
            score += IP_HOST_WEIGHT
            reasons.append("El enlace usa una dirección IP en lugar de un dominio reconocible.")

        if len(url) > LONG_URL_LENGTH:
            score += LONG_URL_WEIGHT
            reasons.append("La dirección es inusualmente larga.")

        if self._subdomain_count(hostname) > MAX_SUBDOMAINS:
            score += MANY_SUBDOMAINS_WEIGHT
            reasons.append("El dominio contiene una cantidad inusual de subdominios.")

        if "@" in parsed.netloc or hostname.startswith("xn--"):
            score += SUSPICIOUS_CHARACTER_WEIGHT
            reasons.append("La dirección contiene caracteres que merecen una revisión adicional.")

        lowered_url = url.lower()
        matching_keywords = [word for word in SENSITIVE_KEYWORDS if word in lowered_url]
        if matching_keywords:
            score += SENSITIVE_KEYWORD_WEIGHT
            reasons.append(
                "El enlace contiene términos sensibles: " + ", ".join(matching_keywords) + "."
            )

        return HeuristicResult(score=min(score, 100), reasons=reasons)

    @staticmethod
    def _is_ip(hostname: str) -> bool:
        try:
            ipaddress.ip_address(hostname)
        except ValueError:
            return False
        return True

    @staticmethod
    def _subdomain_count(hostname: str) -> int:
        if HeuristicAnalyzer._is_ip(hostname):
            return 0
        labels = [part for part in hostname.rstrip(".").split(".") if part]
        return max(0, len(labels) - 2)
