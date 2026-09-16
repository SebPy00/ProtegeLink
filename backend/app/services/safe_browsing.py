import logging
from typing import Protocol

import httpx

logger = logging.getLogger(__name__)
SAFE_BROWSING_URL = "https://safebrowsing.googleapis.com/v5/urls:search"


class ReputationProvider(Protocol):
    async def is_dangerous(self, url: str) -> bool: ...


class SafeBrowsingService:
    def __init__(self, api_key: str | None, timeout_seconds: float = 5.0) -> None:
        self._api_key = api_key
        self._timeout_seconds = timeout_seconds

    @property
    def enabled(self) -> bool:
        return bool(self._api_key)

    async def is_dangerous(self, url: str) -> bool:
        if not self.enabled:
            logger.info("Google Safe Browsing está deshabilitado: no hay API key.")
            return False

        try:
            async with httpx.AsyncClient(timeout=self._timeout_seconds) as client:
                response = await client.get(
                    SAFE_BROWSING_URL,
                    params={"urls": url},
                    headers={"X-Goog-Api-Key": self._api_key or ""},
                )
                response.raise_for_status()
        except httpx.HTTPError:
            logger.warning("Safe Browsing no respondió; continúa el análisis local.", exc_info=True)
            return False

        return bool(response.json().get("threats", []))
