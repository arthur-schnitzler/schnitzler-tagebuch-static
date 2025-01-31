<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://dse-static.foo.bar"
    xmlns:mam="whatever" version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes"
        omit-xml-declaration="yes"/>
    <xsl:import href="./partials/shared.xsl"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/osd-container.xsl"/>
    <xsl:import href="./partials/tei-facsimile.xsl"/>
    <xsl:import href="./partials/entities.xsl"/>
    <xsl:import href="./partials/html_title_navigation.xsl"/>
    <xsl:import href="./partials/view-type.xsl"/>
    <!-- Einstellungen für die Schnitzler-Chronik. Das entfernte XSL wird nur benützt, wenn fetch-locally auf  -->
    <xsl:import href="https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-chronik-static/refs/heads/main/xslt/export/schnitzler-chronik.xsl"/>
    <!--<xsl:import href="../../schnitzler-chronik-static/xslt/export/schnitzler-chronik.xsl"/>-->
    <xsl:param name="schnitzler-chronik_fetch-locally" as="xs:boolean" select="true()"/>
    <xsl:param name="schnitzler-chronik_current-type" as="xs:string" select="'schnitzler-tagebuch'"/>
    
    <xsl:import href="./partials/biblStruct-output.xsl"/>
    <xsl:param name="quotationURL"/>
    <xsl:param name="chronik-dir">../chronik-data</xsl:param>
    <xsl:variable name="chronik-data"
        select="collection(concat($chronik-dir, '/?select=L0*.xml;recurse=yes'))"/>
    <xsl:variable name="prev">
        <xsl:value-of select="replace(tokenize(data(tei:TEI/@prev), '/')[last()], '.xml', '.html')"
        />
    </xsl:variable>
    <xsl:variable name="next">
        <xsl:value-of select="replace(tokenize(data(tei:TEI/@next), '/')[last()], '.xml', '.html')"
        />
    </xsl:variable>
    <xsl:variable name="teiSource">
        <xsl:value-of select="replace(data(tei:TEI/@xml:id), '.xml', '')"/>
    </xsl:variable>
    <xsl:variable name="link">
        <xsl:value-of select="replace($teiSource, '.xml', '.html')"/>
    </xsl:variable>
    <xsl:variable name="doc_title">
        <xsl:value-of select=".//tei:title[@type = 'main'][1]/text()"/>
    </xsl:variable>
    <xsl:variable name="entryDate">
        <xsl:value-of select="xs:date(//tei:title[@type = 'iso-date']/text())"/>
    </xsl:variable>
    <xsl:variable name="doctitle">
        <xsl:value-of select="//tei:teiHeader//tei:titleStmt/tei:title[@type = 'main']/text()"/>
    </xsl:variable>
    <xsl:variable name="currentDate">
        <xsl:value-of select="format-date(current-date(), '[D1].&#160;[M1].&#160;[Y4]')"/>
    </xsl:variable>
    <xsl:variable name="pid">
        <xsl:value-of select="//tei:publicationStmt//tei:idno[@type = 'URI']/text()"/>
    </xsl:variable>
    <xsl:variable name="source_volume">
        <xsl:value-of
            select="replace(//tei:monogr//tei:biblScope[@unit = 'volume']/text(), '-', '_')"/>
    </xsl:variable>
    <xsl:variable name="source_base_url"
        >https://austriaca.at/buecher/files/arthur_schnitzler_tagebuch/Tagebuch1879-1931Einzelseiten/schnitzler_tb_</xsl:variable>
    <xsl:variable name="source_page_nr">
        <xsl:value-of
            select="format-number(//tei:monogr//tei:biblScope[@unit = 'page']/text(), '000')"/>
    </xsl:variable>
    <xsl:variable name="source_pdf">
        <xsl:value-of
            select="concat($source_base_url, $source_volume, 's', $source_page_nr, '.pdf')"/>
    </xsl:variable>
    <xsl:variable name="current-date">
        <xsl:value-of select="substring-after($doctitle, ': ')"/>
    </xsl:variable>
    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select="descendant::tei:titleStmt[1]/tei:title[@type = 'main'][1]/text()"
            />
        </xsl:variable>
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
        <html lang="de">
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"/>
            </xsl:call-template>
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    <div class="container-fluid">
                        <div class="wp-transcript">
                            <div class="card" data-index="true">
                                <div class="card-header">
                                    <div class="row">
                                        <div class="col-md-2">
                                            <xsl:if test="ends-with($prev, '.html')">
                                                <h2>
                                                  <a>
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of select="$prev"/>
                                                  </xsl:attribute>
                                                  <i class="fas fa-chevron-left" title="prev"/>
                                                  </a>
                                                </h2>
                                            </xsl:if>
                                        </div>
                                        <div class="col-md-8">
                                            <h1 align="center">
                                                <xsl:value-of select="$doc_title"/>
                                            </h1>
                                        </div>
                                        <div class="col-md-2" style="text-align:right">
                                            <xsl:if test="ends-with($next, '.html')">
                                                <h1>
                                                  <a>
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of select="$next"/>
                                                  </xsl:attribute>
                                                  <i class="fas fa-chevron-right" title="next"/>
                                                  </a>
                                                </h1>
                                            </xsl:if>
                                        </div>
                                    </div>
                                </div>
                                <div class="card-body-normalertext" data-index="true">
                                    <xsl:apply-templates select=".//tei:body"/>
                                </div>
                            </div>
                            <div class="card-footer" style="clear: both;">
                                <nav class="navbar navbar-expand-lg" style="box-shadow: none;">
                                    <div class="container-fluid">
                                        <div id="navbarSupportedContent">
                                            <ul class="navbar-nav mb-2 mb-lg-0" id="secondary-menu">
                                                <li class="nav-item"> &#160;<a href="#"
                                                  data-bs-target="#entitaeten" type="button"
                                                  data-bs-toggle="modal"
                                                  title="Entitäten in diesem Eintrag">
                                                  <i class="fas fa-sharp fa-solid fa-people-group"/>
                                                  ENTITÄTEN </a>&#160; </li>
                                                <li class="nav-item"> &#160;<a href="#"
                                                  data-bs-target="#zitat" type="button"
                                                  data-bs-toggle="modal"
                                                  title="Zitiervorschlag zu diesem Eintrag">
                                                  <i class="fas fa-quote-right"/> ZITIEREN
                                                  </a>&#160; </li>
                                                <li class="nav-item"> &#160; <a href="#"
                                                  title="Faksimile zu diesem Eintrag"
                                                  data-bs-toggle="modal" type="button"
                                                  data-bs-target="#faks-modal">
                                                  <i class="fa-lg far fa-file-image"/> FAKSIMILE
                                                  </a>&#160; </li>
                                                <li class="nav-item"> &#160;<a href="#"
                                                  data-bs-target="#downloadModal" type="button"
                                                  data-bs-toggle="modal"
                                                  title="Diesen Eintrag herunterladen"><i
                                                  class="fas fa-solid fa-download"/> DOWNLOAD
                                                  </a>&#160; </li>
                                                <li class="nav-item"> &#160;<a href="#"
                                                  data-bs-target="#chronik" type="button"
                                                  data-bs-toggle="modal"
                                                  title="Weitere Ereignisse an diesem Tag">
                                                  <i class="fas fa-calendar-day"/> CHRONIK
                                                  </a>&#160; </li>
                                            </ul>
                                        </div>
                                    </div>
                                </nav>
                            </div>
                            <xsl:call-template name="html_footer"/>
                            <div class="d-flex justify-content-between">
                                <span id="isoDateValue" style="color:white">
                                    <xsl:value-of select="descendant::tei:titleStmt[1]/tei:title[@type = 'iso-date'][1]/text()"/>
                                </span>
                                
                                <span id="isoDateValueLink" style="color:white">
                                    <xsl:element name="a">
                                        <xsl:attribute name="style">
                                            <xsl:text>color:white</xsl:text>
                                        </xsl:attribute>
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="concat('https://wienerschnitzler.org/tag.html#', descendant::tei:titleStmt[1]/tei:title[@type = 'iso-date'][1]/text())"/>
                                        </xsl:attribute>
                                        <xsl:attribute name="target">_blank</xsl:attribute>
                                        <xsl:value-of select="descendant::tei:titleStmt[1]/tei:title[@type = 'iso-date'][1]/text()"/>
                                    </xsl:element>
                                </span>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Modal Entitäten -->
                <div class="modal fade" id="entitaeten" tabindex="-1"
                    aria-labelledby="entitaetenModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="exampleModalLabel">Erwähnte
                                    Entitäten</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Schließen"/>
                            </div>
                            <div class="modal-body">
                                <div>
                                    <xsl:if test="//tei:back/tei:listPerson/tei:person[1]">
                                        <legend>Personen</legend>
                                        <ul>
                                            <xsl:for-each
                                                select="descendant::tei:back/tei:listPerson/tei:person">
                                                <li>
                                                  <a>
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of
                                                  select="concat(data(@xml:id), '.html')"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of select="child::tei:persName[1]"/>
                                                  </a>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </xsl:if>
                                </div>
                                <div>
                                    <xsl:if test=".//tei:back/tei:listBibl/tei:bibl[1]">
                                        <legend>Werke</legend>
                                        <ul>
                                            <xsl:for-each
                                                select="descendant::tei:back/tei:listBibl/tei:bibl">
                                                <li>
                                                  <a>
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of
                                                  select="concat(data(@xml:id), '.html')"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of
                                                  select="tei:title[@type = 'main'][1]"/>
                                                  </a>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </xsl:if>
                                </div>
                                <div>
                                    <xsl:if test="//tei:back/tei:listPlace/tei:place[1]">
                                        <legend>Orte</legend>
                                        <ul>
                                            <xsl:for-each
                                                select="descendant::tei:back/tei:listPlace/tei:place">
                                                <li>
                                                  <a>
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of
                                                  select="concat(data(@xml:id), '.html')"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of
                                                  select="child::tei:placeName[1]/text()"/>
                                                  </a>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </xsl:if>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary"
                                    data-bs-dismiss="modal">Schließen</button>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Modal Zitat -->
                <div class="modal fade" id="zitat" tabindex="-1" aria-labelledby="zitatModalLabel"
                    aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="exampleModalLabel">Zitiervorschlag</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Schließen"/>
                            </div>
                            <div class="modal-body"> Arthur Schnitzler: Tagebuch. Digitale Edition,
                                    <xsl:value-of select="$doctitle"/>,
                                    https://schnitzler-tagebuch.acdh.oeaw.ac.at/entry__<xsl:value-of
                                    select="descendant::tei:teiHeader[1]/tei:fileDesc[1]/tei:titleStmt[1]/tei:title[@type = 'iso-date']"
                                />.html (Stand <xsl:value-of select="$currentDate"/>), PID:
                                    <xsl:value-of select="$pid"/>. </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary"
                                    data-bs-dismiss="modal">Schließen</button>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Modal Faksimile -->
                <div class="modal fade" id="faks-modal" tabindex="-1" role="dialog"
                    aria-labelledby="exampleModalLabel" aria-hidden="true">
                    <div class="modal-dialog modal-lg faksimile-modal" role="document" style="max-width: 75%;">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="faksimile">Faksimile</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Schließen"/>
                            </div>
                            <div class="modal-body">
                                <div id="openseadragon-photo" style="height: 850px;"/>
                                <script src="https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.1/openseadragon.min.js"/>
                                <script type="text/javascript">
                                    var viewer = OpenSeadragon({
                                        id: "openseadragon-photo",
                                        protocol: "http://iiif.io/api/image",
                                        prefixUrl: "https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.1/images/",
                                        sequenceMode: true,
                                        showReferenceStrip: true,
                                        tileSources:[<xsl:for-each select=".//tei:facsimile/tei:graphic/data(@url)">{
                                        type: 'image',
                                        url: '<xsl:value-of select="concat(., '?format=iiif')"/>'
                                        }
                                        <xsl:choose>
                                            <xsl:when test="position() != last()">,</xsl:when>
                                        </xsl:choose></xsl:for-each>
]
                                });</script>
                            </div>
                            <div class="modal-footer" style="justify-content: flex-start;">
                                <ul style="list-style-type: none;">
                                    <xsl:for-each select=".//tei:facsimile/tei:graphic/data(@url)">
                                        <li>
                                            <a>
                                                <xsl:attribute name="href">
                                                  <xsl:value-of select="concat(., '?format=gui')"/>
                                                </xsl:attribute>
                                                <xsl:value-of select="."/>
                                            </a>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </div>
                        </div>
                    </div>
                </div>
                <!--<xsl:for-each select=".//tei:back/tei:listPerson/tei:person[@xml:id]">
                    <xsl:variable name="xmlId">
                        <xsl:value-of select="data(./@xml:id)"/>
                    </xsl:variable>
                    <div class="modal fade" tabindex="-1" role="dialog" aria-hidden="true"
                        id="{$xmlId}">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">
                                        <xsl:value-of
                                            select="normalize-space(string-join(.//tei:persName[1]//text()))"/>
                                        <xsl:text> </xsl:text>
                                        <a href="{concat($xmlId, '.html')}">
                                            <i class="fas fa-external-link-alt"/>
                                        </a>
                                    </h5>
                                </div>
                                <div class="modal-body">
                                    <xsl:call-template name="person_detail">
                                        <xsl:with-param name="showNumberOfMentions" select="5"/>
                                    </xsl:call-template>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary"
                                        data-dismiss="modal">Schließen</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </xsl:for-each>-->
                <!--<xsl:for-each select=".//tei:back/tei:listPlace/tei:place[@xml:id]">
                    <xsl:variable name="xmlId">
                        <xsl:value-of select="data(./@xml:id)"/>
                    </xsl:variable>
                    <div class="modal fade" tabindex="-1" role="dialog" aria-hidden="true"
                        id="{$xmlId}">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title">
                                        <xsl:value-of
                                            select="normalize-space(string-join(.//tei:placeName[1]/text()))"/>
                                        <xsl:text> </xsl:text>
                                        <a href="{concat($xmlId, '.html')}">
                                            <i class="fas fa-external-link-alt"/>
                                        </a>
                                    </h5>
                                </div>
                                <div class="modal-body">
                                    <xsl:call-template name="place_detail">
                                        <xsl:with-param name="showNumberOfMentions" select="5"/>
                                    </xsl:call-template>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary"
                                        data-dismiss="modal">Schließen</button>
                                </div>
                            </div>
                        </div>
                    </div>
                </xsl:for-each>-->
                <!-- Modal Download -->
                <div class="modal fade" id="downloadModal" tabindex="-1"
                    aria-labelledby="downloadModalLabel" aria-hidden="true">
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="exampleModalLongTitle4"
                                    >Downloadmöglichkeiten</h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Schließen"/>
                            </div>
                            <div class="modal-body">
                                <p>
                                    <a class="ml-3" data-toggle="tooltip" title="Eintrag als PDF">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="$source_pdf"/>
                                        </xsl:attribute>
                                        <i class="fa-lg far fa-file-pdf"/> PDF </a>
                                </p>
                                <p>
                                    <a class="ml-3" data-toggle="tooltip"
                                        title="Eintrag als TEI-Datei">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="$teiSource"/>
                                        </xsl:attribute>
                                        <i class="fa-lg far fa-file-code"/> TEI </a>
                                </p>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary"
                                    data-bs-dismiss="modal">Schließen</button>
                            </div>
                        </div>
                    </div>
                </div>
                <!-- Modal Chronik -->
                <div class="modal fade" id="chronik" tabindex="-1"
                    aria-labelledby="downloadModalLabel2" aria-hidden="true">
                     <xsl:variable name="datum"
                            select="descendant::tei:title[@type = 'iso-date']/text()" as="xs:date"/>
                    <xsl:variable name="datum-written" select="
                        format-date($datum, '[D1].&#160;[M1].&#160;[Y0001]',
                        'en',
                        'AD',
                        'EN')"/>
                    <xsl:variable name="wochentag">
                        <xsl:choose>
                            <xsl:when test="
                                format-date($datum, '[F]',
                                'en',
                                'AD',
                                'EN') = 'Monday'">
                                <xsl:text>Montag</xsl:text>
                            </xsl:when>
                            <xsl:when test="
                                format-date($datum, '[F]',
                                'en',
                                'AD',
                                'EN') = 'Tuesday'">
                                <xsl:text>Dienstag</xsl:text>
                            </xsl:when>
                            <xsl:when test="
                                format-date($datum, '[F]',
                                'en',
                                'AD',
                                'EN') = 'Wednesday'">
                                <xsl:text>Mittwoch</xsl:text>
                            </xsl:when>
                            <xsl:when test="
                                format-date($datum, '[F]',
                                'en',
                                'AD',
                                'EN') = 'Thursday'">
                                <xsl:text>Donnerstag</xsl:text>
                            </xsl:when>
                            <xsl:when test="
                                format-date($datum, '[F]',
                                'en',
                                'AD',
                                'EN') = 'Friday'">
                                <xsl:text>Freitag</xsl:text>
                            </xsl:when>
                            <xsl:when test="
                                format-date($datum, '[F]',
                                'en',
                                'AD',
                                'EN') = 'Saturday'">
                                <xsl:text>Samstag</xsl:text>
                            </xsl:when>
                            <xsl:when test="
                                format-date($datum, '[F]',
                                'en',
                                'AD',
                                'EN') = 'Sunday'">
                                <xsl:text>Sonntag</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>DATUMSFEHLER</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:variable>
                    <div class="modal-dialog">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="exampleModalLongTitle3">
                                    <a
                                        href="{concat('https://schnitzler-chronik.acdh.oeaw.ac.at/', $datum, '.html')}"
                                        target="_blank" style="color: #C67F53">
                                        <xsl:value-of
                                            select="concat($wochentag, ', ', $datum-written)"/>
                                    </a>
                                </h5>
                                <button type="button" class="btn-close" data-bs-dismiss="modal"
                                    aria-label="Schließen"/>
                            </div>
                            <xsl:variable name="relevant-eventtypes" as="xs:string" select="'Arthur-Schnitzler-digital,schnitzler-briefe,pollaczek,schnitzler-interviews,schnitzler-bahr,schnitzler-orte,schnitzler-chronik-manuell,pmb,schnitzler-events,schnitzler-cmif,schnitzler-mikrofilme-daten,schnitzler-traeume-buch,schnitzler-kino-buch,schnitzler-kempny-buch,kalliope-verbund'"/>
                            <!-- Achtung, kein Tagebuch, weil es ja keine zwei Einträge an einem Tag gibt -->
                            <div class="modal-body">
                                <div id="chronik-modal-body"/>
                                <!-- SCHNITZLER-CHRONIK. Zuerst wird der Eintrag geladen, weil das schneller ist, wenn er lokal vorliegt -->
                                <xsl:variable name="fetchContentsFromURL" as="node()?">
                                    <xsl:choose>
                                        <xsl:when test="$schnitzler-chronik_fetch-locally">
                                            <xsl:copy-of
                                                select="document(concat('../chronik-data/', $datum, '.xml'))"/>
                                            <!-- das geht davon aus, dass das schnitzler-chronik-repo lokal vorliegt -->
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:copy-of
                                                select="document(concat('https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-chronik-data/refs/heads/main/editions/data/', $datum, '.xml'))"
                                            />
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:variable>
                                <xsl:call-template name="mam:schnitzler-chronik">
                                    <xsl:with-param name="datum-iso" select="$datum"/>
                                    <xsl:with-param name="current-type" select="$schnitzler-chronik_current-type"/>
                                    <xsl:with-param name="teiSource" select="$teiSource"/>
                                    <xsl:with-param name="fetchContentsFromURL" select="$fetchContentsFromURL" as="node()?"/>
                                </xsl:call-template>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary"
                                    data-bs-dismiss="modal">Schließen</button>
                            </div>
                        </div>
                    </div>
                </div>
                <!--<script src="https://unpkg.com/de-micro-editor@0.2.6/dist/de-editor.min.js"/>-->
                <!--<script type="text/javascript" src="js/run.js"/>-->
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:fw"/>
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
</xsl:stylesheet>
