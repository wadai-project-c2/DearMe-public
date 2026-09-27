import unittest
from unittest.mock import patch

from fastapi.testclient import TestClient

from main import app


class ImageProcessingApiTest(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)

    def test_direct_image_body_returns_png_and_title_only_metadata(self):
        captured = {}

        def fake_process(metadata, image_bytes, content_type):
            captured["metadata"] = metadata.model_dump()
            captured["bytes"] = image_bytes
            captured["content_type"] = content_type
            return b"processed-png"

        with patch(
            "routers.images.process_image_with_openai",
            side_effect=fake_process,
        ):
            response = self.client.post(
                "/images/process",
                params={
                    "item_id": "item-1",
                    "title": "  白いTシャツ  ",
                    "output_type": "sticker_png",
                    "memo": "OpenAIへ送ってはいけないメモ",
                },
                content=b"original-image",
                headers={"Content-Type": "image/png"},
            )

        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.headers["content-type"], "image/png")
        self.assertEqual(response.content, b"processed-png")
        self.assertEqual(
            captured["metadata"],
            {
                "item_id": "item-1",
                "title": "白いTシャツ",
                "output_type": "sticker_png",
            },
        )
        self.assertEqual(captured["bytes"], b"original-image")
        self.assertEqual(captured["content_type"], "image/png")

    def test_title_and_image_validation_are_preserved(self):
        blank_title = self.client.post(
            "/images/process",
            params={"item_id": "item-1", "title": "   "},
            content=b"image",
            headers={"Content-Type": "image/png"},
        )
        empty_image = self.client.post(
            "/images/process",
            params={"item_id": "item-1", "title": "時計"},
            content=b"",
            headers={"Content-Type": "image/png"},
        )
        unsupported = self.client.post(
            "/images/process",
            params={"item_id": "item-1", "title": "時計"},
            content=b"image",
            headers={"Content-Type": "text/plain"},
        )

        self.assertEqual(blank_title.status_code, 422)
        self.assertEqual(empty_image.status_code, 400)
        self.assertEqual(unsupported.status_code, 415)

    def test_lambda_payload_limit_is_enforced_for_input_and_output(self):
        oversized_input = self.client.post(
            "/images/process",
            params={"item_id": "item-1", "title": "時計"},
            content=b"x" * (4 * 1024 * 1024 + 1),
            headers={"Content-Type": "image/png"},
        )
        with patch(
            "routers.images.process_image_with_openai",
            return_value=b"x" * (4 * 1024 * 1024 + 1),
        ):
            oversized_output = self.client.post(
                "/images/process",
                params={"item_id": "item-1", "title": "時計"},
                content=b"image",
                headers={"Content-Type": "image/png"},
            )

        self.assertEqual(oversized_input.status_code, 413)
        self.assertEqual(oversized_output.status_code, 502)

    def test_openai_failure_is_generic_and_legacy_s3_routes_are_inactive(self):
        from routers import images as images_router

        with patch(
            "routers.images.process_image_with_openai",
            side_effect=RuntimeError("internal provider detail"),
        ), self.assertLogs(images_router.logger, level="ERROR") as logs:
            response = self.client.post(
                "/images/process",
                params={"item_id": "item-1", "title": "時計"},
                content=b"image",
                headers={"Content-Type": "image/jpeg"},
            )

        self.assertEqual(response.status_code, 502)
        self.assertEqual(response.json(), {"detail": "画像加工に失敗しました。"})
        self.assertIn("RuntimeError", logs.output[0])
        self.assertNotIn("internal provider detail", " ".join(logs.output))
        self.assertEqual(
            self.client.post("/images/presigned-upload-url").status_code,
            404,
        )
        self.assertEqual(
            self.client.post("/images/presigned-download-url").status_code,
            404,
        )


if __name__ == "__main__":
    unittest.main()
