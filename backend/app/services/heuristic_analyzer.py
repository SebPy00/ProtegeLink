import ipaddress
from dataclasses import dataclass
from urllib.parse import urlsplit

HTTP_WITHOUT_TLS_WEIGHT = 10
IP_HOST_WEIGHT = 25
LONG_URL_WEIGHT = 10
MANY_SUBDOMAINS_WEIGHT = 10
SUSPICIOUS_CHARACTER_WEIGHT = 10
UNICODE_OR_PUNYCODE_WEIGHT = 20
SENSITIVE_KEYWORD_WEIGHT = 5
MAX_SENSITIVE_KEYWORD_SCORE = 25

LONG_URL_LENGTH = 120
MAX_SUBDOMAINS = 3
SENSITIVE_KEYWORDS = ("login", "verify", "account", "security", "password")

INSECURE_HTTP_REASON = "insecure_http"
IP_ADDRESS_HOST_REASON = "ip_address_host"
VERY_LONG_URL_REASON = "very_long_url"
TOO_MANY_SUBDOMAINS_REASON = "too_many_subdomains"
SUSPICIOUS_CHARACTERS_REASON = "suspicious_characters"
UNICODE_OR_PUNYCODE_REASON = "unicode_or_punycode"
SUSPICIOUS_KEYWORDS_REASON = "suspicious_keywords"


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
            reasons.append(INSECURE_HTTP_REASON)

        if self._is_ip(hostname):
            score += IP_HOST_WEIGHT
            reasons.append(IP_ADDRESS_HOST_REASON)

        if len(url) > LONG_URL_LENGTH:
            score += LONG_URL_WEIGHT
            reasons.append(VERY_LONG_URL_REASON)

        if self._subdomain_count(hostname) > MAX_SUBDOMAINS:
            score += MANY_SUBDOMAINS_WEIGHT
            reasons.append(TOO_MANY_SUBDOMAINS_REASON)

        if "@" in parsed.netloc:
            score += SUSPICIOUS_CHARACTER_WEIGHT
            reasons.append(SUSPICIOUS_CHARACTERS_REASON)

        if self._has_unicode_or_punycode(hostname):
            score += UNICODE_OR_PUNYCODE_WEIGHT
            reasons.append(UNICODE_OR_PUNYCODE_REASON)

        lowered_url = url.lower()
        matching_keywords = [word for word in SENSITIVE_KEYWORDS if word in lowered_url]
        if matching_keywords:
            # Cada término distinto aporta una señal pequeña. El límite impide
            # que repetir palabras por sí solo convierta una URL en peligrosa.
            score += min(
                len(matching_keywords) * SENSITIVE_KEYWORD_WEIGHT,
                MAX_SENSITIVE_KEYWORD_SCORE,
            )
            reasons.append(SUSPICIOUS_KEYWORDS_REASON)

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

    @staticmethod
    def _has_unicode_or_punycode(hostname: str) -> bool:
        labels = hostname.lower().split(".")
        return any(label.startswith("xn--") for label in labels) or any(
            ord(character) > 127 for character in hostname
        )
