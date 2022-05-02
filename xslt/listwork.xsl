<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/work.xsl"/>
    <xsl:param name="work-day"
        select="document('../data/indices/index_work_day.xml')"/>
    <xsl:key name="work-day-lookup" match="item/@when" use="ref"/>
    <xsl:variable name="teiSource" select="'listwork.xml'"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Verzeichnis erwähnter (literarischer) Werke'"/>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html lang="de">
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
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
                                <h3>
                                    <a>
                                        <i class="fas fa-info" title="Info zum Verzeichnis der Arbeiten von Arthur Schnitzler und anderer im Tagebuch erwähnter (literarischer) Werke" data-toggle="modal" data-target="#exampleModal"/>
                                    </a><xsl:text> | </xsl:text>
                                    <a href="{$teiSource}">
                                        <i class="fas fa-download" title="Download XML/TEI"/>
                                    </a>
                                </h3>
                            </div>
                            <div class="card-body">
                            <div class="w-100 text-center">
                                <div class="spinner-grow table-loader" role="status">
                                    <span class="sr-only">Wird geladen…</span>
                                </div>          
                            </div>                               
                                <table class="table table-striped display d-none" id="tocTable" style="width:100%">
                                    <thead>
                                        <tr>
                                            <th scope="col">Titel</th>
                                            <th scope="col">Autor:in</th>
                                            <th scope="col">Erwähnungen</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each select=".//tei:bibl">
                                            <xsl:variable name="id">
                                                <xsl:value-of select="data(@xml:id)"/>
                                            </xsl:variable>
                                            <xsl:variable name="titel" select="normalize-space(tei:title[1]/text())"/>
                                            <xsl:for-each select="tei:author">
                                            <tr>
                                                <td><xsl:element name="a">
                                                    <xsl:attribute name="href">
                                                        <xsl:value-of select="concat($id, '.html')"/>
                                                    </xsl:attribute>
                                                    <xsl:value-of select="$titel"/>
                                                    </xsl:element>
                                                </td>
                                                <td>
                                                    <xsl:value-of select="tei:persName[1]/tei:surname/text()"/>, <xsl:value-of select="tei:persName[1]/tei:forename/text()"/>
                                                    <xsl:if test="@role='editor'">
                                                        <xsl:text> (Hrsg.)</xsl:text>
                                                    </xsl:if>
                                                    <xsl:if test="@role='translator'">
                                                        <xsl:text> (Übersetzung)</xsl:text>
                                                    </xsl:if>
                                                    <xsl:if test="@role='illustrator'">
                                                        <xsl:text> (Illustrationen)</xsl:text>
                                                    </xsl:if>
                                                </td>
                                                <td>
                                                    <xsl:value-of select="count(key('work-day-lookup', $id, $work-day))"/>
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
                                        <h5 class="modal-title">Info zum Verzeichnis der Arbeiten von Arthur Schnitzler</h5>
                                    </div>
                                    <div class="modal-body">
                                        <p>Das Register verzeichnet - unter Einschluß der indirekten Erwähnungen, wie etwa 
                                            durch die Namen einzelner Figuren oder durch Verweise auf Proben, Vorlesungen u. a. 
                                            und unter Aufnahme auch der vorläufigen oder in Schnitzlers Schreibweise 
                                            divergierenden Titel sowie unter Einbeziehung des nur im Nachlass überlieferten 
                                            alle im Tagebuch eigens genannten und identifizierten literarischen Arbeiten. 
                                            Verweise auf eigene Briefe und Verweise auf das eigene Tagebuch sowie allgemeine, 
                                            sich offenkundig nicht auf eine einzelne Arbeit beziehende Gattungsbezeichnungen 
                                            bleiben unberücksichtigt. 
                                        </p>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Schließen</button>
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
        <xsl:for-each select=".//tei:bibl">
            <xsl:variable name="filename" select="concat(./@xml:id, '.html')"/>
            <xsl:variable name="name" select="./tei:title[1]/text()"></xsl:variable>
            <xsl:result-document href="{$filename}">
                <html xmlns="http://www.w3.org/1999/xhtml" lang="de">
                    <xsl:call-template name="html_head">
                        <xsl:with-param name="html_title" select="$name"></xsl:with-param>
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
