#!/usr/bin/env python3
"""Check whether xslt/partials/entities.xsl matches the upstream version in
schnitzler-chronik-static and update it if it does not."""

import hashlib
import sys
from pathlib import Path
from urllib.request import urlopen

REMOTE_URL = (
    "https://raw.githubusercontent.com/arthur-schnitzler/"
    "schnitzler-chronik-static/refs/heads/main/xslt/export/entities.xsl"
)
LOCAL_PATH = Path(__file__).parent / "xslt" / "partials" / "entities.xsl"


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def main() -> int:
    with urlopen(REMOTE_URL) as response:
        remote_bytes = response.read()

    if LOCAL_PATH.exists():
        local_bytes = LOCAL_PATH.read_bytes()
        if sha256(local_bytes) == sha256(remote_bytes):
            print(f"{LOCAL_PATH} ist aktuell.")
            return 0
        print(f"{LOCAL_PATH} weicht vom Upstream ab – wird aktualisiert.")
    else:
        print(f"{LOCAL_PATH} fehlt – wird angelegt.")
        LOCAL_PATH.parent.mkdir(parents=True, exist_ok=True)

    LOCAL_PATH.write_bytes(remote_bytes)
    print(f"{LOCAL_PATH} wurde vom Upstream aktualisiert.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
