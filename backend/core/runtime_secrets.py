import json
import os
from typing import Any


_REQUIRED_SECRET_KEYS = ("OPENAI_API_KEY", "DEARME_API_TOKEN")


def load_runtime_secrets(
    *,
    secret_id: str | None = None,
    region_name: str | None = None,
    secrets_client: Any | None = None,
) -> None:
    """Load Lambda-only runtime secrets without logging their values."""

    resolved_secret_id = secret_id or os.environ.get("DEARME_SECRET_ID", "")
    if not resolved_secret_id:
        return

    if secrets_client is None:
        import boto3

        secrets_client = boto3.client(
            "secretsmanager",
            region_name=region_name or os.environ.get("AWS_REGION"),
        )

    response = secrets_client.get_secret_value(SecretId=resolved_secret_id)
    secret_string = response.get("SecretString")
    if not isinstance(secret_string, str) or not secret_string:
        raise RuntimeError("The DearMe runtime secret must contain SecretString JSON.")

    try:
        payload = json.loads(secret_string)
    except json.JSONDecodeError as error:
        raise RuntimeError("The DearMe runtime secret is not valid JSON.") from error
    if not isinstance(payload, dict):
        raise RuntimeError("The DearMe runtime secret must be a JSON object.")

    for key in _REQUIRED_SECRET_KEYS:
        value = payload.get(key)
        if not isinstance(value, str) or not value:
            raise RuntimeError(f"The DearMe runtime secret is missing {key}.")
        os.environ.setdefault(key, value)
