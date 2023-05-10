<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mam="whatever" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl tei xs" version="3.0">
    <!-- The template "add_header-navigation-custom-title" creates a custom header without
                using tei:title but includes prev and next urls. -->
    <xsl:template name="header-nav">
        <xsl:variable name="doc_title">
            <xsl:value-of select="descendant::tei:titleSmt/tei:title[@level = 'a'][1]/text()"/>
        </xsl:variable>
        <xsl:variable name="correspContext" as="node()?" select="descendant::tei:correspDesc[1]/tei:correspContext"/>
        <div class="row" id="title-nav">
            <div class="col-md-2 col-lg-2 col-sm-12">
                <xsl:if test="$correspContext/tei:ref/@subtype='previous_letter'">
                    <h1>
                        <nav class="navbar navbar-previous-next" style="text-indent: 1em;">
                            <i class="fas fa-chevron-left nav-link float-start" href="#"
                                id="navbarDropdownLeft" role="button" data-bs-toggle="dropdown"
                                aria-expanded="false"/>
                            <ul class="dropdown-menu unstyled" aria-labelledby="navbarDropdown">
                                <xsl:if
                                    test="$correspContext/tei:ref[@type = 'withinCollection' and @subtype = 'previous_letter'][1]">
                                    <span class="dropdown-item-text">Nächster Brief </span>
                                    <xsl:for-each
                                        select="$correspContext/tei:ref[@type = 'withinCollection' and @subtype = 'previous_letter']">
                                        <xsl:call-template name="mam:nav-li-item">
                                            <xsl:with-param name="eintrag" select="."/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:if>
                                <xsl:if
                                    test="$correspContext/tei:ref[@type = 'withinCorrespondence' and @subtype = 'previous_letter'][1]">
                                    <span class="dropdown-item-text">… in der Korrespondenz</span>
                                    <xsl:for-each
                                        select="$correspContext/tei:ref[@type = 'withinCorrespondence' and @subtype = 'previous_letter']">
                                        <xsl:call-template name="mam:nav-li-item">
                                            <xsl:with-param name="eintrag" select="."/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:if>
                            </ul>
                        </nav>
                    </h1>
                </xsl:if>
            </div>
            <div class="col-md-8">
                <h1 align="center">
                    <xsl:value-of select="//tei:fileDesc/tei:titleStmt/tei:title[@level = 'a']"/>
                </h1>
            </div>
            <div class="col-md-2 col-lg-2 col-sm-12" style="text-align:right">
                <xsl:if test="$correspContext/tei:ref/@subtype='next_letter'">
                    <h1>
                        <nav class="navbar navbar-previous-next float-end dropstart">
                            <i class="fas fa-chevron-right nav-link" href="#"
                                id="navbarDropdownRight" role="button" data-bs-toggle="dropdown"
                                aria-expanded="false"/>
                            <ul class="dropdown-menu" aria-labelledby="navbarDropdown">
                                <xsl:if
                                    test="$correspContext/tei:ref[@type = 'withinCollection' and @subtype = 'next_letter'][1]">
                                    <span class="dropdown-item-text">Nächster Brief </span>
                                    <xsl:for-each
                                        select="$correspContext/tei:ref[@type = 'withinCollection' and @subtype = 'next_letter']">
                                        <xsl:call-template name="mam:nav-li-item">
                                            <xsl:with-param name="eintrag" select="."/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:if>
                                <xsl:if
                                    test="$correspContext/tei:ref[@type = 'withinCorrespondence' and @subtype = 'next_letter'][1]">
                                    <span class="dropdown-item-text">… in der Korrespondenz</span>
                                    <xsl:for-each
                                        select="$correspContext/tei:ref[@type = 'withinCorrespondence' and @subtype = 'next_letter']">
                                        <xsl:call-template name="mam:nav-li-item">
                                            <xsl:with-param name="eintrag" select="."/>
                                        </xsl:call-template>
                                    </xsl:for-each>
                                </xsl:if>
                            </ul>
                        </nav>
                    </h1>
                </xsl:if>
            </div>
        </div>
    </xsl:template>
    <xsl:template name="mam:nav-li-item">
        <xsl:param name="eintrag" as="node()"/>
        <xsl:element name="li">
            <xsl:element name="a">
                <xsl:attribute name="class">
                    <xsl:text>dropdown-item</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat($eintrag/@target, '.html')"/>
                </xsl:attribute>
                <xsl:choose>
                    <xsl:when test="contains($eintrag/@subtype, 'next')">
                        <i class="fas fa-chevron-right"/>&#160; </xsl:when>
                    <xsl:when test="contains($eintrag/@subtype, 'previous')">
                        <i class="fas fa-chevron-left"/>&#160; </xsl:when>
                </xsl:choose>
                <xsl:value-of select="$eintrag"/>
            </xsl:element>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
