#!/usr/bin/env python3
"""
Lädt relations.csv von PMB herunter und filtert sie auf Relationen,
bei denen mindestens eine Seite (source_id ODER target_id) in den
Projekt-Indizes (listperson.xml, listplace.xml, listorg.xml,
listwork.xml/listbibl.xml, listevent.xml) tatsächlich vorkommt.

Aufruf typischerweise vor dem XSLT-Build:
    python3 xslt/export/fetch_relations.py

Mit abweichenden Pfaden:
    python3 xslt/export/fetch_relations.py \
        --output data/indices/relations.csv \
        --index data/indices/listperson.xml \
        --index data/editions/listevent.xml
"""
from __future__ import annotations

import argparse
import csv
import re
import sys
import urllib.request
from pathlib import Path

DEFAULT_URL = "https://pmb.acdh.oeaw.ac.at/media/relations.csv"
DEFAULT_OUTPUT = Path("data/indices/relations.csv")
DEFAULT_INDEX_FILES = [
    Path("data/indices/listperson.xml"),
    Path("data/indices/listplace.xml"),
    Path("data/indices/listorg.xml"),
    Path("data/indices/listwork.xml"),
    Path("data/indices/listbibl.xml"),
    Path("data/editions/listevent.xml"),
]

# Spalten-Indizes der relations.csv (0-basiert)
COL_SOURCE_ID = 9
COL_TARGET_ID = 15
MIN_COLS = 17

ID_PATTERN = re.compile(r'xml:id="pmb(\d+)"')


def collect_ids(paths: list[Path]) -> set[str]:
    """Sammelt alle pmb-Nummern aus den angegebenen XML-Indexdateien."""
    ids: set[str] = set()
    for path in paths:
        if not path.exists():
            continue
        with path.open(encoding="utf-8") as f:
            for m in ID_PATTERN.finditer(f.read()):
                ids.add(m.group(1))
    return ids


def fetch(url: str, dest: Path) -> Path:
    dest.parent.mkdir(parents=True, exist_ok=True)
    tmp = dest.with_suffix(dest.suffix + ".tmp")
    with urllib.request.urlopen(url) as resp, tmp.open("wb") as out:
        while True:
            chunk = resp.read(65536)
            if not chunk:
                break
            out.write(chunk)
    return tmp


# Spalten, die bei der Eindeutigkeitsprüfung ignoriert werden
# (Primärschlüssel + sämtliche Zeitangaben)
IGNORE_COLS = {0, 4, 5, 6, 7, 11, 12, 17, 18}


def _dedup_key(row: list[str]) -> tuple[str, ...]:
    """Erzeugt einen Schlüssel aus allen Spalten außer PK und Zeitangaben."""
    return tuple(v for i, v in enumerate(row) if i not in IGNORE_COLS)


def filter_csv(src: Path, dest: Path, ids: set[str]) -> tuple[int, int, int]:
    kept = total = 0
    seen: set[tuple[str, ...]] = set()
    dupes = 0
    with src.open(newline="", encoding="utf-8") as f_in, \
            dest.open("w", newline="", encoding="utf-8") as f_out:
        reader = csv.reader(f_in)
        writer = csv.writer(f_out)
        try:
            writer.writerow(next(reader))
        except StopIteration:
            return 0, 0, 0
        for row in reader:
            total += 1
            if len(row) < MIN_COLS:
                continue
            if row[COL_SOURCE_ID] in ids or row[COL_TARGET_ID] in ids:
                key = _dedup_key(row)
                if key in seen:
                    dupes += 1
                    continue
                seen.add(key)
                writer.writerow(row)
                kept += 1
    return kept, total, dupes


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("--url", default=DEFAULT_URL, help=f"Quelle (Default: {DEFAULT_URL})")
    p.add_argument("--output", type=Path, default=DEFAULT_OUTPUT,
                   help=f"Zielpfad (Default: {DEFAULT_OUTPUT})")
    p.add_argument("--index", type=Path, action="append", default=[],
                   help="Zusätzliche Indexdatei (mehrfach möglich). "
                        "Ohne diese Option werden die Standard-Pfade verwendet.")
    p.add_argument("--only-index", type=Path, action="append", default=[],
                   help="Ersetzt die Standard-Indexpfade komplett.")
    args = p.parse_args()

    index_paths = args.only_index if args.only_index else DEFAULT_INDEX_FILES + args.index
    ids = collect_ids(index_paths)
    if not ids:
        print(
            "FEHLER: keine pmb-IDs in den Indexdateien gefunden.\n"
            f"Gesucht in: {[str(p) for p in index_paths]}",
            file=sys.stderr,
        )
        return 1
    print(f"{len(ids)} Projekt-IDs gesammelt (aus {sum(1 for p in index_paths if p.exists())} Dateien).")

    print(f"Lade {args.url} ...")
    tmp = fetch(args.url, args.output)
    try:
        kept, total, dupes = filter_csv(tmp, args.output, ids)
    finally:
        tmp.unlink(missing_ok=True)

    print(f"{kept} von {total} Relationen behalten ({dupes} Duplikate entfernt) → {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
