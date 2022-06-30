# bin/bash
rm master.zip
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

echo "add mentions to register-files"
python add_mentions.py

echo "build search index with typesense"
python make_typesense_index.py