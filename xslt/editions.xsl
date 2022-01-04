<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://dse-static.foo.bar"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:import href="./partials/shared.xsl"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/osd-container.xsl"/>
    <xsl:import href="./partials/tei-facsimile.xsl"/>
    <xsl:import href="./partials/person.xsl"/>
    <xsl:import href="./partials/place.xsl"/>
    
    <xsl:param name="quotationURL"/>
    
    

    <xsl:variable name="prev">
        <xsl:value-of select="replace(tokenize(data(tei:TEI/@prev), '/')[last()], '.xml', '.html')"/>
    </xsl:variable>
    <xsl:variable name="next">
        <xsl:value-of select="replace(tokenize(data(tei:TEI/@next), '/')[last()], '.xml', '.html')"/>
    </xsl:variable>
    <xsl:variable name="teiSource">
        <xsl:value-of select="data(tei:TEI/@xml:id)"/>
    </xsl:variable>
    <xsl:variable name="link">
        <xsl:value-of select="replace($teiSource, '.xml', '.html')"/>
    </xsl:variable>
    <xsl:variable name="doc_title">
        <xsl:value-of select=".//tei:title[@level='a'][1]/text()"/>
    </xsl:variable>
    
    <xsl:variable name="entryDate">
        <xsl:value-of select="xs:date(//tei:title[@type='iso-date']/text())"/>
    </xsl:variable>
    <xsl:variable name="doctitle">
        <xsl:value-of select="//tei:title[@type='main']/text()"/>
    </xsl:variable>
    <xsl:variable name="currentDate">
        <xsl:value-of select="format-date(current-date(), '[Y]-[M01]-[D01]')"/>
    </xsl:variable>
    <xsl:variable name="pid">
        <xsl:value-of select="//tei:publicationStmt//tei:idno[@type='URI']/text()"/>
    </xsl:variable>
        
    <xsl:variable name="source_volume">
        <xsl:value-of select="replace(//tei:monogr//tei:biblScope[@unit='volume']/text(), '-', '_')"/>
    </xsl:variable>
    <xsl:variable name="source_base_url">https://austriaca.at/buecher/files/arthur_schnitzler_tagebuch/Tagebuch1879-1931Einzelseiten/schnitzler_tb_</xsl:variable>
    <xsl:variable name="source_page_nr">
        <xsl:value-of select="format-number(//tei:monogr//tei:biblScope[@unit='page']/text(), '000')"/>
    </xsl:variable>
    <xsl:variable name="source_pdf">
        <xsl:value-of select="concat($source_base_url, $source_volume, 's', $source_page_nr, '.pdf')"/>
    </xsl:variable>
    <xsl:variable name="current-date">
        <xsl:value-of select="substring-after($doctitle, ': ')"/>
    </xsl:variable>

    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select=".//tei:title[@type='main'][1]/text()"/>
        </xsl:variable>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html>
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
            </xsl:call-template>
            
            <body class="page">
                <link rel="stylesheet" href="css/cslink.css"/>
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    
                    <div class="container-fluid">                        
                        <div class="card">
                            <div class="card-header">
                                <div class="row">
                                    <div class="col-md-2">
                                        <xsl:if test="ends-with($prev,'.html')">
                                            <h1>
                                                <a>
                                                    <xsl:attribute name="href">
                                                        <xsl:value-of select="$prev"/>
                                                    </xsl:attribute>
                                                    <i class="fas fa-chevron-left" title="prev"/>
                                                </a>
                                            </h1>
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
                            <div class="card-body-tagebuch" data-index="true">                                
                                <xsl:apply-templates select=".//tei:body"></xsl:apply-templates>
                            </div>
                            <div class="card-footer text-muted">
                                <div id="srcbuttons" style="text-align:center">
                                    <div class="res-act-button res-act-button-copy-url" id="res-act-button-copy-url">
                                        <span id="copy-url-button" data-toggle="modal" data-target="#quoteModal">
                                            <i class="fas fa-quote-right"/> ZITIEREN
                                        </span>
                                    </div>
                                    <xsl:if test=".//tei:facsimile/*">
                                        <a class="ml-3" title="Faksimile zu diesem Eintrag" data-toggle="modal" data-target="#exampleModal">
                                            <i class="fa-lg far fa-file-image"/> Faksimile
                                        </a>
                                    </xsl:if>
                                    <a class="ml-3" data-toggle="tooltip" title="Link zum PDF der Buchvorlage zu diesem Eintrag">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="$source_pdf"/>
                                        </xsl:attribute>
                                        <i class="fa-lg far fa-file-pdf"/> PDF
                                    </a>
                                    <a class="ml-3" data-toggle="tooltip" title="Link zur TEI-Datei">
                                        <xsl:attribute name="href">
                                            <xsl:value-of select="$teiSource"/>
                                        </xsl:attribute>
                                        <i class="fa-lg far fa-file-code"/> TEI 
                                    </a>
                                    <a class="ml-3" data-toggle="tooltip" title="Zeige Register" onclick="myFunction()">
                                        <i class="fas fa-map-marked-alt"/> Verstecke/Zeige Register
                                    </a>
                                    <span class="nav-link">
                                        <div id="csLink" data-correspondent-1-name="Arthur Schnitzler"
                                            data-correspondent-1-id="http%3A%2F%2Fd-nb.info%2Fgnd%2F118609807"
                                            data-correspondent-2-name="" data-correspondent-2-id="" data-start-date="{$entryDate}"
                                            data-end-date="" data-range="50" data-selection-when="before-after" data-selection-span="median-before-after"
                                            data-result-max="4" data-exclude-edition=""
                                        />
                                    </span>
                                    
                                </div>
                                <div id="registerDiv">
                                    <nav>
                                        <div class="nav nav-tabs" id="nav-tab" role="tablist">
                                            <a class="nav-item nav-link active" id="nav-home-tab" data-toggle="tab" href="#nav-home" role="tab" aria-controls="nav-home" aria-selected="true">Orte</a>
                                            <a class="nav-item nav-link" id="nav-profile-tab" data-toggle="tab" href="#nav-profile" role="tab" aria-controls="nav-profile" aria-selected="false">Personen</a>
                                            <a class="nav-item nav-link" id="nav-contact-tab" data-toggle="tab" href="#nav-contact" role="tab" aria-controls="nav-contact" aria-selected="false">Werke</a>
                                        </div>
                                    </nav>
                                    <div class="tab-content" id="nav-tabContent">
                                        <div class="tab-pane fade show active" id="nav-home" role="tabpanel" aria-labelledby="nav-home-tab">
                                            <legend>Orte</legend>
                                            <div class="row">
                                                <div class="col-md-4">
                                                    <ul>
                                                        <xsl:for-each select=".//tei:listPlace/tei:place">
                                                            <li>
                                                                <a>
                                                                    <xsl:attribute name="href"><xsl:value-of select="concat(data(@xml:id), '.html')"/></xsl:attribute>
                                                                    <xsl:value-of select="./tei:placeName[1]/text()"/>
                                                                </a>
                                                            </li>
                                                        </xsl:for-each>
                                                    </ul>
                                                </div>
                                                <div id="mapid" style="height: 400px;" class="col-md-8"/>
                                            </div>
                                            <link rel="stylesheet" href="https://unpkg.com/leaflet@1.7.1/dist/leaflet.css" integrity="sha512-xodZBNTC5n17Xt2atTPuE1HxjVMSvLVW9ocqUKLsCC5CXdbqCmblAshOMAS6/keqq/sMZMZ19scR4PsZChSR7A==" crossorigin=""/>
                                            <script src="https://unpkg.com/leaflet@1.7.1/dist/leaflet.js" integrity="sha512-XQoYMqMTK8LvdxXYG3nZ448hOEQiglfqkJs1NOQV44cWnUrBc8PkAOcXy20w0vlaXaVUearIOBhiXZ5V3ynxwA==" crossorigin=""/>
                                            <script>
                                                
                                                var mymap = L.map('mapid').setView([50, 12], 5);
                                                
                                                L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                                                attribution: 'Map data &amp;copy; <a href="https://www.openstreetmap.org/">OpenStreetMap</a> contributors, <a href="https://creativecommons.org/licenses/by-sa/2.0/">CC-BY-SA</a>, Imagery © <a href="https://www.openstreetmap.org/">OpenStreetMap</a>',
                                                maxZoom: 18,
                                                zIndex: 1
                                                }).addTo(mymap);
                                                <xsl:for-each select=".//tei:listPlace/tei:place">
                                                    L.marker([<xsl:value-of select="substring-before(.//tei:geo/text()[1], ' ')"/>, <xsl:value-of select="substring-after(.//tei:geo/text(), ' ')"/>]).addTo(mymap)
                                                    .bindPopup("<b>
                                                        <xsl:value-of select="./tei:placeName[1]/text()"/>
                                                    </b>").openPopup();
                                                </xsl:for-each>
                                            </script>
                                            
                                        </div>
                                        <div class="tab-pane fade" id="nav-profile" role="tabpanel" aria-labelledby="nav-profile-tab">
                                            <legend>Personen</legend>
                                            <ul>
                                                <xsl:for-each select=".//tei:listPerson//tei:person">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href"><xsl:value-of select="concat(data(@xml:id), '.html')"/></xsl:attribute>
                                                            <xsl:value-of select="./tei:persName"/>
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                        </div>
                                        <div class="tab-pane fade" id="nav-contact" role="tabpanel" aria-labelledby="nav-contact-tab">
                                            <legend>Werke</legend>
                                            <ul>
                                                <xsl:for-each select=".//tei:listBibl//tei:bibl">
                                                    <li>
                                                        <a>
                                                            <xsl:attribute name="href"><xsl:value-of select="concat(data(@xml:id), '.html')"/></xsl:attribute>
                                                            <xsl:value-of select="./tei:title"/>
                                                        </a>
                                                    </li>
                                                </xsl:for-each>
                                            </ul>
                                        </div>
                                    </div></div>
                            </div>
                        </div>                       
                    </div>
                    <div class="modal fade" id="quoteModal" tabindex="-1" role="dialog" aria-labelledby="quoteModalLabel" aria-hidden="true">
                        <div class="modal-dialog" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h5 class="modal-title" id="quoteModalLabel">Zitiervorschlag</h5>
                                </div>
                                <div class="modal-body">
                                    Arthur Schnitzler: Tagebuch. Digitale Edition, <xsl:value-of select="$doctitle"/>, https://schnitzler-tagebuch.acdh.oeaw.ac.at/entry__1894-03-18.html (Stand <xsl:value-of select="$currentDate"/>), PID: <xsl:value-of select="$pid"/>. 
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-dismiss="modal">Schließen</button>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="modal fade" id="exampleModal" tabindex="-1" role="dialog" aria-labelledby="exampleModalLabel" aria-hidden="true">
                        <div class="modal-dialog modal-lg" role="document">
                            <div class="modal-content">
                                <div class="modal-header">
                                    <h3>Faksimile</h3>
                                </div>
                                <div class="modal-body">
                                    <div id="openseadragon-photo" style="height: 350px;"/>
                                    <script src="https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.1/openseadragon.min.js"/>
                                    <script type="text/javascript">
                                        var viewer = OpenSeadragon({
                                        id: "openseadragon-photo",
                                        protocol: "http://iiif.io/api/image",
                                        prefixUrl: "https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.1/images/",
                                        sequenceMode : true,
                                        showReferenceStrip: true,
                                        tileSources: [
                                            <xsl:for-each select=".//data(@url)">{
                                                type: 'image',
                                                url: '<xsl:value-of select="concat(., '?format=iiif')"/>'
                                             }
                                            <xsl:choose>
                                            <xsl:when test="position() != last()">,</xsl:when>
                                        </xsl:choose></xsl:for-each>]
                                        });
                                    </script>
                                </div>
                                <div class="modal-footer" style="justify-content: flex-start;">
                                    <ul style="list-style-type: none;">
                                        <xsl:for-each select=".//data(@url)">
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
                    
                    <xsl:for-each select=".//tei:back//tei:person[@xml:id]">
                        <xsl:variable name="xmlId">
                            <xsl:value-of select="data(./@xml:id)"/>
                        </xsl:variable>
                        
                        <div class="modal fade" tabindex="-1" role="dialog" aria-hidden="true" id="{$xmlId}">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">
                                            <xsl:value-of select="normalize-space(string-join(.//tei:persName[1]//text()))"/>
                                            <xsl:text> </xsl:text>
                                            <a href="{concat($xmlId, '.html')}">
                                                <i class="fas fa-external-link-alt"></i>
                                            </a>
                                        </h5>
                                        
                                    </div>
                                    <div class="modal-body">
                                        <xsl:call-template name="person_detail">
                                            <xsl:with-param name="showNumberOfMentions" select="5"/>
                                        </xsl:call-template>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Schließen</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:for-each select=".//tei:back//tei:place[@xml:id]">
                        <xsl:variable name="xmlId">
                            <xsl:value-of select="data(./@xml:id)"/>
                        </xsl:variable>
                        
                        <div class="modal fade" tabindex="-1" role="dialog" aria-hidden="true" id="{$xmlId}">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">
                                            <xsl:value-of select="normalize-space(string-join(.//tei:placeName[1]/text()))"/>
                                            <xsl:text> </xsl:text>
                                            <a href="{concat($xmlId, '.html')}">
                                                <i class="fas fa-external-link-alt"></i>
                                            </a>
                                        </h5>
                                    </div>
                                    <div class="modal-body">
                                        <xsl:call-template name="place_detail">
                                            <xsl:with-param name="showNumberOfMentions" select="5"/>
                                        </xsl:call-template>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Schließen</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </xsl:for-each>
                    <xsl:call-template name="html_footer"/>
                    <script src="js/cslink.js"/>
                    <script>
                        function myFunction() {
                        var x = document.getElementById("registerDiv");
                            if (x.style.display === "none") {
                                x.style.display = "block";
                            } else {
                                x.style.display = "none";
                            }
                        } 
                    </script>
                </div>
            </body>
        </html>
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
</xsl:stylesheet>