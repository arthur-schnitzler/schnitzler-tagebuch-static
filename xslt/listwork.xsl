<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes"
        omit-xml-declaration="yes"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/work.xsl"/>
    <xsl:param name="work-day" select="document('../data/indices/index_work_day.xml')"/>
    <xsl:key name="work-day-lookup" match="item/@when" use="ref"/>
    <xsl:variable name="teiSource" select="'listwork.xml'"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Verzeichnis erwähnter Werke'"/>
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
                                <div class="w-100 text-center">
                                    <div class="spinner-grow table-loader" role="status">
                                        <span class="sr-only">Wird geladen…</span>
                                    </div>
                                </div>
                                <table class="table table-striped display" id="tocTable"
                                    style="width:100%">
                                    <thead>
                                        <tr>
                                            <th scope="col">Titel</th>
                                            <th scope="col">Autorin, Autor</th>
                                            <th scope="col">Datum</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each select="descendant::tei:listBibl/tei:bibl">
                                            <xsl:variable name="id">
                                                <xsl:value-of select="data(@xml:id)"/>
                                            </xsl:variable>
                                            <xsl:variable name="titel"
                                                select="normalize-space(tei:title[1]/text())"/>
                                            <xsl:variable name="datum">
                                                <xsl:choose>
                                                    <xsl:when test="contains(tei:date/text(), '>&lt;')">
                                                        <xsl:value-of select="substring-before(tei:date/text(), '>&lt;')"/>
                                                    </xsl:when>
                                                    <xsl:otherwise>
                                                        <xsl:value-of select="tei:date"/>
                                                    </xsl:otherwise>
                                                </xsl:choose>
                                            </xsl:variable>
                                            <xsl:for-each select="tei:author">
                                                <tr>
                                                    <td>
                                                        <xsl:element name="a">
                                                            <xsl:attribute name="href">
                                                                <xsl:value-of select="concat($id, '.html')"/>
                                                            </xsl:attribute>
                                                            <xsl:value-of select="$titel"/>
                                                        </xsl:element>
                                                    </td>
                                                    <td>
                                                        <a>
                                                            <xsl:attribute name="href">
                                                                <xsl:value-of select="concat(@ref, '.html')"/>
                                                            </xsl:attribute>
                                                            <xsl:value-of select="."/>
                                                        </a>
                                                        <xsl:if
                                                            test="@role = 'editor' or @role = 'hat-herausgegeben'">
                                                            <xsl:text> (Hrsg.)</xsl:text>
                                                        </xsl:if>
                                                        <xsl:if
                                                            test="@role = 'translator' or @role = 'hat-ubersetzt'">
                                                            <xsl:text> (Übersetzung)</xsl:text>
                                                        </xsl:if>
                                                        <xsl:if
                                                            test="@role = 'illustrator' or @role = 'hat-illustriert'">
                                                            <xsl:text> (Illustrationen)</xsl:text>
                                                        </xsl:if>
                                                    </td>
                                                    <td>
                                                        <xsl:value-of select="$datum"/>
                                                    </td>
                                                </tr>
                                            </xsl:for-each>
                                        </xsl:for-each>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div class="modal" tabindex="-1" role="dialog" id="exampleModal">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Info zum Verzeichnis der
                                            Arbeiten</h5>
                                    </div>
                                    <div class="modal-body">
                                        <p>Das Register verzeichnet alle - unter Einschluss der
                                            indirekten Erwähnungen, wie etwa durch die Namen
                                            einzelner Figuren oder durch Verweise auf Proben,
                                            Vorlesungen u. a. – identifizierte Kunstwerke. </p>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary"
                                            data-dismiss="modal">Schließen</button>
                                    </div>
                                </div>
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
        <xsl:for-each select="descendant::tei:bibl[@xml:id]">
            <xsl:variable name="filename" select="concat(./@xml:id, '.html')"/>
            <xsl:variable name="name" select="./tei:title[1]/text()"/>
            <xsl:result-document href="{$filename}">
                <html xmlns="http://www.w3.org/1999/xhtml" lang="de">
                    <xsl:call-template name="html_head">
                        <xsl:with-param name="html_title" select="$name"/>
                    </xsl:call-template>
                    <body class="page">
                        <div class="hfeed site" id="page">
                            <xsl:call-template name="nav_bar"/>
                            <div class="container-fluid">
                                <div class="card">
                                    <div class="card-header">
                                        <h1 align="center">
                                            <xsl:value-of select="$name"/>
                                        </h1>
                                    </div>
                                    <div class="card-body">
                                        <xsl:call-template name="work_detail"/>
                                    </div>
                                </div>
                            </div>
                            <xsl:call-template name="html_footer"/>
                        </div>
                    </body>
                </html>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
