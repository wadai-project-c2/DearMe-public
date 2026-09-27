import unittest
from unittest.mock import patch

from core.config import ENV_PATH, Settings


class SettingsTest(unittest.TestCase):
    def test_env_file_is_under_backend_directory(self):
        self.assertEqual(ENV_PATH, ENV_PATH.parent / ".env")
        self.assertEqual(ENV_PATH.parent.name, "backend")

    def test_defaults_when_env_is_unset(self):
        with patch.dict("os.environ", {}, clear=True):
            settings = Settings(_env_file=None)

        self.assertEqual(settings.app_env, "local")
        self.assertEqual(settings.openai_api_key, "")
        self.assertEqual(settings.dearme_api_token, "")

    def test_env_vars_override_defaults(self):
        with patch.dict(
            "os.environ",
            {
                "APP_ENV": "production",
                "OPENAI_API_KEY": "sk-test-key",
                "DEARME_API_TOKEN": "test-api-token",
            },
            clear=True,
        ):
            settings = Settings(_env_file=None)

        self.assertEqual(settings.app_env, "production")
        self.assertEqual(settings.openai_api_key, "sk-test-key")
        self.assertEqual(settings.dearme_api_token, "test-api-token")


if __name__ == "__main__":
    unittest.main()
