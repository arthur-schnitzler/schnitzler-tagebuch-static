<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:df="http://example.com/df"
    exclude-result-prefixes="xs" version="2.0">
    <xsl:function name="df:germanNames">
        <xsl:param name="input"/>
        <xsl:choose>
            <xsl:when test="$input='Monday'">Montag</xsl:when>
            <xsl:when test="$input='Tuesday'">Dienstag</xsl:when>
            <xsl:when test="$input='Wednesday'">Mittwoch</xsl:when>
            <xsl:when test="$input='Thursday'">Donnerstag</xsl:when>
            <xsl:when test="$input='Friday'">Freitag</xsl:when>
            <xsl:when test="$input='Saturday'">Samstag</xsl:when>
            <xsl:when test="$input='Sunday'">Sonntag</xsl:when>
            <xsl:when test="$input='January'">Januar</xsl:when>
            <xsl:when test="$input='February'">Februar</xsl:when>
            <xsl:when test="$input='March'">März</xsl:when>
            <xsl:when test="$input='May'">Mai</xsl:when>
            <xsl:when test="$input='June'">Juni</xsl:when>
            <xsl:when test="$input='July'">Juli</xsl:when>
            <xsl:when test="$input='October'">Oktober</xsl:when>
            <xsl:when test="$input='December'">Dezember</xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$input"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>