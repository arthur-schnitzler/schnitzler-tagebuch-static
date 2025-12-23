<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mam="whatever" version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:import href="./LOD-idnos.xsl"/>
    <xsl:include href="./params.xsl"/>
    <xsl:param name="places" select="document('../../data/indices/listplace.xml')"/>
    <!-- nur fürs Schnitzler-Tagebuch die folgenden beiden Einbindungen -->
    <xsl:param name="listperson" select="document('../../data/indices/listperson.xml')"/>
    <xsl:key name="author-lookup" match="tei:person" use="tei:idno[@subtype = 'pmb']"/>
    <!-- Korrespondenzen (nur für schnitzler-briefe) -->
    <xsl:variable name="listcorrespondencePath" select="'../../data/indices/listcorrespondence.xml'"/>
    <xsl:param name="listcorrespondence" select="
            if (unparsed-text-available($listcorrespondencePath))
            then
                document($listcorrespondencePath)
            else
                ()"/>
    <xsl:key name="correspondence-lookup" match="tei:personGrp[not(@ana='planned') and not(@xml:id='correspondence_null')]" use="tei:persName[@role='main'][1]/@ref"/>
    <xsl:variable name="listbiblPath" select="'../../data/indices/listbibl.xml'"/>
    <xsl:variable name="listworkPath" select="'../../data/indices/listwork.xml'"/>
    <xsl:param name="events"
        select="document('../../data/editions/listevent.xml')/descendant::tei:listEvent[1]"/>
    <xsl:variable name="actualFilePath" select="
            if (unparsed-text-available($listbiblPath))
            then
                $listbiblPath
            else
                $listworkPath"/>
    <xsl:param name="works" select="document($actualFilePath)"/>
    <xsl:key name="work-lookup" match="tei:bibl" use="tei:relatedItem/@target"/>
    <xsl:key name="only-relevant-uris" match="item" use="abbr"/>
    <xsl:key name="authorwork-lookup" match="tei:bibl"
        use="tei:author/@*[name() = 'key' or name() = 'ref']"/>
    <!--  -->
    <xsl:param name="konkordanz" select="document('../../data/indices/index_person_day.xml')"/>
    <xsl:param name="work-day" select="document('../../data/indices/index_work_day.xml')"/>
    <xsl:key name="konk-lookup" match="item" use="ref"/>
    <xsl:key name="work-lookup" match="tei:bibl" use="tei:relatedItem/@target"/>
    <xsl:key name="work-day-lookup" match="item" use="ref"/>
    <xsl:key name="only-relevant-uris" match="item" use="abbr"/>
    <!-- Schnitzler-Lektüren -->
    <xsl:param name="lektueren-konkordanz" select="document('../../data/indices/konkordanz.xml')"/>
    <xsl:key name="lektueren-konk-lookup" match="ref" use="@xml:id"/>
    <!-- PERSON -->
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
            <xsl:choose>
                <xsl:when test="tei:figure/tei:graphic/@url">
                    <div class="WikimediaContainer">
                        <!-- Left div -->
                        <div class="WikimediaLeft-div">
                            <xsl:element name="figure">
                                <xsl:variable name="imageUrl" select="tei:figure/tei:graphic/@url"/>
                                <!-- Create an <img> element with the extracted URL -->
                                <img src="{$imageUrl}" alt="Image" width="200px;"/>
                            </xsl:element>
                        </div>
                        <!-- Right div -->
                        <div class="WikimediaRight-div">
                            <!-- Achtung, der Teil kommt zweimal, einmal mit Bild auf der Seite, einmal ohne -->
                            <xsl:for-each select="$namensformen/descendant::tei:persName">
                                <p class="personenname">
                                    <xsl:choose>
                                        <xsl:when test="descendant::*">
                                            <!-- den Fall dürfte es eh nicht geben, aber löschen braucht man auch nicht -->
                                            <xsl:choose>
                                                <xsl:when
                                                  test="./tei:forename/text() and ./tei:surname/text()">
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
                                                  test="@type = 'person_geburtsname_vorname' and $namensformen/descendant::tei:persName[@type = 'person_geburtsname_nachname']">
                                                  <xsl:text>geboren </xsl:text>
                                                  <xsl:value-of
                                                  select="concat(., ' ', $namensformen/descendant::tei:persName[@type = 'person_geburtsname_nachname'][1])"
                                                  />
                                                </xsl:when>
                                                <xsl:when
                                                  test="@type = 'person_geburtsname_vorname'">
                                                  <xsl:text>geboren </xsl:text>
                                                  <xsl:value-of
                                                  select="concat(., ' ', $lemma-name//tei:surname)"
                                                  />
                                                </xsl:when>
                                                <xsl:when
                                                  test="@type = 'person_geburtsname_nachname' and $namensformen/descendant::tei:persName[@type = 'person_geburtsname_vorname'][1]"/>
                                                <xsl:when
                                                  test="@type = 'person_geburtsname_nachname'">
                                                  <xsl:text>geboren </xsl:text>
                                                  <xsl:value-of select="."/>
                                                </xsl:when>
                                                <xsl:when
                                                  test="@type = 'person_adoptierter-nachname'">
                                                  <xsl:text>Nachname durch Adoption </xsl:text>
                                                  <xsl:value-of select="."/>
                                                </xsl:when>
                                                <xsl:when
                                                  test="@type = 'person_namensvariante-nachname'">
                                                  <xsl:text>Namensvariante Nachame </xsl:text>
                                                  <xsl:value-of select="."/>
                                                </xsl:when>
                                                <xsl:when
                                                  test="@type = 'person_namensvariante-vorname'">
                                                  <xsl:text>Namensvariante Vorname </xsl:text>
                                                  <xsl:value-of select="."/>
                                                </xsl:when>
                                                <xsl:when test="@type = 'person_namensvariante'">
                                                  <xsl:text>Namensvariante </xsl:text>
                                                  <xsl:value-of select="."/>
                                                </xsl:when>
                                                <xsl:when test="@type = 'person_rufname_vorname'">
                                                  <xsl:text>Rufname </xsl:text>
                                                  <xsl:value-of select="."/>
                                                </xsl:when>
                                                <xsl:when test="@type = 'person_pseudonym'">
                                                  <xsl:text>Pseudonym </xsl:text>
                                                  <xsl:value-of select="."/>
                                                </xsl:when>
                                                <xsl:when test="@type = 'person_ehename_nachname'">
                                                  <xsl:text>Ehename </xsl:text>
                                                  <xsl:value-of select="."/>
                                                </xsl:when>
                                                <xsl:when
                                                  test="@type = 'person_geschieden_nachname'">
                                                  <xsl:text>geschieden </xsl:text>
                                                  <xsl:value-of select="."/>
                                                </xsl:when>
                                                <xsl:when test="@type = 'person_verwitwet_nachname'">
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
                                            <xsl:for-each
                                                select="$entity/descendant::tei:occupation">
                                                <xsl:variable name="beruf" as="xs:string">
                                                  <xsl:choose>
                                                  <xsl:when test="contains(., '&gt;&gt;')">
                                                  <xsl:value-of
                                                  select="tokenize(., '&gt;&gt;')[last()]"/>
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
                        </div>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <div>
                        <xsl:for-each select="$namensformen/descendant::tei:persName">
                            <p class="personenname">
                                <xsl:choose>
                                    <xsl:when test="descendant::*">
                                        <!-- den Fall dürfte es eh nicht geben, aber löschen braucht man auch nicht -->
                                        <xsl:choose>
                                            <xsl:when
                                                test="./tei:forename/text() and ./tei:surname/text()">
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
                                                test="@type = 'person_geburtsname_vorname' and $namensformen/descendant::tei:persName[@type = 'person_geburtsname_nachname']">
                                                <xsl:text>geboren </xsl:text>
                                                <xsl:value-of
                                                  select="concat(., ' ', $namensformen/descendant::tei:persName[@type = 'person_geburtsname_nachname'][1])"
                                                />
                                            </xsl:when>
                                            <xsl:when
                                                test="@type = 'person_geburtsname_nachname' and $namensformen/descendant::tei:persName[@type = 'person_geburtsname_vorname'][1]"/>
                                            <xsl:when test="@type = 'person_geburtsname_nachname'">
                                                <xsl:text>geboren </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:when>
                                            <xsl:when test="@type = 'person_adoptierter-nachname'">
                                                <xsl:text>Nachname durch Adoption </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:when>
                                            <xsl:when
                                                test="@type = 'person_namensvariante-nachname'">
                                                <xsl:text>Namensvariante Nachame </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:when>
                                            <xsl:when test="@type = 'person_namensvariante-vorname'">
                                                <xsl:text>Namensvariante Vorname </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:when>
                                            <xsl:when test="@type = 'person_namensvariante'">
                                                <xsl:text>Namensvariante </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:when>
                                            <xsl:when test="@type = 'person_rufname_vorname'">
                                                <xsl:text>Rufname </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:when>
                                            <xsl:when test="@type = 'person_pseudonym'">
                                                <xsl:text>Pseudonym </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:when>
                                            <xsl:when test="@type = 'person_ehename_nachname'">
                                                <xsl:text>Ehename </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:when>
                                            <xsl:when test="@type = 'person_geschieden_nachname'">
                                                <xsl:text>geschieden </xsl:text>
                                                <xsl:value-of select="."/>
                                            </xsl:when>
                                            <xsl:when test="@type = 'person_verwitwet_nachname'">
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
                                                  <xsl:value-of
                                                  select="tokenize(., '&gt;&gt;')[last()]"/>
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
                    </div>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:variable name="idnos" as="node()">
                <xsl:element name="idnos">
                    <xsl:copy-of select="tei:idno"/>
                </xsl:element>
            </xsl:variable>
            <xsl:call-template name="lod-reihe">
                <xsl:with-param name="idno" select="$idnos"/>
            </xsl:call-template>
            <xsl:if test="$current-edition = 'schnitzler-briefe'">
                <xsl:variable name="person-ref" as="xs:string">
                    <xsl:value-of select="concat('#pmb', replace(replace(@xml:id, 'person__', ''), 'pmb', ''))"/>
                </xsl:variable>
                <xsl:variable name="correspondence" select="key('correspondence-lookup', $person-ref, $listcorrespondence)"/>
                <xsl:if test="$correspondence">
                    <div class="korrespondenz">
                        <legend>Korrespondenz</legend>
                        <ul class="dashed">
                            <li>
                                <a>
                                    <xsl:attribute name="href">
                                        <xsl:value-of select="concat('toc_', replace($correspondence/@xml:id, 'correspondence_', ''), '.html')"/>
                                    </xsl:attribute>
                                    <xsl:text>Zum Briefwechsel Schnitzler – </xsl:text>
                                    <xsl:value-of select="$lemma-name"/>
                                </a>
                            </li>
                        </ul>
                    </div>
                </xsl:if>
            </xsl:if>
            <div class="werke">
                <xsl:variable name="author-ref" as="xs:string">
                    <xsl:choose>
                        <xsl:when test="$current-edition = 'schnitzler-tagebuch'">
                            <xsl:value-of
                                select="replace(concat('pmb', tei:idno[@subtype = 'pmb'][1]/substring-after(., 'https://pmb.acdh.oeaw.ac.at/entity/')), '/', '')"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of
                                select="concat('pmb', replace(replace(@xml:id, 'person__', ''), 'pmb', ''))"/>
                            <!-- etwas redundant, aber sicher ist sicherer -->
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:if test="key('authorwork-lookup', $author-ref, $works)[1]">
                    <legend>Werke</legend>
                    <ul class="dashed">
                        <xsl:for-each select="key('authorwork-lookup', $author-ref, $works)">
                            <xsl:sort select="descendant::tei:date[1]"/>
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
                                            select="tei:author[not(replace(@*[name() = 'key' or name() = 'ref'], '#', '') = $author-ref)]">
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
                                            <xsl:if
                                                test="@role = 'hat-ein-vorwortnachwort-verfasst-zu'">
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
                                <xsl:if test="tei:date[not(. = 'None')][1]">
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
                                <!--<xsl:text> </xsl:text>
                            <xsl:variable name="idnos-of-current" as="node()">
                                <xsl:element name="nodeset_person">
                                    <xsl:for-each select="tei:idno">
                                        <xsl:copy-of select="."/>
                                    </xsl:for-each>
                                </xsl:element>
                            </xsl:variable>
                            <xsl:call-template name="mam:idnosToLinks">
                                <xsl:with-param name="idnos-of-current" select="$idnos-of-current"/>
                            </xsl:call-template>-->
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                <xsl:if test="$current-edition = 'schnitzler-lektueren'">
                    <p class="text-center">
                        <xsl:variable name="link"
                            select="key('lektueren-konk-lookup', @xml:id, $lektueren-konkordanz)[1]/@target"/>
                        <a href="{concat($link, '#', @xml:id)}"
                            style="display: inline-block; background-color: #022954; color: white; padding: 0.5em 1em; border-radius: 0.25rem; text-decoration: none;"
                            > Zur Leseliste </a>
                    </p>
                </xsl:if>
            </div>
            <xsl:choose>
                <xsl:when test="$current-edition = 'schnitzler-kultur'">
                    <xsl:variable name="notes" as="node()">
                        <xsl:call-template name="fill-event-variable">
                            <xsl:with-param name="xmlid" select="@xml:id"/>
                            <xsl:with-param name="entitityType" select="'persName'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:call-template name="list-all-mentions">
                        <xsl:with-param name="mentions" select="$notes"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test=".//tei:note[@type = 'mentions'][1]">
                    <xsl:variable name="mentionsGrp">
                        <xsl:element name="noteGrp" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:copy-of select="descendant::tei:note[@type = 'mentions']"/>
                        </xsl:element>
                    </xsl:variable>
                    <xsl:call-template name="list-all-mentions">
                        <xsl:with-param name="mentions" select="$mentionsGrp"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- hier ließe sich eine Fehlermeldung ausgeben -->
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <xsl:template name="fill-event-variable" as="node()">
        <xsl:param name="xmlid" as="xs:string"/>
        <xsl:param name="entitityType" as="xs:string"/>
        <xsl:variable name="matchingEvents"
            select="$events/tei:event[descendant::*[name() = $entitityType]/@key = $xmlid]"/>
        <xsl:element name="noteGrp" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:for-each select="$matchingEvents">
                <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type">
                        <xsl:text>mentions</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="target">
                        <xsl:value-of select="@xml:id"/>
                    </xsl:attribute>
                    <xsl:attribute name="corresp">
                        <xsl:value-of select="@when-iso"/>
                    </xsl:attribute>
                    <xsl:value-of select="tei:eventName"/>
                </xsl:element>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <!-- WORK / WERKE -->
    <xsl:template match="tei:listBibl/tei:bibl" name="work_detail">
        <xsl:param name="showNumberOfMentions" as="xs:integer" select="50000"/>
        <xsl:variable name="selfLink">
            <xsl:value-of select="concat(data(@xml:id), '.html')"/>
        </xsl:variable>
        <div class="card-body-index">
            <xsl:variable name="idnos" as="node()">
                <xsl:element name="idnos">
                    <xsl:copy-of select="tei:idno"/>
                </xsl:element>
            </xsl:variable>
            <xsl:call-template name="lod-reihe">
                <xsl:with-param name="idno" select="$idnos"/>
            </xsl:call-template>
            <xsl:if test="tei:author">
                <div id="autor_innen">
                    <legend>Geschaffen von</legend>
                    <xsl:for-each select="tei:author">
                        <ul class="dashed">
                            <li>
                                <xsl:variable name="keyToRef" as="xs:string">
                                    <xsl:choose>
                                        <xsl:when test="@key != ''">
                                            <xsl:value-of select="@key"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="@ref"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:variable name="autor-ref" as="xs:string">
                                    <xsl:choose>
                                        <xsl:when test="contains($keyToRef, 'person__')">
                                            <xsl:value-of
                                                select="concat('pmb', substring-after($keyToRef, 'person__'))"
                                            />
                                        </xsl:when>
                                        <xsl:when test="starts-with($keyToRef, 'pmb')">
                                            <xsl:value-of select="$keyToRef"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="concat('pmb', $keyToRef)"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when
                                        test="$autor-ref = 'pmb2121' and $current-edition = 'schnitzler-tagebuch'">
                                        <xsl:text>Arthur Schnitzler</xsl:text>
                                    </xsl:when>
                                    <xsl:when test="$autor-ref = 'pmb2121'">
                                        <a href="pmb2121.html">
                                            <xsl:text>Arthur Schnitzler</xsl:text>
                                        </a>
                                    </xsl:when>
                                    <xsl:when test="$current-edition = 'schnitzler-tagebuch'">
                                        <xsl:variable name="author-lookup-mit-schraegstrich"
                                            select="
                                                key('author-lookup', concat('https://pmb.acdh.oeaw.ac.at/entity/', replace($autor-ref, 'pmb', ''), '/'),
                                                $listperson)/tei:idno[@subtype = 'schnitzler-tagebuch' or @type = 'schnitzler-tagebuch'][1]/substring-after(., 'https://schnitzler-tagebuch.acdh.oeaw.ac.at/')"/>
                                        <xsl:variable name="autor-ref-schnitzler-tagebuch">
                                            <xsl:choose>
                                                <xsl:when
                                                  test="$author-lookup-mit-schraegstrich != ''">
                                                  <xsl:value-of
                                                  select="$author-lookup-mit-schraegstrich"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="(key('author-lookup', concat('https://pmb.acdh.oeaw.ac.at/entity/', $autor-ref), $listperson)/tei:idno[@subtype = 'schnitzler-tagebuch' or @type = 'schnitzler-tagebuch'][1]/substring-after(., 'https://schnitzler-tagebuch.acdh.oeaw.ac.at/'))"
                                                  />
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:variable>
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of
                                                  select="$autor-ref-schnitzler-tagebuch"/>
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
                                            <xsl:when test="@role = 'hat-anonym-veroffentlicht'">
                                                <xsl:text> (ohne Namensnennung)</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="@role = 'bekommt-zugeschrieben'">
                                                <xsl:text> (Zuschreibung)</xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <a>
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="concat($autor-ref, '.html')"/>
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
                                            <xsl:when test="@role = 'hat-anonym-veroffentlicht'">
                                                <xsl:text> (ohne Namensnennung)</xsl:text>
                                            </xsl:when>
                                            <xsl:when test="@role = 'bekommt-zugeschrieben'">
                                                <xsl:text> (Zuschreibung)</xsl:text>
                                            </xsl:when>
                                        </xsl:choose>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </li>
                        </ul>
                    </xsl:for-each>
                </div>
                <div id="erscheinungsdatum" class="mt-2">
                    <p>
                        <xsl:if test="tei:date[1]">
                            <legend>Erschienen</legend>
                            <ul class="dashed">
                                <li>
                                    <xsl:choose>
                                        <xsl:when test="contains(tei:date[1], '-')">
                                            <xsl:choose>
                                                <xsl:when
                                                  test="normalize-space(tokenize(tei:date[1], '-')[1]) = normalize-space(tokenize(tei:date[1], '-')[2])">
                                                  <xsl:value-of
                                                  select="mam:normalize-date(normalize-space((tokenize(tei:date[1], '-')[1])))"
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
                                </li>
                            </ul>
                        </xsl:if>
                    </p>
                </div>
                <p/>
            </xsl:if>
            <xsl:if
                test="tei:title[@type = 'werk_bibliografische-angabe' or starts-with(@type, 'werk_link')]">
                <div id="labels" class="mt-2">
                    <span class="infodesc mr-2">
                        <ul class="dashed">
                            <xsl:for-each select="tei:title[@type = 'werk_bibliografische-angabe']">
                                <li>
                                    <xsl:text>Bibliografische Angabe: </xsl:text>
                                    <xsl:value-of select="."/>
                                </li>
                            </xsl:for-each>
                            <xsl:for-each select="tei:title[@type = 'werk_link' or @type = 'anno']">
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
            <xsl:choose>
                <xsl:when test="$current-edition = 'schnitzler-kultur'">
                    <xsl:variable name="notes" as="node()">
                        <xsl:call-template name="fill-event-variable">
                            <xsl:with-param name="xmlid" select="@xml:id"/>
                            <xsl:with-param name="entitityType" select="'title'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:call-template name="list-all-mentions">
                        <xsl:with-param name="mentions" select="$notes"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test=".//tei:note[@type = 'mentions'][1]">
                    <xsl:variable name="mentionsGrp">
                        <xsl:element name="noteGrp" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:copy-of select="descendant::tei:note[@type = 'mentions']"/>
                        </xsl:element>
                    </xsl:variable>
                    <xsl:call-template name="list-all-mentions">
                        <xsl:with-param name="mentions" select="$mentionsGrp"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- hier ließe sich eine Fehlermeldung ausgeben -->
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <!-- PLACE -->
    <xsl:template match="tei:place" name="place_detail">
        <xsl:param name="showNumberOfMentions" as="xs:integer" select="50000"/>
        <xsl:variable name="selfLink">
            <xsl:value-of select="concat(data(@xml:id), '.html')"/>
        </xsl:variable>
        <div class="container-fluid">
            <div class="card-body-index">
                <xsl:variable name="idnos" as="node()">
                    <xsl:element name="idnos">
                        <xsl:copy-of select="tei:idno"/>
                    </xsl:element>
                </xsl:variable>
                <xsl:call-template name="lod-reihe">
                    <xsl:with-param name="idno" select="$idnos"/>
                </xsl:call-template>
                <xsl:if test=".//tei:geo/text()">
                    <div id="mapid" style="height: 400px; width:100%; clear: both;"> </div>
                    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css"
                        integrity="sha512-xodZBNTC5n17Xt2atTPuE1HxjVMSvLVW9ocqUKLsCC5CXdbqCmblAshOMAS6/keqq/sMZMZ19scR4PsZChSR7A=="
                        crossorigin=""/>
                    <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js" integrity="sha512-XQoYMqMTK8LvdxXYG3nZ448hOEQiglfqkJs1NOQV44cWnUrBc8PkAOcXy20w0vlaXaVUearIOBhiXZ5V3ynxwA==" crossorigin=""/>
                    <script>
                        <xsl:variable name="laenge" select="replace(tokenize(descendant::tei:geo[1]/text(), ' ')[2], ',', '.')"/>
                        <xsl:variable name="breite" select="replace(tokenize(descendant::tei:geo[1]/text(), ' ')[1], ',', '.')"/>
                        
                        var mymap = L.map('mapid').setView([<xsl:value-of select="$breite"/>, <xsl:value-of select="$laenge"/>], 14);
                        
                        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                        attribution: 'Map data © <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors',
                        maxZoom: 18
                        }).addTo(mymap);
                        
                        L.marker([<xsl:value-of select="$breite"/>, <xsl:value-of select="$laenge"/>])
                        .addTo(mymap)
                        .bindPopup("<b><xsl:value-of select="./tei:placeName[1]/text()"/></b>")
                        .openPopup();
                    </script>
                </xsl:if>
                <xsl:if test="count(.//tei:placeName[contains(@type, 'namensvariante')]) gt 1">
                    <legend>Namensvarianten</legend>
                    <ul class="dashed">
                        <xsl:for-each select=".//tei:placeName[contains(@type, 'namensvariante')]">
                            <li>
                                <xsl:value-of select="./text()"/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="$current-edition = 'schnitzler-kultur'">
                        <xsl:variable name="notes" as="node()">
                            <xsl:call-template name="fill-event-variable">
                                <xsl:with-param name="xmlid" select="@xml:id"/>
                                <xsl:with-param name="entitityType" select="'placeName'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="list-all-mentions">
                            <xsl:with-param name="mentions" select="$notes"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:when test=".//tei:note[@type = 'mentions'][1]">
                        <xsl:variable name="mentionsGrp">
                            <xsl:element name="noteGrp" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:copy-of select="descendant::tei:note[@type = 'mentions']"/>
                            </xsl:element>
                        </xsl:variable>
                        <xsl:call-template name="list-all-mentions">
                            <xsl:with-param name="mentions" select="$mentionsGrp"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- hier ließe sich eine Fehlermeldung ausgeben -->
                    </xsl:otherwise>
                </xsl:choose>
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
    <!-- ORG -->
    <xsl:key name="place-lookup" match="tei:place" use="@xml:id"/>
    <xsl:template match="tei:org" name="org_detail">
        <xsl:param name="showNumberOfMentions" as="xs:integer" select="50000"/>
        <xsl:variable name="selfLink">
            <xsl:value-of select="concat(data(@xml:id), '.html')"/>
        </xsl:variable>
        <div class="card-body-index">
            <xsl:variable name="idnos" as="node()">
                <xsl:element name="idnos">
                    <xsl:copy-of select="tei:idno"/>
                </xsl:element>
            </xsl:variable>
            <xsl:call-template name="lod-reihe">
                <xsl:with-param name="idno" select="$idnos"/>
            </xsl:call-template>
            <xsl:variable name="ersterName" select="tei:orgName[1]"/>
            <xsl:if test="tei:orgName[2]">
                <p>
                    <xsl:for-each
                        select="distinct-values(tei:orgName[@type = 'ort_alternative-name'])">
                        <xsl:if test=". != $ersterName">
                            <xsl:value-of select="."/>
                        </xsl:if>
                        <xsl:if test="not(position() = last())">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </p>
            </xsl:if>
            <xsl:if test="tei:location">
                <div>
                    <legend>Orte</legend>
                    <ul class="dashed">
                        <li>
                            <xsl:for-each
                                select="tei:location/tei:placeName[not(. = preceding-sibling::tei:placeName)]">
                                <xsl:variable name="key-or-ref" as="xs:string?">
                                    <xsl:value-of
                                        select="concat(replace(@key, 'place__', 'pmb'), replace(@ref, 'place__', 'pmb'))"
                                    />
                                </xsl:variable>
                                <xsl:choose>
                                    <xsl:when test="key('place-lookup', $key-or-ref, $places)">
                                        <xsl:element name="a">
                                            <xsl:attribute name="href">
                                                <xsl:value-of select="concat($key-or-ref, '.html')"
                                                />
                                            </xsl:attribute>
                                            <xsl:value-of select="."/>
                                        </xsl:element>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of select="."/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                <xsl:if test="not(position() = last())">
                                    <xsl:text>, </xsl:text>
                                </xsl:if>
                            </xsl:for-each>
                        </li>
                    </ul>
                </div>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$current-edition = 'schnitzler-kultur'">
                    <xsl:variable name="notes" as="node()">
                        <xsl:call-template name="fill-event-variable">
                            <xsl:with-param name="xmlid" select="@xml:id"/>
                            <xsl:with-param name="entitityType" select="'orgName'"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:call-template name="list-all-mentions">
                        <xsl:with-param name="mentions" select="$notes"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:when test=".//tei:note[@type = 'mentions'][1]">
                    <xsl:variable name="mentionsGrp">
                        <xsl:element name="noteGrp" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:copy-of select="descendant::tei:note[@type = 'mentions']"/>
                        </xsl:element>
                    </xsl:variable>
                    <xsl:call-template name="list-all-mentions">
                        <xsl:with-param name="mentions" select="$mentionsGrp"/>
                    </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                    <!-- hier ließe sich eine Fehlermeldung ausgeben -->
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <!-- EVENT -->
    <xsl:template match="tei:event" name="event_detail">
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
                <xsl:variable name="xmlid" select="@xml:id"/>
                <table class="table entity-table mx-auto" style="max-width=800px">
                    <tbody>
                        <tr>
                            <th> Datum </th>
                            <td>
                                <ul>
                                    <li>
                                        <xsl:choose>
                                            <xsl:when test="@from-iso and @to-iso">
                                                <xsl:value-of select="mam:wochentag(@from-iso)"/>
                                                <xsl:text>, </xsl:text>
                                                <xsl:value-of
                                                  select="format-date(@from-iso, '[D1]. ')"/>
                                                <xsl:value-of select="mam:monat(@from-iso)"/>
                                                <xsl:value-of
                                                  select="format-date(@from-iso, ' [Y]')"/>
                                                <xsl:text> bis </xsl:text>
                                                <xsl:value-of select="mam:wochentag(@to-iso)"/>
                                                <xsl:text>, </xsl:text>
                                                <xsl:value-of
                                                  select="format-date(@to-iso, '[D1]. ')"/>
                                                <xsl:value-of select="mam:monat(@to-iso)"/>
                                                <xsl:value-of select="format-date(@to-iso, ' [Y]')"
                                                />
                                            </xsl:when>
                                            <xsl:when
                                                test="(@from-iso = '' or not(@from-iso)) and @to-iso">
                                                <xsl:text>bis </xsl:text>
                                                <xsl:value-of select="mam:wochentag(@to-iso)"/>
                                                <xsl:text>, </xsl:text>
                                                <xsl:value-of
                                                  select="format-date(@to-iso, '[D1]. ')"/>
                                                <xsl:value-of select="mam:monat(@to-iso)"/>
                                                <xsl:value-of select="format-date(@to-iso, ' [Y]')"
                                                />
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:value-of select="mam:wochentag(@when-iso)"/>
                                                <xsl:text>, </xsl:text>
                                                <xsl:value-of
                                                  select="format-date(@when-iso, '[D1]. ')"/>
                                                <xsl:value-of select="mam:monat(@when-iso)"/>
                                                <xsl:value-of
                                                  select="format-date(@when-iso, ' [Y]')"/>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </li>
                                </ul>
                            </td>
                        </tr>
                        <tr>
                            <th>Veranstaltungsort</th>
                            <td>
                                <ul>
                                    <xsl:for-each select="tei:listPlace/tei:place">
                                        <li>
                                            <!-- Link zum Ort -->
                                            <xsl:element name="a">
                                                <xsl:attribute name="target">_blank</xsl:attribute>
                                                <xsl:attribute name="href">
                                                  <xsl:value-of
                                                  select="concat(tei:placeName/@key, '.html')"/>
                                                </xsl:attribute>
                                                <xsl:value-of
                                                  select="normalize-space(tei:placeName)"/>
                                            </xsl:element>
                                            <!-- Karte & OSM-Link -->
                                            <xsl:if test="./tei:location/tei:geo">
                                                <!-- Karte -->
                                                <div id="map_detail"
                                                  style="height: 250px; width: 475px;"/>
                                                <!-- Koordinaten vorbereiten -->
                                                <xsl:variable name="mlat"
                                                  select="replace(tokenize(./tei:location[1]/tei:geo[1], '\s')[1], ',', '.')"/>
                                                <xsl:variable name="mlong"
                                                  select="replace(tokenize(./tei:location[1]/tei:geo[1], '\s')[2], ',', '.')"/>
                                                <xsl:variable name="mappin"
                                                  select="concat('mlat=', $mlat, '&amp;mlon=', $mlong)"
                                                  as="xs:string"/>
                                                <xsl:variable name="openstreetmapurl"
                                                  select="concat('https://www.openstreetmap.org/?', $mappin, '#map=12/', $mlat, '/', $mlong)"/>
                                                <!-- OSM-Link klein und rechtsbündig -->
                                                <div class="text-end" style="width: 475px;">
                                                  <a class="small d-block mt-1" target="_blank">
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of select="$openstreetmapurl"/>
                                                  </xsl:attribute>
                                                  <i class="bi bi-box-arrow-up-right"/>
                                                  OpenStreetMap </a>
                                                </div>
                                            </xsl:if>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </td>
                        </tr>
                        <xsl:if
                            test="tei:listBibl/tei:bibl/tei:title[not(tei:note[contains(., 'rezensi')])]">
                            <tr>
                                <th>Aufgeführte Werke</th>
                                <td>
                                    <ul>
                                        <xsl:for-each
                                            select="tei:listBibl/tei:bibl[not(tei:note[contains(., 'rezensi')]) and normalize-space(tei:title)]">
                                            <li>
                                                <xsl:element name="a">
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of
                                                  select="concat(tei:title/@key, '.html')"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of select="normalize-space(tei:title)"
                                                  />
                                                </xsl:element>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </td>
                            </tr>
                        </xsl:if>
                        <xsl:if
                            test="tei:listBibl/tei:bibl/tei:title[(tei:note[contains(., 'rezensi')])]">
                            <tr>
                                <th>Rezensionen</th>
                                <td>
                                    <ul>
                                        <xsl:for-each
                                            select="tei:listBibl/tei:bibl[(tei:note[contains(., 'rezensi')]) and normalize-space(tei:title)]">
                                            <li>
                                                <xsl:element name="a">
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of
                                                  select="concat(tei:title/@key, '.html')"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of select="normalize-space(tei:title)"
                                                  />
                                                </xsl:element>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </td>
                            </tr>
                        </xsl:if>
                        <xsl:if test="tei:listPerson/tei:person[@role = 'hat als Arbeitskraft']">
                            <tr>
                                <th>Arbeitskräfte</th>
                                <td>
                                    <ul>
                                        <xsl:for-each
                                            select="tei:listPerson/tei:person[@role = 'hat als Arbeitskraft']">
                                            <li>
                                                <xsl:variable name="name" select="tei:persName"/>
                                                <xsl:choose>
                                                  <!-- Wenn genau ein Komma enthalten ist -->
                                                  <xsl:when
                                                  test="matches($name, '^[^,]+,\s*[^,]+$')">
                                                  <xsl:element name="a">
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of select="concat($name/@key, '.html')"
                                                  />
                                                  </xsl:attribute>
                                                  <xsl:analyze-string select="$name"
                                                  regex="^([^,]+),\s*(.+)$">
                                                  <xsl:matching-substring>
                                                  <xsl:value-of select="regex-group(2)"/>
                                                  <xsl:text> </xsl:text>
                                                  <xsl:value-of select="regex-group(1)"/>
                                                  </xsl:matching-substring>
                                                  <xsl:non-matching-substring>
                                                  <xsl:value-of select="."/>
                                                  </xsl:non-matching-substring>
                                                  </xsl:analyze-string>
                                                  </xsl:element>
                                                  </xsl:when>
                                                  <!-- Wenn kein oder mehr als ein Komma enthalten ist -->
                                                  <xsl:otherwise>
                                                  <xsl:element name="a">
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of select="concat($name/@key, '.html')"
                                                  />
                                                  </xsl:attribute>
                                                  <xsl:value-of select="$name"/>
                                                  </xsl:element>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </td>
                            </tr>
                        </xsl:if>
                        <tr>
                            <th>Teilnehmende</th>
                            <td>
                                <ul>
                                    <xsl:for-each
                                        select="tei:listPerson/tei:person[@role = 'hat als Teilnehmer:in']">
                                        <li>
                                            <xsl:variable name="name" select="tei:persName"/>
                                            <xsl:choose>
                                                <!-- Wenn genau ein Komma enthalten ist -->
                                                <xsl:when test="matches($name, '^[^,]+,\s*[^,]+$')">
                                                  <xsl:element name="a">
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of select="concat($name/@key, '.html')"
                                                  />
                                                  </xsl:attribute>
                                                  <xsl:analyze-string select="$name"
                                                  regex="^([^,]+),\s*(.+)$">
                                                  <xsl:matching-substring>
                                                  <xsl:value-of select="regex-group(2)"/>
                                                  <xsl:text> </xsl:text>
                                                  <xsl:value-of select="regex-group(1)"/>
                                                  </xsl:matching-substring>
                                                  <xsl:non-matching-substring>
                                                  <xsl:value-of select="."/>
                                                  </xsl:non-matching-substring>
                                                  </xsl:analyze-string>
                                                  </xsl:element>
                                                </xsl:when>
                                                <!-- Wenn kein oder mehr als ein Komma enthalten ist -->
                                                <xsl:otherwise>
                                                  <xsl:element name="a">
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of select="concat($name/@key, '.html')"
                                                  />
                                                  </xsl:attribute>
                                                  <xsl:value-of select="$name"/>
                                                  </xsl:element>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </td>
                        </tr>
                        <xsl:if test="descendant::tei:listOrg">
                            <tr>
                                <th>Beteiligte Institution</th>
                                <td>
                                    <ul>
                                        <xsl:for-each
                                            select="tei:note[@type = 'listorg']/tei:listOrg/tei:org">
                                            <li>
                                                <xsl:element name="a">
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of
                                                  select="concat(tei:orgName/@key, '.html')"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of select="tei:orgName"/>
                                                </xsl:element>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </td>
                            </tr>
                        </xsl:if>
                        <xsl:if
                            test="(descendant::tei:placeName/@key = 'pmb14' or descendant::tei:placeName/@key = 'pmb185621') and not(contains(tei:eventName/@n, 'robe'))">
                            <tr>
                                <th>Theaterzettel</th>
                                <td>
                                    <ul>
                                        <li>
                                            <a>
                                                <xsl:attribute name="target">
                                                  <xsl:text>_blank</xsl:text>
                                                </xsl:attribute>
                                                <xsl:attribute name="href">
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="year-from-date(@when-iso) &lt; 1899">
                                                  <xsl:value-of
                                                  select="concat('https://anno.onb.ac.at/cgi-content/anno?aid=wtz&amp;datum=', replace(@when-iso, '-', ''))"
                                                  />
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="concat('https://anno.onb.ac.at/cgi-content/anno?aid=bth&amp;datum=', replace(@when-iso, '-', ''))"
                                                  />
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </xsl:attribute>
                                                <xsl:text>ANNO</xsl:text>
                                            </a>
                                        </li>
                                    </ul>
                                </td>
                            </tr>
                        </xsl:if>
                        <tr>
                            <th>Tageszeitungen</th>
                            <td>
                                <ul>
                                    <li>
                                        <a>
                                            <xsl:attribute name="target">
                                                <xsl:text>_blank</xsl:text>
                                            </xsl:attribute>
                                            <xsl:attribute name="href">
                                                <xsl:value-of
                                                  select="concat('https://anno.onb.ac.at/cgi-content/anno?datum=', replace(@when-iso, '-', ''))"
                                                />
                                            </xsl:attribute>
                                            <xsl:text>Österreich</xsl:text>
                                        </a>
                                    </li>
                                    <li>
                                        <a>
                                            <xsl:attribute name="target">
                                                <xsl:text>_blank</xsl:text>
                                            </xsl:attribute>
                                            <xsl:attribute name="href">
                                                <xsl:value-of
                                                  select="concat('https://www.deutsche-digitale-bibliothek.de/newspaper/select/month?day=', day-from-date(@when-iso), '&amp;month=', month-from-date(@when-iso), '&amp;year=', year-from-date(@when-iso))"
                                                />
                                            </xsl:attribute>
                                            <xsl:text>Deutschland</xsl:text>
                                        </a>
                                    </li>
                                </ul>
                            </td>
                        </tr>
                    </tbody>
                </table>
                <xsl:choose>
                    <!--<xsl:when test="$current-edition = 'schnitzler-kultur'">
                        <xsl:variable name="notes" as="node()">
                            <xsl:call-template name="fill-event-variable">
                                <xsl:with-param name="xmlid" select="@xml:id"/>
                                <xsl:with-param name="entitityType" select="'persName'"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:call-template name="list-all-mentions">
                            <xsl:with-param name="mentions" select="$notes"/>
                        </xsl:call-template>
                    </xsl:when>-->
                    <!-- events in events gerade nicht vorgesehen -->
                    <xsl:when test=".//tei:note[@type = 'mentions'][1]">
                        <xsl:variable name="mentionsGrp">
                            <xsl:element name="noteGrp" namespace="http://www.tei-c.org/ns/1.0">
                                <xsl:copy-of select="descendant::tei:note[@type = 'mentions']"/>
                            </xsl:element>
                        </xsl:variable>
                        <xsl:call-template name="list-all-mentions">
                            <xsl:with-param name="mentions" select="$mentionsGrp"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- hier ließe sich eine Fehlermeldung ausgeben -->
                    </xsl:otherwise>
                </xsl:choose>
            </div>
        </div>
    </xsl:template>
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
    <xsl:template name="list-all-mentions">
        <xsl:param name="mentions" as="node()"/>
        <xsl:variable name="mentionCount" select="count($mentions//tei:note)"/>
        <xsl:if test="count($mentions//tei:note) > 0">
            <!-- Balkendiagramm oben -->
            <div id="mentions">
                <span class="infodesc mr-2">
                    <legend>Erwähnungen</legend>
                    <div id="mentions-chart" class="mt-3 mb-3">
                        <xsl:variable name="start-year" as="xs:integer">
                            <xsl:choose>
                                <xsl:when test="$current-edition = 'schnitzler-kultur'"> 1876 </xsl:when>
                                <xsl:otherwise> 1879 </xsl:otherwise>
                            </xsl:choose>
                        </xsl:variable>
                        <xsl:variable name="years" as="element()*">
                            <xsl:element name="years">
                                <xsl:for-each select="$start-year to 1931">
                                    <xsl:element name="year">
                                        <xsl:attribute name="val">
                                            <xsl:value-of select="."/>
                                        </xsl:attribute>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:element>
                        </xsl:variable>
                        <!-- SVG Balkendiagramm -->
                        <svg viewBox="0 0 600 200" width="100%" height="300px"
                            preserveAspectRatio="xMidYMid meet"
                            aria-label="Balkendiagramm der Erwähnungen pro Jahr" role="img">
                            <!-- Achsen -->
                            <line x1="50" y1="10" x2="50" y2="160" stroke="black" stroke-width="2"/>
                            <line x1="50" y1="160" x2="580" y2="160" stroke="black" stroke-width="2"/>
                            <!-- Y-Achse Beschriftung -->
                            <text x="30" y="165" font-size="10" text-anchor="end">0</text>
                            <text x="30" y="115" font-size="10" text-anchor="end">10</text>
                            <text x="30" y="65" font-size="10" text-anchor="end">20</text>
                            <text x="30" y="15" font-size="10" text-anchor="end">30</text>
                            <!-- X-Achse Beschriftung -->
                            <xsl:variable name="totalYears" select="1931 - $start-year + 1"/>
                            <xsl:variable name="stepWidth" select="(580 - 50) div $totalYears"/>
                            <xsl:for-each select="188 to 193">
                                <xsl:variable name="year" select="(.) * 10"/>
                                <xsl:variable name="xPos"
                                    select="50 + ($year - $start-year) * $stepWidth"/>
                                <text x="{$xPos}" y="175" font-size="10" text-anchor="middle">
                                    <xsl:value-of select="$year"/>
                                </text>
                            </xsl:for-each>
                            <!-- Balken -->
                            <xsl:for-each select="$years/*[local-name() = 'year']">
                                <xsl:variable name="year" select="number(@val)"/>
                                <xsl:variable name="count"
                                    select="count($mentions//tei:note[substring(@corresp, 1, 4) = string($year)])"/>
                                <xsl:variable name="barHeight" select="($count * 140) div 30"/>
                                <xsl:variable name="xPos"
                                    select="50 + ($year - $start-year) * $stepWidth - 2"/>
                                <rect x="{$xPos}" y="{160 - $barHeight}" width="4"
                                    height="{$barHeight}" fill="{$current-colour}">
                                    <title>
                                        <xsl:value-of
                                            select="concat($year, ': ', $count, ' Erwähnungen')"/>
                                    </title>
                                </rect>
                            </xsl:for-each>
                        </svg>
                    </div>
                    <div id="mentions-liste" class="mt-2">
                        <div id="mentions-liste" class="mt-2">
                            <xsl:choose>
                                <!-- Wenn mehr als 10 Erwähnungen -->
                                <xsl:when test="$mentionCount > 10">
                                    <div class="mentions-by-year">
                                        <!-- Gruppieren nach Jahr -->
                                        <xsl:for-each-group select="$mentions//tei:note"
                                            group-by="substring(@corresp, 1, 4)">
                                            <xsl:sort select="current-grouping-key()"
                                                data-type="number" order="ascending"/>
                                            <xsl:variable name="year"
                                                select="current-grouping-key()"/>
                                            <details class="year-details mb-3">
                                                <summary class="year-summary">
                                                  <xsl:choose>
                                                  <xsl:when test="count(current-group()) = 1">
                                                  <xsl:value-of
                                                  select="concat($year, ' (1 Eintrag)')"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="concat($year, ' (', count(current-group()), ' Einträge)')"
                                                  />
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </summary>
                                                <div class="year-content">
                                                  <xsl:choose>
                                                  <xsl:when test="count(current-group()) > 10">
                                                  <xsl:for-each-group select="current-group()"
                                                  group-by="substring(@corresp, 1, 7)">
                                                  <xsl:sort select="current-grouping-key()"
                                                  order="ascending"/>
                                                  <xsl:variable name="monthKey"
                                                  select="current-grouping-key()"/>
                                                  <details
                                                  class="month-details ms-4 mb-3 bg-light rounded p-2"
                                                  open="open">
                                                  <summary
                                                  class="month-summary p-2 bg-light rounded fw-medium">
                                                  <xsl:variable name="monthNum"
                                                  select="number(substring(current-grouping-key(), 6, 2))"/>
                                                  <xsl:choose>
                                                  <xsl:when test="$monthNum = 1">Jänner</xsl:when>
                                                  <xsl:when test="$monthNum = 2">Februar</xsl:when>
                                                  <xsl:when test="$monthNum = 3">März</xsl:when>
                                                  <xsl:when test="$monthNum = 4">April</xsl:when>
                                                  <xsl:when test="$monthNum = 5">Mai</xsl:when>
                                                  <xsl:when test="$monthNum = 6">Juni</xsl:when>
                                                  <xsl:when test="$monthNum = 7">Juli</xsl:when>
                                                  <xsl:when test="$monthNum = 8">August</xsl:when>
                                                  <xsl:when test="$monthNum = 9"
                                                  >September</xsl:when>
                                                  <xsl:when test="$monthNum = 10">Oktober</xsl:when>
                                                  <xsl:when test="$monthNum = 11"
                                                  >November</xsl:when>
                                                  <xsl:when test="$monthNum = 12"
                                                  >Dezember</xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of select="current-grouping-key()"/>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </summary>
                                                  <div class="month-content py-2">
                                                  <ul class="dashed">
                                                  <xsl:for-each select="current-group()">
                                                  <xsl:sort select="replace(@corresp, '-', '')"
                                                  order="ascending" data-type="number"/>
                                                  <xsl:variable name="linkToDocument"
                                                  select="replace(tokenize(data(.//@target), '/')[last()], '.xml', '.html')"/>
                                                  <li>
                                                  <a href="{$linkToDocument}">
                                                  <xsl:value-of select="."/>
                                                  <xsl:text> </xsl:text>
                                                  <i class="fas fa-external-link-alt"/>
                                                  </a>
                                                  </li>
                                                  </xsl:for-each>
                                                  </ul>
                                                  </div>
                                                  </details>
                                                  </xsl:for-each-group>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <ul class="dashed">
                                                  <xsl:for-each select="current-group()">
                                                  <xsl:sort select="replace(@corresp, '-', '')"
                                                  order="ascending" data-type="number"/>
                                                  <xsl:variable name="linkToDocument">
                                                  <xsl:value-of
                                                  select="replace(tokenize(data(.//@target), '/')[last()], '.xml', '.html')"
                                                  />
                                                  </xsl:variable>
                                                  <li>
                                                  <a href="{$linkToDocument}">
                                                  <xsl:value-of select="."/>
                                                  <xsl:text> </xsl:text>
                                                  <i class="fas fa-external-link-alt"/>
                                                  </a>
                                                  </li>
                                                  </xsl:for-each>
                                                  </ul>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </div>
                                            </details>
                                        </xsl:for-each-group>
                                    </div>
                                </xsl:when>
                                <!-- Weniger als oder gleich 10: Standardliste -->
                                <xsl:otherwise>
                                    <ul class="dashed">
                                        <xsl:for-each select="$mentions//tei:note">
                                            <xsl:sort select="replace(@corresp, '-', '')"
                                                order="ascending" data-type="number"/>
                                            <xsl:variable name="linkToDocument">
                                                <xsl:value-of
                                                  select="replace(tokenize(data(.//@target), '/')[last()], '.xml', '.html')"
                                                />
                                            </xsl:variable>
                                            <li>
                                                <a href="{$linkToDocument}">
                                                  <xsl:value-of select="."/>
                                                  <xsl:text> </xsl:text>
                                                  <i class="fas fa-external-link-alt"/>
                                                </a>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                    </div>
                </span>
            </div>
        </xsl:if>
    </xsl:template>
    <xsl:template name="lod-reihe">
        <xsl:param name="idno" as="node()"/>
        <div id="lod-mentions">
            <xsl:if
                test="key('only-relevant-uris', $idno/tei:idno[not(@subtype = $current-edition)]/@subtype, $relevant-uris)[1]">
                <p class="buttonreihe">
                    <xsl:variable name="idnos-of-current" as="node()">
                        <xsl:element name="nodeset_person">
                            <xsl:for-each select="$idno/tei:idno[not(@subtype = $current-edition)]">
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
    </xsl:template>
    <xsl:function name="mam:monat" as="xs:string">
        <xsl:param name="iso-datum" as="xs:date"/>
        <xsl:variable name="month-of-the-year" as="xs:string"
            select="format-date($iso-datum, '[MNn]')"/>
        <xsl:choose>
            <xsl:when test="$month-of-the-year = 'January'">
                <xsl:text>Jänner</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'February'">
                <xsl:text>Februar</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'March'">
                <xsl:text>März</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'April'">
                <xsl:text>April</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'May'">
                <xsl:text>Mai</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'June'">
                <xsl:text>Juni</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'July'">
                <xsl:text>Juli</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'August'">
                <xsl:text>August</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'September'">
                <xsl:text>September</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'October'">
                <xsl:text>Oktober</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'November'">
                <xsl:text>November</xsl:text>
            </xsl:when>
            <xsl:when test="$month-of-the-year = 'December'">
                <xsl:text>Dezember</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Unbekannter Monat</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="mam:wochentag" as="xs:string">
        <xsl:param name="iso-datum" as="xs:date"/>
        <xsl:variable name="day-of-the-week" as="xs:string" select="format-date($iso-datum, '[F]')"/>
        <xsl:choose>
            <xsl:when test="$day-of-the-week = 'Monday'">
                <xsl:text>Montag</xsl:text>
            </xsl:when>
            <xsl:when test="$day-of-the-week = 'Tuesday'">
                <xsl:text>Dienstag</xsl:text>
            </xsl:when>
            <xsl:when test="$day-of-the-week = 'Wednesday'">
                <xsl:text>Mittwoch</xsl:text>
            </xsl:when>
            <xsl:when test="$day-of-the-week = 'Thursday'">
                <xsl:text>Donnerstag</xsl:text>
            </xsl:when>
            <xsl:when test="$day-of-the-week = 'Friday'">
                <xsl:text>Freitag</xsl:text>
            </xsl:when>
            <xsl:when test="$day-of-the-week = 'Saturday'">
                <xsl:text>Samstag</xsl:text>
            </xsl:when>
            <xsl:when test="$day-of-the-week = 'Sunday'">
                <xsl:text>Sonntag</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>Unbekannt</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
