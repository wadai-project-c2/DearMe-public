#!/usr/bin/env python3
"""Test DearMe health and optionally one paid image edit without exposing tokens."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
from urllib import error, parse, request
import uuid

from set_function_url import validate_backend_url


class NoRedirect(request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        # Never forward the custom token to another origin after a redirect.
        return None


def call(url: str, *, data: bytes | None = None, headers: dict[str, str] | None = None):
    http_request = request.Request(url, data=data, headers=headers or {})
    try:
        return request.build_opener(NoRedirect).open(http_request, timeout=190)
    except error.HTTPError as http_error:
        raise SystemExit(f"HTTP {http_error.code}: request failed (body omitted).") from None
    except error.URLError:
        raise SystemExit("Backend connection failed (details omitted).") from None


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dart-define-file", type=Path, required=True)
    parser.add_argument("--image", type=Path)
    parser.add_argument("--output", type=Path)
    parser.add_argument("--confirm-paid-request", action="store_true")
    args = parser.parse_args()

    config = json.loads(args.dart_define_file.read_text(encoding="utf-8"))
    base_url = str(config.get("DEARME_BACKEND_URL", "")).rstrip("/")
    api_token = str(config.get("DEARME_API_TOKEN", ""))
    if not base_url.startswith("https://") or not api_token:
        raise SystemExit("HTTPS URL or API token is missing from dart-define file.")
    base_url = validate_backend_url(base_url)
    if args.image is not None and not args.confirm_paid_request:
        raise SystemExit("Image processing is paid; add --confirm-paid-request after approval.")

    with call(f"{base_url}/health") as response:
        if response.status != 200:
            raise SystemExit("Unexpected health status.")
        print(f"/health: HTTP {response.status}")

    if args.image is None:
        return
    if args.output is None:
        raise SystemExit("--output is required when --image is used.")
    image_bytes = args.image.read_bytes()
    if not image_bytes or len(image_bytes) > 4 * 1024 * 1024:
        raise SystemExit("Test image must be 4 MiB or smaller.")
    content_type = {
        ".jpg": "image/jpeg",
        ".jpeg": "image/jpeg",
        ".png": "image/png",
        ".webp": "image/webp",
    }.get(args.image.suffix.lower())
    if content_type is None:
        raise SystemExit("Test image must be JPG, PNG, or WEBP.")

    query = parse.urlencode(
        {
            "item_id": str(uuid.uuid4()),
            "title": "Lambda画像加工テスト",
            "output_type": "sticker_png",
        }
    )
    with call(
        f"{base_url}/images/process?{query}",
        data=image_bytes,
        headers={
            "X-DearMe-Token": api_token,
            "x-amz-content-sha256": hashlib.sha256(image_bytes).hexdigest(),
            "Content-Type": content_type,
            "X-File-Name": parse.quote(args.image.name),
        },
    ) as response:
        processed_bytes = response.read()
        if (
            response.status != 200
            or response.headers.get_content_type() != "image/png"
            or not processed_bytes.startswith(b"\x89PNG\r\n\x1a\n")
        ):
            raise SystemExit("Image processing did not return a PNG.")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_bytes(processed_bytes)
    print(f"/images/process: HTTP 200 ({len(processed_bytes)} bytes)")
    print(f"Output: {args.output}")


if __name__ == "__main__":
    main()
