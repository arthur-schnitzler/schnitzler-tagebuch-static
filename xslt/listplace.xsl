<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:foo="whatever" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0"
    exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes" omit-xml-declaration="yes"  doctype-system="" doctype-public=""/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/entities.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Erwähnte Orte'"/>
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
        <html xmlns="http://www.w3.org/1999/xhtml" lang="de">
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"/>
            </xsl:call-template>
            <link href="https://unpkg.com/tabulator-tables@6.2.1/dist/css/tabulator_bootstrap5.min.css" rel="stylesheet" />
            <link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"
                integrity="sha256-p4NxAoJBhIIN+hmNHrzRCf9tD/miZyoHS5obTRR9BMY=" crossorigin=""/>
            <script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js" integrity="sha256-20nQCchB9co0qIjJZRGuk2/Z9VM+kNiyxNV1lvTlZBo=" crossorigin=""/>
            <link rel="stylesheet"
                href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.css"/>
            <link rel="stylesheet"
                href="https://unpkg.com/leaflet.markercluster@1.4.1/dist/MarkerCluster.Default.css"/>
            <script src="https://unpkg.com/leaflet.markercluster@1.4.1/dist/leaflet.markercluster.js"/>
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    <div class="container">
                        <div >
                            <div class="card-header" style="text-align:center">
                                <h1>
                                    <xsl:value-of select="$doc_title"/>
                                </h1>
                            </div>
                            <div class="card-body">
                                <div id="map"/>
                                <div id="container" class="mb-3" style="max-width:1200px; margin: 0 auto; width: 100%;">
                                <table id="placesTable"
                                    style="width:100%">
                                    <thead>
                                        <tr>
                                            <th scope="col">Ortsname</th>
                                            <th scope="col">Zugehörigkeit</th>
                                            <th scope="col">Erwähnungen</th>
                                            <th scope="col">lat</th>
                                            <th scope="col">lng</th>
                                            <th scope="col">linkToEntity</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each select=".//tei:place">
                                            <xsl:variable name="id">
                                                <xsl:value-of select="data(@xml:id)"/>
                                            </xsl:variable>
                                            <tr>
                                                <td>
                                                    <xsl:value-of
                                                        select="descendant::tei:placeName[1]/text()"/>
                                                </td>
                                                <td>
                                                    <xsl:for-each select="descendant::tei:location[@type='located_in_place']">
                                                        <xsl:value-of select="tei:placeName[1]"/>
                                                        <xsl:if test="not(position()=last())">
                                                            <xsl:text>, </xsl:text>
                                                        </xsl:if>
                                                    </xsl:for-each>
                                                </td>
                                                <td>
                                                    <xsl:value-of
                                                        select="count(descendant::tei:ptr)"/>
                                                </td>
                                                <td>
                                                    <xsl:choose>
                                                        <xsl:when test="child::tei:location/tei:geo">
                                                            <xsl:value-of
                                                                select="replace(tokenize(child::tei:location[1]/tei:geo/text(), ' ')[1], ',', '.')"
                                                            />
                                                        </xsl:when>
                                                    </xsl:choose>
                                                </td>
                                                <td>
                                                    <xsl:choose>
                                                        <xsl:when test="child::tei:location/tei:geo">
                                                            <xsl:value-of
                                                                select="replace(tokenize(child::tei:location[1]/tei:geo/text(), ' ')[last()], ',', '.')"
                                                            />
                                                        </xsl:when>
                                                    </xsl:choose>
                                                </td>
                                                <td>
                                                    <xsl:value-of select="$id"/>
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </tbody>
                                </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    <xsl:call-template name="html_footer"/>
                    <script type="text/javascript" src="https://unpkg.com/tabulator-tables@5.5.2/dist/js/tabulator.min.js"/>
                    <script src="js/map_table_cfg.js"/>
                    <script src="js/make_map_and_table.js"/>
                    <script>
                        build_map_and_table(map_cfg, table_cfg, wms_cfg=null, tms_cfg=null);
                    </script>
                </div>
            </body>
        </html>
        <xsl:for-each select=".//tei:place">
            <xsl:variable name="filename" select="concat(./@xml:id, '.html')"/>
            <xsl:variable name="name" select="./tei:placeName[1]/text()"/>
            <xsl:result-document href="{$filename}">
                <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
                <html xmlns="http://www.w3.org/1999/xhtml" lang="de">
                    <xsl:call-template name="html_head">
                        <xsl:with-param name="html_title" select="$name"/>
                    </xsl:call-template>
                    <body class="page">
                        <div class="hfeed site" id="page">
                            <xsl:call-template name="nav_bar"/>
                            <div class="container-fluid">
                                <div>
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
