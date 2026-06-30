<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:local="http://dse-static.foo.bar"
    xmlns:mam="whatever" version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:import href="./partials/shared.xsl"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/osd-container.xsl"/>
    <xsl:import href="./partials/tei-facsimile.xsl"/>
    <xsl:import href="./partials/entities.xsl"/>
    <xsl:import href="./partials/html_title_navigation.xsl"/>
    <xsl:import href="./partials/view-type.xsl"/>
    <xsl:import href="./partials/zotero.xsl"/>
    <xsl:import href="./partials/biblStruct-output.xsl"/>
    <!-- Einstellungen für die Schnitzler-Chronik. Lokaler Import zur Vermeidung von Remote-Fetching während des Builds -->
    <xsl:import href="../../schnitzler-chronik-static/xslt/export/schnitzler-chronik.xsl"/>
    <!--<xsl:import
        href="https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-chronik-static/refs/heads/main/xslt/export/schnitzler-chronik.xsl"/>-->
    <xsl:param name="schnitzler-chronik_fetch-locally" as="xs:boolean" select="true()"/>
    <xsl:param name="schnitzler-chronik_current-type" as="xs:string" select="'schnitzler-tagebuch'"/>
    <xsl:param name="quotationURL"/>
    <xsl:param name="chronik-dir">../chronik-data</xsl:param>
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes"
        omit-xml-declaration="yes"/>
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
    <xsl:variable name="pageRange"
        select="//tei:monogr//tei:biblScope[starts-with(@unit, 'page')]/text()"/>
    <xsl:variable name="source_page_nr1">
        <xsl:choose>
            <xsl:when test="contains($pageRange, '–')">
                <xsl:value-of
                    select="format-number(number(substring-before($pageRange, '–')), '000')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="format-number(number($pageRange), '000')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:variable name="source_page_nr2" select="
            if (contains($pageRange, '–'))
            then
                format-number(number(substring-after($pageRange, '–')), '000')
            else
                format-number(number($pageRange), '000')"/>
    <xsl:variable name="source1_pdf">
        <xsl:value-of
            select="concat($source_base_url, $source_volume, 's', $source_page_nr1, '.pdf')"/>
    </xsl:variable>
    <xsl:variable name="source2_pdf">
        <xsl:value-of
            select="concat($source_base_url, $source_volume, 's', $source_page_nr2, '.pdf')"/>
    </xsl:variable>
    <xsl:variable name="source-double-page" as="xs:boolean">
        <xsl:choose>
            <xsl:when test="contains($pageRange, '–')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
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
        <html xmlns="http://www.w3.org/1999/xhtml" lang="de">
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"/>
                <xsl:with-param name="entry_date"
                    select="descendant::tei:titleStmt[1]/tei:title[@type = 'iso-date'][1]/text()"/>
                <xsl:with-param name="page_url"
                    select="concat('https://schnitzler-tagebuch.acdh.oeaw.ac.at/', $teiSource, '.html')"/>
                <xsl:with-param name="meta_description"
                    select="concat('Tagebucheintrag von Arthur Schnitzler vom ', $doc_title, '. Digitale Edition des Tagebuchs (1879–1931) des österreichischen Schriftstellers.')"
                />
            </xsl:call-template>
            <xsl:call-template name="zoterMetaTags">
                <xsl:with-param name="pageId" select="$link"/>
                <xsl:with-param name="zoteroTitle" select="$doc_title"/>
            </xsl:call-template>
            <body class="page">
                <!-- Unsichtbarer ISO-Datum-Kopierbereich in der oberen rechten Ecke -->
                <div
                    style="position: fixed; top: 0; right: 0; width: 50px; height: 50px; cursor: pointer; z-index: 9999; opacity: 0;"
                    title="ISO-Datum kopieren">
                    <xsl:attribute name="onclick">
                        <xsl:text>navigator.clipboard.writeText('</xsl:text>
                        <xsl:value-of
                            select="descendant::tei:titleStmt[1]/tei:title[@type = 'iso-date'][1]/text()"/>
                        <xsl:text>').then(() => { this.style.opacity = '0.2'; setTimeout(() => { this.style.opacity = '0'; }, 500); });</xsl:text>
                    </xsl:attribute>
                </div>
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    <!-- Zweites Menü: breiter Balken in Projekt-Farbe direkt unter der Navbar -->
                    <nav class="action-bar" id="actionBar"
                        aria-label="Werkzeuge und Blättern">
                        <div class="inner">
                            <button type="button" data-drawer="entitaeten" aria-expanded="false"
                                title="Entitäten in diesem Eintrag">
                                <i class="fas fa-sharp fa-solid fa-people-group"/>
                                <xsl:text> Entitäten</xsl:text>
                            </button>
                            <button type="button" data-drawer="cite" aria-expanded="false"
                                title="Zitiervorschlag zu diesem Eintrag">
                                <i class="fas fa-quote-right"/>
                                <xsl:text> Zitieren</xsl:text>
                            </button>
                            <!-- Faksimile bleibt ein Modal (OpenSeadragon-Viewer) -->
                            <a href="#" data-bs-target="#faks-modal" data-bs-toggle="modal"
                                title="Faksimile zu diesem Eintrag">
                                <i class="fa-lg far fa-file-image"/>
                                <xsl:text> Faksimile</xsl:text>
                            </a>
                            <button type="button" data-drawer="download" aria-expanded="false"
                                title="Diesen Eintrag herunterladen">
                                <i class="fas fa-solid fa-download"/>
                                <xsl:text> Download</xsl:text>
                            </button>
                            <button type="button" data-drawer="chronik" aria-expanded="false"
                                title="Weitere Ereignisse an diesem Tag">
                                <i class="fas fa-calendar-day"/>
                                <xsl:text> Chronik</xsl:text>
                            </button>
                            <span class="gap"/>
                            <span class="neighbors">
                                <xsl:if test="ends-with($prev, '.html')">
                                    <a href="{$prev}" title="vorheriger Eintrag"
                                        aria-label="vorheriger Eintrag">
                                        <i class="fas fa-chevron-left"/>
                                    </a>
                                </xsl:if>
                                <xsl:if test="ends-with($next, '.html')">
                                    <a href="{$next}" title="nächster Eintrag"
                                        aria-label="nächster Eintrag">
                                        <i class="fas fa-chevron-right"/>
                                    </a>
                                </xsl:if>
                            </span>
                        </div>
                    </nav>
                    <!-- Drawer, der unter der Action-Bar aufklappt -->
                    <div class="drawer-backdrop" id="drawerBackdrop"/>
                    <div class="action-drawer" id="drawer" role="region" aria-label="Werkzeuge">
                        <div class="drawer-inner">
                            <!-- ENTITÄTEN -->
                            <div class="drawer-panel" data-panel="entitaeten">
                                <h3>Erwähnte Entitäten <button type="button" class="close"
                                        data-close="">schließen ✕</button></h3>
                                <div class="drawer-grid">
                                    <xsl:if test="//tei:back/tei:listPerson/tei:person[1]">
                                        <div>
                                            <div class="meta-caption">Personen</div>
                                            <ul>
                                                <xsl:for-each
                                                  select="descendant::tei:back/tei:listPerson/tei:person">
                                                  <li>
                                                  <a href="{concat(data(@xml:id), '.html')}">
                                                  <xsl:value-of select="child::tei:persName[1]"/>
                                                  </a>
                                                  </li>
                                                </xsl:for-each>
                                            </ul>
                                        </div>
                                    </xsl:if>
                                    <xsl:if test=".//tei:back/tei:listBibl/tei:bibl[1]">
                                        <div>
                                            <div class="meta-caption">Werke</div>
                                            <ul>
                                                <xsl:for-each
                                                  select="descendant::tei:back/tei:listBibl/tei:bibl">
                                                  <li>
                                                  <a href="{concat(data(@xml:id), '.html')}">
                                                  <xsl:value-of select="tei:title[@type = 'main'][1]"/>
                                                  </a>
                                                  </li>
                                                </xsl:for-each>
                                            </ul>
                                        </div>
                                    </xsl:if>
                                    <xsl:if test="//tei:back/tei:listPlace/tei:place[1]">
                                        <div>
                                            <div class="meta-caption">Orte</div>
                                            <ul>
                                                <xsl:for-each
                                                  select="descendant::tei:back/tei:listPlace/tei:place">
                                                  <li>
                                                  <a href="{concat(data(@xml:id), '.html')}">
                                                  <xsl:value-of
                                                  select="child::tei:placeName[1]/text()"/>
                                                  </a>
                                                  </li>
                                                </xsl:for-each>
                                            </ul>
                                        </div>
                                    </xsl:if>
                                </div>
                            </div>
                            <!-- ZITIEREN -->
                            <div class="drawer-panel" data-panel="cite">
                                <h3>Zitieren <button type="button" class="close" data-close=""
                                        >schließen ✕</button></h3>
                                <div class="meta-caption">Empfohlene Zitierweise</div>
                                <blockquote class="cite-block"
                                    style="cursor: pointer; user-select: all;"
                                    title="Klicken zum Kopieren"
                                    onclick="navigator.clipboard.writeText(this.innerText)"> Arthur
                                    Schnitzler: Tagebuch. Digitale Edition, <xsl:value-of
                                        select="$doctitle"/>,
                                    https://schnitzler-tagebuch.acdh.oeaw.ac.at/entry__<xsl:value-of
                                        select="descendant::tei:teiHeader[1]/tei:fileDesc[1]/tei:titleStmt[1]/tei:title[@type = 'iso-date']"
                                    />.html (Stand <xsl:value-of select="$currentDate"/>), PID:
                                        <xsl:value-of select="$pid"/>. </blockquote>
                            </div>
                            <!-- DOWNLOAD -->
                            <div class="drawer-panel" data-panel="download">
                                <h3>Download <button type="button" class="close" data-close=""
                                        >schließen ✕</button></h3>
                                <div class="download-list">
                                    <xsl:choose>
                                        <xsl:when test="$source-double-page = true()">
                                            <a href="{$source1_pdf}" data-bs-toggle="tooltip"
                                                title="Eintrag als PDF">
                                                <i class="far fa-file-pdf"/>
                                                <xsl:text> PDF (Seite 1)</xsl:text>
                                            </a>
                                            <a href="{$source2_pdf}" data-bs-toggle="tooltip"
                                                title="Eintrag als PDF">
                                                <i class="far fa-file-pdf"/>
                                                <xsl:text> PDF (Seite 2)</xsl:text>
                                            </a>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <a href="{$source1_pdf}" data-bs-toggle="tooltip"
                                                title="Eintrag als PDF">
                                                <i class="far fa-file-pdf"/>
                                                <xsl:text> PDF</xsl:text>
                                            </a>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <a class="secondary"
                                        href="{concat(replace($teiSource, '.xml', ''), '.xml')}"
                                        data-bs-toggle="tooltip" title="Eintrag als TEI-Datei">
                                        <i class="far fa-file-code"/>
                                        <xsl:text> TEI-XML</xsl:text>
                                    </a>
                                </div>
                            </div>
                            <!-- CHRONIK -->
                            <div class="drawer-panel" data-panel="chronik">
                                <xsl:variable name="datum"
                                    select="descendant::tei:title[@type = 'iso-date']/text()"
                                    as="xs:date"/>
                                <h3>Chronik <button type="button" class="close" data-close=""
                                        >schließen ✕</button></h3>
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
                                    <xsl:with-param name="current-type"
                                        select="$schnitzler-chronik_current-type"/>
                                    <xsl:with-param name="teiSource" select="$teiSource"/>
                                    <xsl:with-param name="fetchContentsFromURL"
                                        select="$fetchContentsFromURL" as="node()?"/>
                                </xsl:call-template>
                            </div>
                        </div>
                    </div>
                    <div class="container-fluid">
                        <div class="wp-transcript">
                            <div class="card" data-index="true">
                                <div class="card-header">
                                    <div class="row">
                                        <div class="col-md-12">
                                            <h1 align="center">
                                                <xsl:value-of select="$doc_title"/>
                                            </h1>
                                        </div>
                                    </div>
                                </div>
                                <div class="card-body-normalertext" data-index="true">
                                    <xsl:apply-templates select=".//tei:body"/>
                                </div>
                            </div>
                        </div>
                    </div>
                    <xsl:call-template name="html_footer"/>
                </div>
                <!-- Modal Faksimile -->
                <div class="modal fade" id="faks-modal" tabindex="-1" aria-labelledby="faksimile"
                    aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered faksimile-modal"
                        style="max-width: 1000px;">
                        <div class="modal-content">
                            <!-- Modal Header -->
                            <div class="modal-header">
                                <h5 class="modal-title">Faksimile</h5>
                                <div class="d-flex align-items-center gap-2">
                                    <button type="button" class="btn btn-primary btn-sm"
                                        id="faks-download-btn" onclick="downloadFaksimile()">
                                        <i class="fa-solid fa-download"/> Herunterladen </button>
                                    <button type="button" class="btn-close" data-bs-dismiss="modal"
                                        aria-label="Schließen"/>
                                </div>
                            </div>
                            <!-- Modal Body -->
                            <div class="modal-body">
                                <div id="openseadragon-photo" style="height: 80vh;"/>
                                <!-- OpenSeadragon Script -->
                                <script src="https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.1/openseadragon.min.js"/>
                                <script type="text/javascript">
                                    var faksUrls = [<xsl:for-each select=".//tei:facsimile/tei:graphic/data(@url)">
                                        "<xsl:value-of select="."/>"<xsl:if test="position() != last()">,</xsl:if>
                                    </xsl:for-each>];
                                    var viewer = OpenSeadragon({
                                        id: "openseadragon-photo",
                                        protocol: "http://iiif.io/api/image",
                                        prefixUrl: "https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.1/images/",
                                        sequenceMode: true,
                                        showReferenceStrip: true,
                                        tileSources:[<xsl:for-each select=".//tei:facsimile/tei:graphic/data(@url)">
                                        {
                                        type: "image",
                                        url: "<xsl:value-of select="concat(., '?format=iiif')"/>"
                                        }<xsl:if test="position() != last()">,</xsl:if>
                                    </xsl:for-each>
]
                                    });
                                    function downloadFaksimile() {
                                        var i = viewer ? viewer.currentPage() : 0;
                                        var url = faksUrls[i];
                                        if (url) {
                                            window.open(url + "?format=iiif&amp;param=/full/full/0/default.jpg", "_blank");
                                        }
                                    }</script>
                            </div>
                            <!-- Modal Footer (Links) -->
                            <div class="modal-footer" style="justify-content: flex-start;">
                                <div class="w-100">
                                    <p class="mb-1 fw-bold">Alle Faksimiles dieses Eintrags:</p>
                                    <ul class="list-unstyled mb-0">
                                        <xsl:for-each
                                            select=".//tei:facsimile/tei:graphic/data(@url)">
                                            <li class="mb-1">
                                                <a href="{concat(., '?format=iiif&amp;param=/full/full/0/default.jpg')}"
                                                    target="_blank" class="me-3">
                                                    <i class="fa-solid fa-download"/> Bild
                                                        <xsl:value-of select="position()"/>
                                                    als JPEG </a>
                                                <a href="{concat(., '?format=gui')}"
                                                    target="_blank">
                                                    <i class="fa-solid fa-up-right-from-square"/> in
                                                    ARCHE (TIFF) </a>
                                            </li>
                                        </xsl:for-each>
                                    </ul>
                                </div>
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
                <!--<script src="https://unpkg.com/de-micro-editor@0.2.6/dist/de-editor.min.js"/>-->
                <!--<script type="text/javascript" src="js/run.js"/>-->
                <script>
// Action-Bar-Drawer (Entitäten, Zitieren, Download, Chronik)
(function(){
var bar=document.getElementById('actionBar');
var drawer=document.getElementById('drawer');
var backdrop=document.getElementById('drawerBackdrop');
if(!bar||!drawer){return;}
var buttons=bar.querySelectorAll('button[data-drawer]');
var panels=drawer.querySelectorAll('.drawer-panel');
function syncTop(){drawer.style.top=bar.offsetHeight+'px';}
syncTop();
window.addEventListener('resize',syncTop);
if(window.ResizeObserver){new ResizeObserver(syncTop).observe(bar);}
function openDrawer(name){
syncTop();
buttons.forEach(function(b){b.setAttribute('aria-expanded',b.getAttribute('data-drawer')===name?'true':'false');});
panels.forEach(function(p){p.classList.toggle('active',p.getAttribute('data-panel')===name);});
drawer.classList.add('open');
if(backdrop){backdrop.classList.add('show');}
var inner=drawer.querySelector('.drawer-inner');
if(inner){inner.scrollTop=0;}
document.dispatchEvent(new CustomEvent('drawer:open',{detail:name}));
}
function closeDrawer(){
buttons.forEach(function(b){b.setAttribute('aria-expanded','false');});
drawer.classList.remove('open');
if(backdrop){backdrop.classList.remove('show');}
}
buttons.forEach(function(b){
b.addEventListener('click',function(){
var name=b.getAttribute('data-drawer');
var expanded=b.getAttribute('aria-expanded')==='true';
if(expanded){closeDrawer();}else{openDrawer(name);}
});
});
drawer.querySelectorAll('[data-close]').forEach(function(c){c.addEventListener('click',closeDrawer);});
if(backdrop){backdrop.addEventListener('click',closeDrawer);}
document.addEventListener('keydown',function(e){if(e.key==='Escape'){closeDrawer();}});
})();</script>
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
    <xsl:template match="tei:hi[@rend = 'italicised']">
        <span style="text-decoration:underline;">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
</xsl:stylesheet>
