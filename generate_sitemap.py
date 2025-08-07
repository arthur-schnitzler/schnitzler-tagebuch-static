#!/usr/bin/env python3

import glob
import os
from datetime import datetime
from xml.etree.ElementTree import Element, SubElement, ElementTree

def generate_sitemap():
    """Generate sitemap.xml for the Schnitzler Tagebuch website"""
    
    base_url = "https://schnitzler-tagebuch.acdh.oeaw.ac.at"
    sitemap_file = "./html/sitemap.xml"
    
    # Create root sitemap element
    urlset = Element("urlset", xmlns="http://www.sitemaps.org/schemas/sitemap/0.9")
    
    # Add homepage
    url = SubElement(urlset, "url")
    SubElement(url, "loc").text = base_url + "/"
    SubElement(url, "lastmod").text = datetime.now().strftime('%Y-%m-%d')
    SubElement(url, "changefreq").text = "weekly"
    SubElement(url, "priority").text = "1.0"
    
    # Add static pages
    static_pages = [
        ("about.html", "monthly", "0.8"),
        ("toc.html", "weekly", "0.9"), 
        ("calendar.html", "weekly", "0.8"),
        ("listperson.html", "monthly", "0.7"),
        ("listwork.html", "monthly", "0.7"),
        ("listplace.html", "monthly", "0.7"),
        ("search.html", "monthly", "0.6")
    ]
    
    for page, changefreq, priority in static_pages:
        html_file = f"./html/{page}"
        if os.path.exists(html_file):
            url = SubElement(urlset, "url")
            SubElement(url, "loc").text = f"{base_url}/{page}"
            SubElement(url, "lastmod").text = datetime.now().strftime('%Y-%m-%d')
            SubElement(url, "changefreq").text = changefreq
            SubElement(url, "priority").text = priority
    
    # Add diary entries
    entry_files = glob.glob('./html/entry__*.html')
    
    for entry_file in sorted(entry_files):
        filename = os.path.basename(entry_file)
        
        # Extract date from filename for lastmod
        try:
            # filename format: entry__YYYY-MM-DD.html
            date_part = filename.replace('entry__', '').replace('.html', '')
            entry_date = datetime.strptime(date_part, '%Y-%m-%d')
            lastmod = entry_date.strftime('%Y-%m-%d')
        except:
            lastmod = datetime.now().strftime('%Y-%m-%d')
        
        url = SubElement(urlset, "url")
        SubElement(url, "loc").text = f"{base_url}/{filename}"
        SubElement(url, "lastmod").text = lastmod
        SubElement(url, "changefreq").text = "never"  # Historical entries don't change
        SubElement(url, "priority").text = "0.8"
    
    # Write sitemap to file
    tree = ElementTree(urlset)
    tree.write(sitemap_file, encoding="utf-8", xml_declaration=True)
    
    print(f"Generated sitemap with {len(urlset)} URLs at {sitemap_file}")
    
    # Generate sitemap index if needed (for large sites)
    total_urls = len(urlset)
    if total_urls > 45000:  # Close to sitemap limit of 50,000
        print(f"Warning: Large sitemap with {total_urls} URLs. Consider splitting into multiple sitemaps.")

if __name__ == "__main__":
    generate_sitemap()