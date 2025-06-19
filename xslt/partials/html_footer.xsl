<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl xs"
    version="2.0">
    <xsl:template match="/" name="html_footer">
        
        <div class="wrapper hide-reading" id="wrapper-footer-full">
            <div class="container-fluid" id="footer-full-content" tabindex="-1">
                <div class="row mb-3 align-items-center footer-separator">
                    <div class="col-auto">
                        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" fill="none" stroke="currentColor"
                            stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-message-circle">
                            <path
                                d="M21 11.5a8.38 8.38 0 0 1-.9 3.8 8.5 8.5 0 0 1-7.6 4.7 8.38 8.38 0 0 1-3.8-.9L3 21l1.9-5.7a8.38 8.38 0 0 1-.9-3.8 8.5 8.5 0 0 1 4.7-7.6 8.38 8.38 0 0 1 3.8-.9h.5a8.48 8.48 0 0 1 8 8v.5z" />
                        </svg>
                    </div>
                    <div class="col">
                        <strong>KONTAKT</strong>
                    </div>
                </div>
                
                <div class="row">
                    <!-- Linke Spalte -->
                    <div class="col-md-6 d-flex">
                        <div class="me-3">
                            <a href="/">
                                <img src="https://fundament.acdh.oeaw.ac.at/common-assets/images/acdh_logo.svg" alt="ACDH Logo"
                                    style="max-width: 100px; height: auto;" title="ACDH Logo" />
                            </a>
                        </div>
                        <div>
                            <p>
                                <strong>ACDH</strong><br/>
                                    Austrian Centre for Digital Humanities<br/>
                                        Österreichische Akademie der Wissenschaften
                            </p>
                            <p>
                                Bäckerstraße 13<br/>
                                    1010 Wien
                            </p>
                            <p>
                                T: +43 1 51581-2200<br/>
                                    E: <a href="mailto:acdh-ch-helpdesk@oeaw.ac.at">acdh-ch-helpdesk(at)oeaw.ac.at</a>
                            </p>
                        </div>
                    </div>
                    
                    <!-- Rechte Spalte -->
                    <div class="col-md-6">
                        <h6>Work in Progress</h6>
                        <p>
                            Bei Fragen, Anmerkungen, Kritik, aber gerne auch Lob, wenden Sie sich bitte an den
                            <a href="mailto:acdh-ch-helpdesk@oeaw.ac.at">ACDH-CH Helpdesk</a>.
                        </p>
                        <p>
                            <a class="helpdesk-button"
                                href="mailto:acdh-ch-helpdesk@oeaw.ac.at">e-Mail</a>
                        </p>
                        <p>
                            <a href="https://github.com/arthur-schnitzler/schnitzler-tagebuch-static">
                                <i class="fab fa-github-square fa-2x" style="color: #037a33;"></i>
                            </a>
                        </p>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="footer-imprint-bar hide-reading" id="wrapper-footer-secondary"
            style="text-align:center; padding:0.4rem 0; font-size: 0.9rem;"> © Copyright OEAW | <a
                href="imprint.html">Impressum</a>
        </div>
        <!-- #wrapper-footer-full -->
        
        <script src="https://cdn.jsdelivr.net/npm/typesense-instantsearch-adapter@2/dist/typesense-instantsearch-adapter.min.js"/>
        <script src="https://cdn.jsdelivr.net/npm/algoliasearch@4.5.1/dist/algoliasearch-lite.umd.js" integrity="sha256-EXPXz4W6pQgfYY3yTpnDa3OH8/EPn16ciVsPQ/ypsjk=" crossorigin="anonymous"/>
        <script src="https://cdn.jsdelivr.net/npm/instantsearch.js@4.8.3/dist/instantsearch.production.min.js" integrity="sha256-LAGhRRdtVoD6RLo2qDQsU2mp+XVSciKRC8XPOBWmofM=" crossorigin="anonymous"/>
        <script src="js/listStopProp.js"/>
        <script src="https://code.jquery.com/jquery-3.6.3.min.js" integrity="sha256-pvPw+upLPUjgMXY0G+8O0xUf+/Im1MZjXxxgOcBQBXU=" crossorigin="anonymous"/>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/js/bootstrap.bundle.min.js" integrity="sha384-ndDqU0Gzau9qJ1lfW4pNLlhNTkCfHzAVBReH9diLvGRem5+R9g2FzA8ZGN954O5Q" crossorigin="anonymous"></script>
    </xsl:template>
</xsl:stylesheet>
