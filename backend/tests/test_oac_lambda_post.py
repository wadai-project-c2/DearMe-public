"""Exercise Mangum's real Function URL binary transport without AWS/OpenAI."""
import base64
import hashlib
from unittest.mock import patch

import pytest

from core.config import settings
from lambda_handler import handler


@pytest.mark.parametrize("token,status", [("test-token", 200), (None, 401), ("wrong", 401)])
def test_sigv4_and_app_token_with_function_url_binary_body(token, status):
    image = b"\x89PNG\r\n\x1a\n\x00\xfforiginal"
    processed = b"\x89PNG\r\n\x1a\n\x00\xffprocessed"
    headers = {
        "host": "example.lambda-url.ap-northeast-1.on.aws",
        "content-type": "image/png",
        "authorization": "AWS4-HMAC-SHA256 fake-for-offline-test",
        "x-amz-content-sha256": hashlib.sha256(image).hexdigest(),
        "x-file-name": "penguin.png",
    }
    if token is not None:
        headers["x-dearme-token"] = token
    event = {
        "version": "2.0", "routeKey": "$default", "rawPath": "/images/process",
        "rawQueryString": "item_id=id-1&title=penguin&output_type=sticker_png",
        "headers": headers,
        "body": base64.b64encode(image).decode(), "isBase64Encoded": True,
        "requestContext": {
            "http": {"method": "POST", "path": "/images/process",
                     "sourceIp": "127.0.0.1", "protocol": "HTTP/1.1"},
        },
    }
    with patch.object(settings, "app_env", "production"), patch.object(
        settings, "dearme_api_token", "test-token"
    ), patch("routers.images.reserve_daily_attempt") as reserve, patch("routers.images.process_image_with_openai", return_value=processed) as process:
        response = handler(event, None)
    assert response["statusCode"] == status
    if status == 200:
        reserve.assert_called_once()
        assert response["isBase64Encoded"]
        assert base64.b64decode(response["body"]) == processed
        assert response["headers"]["cache-control"] == "no-store"
        assert process.call_args.args[1] == image
        assert process.call_args.args[2] == "image/png"
        assert process.call_args.args[0].title == "penguin"
    else:
        reserve.assert_not_called()
        process.assert_not_called()
