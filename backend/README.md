# バックエンド参考実装

公開デモの利用者はバックエンドの起動・AWSの契約・OpenAIキーの設定は不要です。ルートREADMEの起動手順を使用してください。

自分の環境で開発する場合はPython 3.12とuvを使用し、このディレクトリで`uv sync`、`uv run pytest`、`uv run uvicorn main:app --reload`を実行します。`.env.example`を参考にGit管理外の`.env`を作成し、自分のOpenAIキーを設定します。実加工には料金が発生します。キーはコミットしないでください。

非local環境ではアプリトークンと`DEARME_DAILY_QUOTA_TABLE`が必須です。日次テーブルのパーティションキーは`quota_key`（文字列）、TTL属性は`expires_at`、実行ロールには対象テーブルの`dynamodb:UpdateItem`が必要です。アプリトークンはAWS用のAuthorization署名と分離し、`X-DearMe-Token`で送ります。

infra内のAWSアカウントID等はダミーであり、そのまま共有デモへデプロイすることはできません。
