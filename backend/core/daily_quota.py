"""Reserve a global daily processing attempt before calling the provider."""

from datetime import datetime, timedelta, timezone

import boto3
from botocore.config import Config
from botocore.exceptions import ClientError
from fastapi import HTTPException

from core.config import settings

DAILY_LIMIT = 50
JST = timezone(timedelta(hours=9))


def reserve_daily_attempt(*, now=None, client=None):
    table = settings.dearme_daily_quota_table
    if not table:
        if settings.app_env.lower() == "local":
            return
        raise HTTPException(503, "画像加工の利用制限を確認できません。時間をおいてお試しください。")

    current = (now or datetime.now(JST)).astimezone(JST)
    midnight = current.replace(hour=0, minute=0, second=0, microsecond=0)
    reset = midnight + timedelta(days=1)
    try:
        # Do not automatically retry an ambiguous write: it may have committed.
        db = client or boto3.client(
            "dynamodb", config=Config(
                connect_timeout=3, read_timeout=5,
                retries={"total_max_attempts": 1},
            )
        )
        db.update_item(
            TableName=table,
            Key={"quota_key": {"S": f"GLOBAL#{current.date().isoformat()}"}},
            UpdateExpression="SET #used = if_not_exists(#used, :zero) + :one, expires_at = :expiry",
            ConditionExpression="attribute_not_exists(#used) OR #used < :limit",
            ExpressionAttributeNames={"#used": "used"},
            ExpressionAttributeValues={
                ":zero": {"N": "0"}, ":one": {"N": "1"},
                ":limit": {"N": str(DAILY_LIMIT)},
                ":expiry": {"N": str(int((reset + timedelta(days=7)).timestamp()))},
            },
        )
    except ClientError as error:
        if error.response.get("Error", {}).get("Code") == "ConditionalCheckFailedException":
            raise HTTPException(
                429, {"code": "daily_quota_exceeded"},
                headers={"Retry-After": str(max(1, int((reset - current).total_seconds())))},
            ) from None
        raise HTTPException(503, "画像加工の利用制限を確認できません。時間をおいてお試しください。") from None
    except Exception:
        # Never run paid processing when quota storage cannot be checked.
        raise HTTPException(503, "画像加工の利用制限を確認できません。時間をおいてお試しください。") from None
