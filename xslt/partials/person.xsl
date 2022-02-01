<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    
    <xsl:template match="tei:person" name="person_detail">
        <xsl:param name="showNumberOfMentions" as="xs:integer" select="50000" />
        <xsl:variable name="selfLink">
            <xsl:value-of select="concat(data(@xml:id), '.html')"/>
        </xsl:variable>
        <div class="card-body-tagebuch w-75">
            <div>
                <span class="infodesc mr-2">Vorname</span>
                <span><xsl:value-of select=".//tei:forename/text()"/></span>
            </div>
            <div class="mt-2">
                <span class="infodesc mr-2">Nachname</span>
                <span><xsl:value-of select=".//tei:surname/text()"/></span>
            </div>
            <div  class="mt-2">
                <span class="infodesc mr-2">geboren</span>
                <span><xsl:value-of select=".//tei:birth/tei:date/text()"/></span>
            </div>
            <div class="mt-2">
                <span class="infodesc mr-2">gestorben</span>
                <span><xsl:value-of select=".//tei:death/tei:date/text()"/></span>
            </div>
            <xsl:if test="count(.//tei:event) gt 0">
            <div id="mentions"  class="mt-2">
                <span class="infodesc mr-2">Erwähnt am</span>
                <ul class="list-unstyled ml-2">
                    <xsl:for-each select=".//tei:ptr">
                        <xsl:variable name="linkToDocument">
                            <xsl:value-of select="replace(data(.//@target), '.xml', '.html')"/>
                        </xsl:variable>
                        <xsl:choose>
                            <xsl:when test="position() lt 0">
                                <li>
                                    <xsl:value-of select="substring-after(replace(data(.//@target), '.xml', ''), '__')"/> <xsl:text> </xsl:text>
                                    <a href="{$linkToDocument}">
                                        <i class="fas fa-external-link-alt"></i>
                                    </a>
                                </li>
                            </xsl:when>
                        </xsl:choose>
                    </xsl:for-each>
                </ul>
            </div>
            </xsl:if>
        </div>
    </xsl:template>
</xsl:stylesheet>