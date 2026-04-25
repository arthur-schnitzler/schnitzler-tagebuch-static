"""Generate redirect HTML pages from old person_*.html IDs to new pmb*.html IDs."""

import json
import os

CONCORDANCE = "./data/indices/person_pmb_concordance.json"
TARGET_DIR = "./html"

REDIRECT_TEMPLATE = """<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="utf-8">
<title>Weiterleitung auf {target}.html</title>
<link rel="canonical" href="{target}.html">
<meta http-equiv="refresh" content="0; url={target}.html">
<meta name="robots" content="noindex">
</head>
<body>
<p>Diese Seite wurde nach <a href="{target}.html">{target}.html</a> verschoben.</p>
</body>
</html>
"""


def main():
    with open(CONCORDANCE, "r", encoding="utf-8") as f:
        mapping = json.load(f)

    os.makedirs(TARGET_DIR, exist_ok=True)
    written = 0
    for old_id, new_id in mapping.items():
        path = os.path.join(TARGET_DIR, f"{old_id}.html")
        with open(path, "w", encoding="utf-8") as f:
            f.write(REDIRECT_TEMPLATE.format(target=new_id))
        written += 1
    print(f"Wrote {written} redirect pages to {TARGET_DIR}")


if __name__ == "__main__":
    main()
