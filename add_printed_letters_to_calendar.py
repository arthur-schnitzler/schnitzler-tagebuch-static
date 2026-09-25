import re
import json
import requests
import xml.etree.ElementTree as ET

# Vorbild: schnitzler-briefe-static/python/fetch_cmif_data.py.
# Anders als dort werden hier nur die von Arthur Schnitzler selbst
# geschriebenen Briefe uebernommen (Kopfzeile "Arthur Schnitzler ... an ...").
CMIF_SOURCES = [
    {
        'url': 'https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-chronik-data/refs/heads/main/import-lists/schnitzler-cmif_tage.xml',
        'category': 'gedruckt',
        'label': 'gedruckte Briefe',
    },
    {
        'url': 'https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-chronik-data/refs/heads/main/import-lists/schnitzler-fischer-cmif_tage.xml',
        'category': 'fischer',
        'label': 'S. Fischer',
    },
]

NS = {'tei': 'http://www.tei-c.org/ns/1.0'}
CATEGORY_LABELS = {'gedruckt': 'Gedruckte Briefe', 'fischer': 'S. Fischer'}
calendar_file = './html/calendarData.js'


def is_from_schnitzler(head_text):
    sender_part = head_text.split(' an ', 1)[0]
    return 'Arthur Schnitzler' in sender_part


def parse_cmif_xml(xml_content, category):
    root = ET.fromstring(xml_content)
    events = []
    for event in root.findall('.//tei:event', NS):
        when_iso = event.get('when-iso')
        head = event.find('tei:head', NS)
        if not when_iso or head is None or not head.text:
            continue

        letter_title = head.text.strip()
        if not is_from_schnitzler(letter_title):
            continue

        bibl = event.find('.//tei:bibl', NS)
        bibliographic_info = bibl.text.strip() if bibl is not None and bibl.text and bibl.text.strip() else None

        idno = event.find('.//tei:idno[@type="schnitzler-fischer"]', NS)
        link_url = idno.text.strip() if idno is not None and idno.text else None

        date_part = when_iso.replace('-', '')
        title_part = re.sub(r'[^a-zA-Z0-9]', '', letter_title)[:20]
        cmif_id = f'CMIF_{category}_{date_part}_{title_part}'

        events.append({
            'name': letter_title,
            'startDate': when_iso,
            'tageszaehler': '00',
            'id': link_url or cmif_id,
            'category': category,
            'categoryLabel': CATEGORY_LABELS[category],
            'bibliographic': bibliographic_info,
        })
    return events


print(f"loading existing calendar data from {calendar_file}")
with open(calendar_file, 'r', encoding='utf8') as f:
    content = f.read()
existing_data = json.loads(content[content.find('['):content.rfind(']') + 1])

cmif_categories = {s['category'] for s in CMIF_SOURCES}
base_data = [e for e in existing_data if e.get('category') not in cmif_categories]

all_new_events = []
for source in CMIF_SOURCES:
    print(f"fetching {source['label']} from {source['url']}")
    response = requests.get(source['url'])
    response.raise_for_status()
    events = parse_cmif_xml(response.text, source['category'])
    print(f"  {len(events)} Briefe von Arthur Schnitzler gefunden")
    all_new_events.extend(events)

all_events = base_data + all_new_events
print(f"writing {len(all_events)} calendar events to {calendar_file}")
with open(calendar_file, 'w', encoding='utf8') as f:
    f.write(f"var calendarData = {json.dumps(all_events, ensure_ascii=False)}")
