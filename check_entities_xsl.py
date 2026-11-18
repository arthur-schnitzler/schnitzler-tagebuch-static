#!/usr/bin/env python3
"""Sync entity-related assets from schnitzler-chronik-static.

Pulls the XSL partials as well as the companion CSS/JS files described in the
upstream README ``xslt/export/README-entities-layout.md`` and writes each file
to its project-specific destination. Existing files are only touched when the
upstream content changed."""

import hashlib
import sys
from pathlib import Path
from urllib.request import urlopen
from xml.etree import ElementTree as ET

REMOTE_BASE = (
    "https://raw.githubusercontent.com/arthur-schnitzler/"
    "schnitzler-chronik-static/refs/heads/main/xslt/export/"
)
REPO_ROOT = Path(__file__).parent

# (remote filename, local destination directory)
ASSETS = (
    ("entities.xsl", REPO_ROOT / "xslt" / "partials"),
    ("entities-setup.xsl", REPO_ROOT / "xslt" / "partials"),
    ("relations.json", REPO_ROOT / "xslt" / "partials"),
    ("entities.css", REPO_ROOT / "html" / "css"),
    ("entity-tabs.js", REPO_ROOT / "html" / "js"),
)


def sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def is_well_formed_xml(data: bytes) -> tuple[bool, str]:
    try:
        ET.fromstring(data)
    except ET.ParseError as exc:
        return False, str(exc)
    return True, ""


def sync(filename: str, dest_dir: Path) -> int:
    remote_url = REMOTE_BASE + filename
    local_path = dest_dir / filename

    with urlopen(remote_url) as response:
        remote_bytes = response.read()

    if filename.endswith((".xsl", ".xml")):
        ok, err = is_well_formed_xml(remote_bytes)
        if not ok:
            print(
                f"WARNUNG: Upstream {remote_url} ist kein wohlgeformtes XML "
                f"({err}) – {local_path} bleibt unverändert, Build läuft mit "
                f"lokalem Stand weiter.",
                file=sys.stderr,
            )
            return 0

    if local_path.exists():
        local_bytes = local_path.read_bytes()
        if sha256(local_bytes) == sha256(remote_bytes):
            print(f"{local_path} ist aktuell.")
            return 0
        print(f"{local_path} weicht vom Upstream ab – wird aktualisiert.")
    else:
        print(f"{local_path} fehlt – wird angelegt.")
        local_path.parent.mkdir(parents=True, exist_ok=True)

    local_path.write_bytes(remote_bytes)
    print(f"{local_path} wurde vom Upstream aktualisiert.")
    return 0


# Lokale Korrekturen an Dateien, die bewusst NICHT vom Upstream ueberschrieben
# werden (LOD-idnos.xsl laedt list-of-relevant-uris.xml projektspezifisch).
# Jede Ersetzung ist idempotent: ist der alte Text nicht (mehr) da, passiert nichts.
LOCAL_PATCHES = (
    (
        REPO_ROOT / "xslt" / "partials" / "LOD-idnos.xsl",
        "Modal 'Mehrfache Links': h5 -> h2, eindeutige id (Barrierefreiheit)",
        (
            (
                'aria-labelledby="{$pill/caption}" aria-hidden="true"',
                'aria-labelledby="{$pill/caption}-label" aria-hidden="true"',
            ),
            (
                '<h5 class="modal-title" id="exampleModalLabel">Mehrfache Links</h5>',
                '<h2 class="modal-title h5" id="{$pill/caption}-label">Mehrfache Links</h2>',
            ),
        ),
    ),
)


def apply_local_patches() -> int:
    for path, label, replacements in LOCAL_PATCHES:
        if not path.exists():
            continue
        text = path.read_text(encoding="utf-8")
        patched = text
        for old, new in replacements:
            patched = patched.replace(old, new)
        if patched == text:
            print(f"{path}: {label} – bereits angewendet.")
            continue
        ok, err = is_well_formed_xml(patched.encode("utf-8"))
        if not ok:
            print(
                f"WARNUNG: {path} nach Korrektur nicht wohlgeformt ({err}) – "
                f"bleibt unveraendert.",
                file=sys.stderr,
            )
            continue
        path.write_text(patched, encoding="utf-8")
        print(f"{path}: {label} – angewendet.")
    return 0


def main() -> int:
    exit_code = 0
    for filename, dest_dir in ASSETS:
        exit_code |= sync(filename, dest_dir)
    exit_code |= apply_local_patches()
    return exit_code


if __name__ == "__main__":
    sys.exit(main())
