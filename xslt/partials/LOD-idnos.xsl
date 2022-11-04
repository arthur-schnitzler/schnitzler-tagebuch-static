<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mam="whatever" exclude-result-prefixes="xs" version="2.0">
    <!-- This function gets as input a node with idnos as child element
    and checks them against the file of desired idnos and gives links
    as output
   -->
    <xsl:param name="relevant-uris" select="document('../utils/list-of-relevant-uris.xml')"/>
    <xsl:key name="only-relevant-uris" match="item" use="abbr"/>
    <xsl:template name="mam:idnosToLinks">
        <xsl:param name="idnos-of-current" as="node()"/>
        <xsl:for-each select="$relevant-uris/descendant::item[not(@type)]">
            <xsl:variable name="abbr" select="child::abbr"/>
            <xsl:variable name="uri-color" select="child::color" as="xs:string?"/>
            <xsl:if test="$idnos-of-current/descendant::tei:idno[@subtype = $abbr][1]">
                <xsl:variable name="current-idno" as="node()"
                    select="$idnos-of-current/descendant::tei:idno[@subtype = $abbr][1]"/>
                <xsl:element name="a">
                    <xsl:choose>
                        <xsl:when test="$abbr = 'wikidata'">
                            <xsl:variable name="wikipediaVSdata"
                                select="mam:wikidata2wikipedia($current-idno)" as="xs:string"/>
                            <xsl:attribute name="href">
                                <xsl:value-of select="$wikipediaVSdata"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">
                                <xsl:text>_blank</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="$abbr = 'pmb'">
                            <xsl:variable name="pmb-entitytype" as="xs:string">
                                <xsl:choose>
                                    <xsl:when test="tokenize($idnos-of-current/name(), '_')[2] = 'org'">
                                        <xsl:text>institution</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="tokenize($idnos-of-current/name(), '_')[2]"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:variable name="pmb-number" as="xs:string">
                                <xsl:choose>
                                    <xsl:when test="ends-with($current-idno, '/')">
                                        <xsl:value-of
                                            select="tokenize($current-idno, '/')[last() - 1]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="tokenize($current-idno, '/')[last()]"
                                        />
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:variable>
                            <xsl:attribute name="href">
                                <xsl:value-of
                                    select="concat('https://pmb.acdh.oeaw.ac.at/apis/entities/entity/', $pmb-entitytype, '/', $pmb-number, '/detail')"
                                />
                            </xsl:attribute>
                            <xsl:attribute name="target">
                                <xsl:text>_blank</xsl:text>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="href">
                                <xsl:value-of select="$current-idno"/>
                            </xsl:attribute>
                            <xsl:attribute name="target">
                                <xsl:text>_blank</xsl:text>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:element name="span">
                        <xsl:attribute name="class">
                            <xsl:text>badge rounded-pill</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="style">
                            <xsl:text>background-color: </xsl:text>
                            <xsl:choose>
                                <xsl:when test="$uri-color">
                                    <xsl:value-of select="$uri-color"/>
                                    <xsl:text>;</xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>black; </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text> color: white</xsl:text>
                        </xsl:attribute>
                        <xsl:choose>
                            <xsl:when test="$abbr = 'wikidata'">
                                <xsl:variable name="wikipediaVSdata"
                                    select="mam:wikidata2wikipedia($current-idno)" as="xs:string"/>
                                <xsl:variable name="lang-code"
                                    select="substring(substring-after($wikipediaVSdata, 'https://'), 1, 2)"/>
                                <xsl:choose>
                                    <xsl:when test="contains($wikipediaVSdata, 'wikipedia')">
                                        <xsl:choose>
                                            <xsl:when test="$lang-code = 'de'"/>
                                            <xsl:otherwise>
                                                <xsl:value-of select="$lang-code"/>
                                                <xsl:text>:</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:text>Wikipedia</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:text>Wikidata</xsl:text>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="./caption"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:element>
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:for-each select="$relevant-uris/descendant::item[@type = 'print-online']">
            <xsl:variable name="abbr" select="child::abbr"/>
            <xsl:if test="$idnos-of-current/descendant::tei:idno[@subtype = $abbr][1]">
                <xsl:variable name="current-idno" as="node()"
                    select="$idnos-of-current/descendant::tei:idno[@subtype = $abbr][1]"/>
                <xsl:variable name="uri-color" select="child::color" as="xs:string?"/>
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="child::url"/>
                    </xsl:attribute>
                    <xsl:attribute name="target">
                        <xsl:text>_blank</xsl:text>
                    </xsl:attribute>
                    <xsl:element name="span">
                        <xsl:attribute name="class">
                            <xsl:text>badge rounded-pill</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="style">
                            <xsl:text>background-color: </xsl:text>
                            <xsl:choose>
                                <xsl:when test="$uri-color">
                                    <xsl:value-of select="$uri-color"/>
                                    <xsl:text>; </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>black; </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text> color: white</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="./caption"/>
                    </xsl:element>
                </xsl:element>
                <xsl:text> </xsl:text>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    <xsl:function name="mam:wikidata2wikipedia">
        <xsl:param name="wikidata-entry" as="xs:string"/>
        <xsl:variable name="wikidata-entity">
            <xsl:choose>
                <xsl:when test="starts-with($wikidata-entry, 'Q')">
                    <xsl:value-of select="normalize-space($wikidata-entry)"/>
                </xsl:when>
                <xsl:when test="starts-with($wikidata-entry, 'https://www.wikidata.org/entity/')">
                    <xsl:value-of
                        select="normalize-space(substring-after($wikidata-entry, 'https://www.wikidata.org/entity/'))"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of
                        select="normalize-space(concat('Q', tokenize($wikidata-entry, 'Q')[last()]))"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="get-string" as="xs:string">
            <xsl:value-of
                select="concat('https://www.wikidata.org/w/api.php?action=wbgetentities&amp;format=xml&amp;props=sitelinks&amp;ids=', $wikidata-entity,'')"
            />
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="document($get-string)/api[descendant::sitelink]/@success = '1'">
                <xsl:variable name="sitelinks"
                    select="document($get-string)/descendant::sitelinks[1]" as="node()"/>
                <xsl:choose>
                    <xsl:when test="$sitelinks/sitelink[@site = 'dewiki']">
                        <xsl:value-of
                            select="concat('https://de.wikipedia.org/wiki/', $sitelinks/sitelink[@site = 'dewiki']/@title)"
                        />
                    </xsl:when>
                    <xsl:when test="$sitelinks/sitelink[@site = 'enwiki']">
                        <xsl:value-of
                            select="concat('https://en.wikipedia.org/wiki/', $sitelinks/sitelink[@site = 'enwiki']/@title)"
                        />
                    </xsl:when>
                    <xsl:when test="$sitelinks/sitelink[@site = 'frwiki']">
                        <xsl:value-of
                            select="concat('https://fr.wikipedia.org/wiki/', $sitelinks/sitelink[@site = 'frwiki']/@title)"
                        />
                    </xsl:when>
                    <xsl:when test="$sitelinks/sitelink[@site = 'itwiki']">
                        <xsl:value-of
                            select="concat('https://it.wikipedia.org/wiki/', $sitelinks/sitelink[@site = 'frwiki']/@title)"
                        />
                    </xsl:when>
                    <xsl:when test="$sitelinks/sitelink[@site = 'eswiki']">
                        <xsl:value-of
                            select="concat('https://es.wikipedia.org/wiki/', $sitelinks/sitelink[@site = 'eswiki']/@title)"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="lang-code"
                            select="substring($sitelinks/sitelink[1]/@site, 1, 2)"/>
                        <xsl:value-of
                            select="concat('https://', $lang-code, 'wikipedia.org/wiki/', $sitelinks/sitelink[1]/@title)"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$wikidata-entry"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="mam:normalize-date">
        <xsl:param name="date-string-mit-spitze" as="xs:string?"/>
        <xsl:variable name="date-string" as="xs:string">
            <xsl:choose>
                <xsl:when test="contains($date-string-mit-spitze, '&lt;')">
                    <xsl:value-of select="substring-before($date-string-mit-spitze, '&lt;')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$date-string-mit-spitze"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:analyze-string select="$date-string" regex="^(\d{{4}})-(\d{{2}})-(\d{{2}})$">
            <xsl:matching-substring>
                <xsl:variable name="year" select="xs:integer(regex-group(1))"/>
                <xsl:variable name="month">
                    <xsl:choose>
                        <xsl:when test="starts-with(regex-group(2), '0')">
                            <xsl:value-of select="substring(regex-group(2), 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="regex-group(2)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="day">
                    <xsl:choose>
                        <xsl:when test="starts-with(regex-group(3), '0')">
                            <xsl:value-of select="substring(regex-group(3), 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="regex-group(3)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:value-of select="concat($day, '. ', $month, '. ', $year)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:analyze-string select="." regex="^(\d{{2}}).(\d{{2}}).(\d{{4}})$">
                    <xsl:matching-substring>
                        <xsl:variable name="year" select="xs:integer(regex-group(3))"/>
                        <xsl:variable name="month">
                            <xsl:choose>
                                <xsl:when test="starts-with(regex-group(2), '0')">
                                    <xsl:value-of select="substring(regex-group(2), 2)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="regex-group(2)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="day">
                            <xsl:choose>
                                <xsl:when test="starts-with(regex-group(1), '0')">
                                    <xsl:value-of select="substring(regex-group(1), 2)"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="regex-group(1)"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:value-of select="concat($day, '. ', $month, '. ', $year)"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="."/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    <xsl:function name="mam:startenddatumgleich">
        <!-- sowas wird auf ein datum gekürzt: "1902-11-14 – 1902-11-14" -->
        <xsl:param name="date-string" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="tokenize($date-string, ' – ')[1] = tokenize($date-string, ' – ')[2]">
                <xsl:value-of select="tokenize($date-string, ' – ')[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$date-string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
