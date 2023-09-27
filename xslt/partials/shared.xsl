<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://dse-static.foo.bar"
    exclude-result-prefixes="xs"
    version="2.0">

    <xsl:function name="local:makeId" as="xs:string">
        <xsl:param name="currentNode" as="node()"/>
        <xsl:variable name="nodeCurrNr">
            <xsl:value-of select="count($currentNode//preceding-sibling::*) + 1"/>
        </xsl:variable>
        <xsl:value-of select="concat(name($currentNode), '__', $nodeCurrNr)"/>
    </xsl:function>

    <xsl:template match="tei:rs[@ref or @key]">
            <xsl:element name="a">
                <!--<xsl:attribute name="data-toggle">modal</xsl:attribute>
                <xsl:attribute name="data-target">-->
                <xsl:attribute name="target">
                    <xsl:value-of select="concat(replace(@ref, '#',''), replace(@key, '#',''), '.html')"/>
                </xsl:attribute>
                <xsl:attribute name="style">color:black</xsl:attribute>
                <xsl:apply-templates/>
            </xsl:element>
    </xsl:template>

</xsl:stylesheet>