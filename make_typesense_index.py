import glob
import os
import ciso8601
import time
import json

import typesense

from typesense.api_call import ObjectNotFound
from acdh_tei_pyutils.tei import TeiReader
from tqdm import tqdm

files = glob.glob('./data/editions/*.xml')
TYPESENSE_API_KEY = os.environ.get("TYPESENSE_API_KEY", "xyz")


client = typesense.Client({
  'nodes': [{
    'host': 'localhost', # For Typesense Cloud use xxx.a1.typesense.net
    'port': '8108',      # For Typesense Cloud use 443
    'protocol': 'http'   # For Typesense Cloud use https
  }],
  'api_key': TYPESENSE_API_KEY,
  'connection_timeout_seconds': 2
})

try:
    client.collections['stb'].delete()
except ObjectNotFound:
    pass

current_schema = {
    'name': 'stb',
    'fields': [
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
            'optional': True
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
    ]
}

client.collections.create(current_schema)

records = []
for x in tqdm(files, total=len(files)):
    record = {}
    doc = TeiReader(x)
    body = doc.any_xpath('.//tei:body')[0]
    record['rec_id'] = os.path.split(x)[-1]
    record['title'] = " ".join(" ".join(doc.any_xpath('.//tei:title[@type="main"]//text()')).split())
    date_str = doc.any_xpath('.//tei:title[@type="iso-date"]/text()')[0]
    try:
        ts = ciso8601.parse_datetime(date_str)
    except ValueError:
        ts = ciso8601.parse_datetime('1800-01-01')

    record['date'] = int(time.mktime(ts.timetuple()))
    record['persons'] = [
        " ".join(" ".join(x.xpath('.//text()')).split()) for x in doc.any_xpath('.//tei:person/tei:persName')
    ]
    record['places'] = [
         " ".join(" ".join(x.xpath('.//text()')).split()) for x in doc.any_xpath('.//tei:place[@xml:id]/tei:placeName')
    ]
    record['works'] = [
         " ".join(" ".join(x.xpath('.//text()')).split()) for x in doc.any_xpath('.//tei:listBibl//tei:bibl[@xml:id]/tei:title')
    ]
    record['full_text'] = " ".join(''.join(body.itertext()).split())
    records.append(record)

make_index = client.collections['stb'].documents.import_(records)
# print(make_index)
print('done with indexing')