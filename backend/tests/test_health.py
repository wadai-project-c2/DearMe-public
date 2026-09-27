import unittest

from fastapi.testclient import TestClient

from main import app


class HealthApiTest(unittest.TestCase):
    def setUp(self):
        self.client = TestClient(app)

    def test_health_check_returns_ok(self):
        response = self.client.get("/health")

        self.assertEqual(response.status_code, 200)
        self.assertEqual(
            response.json(),
            {"status": "ok", "message": "DEAR ME backend is running"},
        )


if __name__ == "__main__":
    unittest.main()
