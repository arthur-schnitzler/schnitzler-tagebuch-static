<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:df="http://example.com/df"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:import href="germandate.xsl"/>
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
            <div class="mt-2">
                <span class="infodesc mr-2">Profession</span>
                <span><xsl:value-of select="string-join(.//tei:occupation/text(), '; ')"/></span>
            </div>
            <div  class="mt-2">
                <span class="infodesc mr-2">geboren</span>
                <span><xsl:value-of select=".//tei:birth/tei:date/text()"/></span>
                <xsl:if test=".//tei:birth//tei:settlement/text()">, <xsl:value-of select=".//tei:birth//tei:settlement/text()"/></xsl:if>
            </div>
            <div class="mt-2">
                <span class="infodesc mr-2">gestorben</span>
                <span><xsl:value-of select=".//tei:death/tei:date/text()"/></span>
                <xsl:if test=".//tei:death//tei:settlement/text()">, <xsl:value-of select=".//tei:death//tei:settlement/text()"/></xsl:if>
            </div>
            <xsl:if test="count(.//tei:ptr) gt 0">
            <div id="mentions"  class="mt-2">
                <span class="infodesc mr-2">Erwähnt am</span>
                <ul class="list-unstyled">
                    <xsl:for-each select=".//tei:ptr">
                        <xsl:sort data-type="text" order="ascending" select="@target"/>
                        <xsl:variable name="linkToDocument">
                            <xsl:value-of select="replace(data(.//@target), '.xml', '.html')"/>
                        </xsl:variable>
                        <xsl:variable name="doc_date">
                            <xsl:value-of select="substring-after(replace(data(.//@target), '.xml', ''), '__')"/>
                        </xsl:variable>
                        <xsl:variable name="print_date">
                            <xsl:variable name="monat" select="df:germanNames(format-date($doc_date,'[MNn]'))"/>
                            <xsl:variable name="wochentag" select="df:germanNames(format-date($doc_date,'[F]'))"/>
                            <xsl:variable name="tag" select="concat(format-date($doc_date,'[D]'),'. ')"/>
                            <xsl:variable name="jahr" select="format-date($doc_date,'[Y]')"/>
                            <xsl:value-of select="concat($wochentag, ', ', $tag, $monat, ' ', $jahr)"/>
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
            </xsl:if>
        </div>
    </xsl:template>
</xsl:stylesheet>