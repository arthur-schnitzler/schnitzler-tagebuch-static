import glob
import os
import lxml.etree as ET
from acdh_tei_pyutils.tei import TeiReader
from collections import defaultdict
from tqdm import tqdm


files = glob.glob('./data/editions/*.xml')
indices = glob.glob('./data/indices/listp*.xml')

d = defaultdict(set)
for x in tqdm(sorted(files), total=len(files)):
    doc = TeiReader(x)
    for entity in doc.any_xpath('.//tei:back//*[@xml:id]/@xml:id'):
        d[entity].add(os.path.split(x)[1])

for x in indices:
    doc = TeiReader(x)
    for node in doc.any_xpath('.//tei:body//*[@xml:id]'):
        node_id = node.attrib['{http://www.w3.org/XML/1998/namespace}id']
        for mention in d[node_id]:
            ptr = ET.Element('{http://www.tei-c.org/ns/1.0}ptr')
            ptr.attrib['target'] = mention
            node.append(ptr)
    doc.tree_to_file(file=x)

print("DONE")