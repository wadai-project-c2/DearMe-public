from mangum import Mangum

from core.runtime_secrets import load_runtime_secrets


# Settings is initialized while importing main, so load Secrets Manager first.
load_runtime_secrets()

from main import app


# AWS Lambdaが呼び出す入口。
# Function URLから来たリクエストをFastAPIに渡す。
handler = Mangum(app, lifespan="off")
