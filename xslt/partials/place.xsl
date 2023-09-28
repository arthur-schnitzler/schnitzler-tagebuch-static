<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mam="whatever"
    xmlns:df="http://example.com/df" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0" version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:import href="LOD-idnos.xsl"/>
    <xsl:import href="germandate.xsl"/>
    <xsl:param name="relevant-uris" select="document('../utils/list-of-relevant-uris.xml')"/>
    <xsl:key name="only-relevant-uris" match="item" use="abbr"/>
    <xsl:template match="tei:place" name="place_detail">
        <xsl:param name="showNumberOfMentions" as="xs:integer" select="50000"/>
        <xsl:variable name="selfLink">
            <xsl:value-of select="concat(data(@xml:id), '.html')"/>
        </xsl:variable>
        <div class="container-fluid">
            <div class="card-body-index">
                <div id="mentions">
                    <xsl:if test="key('only-relevant-uris', tei:idno/@subtype, $relevant-uris)[1]">
                        <p class="buttonreihe">
                            <xsl:variable name="idnos-of-current" as="node()">
                                <xsl:element name="nodeset_place">
                                    <xsl:for-each select="tei:idno">
                                        <xsl:copy-of select="."/>
                                    </xsl:for-each>
                                </xsl:element>
                            </xsl:variable>
                            <xsl:call-template name="mam:idnosToLinks">
                                <xsl:with-param name="idnos-of-current" select="$idnos-of-current"/>
                            </xsl:call-template>
                        </p>
                    </xsl:if>
                </div>
                <xsl:if test=".//tei:geo/text()">
                    <div id="mapid" style="height: 400px; width:100%; clear: both;"/>
                    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css"
                        integrity="sha512-xodZBNTC5n17Xt2atTPuE1HxjVMSvLVW9ocqUKLsCC5CXdbqCmblAshOMAS6/keqq/sMZMZ19scR4PsZChSR7A=="
                        crossorigin=""/>
                    <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js" integrity="sha512-XQoYMqMTK8LvdxXYG3nZ448hOEQiglfqkJs1NOQV44cWnUrBc8PkAOcXy20w0vlaXaVUearIOBhiXZ5V3ynxwA==" crossorigin=""/>
                    <script>
                                                    
                                                    var mymap = L.map('mapid').setView([50, 12], 5);
                                                    
                                                    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                                                    attribution: 'Map data &amp;copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.openstreetmap.org/">OpenStreetMap</a>',
                                                    maxZoom: 18,
                                                    zIndex: 1
                                                    }).addTo(mymap);
                                                    <xsl:variable name="laenge" as="xs:string" select="replace(tokenize(descendant::tei:geo[1]/text(), ' ')[1], ',', '.')"/>
                                                    <xsl:variable name="breite" as="xs:string" select="replace(tokenize(descendant::tei:geo[1]/text(), ' ')[2], ',', '.')"/>
                                                        <xsl:variable name="laengebreite" as="xs:string" select="concat($laenge, ', ', $breite)"/>
                                                        <xsl:value-of select="$laengebreite"/>
                                                        L.marker([<xsl:value-of select="$laengebreite"/>]).addTo(mymap)
                                                        .bindPopup("<b>
                                                            <xsl:value-of select="./tei:placeName[1]/text()"/>
                                                        </b>").openPopup();
                                                </script>
                 
                </xsl:if>
                <div class="card"> 
                    <xsl:if test="count(.//tei:placeName[contains(@type, 'namensvariante')]) gt 1">
                        <legend>Namensvarianten</legend>
                        <ul>
                            <xsl:for-each select=".//tei:placeName[contains(@type, 'namensvariante')]">
                                <li>
                                    <xsl:value-of select="./text()"/>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </xsl:if>
                    <div id="mentions" class="mt-2">
                        <legend>Erwähnt am</legend>
                        <ul class="list-unstyled">
                            <xsl:for-each select=".//tei:ptr">
                                <xsl:sort data-type="text" order="ascending" select="@target"/>
                                <xsl:variable name="linkToDocument">
                                    <xsl:value-of select="replace(data(.//@target), '.xml', '.html')"/>
                                </xsl:variable>
                                <xsl:variable name="doc_date">
                                    <xsl:value-of
                                        select="substring-after(replace(data(.//@target), '.xml', ''), '__')"
                                    />
                                </xsl:variable>
                                <xsl:variable name="print_date">
                                    <xsl:variable name="monat"
                                        select="df:germanNames(format-date($doc_date, '[MNn]'))"/>
                                    <xsl:variable name="wochentag"
                                        select="df:germanNames(format-date($doc_date, '[F]'))"/>
                                    <xsl:variable name="tag"
                                        select="concat(format-date($doc_date, '[D]'), '. ')"/>
                                    <xsl:variable name="jahr" select="format-date($doc_date, '[Y]')"/>
                                    <xsl:value-of
                                        select="concat($wochentag, ', ', $tag, $monat, ' ', $jahr)"/>
                                </xsl:variable>
                                <li>
                                    <xsl:value-of select="$print_date"/>
                                    <xsl:text> </xsl:text>
                                    <a href="{$linkToDocument}">
                                        <i class="fas fa-external-link-alt"/>
                                    </a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>
