import json
from urllib.error import HTTPError
from urllib.request import urlopen


def endpoint_should_report(base_url, path, expected_status, expected_code):
    url = f"{base_url.rstrip('/')}{path}"
    try:
        with urlopen(url, timeout=5) as response:
            code = response.status
            body = json.load(response)
    except HTTPError as error:
        with error:
            code = error.code
            body = json.load(error)
    if code != int(expected_code) or body.get("status") != expected_status:
        raise AssertionError(f"{path} returned HTTP {code} with body {body!r}")
