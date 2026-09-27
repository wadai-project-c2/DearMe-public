"""Offline tests: never use an AWS client or make external HTTP requests."""
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
from email.message import Message
from unittest.mock import patch

import pytest

AWS_DIR = Path(__file__).resolve().parents[2] / "infra" / "aws"
sys.path.insert(0, str(AWS_DIR))
from set_function_url import validate_backend_url

spec = importlib.util.spec_from_file_location("cloudfront_smoke", AWS_DIR / "test_function_url.py")
smoke = importlib.util.module_from_spec(spec)
spec.loader.exec_module(smoke)


@pytest.mark.parametrize("url", [
    "https://example.lambda-url.ap-northeast-1.on.aws/",
    "http://example.cloudfront.net", "https://example.cloudfront.net.attacker.test",
    "https://token@example.cloudfront.net", "https://example.cloudfront.net?token=secret",
    "https://example.cloudfront.net/path", "https://example.cloudfront.net/#secret",
])
def test_aws_url_helper_rejects_direct_and_unsafe_urls(url):
    with pytest.raises(ValueError):
        validate_backend_url(url)


def test_cloudfront_url_validation():
    assert validate_backend_url("https://d3809md2nuofm8.cloudfront.net/") == "https://d3809md2nuofm8.cloudfront.net"


@pytest.mark.parametrize("mode", ["AWS_IAM", "NONE", "denied"])
def test_deploy_is_code_only_and_fails_closed(tmp_path, mode):
    script = tmp_path / "infra/aws/deploy_lambda.sh"
    script.parent.mkdir(parents=True)
    shutil.copyfile(AWS_DIR / "deploy_lambda.sh", script)
    artifact = tmp_path / "build/lambda/dearme-api-dev.zip"
    artifact.parent.mkdir(parents=True)
    artifact.write_bytes(b"fake zip: not sent anywhere")
    calls = tmp_path / "calls.jsonl"
    fake = tmp_path / "fake-aws"
    fake.write_text(f"#!{sys.executable}\n" + '''import json, os, sys
with open(os.environ["TEST_AWS_CALLS"], "a") as stream:
    stream.write(json.dumps(sys.argv[1:]) + "\\n")
operation = sys.argv[2]
if operation == "get-function-url-config":
    if os.environ["TEST_AUTH"] == "denied":
        sys.exit(1)
    print(os.environ["TEST_AUTH"])
elif operation == "get-function-configuration":
    print("revision-123")
elif operation not in ("update-function-code", "wait"):
    sys.exit(99)
''')
    fake.chmod(0o700)
    env = dict(os.environ, DEARME_AWS_CLI=str(fake), TEST_AWS_CALLS=str(calls), TEST_AUTH=mode)
    # No confirmation means no AWS calls, even reads.
    assert subprocess.run(["bash", str(script)], env=env, capture_output=True).returncode != 0
    assert not calls.exists()
    result = subprocess.run(["bash", str(script), "--confirm-code-update"], env=env, capture_output=True)
    operations = [json.loads(line) for line in calls.read_text().splitlines()]
    if mode == "AWS_IAM":
        assert result.returncode == 0
        assert [args[1] for args in operations] == ["get-function-url-config", "get-function-configuration", "update-function-code", "wait"]
        assert "--revision-id" in operations[2]
    else:
        assert result.returncode != 0
        assert len(operations) == 1


def test_deployer_policy_cannot_create_or_publish_resources():
    policy = json.loads((AWS_DIR / "dearme-dev-deployer-policy.json").read_text())
    actions = {action for statement in policy["Statement"] for action in statement["Action"]}
    assert actions == {"lambda:GetFunctionConfiguration", "lambda:GetFunctionUrlConfig",
                       "lambda:GetPolicy", "lambda:UpdateFunctionCode"}


def test_paid_smoke_uses_exact_body_hash_and_custom_token(tmp_path):
    config = tmp_path / "config.json"
    config.write_text(json.dumps({"DEARME_BACKEND_URL": "https://example.cloudfront.net", "DEARME_API_TOKEN": "test-token"}))
    photo = tmp_path / "photo.png"
    photo.write_bytes(b"test-image-bytes")
    output = tmp_path / "result.png"
    seen = []
    class Response:
        status = 200
        headers = Message()
        headers["Content-Type"] = "image/png"
        def __enter__(self): return self
        def __exit__(self, *args): pass
        def read(self): return b"\x89PNG\r\n\x1a\nprocessed"
    def fake_call(url, **kwargs):
        seen.append((url, kwargs))
        return Response()
    argv = ["smoke", "--dart-define-file", str(config), "--image", str(photo), "--output", str(output)]
    with patch.object(sys, "argv", argv), patch.object(smoke, "call", side_effect=fake_call):
        with pytest.raises(SystemExit, match="paid"):
            smoke.main()
    assert seen == []
    with patch.object(sys, "argv", argv + ["--confirm-paid-request"]), patch.object(smoke, "call", side_effect=fake_call):
        smoke.main()
    request = seen[1][1]
    assert request["data"] == photo.read_bytes()
    assert request["headers"]["X-DearMe-Token"] == "test-token"
    assert request["headers"]["x-amz-content-sha256"] == hashlib.sha256(photo.read_bytes()).hexdigest()
    assert "Authorization" not in request["headers"]
    assert output.read_bytes().startswith(b"\x89PNG")


def test_smoke_never_follows_redirects():
    assert smoke.NoRedirect().redirect_request(None, None, 302, "", {}, "https://other.test") is None
