import base64
import unittest
from unittest.mock import MagicMock, patch

import httpx
from openai import APIStatusError

from schemas.image_schema import ImageProcessRequest
from services import openai_image_service


class ProcessImageWithOpenaiTest(unittest.TestCase):
    def setUp(self):
        self.request = ImageProcessRequest(item_id="item-1", title="白いTシャツ")

    def test_raises_when_api_key_is_not_configured(self):
        with patch.object(openai_image_service.settings, "openai_api_key", ""):
            with self.assertRaisesRegex(
                ValueError, "OPENAI_API_KEY is not configured"
            ):
                openai_image_service.process_image_with_openai(
                    self.request, b"image-bytes", "image/png"
                )

    def test_raises_when_image_is_empty(self):
        with patch.object(
            openai_image_service.settings, "openai_api_key", "sk-test-key"
        ):
            with self.assertRaisesRegex(ValueError, "image is empty"):
                openai_image_service.process_image_with_openai(
                    self.request, b"", "image/png"
                )

    def test_raises_when_content_type_is_unsupported(self):
        with patch.object(
            openai_image_service.settings, "openai_api_key", "sk-test-key"
        ):
            with self.assertRaisesRegex(
                ValueError, "unsupported image content type"
            ):
                openai_image_service.process_image_with_openai(
                    self.request, b"image-bytes", "text/plain"
                )

    def test_returns_decoded_bytes_from_openai_response(self):
        expected_bytes = b"processed-png-bytes"
        fake_response = MagicMock()
        fake_response.data = [
            MagicMock(b64_json=base64.b64encode(expected_bytes).decode())
        ]
        fake_client = MagicMock()
        fake_client.images.edit.return_value = fake_response

        with patch.object(
            openai_image_service.settings, "openai_api_key", "sk-test-key"
        ), patch.object(
            openai_image_service, "OpenAI", return_value=fake_client
        ) as mock_openai_cls:
            result = openai_image_service.process_image_with_openai(
                self.request, b"image-bytes", "image/png"
            )

        mock_openai_cls.assert_called_once_with(api_key="sk-test-key", max_retries=0)
        fake_client.images.edit.assert_called_once()
        self.assertEqual(result, expected_bytes)

    def test_raises_when_openai_returns_no_image_data(self):
        fake_response = MagicMock()
        fake_response.data = [MagicMock(b64_json=None)]
        fake_client = MagicMock()
        fake_client.images.edit.return_value = fake_response

        with patch.object(
            openai_image_service.settings, "openai_api_key", "sk-test-key"
        ), patch.object(openai_image_service, "OpenAI", return_value=fake_client):
            with self.assertRaisesRegex(ValueError, "OpenAI returned no image data"):
                openai_image_service.process_image_with_openai(
                    self.request, b"image-bytes", "image/png"
                )

    def test_logs_openai_api_error_and_reraises(self):
        request_obj = httpx.Request("POST", "https://api.openai.com/v1/images/edits")
        response_obj = httpx.Response(
            status_code=400,
            request=request_obj,
            json={"error": {"message": "invalid prompt"}},
        )
        api_error = APIStatusError(
            "invalid prompt",
            response=response_obj,
            body={"error": {"message": "invalid prompt"}},
        )
        fake_client = MagicMock()
        fake_client.images.edit.side_effect = api_error

        with patch.object(
            openai_image_service.settings, "openai_api_key", "sk-test-key"
        ), patch.object(
            openai_image_service, "OpenAI", return_value=fake_client
        ), self.assertLogs(
            openai_image_service.logger, level="ERROR"
        ) as logs:
            with self.assertRaises(APIStatusError):
                openai_image_service.process_image_with_openai(
                    self.request, b"image-bytes", "image/png"
                )

        self.assertNotIn("invalid prompt", " ".join(logs.output))
        self.assertIn("400", logs.output[0])


if __name__ == "__main__":
    unittest.main()
