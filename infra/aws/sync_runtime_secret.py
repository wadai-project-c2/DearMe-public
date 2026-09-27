#!/usr/bin/env python3
"""Safely sync OpenAI and temporary app tokens without printing either value."""

from __future__ import annotations

import argparse
import json
import os
from pathlib import Path
import secrets

import boto3
from botocore.exceptions import ClientError
from dotenv import dotenv_values


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--env-file", type=Path, required=True)
    parser.add_argument("--dart-define-file", type=Path, required=True)
    parser.add_argument("--secret-id", default="dearme/dev/backend")
    parser.add_argument("--region", default="ap-northeast-1")
    return parser.parse_args()


def read_app_config(path: Path) -> dict[str, str]:
    if not path.exists():
        return {}
    value = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(value, dict):
        raise ValueError("dart-define file must contain a JSON object")
    return {str(key): str(item) for key, item in value.items()}


def write_private_json(path: Path, value: dict[str, str]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary_path = path.with_suffix(f"{path.suffix}.tmp")
    temporary_path.write_text(
        json.dumps(value, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    os.chmod(temporary_path, 0o600)
    temporary_path.replace(path)


def main() -> None:
    args = parse_args()
    env_values = dotenv_values(args.env_file)
    openai_key = env_values.get("OPENAI_API_KEY")
    if not isinstance(openai_key, str) or not openai_key:
        raise SystemExit("OPENAI_API_KEY is missing from the selected .env file.")

    app_config = read_app_config(args.dart_define_file)
    api_token = app_config.get("DEARME_API_TOKEN") or secrets.token_urlsafe(32)
    app_config["DEARME_API_TOKEN"] = api_token

    client = boto3.client("secretsmanager", region_name=args.region)
    secret_value = json.dumps(
        {
            "OPENAI_API_KEY": openai_key,
            "DEARME_API_TOKEN": api_token,
        }
    )
    try:
        client.describe_secret(SecretId=args.secret_id)
    except ClientError as error:
        if error.response.get("Error", {}).get("Code") != "ResourceNotFoundException":
            raise
        response = client.create_secret(
            Name=args.secret_id,
            Description="DearMe development backend runtime secrets",
            SecretString=secret_value,
            Tags=[
                {"Key": "Project", "Value": "DearMe"},
                {"Key": "Environment", "Value": "dev"},
                {"Key": "ManagedBy", "Value": "Codex"},
            ],
        )
        secret_arn = response["ARN"]
        operation = "created"
    else:
        response = client.put_secret_value(
            SecretId=args.secret_id,
            SecretString=secret_value,
        )
        secret_arn = response["ARN"]
        operation = "updated"

    write_private_json(args.dart_define_file, app_config)
    print(f"Secret {operation}: {secret_arn}")
    print(f"App config updated: {args.dart_define_file}")
    print("Secret values were not printed.")


if __name__ == "__main__":
    main()
