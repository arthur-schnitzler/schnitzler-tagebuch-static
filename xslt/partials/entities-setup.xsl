<?xml version="1.0" encoding="UTF-8"?>
<!--
    Setup-Modul für entities.xsl:
    Imports, Parameter, Variablen und Keys für Index-Dateien,
    den Relationen-CSV-Index und das Relations-Vokabular (relations.json).
    Wird per <xsl:include href="./entities-setup.xsl"/> in entities.xsl eingebunden.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:mam="whatever" version="2.0" exclude-result-prefixes="xsl tei xs">
    <xsl:import href="./LOD-idnos.xsl"/>
    <!-- Index-Dateien -->
    <xsl:param name="places" select="document('../../data/indices/listplace.xml')"/>
    <!-- nur fürs Schnitzler-Tagebuch die folgenden beiden Einbindungen -->
    <xsl:param name="listperson" select="document('../../data/indices/listperson.xml')"/>
    <xsl:key name="author-lookup" match="tei:person" use="tei:idno[@subtype = 'pmb']"/>
    <!-- Korrespondenzen (nur für schnitzler-briefe) -->
    <xsl:variable name="listcorrespondencePath" select="'../../data/indices/listcorrespondence.xml'"/>
    <xsl:param name="listcorrespondence" select="
            if (unparsed-text-available($listcorrespondencePath))
            then
                document($listcorrespondencePath)
            else
                ()"/>
    <xsl:key name="correspondence-lookup" match="tei:personGrp[not(@ana='planned') and not(@xml:id='correspondence_null')]" use="tei:persName[@role='main'][1]/@ref"/>
    <!-- Werke / Bibliografie -->
    <xsl:variable name="listbiblPath" select="'../../data/indices/listbibl.xml'"/>
    <xsl:variable name="listworkPath" select="'../../data/indices/listwork.xml'"/>
    <xsl:variable name="listeventIndicesPath" select="'../../data/indices/listevent.xml'"/>
    <xsl:variable name="listeventEditionsPath" select="'../../data/editions/listevent.xml'"/>
    <xsl:param name="events" select="
            if (unparsed-text-available($listeventIndicesPath))
            then
                document($listeventIndicesPath)/descendant::tei:listEvent[1]
            else
                if (unparsed-text-available($listeventEditionsPath))
                then
                    document($listeventEditionsPath)/descendant::tei:listEvent[1]
                else
                    ()"/>
    <xsl:variable name="actualFilePath" select="
            if (unparsed-text-available($listbiblPath))
            then
                $listbiblPath
            else
                $listworkPath"/>
    <xsl:param name="works" select="document($actualFilePath)"/>
    <xsl:key name="work-lookup" match="tei:bibl" use="tei:relatedItem/@target"/>
    <xsl:key name="only-relevant-uris" match="item" use="abbr"/>
    <xsl:key name="authorwork-lookup" match="tei:bibl"
        use="tei:author/@*[name() = 'key' or name() = 'ref']"/>
    <!-- Konkordanzen (Person-Tag, Werk-Tag) -->
    <xsl:param name="konkordanz" select="document('../../data/indices/index_person_day.xml')"/>
    <xsl:param name="work-day" select="document('../../data/indices/index_work_day.xml')"/>
    <xsl:key name="konk-lookup" match="item" use="ref"/>
    <xsl:key name="work-day-lookup" match="item" use="ref"/>
    <!-- Schnitzler-Lektüren -->
    <xsl:param name="lektueren-konkordanz" select="document('../../data/indices/konkordanz.xml')"/>
    <xsl:key name="lektueren-konk-lookup" match="ref" use="@xml:id"/>
    <!-- Projekt-interne Entitäten (für Relationen-Block) -->
    <xsl:variable name="listorgPath" select="'../../data/indices/listorg.xml'"/>
    <xsl:param name="listorg" select="
            if (unparsed-text-available($listorgPath))
            then
                document($listorgPath)
            else
                ()"/>
    <xsl:key name="project-person-xmlid" match="tei:person[@xml:id]" use="@xml:id"/>
    <xsl:key name="project-org-xmlid" match="tei:org[@xml:id]" use="@xml:id"/>
    <xsl:key name="project-place-xmlid" match="tei:place[@xml:id]" use="@xml:id"/>
    <xsl:key name="project-event-xmlid" match="tei:event[@xml:id]" use="@xml:id"/>
    <xsl:key name="project-bibl-xmlid" match="tei:bibl[@xml:id]" use="@xml:id"/>
    <!-- Relationen aus relations.csv (selber Ordner wie listperson.xml etc.) -->
    <xsl:variable name="relationsPath" select="'../../data/indices/relations.csv'"/>
    <xsl:variable name="relations-csv-raw" as="xs:string?" select="
            if (unparsed-text-available($relationsPath))
            then
                unparsed-text($relationsPath)
            else
                ()"/>
    <xsl:variable name="relations-lines" as="xs:string*" select="
            if ($relations-csv-raw) then
                tokenize($relations-csv-raw, '\r?\n')[position() gt 1][normalize-space(.) != '']
            else
                ()"/>
    <!-- Vorverarbeiteter Relationen-Index (wird pro Transformation einmal aufgebaut) -->
    <xsl:variable name="relations-doc">
        <relations>
            <xsl:for-each select="$relations-lines">
                <xsl:variable name="f" select="mam:split-csv-line(.)"/>
                <xsl:if test="count($f) ge 17
                              and matches($f[10], '^\d+$')
                              and matches($f[16], '^\d+$')">
                    <rel type="{$f[2]}"
                         src-id="{$f[10]}" src-type="{$f[11]}" src-name="{$f[9]}"
                         tgt-id="{$f[16]}" tgt-type="{$f[17]}" tgt-name="{$f[15]}"/>
                </xsl:if>
            </xsl:for-each>
        </relations>
    </xsl:variable>
    <xsl:key name="rel-by-src" match="rel" use="@src-id"/>
    <xsl:key name="rel-by-tgt" match="rel" use="@tgt-id"/>
    <!-- Vokabular für Relationen (relations.json im selben Ordner wie entities.xsl) -->
    <xsl:variable name="vocabPath" select="'relations.json'"/>
    <xsl:variable name="vocab-raw" as="xs:string?" select="
            if (unparsed-text-available($vocabPath))
            then
                unparsed-text($vocabPath)
            else
                ()"/>
    <xsl:variable name="vocab-doc">
        <vocab>
            <xsl:if test="$vocab-raw">
                <xsl:analyze-string select="$vocab-raw"
                    regex='&quot;([a-z]+relation)&quot;:\s*\[([^\]]*)\]'>
                    <xsl:matching-substring>
                        <xsl:variable name="cls" select="regex-group(1)"/>
                        <xsl:variable name="body" select="regex-group(2)"/>
                        <xsl:analyze-string select="$body"
                            regex='&quot;name&quot;:\s*&quot;([^&quot;]*)&quot;,\s*&quot;name_reverse&quot;:\s*&quot;([^&quot;]*)&quot;'>
                            <xsl:matching-substring>
                                <entry class="{$cls}" name="{regex-group(1)}"
                                    reverse="{regex-group(2)}"/>
                            </xsl:matching-substring>
                        </xsl:analyze-string>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:if>
        </vocab>
    </xsl:variable>
    <xsl:key name="vocab-by-cn" match="entry" use="concat(@class, '|', @name)"/>
</xsl:stylesheet>
