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
    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select=".//tei:title[@type='main'][1]/text()"/>
        </xsl:variable>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html lang="de">
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
            </xsl:call-template>
            <body class="page">
                <script src="https://unpkg.com/js-year-calendar@latest/dist/js-year-calendar.min.js"></script>
                <script src="https://unpkg.com/js-year-calendar@latest/locales/js-year-calendar.de.js"></script>
                <link rel="stylesheet" type="text/css" href="https://unpkg.com/js-year-calendar@latest/dist/js-year-calendar.min.css" />
                <script src="calendarData.js"></script>
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    
                    <div class="container-fluid">                        
                        <div class="card">
                            <div class="card-header" style="text-align:center">
                                <h1 style="display:inline-block;margin-bottom:0;padding-right:5px;">
                                    Kalender</h1>
                                <a>
                                    <i class="fas fa-info" title="Info" data-toggle="modal" data-target="#exampleModal"/>
                                </a>
                                <a style="padding-left:5px;" href="calendar.json">
                                    <i class="fas fa-download" title="Data"/>
                                </a>
                            </div>
                            <div class="card-body containingloader">
                                <div class="row">
                                    <div class="col-sm-2 yearscol">
                                        <div class="row">
                                            <div class="col-sm-12">
                                                <p style="text-align:center;font-weight:bold;margin-bottom:0;">Jahr</p>
                                            </div>
                                        </div>
                                        <div class="row justify-content-md-center" id="years-table">
                                            
                                        </div>
                                    </div>
                                    <div class="col-sm-10">
                                        <div id="calendar"/>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal" tabindex="-1" role="dialog" id="exampleModal">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">Das Tagebuch in Kalenderansicht</h5>
                                </div>
                                <div class="modal-body">
                                    <p>
                                        Fünfzig Jahre lang legte Schnitzler nahezu täglich Einträge an. Über den Kalender können bestimmte Tage direkt aufgefunden werden.
                                    </p>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Close</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <script type="text/javascript" src="js/calendar.js" charset="UTF-8"/>
                    <xsl:call-template name="html_footer"/>
                </div>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>