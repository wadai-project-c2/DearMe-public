import json
import unittest

from lambda_handler import handler


class LambdaHandlerTest(unittest.TestCase):
    def test_function_url_payload_reaches_fastapi_health_endpoint(self):
        event = {
            "version": "2.0",
            "routeKey": "$default",
            "rawPath": "/health",
            "rawQueryString": "",
            "headers": {
                "accept": "application/json",
                "host": "example.lambda-url.ap-northeast-1.on.aws",
            },
            "requestContext": {
                "accountId": "anonymous",
                "apiId": "example",
                "domainName": "example.lambda-url.ap-northeast-1.on.aws",
                "domainPrefix": "example",
                "http": {
                    "method": "GET",
                    "path": "/health",
                    "protocol": "HTTP/1.1",
                    "sourceIp": "127.0.0.1",
                    "userAgent": "unittest",
                },
                "requestId": "test-request",
                "routeKey": "$default",
                "stage": "$default",
                "time": "04/Aug/2026:00:00:00 +0000",
                "timeEpoch": 1785801600000,
            },
            "isBase64Encoded": False,
        }

        response = handler(event, None)

        self.assertEqual(response["statusCode"], 200)
        self.assertEqual(json.loads(response["body"])["status"], "ok")


if __name__ == "__main__":
    unittest.main()
