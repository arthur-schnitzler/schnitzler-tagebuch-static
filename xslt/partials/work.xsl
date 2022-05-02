<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:df="http://example.com/df"
    xmlns:mam="personalShit"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:import href="germandate.xsl"/>
    <xsl:param name="works"
        select="document('../../data/indices/listwork.xml')"/>
    <xsl:key name="work-lookup" match="tei:bibl" use="tei:relatedItem/@target"/>
    <xsl:param name="work-day"
        select="document('../../data/indices/index_work_day.xml')"/>
    <xsl:key name="work-day-lookup" match="item" use="ref"/>
    <xsl:template match="tei:bibl" name="work_detail">
        <xsl:param name="showNumberOfMentions" as="xs:integer" select="50000"/>
        <xsl:variable name="selfLink">
            <xsl:value-of select="concat(data(@xml:id), '.html')"/>
        </xsl:variable>
        <div class="card-body-tagebuch w-75">
            <div class="mt-2">
                <xsl:if test="tei:date">
                    <p><xsl:text>Erschienen: </xsl:text>
                    <xsl:value-of select="tei:date"/>
                    <xsl:if test="not(ends-with(tei:date[1], '.'))">
                        <xsl:text>.</xsl:text>
                    </xsl:if></p>
                </xsl:if>
                <span>
                    <xsl:for-each select="tei:author">
                        <xsl:variable name="autor-ref" select="tei:idno[@type='schnitzler-tagebuch']"/>
                        <xsl:choose>
                            <xsl:when test="tei:idno[@type='pmb']/text()='pmb2121'">
                                <xsl:text>Arthur Schnitzler</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <a href="{$autor-ref}">
                                    <xsl:choose>
                                        <xsl:when test="tei:persName/tei:forename and tei:persName/tei:surname ">
                                            <xsl:value-of select="tei:persName/tei:forename"/><xsl:text> </xsl:text><xsl:value-of select="tei:persName/tei:surname"/>
                                        </xsl:when>
                                        <xsl:when test="tei:persName/tei:surname">
                                            <xsl:value-of select="tei:persName/tei:surname"/>
                                        </xsl:when>
                                        <xsl:when test="tei:persName/tei:forename">
                                            <xsl:value-of select="tei:persName/tei:forename"/>"/>
                                        </xsl:when>
                                    </xsl:choose>
                                </a>
                                <xsl:if test="@role='editor'">
                                    <xsl:text> (Hrsg.)</xsl:text>
                                </xsl:if>
                                <xsl:if test="@role='translator'">
                                    <xsl:text> (Übersetzung)</xsl:text>
                                </xsl:if>
                                <xsl:if test="@role='illustrator'">
                                    <xsl:text> (Illustrationen)</xsl:text>
                                </xsl:if>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text> </xsl:text>
                        <xsl:if test="not(position() = last())">
                           <br/>
                        </xsl:if>
                    </xsl:for-each>
                </span>
            </div>
            <p/>
            <div>
                
                <xsl:for-each select="child::tei:idno[not(@type = 'schnitzler-tagebuch')]">
                    <xsl:text> </xsl:text>
                    <xsl:choose>
                        <xsl:when test="not(. = '')">
                            <span>
                                <xsl:element name="a">
                                    <xsl:attribute name="class">
                                        <xsl:choose>
                                            <xsl:when test="@type = 'gnd'">
                                                <xsl:text>wikipedia-workbutton</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="@type = 'schnitzler-briefe'">
                                                <xsl:text>briefe-workbutton</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="@type = 'schnitzler-lektueren'">
                                                <xsl:text>leseliste-workbutton</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="@type = 'bahrschnitzler'">
                                                <xsl:text>bahrschnitzler-workbutton</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="@type = 'pmb'">
                                                <xsl:text>pmb-workbutton</xsl:text>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="@type"/>
                                                <xsl:text>XXXX</xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:attribute name="href">
                                        <xsl:choose>
                                            <xsl:when
                                                test="@type = 'pmb' and not(contains(., 'http'))">
                                                <xsl:value-of
                                                  select="concat('https://pmb.acdh.oeaw.ac.at/apis/entities/entity/work/', substring-after(., 'pmb'), '/detail')"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="."/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:attribute>
                                    <xsl:attribute name="target">
                                        <xsl:text>_blank</xsl:text>
                                    </xsl:attribute>
                                    <xsl:element name="span">
                                        <xsl:attribute name="class">
                                            <xsl:value-of select="concat('color-', @type)"/>
                                        </xsl:attribute>
                                        <xsl:value-of select="mam:ahref-namen(@type)"/>
                                    </xsl:element>
                                </xsl:element>
                            </span>
                            <xsl:text> </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="span">
                                <xsl:attribute name="class">
                                    <xsl:text>color-inactive</xsl:text>
                                </xsl:attribute>
                                <xsl:value-of select="mam:ahref-namen(@type)"/>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:if test="position() = last()">
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </xsl:for-each>
                <xsl:if test="starts-with(@xml:id, 'pmb')">
                    <xsl:text> </xsl:text>
                    <xsl:element name="a">
                        <xsl:attribute name="class">
                                    <xsl:text>pmb-workbutton</xsl:text>
                        </xsl:attribute>
                    <xsl:attribute name="href">
                                <xsl:value-of
                                    select="concat('https://pmb.acdh.oeaw.ac.at/apis/entities/entity/work/', substring-after(@xml:id, 'pmb'), '/detail')"
                                />
                    </xsl:attribute>
                        <xsl:element name="span">
                            <xsl:attribute name="class">
                                <xsl:text>color-pmb</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="mam:ahref-namen('pmb')"/>
                        </xsl:element>
                    </xsl:element>
                </xsl:if>
            </div>
            <div id="mentions" class="mt-2">
                <span class="infodesc mr-2">Erwähnt am</span>
                <ul class="list-unstyled">
                    <xsl:for-each select="key('work-day-lookup', @xml:id, $work-day)">
                        <xsl:variable name="linkToDocument">
                            <xsl:value-of select="concat('entry__', data(@target), '.html')"/>
                        </xsl:variable>
                        <xsl:variable name="print_date">
                            <xsl:variable name="monat" select="df:germanNames(format-date(data(@target),'[MNn]'))"/>
                            <xsl:variable name="wochentag" select="df:germanNames(format-date(data(@target),'[F]'))"/>
                            <xsl:variable name="tag" select="concat(format-date(data(@target),'[D]'),'. ')"/>
                            <xsl:variable name="jahr" select="format-date(data(@target),'[Y]')"/>
                            <xsl:value-of select="concat($wochentag, ', ', $tag, $monat, ' ', $jahr)"/>
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
            <xsl:when test="$typityp = 'schnitzler-lektueren'">
                <xsl:text> Lektüren</xsl:text>
            </xsl:when>
            <xsl:when test="$typityp = 'schnitzler-briefe'">
                <xsl:text> Briefe</xsl:text>
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
            <xsl:when test="$typityp = 'bahrschnitzler'">
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
    <xsl:template match="tei:supplied">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>]</xsl:text>
    </xsl:template>
</xsl:stylesheet>
