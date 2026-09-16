from pydantic import AnyHttpUrl, BaseModel, Field, TypeAdapter, field_validator

from app.models.url_analysis import AnalysisStatus


class UrlAnalysisRequest(BaseModel):
    url: str

    @field_validator("url")
    @classmethod
    def validate_http_url(cls, value: str) -> str:
        normalized = value.strip()
        TypeAdapter(AnyHttpUrl).validate_python(normalized)
        return normalized


class UrlAnalysisResponse(BaseModel):
    url: str
    domain: str
    status: AnalysisStatus
    risk_score: int = Field(ge=0, le=100)
    reasons: list[str]
