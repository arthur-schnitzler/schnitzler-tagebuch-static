<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mam="whatever" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0"
    exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes"
        omit-xml-declaration="yes"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/entities.xsl"/>
    <xsl:import href="./partials/tabulator_js.xsl"/>
    <xsl:variable name="teiSource" select="'listperson.xml'"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Verzeichnis erwähnter Personen'"/>
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
        <html lang="de">
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"/>
            </xsl:call-template>
            <link href="vendor/tabulator-tables/css/tabulator_bootstrap5.min.css"
                rel="stylesheet"/>
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    <div class="container-fluid">
                        <div class="card">
                            <div class="card-header" style="text-align:center">
                                <h1>
                                    <xsl:value-of select="$doc_title"/>
                                </h1>
                            </div>
                            <div class="card">
                                <table class="table table-sm display" id="tabulator-table-person">
                                    <thead>
                                        <tr>
                                            <th scope="col" tabulator-headerFilter="input"
                                                >Vorname</th>
                                            <th scope="col" tabulator-headerFilter="input"
                                                >Nachname</th>
                                            <th scope="col" tabulator-headerFilter="input"
                                                tabulator-formatter="html">Namensvarianten</th>
                                            <th scope="col" tabulator-headerFilter="input"
                                                tabulator-formatter="html">Lebensdaten</th>
                                            <th scope="col" tabulator-headerFilter="input"
                                                >Berufe</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each
                                            select="descendant::tei:listPerson[1]/tei:person">
                                            <xsl:variable name="entiyID"
                                                select="replace(@xml:id, '#', '')"/>
                                            <xsl:variable name="entity" as="node()" select="."/>
                                            <tr>
                                                <td>
                                                    <span hidden="true">
                                                        <xsl:choose>
                                                            <xsl:when test="starts-with($entity/tei:persName[1]/tei:forename[1]/text(), '??')">
                                                                <xsl:text>ZZZ </xsl:text><!-- Vornamen mit ?? nach unten reihen -->
                                                            </xsl:when>
                                                            <xsl:when test="normalize-space($entity/tei:persName[1]/tei:forename[1]/text()) = ''">
                                                                <xsl:value-of select="substring($entity/tei:persName[1]/tei:surname/text(), 1, 1)"/>
                                                            </xsl:when>
                                                        </xsl:choose>
                                                        <xsl:value-of
                                                            select="$entity/tei:persName[1]/tei:forename[1]/text()"
                                                        />
                                                    </span>
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:value-of
                                                                select="concat($entity/@xml:id, '.html')"/>
                                                        </xsl:attribute>
                                                        <xsl:value-of
                                                            select="$entity/tei:persName[1]/tei:forename[1]/text()"
                                                        />
                                                    </a>
                                                </td>
                                                <td>
                                                    <span hidden="true">
                                                        <xsl:if
                                                            test="starts-with($entity/tei:persName[1]/tei:surname[1]/text(), '??')">
                                                            <xsl:text>ZZZ </xsl:text>
                                                        </xsl:if>
                                                        <xsl:if
                                                            test="not($entity/tei:persName[1]/tei:surname[1]) or normalize-space($entity/tei:persName[1]/tei:surname[1]/text())=''">
                                                            <xsl:text>ZZ </xsl:text>
                                                        </xsl:if>
                                                        <xsl:value-of
                                                            select="$entity/tei:persName[1]/tei:surname[1]/text()"
                                                        />
                                                    </span>
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:value-of
                                                                select="concat($entity/@xml:id, '.html')"/>
                                                        </xsl:attribute>
                                                        <xsl:value-of
                                                            select="$entity/tei:persName[1]/tei:surname[1]/text()"
                                                        />
                                                    </a>
                                                </td>
                                                <td>
                                                    <xsl:variable name="lemma-name"
                                                        select="$entity/tei:persName[(position() = 1)]"
                                                        as="node()"/>
                                                    <xsl:variable name="namensformen" as="node()">
                                                        <xsl:element name="listPerson">
                                                            <xsl:for-each
                                                                select="$entity/descendant::tei:persName[not(position() = 1) and not(@type = 'legacy-name-merge')]">
                                                                <xsl:copy-of select="."/>
                                                            </xsl:for-each>
                                                        </xsl:element>
                                                    </xsl:variable>
                                                    <xsl:for-each
                                                        select="distinct-values($namensformen/descendant::tei:persName/@type)">
                                                        <xsl:choose>
                                                            <xsl:when
                                                                test=". = 'person_geburtsname_vorname' and $namensformen/descendant::tei:persName[@type = 'person_geburtsname_nachname']">
                                                                <xsl:text>geboren: </xsl:text>
                                                                <xsl:for-each
                                                                    select="$namensformen/descendant::tei:persName[@type = 'person_geburtsname_vorname']">
                                                                    <xsl:value-of
                                                                        select="concat(., ' ', $namensformen/descendant::tei:persName[@type = 'person_geburtsname_nachname'][1])"/>
                                                                    <xsl:choose>
                                                                        <xsl:when test="not(position() = last())">
                                                                            <xsl:text>, </xsl:text>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:element name="br"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </xsl:for-each>
                                                            </xsl:when>
                                                            <xsl:when
                                                                test=". = 'person_geburtsname_vorname' and not($namensformen/descendant::tei:persName[@type = 'person_geburtsname_nachname'])">
                                                                <xsl:for-each
                                                                    select="$namensformen/descendant::tei:persName[@type = 'person_geburtsname_vorname']">
                                                                    <xsl:if test="position() = 1">
                                                                        <xsl:text>geboren: </xsl:text>
                                                                    </xsl:if>
                                                                    <xsl:value-of
                                                                        select="concat(., ' ', $lemma-name//tei:surname)"/>
                                                                    <xsl:choose>
                                                                        <xsl:when test="not(position() = last())">
                                                                            <xsl:text>, </xsl:text>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:element name="br"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </xsl:for-each>
                                                            </xsl:when>
                                                            <xsl:when
                                                                test=". = 'person_geburtsname_nachname' and not($namensformen/descendant::tei:persName[@type = 'person_geburtsname_vorname'])">
                                                                <xsl:for-each
                                                                    select="$namensformen/descendant::tei:persName[@type = 'person_geburtsname_nachname']">
                                                                    <xsl:if test="position() = 1">
                                                                        <xsl:text>geboren: </xsl:text>
                                                                    </xsl:if>
                                                                    <xsl:value-of select="."/>
                                                                    <xsl:choose>
                                                                        <xsl:when test="not(position() = last())">
                                                                            <xsl:text>, </xsl:text>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:element name="br"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </xsl:for-each>
                                                            </xsl:when>
                                                            <xsl:when
                                                                test=". = 'person_geburtsname_nachname' and $namensformen/descendant::tei:persName[@type = 'person_geburtsname_vorname']"/>
                                                            <!--  -->
                                                            <xsl:when
                                                                test=". = 'person_namensvariante_vorname' and $namensformen/descendant::tei:persName[@type = 'person_namensvariante_nachname']">
                                                                <xsl:text>Namensvariante: </xsl:text>
                                                                <xsl:for-each
                                                                    select="$namensformen/descendant::tei:persName[@type = 'person_namensvariante_vorname']">
                                                                    <xsl:value-of
                                                                        select="concat(., ' ', $namensformen/descendant::tei:persName[@type = 'person_namensvariante_nachname'][1])"/>
                                                                    <xsl:choose>
                                                                        <xsl:when test="not(position() = last())">
                                                                            <xsl:text>, </xsl:text>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:element name="br"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </xsl:for-each>
                                                            </xsl:when>
                                                            <xsl:when
                                                                test=". = 'person_namensvariante_vorname' and not($namensformen/descendant::tei:persName[@type = 'person_namensvariante_nachname'])">
                                                                <xsl:for-each
                                                                    select="$namensformen/descendant::tei:persName[@type = 'person_namensvariante_vorname']">
                                                                    <xsl:if test="position() = 1">
                                                                        <xsl:text>Namensvariante: </xsl:text>
                                                                    </xsl:if>
                                                                    <xsl:value-of
                                                                        select="concat(., ' ', $lemma-name//tei:surname)"/>
                                                                    <xsl:choose>
                                                                        <xsl:when test="not(position() = last())">
                                                                            <xsl:text>, </xsl:text>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:element name="br"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </xsl:for-each>
                                                            </xsl:when>
                                                            <xsl:when
                                                                test=". = 'person_namensvariante_nachname' and not($namensformen/descendant::tei:persName[@type = 'person_namensvariante_vorname'])">
                                                                <xsl:for-each
                                                                    select="$namensformen/descendant::tei:persName[@type = 'person_namensvariante_nachname']">
                                                                    <xsl:if test="position() = 1">
                                                                        <xsl:text>Namensvariante: </xsl:text>
                                                                    </xsl:if>
                                                                    <xsl:value-of select="."/>
                                                                    <xsl:choose>
                                                                        <xsl:when test="not(position() = last())">
                                                                            <xsl:text>, </xsl:text>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:element name="br"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </xsl:for-each>
                                                            </xsl:when>
                                                            <xsl:when
                                                                test=". = 'person_namensvariante_nachname' and $namensformen/descendant::tei:persName[@type = 'person_namensvariante_vorname']"/>
                                                            <xsl:otherwise>
                                                                <xsl:variable name="current-typ" select="."
                                                                    as="xs:string"/>
                                                                <xsl:variable name="current-typ-name" as="node()?">
                                                                    <list>
                                                                        <item type="person_adoptierter-nachname"
                                                                            >adoptierter Name</item>
                                                                        <item type="namensvariante">Namensvariante</item>
                                                                        <item type="person_rufname">Rufname</item>
                                                                        <item type="person_pseudonym">Pseudonym</item>
                                                                        <item type="person_geschieden_nachname">geschieden</item>
                                                                        <item type="person_ehename">Ehename</item>
                                                                        <item type="person_ehename_nachname"
                                                                            >Ehename</item>
                                                                        <item type="person_verwitwet">verwitwet</item>
                                                                    </list>
                                                                </xsl:variable>
                                                                <xsl:for-each
                                                                    select="$namensformen/descendant::tei:persName[@type = $current-typ]">
                                                                    <xsl:if test="position() = 1">
                                                                        <xsl:value-of
                                                                            select="$current-typ-name//*:item[@type = $current-typ]"/>
                                                                        <xsl:text>: </xsl:text>
                                                                    </xsl:if>
                                                                    <xsl:value-of select="."/>
                                                                    <xsl:choose>
                                                                        <xsl:when test="not(position() = last())">
                                                                            <xsl:text>, </xsl:text>
                                                                        </xsl:when>
                                                                        <xsl:otherwise>
                                                                            <xsl:element name="br"/>
                                                                        </xsl:otherwise>
                                                                    </xsl:choose>
                                                                </xsl:for-each>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </xsl:for-each>
                                                </td>
                                                <td>
                                                    <xsl:value-of select="mam:lebensdaten($entity)"/>
                                                </td>
                                                <td>
                                                    <xsl:if test="$entity/descendant::tei:occupation">
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
                                                    </xsl:if>
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </tbody>
                                </table>
                                <xsl:call-template name="tabulator_dl_buttons"/>
                            </div>
                        </div>
                    </div>
                    <xsl:call-template name="html_footer"/>
                    <script type="text/javascript" src="https://unpkg.com/tabulator-tables@6.2.1/dist/js/tabulator.min.js"/>
                    <script src="tabulator-js/tabulator_person.js"/>
                </div>
            </body>
        </html>
        <xsl:for-each select=".//tei:person[@xml:id]">
            <xsl:variable name="filename" select="concat(./@xml:id, '.html')"/>
            <xsl:variable name="name">
                <xsl:choose>
                    <xsl:when
                        test="./tei:persName[1]/tei:forename[1] and ./tei:persName[1]/tei:surname[1]">
                        <xsl:value-of
                            select="normalize-space(concat(./tei:persName[1]/tei:forename[1], ' ', ./tei:persName[1]/tei:surname[1]))"
                        />
                    </xsl:when>
                    <xsl:when test="./tei:persName[1]/tei:forename[1]">
                        <xsl:value-of select="normalize-space(./tei:persName[1]/tei:forename[1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(./tei:persName[1]/tei:surname[1])"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="entity" select="." as="node()"/>
            <xsl:result-document href="{$filename}">
                <html xmlns="http://www.w3.org/1999/xhtml">
                    <xsl:call-template name="html_head">
                        <xsl:with-param name="html_title" select="$name"/>
                    </xsl:call-template>
                    <script src="./js/highcharts-persons-occurences.js"></script>
                    <script src="https://code.highcharts.com/highcharts.js"/>
                    <script src="https://code.highcharts.com/highcharts-more.js"/>
                    <script src="https://code.highcharts.com/modules/data.js"/>
                    <script src="https://code.highcharts.com/modules/exporting.js"/>
                    
                    <body class="page">
                        <div class="hfeed site" id="page">
                            <xsl:call-template name="nav_bar"/>
                            <div class="container-fluid">
                                <div class="card">
                                    <div class="card-header">
                                    <h2 align="center">
                                        <xsl:value-of select="$name"/>
                                        <xsl:text> </xsl:text>
                                        <xsl:choose>
                                            <xsl:when test="child::tei:birth and child::tei:death">
                                                <span class="lebensdaten">
                                                    <xsl:text>(</xsl:text>
                                                    <xsl:value-of select="mam:lebensdaten($entity)"/>
                                                    <xsl:text>)</xsl:text>
                                                </span>
                                            </xsl:when>
                                        </xsl:choose>
                                    </h2>
                                </div>
                                <div class="card-body-index">
                                    <xsl:call-template name="person_detail"/>
                                </div></div>
                            </div>
                            <xsl:call-template name="html_footer"/>
                        </div>
                    </body>
                </html>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    <xsl:function name="mam:lebensdaten">
        <xsl:param name="entity" as="node()"/>
        <xsl:variable name="geburtsort" as="xs:string?" select="$entity/tei:birth[1]/tei:settlement[1]/tei:placeName[1]"/>
        <xsl:variable name="geburtsdatum" as="xs:string?" select="mam:normalize-date($entity/tei:birth[1]/tei:date[1]/text())"/>
        <xsl:variable name="todessort" as="xs:string?" select="$entity/tei:death[1]/tei:settlement[1]/tei:placeName[1]"/>
        <xsl:variable name="todesdatum" as="xs:string?" select="mam:normalize-date($entity/tei:death[1]/tei:date[1]/text())"/>
        <xsl:choose>
            <xsl:when test="$geburtsdatum !='' and $todesdatum != ''">
                <xsl:value-of select="$geburtsdatum"/>
                <xsl:if
                    test="$geburtsort != ''">
                    <xsl:text> </xsl:text>
                    <xsl:value-of
                        select="$geburtsort"/>
                </xsl:if>
                <xsl:text> – </xsl:text>
                <xsl:value-of select="$todesdatum"/>
                <xsl:if
                    test="$todessort != ''">
                    <xsl:text> </xsl:text>
                    <xsl:value-of
                        select="$todessort"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$geburtsdatum !=''">
                <xsl:text>* </xsl:text>
                <xsl:value-of select="$geburtsdatum"/>
                <xsl:if
                    test="$geburtsort != ''">
                    <xsl:text> </xsl:text>
                    <xsl:value-of
                        select="$geburtsort"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="$todesdatum !=''">
                <xsl:text>† </xsl:text>
                <xsl:value-of select="$todesdatum"/>
                <xsl:if
                    test="$todessort != ''">
                    <xsl:text> </xsl:text>
                    <xsl:value-of
                        select="$todessort"/>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
