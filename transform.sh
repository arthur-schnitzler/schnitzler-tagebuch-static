#!/bin/bash

echo "add mentions"
python add_mentions.py

echo "make calendar data"
python make_calendar_data.py

echo "build ft-index"
python make_typesense_index.py

echo "create app"
ant