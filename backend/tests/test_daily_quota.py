from concurrent.futures import ThreadPoolExecutor
from datetime import datetime, timezone
from threading import Lock
from unittest.mock import Mock, patch

import pytest
from botocore.exceptions import ClientError
from fastapi import HTTPException
from fastapi.testclient import TestClient

from core.config import settings
from core.daily_quota import reserve_daily_attempt
from main import app


@pytest.fixture(autouse=True)
def quota_settings(monkeypatch):
    monkeypatch.setattr(settings, "dearme_daily_quota_table", "test-quota")


def test_jst_day_changes_without_ttl_deletion():
    db = Mock()
    for instant in ["2026-09-28T14:59:59+00:00", "2026-09-28T15:00:00+00:00"]:
        reserve_daily_attempt(now=datetime.fromisoformat(instant), client=db)
    calls = db.update_item.call_args_list
    assert calls[0].kwargs["Key"] == {"quota_key": {"S": "GLOBAL#2026-09-28"}}
    assert calls[1].kwargs["Key"] == {"quota_key": {"S": "GLOBAL#2026-09-29"}}
    assert calls[0].kwargs["ExpressionAttributeValues"][":limit"] == {"N": "50"}
    assert calls[0].kwargs["ConditionExpression"] == "attribute_not_exists(#used) OR #used < :limit"


def test_fifty_concurrent_reservations_then_reject():
    # Model DynamoDB's atomic conditional update, not an AWS integration test.
    lock = Lock()
    count = 0

    def update(**kwargs):
        nonlocal count
        with lock:
            if count >= int(kwargs["ExpressionAttributeValues"][":limit"]["N"]):
                raise ClientError({"Error": {"Code": "ConditionalCheckFailedException"}}, "UpdateItem")
            count += 1

    db = Mock()
    db.update_item.side_effect = update

    def attempt(_):
        try:
            reserve_daily_attempt(client=db)
            return 200
        except HTTPException as error:
            return error.status_code

    with ThreadPoolExecutor(max_workers=10) as pool:
        statuses = list(pool.map(attempt, range(70)))
    assert statuses.count(200) == 50
    assert statuses.count(429) == 20


def test_quota_rejection_returns_retry_after():
    db = Mock()
    db.update_item.side_effect = ClientError({"Error": {"Code": "ConditionalCheckFailedException"}}, "UpdateItem")
    with pytest.raises(HTTPException) as result:
        reserve_daily_attempt(now=datetime(2026, 9, 28, 14, 59, 59, tzinfo=timezone.utc), client=db)
    assert result.value.status_code == 429
    assert result.value.headers == {"Retry-After": "1"}


@pytest.mark.parametrize("failure", [RuntimeError("timeout"), ClientError({"Error": {"Code": "AccessDeniedException"}}, "UpdateItem")])
def test_storage_errors_fail_closed(failure):
    db = Mock()
    db.update_item.side_effect = failure
    with pytest.raises(HTTPException) as result:
        reserve_daily_attempt(client=db)
    assert result.value.status_code == 503


def test_missing_table_is_allowed_only_locally(monkeypatch):
    monkeypatch.setattr(settings, "dearme_daily_quota_table", "")
    monkeypatch.setattr(settings, "app_env", "local")
    reserve_daily_attempt()
    monkeypatch.setattr(settings, "app_env", "production")
    with pytest.raises(HTTPException) as result:
        reserve_daily_attempt()
    assert result.value.status_code == 503


def test_router_validates_before_reserving_and_stops_before_openai():
    with patch("routers.images.reserve_daily_attempt", side_effect=HTTPException(429, {"code": "daily_quota_exceeded"})) as reserve, patch("routers.images.process_image_with_openai") as process:
        client = TestClient(app)
        args = {"params": {"item_id": "test", "title": "test"}, "headers": {"Content-Type": "image/png"}}
        assert client.post("/images/process", content=b"", **args).status_code == 400
        reserve.assert_not_called()
        assert client.post("/images/process", content=b"image", **args).status_code == 429
        reserve.assert_called_once()
        process.assert_not_called()


def test_failed_processing_keeps_reservation_and_retry_reserves_again():
    events = []
    def reserve():
        events.append("reserve")
    def process(*args):
        events.append("process")
        raise RuntimeError("provider failed")
    with patch("routers.images.reserve_daily_attempt", side_effect=reserve), patch("routers.images.process_image_with_openai", side_effect=process):
        client = TestClient(app)
        for _ in range(2):
            assert client.post("/images/process", params={"item_id": "test", "title": "test"}, headers={"Content-Type": "image/png"}, content=b"image").status_code == 502
    assert events == ["reserve", "process", "reserve", "process"]
