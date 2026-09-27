import unittest
from unittest.mock import patch

from fastapi.testclient import TestClient

from core.config import settings
from main import app


class ApiAuthenticationTest(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)
        quota = patch("routers.images.reserve_daily_attempt")
        self.reserve = quota.start()
        self.addCleanup(quota.stop)

    def _post_image(self, token: str | None = None):
        headers = {"Content-Type": "image/png"}
        if token is not None:
            headers["X-DearMe-Token"] = token
        return self.client.post(
            "/images/process",
            params={"item_id": "item-1", "title": "時計"},
            content=b"image",
            headers=headers,
        )

    def test_paid_endpoint_requires_configured_app_token(self):
        with patch.object(settings, "app_env", "production"), patch.object(
            settings, "dearme_api_token", "temporary-test-token"
        ), patch(
            "routers.images.process_image_with_openai",
            return_value=b"processed-png",
        ):
            missing = self._post_image()
            wrong = self._post_image("wrong-token")
            self.reserve.assert_not_called()
            accepted = self._post_image("temporary-test-token")

        self.assertEqual(missing.status_code, 401)
        self.assertEqual(wrong.status_code, 401)
        self.assertEqual(accepted.status_code, 200)

    def test_sigv4_does_not_replace_app_authentication(self):
        with patch.object(settings, "app_env", "production"), patch.object(
            settings, "dearme_api_token", "temporary-test-token"
        ), patch("routers.images.process_image_with_openai", return_value=b"png") as process:
            for authorization in ("AWS4-HMAC-SHA256 fake-signature", "Bearer temporary-test-token"):
                missing = self.client.post("/images/process", params={"item_id": "id", "title": "写真"},
                    content=b"image", headers={"Content-Type": "image/png", "Authorization": authorization})
                self.assertEqual(missing.status_code, 401)
            process.assert_not_called()
            accepted = self.client.post("/images/process", params={"item_id": "id", "title": "写真"},
                content=b"image", headers={"Content-Type": "image/png",
                    "Authorization": "AWS4-HMAC-SHA256 fake-signature",
                    "X-DearMe-Token": "temporary-test-token"})
            self.assertEqual(accepted.status_code, 200)

    def test_local_development_without_token_is_preserved(self):
        with patch.object(settings, "app_env", "local"), patch.object(
            settings, "dearme_api_token", ""
        ), patch("routers.images.process_image_with_openai", return_value=b"png"):
            self.assertEqual(self._post_image().status_code, 200)

    def test_duplicate_token_headers_are_rejected(self):
        with patch.object(settings, "app_env", "production"), patch.object(
            settings, "dearme_api_token", "temporary-test-token"
        ):
            response = self.client.post("/images/process", params={"item_id": "id", "title": "写真"},
                content=b"image", headers=[("Content-Type", "image/png"),
                    ("X-DearMe-Token", "temporary-test-token"), ("X-DearMe-Token", "wrong")])
            self.assertEqual(response.status_code, 401)

    def test_production_fails_closed_when_token_is_missing(self):
        with patch.object(settings, "app_env", "production"), patch.object(
            settings, "dearme_api_token", ""
        ):
            response = self._post_image()

        self.assertEqual(response.status_code, 503)

    def test_health_endpoint_remains_public(self):
        with patch.object(settings, "app_env", "production"), patch.object(
            settings, "dearme_api_token", "temporary-test-token"
        ):
            response = self.client.get("/health")

        self.assertEqual(response.status_code, 200)


if __name__ == "__main__":
    unittest.main()
