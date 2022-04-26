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
    <xsl:import href="./partials/place.xsl"/>
    <xsl:variable name="teiSource" select="'listplace.xml'"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Ortsregister'"/>
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
                                <h1><xsl:value-of select="$doc_title"/></h1>
                                <h3>
                                    <a>
                                        <i class="fas fa-info" title="Info zu diesem Ortsregister" data-toggle="modal" data-target="#exampleModal"/>
                                    </a><xsl:text> | </xsl:text>
                                    <a href="{$teiSource}">
                                        <i class="fas fa-download" title="Download XML/TEI"/>
                                    </a>
                                </h3>
                            </div>
                            <div class="card-body">
                            <div class="w-100 text-center">
                                <div class="spinner-grow table-loader" role="status">
                                    <span class="sr-only">Loading...</span>
                                </div>          
                            </div>                                
                                <table class="table table-striped display d-none" id="tocTable" style="width:100%">
                                    <thead>
                                        <tr>
                                            <th scope="col">Ortsname</th>
                                            <th scope="col">Lat/Lng</th>
                                            <th scope="col">Erwähnungen</th>
                                            <th scope="col">Geonames</th>
                                            <th scope="col">ID</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each select=".//tei:place">
                                            <xsl:variable name="id">
                                                <xsl:value-of select="data(@xml:id)"/>
                                            </xsl:variable>
                                            <tr>
                                                <td>
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:value-of select="concat($id, '.html')"/>
                                                        </xsl:attribute>
                                                        <xsl:value-of select=".//tei:placeName[1]/text()"/>
                                                    </a>
                                                </td>
                                                <td>
                                                    <xsl:value-of select=".//tei:geo[1]/text()"/>
                                                </td>
                                                <td>
                                                    <xsl:value-of select="count(.//tei:ptr)"/>
                                                </td>
                                                <td>
                                                    <a>
                                                        <xsl:attribute name="href"><xsl:value-of select=".//tei:idno[@type='geonames']/text()"/></xsl:attribute>
                                                        <xsl:value-of select=".//tei:idno[@type='geonames']/text()"/>
                                                    </a>
                                                </td>
                                                <td>
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:value-of select="concat($id, '.html')"/>
                                                        </xsl:attribute>
                                                        <xsl:value-of select="$id"/>
                                                    </a> 
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div class="modal" tabindex="-1" role="dialog" id="exampleModal">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Info zum Ortsregister</h5>
                                    </div>
                                    <div class="modal-body">
                                        <p>Das vorliegende Ortsverzeichnis umfasst Orte die in den
                                            Tagebucheinträgen erwähnt werden. Die Namensansetzung wurden
                                            von den EditorInnen zum Zwecke besserer Suchmöglichkeiten
                                            normalisiert. Darüberhinaus wurden die Orte auch mit
                                            Koordinaten versehen, wodurch die Orte auf einer Karte
                                            angezeigt werden können. Sofern möglich wurden die Orte auch
                                            mit <a href="http://www.geonames.org/">geonames</a>
                                            verknüpft.</p>
                                        <p>Der Name des jeweiligen Ortes ist mit jenen Dokumenten
                                            verlinkt, in denen dieser Ort erwähnt wird. </p>
                                        <p>Die Sortierung der einzelnen Spalten kann durch einen Klick
                                            auf die Spaltenüberschrift geändert werden. Das Suchfeld
                                            rechts oberhalb der Tabelle durchsucht den gesamten
                                            Tabelleninhalt. Darüberhinaus können mit Hilfe der
                                            Suchfelder am Fußende der Spalten gezielt die Inhalte dieser
                                            Spalten durchsucht bzw. gefiltert werden. </p>
                                        <p>Die (ggf. gefilterte) Tabelle kann als PDF oder Excel
                                            heruntergeladen bzw. in den Zwischenspeicher kopiert
                                            werden.</p>
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
        <xsl:for-each select=".//tei:place">
            <xsl:variable name="filename" select="concat(./@xml:id, '.html')"/>
            <xsl:variable name="name" select="normalize-space(string-join(./tei:placeName[1]//text()))"></xsl:variable>
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
                                        <xsl:call-template name="place_detail"/>
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