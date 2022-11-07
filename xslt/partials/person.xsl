<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mam="whatever" version="2.0" xmlns:df="http://example.com/df"
    exclude-result-prefixes="xsl tei xs">
    <xsl:import href="germandate.xsl"/>
    <xsl:import href="LOD-idnos.xsl"/>
    <xsl:param name="works" select="document('../../data/indices/listwork.xml')"/>
    <xsl:key name="authorwork-lookup" match="tei:bibl"
        use="tei:author/@key/replace(replace(., 'person__', ''), 'pmb', '')"/>
    <xsl:template match="tei:person" name="person_detail">
        <xsl:param name="showNumberOfMentions" as="xs:integer" select="50000"/>
        <xsl:variable name="selfLink">
            <xsl:value-of select="concat(data(@xml:id), '.html')"/>
        </xsl:variable>
        <div class="card-body-index">
            <xsl:variable name="lemma-name" select="tei:persName[(position() = 1)]" as="node()"/>
            <xsl:variable name="namensformen" as="node()">
                <xsl:element name="listPerson">
                    <xsl:for-each select="descendant::tei:persName[not(position() = 1)]">
                        <xsl:copy-of select="."/>
                    </xsl:for-each>
                </xsl:element>
            </xsl:variable>
            <div id="mentions">
                <xsl:if test="key('only-relevant-uris', tei:idno/@subtype, $relevant-uris)[1]">
                    <p class="buttonreihe">
                        <xsl:variable name="idnos-of-current" as="node()">
                            <xsl:element name="nodeset_person">
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
            <xsl:for-each select="$namensformen//tei:persName">
                
                <p class="personenname">
                    <xsl:choose>
                        <xsl:when test="descendant::*">
                            <!-- den Fall dürfte es eh nicht geben, aber löschen braucht man auch nicht -->
                            <xsl:choose>
                                <xsl:when test="./tei:forename/text() and ./tei:surname/text()">
                                    <xsl:value-of
                                        select="concat(./tei:forename/text(), ' ', ./tei:surname/text())"
                                    />
                                </xsl:when>
                                <xsl:when test="./tei:forename/text()">
                                    <xsl:value-of select="./tei:forename/text()"/>
                                </xsl:when>
                                <xsl:when test="./tei:surname/text()">
                                    <xsl:value-of select="./tei:surname/text()"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when
                                    test="@type = 'person_geburtsname-vorname' and $namensformen/descendant::tei:persName[@type = 'person_geburtsname_nachname']">
                                    <xsl:text>geboren </xsl:text>
                                    <xsl:value-of
                                        select="concat(., ' ', $namensformen/descendant::tei:persName[@type = 'person_geburtsname_nachname'][1])"
                                    />
                                </xsl:when>
                                <xsl:when
                                    test="@type = 'person_geburtsname-nachname' and $namensformen/descendant::tei:persName[@type = 'person_geburtsname_vorname'][1]"/>
                                <xsl:when test="@type = 'person_adoptierter-nachname'">
                                    <xsl:text>Nachname durch Adoption </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_variante-nachname-vorname'">
                                    <xsl:text>Namensvariante </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_namensvariante'">
                                    <xsl:text>Namensvariante </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_rufname'">
                                    <xsl:text>Rufname </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_pseudonym'">
                                    <xsl:text>Pseudonym </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_ehename'">
                                    <xsl:text>Ehename </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_geschieden'">
                                    <xsl:text>geschieden </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                                <xsl:when test="@type = 'person_verwitwet'">
                                    <xsl:text>verwitwet </xsl:text>
                                    <xsl:value-of select="."/>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </p>
            </xsl:for-each>
            <xsl:if test=".//tei:occupation">
                <xsl:variable name="entity" select="."/>
                <p>
                    <xsl:if test="$entity/descendant::tei:occupation">
                        <i>
                            <xsl:for-each select="$entity/descendant::tei:occupation">
                                <xsl:variable name="beruf" as="xs:string">
                                    <xsl:choose>
                                        <xsl:when test="contains(., '&gt;&gt;')">
                                            <xsl:value-of select="tokenize(., '&gt;&gt;')[last()]"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="."/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="$entity/tei:sex/@value = 'male'">
                                        <xsl:value-of select="tokenize($beruf, '/')[1]"/>
                                    </xsl:when>
                                    <xsl:when test="$entity/tei:sex/@value = 'female'">
                                        <xsl:value-of select="tokenize($beruf, '/')[2]"/>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="$beruf"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="not(position() = last())">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </i>
                    </xsl:if>
                </p>
            </xsl:if>
            
            <div class="werke">
                <xsl:variable name="author-ref"
                    select="replace(replace(@xml:id, 'person__', ''), 'pmb', '')"/>
                <xsl:if test="key('authorwork-lookup', $author-ref, $works)[1]">
                    <span class="infodesc mr-2">
                        <legend>Werke</legend>
                    </span>
                </xsl:if>
                <p/>
                <ul class="dashed">
                    <xsl:for-each select="key('authorwork-lookup', $author-ref, $works)">
                        <li>
                            <xsl:if test="@role = 'editor' or @role = 'hat-herausgegeben'">
                                <xsl:text> (Herausgabe)</xsl:text>
                            </xsl:if>
                            <xsl:if test="@role = 'translator' or @role = 'hat-ubersetzt'">
                                <xsl:text> (Übersetzung)</xsl:text>
                            </xsl:if>
                            <xsl:if test="@role = 'illustrator' or @role = 'hat-illustriert'">
                                <xsl:text> (Illustration)</xsl:text>
                            </xsl:if>
                            <xsl:if test="@role = 'hat-einen-beitrag-geschaffen-zu'">
                                <xsl:text> (Beitrag)</xsl:text>
                            </xsl:if>
                            <xsl:if test="@role = 'hat-ein-vorwortnachwort-verfasst-zu'">
                                <xsl:text> (Vor-/Nachwort)</xsl:text>
                            </xsl:if>
                            <xsl:choose>
                                <xsl:when test="tei:author[2]">
                                    <xsl:for-each
                                        select="tei:author[not(replace(@key, '#', '') = $author-ref)]">
                                        <xsl:choose>
                                            <xsl:when
                                                test="tei:persName/tei:forename and tei:persName/tei:surname">
                                                <xsl:value-of select="tei:persName/tei:forename"/>
                                                <xsl:text> </xsl:text>
                                                <xsl:value-of select="tei:persName/tei:surname"/>
                                            </xsl:when>
                                            <xsl:when test="tei:persName/tei:surname">
                                                <xsl:value-of select="tei:persName/tei:surname"/>
                                            </xsl:when>
                                            <xsl:when test="tei:persName/tei:forename">
                                                <xsl:value-of select="tei:persName/tei:forename"
                                                />"/> </xsl:when>
                                            <xsl:when test="contains(tei:persName, ', ')">
                                                <xsl:value-of
                                                  select="concat(substring-after(tei:persName, ', '), ' ', substring-before(tei:persName, ', '))"
                                                />
                                            </xsl:when>
                                            <xsl:when test="contains(., ', ')">
                                                <xsl:value-of
                                                  select="concat(substring-after(., ', '), ' ', substring-before(., ', '))"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="."/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <xsl:if
                                            test="@role = 'editor' or @role = 'hat-herausgegeben'">
                                            <xsl:text> (Herausgabe)</xsl:text>
                                        </xsl:if>
                                        <xsl:if
                                            test="@role = 'translator' or @role = 'hat-ubersetzt'">
                                            <xsl:text> (Übersetzung)</xsl:text>
                                        </xsl:if>
                                        <xsl:if
                                            test="@role = 'illustrator' or @role = 'hat-illustriert'">
                                            <xsl:text> (Illustration)</xsl:text>
                                        </xsl:if>
                                        <xsl:if test="@role = 'hat-einen-beitrag-geschaffen-zu'">
                                            <xsl:text> (Beitrag)</xsl:text>
                                        </xsl:if>
                                        <xsl:if test="@role = 'hat-ein-vorwortnachwort-verfasst-zu'">
                                            <xsl:text> (Vor-/Nachwort)</xsl:text>
                                        </xsl:if>
                                        <xsl:choose>
                                            <xsl:when test="position() = last()"/>
                                            <xsl:otherwise>
                                                <xsl:text>, </xsl:text>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:for-each>
                                    <xsl:text>: </xsl:text>
                                </xsl:when>
                            </xsl:choose>
                            <xsl:element name="a">
                                <xsl:attribute name="href">
                                    <xsl:value-of select="concat(@xml:id, '.html')"/>
                                </xsl:attribute>
                                <xsl:value-of select="normalize-space(tei:title[1])"/>
                            </xsl:element>
                            <xsl:if test="tei:date[1]">
                                <xsl:text> (</xsl:text>
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
                                <xsl:text>)</xsl:text>
                            </xsl:if>
                            <xsl:text> </xsl:text>
                            <xsl:variable name="idnos-of-current" as="node()">
                                <xsl:element name="nodeset_person">
                                    <xsl:for-each select="tei:idno">
                                        <xsl:copy-of select="."/>
                                    </xsl:for-each>
                                </xsl:element>
                            </xsl:variable>
                            <xsl:call-template name="mam:idnosToLinks">
                                <xsl:with-param name="idnos-of-current" select="$idnos-of-current"/>
                            </xsl:call-template>
                        </li>
                    </xsl:for-each>
                </ul>
            </div>
            <div id="mentions" class="mt-2">
                <span class="infodesc mr-2">
                    <legend>Erwähnungen</legend>
                    <ul>
                        <xsl:for-each select=".//tei:note[@type = 'mentions']">
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
                    <xsl:if
                        test="count(.//tei:note[@type = 'mentions']) gt $showNumberOfMentions + 1">
                        <p>Anzahl der Erwähnungen limitiert, klicke <a href="{$selfLink}">hier</a>
                            für eine vollständige Auflistung</p>
                    </xsl:if>
                </span>
            </div>
        </div>
    </xsl:template>
    <xsl:template match="tei:supplied">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>]</xsl:text>
    </xsl:template>
</xsl:stylesheet>
