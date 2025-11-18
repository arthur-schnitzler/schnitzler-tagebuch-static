<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:local="http://dse-static.foo.bar" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes" omit-xml-declaration="yes"/>
    <xsl:import href="./partials/shared.xsl"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>
    <xsl:import href="partials/osd-container.xsl"/>
    <xsl:import href="partials/tei-facsimile.xsl"/>
    <xsl:variable name="currentDate">
        <xsl:value-of select="format-date(current-date(), '[Y]-[M01]-[D01]')"/>
    </xsl:variable>
    <xsl:variable name="pid">
        <xsl:value-of select="//tei:publicationStmt//tei:idno[@type = 'URI']/text()"/>
    </xsl:variable>
    <xsl:variable name="doc_title">
        <xsl:value-of select=".//tei:title[@type = 'main'][1]/text()"/>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
        <html xmlns="http://www.w3.org/1999/xhtml" lang="de">
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"/>
                <xsl:with-param name="page_url" select="concat('https://schnitzler-tagebuch.acdh.oeaw.ac.at/', child::tei:TEI/@xml:id, '.html')"/>
            </xsl:call-template>
            <body role="document" class="home contained fixed-nav" id="body">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    <div class="hfeed site" id="page">
                        <div class="container-fluid">
                            <div class="card">
                                <div class="card-header">
                                    <h2 align="center">
                                        <xsl:value-of select="$doc_title"/>
                                    </h2>
                                </div>
                                <div class="card-body-index">
                                    <xsl:apply-templates select=".//tei:body"/>
                                </div>
                                <div class="card-footer text-muted" style="text-align:center">
                                    <div id="srcbuttons">
                                        <div class="res-act-button res-act-button-copy-url"
                                            id="res-act-button-copy-url">
                                            <span id="copy-url-button" data-toggle="modal"
                                                data-target="#quoteModal">
                                                <i class="fas fa-quote-right"/> ZITIEREN </span>
                                        </div>
                                        <a class="ml-3" href="about.xml">
                                            <i class="fa-lg far fa-file-code"/> TEI </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <xsl:call-template name="html_footer"/>
                </div>
            </body>
            <div class="modal fade" id="quoteModal" tabindex="-1" role="dialog"
                aria-labelledby="quoteModalLabel" aria-hidden="true">
                <div class="modal-dialog" role="document">
                    <div class="modal-content">
                        <div class="modal-header">
                            <h5 class="modal-title" id="quoteModalLabel">Zitiervorschlag</h5>
                        </div>
                        <div class="modal-body"> Arthur Schnitzler: Tagebuch. Digitale Edition,
                                <xsl:value-of select="$doc_title"/>,
                            <xsl:value-of select="concat('https://schnitzler-tagebuch.acdh.oeaw.ac.at/', child::tei:TEI/@xml:id, '.html')"/>
                            (Stand <xsl:value-of select="$currentDate"/>). </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-dismiss="modal"
                                >Schließen</button>
                        </div>
                    </div>
                </div>
            </div>
        </html>
    </xsl:template>
    <xsl:template match="tei:ref">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="data(./@target)"/>
            </xsl:attribute>
            <xsl:value-of select="./text()"/>
        </a>
    </xsl:template>
    <xsl:template match="tei:p">
        <p id="{local:makeId(.)}">
            <xsl:apply-templates/>
        </p>
    </xsl:template>
    <xsl:template match="tei:div">
        <div id="{local:makeId(.)}">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:list">
        <ul id="{local:makeId(.)}">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    <xsl:template match="tei:item">
        <li id="{local:makeId(.)}">
            <xsl:apply-templates/>
        </li>
    </xsl:template>
</xsl:stylesheet>
