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

# get schnitzler-chronik-data

# Download XML files from GitHub repository
wget https://github.com/arthur-schnitzler/schnitzler-chronik-data/archive/refs/heads/main.zip
rm -rf chronik-data
unzip main.zip

mv schnitzler-chronik-data-main/editions/data chronik-data/
rm -rf schnitzler-chronik-data-main

rm main.zip