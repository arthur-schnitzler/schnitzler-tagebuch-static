#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "add mentions"
python add_mentions.py

echo "make calendar data"
python make_calendar_data.py

echo "add letters to calendar"
python add_letters_to_calendar.py

echo "make calendar entities data"
python make_calendar_entities_data.py

echo "build ft-index"
python make_typesense_index.py

echo "create app"
ant

echo "generate sitemap"
python3 generate_sitemap.py