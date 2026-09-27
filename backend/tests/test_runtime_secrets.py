import json
import os
import unittest
from unittest.mock import MagicMock, patch

from core.runtime_secrets import load_runtime_secrets


class RuntimeSecretsTest(unittest.TestCase):
    def test_noop_when_secret_id_is_not_configured(self):
        client = MagicMock()
        with patch.dict(os.environ, {}, clear=True):
            load_runtime_secrets(secrets_client=client)

        client.get_secret_value.assert_not_called()

    def test_loads_required_values_without_overwriting_explicit_environment(self):
        client = MagicMock()
        client.get_secret_value.return_value = {
            "SecretString": json.dumps(
                {
                    "OPENAI_API_KEY": "secret-openai-key",
                    "DEARME_API_TOKEN": "secret-api-token",
                }
            )
        }
        with patch.dict(
            os.environ,
            {"OPENAI_API_KEY": "explicit-key"},
            clear=True,
        ):
            load_runtime_secrets(
                secret_id="dearme/dev/backend",
                secrets_client=client,
            )
            self.assertEqual(os.environ["OPENAI_API_KEY"], "explicit-key")
            self.assertEqual(os.environ["DEARME_API_TOKEN"], "secret-api-token")

        client.get_secret_value.assert_called_once_with(
            SecretId="dearme/dev/backend"
        )

    def test_rejects_missing_required_value(self):
        client = MagicMock()
        client.get_secret_value.return_value = {
            "SecretString": json.dumps({"OPENAI_API_KEY": "key"})
        }
        with patch.dict(os.environ, {}, clear=True), self.assertRaisesRegex(
            RuntimeError, "DEARME_API_TOKEN"
        ):
            load_runtime_secrets(
                secret_id="dearme/dev/backend",
                secrets_client=client,
            )


if __name__ == "__main__":
    unittest.main()
