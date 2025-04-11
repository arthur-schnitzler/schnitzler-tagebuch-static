<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mam="whatever" version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:import href="./LOD-idnos.xsl"/>
    <xsl:param name="places" select="document('../../data/indices/listplace.xml')"/>
    <xsl:param name="works" select="document('../../data/indices/listwork.xml')"/>
    <xsl:param name="konkordanz" select="document('../../data/indices/index_person_day.xml')"/>
    <xsl:param name="work-day" select="document('../../data/indices/index_work_day.xml')"/>
    <xsl:key name="konk-lookup" match="item" use="ref"/>
    <xsl:key name="work-lookup" match="tei:bibl" use="tei:relatedItem/@target"/>
    <xsl:key name="work-day-lookup" match="item" use="ref"/>
    <xsl:key name="only-relevant-uris" match="item" use="abbr"/>
    <xsl:key name="authorwork-lookup" match="tei:bibl"
        use="tei:author/@*[name() = 'key' or name() = 'ref']"/>
    <xsl:param name="authors" select="document('../../data/indices/listperson.xml')"/>
    <xsl:key name="author-lookup" match="tei:person" use="tei:idno[@subtype = 'pmb']"/>
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
            <xsl:variable name="csvFilename"
                select="concat('tagebuch-vorkommen-jahr_', @xml:id, '.csv')"/>
            <script>
                function getTitle() {
                var title = '<xsl:value-of select="$csvFilename"/>';
                return title;
                }
                document.addEventListener('DOMContentLoaded', function () {
                var title = getTitle();
                createChartFromXSLT(title);
                });
            </script>
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
                                                  test="@type = 'person_variante-nachname-vorname'">
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
                                                test="@type = 'person_variante-nachname-vorname'">
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
            <div id="container" style="width:100%; height:400px min-width:768px;"/>
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
            <div class="werke">
                <xsl:variable name="author-ref"
                    select="replace(concat('pmb', tei:idno[@subtype = 'pmb'][1]/substring-after(., 'https://pmb.acdh.oeaw.ac.at/entity/')), '/', '')"
                    as="xs:string"/>
                <!-- hier ist pmb im einsatz, also haben wir jetzt eine nummerm
                    bspw. 'pmb11461' für goethe -->
                <xsl:if test="key('authorwork-lookup', $author-ref, $works)[1]">
                    <legend>Werke</legend>
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
                                            <xsl:value-of select="tei:persName/tei:forename"/>"/> </xsl:when>
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
                                    <xsl:if test="@role = 'editor' or @role = 'hat-herausgegeben'">
                                        <xsl:text> (Herausgabe)</xsl:text>
                                    </xsl:if>
                                    <xsl:if test="@role = 'translator' or @role = 'hat-ubersetzt'">
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
                                        <xsl:when test="position() = last()">
                                            <xsl:text>: </xsl:text>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:text>, </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
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
            </div>
            <xsl:if test="key('konk-lookup', @xml:id, $konkordanz)[1]">
                <xsl:variable name="allMentionsForThisPerson"
                    select="key('konk-lookup', @xml:id, $konkordanz)"/>
                <xsl:call-template name="display-mentions">
                    <xsl:with-param name="mentionNodes" select="$allMentionsForThisPerson"/>
                </xsl:call-template>
            </xsl:if>
        </div>
    </xsl:template>
    <!-- WORK -->
    <xsl:template match="tei:listBibl/tei:bibl" name="work_detail">
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
                                    <xsl:variable name="autor-ref" as="xs:string"
                                        select="replace(replace($keyToRef, 'pmb', ''), 'person__', '')"/>
                                    <xsl:choose>
                                        <xsl:when test="$autor-ref = '2121'">
                                            <a href="pmb2121.html">
                                                <xsl:text>Arthur Schnitzler</xsl:text>
                                            </a>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:variable name="autor-ref-schnitzler-tagebuch">
                                                <xsl:variable name="author-lookup-mit-schraegstrich"
                                                  select="key('author-lookup', concat('https://pmb.acdh.oeaw.ac.at/entity/', $autor-ref, '/'), $authors)/tei:idno[@subtype = 'schnitzler-tagebuch' or @type = 'schnitzler-tagebuch'][1]/substring-after(., 'https://schnitzler-tagebuch.acdh.oeaw.ac.at/')"/>
                                                <xsl:choose>
                                                  <xsl:when
                                                  test="$author-lookup-mit-schraegstrich != ''">
                                                  <xsl:value-of
                                                  select="$author-lookup-mit-schraegstrich"/>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:value-of
                                                  select="key('author-lookup', concat('https://pmb.acdh.oeaw.ac.at/entity/', $autor-ref), $authors)/tei:idno[@subtype = 'schnitzler-tagebuch' or @type = 'schnitzler-tagebuch'][1]/substring-after(., 'https://schnitzler-tagebuch.acdh.oeaw.ac.at/')"
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
            <xsl:variable name="allMentionsForThisWork"
                select="key('work-day-lookup', @xml:id, $work-day)"/>
            <xsl:call-template name="display-mentions">
                <xsl:with-param name="mentionNodes" select="$allMentionsForThisWork"/>
            </xsl:call-template>
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
                <xsl:if test=".//tei:geo/text()">
                    <div id="mapid" style="height: 400px; width:100%; clear: both;"/>
                    <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css"
                        integrity="sha512-xodZBNTC5n17Xt2atTPuE1HxjVMSvLVW9ocqUKLsCC5CXdbqCmblAshOMAS6/keqq/sMZMZ19scR4PsZChSR7A=="
                        crossorigin=""/>
                    <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js" integrity="sha512-XQoYMqMTK8LvdxXYG3nZ448hOEQiglfqkJs1NOQV44cWnUrBc8PkAOcXy20w0vlaXaVUearIOBhiXZ5V3ynxwA==" crossorigin=""/>
                    <script>
                        
                        var mymap = L.map('mapid').setView([50, 12], 5);
                        
                        L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                        attribution: 'Map data &amp;copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.openstreetmap.org/">OpenStreetMap</a>',
                        maxZoom: 18,
                        zIndex: 1
                        }).addTo(mymap);
                        <xsl:variable name="laenge" as="xs:string" select="replace(tokenize(descendant::tei:geo[1]/text(), ' ')[1], ',', '.')"/>
                        <xsl:variable name="breite" as="xs:string" select="replace(tokenize(descendant::tei:geo[1]/text(), ' ')[2], ',', '.')"/>
                        <xsl:variable name="laengebreite" as="xs:string" select="concat($laenge, ', ', $breite)"/>
                        <xsl:value-of select="$laengebreite"/>
                        L.marker([<xsl:value-of select="$laengebreite"/>]).addTo(mymap)
                        .bindPopup("<b>
                            <xsl:value-of select="./tei:placeName[1]/text()"/>
                        </b>").openPopup();
                    </script>
                    <div class="card"> </div>
                </xsl:if>
                <xsl:if test="count(.//tei:placeName[contains(@type, 'namensvariante')]) gt 1">
                    <ul>
                        <legend>Namensvarianten</legend>
                        <xsl:for-each select=".//tei:placeName[contains(@type, 'namensvariante')]">
                            <li>
                                <xsl:value-of select="./text()"/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </xsl:if>
                
                <xsl:variable name="allMentionsOfPlace" select=".//tei:ptr"/>
                <xsl:call-template name="display-ptr-mentions">  <!-- Call the NEW template -->
                    <xsl:with-param name="ptrNodes" select="$allMentionsOfPlace"/>
                    <xsl:with-param name="contextNodeForId" select="."/>
                </xsl:call-template>
                
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
            <div id="mentions">
                <xsl:if test="key('only-relevant-uris', tei:idno/@subtype, $relevant-uris)[1]">
                    <p class="buttonreihe">
                        <xsl:variable name="idnos-of-current" as="node()">
                            <xsl:element name="nodeset_org">
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
                    <ul>
                        <legend>Orte</legend>
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
            <div id="mentions-{generate-id()}" class="mt-2">
                <legend>Erwähnungen</legend>
                <xsl:variable name="allMentions" select=".//tei:note[@type = 'mentions']"/>
                <xsl:variable name="mentionCount" select="count($allMentions)"/>
                <xsl:choose>
                    <xsl:when test="$mentionCount > 15">
                        <div class="accordion" id="accordion-mentions-{generate-id()}">
                            <xsl:for-each-group select="$allMentions"
                                group-by="substring-before(@corresp, '-')">
                                <xsl:sort select="current-grouping-key()" data-type="number"
                                    order="ascending"/>
                                <xsl:variable name="year" select="current-grouping-key()"/>
                                <xsl:variable name="mentionsInYear" select="current-group()"/>
                                <xsl:variable name="countInYear" select="count($mentionsInYear)"/>
                                <xsl:variable name="accordionBaseId"
                                    select="concat('mention-year-', $year, '-', generate-id(..))"/>
                                <xsl:variable name="headerId"
                                    select="concat('header-', $accordionBaseId)"/>
                                <xsl:variable name="collapseId"
                                    select="concat('collapse-', $accordionBaseId)"/>
                                <xsl:variable name="parentId"
                                    select="concat('accordion-mentions-', generate-id(..))"/>
                                <div class="accordion-item">
                                    <h2 class="accordion-header" id="{$headerId}">
                                        <button class="accordion-button collapsed" type="button"
                                            data-bs-toggle="collapse"
                                            data-bs-target="#{$collapseId}" aria-expanded="false"
                                            aria-controls="{$collapseId}">
                                            <xsl:value-of select="$year"/>
                                            <xsl:text> (</xsl:text>
                                            <xsl:value-of select="$countInYear"/>
                                            <xsl:text> Erwähnung</xsl:text>
                                            <xsl:if test="$countInYear != 1">en</xsl:if>
                                            <xsl:text>)</xsl:text>
                                        </button>
                                    </h2>
                                    <div id="{$collapseId}" class="accordion-collapse collapse"
                                        aria-labelledby="{$headerId}" data-bs-parent="#{$parentId}">
                                        <div class="accordion-body">
                                            <ul>
                                                <xsl:for-each select="$mentionsInYear">
                                                  <xsl:sort select="replace(@corresp, '-', '')"
                                                  order="ascending" data-type="number"/>
                                                  <xsl:variable name="linkToDocument">
                                                  <xsl:value-of
                                                  select="replace(tokenize(data(.//@target), '/')[last()], '.xml', '.html')"
                                                  />
                                                  </xsl:variable>
                                                  <li>
                                                  <xsl:value-of select="."/>
                                                  <xsl:text> </xsl:text>
                                                  <a href="{$linkToDocument}" target="_blank"
                                                  rel="noopener noreferrer" title="Dokument öffnen">
                                                  <i class="fas fa-external-link-alt"/>
                                                  </a>
                                                  </li>
                                                </xsl:for-each>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </xsl:for-each-group>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$mentionCount > 0">
                                <ul class="list-unstyled">
                                    <xsl:for-each select="$allMentions">
                                        <xsl:sort select="replace(@corresp, '-', '')"
                                            order="ascending" data-type="number"/>
                                        <xsl:variable name="linkToDocument">
                                            <xsl:value-of
                                                select="replace(tokenize(data(.//@target), '/')[last()], '.xml', '.html')"
                                            />
                                        </xsl:variable>
                                        <li>
                                            <xsl:value-of select="."/>
                                            <xsl:text> </xsl:text>
                                            <a href="{$linkToDocument}" target="_blank"
                                                rel="noopener noreferrer" title="Dokument öffnen">
                                                <i class="fas fa-external-link-alt"/>
                                            </a>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </xsl:when>
                            <xsl:otherwise>
                                <p>Keine Erwähnungen vorhanden.</p>
                            </xsl:otherwise>
                        </xsl:choose>
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
    <xsl:function name="mam:germanNames">
        <xsl:param name="input"/>
        <xsl:choose>
            <xsl:when test="$input = 'Monday'">Montag</xsl:when>
            <xsl:when test="$input = 'Tuesday'">Dienstag</xsl:when>
            <xsl:when test="$input = 'Wednesday'">Mittwoch</xsl:when>
            <xsl:when test="$input = 'Thursday'">Donnerstag</xsl:when>
            <xsl:when test="$input = 'Friday'">Freitag</xsl:when>
            <xsl:when test="$input = 'Saturday'">Samstag</xsl:when>
            <xsl:when test="$input = 'Sunday'">Sonntag</xsl:when>
            <xsl:when test="$input = 'January'">Januar</xsl:when>
            <xsl:when test="$input = 'February'">Februar</xsl:when>
            <xsl:when test="$input = 'March'">März</xsl:when>
            <xsl:when test="$input = 'May'">Mai</xsl:when>
            <xsl:when test="$input = 'June'">Juni</xsl:when>
            <xsl:when test="$input = 'July'">Juli</xsl:when>
            <xsl:when test="$input = 'October'">Oktober</xsl:when>
            <xsl:when test="$input = 'December'">Dezember</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$input"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:template name="display-mentions">
        <xsl:param name="mentionNodes" as="item()*"/>
        <xsl:param name="contextNodeForId" select="."/>
        <xsl:variable name="mentionCount" select="count($mentionNodes)"/>
        <xsl:variable name="uniqueComponent" select="generate-id($contextNodeForId)"/>
        <div id="mentions-{generate-id()}" class="mt-2">
            <legend>Erwähnt am</legend>
            <xsl:choose>
                <xsl:when test="$mentionCount > 15">
                    <div class="accordion" id="accordion-mentions-{$uniqueComponent}">
                        <xsl:for-each-group select="$mentionNodes"
                            group-by="substring(@target, 1, 4)">
                            <xsl:sort select="current-grouping-key()" data-type="number"
                                order="ascending"/>
                            <xsl:if test="matches(current-grouping-key(), '^\d{4}$')">
                                <xsl:variable name="year" select="current-grouping-key()"/>
                                <xsl:variable name="mentionsInYear" select="current-group()"/>
                                <xsl:variable name="countInYear" select="count($mentionsInYear)"/>
                                <xsl:variable name="accordionBaseId"
                                    select="concat('mention-year-', $year, '-', $uniqueComponent)"/>
                                <xsl:variable name="headerId"
                                    select="concat('header-', $accordionBaseId)"/>
                                <xsl:variable name="collapseId"
                                    select="concat('collapse-', $accordionBaseId)"/>
                                <xsl:variable name="parentId"
                                    select="concat('accordion-mentions-', $uniqueComponent)"/>
                                <div class="accordion-item">
                                    <h2 class="accordion-header" id="{$headerId}">
                                        <button class="accordion-button collapsed" type="button"
                                            data-bs-toggle="collapse"
                                            data-bs-target="#{$collapseId}" aria-expanded="false"
                                            aria-controls="{$collapseId}">
                                            <xsl:value-of select="$year"/>
                                            <xsl:text> (</xsl:text>
                                            <xsl:value-of select="$countInYear"/>
                                            <xsl:text> Erwähnung</xsl:text>
                                            <xsl:if test="$countInYear != 1">en</xsl:if>
                                            <xsl:text>)</xsl:text>
                                        </button>
                                    </h2>
                                    <div id="{$collapseId}" class="accordion-collapse collapse"
                                        aria-labelledby="{$headerId}" data-bs-parent="#{$parentId}">
                                        <div class="accordion-body">
                                            <ul class="list-unstyled">
                                                <xsl:for-each select="$mentionsInYear">
                                                  <xsl:sort select="@target" data-type="text"
                                                  order="ascending"/>
                                                  <xsl:variable name="linkToDocument"
                                                  select="concat('entry__', @target, '.html')"/>
                                                  <xsl:variable name="print_date">
                                                  <xsl:if
                                                  test="matches(@target, '^\d{4}-\d{2}-\d{2}$')">
                                                  <xsl:variable name="date-value"
                                                  select="xs:date(@target)" as="xs:date"/>
                                                  <xsl:variable name="monat_en"
                                                  select="format-date($date-value, '[MNn]', 'en', (), ())"/>
                                                  <xsl:variable name="wochentag_en"
                                                  select="format-date($date-value, '[F]', 'en', (), ())"/>
                                                  <xsl:variable name="monat"
                                                  select="mam:germanNames($monat_en)"/>
                                                  <xsl:variable name="wochentag"
                                                  select="mam:germanNames($wochentag_en)"/>
                                                  <xsl:variable name="tag"
                                                  select="concat(format-date($date-value, '[D]', 'en', (), ()), '. ')"/>
                                                  <xsl:variable name="jahr"
                                                  select="format-date($date-value, '[Y]', 'en', (), ())"/>
                                                  <xsl:value-of
                                                  select="concat($wochentag, ', ', $tag, $monat, ' ', $jahr)"
                                                  />
                                                  </xsl:if>
                                                  </xsl:variable>
                                                  <xsl:if test="normalize-space($print_date) != ''">
                                                  <li>
                                                  <a href="{$linkToDocument}" target="_blank"
                                                  rel="noopener noreferrer"
                                                  title="Eintrag vom {$print_date} öffnen">
                                                  <xsl:value-of select="$print_date"/>
                                                  </a>
                                                  </li>
                                                  </xsl:if>
                                                </xsl:for-each>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </xsl:if>
                        </xsl:for-each-group>
                    </div>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$mentionCount > 0">
                            <ul class="list-unstyled">
                                <xsl:for-each select="$mentionNodes">
                                    <xsl:sort select="@target" data-type="text" order="ascending"/>
                                    <xsl:variable name="linkToDocument"
                                        select="concat('entry__', @target, '.html')"/>
                                    <xsl:variable name="print_date">
                                        <xsl:if test="matches(@target, '^\d{4}-\d{2}-\d{2}$')">
                                            <xsl:variable name="date-value"
                                                select="xs:date(@target)" as="xs:date"/>
                                            <xsl:variable name="monat_en"
                                                select="format-date($date-value, '[MNn]', 'en', (), ())"/>
                                            <xsl:variable name="wochentag_en"
                                                select="format-date($date-value, '[F]', 'en', (), ())"/>
                                            <xsl:variable name="monat"
                                                select="mam:germanNames($monat_en)"/>
                                            <xsl:variable name="wochentag"
                                                select="mam:germanNames($wochentag_en)"/>
                                            <xsl:variable name="tag"
                                                select="concat(format-date($date-value, '[D]', 'en', (), ()), '. ')"/>
                                            <xsl:variable name="jahr"
                                                select="format-date($date-value, '[Y]', 'en', (), ())"/>
                                            <xsl:value-of
                                                select="concat($wochentag, ', ', $tag, $monat, ' ', $jahr)"
                                            />
                                        </xsl:if>
                                    </xsl:variable>
                                    <xsl:if test="normalize-space($print_date) != ''">
                                        <li>
                                            <a href="{$linkToDocument}" target="_blank"
                                                rel="noopener noreferrer"
                                                title="Eintrag vom {$print_date} öffnen">
                                                <xsl:value-of select="$print_date"/>
                                            </a>
                                        </li>
                                    </xsl:if>
                                </xsl:for-each>
                            </ul>
                        </xsl:when>
                        <xsl:otherwise>
                            <p>Keine Erwähnungen vorhanden.</p>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <!-- ================================================== -->
    <!-- Named Template to Display Mentions from tei:ptr    -->
    <!-- ================================================== -->
    <xsl:template name="display-ptr-mentions">
        <xsl:param name="ptrNodes" as="element(tei:ptr)*"/> <!-- Specific type -->
        <xsl:param name="contextNodeForId" select="."/>
        
        <xsl:variable name="mentionCount" select="count($ptrNodes)"/>
        <xsl:variable name="uniqueComponent" select="generate-id($contextNodeForId)"/>
        <div id="mentions-{generate-id()}" class="mt-2">
            <legend>Erwähnt am</legend>
        <xsl:choose>
            <!-- Case 1: More than 15 mentions -> Bootstrap Accordion -->
            <xsl:when test="$mentionCount > 15">
                <div class="accordion" id="accordion-ptr-mentions-{$uniqueComponent}">
                    <!-- Group by year extracted from @target filename -->
                    <xsl:for-each-group select="$ptrNodes" group-by="substring(replace(@target, 'entry__|.xml', ''), 1, 4)">
                        <xsl:sort select="current-grouping-key()" data-type="number" order="ascending"/>
                        <xsl:variable name="year" select="current-grouping-key()"/>
                        <!-- Basic check if year looks like 4 digits -->
                        <xsl:if test="matches($year, '^\d{4}$')">
                            <xsl:variable name="mentionsInYear" select="current-group()"/>
                            <xsl:variable name="countInYear" select="count($mentionsInYear)"/>
                            
                            <xsl:variable name="accordionBaseId" select="concat('ptr-mention-year-', $year, '-', $uniqueComponent)"/>
                            <xsl:variable name="headerId" select="concat('header-', $accordionBaseId)"/>
                            <xsl:variable name="collapseId" select="concat('collapse-', $accordionBaseId)"/>
                            <xsl:variable name="parentId" select="concat('accordion-ptr-mentions-', $uniqueComponent)"/>
                            
                            <div class="accordion-item">
                                <h2 class="accordion-header" id="{$headerId}">
                                    <button class="accordion-button collapsed" type="button" data-bs-toggle="collapse" data-bs-target="#{$collapseId}" aria-expanded="false" aria-controls="{$collapseId}">
                                        <xsl:value-of select="$year"/>
                                        <xsl:text> (</xsl:text>
                                        <xsl:value-of select="$countInYear"/>
                                        <xsl:text> Erwähnung</xsl:text>
                                        <xsl:if test="$countInYear != 1">en</xsl:if>
                                        <xsl:text>)</xsl:text>
                                    </button>
                                </h2>
                                <div id="{$collapseId}" class="accordion-collapse collapse" aria-labelledby="{$headerId}" data-bs-parent="#{$parentId}">
                                    <div class="accordion-body">
                                        <ul class="list-unstyled">
                                            <xsl:for-each select="$mentionsInYear">
                                                <!-- Sort by extracted date string within the year -->
                                                <xsl:sort select="replace(@target, 'entry__|.xml', '')" data-type="text" order="ascending"/>
                                                
                                                <!-- Extract date string for formatting -->
                                                <xsl:variable name="dateString" select="replace(@target, 'entry__|.xml', '')"/>
                                                <!-- Generate link -->
                                                <xsl:variable name="linkToDocument" select="replace(@target, '.xml', '.html')"/>
                                                
                                                <!-- $print_date variable calculation (using extracted dateString) -->
                                                <xsl:variable name="print_date">
                                                    <xsl:if test="matches($dateString, '^\d{4}-\d{2}-\d{2}$')">
                                                        <xsl:variable name="date-value" select="xs:date($dateString)" as="xs:date"/>
                                                        <xsl:variable name="monat_en" select="format-date($date-value, '[MNn]', 'en', (), ())"/>
                                                        <xsl:variable name="wochentag_en" select="format-date($date-value, '[F]', 'en', (), ())"/>
                                                        <xsl:variable name="monat" select="mam:germanNames($monat_en)"/>
                                                        <xsl:variable name="wochentag" select="mam:germanNames($wochentag_en)"/>
                                                        <xsl:variable name="tag" select="concat(format-date($date-value, '[D]', 'en', (), ()), '. ')"/>
                                                        <xsl:variable name="jahr" select="format-date($date-value, '[Y]', 'en', (), ())"/>
                                                        <xsl:value-of select="concat($wochentag, ', ', $tag, $monat, ' ', $jahr)"/>
                                                    </xsl:if>
                                                </xsl:variable>
                                                <xsl:if test="normalize-space($print_date) != ''">
                                                    <li>
                                                        <a href="{$linkToDocument}" target="_blank" rel="noopener noreferrer" title="Eintrag vom {$print_date} öffnen">
                                                            <xsl:value-of select="$print_date"/>
                                                        </a>
                                                    </li>
                                                </xsl:if>
                                            </xsl:for-each>
                                        </ul>
                                    </div>
                                </div>
                            </div>
                        </xsl:if>
                    </xsl:for-each-group>
                </div>
            </xsl:when>
            <!-- Case 2: 15 or fewer mentions -> Simple List -->
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$mentionCount > 0">
                        <ul class="list-unstyled">
                            <xsl:for-each select="$ptrNodes">
                                <!-- Sort by extracted date string -->
                                <xsl:sort select="replace(@target, 'entry__|.xml', '')" data-type="text" order="ascending"/>
                                
                                <xsl:variable name="dateString" select="replace(@target, 'entry__|.xml', '')"/>
                                <xsl:variable name="linkToDocument" select="replace(@target, '.xml', '.html')"/>
                                
                                <!-- $print_date variable calculation (using extracted dateString) -->
                                <xsl:variable name="print_date">
                                    <xsl:if test="matches($dateString, '^\d{4}-\d{2}-\d{2}$')">
                                        <xsl:variable name="date-value" select="xs:date($dateString)" as="xs:date"/>
                                        <xsl:variable name="monat_en" select="format-date($date-value, '[MNn]', 'en', (), ())"/>
                                        <xsl:variable name="wochentag_en" select="format-date($date-value, '[F]', 'en', (), ())"/>
                                        <xsl:variable name="monat" select="mam:germanNames($monat_en)"/>
                                        <xsl:variable name="wochentag" select="mam:germanNames($wochentag_en)"/>
                                        <xsl:variable name="tag" select="concat(format-date($date-value, '[D]', 'en', (), ()), '. ')"/>
                                        <xsl:variable name="jahr" select="format-date($date-value, '[Y]', 'en', (), ())"/>
                                        <xsl:value-of select="concat($wochentag, ', ', $tag, $monat, ' ', $jahr)"/>
                                    </xsl:if>
                                </xsl:variable>
                                <xsl:if test="normalize-space($print_date) != ''">
                                    <li>
                                        <a href="{$linkToDocument}" target="_blank" rel="noopener noreferrer" title="Eintrag vom {$print_date} öffnen">
                                            <xsl:value-of select="$print_date"/>
                                        </a>
                                    </li>
                                </xsl:if>
                            </xsl:for-each>
                        </ul>
                    </xsl:when>
                    <xsl:otherwise>
                        <p>Keine Erwähnungen vorhanden.</p>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
        </div>
    </xsl:template>
</xsl:stylesheet>
