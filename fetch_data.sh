#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status
rm -f master.zip
rm -rf data
wget https://github.com/arthur-schnitzler/schnitzler-tagebuch-data/archive/refs/heads/master.zip
unzip master
mv schnitzler-tagebuch-data-master ./data
./dl_imprint.sh
rm master.zip
echo "create calendar data"
python make_calendar_data.py

echo "add ids"
add-attributes -g "./data/editions/*.xml" -b "https://id.acdh.oeaw.ac.at/schnitzler/schnitzler-tagebuch/editions"

echo "denormalize indices"
schnitzler

# get schnitzler-chronik-data

# Download XML files from GitHub repository
wget https://github.com/arthur-schnitzler/schnitzler-chronik-data/archive/refs/heads/main.zip
rm -rf chronik-data
unzip main.zip

mv schnitzler-chronik-data-main/editions/data chronik-data/
rm -rf schnitzler-chronik-data-main

rm main.zip

# get schnitzler-chronik-static (for local XSLT import to avoid remote fetching during build)
echo "download schnitzler-chronik-static for local XSLT"
cd ..
rm -rf schnitzler-chronik-static
wget https://github.com/arthur-schnitzler/schnitzler-chronik-static/archive/refs/heads/main.zip -O chronik-static.zip
unzip chronik-static.zip
mv schnitzler-chronik-static-main schnitzler-chronik-static
rm chronik-static.zip
cd schnitzler-tagebuch-static