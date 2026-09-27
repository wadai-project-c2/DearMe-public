import importlib
from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient

import main
from core.config import settings


@pytest.mark.parametrize("environment", ["production", "dev", "local"])
def test_docs_only_available_in_local(environment):
    try:
        with patch.object(settings, "app_env", environment):
            client = TestClient(importlib.reload(main).app)
            for path in ("/docs", "/redoc", "/openapi.json"):
                assert client.get(path).status_code == (200 if environment == "local" else 404)
    finally:
        importlib.reload(main)


def test_cors_preflight_accepts_hash_and_app_token_without_cookie_credentials():
    client = TestClient(main.app)
    response = client.options("/images/process", headers={
        "Origin": "https://example.test",
        "Access-Control-Request-Method": "POST",
        "Access-Control-Request-Headers": "x-dearme-token,x-amz-content-sha256,content-type,x-file-name",
    })
    assert response.status_code == 200
    assert "access-control-allow-credentials" not in response.headers
