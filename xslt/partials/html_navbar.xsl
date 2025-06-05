<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xsl tei xs" version="2.0">
    <xsl:template match="/" name="nav_bar">
        <nav class="navbar navbar-expand-md" style="padding-top:1px;">
            <div class="container-fluid">
                <a href="index.html" class="navbar-brand custom-logo-link" rel="home" itemprop="url">
                    <img src="https://shared.acdh.oeaw.ac.at/schnitzler-tagebuch/project-logo.svg" class="img-fluid" title="Schnitzler Tagebuch"
                        alt="Schnitzler Tagebuch" itemprop="logo"/>
                </a>
                <button class="navbar-toggler" type="button" data-bs-toggle="collapse"
                    data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false"
                    aria-label="Toggle navigation">
                    <span class="navbar-toggler-icon"></span>
                </button>
                
                        <div class="collapse navbar-collapse" id="navbarSupportedContent">
                            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                                <!-- Projekt Dropdown -->
                                <li class="nav-item dropdown">
                                    <a class="nav-link dropdown-toggle" href="#" id="projektDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                        Zum Projekt
                                    </a>
                                    <ul class="dropdown-menu" aria-labelledby="projektDropdown">
                                        <li><a class="dropdown-item" href="about.html">Zur Edition</a></li>
                                        
                                        <li><a class="dropdown-item" href="toc.html">Einträge</a></li>
                                        <li><a class="dropdown-item" href="https://github.com/arthur-schnitzler/schnitzler-tagebuch-data" target="_blank">Offene Daten auf gitHub</a></li>
                                    </ul>
                                </li>
                                
                                <li class="nav-item">
                                    <a class="nav-link" href="calendar.html">Kalender</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="listperson.html">Personen</a>
                                </li>
                                <li class="nav-item">
                                    <a class="nav-link" href="listwork.html">Werke</a>
                                </li>
                                
                                <li class="nav-item dropdown">
                                    <a class="nav-link dropdown-toggle" href="#" id="OrteDropdown" role="button" data-bs-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                        Orte
                                    </a>
                                    <ul class="dropdown-menu" aria-labelledby="OrteDropdown">
                                        <li><a class="dropdown-item" href="https://wienerschnitzler.org/listplace.html" target="_blank">Wiener Schnitzler (Aufenthaltsorte)</a></li>
                                        <li><a class="dropdown-item" href="listplace.html">Erwähnte Orte</a></li>
                                        <li><a class="dropdown-item" href="ortsregister.html">Über die Ortsregister</a></li>
                                    </ul>
                                </li>
                                
                                <!-- Schnitzler-Links Dropdown -->
                                <li class="nav-item dropdown">
                                    <a class="nav-link dropdown-toggle" href="#" id="schnitzlerLinksDropdown" role="button" data-bs-toggle="dropdown" aria-expanded="false">Schnitzler</a>
                                    <ul class="dropdown-menu" aria-labelledby="schnitzlerLinksDropdown">
                                        <li><a class="dropdown-item" href="https://de.wikipedia.org/wiki/Arthur_Schnitzler" target="_blank">Wikipedia</a></li>
                                        <li><a class="dropdown-item" href="https://www.geschichtewiki.wien.gv.at/Arthur_Schnitzler" target="_blank">Wien Geschichte Wiki</a></li>
                                        <li><a class="dropdown-item" href="https://schnitzler-briefe.acdh.oeaw.ac.at/" target="_blank">Briefe (1888–1931)</a></li>
                                        <li><a class="dropdown-item" href="https://www.arthur-schnitzler.de" target="_blank">Werke digital (1905–1931)</a></li>
                                        <li><a class="dropdown-item" href="https://schnitzler-mikrofilme.acdh.oeaw.ac.at/" target="_blank">Mikrofilme</a></li>
                                        <li><a class="dropdown-item" href="https://schnitzler-zeitungen.acdh.oeaw.ac.at/" target="_blank">Archiv der Zeitungsausschnitte</a></li>
                                        <li><a class="dropdown-item" href="https://schnitzler-interviews.acdh.oeaw.ac.at/" target="_blank">Interviews, Meinungen, Proteste</a></li>
                                        <li><a class="dropdown-item" href="https://wienerschnitzler.org/" target="_blank">Wiener Schnitzler – Schnitzlers Wien</a></li>
                                        <li><a class="dropdown-item" href="https://schnitzler-bahr.acdh.oeaw.ac.at/" target="_blank">Korrespondenz mit Hermann Bahr</a></li>
                                        <li><a class="dropdown-item" href="https://schnitzler-chronik.acdh.oeaw.ac.at/" target="_blank">Chronik</a></li>
                                        <li><a class="dropdown-item" href="https://schnitzler-lektueren.acdh.oeaw.ac.at/" target="_blank">Lektüren</a></li>
                                        <li><a class="dropdown-item" href="https://pollaczek.acdh.oeaw.ac.at/" target="_blank">Pollaczek: Schnitzler und ich</a></li>
                                        <li><a class="dropdown-item" href="https://pmb.acdh.oeaw.ac.at/" target="_blank" >PMB – Personen der Moderne Basis</a></li>
                                        
                                    </ul>
                                </li>
                            </ul>
                            <a href="search.html">
                                <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="feather feather-search">
                                    <circle cx="11" cy="11" r="8"/>
                                    <line x1="21" y1="21" x2="16.65" y2="16.65"/>
                                </svg>
                                SUCHE
                            </a>
                        </div>
                    </div>
                </nav>
        
        
        
      
                
    </xsl:template>
</xsl:stylesheet>