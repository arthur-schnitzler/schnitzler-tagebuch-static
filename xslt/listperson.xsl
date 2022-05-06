<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/person.xsl"/>
    <xsl:variable name="teiSource" select="'listperson.xml'"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select="'Personen'"/>
        </xsl:variable>
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html lang="de">
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
            </xsl:call-template>
            
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    
                    <div class="container-fluid">                        
                        <div class="card">
                            <div class="card-header" style="text-align:center">
                                <h1><xsl:value-of select="$doc_title"/></h1>
                                <h3>
                                    <a>
                                        <i class="fas fa-info" title="Info zu diesem Personenregister" data-toggle="modal" data-target="#exampleModal"/>
                                    </a><xsl:text> | </xsl:text>
                                    <a href="{$teiSource}">
                                        <i class="fas fa-download" title="Download XML/TEI"/>
                                    </a>
                                </h3>
                            </div>
                            <div class="card-body">
                            <div class="w-100 text-center">
                                <div class="spinner-grow table-loader" role="status">
                                    <span class="sr-only">Loading...</span>
                                </div>          
                            </div>                      
                                <table class="table table-striped display d-none" id="tocTable" style="width:100%">
                                    <thead>
                                        <tr>
                                            <th scope="col">Nachname</th>
                                            <th scope="col">Vorname</th>
                                            <th scope="col">Erwähnungen</th>
                                            <th scope="col">Profession</th>
                                            <th scope="col">geboren am</th>
                                            <th scope="col">geboren in</th>
                                            <th scope="col">gestorben am</th>
                                            <th scope="col">gestorben in</th>
                                            <th scope="col">ID</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <xsl:for-each select=".//tei:person">
                                            <xsl:variable name="id">
                                                <xsl:value-of select="data(@xml:id)"/>
                                            </xsl:variable>
                                            <tr>
                                                <td>
                                                    <xsl:value-of select=".//tei:persName[1]/tei:surname/text()"/>
                                                </td>
                                                <td>                                        
                                                    <xsl:value-of select=".//tei:persName[1]/tei:forename/text()"/>
                                                </td>
                                                <td>
                                                    <xsl:value-of select="count(.//tei:ptr)"/>
                                                </td>
                                                <td><xsl:value-of select="string-join(.//tei:occupation/text(), '; ')"/></td>
                                                <td><xsl:value-of select=".//tei:birth/tei:date/text()"/></td>
                                                <td><xsl:value-of select=".//tei:birth//tei:settlement/text()"/></td>
                                                <td><xsl:value-of select=".//tei:death/tei:date/text()"/></td>
                                                <td><xsl:value-of select=".//tei:death//tei:settlement/text()"/></td>
                                                <td>
                                                    <a>
                                                        <xsl:attribute name="href">
                                                            <xsl:value-of select="concat($id, '.html')"/>
                                                        </xsl:attribute>
                                                        <xsl:value-of select="$id"/>
                                                    </a> 
                                                </td>
                                            </tr>
                                        </xsl:for-each>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                        <div class="modal" tabindex="-1" role="dialog" id="exampleModal">
                            <div class="modal-dialog" role="document">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title">Info zum Personenregister</h5>
                                    </div>
                                    <div class="modal-body">
                                        <p>Das digitale Personenverzeichnis geht auf die Grundlage von Peter Michael Braunwarth zurück,
                                            der die im Zuge der Printedition erstellten Karteikarten digitalisierte. Diese Daten sind
                                            mittlerweile in der Webapplikation PMB – https://pmb.acdh.oeaw.ac.at/ – verfügbar und werden
                                            von neueren Projekten aktualisiert und weitergepflegt. Im Mai 2021 wurde zuletzt ein Abgleich gemacht,
                                            so dass nun deutlich mehr Personen mit Lebensdaten identifiziert sind, als das zum Zeitpunkt
                                            der Drucklegung der Fall war.</p>
                                        <p>Im Zuge dessen wurde eine eine Schwäche der digitalen Daten notdürftig behoben, nämlich dass in den
                                            digitalen Daten nicht alle Personen an der Stelle ihres Vorkommens ausgezeichnet sind. Nunmehr 
                                            greift der Index auf eine aus dem Register der Printedition entwickelte, tagesaktuelle Liste 
                                            zu, um das Vorkommen einer Person an einem Tag zu ermitteln.</p>
                                        <p>Weiterhin eine Schwachstelle, die Erklärung benötigt, sind jene Personen, die im Register vorkommen, die aber zu keinem Ergebnis im Tagebuch führen.
                                            Dabei handelt es sich um Verfasser von Werken, die im Tagebuch Erwähnung finden, die aber selbst nicht namentlich auftreten. Das gedruckte Werkregister
                                            wird hoffentlich zu einem späteren Zeitpunkt eingepflegt. In dem betreffenden Fall – wenn
                                            ein Name keinen Fundort hat — sei behelfsmäßig auf das gedruckte Gesamtregister verwiesen, das unter https://www.austriaca.at/arthur_schnitzler_tagebuch?frames=yes
                                            eingesehen werden kann.</p>
                                        <p>Der Name des jeweiligen Person ist mit jenen Dokumenten
                                            verlinkt, in denen diese erwähnt wird. </p>
                                        <p>Die Sortierung der einzelnen Spalten kann durch einen Klick
                                            auf die Spaltenüberschrift geändert werden. Das Suchfeld
                                            rechts oberhalb der Tabelle durchsucht den gesamten
                                            Tabelleninhalt. Darüberhinaus können mit Hilfe der
                                            Suchfelder oberhalb der Spalten gezielt die Inhalte dieser
                                            Spalten durchsucht bzw. gefiltert werden. </p>
                                        <p>Die (ggf. gefilterte) Tabelle kann als PDF oder Excel
                                            heruntergeladen bzw. in den Zwischenspeicher kopiert
                                            werden.</p>
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-dismiss="modal">Schließen</button>
                                    </div>
                                </div>
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
        <xsl:for-each select=".//tei:person[@xml:id]">
            <xsl:variable name="filename" select="concat(./@xml:id, '.html')"/>
            <xsl:variable name="name">
                <xsl:choose>
                    <xsl:when
                        test="./tei:persName[1]/tei:forename[1] and ./tei:persName[1]/tei:surname[1]">
                        <xsl:value-of
                            select="normalize-space(concat(./tei:persName[1]/tei:forename[1], ' ', ./tei:persName[1]/tei:surname[1]))"
                        />
                    </xsl:when>
                    <xsl:when test="./tei:persName[1]/tei:forename[1]">
                        <xsl:value-of select="normalize-space(./tei:persName[1]/tei:forename[1])"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="normalize-space(./tei:persName[1]/tei:surname[1])"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="lebensdaten_geburtsdatum-und-ort"
                select="./tei:birth[1]/tei:date[1]//text()"/>
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
                                        <h1>
                                            <xsl:value-of select="$name"/>
                                            <xsl:text> </xsl:text>
                                            <xsl:choose>
                                                <xsl:when test="./tei:birth and ./tei:death">
                                                    <span class="lebensdaten">
                                                        <xsl:text>(</xsl:text>
                                                        <xsl:choose>
                                                            <xsl:when
                                                                test="./tei:birth/tei:date and ./tei:birth/tei:placeName/tei:settlement">
                                                                <xsl:value-of
                                                                    select="concat(./tei:birth/tei:date, ' ', ./tei:birth/tei:placeName/tei:settlement)"
                                                                />
                                                            </xsl:when>
                                                            <xsl:when test="./tei:birth/tei:date">
                                                                <xsl:value-of select="./tei:birth/tei:date"/>
                                                            </xsl:when>
                                                            <xsl:when
                                                                test="./tei:birth/tei:placeName/tei:settlement">
                                                                <xsl:value-of
                                                                    select="concat('geboren in ', ./tei:birth/tei:placeName/tei:settlement)"
                                                                />
                                                            </xsl:when>
                                                        </xsl:choose>
                                                        <xsl:text> – </xsl:text>
                                                        <xsl:choose>
                                                            <xsl:when
                                                                test="./tei:death/tei:date and ./tei:death/tei:placeName/tei:settlement">
                                                                <xsl:value-of
                                                                    select="concat(./tei:death/tei:date, ' ', ./tei:death/tei:placeName/tei:settlement)"
                                                                />
                                                            </xsl:when>
                                                            <xsl:when test="./tei:death/tei:date">
                                                                <xsl:value-of select="./tei:death/tei:date"/>
                                                            </xsl:when>
                                                            <xsl:when
                                                                test="./tei:death/tei:placeName/tei:settlement">
                                                                <xsl:value-of
                                                                    select="concat('geboren in ', ./tei:death/tei:placeName/tei:settlement)"
                                                                />
                                                            </xsl:when>
                                                        </xsl:choose>
                                                        <xsl:text>)</xsl:text>
                                                    </span>
                                                </xsl:when>
                                                <xsl:when test="./tei:birth">
                                                    <span class="lebensdaten">
                                                        <xsl:text>(geboren </xsl:text>
                                                        <xsl:choose>
                                                            <xsl:when
                                                                test="./tei:birth/tei:date and ./tei:birth/tei:placeName/tei:settlement">
                                                                <xsl:value-of
                                                                    select="concat(./tei:birth/tei:date, ' ', ./tei:birth/tei:placeName/tei:settlement)"
                                                                />
                                                            </xsl:when>
                                                            <xsl:when test="./tei:birth/tei:date">
                                                                <xsl:value-of select="./tei:birth/tei:date"/>
                                                            </xsl:when>
                                                            <xsl:when
                                                                test="./tei:birth/tei:placeName/tei:settlement">
                                                                <xsl:value-of
                                                                    select="concat('geboren in ', ./tei:birth/tei:placeName/tei:settlement)"
                                                                />
                                                            </xsl:when>
                                                        </xsl:choose>
                                                        <xsl:text>)</xsl:text>
                                                    </span>
                                                </xsl:when>
                                                <xsl:when test="./tei:death">
                                                    <span class="lebensdaten">
                                                        <xsl:text>(† </xsl:text>
                                                        <xsl:choose>
                                                            <xsl:when
                                                                test="./tei:death/tei:date and ./tei:death/tei:placeName/tei:settlement">
                                                                <xsl:value-of
                                                                    select="concat(./tei:death/tei:date, ' ', ./tei:death/tei:placeName/tei:settlement)"
                                                                />
                                                            </xsl:when>
                                                            <xsl:when test="./tei:death/tei:date">
                                                                <xsl:value-of select="./tei:death/tei:date"/>
                                                            </xsl:when>
                                                            <xsl:when
                                                                test="./tei:death/tei:placeName/tei:settlement">
                                                                <xsl:value-of
                                                                    select="concat('geboren in ', ./tei:death/tei:placeName/tei:settlement)"
                                                                />
                                                            </xsl:when>
                                                        </xsl:choose>
                                                        <xsl:text>)</xsl:text>
                                                    </span>
                                                </xsl:when>
                                                <xsl:otherwise/>
                                            </xsl:choose>
                                        </h1>
                                    </div>
                                    <xsl:call-template name="person_detail"/>
                                </div>
                            </div>
                            <xsl:call-template name="html_footer"/>
                        </div>
                    </body>
                </html>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>
