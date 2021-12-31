<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="2.0" exclude-result-prefixes="xsl tei xs">

    <xsl:template match="tei:place" name="place_detail">
        <xsl:param name="showNumberOfMentions" as="xs:integer" select="50000" />
        <xsl:variable name="selfLink">
            <xsl:value-of select="concat(data(@xml:id), '.html')"/>
        </xsl:variable>
        <div class="card-body">
            <xsl:if test="count(.//tei:placeName) gt 1">
                <small>Namensvarianten:</small>
                <ul>
                    <xsl:for-each select=".//tei:placeName">
                        <li><xsl:value-of select="./text()"/></li>
                    </xsl:for-each>
                </ul>
            </xsl:if>
            
            <xsl:if test="count(.//tei:idno) gt 0">
                <small>Normdaten IDs</small>
                <ul>
                    <xsl:for-each select=".//tei:idno">
                        <xsl:if test="./@type">
                            <li>
                                <small><xsl:value-of select="data(./@type)"/>:</small> <xsl:text> </xsl:text>
                                <a>
                                    <xsl:attribute name="href"><xsl:value-of select="./text()"/></xsl:attribute>
                                    <xsl:value-of select="./text()"/>
                                </a>
                            </li>
                        </xsl:if>
                    </xsl:for-each>
                </ul>
            </xsl:if>
            <small>Koordinaten:</small>
            <xsl:if test=".//tei:geo/text()">
                <xsl:text> </xsl:text><xsl:value-of select=".//tei:geo/text()"/>
            </xsl:if>
            <hr />
            <div id="mentions">
                <legend>erwähnt in</legend>
                <ul>
                    <xsl:for-each select=".//tei:ptr">
                        <xsl:variable name="linkToDocument">
                            <xsl:value-of select="replace(data(.//@target), '.xml', '.html')"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="position() lt $showNumberOfMentions + 1">
                                <li>
                                    erwähnt am <xsl:value-of select="substring-after(replace(data(.//@target), '.xml', ''), '__')"/> <xsl:text> </xsl:text>
                                    <a href="{$linkToDocument}">
                                        <i class="fas fa-external-link-alt"></i>
                                    </a>
                                </li>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </ul>
                <xsl:if test="count(.//tei:event) gt $showNumberOfMentions + 1">
                    <p>Anzahl der Erwähnungen limitiert, klicke <a href="{$selfLink}">hier</a> für eine vollständige Auflistung</p>
                </xsl:if>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>
