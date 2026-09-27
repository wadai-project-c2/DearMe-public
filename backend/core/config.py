from pathlib import Path

from pydantic_settings import BaseSettings

# backend/ にある .env を、実行時のカレントディレクトリに依存せず読み込む。
BACKEND_DIR = Path(__file__).resolve().parent.parent
ENV_PATH = BACKEND_DIR / ".env"

class Settings(BaseSettings):
    """
    backend全体の設定を管理するクラス。

    OpenAI APIキーやAPIトークンのような設定値は、
    コードに直接書かず、環境変数または.envから読み込む。
    """

    app_env: str = "local"
    openai_api_key: str = ""
    dearme_api_token: str = ""
    dearme_daily_quota_table: str = ""

    class Config:
        env_file = str(ENV_PATH)
        env_file_encoding = "utf-8"


settings = Settings()
