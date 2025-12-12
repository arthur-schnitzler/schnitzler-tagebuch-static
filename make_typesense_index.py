import glob
import os
import ciso8601
import time
import typesense

from typesense.api_call import ObjectNotFound
from acdh_cfts_pyutils import TYPESENSE_CLIENT as client
from acdh_cfts_pyutils import CFTS_COLLECTION
from acdh_tei_pyutils.tei import TeiReader
from tqdm import tqdm

files = glob.glob('./data/editions/*.xml')

try:
    client.collections['stb'].delete()
except ObjectNotFound:
    pass

current_schema = {
    'name': 'stb',
    'fields': [
        {
            'name': 'id',
            'type': 'string',
        },
        {
            'name': 'rec_id',
            'type': 'string'
        },
        {
            'name': 'title',
            'type': 'string'
        },
        {
            'name': 'full_text',
            'type': 'string'
        },
        {
            'name': 'date',
            'type': 'int64',
            'facet': True
        },
        {
            'name': 'year',
            'type': 'int32',
            'optional': True,
            'facet': True
        },
        {
            'name': 'persons',
            'type': 'string[]',
            'facet': True,
            'optional': True
        },
        {
            'name': 'places',
            'type': 'string[]',
            'facet': True,
            'optional': True
        },
        {
            'name': 'works',
            'type': 'string[]',
            'facet': True,
            'optional': True
        }
    ],
    'default_sorting_field': 'date',
}

client.collections.create(current_schema)

records = []
cfts_records = []
for x in tqdm(files, total=len(files)):
    cfts_record = {
        'project': 'sbt',
    }
    record = {}
    doc = TeiReader(x)
    body = doc.any_xpath('.//tei:body')[0]
    record['rec_id'] = os.path.split(x)[-1]
    cfts_record['rec_id'] = record['rec_id']
    record['id'] = os.path.split(x)[-1].replace('.xml', '')
    cfts_record['resolver'] = f"https://schnitzler-tagebuch.acdh.oeaw.ac.at/{record['id']}.html"
    cfts_record['id'] = record['id']
    record['title'] = " ".join(" ".join(doc.any_xpath('.//tei:titleStmt/tei:title[@type="main"]//text()')).split())
    cfts_record['title'] = record['title']
    date_str = doc.any_xpath('.//tei:titleStmt/tei:title[@type="iso-date"]/text()')[0]
    record['year'] = int(date_str[:4])
    cfts_record['id'] = record['id']
    try:
        ts = ciso8601.parse_datetime(date_str)
    except ValueError:
        ts = ciso8601.parse_datetime('1800-01-01')

    record['date'] = int(time.mktime(ts.timetuple()))
    cfts_record['date'] = record['date']
    record['persons'] = [
        " ".join(" ".join(x.xpath('.//text()')).split()) for x in doc.any_xpath('.//tei:person/tei:persName[1]')
    ]
    cfts_record['persons'] = record['persons']
    record['places'] = [
         " ".join(" ".join(x.xpath('.//text()')).split()) for x in doc.any_xpath('.//tei:place[@xml:id]/tei:placeName[1]')
    ]
    cfts_record['places'] = record['places']
    record['works'] = [
         " ".join(" ".join(x.xpath('.//text()')).split()) for x in doc.any_xpath('.//tei:listBibl//tei:bibl[@xml:id]/tei:title[1]')
    ]
    cfts_record['works'] = record['works']
    # Exclude tei:fw elements from full-text indexing
    full_text_nodes = doc.any_xpath('.//tei:body//text()[not(ancestor::tei:fw)]')
    record['full_text'] = " ".join(''.join(full_text_nodes).split())
    cfts_record['full_text'] = record['full_text']
    records.append(record)
    cfts_records.append(cfts_record)

make_index = client.collections['stb'].documents.import_(records)
# print(make_index)
print('done with indexing')

make_index = CFTS_COLLECTION.documents.import_(cfts_records)
print('done with central indexing')