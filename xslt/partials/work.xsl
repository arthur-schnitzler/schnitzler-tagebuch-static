<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:df="http://example.com/df" xmlns:mam="whatever" version="2.0"
    exclude-result-prefixes="xsl tei xs">
    <xsl:import href="germandate.xsl"/>
    <xsl:import href="LOD-idnos.xsl"/>
    <xsl:param name="relevant-uris" select="document('../utils/list-of-relevant-uris.xml')"/>
    <xsl:key name="only-relevant-uris" match="item" use="abbr"/>
    <xsl:param name="works" select="document('../../data/indices/listwork.xml')"/>
    <xsl:key name="work-lookup" match="tei:bibl" use="tei:relatedItem/@target"/>
    <xsl:param name="authors" select="document('../../data/indices/listperson.xml')"/>
    <xsl:key name="author-lookup" match="tei:person" use="tei:idno[@subtype = 'pmb']"/>
    <xsl:param name="work-day" select="document('../../data/indices/index_work_day.xml')"/>
    <xsl:key name="work-day-lookup" match="item" use="ref"/>
    <xsl:template match="tei:bibl" name="work_detail">
        <xsl:param name="showNumberOfMentions" as="xs:integer" select="50000"/>
        <xsl:variable name="selfLink">
            <xsl:value-of select="concat(data(@xml:id), '.html')"/>
        </xsl:variable>
        <div class="card-body-index">
            <div id="mentions">
                <xsl:if test="key('only-relevant-uris', tei:idno/@subtype, $relevant-uris)[1]">
                    <p class="buttonreihe">
                        <xsl:variable name="idnos-of-current" as="node()">
                            <xsl:element name="nodeset_work">
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
            <xsl:if test="tei:author">
                <div id="autor_innen">
                    <p>
                        <legend>Geschaffen von</legend>
                                <ul>
                                    <xsl:for-each select="tei:author">
                                        <li>
                                            <xsl:variable name="keyToRef" as="xs:string">
                                                <xsl:choose>
                                                  <xsl:when test="@key">
                                                  <xsl:value-of select="replace(@key, '#', '')"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                      <xsl:value-of select="replace(@ref, '#', '')"/>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>
                                            <xsl:variable name="autor-ref" as="xs:string">
                                                <xsl:choose>
                                                  <xsl:when test="contains($keyToRef, 'person__')">
                                                  <xsl:value-of
                                                  select="substring-after($keyToRef, 'person__')"/>
                                                  </xsl:when>
                                                  <xsl:when test="starts-with($keyToRef, 'pmb')">
                                                  <xsl:value-of
                                                  select="replace($keyToRef, 'pmb', '')"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="$keyToRef"/>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>
                                            <xsl:choose>
                                                <xsl:when test="$autor-ref = '2121'">
                                                  <a href="pmb2121.html">
                                                  <xsl:text>Arthur Schnitzler</xsl:text>
                                                  </a>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:variable name="autor-ref-schnitzler-tagebuch">
                                                        <xsl:choose>
                                                            <xsl:when test="key('author-lookup', concat('https://pmb.acdh.oeaw.ac.at/entity/', $autor-ref, '/'), $authors)">
                                                                <xsl:value-of select="key('author-lookup', concat('https://pmb.acdh.oeaw.ac.at/entity/', $autor-ref, '/'), $authors)/tei:idno[@subtype = 'schnitzler-tagebuch']/substring-after(., 'https://schnitzler-tagebuch.acdh.oeaw.ac.at/entity/')"/>
                                                            </xsl:when>
                                                            <xsl:otherwise><!-- hier nur der Schrägstrich am Schluss, falls der in der URI fehlt -->
                                                                <xsl:value-of select="key('author-lookup', concat('https://pmb.acdh.oeaw.ac.at/entity/', $autor-ref), $authors)/tei:idno[@subtype = 'schnitzler-tagebuch']/substring-after(., 'https://schnitzler-tagebuch.acdh.oeaw.ac.at/entity/')"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:variable>
                                                    <a>
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of
                                                  select="concat($autor-ref-schnitzler-tagebuch, '.html')"
                                                  />
                                                  </xsl:attribute>
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="child::tei:forename and child::tei:surname">
                                                  <xsl:value-of select="tei:persName/tei:forename"/>
                                                  <xsl:text> </xsl:text>
                                                  <xsl:value-of select="tei:persName/tei:surname"/>
                                                  </xsl:when>
                                                  <xsl:when test="child::tei:surname">
                                                  <xsl:value-of select="child::tei:surname"/>
                                                  </xsl:when>
                                                  <xsl:when test="child::tei:forename">
                                                  <xsl:value-of select="child::tei:forename"/>"/> </xsl:when>
                                                  <xsl:when test="contains(., ', ')">
                                                  <xsl:value-of
                                                  select="concat(substring-after(., ', '), ' ', substring-before(., ', '))"
                                                  />
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="."/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </a>
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="@role = 'editor' or @role = 'hat-herausgegeben'">
                                                  <xsl:text> (Herausgabe)</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when
                                                  test="@role = 'translator' or @role = 'hat-ubersetzt'">
                                                  <xsl:text> (Übersetzung)</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when test="@role = 'hat-ubersetzt'">
                                                  <xsl:text> (unter Pseudonym)</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when
                                                  test="@role = 'hat-unter-einem-kurzel-veroffentlicht'">
                                                  <xsl:text> (unter Kürzel)</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when test="@role = 'hat-illustriert'">
                                                  <xsl:text> (Illustration)</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when test="@role = 'hat-vertont'">
                                                  <xsl:text> (Vertonung)</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when
                                                  test="@role = 'hat-einen-beitrag-geschaffen-zu'">
                                                  <xsl:text> (Beitrag)</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when
                                                  test="@role = 'hat-ein-vorwortnachwort-verfasst-zu'">
                                                  <xsl:text> (Vorwort/Nachwort)</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when
                                                  test="@role = 'hat-anonym-veroffentlicht'">
                                                  <xsl:text> (ohne Namensnennung)</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when test="@role = 'bekommt-zugeschrieben'">
                                                  <xsl:text> (Zuschreibung)</xsl:text>
                                                  </xsl:when>
                                                  </xsl:choose>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                        
                            
                                
                    </p>
                </div>
                <div id="erscheinungsdatum" class="mt-2">
                    <p>
                        <xsl:if test="tei:date[1]">
                            <legend>Erschienen</legend>
                            <xsl:choose>
                                <xsl:when test="contains(tei:date[1], '–')">
                                    <xsl:choose>
                                        <xsl:when
                                            test="normalize-space(tokenize(tei:date[1], '–')[1]) = normalize-space(tokenize(tei:date[1], '–')[2])">
                                            <xsl:value-of
                                                select="mam:normalize-date(normalize-space((tokenize(tei:date[1], '–')[1])))"
                                            />
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of
                                                select="mam:normalize-date(normalize-space(tei:date[1]))"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="mam:normalize-date(tei:date[1])"/>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:if test="not(ends-with(tei:date[1], '.'))">
                                <xsl:text>.</xsl:text>
                            </xsl:if>
                        </xsl:if>
                    </p>
                </div>
                <p/>
            </xsl:if>
            <xsl:if
                test="tei:title[@type = 'werk_bibliografische-angabe' or starts-with(@type, 'werk_link')]">
                <div id="labels" class="mt-2">
                    <span class="infodesc mr-2">
                        <ul>
                            <xsl:for-each select="tei:title[@type = 'werk_bibliografische-angabe']">
                                <li>
                                    <xsl:text>Bibliografische Angabe: </xsl:text>
                                    <xsl:value-of select="."/>
                                </li>
                            </xsl:for-each>
                            <xsl:for-each select="tei:title[starts-with(@type, 'werk_link')]">
                                <li>
                                    <a>
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="."/>
                                        </xsl:attribute>
                                        <xsl:attribute name="target">
                                            <xsl:text>_blank</xsl:text>
                                        </xsl:attribute>
                                        <xsl:text>Online verfügbar</xsl:text>
                                    </a>
                                </li>
                            </xsl:for-each>
                        </ul>
                    </span>
                </div>
            </xsl:if>
            <div id="mentions" class="mt-2">
                <legend>Erwähnt am</legend>
                <ul class="list-unstyled">
                    <xsl:for-each select="key('work-day-lookup', @xml:id, $work-day)">
                        <xsl:variable name="linkToDocument">
                            <xsl:value-of select="concat('entry__', data(@target), '.html')"/>
                        </xsl:variable>
                        <xsl:variable name="print_date">
                            <xsl:variable name="monat"
                                select="df:germanNames(format-date(data(@target), '[MNn]'))"/>
                            <xsl:variable name="wochentag"
                                select="df:germanNames(format-date(data(@target), '[F]'))"/>
                            <xsl:variable name="tag"
                                select="concat(format-date(data(@target), '[D]'), '. ')"/>
                            <xsl:variable name="jahr" select="format-date(data(@target), '[Y]')"/>
                            <xsl:value-of
                                select="concat($wochentag, ', ', $tag, $monat, ' ', $jahr)"/>
                        </xsl:variable>
                        <li>
                            <a href="{$linkToDocument}">
                                <xsl:value-of select="$print_date"/>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>
