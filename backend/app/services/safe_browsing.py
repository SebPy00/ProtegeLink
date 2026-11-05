import logging
from typing import Protocol

import httpx

logger = logging.getLogger(__name__)
SAFE_BROWSING_URL = "https://safebrowsing.googleapis.com/v5/urls:search"


class ReputationProvider(Protocol):
    async def is_dangerous(self, url: str) -> bool: ...


class SafeBrowsingService:
    def __init__(
        self,
        api_key: str | None,
        timeout_seconds: float = 5.0,
        transport: httpx.AsyncBaseTransport | None = None,
    ) -> None:
        self._api_key = api_key
        self._timeout_seconds = timeout_seconds
        self._transport = transport

    @property
    def enabled(self) -> bool:
        return bool(self._api_key)

    async def is_dangerous(self, url: str) -> bool:
        if not self.enabled:
            logger.info("Google Safe Browsing está deshabilitado: no hay API key.")
            return False

        try:
            async with httpx.AsyncClient(
                timeout=self._timeout_seconds,
                transport=self._transport,
            ) as client:
                response = await client.get(
                    SAFE_BROWSING_URL,
                    params={"urls": url},
                    headers={"X-Goog-Api-Key": self._api_key or ""},
                )
                response.raise_for_status()
                payload = response.json()
                if not isinstance(payload, dict):
                    raise ValueError("Respuesta inesperada de Safe Browsing")
        except (httpx.HTTPError, TypeError, ValueError):
            logger.warning("Safe Browsing no respondió; continúa el análisis local.", exc_info=True)
            return False

        return bool(payload.get("threats", []))
