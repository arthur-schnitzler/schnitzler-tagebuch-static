<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    
    <xsl:template match="tei:bibl" name="work_detail">
        <xsl:param name="showNumberOfMentions" as="xs:integer" select="50000" />
        <xsl:variable name="selfLink">
            <xsl:value-of select="concat(data(@xml:id), '.html')"/>
        </xsl:variable>
         <div class="card-body-tagebuch w-75">
            <div>
                <span class="infodesc mr-2">Titel</span>
                <span><xsl:value-of select=".//tei:title/text()"/></span>
            </div>
            <div class="mt-2">
                <span class="infodesc mr-2">Verfasser:in</span>
                <span><xsl:value-of select=".//tei:surname/text()"/>, <xsl:value-of select=".//tei:forename/text()"/></span> 
            </div>          
            <div id="mentions" class="mt-2">
                <span class="infodesc mr-2">Erwähnt am</span>
                <ul class="list-unstyled ml-2">
                    <xsl:for-each select=".//tei:date">
                        <xsl:variable name="linkToDocument">
                            <xsl:value-of select="concat('entry__', data(@when), '.html')"/>
                        </xsl:variable>
                        <xsl:variable name="print_date">
                            <xsl:value-of select='format-date(data(@when),"[F], [D]. [Mn] [Y]", "de", (), ())'/>
                        </xsl:variable>
                        <li>
                            <xsl:value-of select="$print_date"/> <xsl:text> </xsl:text>
                            <a href="{$linkToDocument}">
                                <i class="fas fa-external-link-alt"></i>
                            </a>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
        </div>
    </xsl:template>
</xsl:stylesheet>