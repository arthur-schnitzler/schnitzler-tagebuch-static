 document.addEventListener("DOMContentLoaded", function() {
        OpenSeadragon({
            id: "openseadragon-photo",
            prefixUrl: "https://cdnjs.cloudflare.com/ajax/libs/openseadragon/2.4.1/images/",
            sequenceMode: true,
            showReferenceStrip: true,
            tileSources: [
                <xsl:for-each select=".//tei:facsimile/tei:graphic/data(@url)">{
                    type: 'image',
                    url: '<xsl:value-of select="concat(., '?format=iiif')"/>'
                }
                <xsl:choose>
                    <xsl:when test="position() != last()">,</xsl:when>
                </xsl:choose>
                </xsl:for-each>
            ]
        });
    });