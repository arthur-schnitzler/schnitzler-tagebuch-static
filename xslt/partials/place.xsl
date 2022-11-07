<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mam="whatever"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:import href="LOD-idnos.xsl"/>
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
                
                <div class="card">
                </div>
            </xsl:if>
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
            <div id="mentions" class="mt-2"><span class="infodesc mr-2">
                <legend>Erwähnungen</legend>
                <ul>
                    <xsl:for-each select=".//tei:note[@type='mentions']">
                        <xsl:variable name="linkToDocument">
                            <xsl:value-of
                                select="replace(tokenize(data(.//@target), '/')[last()], '.xml', '.html')"
                            />
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="position() lt $showNumberOfMentions + 1">
                                <li>
                                    <xsl:value-of select="."/>
                                    <xsl:text> </xsl:text>
                                    <a href="{$linkToDocument}">
                                        <i class="fas fa-external-link-alt"/>
                                    </a>
                                </li>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </ul>
                <xsl:if test="count(.//tei:note[@type='mentions']) gt $showNumberOfMentions + 1">
                    <p>Anzahl der Erwähnungen limitiert, klicke <a href="{$selfLink}">hier</a> für
                        eine vollständige Auflistung</p>
                </xsl:if></span>
            </div>
        </div>
        </div>
    </xsl:template>
    
    <xsl:function name="mam:pmbChange">
        <xsl:param name="url" as="xs:string"/>
        <xsl:param name="entitytyp" as="xs:string"/>
        <xsl:value-of select="
            concat('https://pmb.acdh.oeaw.ac.at/apis/entities/entity/', $entitytyp, '/',
            substring-after($url, 'https://pmb.acdh.oeaw.ac.at/entity/'), '/detail')"/>
    </xsl:function>
    <xsl:function name="mam:ahref-namen">
        <xsl:param name="typityp" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$typityp = 'schnitzler-tagebuch'">
                <xsl:text> Tagebuch</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'schnitzler-briefe'">
                <xsl:text> Briefe</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'schnitzler-lektueren'">
                <xsl:text> Lektüren</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'PMB'">
                <xsl:text> PMB</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'pmb'">
                <xsl:text> PMB</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'briefe_i'">
                <xsl:text> Briefe 1875–1912</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'briefe_ii'">
                <xsl:text> Briefe 1913–1931</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'DLAwidmund'">
                <xsl:text> Widmungsexemplar Deutsches Literaturarchiv</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'jugend-in-wien'">
                <xsl:text> Jugend in Wien</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'gnd'">
                <xsl:text> Wikipedia?</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'schnitzler-briefe'">
                <xsl:text> Bahr/Schnitzler</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'widmungDLA'">
                <xsl:text> Widmung DLA</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> </xsl:text>
                <xsl:value-of select="$typityp"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>
