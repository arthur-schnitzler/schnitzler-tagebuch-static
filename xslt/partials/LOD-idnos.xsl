<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mam="whatever" exclude-result-prefixes="xs" version="2.0">
    <!-- This function gets as input a node with idnos as child element
    and checks them against the file of desired idnos and gives links
    as output
   -->
    <xsl:param name="relevant-uris" select="document('https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-chronik-static/refs/heads/main/xslt/export/list-of-relevant-uris.xml')"/>
    <xsl:key name="only-relevant-uris" match="item" use="abbr"/>
    <xsl:template name="mam:idnosToLinks">
        <xsl:param name="idnos-of-current" as="node()"/>
        <xsl:for-each select="$relevant-uris/descendant::item[not(@type)]">
            <xsl:variable name="pill" as="node()">
                <item>
                    <xsl:copy-of select="child::*"/>
                </item>
            </xsl:variable>
            <xsl:variable name="abbr" select="child::abbr" as="xs:string"/>
            <xsl:choose>
                <xsl:when
                    test="$idnos-of-current/descendant::tei:idno[@subtype = $abbr][2] and @ana = 'multiple'">
                    <xsl:element name="button">
                        <xsl:attribute name="class">
                            <xsl:text>badge rounded-pill</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="style">
                            <xsl:text>background-color: </xsl:text>
                            <xsl:choose>
                                <xsl:when test="$pill/color">
                                    <xsl:value-of select="$pill/color"/>
                                    <xsl:text>; </xsl:text>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>black; </xsl:text>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:text> color: white</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="data-bs-toggle">
                            <xsl:text>modal</xsl:text>
                        </xsl:attribute>
                        <xsl:attribute name="data-bs-target">
                            <xsl:value-of select="concat('#', $pill/caption)"/>
                        </xsl:attribute>
                        <xsl:value-of select="$pill/caption"/>
                    </xsl:element>
                    <xsl:text> </xsl:text>
                </xsl:when>
                <xsl:when test="$idnos-of-current/descendant::tei:idno[@subtype = $abbr][1]">
                    <xsl:call-template name="mam:pill">
                        <xsl:with-param name="current-idno"
                            select="$idnos-of-current/descendant::tei:idno[@subtype = $abbr][1]"/>
                        <xsl:with-param name="pill" select="$pill"/>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
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
        <!-- wenn es mehrere Idnos anzuzeigen gibt, wird die Auswahl als Modal gezeigt, deswegen werden
        für alle @ana='multiple' modals angelegt-->
        <xsl:for-each select="$relevant-uris/descendant::item[not(@type) and @ana = 'multiple']">
            <xsl:variable name="pill" as="node()">
                <item>
                    <xsl:copy-of select="child::*"/>
                </item>
            </xsl:variable>
            <xsl:variable name="abbr" select="child::abbr" as="xs:string"/>
            <div class="modal fade modal-sm" id="{$pill/caption}" tabindex="-1" focus="true"
                keyboard="true" aria-labelledby="{$pill/caption}" aria-hidden="true"
                data-bs-backdrop="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="exampleModalLabel">Mehrfache Links</h5>
                            <button type="button" class="btn-close" data-bs-dismiss="modal"
                                aria-label="Schließen"/>
                        </div>
                        <div class="modal-body">
                            <p>Mehrfaches Vorkommen auf der angesteuerten Website: </p>
                            <ol style="list-style-type: none; padding: 0px;">
                                <xsl:for-each
                                    select="$idnos-of-current/descendant::tei:idno[@subtype = $abbr]">
                                    <li><xsl:value-of select="position()"/><xsl:text>. Link: </xsl:text>
                                        <xsl:call-template name="mam:pill">
                                            <xsl:with-param name="current-idno" select="."/>
                                            <xsl:with-param name="pill" select="$pill"/>
                                        </xsl:call-template>
                                    </li>
                                </xsl:for-each>
                            </ol>
                        </div>
                    </div>
                </div>
            </div>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="mam:pill">
        <xsl:param name="current-idno" as="xs:string"/>
        <xsl:param name="pill" as="node()"/>
        <xsl:variable name="abbr" select="$pill//abbr" as="xs:string"/>
        <xsl:variable name="uri-color" select="$pill//color" as="xs:string?"/>
        <xsl:variable name="caption" select="$pill//caption" as="xs:string"/>
        <xsl:element name="a">
            <xsl:attribute name="href">
                <xsl:value-of select="normalize-space($current-idno)"/>
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
                            <xsl:text>;</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>black; </xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:text> color: white; margin-top: 4px;</xsl:text>
                </xsl:attribute>
                <xsl:value-of select="$caption"/>
            </xsl:element>
        </xsl:element>
        <xsl:text> </xsl:text>
    </xsl:template>
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
