<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl tei xs" version="2.0">

    <!-- Template for Website/Organization structured data -->
    <xsl:template name="website_structured_data">
        <xsl:param name="page_title" select="''"/>
        <xsl:param name="page_url" select="''"/>
        <xsl:param name="page_description" select="''"/>

        <script type="application/ld+json">
        {
            "@context": "https://schema.org",
            "@graph": [
                {
                    "@type": "Organization",
                    "@id": "https://schnitzler-tagebuch.acdh.oeaw.ac.at/#organization",
                    "name": "Austrian Centre for Digital Humanities and Cultural Heritage",
                    "alternateName": "ACDH-CH",
                    "url": "https://www.oeaw.ac.at/acdh/",
                    "logo": {
                        "@type": "ImageObject",
                        "url": "https://shared.acdh.oeaw.ac.at/schnitzler-tagebuch/project-logo.svg"
                    }
                },
                {
                    "@type": "WebSite",
                    "@id": "https://schnitzler-tagebuch.acdh.oeaw.ac.at/#website",
                    "url": "https://schnitzler-tagebuch.acdh.oeaw.ac.at/",
                    "name": "Arthur Schnitzler: Tagebuch (1879–1931). Digitale Edition",
                    "description": "Digitale Edition der Tagebücher Arthur Schnitzlers von 1879 bis 1931",
                    "publisher": {
                        "@id": "https://schnitzler-tagebuch.acdh.oeaw.ac.at/#organization"
                    },
                    "inLanguage": "de-AT",
                    "potentialAction": {
                        "@type": "SearchAction",
                        "target": "https://schnitzler-tagebuch.acdh.oeaw.ac.at/search.html?q={search_term_string}",
                        "query-input": "required name=search_term_string"
                    }
                }<xsl:if test="$page_url != ''">
                ,{
                    "@type": "WebPage",
                    "@id": "<xsl:value-of select="$page_url"/>#webpage",
                    "url": "<xsl:value-of select="$page_url"/>",
                    "name": "<xsl:value-of select="$page_title"/>",
                    <xsl:if test="$page_description != ''">"description": "<xsl:value-of select="replace($page_description, '&quot;', '\\&quot;')"/>",</xsl:if>
                    "isPartOf": {
                        "@id": "https://schnitzler-tagebuch.acdh.oeaw.ac.at/#website"
                    },
                    "inLanguage": "de-AT"
                }</xsl:if>
            ]
        }
        </script>
    </xsl:template>

    <!-- Template for diary entry structured data -->
    <xsl:template name="diary_entry_structured_data">
        <xsl:param name="entry_title" select="''"/>
        <xsl:param name="entry_date" select="''"/>
        <xsl:param name="entry_url" select="''"/>
        <xsl:param name="entry_content" select="''"/>
        <xsl:param name="persons" select="()"/>
        <xsl:param name="places" select="()"/>
        <xsl:param name="works" select="()"/>

        <script type="application/ld+json">
        {
            "@context": "https://schema.org",
            "@type": "CreativeWork",
            "@id": "<xsl:value-of select="$entry_url"/>#entry",
            "name": "<xsl:value-of select="$entry_title"/>",
            "author": {
                "@type": "Person",
                "name": "Arthur Schnitzler",
                "birthDate": "1862-05-15",
                "deathDate": "1931-10-21",
                "nationality": "Austrian",
                "description": "Austrian author and playwright",
                "sameAs": [
                    "https://www.wikidata.org/wiki/Q44331",
                    "https://d-nb.info/gnd/118609807",
                    "https://de.wikipedia.org/wiki/Arthur_Schnitzler"
                ]
            },
            <xsl:if test="$entry_date != ''">"dateCreated": "<xsl:value-of select="$entry_date"/>",</xsl:if>
            "inLanguage": "de-AT",
            "genre": "Diary entry",
            <xsl:if test="$entry_content != ''">"text": "<xsl:value-of select="substring(replace(replace($entry_content, '&quot;', '\\&quot;'), '\n', ' '), 1, 500)"/>...",</xsl:if>
            "isPartOf": {
                "@type": "CreativeWork",
                "name": "Tagebuch (1879–1931)",
                "author": {
                    "@type": "Person",
                    "name": "Arthur Schnitzler"
                }
            },
            "publisher": {
                "@type": "Organization",
                "name": "Austrian Centre for Digital Humanities and Cultural Heritage"
            }<xsl:if test="count($persons) > 0">
            ,"mentions": [
                <xsl:for-each select="$persons[position() &lt;= 10]">
                {
                    "@type": "Person",
                    "name": "<xsl:value-of select="replace(., '&quot;', '\\&quot;')"/>"
                }<xsl:if test="position() != last()">,</xsl:if>
                </xsl:for-each>
            ]</xsl:if><xsl:if test="count($places) > 0">
            ,"contentLocation": [
                <xsl:for-each select="$places[position() &lt;= 5]">
                {
                    "@type": "Place",
                    "name": "<xsl:value-of select="replace(., '&quot;', '\\&quot;')"/>"
                }<xsl:if test="position() != last()">,</xsl:if>
                </xsl:for-each>
            ]</xsl:if>
        }
        </script>
    </xsl:template>

    <!-- Template for search page structured data -->
    <xsl:template name="search_page_structured_data">
        <script type="application/ld+json">
        {
            "@context": "https://schema.org",
            "@type": "WebPage",
            "name": "Volltextsuche - Arthur Schnitzler Tagebuch",
            "description": "Durchsuchen Sie die Tagebücher Arthur Schnitzlers mit Volltext- und linguistischer Suche",
            "url": "https://schnitzler-tagebuch.acdh.oeaw.ac.at/search.html",
            "mainEntity": {
                "@type": "SearchAction",
                "target": "https://schnitzler-tagebuch.acdh.oeaw.ac.at/search.html?q={search_term_string}",
                "query-input": "required name=search_term_string"
            },
            "isPartOf": {
                "@id": "https://schnitzler-tagebuch.acdh.oeaw.ac.at/#website"
            }
        }
        </script>
    </xsl:template>

    <!-- Template for person/place/work index pages -->
    <xsl:template name="index_page_structured_data">
        <xsl:param name="index_type" select="'ItemList'"/>
        <xsl:param name="index_title" select="''"/>
        <xsl:param name="index_description" select="''"/>
        <xsl:param name="index_url" select="''"/>

        <script type="application/ld+json">
        {
            "@context": "https://schema.org",
            "@type": "<xsl:value-of select="$index_type"/>",
            "name": "<xsl:value-of select="$index_title"/>",
            <xsl:if test="$index_description != ''">"description": "<xsl:value-of select="replace($index_description, '&quot;', '\\&quot;')"/>",</xsl:if>
            "url": "<xsl:value-of select="$index_url"/>",
            "isPartOf": {
                "@id": "https://schnitzler-tagebuch.acdh.oeaw.ac.at/#website"
            }
        }
        </script>
    </xsl:template>

</xsl:stylesheet>