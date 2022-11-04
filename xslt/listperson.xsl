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
    <xsl:import href="./partials/person.xsl"/>
    <xsl:variable name="teiSource" select="'listperson.xml'"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Verzeichnis erwähnter Personen'"/>
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
        <html lang="de">
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"/>
            </xsl:call-template>
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
                                <table class="table table-striped display" id="tocTable"
                                    style="width:100%">
                                    <thead>
                                        <tr>
                                            <th scope="col">Name</th>
                                            <th scope="col">Lebensdaten</th>
                                            <th scope="col">Beruf</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each select="descendant::tei:listPerson[1]/tei:person">
                                            <xsl:variable name="entiyID"
                                                select="replace(@xml:id, '#', '')"/>
                                            <xsl:variable name="entity" as="node()" select="."/>
                                            <tr>
                                                <td>
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:value-of
                                                                select="concat($entity/@xml:id, '.html')"/>
                                                        </xsl:attribute>
                                                        <xsl:choose>
                                                            <xsl:when
                                                                test="starts-with($entity/tei:persName[1]/tei:surname[1]/text(), '??')">
                                                                <span hidden="true">ZZZ</span>
                                                                <xsl:value-of
                                                                    select="$entity/tei:persName[1]/tei:surname[1]/text()"/>
                                                            </xsl:when>
                                                            <xsl:when
                                                                test="$entity/tei:persName[1]/tei:surname[1]/text() and $entity/tei:persName[1]/tei:forename[1]/text()">
                                                                <span hidden="true">
                                                                    <xsl:value-of
                                                                        select="$entity/tei:persName[1]/tei:surname[1]/text()"/><xsl:value-of
                                                                            select="$entity/tei:persName[1]/tei:forename[1]/text()"/>
                                                                </span>
                                                                <xsl:value-of
                                                                    select="$entity/tei:persName[1]/tei:forename[1]/text()"/>
                                                                <xsl:text> </xsl:text>
                                                                <xsl:value-of
                                                                    select="$entity/tei:persName[1]/tei:surname[1]/text()"/>
                                                            </xsl:when>
                                                            <xsl:when test="$entity/tei:persName[1]/tei:surname[1]/text()">
                                                                <xsl:value-of
                                                                    select="$entity/tei:persName[1]/tei:surname[1]/text()"/>
                                                            </xsl:when>
                                                            <xsl:when test="$entity/tei:persName[1]/tei:forename[1]/text()">
                                                                <xsl:value-of
                                                                    select="$entity/tei:persName[1]/tei:forename[1]/text()"/>
                                                            </xsl:when>
                                                            <xsl:otherwise>
                                                                <xsl:value-of select="$entity/tei:persName[1]/tei:persName[1]"/>
                                                            </xsl:otherwise>
                                                        </xsl:choose>
                                                    </a>
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
                                                                    <xsl:when test="contains(.,'&gt;&gt;')">
                                                                        <xsl:value-of select="tokenize(.,'&gt;&gt;')[last()]"/>
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
                            </div>
                        </div>
                    </div>
                    <xsl:call-template name="html_footer"/>
                    <script>
                        $(document).ready(function () {
                        createDataTable('tocTable')
                        });
                    </script>
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
                                    <xsl:call-template name="person_detail"/>
                                </div>
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
