#!/usr/bin/env python3
"""Write a CloudFront URL to dart-define (legacy script name retained)."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
from urllib.parse import urlsplit


def validate_backend_url(url: str) -> str:
    parsed = urlsplit(url)
    if (
        parsed.scheme != "https"
        or not parsed.hostname
        or not parsed.hostname.endswith(".cloudfront.net")
        or parsed.username is not None
        or parsed.password is not None
        or parsed.port not in (None, 443)
        or parsed.path not in ("", "/")
        or parsed.query
        or parsed.fragment
    ):
        raise ValueError("Use an HTTPS CloudFront distribution base URL, not a Function URL.")
    return url.rstrip("/")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--dart-define-file", type=Path, required=True)
    parser.add_argument("--url", required=True)
    args = parser.parse_args()

    backend_url = validate_backend_url(args.url)
    value = json.loads(args.dart_define_file.read_text(encoding="utf-8"))
    if not isinstance(value, dict) or not value.get("DEARME_API_TOKEN"):
        raise SystemExit("An existing app token is required in the dart-define file.")
    value["DEARME_BACKEND_URL"] = backend_url

    temporary_path = args.dart_define_file.with_suffix(
        f"{args.dart_define_file.suffix}.tmp"
    )
    temporary_path.write_text(
        json.dumps(value, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    os.chmod(temporary_path, 0o600)
    temporary_path.replace(args.dart_define_file)
    print(f"App backend URL updated: {args.dart_define_file}")


if __name__ == "__main__":
    main()
