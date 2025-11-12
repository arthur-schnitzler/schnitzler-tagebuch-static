<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://dse-static.foo.bar"
    version="2.0" exclude-result-prefixes="xsl tei xs local">
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>

    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select='"404 - Page not found"'/>
        </xsl:variable>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html class="h-100" xmlns="http://www.w3.org/1999/xhtml" lang="de">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
                </xsl:call-template>
            </head>
            <body class="viernullvier-body">
                <xsl:call-template name="nav_bar" />
                <main class="flex-shrink-0 flex-grow-1">
                    <div class="container 404-container" style="height: 75vh;">
                        <h1 class="viernullvier-h1">404</h1>
                        <p class="viernullvier-p lead">
                            Die gewünschte Seite existiert leider nicht.
                        </p>
                        <p class="viernullvier-p lead">Zur <a href="index.html">Startseite</a>.</p>
                        
                    </div>
                </main>
                <xsl:call-template name="html_footer" />
            </body>
        </html>
        
    </xsl:template>
</xsl:stylesheet>