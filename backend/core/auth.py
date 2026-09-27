import secrets

from fastapi import HTTPException, Request, status

from core.config import settings


def require_api_token(request: Request) -> None:
    """Keep app authentication separate from CloudFront OAC's SigV4 header."""

    expected_token = settings.dearme_api_token
    if not expected_token:
        if settings.app_env.lower() == "local":
            return
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="API authentication is not configured.",
        )

    supplied_tokens = request.headers.getlist("x-dearme-token")
    if (
        len(supplied_tokens) != 1
        or not secrets.compare_digest(
            supplied_tokens[0].encode("utf-8"), expected_token.encode("utf-8")
        )
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication is required.",
        )
