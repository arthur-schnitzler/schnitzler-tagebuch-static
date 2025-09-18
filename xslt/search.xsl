<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes" omit-xml-declaration="yes"  doctype-system="" doctype-public=""/>
    
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="partials/html_footer.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Volltextsuche'"/>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html xmlns="http://www.w3.org/1999/xhtml" lang="de">
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
            </xsl:call-template>
            
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    
                    <div class="container-fluid">
                        <div class="card">
                            <div class="card-header">
                                <h1><xsl:value-of select="$doc_title"/></h1>
                            </div>
                            <div class="card-body">
                                <!-- Typesense Search Container -->
                                <div id="typesense-search-container" style="display: block;">
                                    <div class="ais-InstantSearch">
                                        <div class="row">
                                            <div class="col-md-4">
                                                <!-- Search Engine Toggle -->
                                                <div class="card mb-3">
                                                    <div class="card-header d-flex justify-content-between align-items-center">
                                                        <span>Suchmaschine</span>
                                                        <i class="fas fa-info-circle text-muted"
                                                           data-bs-toggle="tooltip"
                                                           data-bs-placement="right"
                                                           title="Typesense: Schnelle Volltextsuche mit Filtern | Noske: Linguistische Suche mit CQL (z.B. [lemma=&quot;sein&quot;] oder lieb*)"></i>
                                                    </div>
                                                    <div class="card-body">
                                                        <div class="btn-group btn-group-sm d-flex" role="group" aria-label="Search engine selection">
                                                            <button type="button" class="btn btn-primary flex-fill" id="btn-typesense">
                                                                <i class="fas fa-search"></i> Typesense
                                                            </button>
                                                            <button type="button" class="btn btn-outline-primary flex-fill" id="btn-noske">
                                                                <i class="fas fa-language"></i> Noske
                                                            </button>
                                                        </div>
                                                    </div>
                                                </div>

                                                <div id="stats-container"></div>
                                                <div id="searchbox"></div>
                                                <div id="current-refinements"></div>
                                                <div id="clear-refinements"></div>

                                                <h4>Sortierung</h4>
                                                <div id="sort-by"></div>
                                                <h4>Jahr</h4>
                                                <div id="range-input"></div>
                                                <h4>Personen</h4>
                                                <div id="refinement-list-persons"></div>
                                                <h4>Werke</h4>
                                                <div id="refinement-list-works"></div>
                                                <h4>Orte</h4>
                                                <div id="refinement-list-places"></div>

                                            </div>
                                            <div class="col-md-8">
                                                <div id="hits"></div>
                                                <div id="pagination"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Noske Search Container -->
                                <div id="noske-search-container" style="display: none;">
                                    <div class="row">
                                        <div class="col-md-4">
                                            <!-- Search Engine Toggle (same as Typesense) -->
                                            <div class="card mb-3">
                                                <div class="card-header d-flex justify-content-between align-items-center">
                                                    <span>Suchmaschine</span>
                                                    <i class="fas fa-info-circle text-muted"
                                                       data-bs-toggle="tooltip"
                                                       data-bs-placement="right"
                                                       title="Typesense: Schnelle Volltextsuche mit Filtern | Noske: Linguistische Suche mit CQL (z.B. [lemma=&quot;sein&quot;] oder lieb*)"></i>
                                                </div>
                                                <div class="card-body">
                                                    <div class="btn-group btn-group-sm d-flex" role="group" aria-label="Search engine selection">
                                                        <button type="button" class="btn btn-outline-primary flex-fill" id="btn-typesense-noske">
                                                            <i class="fas fa-search"></i> Typesense
                                                        </button>
                                                        <button type="button" class="btn btn-primary flex-fill" id="btn-noske-noske">
                                                            <i class="fas fa-language"></i> Noske
                                                        </button>
                                                    </div>
                                                </div>
                                            </div>

                                            <div class="alert alert-info" role="alert">
                                                <h6><i class="fas fa-info-circle"></i> Erweiterte Suche mit Noske</h6>
                                                <p class="mb-2 small">
                                                    <strong>Einfache Suche: </strong> <code>liebe</code> oder <code>lieb*</code> (mit * für beliebige Zeichen)<br/>
                                                    <strong>CQL-Suche: </strong> <code>[lemma="lieben"]</code> • <code>[word=".*ing"]</code><br/>
                                                    <strong>Platzhalter: </strong> Einfach: <code>*</code> und <code>?</code> • CQL: <code>.*</code> in Anführungszeichen<br/>
                                                    <strong>Beispiele: </strong> <code>lieb*</code> • <code>[word="Lie.*"]</code> • <code>[lemma="sein"]</code>
                                                </p>
                                            </div>
                                        </div>
                                        <div class="col-md-8">
                                            <div id="noske-search"></div>
                                            <div id="hitsbox"></div>
                                            <div>
                                                <div id="noske-pagination-test"></div>
                                                <div id="noske-stats"></div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <xsl:call-template name="html_footer"/>
                    
                </div>
                <!--<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.2/dist/js/bootstrap.bundle.min.js"
                    integrity="sha384-MrcW6ZMFYlzcLA8Nl+NtUVF0sA7MsXsP1UyJoMp4YLEuNSfAP+JcXn/tWtIaxVXM" crossorigin="anonymous">
                </script>-->
                <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/instantsearch.css@7/themes/algolia-min.css" />
                <link rel="stylesheet" href="css/noske-search.css" />
                <script src="https://cdn.jsdelivr.net/npm/instantsearch.js@4.46.0"></script>
                <script
                    src="https://cdn.jsdelivr.net/npm/typesense-instantsearch-adapter@2/dist/typesense-instantsearch-adapter.min.js"></script>
                 <script src="js/ts_index.js"></script>
                 <script type="module" src="js/noske_search.js"></script>
                 <script src="js/search_toggle.js"></script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>