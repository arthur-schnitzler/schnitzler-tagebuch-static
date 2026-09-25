import glob
import os
import json
from acdh_tei_pyutils.tei import TeiReader
from tqdm import tqdm

files = glob.glob('./briefe-data/*.xml')
calendar_file = './html/calendarData.js'


def is_from_schnitzler(doc):
    return bool(
        doc.any_xpath('//tei:correspAction[@type="sent"]//tei:persName[@ref="#pmb2121"]')
    )


letters = []
for x in tqdm(files, total=len(files)):
    doc = TeiReader(x)
    if not is_from_schnitzler(doc):
        continue

    file_name = os.path.splitext(os.path.split(x)[1])[0]
    title_nodes = doc.any_xpath('//tei:title[@level="a"]/text()')
    date_nodes = doc.any_xpath('//tei:title[@type="iso-date"]/@when-iso')
    if not date_nodes:
        date_nodes = doc.any_xpath('//tei:title[@type="iso-date"]/text()')
    n_nodes = doc.any_xpath('//tei:title[@type="iso-date"]/@n')
    if not title_nodes or not date_nodes:
        continue

    letters.append({
        'name': title_nodes[0],
        'startDate': date_nodes[0],
        'tageszaehler': n_nodes[0] if n_nodes else '01',
        'id': f'https://schnitzler-briefe.acdh.oeaw.ac.at/{file_name}.html',
        'category': 'letter',
        'categoryLabel': 'Brief von Schnitzler',
    })

print(f"loading existing calendar data from {calendar_file}")
with open(calendar_file, 'r', encoding='utf8') as f:
    content = f.read()
existing_data = json.loads(content[content.find('['):content.rfind(']') + 1])
base_data = [e for e in existing_data if e.get('category') != 'letter']

all_events = base_data + letters
print(f"writing {len(all_events)} calendar events ({len(letters)} letters) to {calendar_file}")
with open(calendar_file, 'w', encoding='utf8') as f:
    f.write(f"var calendarData = {json.dumps(all_events, ensure_ascii=False)}")
