<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl tei xs" version="2.0">
    <xsl:template match="/" name="nav_bar">
        <div class="wrapper-fluid wrapper-navbar sticky-navbar" id="wrapper-navbar" itemscope="" itemtype="http://schema.org/WebSite">
            <a class="skip-link screen-reader-text sr-only" href="#content">Skip to content</a>
            <nav class="navbar navbar-expand-lg navbar-light">
                <div class="container-fluid">
                    <!-- Your site title as branding in the menu -->
                    <a href="index.html" class="navbar-brand custom-logo-link" rel="home" itemprop="url">
                        <img src="https://shared.acdh.oeaw.ac.at/schnitzler-tagebuch/project-logo.svg" class="img-fluid" alt="Schnitzler Tagebuch" itemprop="logo"/>
                    </a><!-- end custom logo -->
                    <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNavDropdown" aria-controls="navbarNavDropdown" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"/>
                    </button>
                    <div class="collapse navbar-collapse justify-content-end" id="navbarNavDropdown">
                        <!-- Your menu goes here -->
                        <ul id="main-menu" class="navbar-nav">
                            <li class="nav-item">
                                <a class="nav-link" href="about.html">Zur Edition</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="calendar.html">Kalender</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="toc.html">Einträge</a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link" href="listperson.html">Personen</a>
                            </li>
                             <li class="nav-item">
                                <a class="nav-link" href="listwork.html">Werke</a>
                            </li> 
                            <li class="nav-item">
                                <a class="nav-link" href="listplace.html">Orte</a>
                            </li>
                            <!--<li class="nav-item dropdown">
                                <a class="nav-link dropdown-toggle" href="#" role="button" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                    API
                                </a>
                                <div class="dropdown-menu">
                                    <a class="dropdown-item" href="../api/api.html">API</a>
                                    <a class="dropdown-item" href="../analyze/beacon.xql">GND-Beacon</a>
                                </div>
                            </li>-->
                        </ul>
                        <form class="form-inline my-2 my-lg-0 navbar-search-form" method="get" action="search.html" role="search">
                            <input class="form-control navbar-search" name="q" type="text" placeholder="Suche" aria-label="Suche"/>
                            <button type="submit" class="navbar-search-icon">
                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-search">
                                    <circle cx="11" cy="11" r="8"/>
                                    <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                                </svg>
                            </button>
                        </form>
                    </div>
                    <!-- .collapse navbar-collapse -->
                </div>
                <!-- .container -->
            </nav>
            <!-- .site-navigation -->
        </div>
    </xsl:template>
</xsl:stylesheet>