<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0" exclude-result-prefixes="tei xsl xs">
    <xsl:output encoding="UTF-8" media-type="text/html" method="xhtml" version="1.0" indent="yes" omit-xml-declaration="yes"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:template match="/">
        <xsl:variable name="doc_title">
            <xsl:value-of select=".//tei:title[@type='main'][1]/text()"/>
        </xsl:variable>

        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
        <html xmlns="http://www.w3.org/1999/xhtml">
            <xsl:call-template name="html_head">
                <xsl:with-param name="html_title" select="$doc_title"></xsl:with-param>
            </xsl:call-template>
            
            <body class="page">
                <div class="hfeed site" id="page">
                    <xsl:call-template name="nav_bar"/>
                    <div class="wrapper" id="wrapper-hero">
                        <!-- ******************* The Hero Area ******************* -->
                        <div class="wrapper" id="wrapper-hero-content" style="background-image:url(https://shared.acdh.oeaw.ac.at/schnitzler-tagebuch/hero-bg.jpg)">
                            <div class="container-fluid-empty hero-light" id="wrapper-hero-inner" tabindex="-1">
                                <div>
                                    <h1 class="mb-0">Arthur Schnitzler</h1>
                                    <h1 class="display-3 mb-2">Tagebuch</h1>
                                    <h2>1879 – 1931</h2>
                                </div>
                                <p class="mt-3">16.407 Einträge notierte der Schriftsteller Arthur Schnitzler in sein Tagebuch. Sie geben Auskunft über das Leben des Wiener Schriftstellers, die Begegnungen, die er machte und die Gespräche die er führte.</p>
                                <a data-template="app:firstDoc"/>
                                <a href="show.html?document=about.xml&amp;directory=meta&amp;stylesheet=meta">
                                    <button class="btn btn-round">Mehr erfahren</button>
                                </a>
                            </div>
                        </div>
                        <!-- #wrapper-hero-content -->
                        
                        <div class="wrapper" id="index-wrapper">
                            <div class="container-fluid-start" id="content" tabindex="-1">
                                <div class="row">
                                    <!-- Do the left sidebar check and opens the primary div -->
                                    <div class="col-md-12 content-area" id="primary">
                                        <main class="site-main" id="main">
                                            <!-- Use custom content block templates if they are defined -->
                                            
                                            <div class="card-wrapper">
                                                <article class="card col-md-6 flat-style">
                                                    <div class="card-inner card-vertical" style="min-height:420px;">
                                                        <a class="entry-top-thumbnail" style="height:230px;" href="#" rel="bookmark">
                                                            <img width="1024" height="684" src="https://shared.acdh.oeaw.ac.at/schnitzler-tagebuch/resources/img/post-bg-1.jpg" alt=""/>
                                                        </a>
                                                        <div data-template="app:randomDoc" data-template-maxlen="200"/>
                                                        <!-- .entry-text-content -->
                                                    </div>
                                                    <!-- .card-inner -->
                                                </article>
                                                <!-- #post-## -->
                                                <article class="card col-md-6 flat-style">
                                                    <div class="card-inner card-vertical" style="min-height:420px;">
                                                        <a class="entry-top-thumbnail" style="height:230px;" href="calendar.html" rel="bookmark">
                                                            <img width="1024" height="684" src="https://shared.acdh.oeaw.ac.at/schnitzler-tagebuch/resources/img/post-bg-2.jpg" alt=""/>
                                                        </a>
                                                        <div class="entry-text-content">
                                                            <header class="entry-header">
                                                                <h4 class="entry-title">
                                                                    <a href="calendar.html" rel="bookmark" class="light">Das Tagebuch in Kalenderansicht</a>
                                                                </h4>
                                                            </header>
                                                            <!-- .entry-header -->
                                                            <div class="entry-content">
                                                                <p>Fünfzig Jahre lang legte Schnitzler nahezu täglich Einträge an. Über den Kalender können bestimmte Tage direkt aufgefunden werden.</p>
                                                                <a class="btn btn-round mb-1" href="calendar.html">Mehr lesen</a>
                                                            </div>
                                                            <!-- .entry-content -->
                                                        </div>
                                                        <!-- .entry-text-content -->
                                                    </div>
                                                    <!-- .card-inner -->
                                                </article>
                                                <!-- #post-## -->
                                                <article class="card col-md-6 flat-style">
                                                    <div class="card-inner card-vertical" style="min-height:420px;">
                                                        <a class="entry-top-thumbnail" style="height:230px;" href="persons.html" rel="bookmark">
                                                            <img width="1024" height="684" src="https://shared.acdh.oeaw.ac.at/schnitzler-tagebuch/resources/img/persons.jpg" title="University Children's Hospital, Vienna: a row of girl patients, outdoors, being measured for height. Photograph, 1921. Credit: Wellcome Collection. CC BY" alt="University Children's Hospital, Vienna: a row of girl patients, outdoors, being measured for height. Photograph, 1921. Credit: Wellcome Collection. CC BY"/>
                                                        </a>
                                                        <div class="entry-text-content">
                                                            <header class="entry-header">
                                                                <h4 class="entry-title">
                                                                    <a href="listperson.html" rel="bookmark" class="light">Personenverzeichnis</a>
                                                                </h4>
                                                            </header>
                                                            <!-- .entry-header -->
                                                            <div class="entry-content">
                                                                <p>Einstieg in das Tagebuch über das Personenregister mit über 8.500 nachgewiesenen Personen und ihrem Vorkommen.</p>
                                                                <a class="btn btn-round mb-1" href="listperson.html">Mehr lesen</a>
                                                            </div>
                                                            <!-- .entry-content -->
                                                        </div>
                                                        <!-- .entry-text-content -->
                                                    </div>
                                                    <!-- .card-inner -->
                                                </article>
                                                <!-- #post-## -->
                                                <article class="card col-md-6 flat-style">
                                                    <div class="card-inner card-vertical" style="min-height:420px;">
                                                        <a class="entry-top-thumbnail" style="height:230px;" href="places.html" rel="bookmark">
                                                            <img width="1024" height="684" src="https://shared.acdh.oeaw.ac.at/schnitzler-tagebuch/resources/img/places.jpg" alt="Stadtplan von Wien innerhalb des Gürtels, Beilage zum Meyers Konversationslexikon von 1905." title="Stadtplan von Wien innerhalb des Gürtels, Beilage zum Meyers Konversationslexikon von 1905."/>
                                                        </a>
                                                        <div class="entry-text-content">
                                                            <header class="entry-header">
                                                                <h4 class="entry-title">
                                                                    <a href="listplace.html" rel="bookmark" class="light">Ortsverzeichnis</a>
                                                                </h4>
                                                            </header>
                                                            <!-- .entry-header -->
                                                            <div class="entry-content">
                                                                <p>Zugang zum Tagebuch mittels 2.200 Orten, die auch über ihre Koordinaten erschlossen sind.</p>
                                                                <a class="btn btn-round mb-1" href="listplace.html">Mehr lesen</a>
                                                            </div>
                                                            <!-- .entry-content -->
                                                        </div>
                                                        <!-- .entry-text-content -->
                                                    </div>
                                                    <!-- .card-inner -->
                                                </article>
                                                <!-- #post-## -->
                                            </div>
                                            <!-- .card-wrapper -->
                                        </main>
                                        <!-- #main -->
                                        <!-- The pagination component -->
                                    </div>
                                    <!-- #primary -->
                                    <!-- Do the right sidebar check -->
                                </div>
                                <!-- .row -->
                            </div>
                            <!-- Container end -->
                        </div>
                        
                    </div>
                
                    
                    
                    
                    <xsl:call-template name="html_footer"/>
                </div>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="tei:div//tei:head">
        <h2 id="{generate-id()}"><xsl:apply-templates/></h2>
    </xsl:template>
    
    <xsl:template match="tei:p">
        <p id="{generate-id()}"><xsl:apply-templates/></p>
    </xsl:template>
    
    <xsl:template match="tei:list">
        <ul id="{generate-id()}"><xsl:apply-templates/></ul>
    </xsl:template>
    
    <xsl:template match="tei:item">
        <li id="{generate-id()}"><xsl:apply-templates/></li>
    </xsl:template>
    <xsl:template match="tei:ref">
        <xsl:choose>
            <xsl:when test="starts-with(data(@target), 'http')">
                <a>
                    <xsl:attribute name="href"><xsl:value-of select="@target"/></xsl:attribute>
                    <xsl:value-of select="."/>
                </a>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>