# bin/bash
rm master.zip
rm -rf data
wget https://github.com/acdh-oeaw/schnitzler-tagebuch-data/archive/refs/heads/master.zip
unzip master
mv schnitzler-tagebuch-data-master ./data
./dl_imprint.sh
rm master.zip
echo "create calendar data"
python make_calendar_data.py

echo "denormalize indices"
schnitzler

echo "add mentions to register-files"
python add_mentions.py