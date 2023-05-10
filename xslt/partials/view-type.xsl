<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:_="urn:acdh"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:mam="whatever"
  exclude-result-prefixes="xs xsl tei" version="2.0">
  <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes"
    omit-xml-declaration="yes"/>
  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <h1>Widget tei-facsimile.</h1>
      <p>Contact person: daniel.stoxreiter@oeaw.ac.at</p>
      <p>Applied with call-templates in html:body.</p>
      <p>The template "view type" generates various view types e.g. reading, diplomatic,
        commentary.</p>
      <p>Select between a type with or without images.</p>
      <p>Bootstrap is required.</p>
    </desc>
  </doc>
  <!--<xsl:function name="_:ano">
        <xsl:param name="node"/>
        <xsl:for-each-group select="$node" group-by="$node">
            <xsl:sequence
                select="concat('(', count(current-group()[current-grouping-key() = .]), ' ', current-grouping-key(), ')')"
            />
        </xsl:for-each-group>
    </xsl:function>-->
  <xsl:template name="mam:view-type-img">
    <xsl:variable name="msIdentifier"
      select="ancestor::tei:TEI/tei:teiHeader[1]/tei:fileDesc[1]/tei:sourceDesc[1]/tei:listWit[1]/tei:witness[@n = '1']/tei:msDesc[1]/tei:msIdentifier[1]"
      as="node()?"/>
    <xsl:variable name="facs-folder" as="xs:string?">
      <xsl:choose>
        <!-- DRUCKE -->
        <xsl:when test="descendant::tei:sourceDesc[not(tei:listWit)]">
          <xsl:text>Drucke</xsl:text>
        </xsl:when>
        <!-- BEINECKE -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'Beinecke')]">
          <xsl:choose>
            <xsl:when test="descendant::tei:pb[1]/@facs[starts-with(., 'ASanRBH')]">
              <xsl:text>Beinecke_ASanRBH</xsl:text>
            </xsl:when>
            <xsl:when test="descendant::tei:pb[1]/@facs[starts-with(., 'Foto-Innen')]">
              <xsl:text>Beinecke_RBH_Foto-Innen</xsl:text>
            </xsl:when>
            <xsl:when test="descendant::tei:pb[1]/@facs[starts-with(., 'undatiert')]">
              <xsl:text>Beinecke_undatiert</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of
                select="concat('Beinecke_', substring(descendant::tei:pb[1]/@facs, 1, 4))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <!-- BSB -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'Bayerische Staatsbibliothek')]">
          <xsl:text>BSB</xsl:text>
        </xsl:when>
        <!-- BURGERBIBLIOTHEK -->
        <!--<xsl:when
                                                  test="descendant::tei:repository[contains(., 'Burgerbibliothek')]">
                                                  <xsl:text>Burgerbibliothek</xsl:text>
                                                </xsl:when>-->
        <!-- CUL -->
        <xsl:when test="$msIdentifier/tei:settlement[contains(., 'Cambridge')]">
          <xsl:variable name="Folder-Number">
            <xsl:choose>
              <xsl:when test="descendant::tei:pb[1]/@facs[contains(., '-')]">
                <xsl:value-of
                  select="replace(tokenize(substring-after(descendant::tei:pb[1]/@facs, '-0')[1], '-')[1], '^0+', '')"
                />
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>noFolderNumber</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$msIdentifier/tei:idno[contains(., 'Schnitzler, A')]">
              <xsl:text>CUL_A</xsl:text>
            </xsl:when>
            <xsl:when test="$msIdentifier/tei:idno[contains(., 'Abschrift')]">
              <xsl:text>CUL_Abschriften</xsl:text>
            </xsl:when>
            <xsl:when test="$Folder-Number != 'noFolderNumber'">
              <xsl:value-of select="concat('CUL_MS_B', $Folder-Number)"/>
            </xsl:when>
          </xsl:choose>
        </xsl:when>
        <!-- DLA -->
        <xsl:when test="$msIdentifier/tei:settlement = 'Marbach am Neckar'">
          <xsl:value-of select="concat('DLA_', substring(descendant::tei:pb[1]/@facs, 1, 5))"/>
        </xsl:when>
        <!-- HOCHSTIFT -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'Hochstift')]">
          <xsl:text>Hochstift</xsl:text>
        </xsl:when>
        <!-- KLASSIK STIFTUNG WEIMAR -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'Klassik Stiftung')]">
          <xsl:text>Klassik_Stiftung_Weimar</xsl:text>
        </xsl:when>
        <!-- KÖNIGLICHE BIBLIOTHEK KOPENHAGEN -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'Kongelige')]">
          <xsl:text>Koenigliche_Bibliothek_Kopenhagen</xsl:text>
        </xsl:when>
        <!-- LEO BAECK INSTITUTE -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'Leo Baeck')]">
          <xsl:text>Leo_Baeck_Institute</xsl:text>
        </xsl:when>
        <!-- MONACENSIA -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'Monacensia')]">
          <xsl:text>Monacensia</xsl:text>
        </xsl:when>
        <!-- NATIONAL LIBRARY ISRAEL -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'Israel')]">
          <xsl:text>National_Library_Israel</xsl:text>
        </xsl:when>
        <!-- NDL KIEL -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'Christian-Albrechts')]">
          <xsl:text>NDL_Kiel</xsl:text>
        </xsl:when>
        <!-- ÖGL -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'Gesellschaft für Literatur')]">
          <xsl:text>OGL</xsl:text>
        </xsl:when>
        <!-- ÖNB -->
        <xsl:when
          test="$msIdentifier/tei:repository[contains(., 'Österreichische Nationalbibliothek')]">
          <xsl:text>ONB_Literaturarchiv</xsl:text>
        </xsl:when>
        <!-- ORIEL LEIBZON -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'Leibzon')]">
          <xsl:text>Privatbesitz_Oriel_Leibzon</xsl:text>
        </xsl:when>
        <!-- REINHARD URBACH -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'Urbach')]">
          <xsl:text>Privatbesitz_Reinhard_Urbach</xsl:text>
        </xsl:when>
        <!-- SBB -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'Staatsbibliothek Berlin')]">
          <xsl:text>SBB</xsl:text>
        </xsl:when>
        <!-- SUB HAMBURG -->
        <xsl:when test="$msIdentifier/tei:settlement[contains(., 'Hamburg')]">
          <xsl:text>SUB_Hamburg</xsl:text>
        </xsl:when>
        <!-- UB SALZBURG -->
        <xsl:when test="$msIdentifier/tei:settlement[contains(., 'Salzburg')]">
          <xsl:text>UB_Salzburg</xsl:text>
        </xsl:when>
        <!-- UB WROCLAW -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'Uniwersytecka')]">
          <xsl:text>UB_Wroclaw</xsl:text>
        </xsl:when>
        <!-- UNITED NATIONS ARCHIVE -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'United Nations')]">
          <xsl:text>United_Nations_Archives</xsl:text>
        </xsl:when>
        <!-- WBR -->
        <xsl:when test="$msIdentifier/tei:repository[contains(., 'Wienbibliothek')]">
          <xsl:text>WBR</xsl:text>
        </xsl:when>
        <!-- otherwise -->
        <xsl:otherwise>
          <xsl:value-of select="$msIdentifier/tei:repository/replace(., ' ', '_')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when
        test="descendant::tei:pb[1]/@facs and not(starts-with(descendant::tei:pb[1]/@facs, 'http') or starts-with(descendant::tei:pb[1]/@facs, 'www.')) and not(contains(descendant::tei:pb[1]/@facs, '.pdf'))">
        <div id="text-resize" class="row transcript active">
          <xsl:for-each select="//tei:body">
            <div id="text-resize" class="col-md-6 col-lg-6 col-sm-12 text yes-index">
              <div id="section">
                <div class="card-body">
                  <div class="card-body-text">
                    <xsl:apply-templates select="//tei:text"/>
                    <xsl:element name="ol">
                      <xsl:attribute name="class">
                        <xsl:text>list-for-footnotes</xsl:text>
                      </xsl:attribute>
                      <xsl:apply-templates select="descendant::tei:note[@type = 'footnote']"
                        mode="footnote"/>
                    </xsl:element>
                  </div>
                </div>
                <!--<xsl:if test="//tei:note[@type = 'footnote']">
                                    <div class="card-footer">
                                        <a class="anchor" id="footnotes"/>
                                        <ul class="footnotes">
                                            <xsl:for-each select="//tei:note[@place = 'foot']">
                                                <li>
                                                  <a class="anchorFoot" id="{@xml:id}"/>
                                                  <span class="footnote_link">
                                                  <a href="#{@xml:id}_inline" class="nounderline">
                                                  <xsl:value-of select="@n"/>
                                                  </a>
                                                  </span>
                                                  <span class="footnote_text">
                                                  <xsl:apply-templates/>
                                                  </span>
                                                </li>
                                            </xsl:for-each>
                                        </ul>
                                    </div>
                                </xsl:if>-->
              </div>
            </div>
            <div id="img-resize" class="col-md-6 col-lg-6 col-sm-12 facsimiles">
              <div id="viewer">
                <div id="container_facsimile">
                  <div class="card-body-iif">
                    <xsl:variable name="facsimiles">
                      <xsl:value-of
                        select="distinct-values(descendant::tei:pb[not(starts-with(@facs, 'http') or starts-with(@facs, 'www.') or @facs = '' or empty(@facs)) and not(preceding-sibling::tei:tp/@facs = @facs) or (not(@facs))]/@facs)"
                      />
                    </xsl:variable>
                    <xsl:variable name="url-of-facsimile">
                      <xsl:for-each select="tokenize($facsimiles, ' ')">
                        <xsl:text>"https://iiif.acdh-dev.oeaw.ac.at/iiif/images/schnitzler-briefe/</xsl:text>
                        <xsl:value-of select="$facs-folder"/>
                        <xsl:text>/</xsl:text>
                        <xsl:value-of select="."/>
                        <xsl:text>.jp2/info.json"</xsl:text>
                        <xsl:if test="not(position() = last())">
                          <xsl:text>, </xsl:text>
                        </xsl:if>
                      </xsl:for-each>
                    </xsl:variable>
                    <xsl:variable name="tileSources"
                      select="concat('tileSources:[', $url-of-facsimile, '], ')"/>
                    <div id="openseadragon-photo" style="height:800px;">
                      <script src="https://cdnjs.cloudflare.com/ajax/libs/openseadragon/4.0.0/openseadragon.min.js"/>
                      <script type="text/javascript">
                                                var viewer = OpenSeadragon({
                                                    id: "openseadragon-photo",
                                                    protocol: "http://iiif.io/api/image",
                                                    prefixUrl: "https://cdnjs.cloudflare.com/ajax/libs/openseadragon/4.0.0/images/",
                                                    sequenceMode: true,
                                                    showNavigationControl: true,
                                                    referenceStripScroll: 'horizontal',
                                                    showReferenceStrip: true,
                                                    defaultZoomLevel: 0,
                                                    fitHorizontally: true,<xsl:value-of select="$tileSources"/>
                                                // Initial rotation angle
                                                degrees: 0,
                                                // Show rotation buttons
                                                showRotationControl: true,
                                                // Enable touch rotation on tactile devices
                                                gestureSettingsTouch: {
                                                    pinchRotate: true
                                                }
                                            });</script>
                      <div class="image-rights">
                        <xsl:text>Bildrechte © </xsl:text>
                        <xsl:value-of
                          select="//tei:fileDesc/tei:sourceDesc[1]/tei:listWit[1]/tei:witness[1]/tei:msDesc[1]/tei:msIdentifier[1]/tei:repository[1]"/>
                        <xsl:text>, </xsl:text>
                        <xsl:value-of
                          select="//tei:fileDesc/tei:sourceDesc[1]/tei:listWit[1]/tei:witness[1]/tei:msDesc[1]/tei:msIdentifier[1]/tei:settlement[1]"
                        />
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </xsl:for-each>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div class="card-body">
          <div class="card-body-normalertext">
            <xsl:apply-templates select="//tei:text"/>
            <xsl:element name="ol">
              <xsl:attribute name="class">
                <xsl:text>list-for-footnotes</xsl:text>
              </xsl:attribute>
              <xsl:apply-templates select="//tei:note[@type = 'footnote']" mode="footnote"/>
            </xsl:element>
          </div>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>
