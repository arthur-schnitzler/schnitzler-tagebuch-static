<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:foo="whatever" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0"
    exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes"
        omit-xml-declaration="yes"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/place.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Erwähnte Orte'"/>
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
                            <div class="card-body">
                                <table class="table table-striped display" id="tocTable"
                                    style="width:100%">
                                    <thead>
                                        <tr>
                                            <th scope="col">Ortsname</th>
                                            <th scope="col">Längen-/Breitengrad</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each select="descendant::tei:place">
                                            <xsl:variable name="id">
                                                <xsl:value-of select="data(@xml:id)"/>
                                            </xsl:variable>
                                            <tr>
                                                <td>
                                                  <a>
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of select="concat($id, '.html')"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of
                                                  select="descendant::tei:placeName[1]/text()"/>
                                                  </a>
                                                </td>
                                                <td>
                                                  <xsl:if test="descendant::tei:geo[1]">
                                                  <xsl:variable name="lat"
                                                  select="replace(tokenize(descendant::tei:geo[1]/text(), ' ')[1], ',', '.')"
                                                  as="xs:string"/>
                                                  <xsl:variable name="long"
                                                  select="replace(tokenize(descendant::tei:geo[1]/text(), ' ')[2], ',', '.')"
                                                  as="xs:string"/>
                                                  <xsl:value-of
                                                  select="concat(foo:grad-kuerzen($lat), '/', foo:grad-kuerzen($long))"
                                                  />
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
        <xsl:for-each select=".//tei:place">
            <xsl:variable name="filename" select="concat(./@xml:id, '.html')"/>
            <xsl:variable name="name" select="./tei:placeName[1]/text()"/>
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
    <xsl:function name="foo:grad-kuerzen">
        <xsl:param name="eingangs-grad" as="xs:string"/>
        <xsl:variable name="vordempunkt" as="xs:string"
            select="substring-before($eingangs-grad, '.')"/>
        <xsl:variable name="nachdempunkt" as="xs:string"
            select="substring-after($eingangs-grad, '.')"/>
        <xsl:choose>
            <xsl:when test="string-length($nachdempunkt) &gt; 4">
                <xsl:value-of select="concat($vordempunkt, '.', substring($nachdempunkt, 1, 4))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$eingangs-grad"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>
