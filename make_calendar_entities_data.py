import json
import lxml.etree as ET
from acdh_tei_pyutils.tei import TeiReader

NS = {'tei': 'http://www.tei-c.org/ns/1.0'}
out_file = './html/entitiesByDay.js'


def node_text(node):
    return ' '.join(''.join(node.itertext()).split())


def build_lookup(file_path, item_xpath, name_xpath):
    doc = TeiReader(file_path)
    lookup = {}
    for el in doc.any_xpath(item_xpath):
        xml_id = el.attrib.get('{http://www.w3.org/XML/1998/namespace}id')
        if not xml_id:
            continue
        name_nodes = el.xpath(name_xpath, namespaces=NS)
        name = node_text(name_nodes[0]) if name_nodes else xml_id
        lookup[xml_id] = {'name': name, 'url': f'{xml_id}.html'}
    return lookup


print("building entity name/url lookups")
person_lookup = build_lookup(
    './data/indices/listperson.xml', './/tei:person[@xml:id]', './tei:persName[1]'
)
place_lookup = build_lookup(
    './data/indices/listplace.xml', './/tei:place[@xml:id]', './tei:placeName[1]'
)
work_lookup = build_lookup(
    './data/indices/listwork.xml', './/tei:bibl[@xml:id]', './tei:title[@type="main"][1]'
)

print("reading days with an actual diary entry")
diary_days = {
    (d.text or '').strip()
    for d in ET.parse('./data/indices/index_days.xml').getroot().xpath('.//date')
}

entities_by_day = {}


def day_entry(date):
    return entities_by_day.setdefault(date, {'persons': [], 'places': [], 'works': []})


print("collecting persons mentioned per day")
person_day = ET.parse('./data/indices/index_person_day.xml').getroot()
for item in person_day.xpath('.//item'):
    date = item.get('target')
    if date not in diary_days:
        continue
    persons = day_entry(date)['persons']
    for ref in item.xpath('./ref'):
        person_id = (ref.text or '').strip()
        info = person_lookup.get(person_id)
        if info and info not in persons:
            persons.append(info)

print("collecting places mentioned per day")
place_day = ET.parse('./data/indices/index_place_day.xml').getroot()
for item in place_day.xpath('.//item'):
    date = item.get('target')
    if date not in diary_days:
        continue
    places = day_entry(date)['places']
    for place_name in item.xpath('./placeName'):
        place_id = place_name.get('ref')
        info = place_lookup.get(place_id)
        if not info and place_name.text:
            info = {'name': place_name.text.strip(), 'url': f'{place_id}.html'}
        if info and info not in places:
            places.append(info)

print("collecting works mentioned per day")
work_day = ET.parse('./data/indices/index_work_day.xml').getroot()
for item in work_day.xpath('.//item'):
    date = item.get('target')
    if date not in diary_days:
        continue
    works = day_entry(date)['works']
    for ref in item.xpath('./ref'):
        work_id = (ref.text or '').strip()
        info = work_lookup.get(work_id)
        if info and info not in works:
            works.append(info)

print(f"writing entities-by-day data for {len(entities_by_day)} days to {out_file}")
with open(out_file, 'w', encoding='utf8') as f:
    f.write(f"var entitiesByDay = {json.dumps(entities_by_day, ensure_ascii=False)}")
