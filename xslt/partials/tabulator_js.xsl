<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <!-- hier sind die verschiedenen tabellentypen. die unterscheidung dient vor allem der sortierung am anfang -->
    
    <xsl:template match="/" name="tabulator_js">
        <link href="https://unpkg.com/tabulator-tables@6.2.1/dist/css/tabulator_bootstrap5.min.css" rel="stylesheet"/>
        <script type="text/javascript" src="https://unpkg.com/tabulator-tables@6.2.1/dist/js/tabulator.min.js"></script>
        <script src="tabulator-js/config.js"></script>
        <script>
            // Erste Tabelle mit Sortierung nach "urheber_in" und "titel"
            var table = new Tabulator("#tabulator-table", {
            pagination:"local",       //paginate the data
            paginationSize:25,         //allow 25 rows per page of data
            paginationCounter:"rows", //display count of paginated rows in footer
            movableColumns:true,
            initialSort:[
            {column:"urheber_in", dir:"asc"}, 
            {column:"titel", dir:"asc"}
            ],
            langs:{
            "de-de":{ //German language definition
            "pagination":{
            "first":"Erste",
            "first_title":"Erste Seite",
            "last":"Letzte",
            "last_title":"Letzte Seite",
            "prev":"Vorige",
            "prev_title":"Vorige Seite",
            "next":"Nächste",
            "next_title":"Nächste Seite",
            "all":"Alle",
            "counter":{
            "showing": "Zeige",
            "of": "von",
            "rows": "Reihen",
            "pages": "Seiten",
            }
            },
            },
            },
            locale: "de-de"
            });
        </script>
        
    </xsl:template>
    
    <xsl:template match="/" name="tabulator_work_js">
        <link href="https://unpkg.com/tabulator-tables@6.2.1/dist/css/tabulator_bootstrap5.min.css" rel="stylesheet"/>
        <script type="text/javascript" src="https://unpkg.com/tabulator-tables@6.2.1/dist/js/tabulator.min.js"></script>
        <script src="tabulator-js/config.js"></script>
        <script>
            // Erste Tabelle mit Sortierung nach "urheber_in" und "titel"
            var table = new Tabulator("#tabulator-table-work", {
            pagination:"local",       //paginate the data
            paginationSize:25,         //allow 25 rows per page of data
            paginationCounter:"rows", //display count of paginated rows in footer
            movableColumns:true,
            layout:"fitColumns",
            initialSort:[
            {column:"urheber_in", dir:"asc"}, 
            {column:"titel", dir:"asc"}
            ],
            langs:{
            "de-de":{ //German language definition
            "pagination":{
            "first":"Erste",
            "first_title":"Erste Seite",
            "last":"Letzte",
            "last_title":"Letzte Seite",
            "prev":"Vorige",
            "prev_title":"Vorige Seite",
            "next":"Nächste",
            "next_title":"Nächste Seite",
            "all":"Alle",
            "counter":{
            "showing": "Zeige",
            "of": "von",
            "rows": "Reihen",
            "pages": "Seiten",
            }
            },
            },
            },
            locale: "de-de"
            });
        </script>
        
    </xsl:template>
    
    <xsl:template match="/" name="tabulator_person_js">
        <link href="https://unpkg.com/tabulator-tables@6.2.1/dist/css/tabulator_bootstrap5.min.css" rel="stylesheet"/>
        <script type="text/javascript" src="https://unpkg.com/tabulator-tables@6.2.1/dist/js/tabulator.min.js"></script>
        <script src="tabulator-js/config.js"></script>
        <script>
            // Erste Tabelle mit Sortierung nach "urheber_in" und "titel"
            var table = new Tabulator("#tabulator-table-person", {
            pagination:"local",       //paginate the data
            paginationSize:25,         //allow 25 rows per page of data
            paginationCounter:"rows", //display count of paginated rows in footer
            movableColumns:true,
            layout:"fitColumns",
            columns: [
            {title: "Vorname", field: "vorname", sorter: "string", formatter: "html"},
            {title: "Nachname", field: "nachname", sorter: "string", formatter: "html"},
            {title: "Namensvarianten", field: "namensvarianten", sorter: "string"},
            {title: "Lebensdaten", field: "lebensdaten", sorter: "string"},
            {title: "Berufe", field: "berufe", sorter: "string"}
            ],
            initialSort:[
            {column:"vorname", dir:"asc"},
            {column:"nachname", dir:"asc"}
            
            ],
            langs:{
            "de-de":{ //German language definition
            "pagination":{
            "first":"Erste",
            "first_title":"Erste Seite",
            "last":"Letzte",
            "last_title":"Letzte Seite",
            "prev":"Vorige",
            "prev_title":"Vorige Seite",
            "next":"Nächste",
            "next_title":"Nächste Seite",
            "all":"Alle",
            "counter":{
            "showing": "Zeige",
            "of": "von",
            "rows": "Reihen",
            "pages": "Seiten",
            }
            },
            },
            },
            locale: "de-de"
            });
        </script>
        
    </xsl:template>
    
    <xsl:template match="/" name="tabulator_org_js">
        <link href="https://unpkg.com/tabulator-tables@6.2.1/dist/css/tabulator_bootstrap5.min.css" rel="stylesheet"/>
        <script type="text/javascript" src="https://unpkg.com/tabulator-tables@6.2.1/dist/js/tabulator.min.js"></script>
        <script src="tabulator-js/config.js"></script>
        <script>
            // Erste Tabelle mit Sortierung nach "urheber_in" und "titel"
            var table = new Tabulator("#tabulator-table-org", {
            pagination: "local",       // paginate the data
            paginationSize: 25,         // allow 25 rows per page of data
            paginationCounter: "rows", // display count of paginated rows in footer
            movableColumns: true,
            layout:"fitColumns",
            columns: [
            { title: "Name", field: "name", sorter: "string" },
            { title: "Namensvarianten", field: "namensvarianten", sorter: "string" },
            { title: "Zugehörigkeiten", field: "zugehoerigkeiten", sorter: "string" },
            { title: "Typ", field: "typ", sorter: "string" }
            ],
            initialSort: [
            { column: "zugehoerigkeiten", dir: "asc" },
            { column: "name", dir: "asc" }
            ],
            langs: {
            "de-de": { // German language definition
            "pagination": {
            "first": "Erste",
            "first_title": "Erste Seite",
            "last": "Letzte",
            "last_title": "Letzte Seite",
            "prev": "Vorige",
            "prev_title": "Vorige Seite",
            "next": "Nächste",
            "next_title": "Nächste Seite",
            "all": "Alle",
            "counter": {
            "showing": "Zeige",
            "of": "von",
            "rows": "Reihen",
            "pages": "Seiten"
            }
            }
            }
            },
            locale: "de-de"
            });
            
        </script>
        
    </xsl:template>
    
    <xsl:template match="/" name="tabulator_archives_js">
        <link href="https://unpkg.com/tabulator-tables@6.2.1/dist/css/tabulator_bootstrap5.min.css" rel="stylesheet"/>
        <script type="text/javascript" src="https://unpkg.com/tabulator-tables@6.2.1/dist/js/tabulator.min.js"></script>
        <script src="tabulator-js/config.js"></script>
        <script>
            var table = new Tabulator("#tabulator-table-archives", {
            pagination: "local",       // paginate the data
            paginationSize: 25,         // allow 25 rows per page of data
            paginationCounter: "rows", // display count of paginated rows in footer
            movableColumns: true,
            layout:"fitColumns",
            columns: [
            { title: "Datum", field: "datum", sorter: "string" },
            { title: "Titel", sorter: "string" },
            { title: "Institution", sorter: "string" },
            { title: "Ort", sorter: "string" },
            { title: "Land", sorter: "string" }
            ],
            initialSort: [
            { column: "datum", dir: "asc" }
            ],
            langs: {
            "de-de": { // German language definition
            "pagination": {
            "first": "Erste",
            "first_title": "Erste Seite",
            "last": "Letzte",
            "last_title": "Letzte Seite",
            "prev": "Vorige",
            "prev_title": "Vorige Seite",
            "next": "Nächste",
            "next_title": "Nächste Seite",
            "all": "Alle",
            "counter": {
            "showing": "Zeige",
            "of": "von",
            "rows": "Reihen",
            "pages": "Seiten"
            }
            }
            }
            },
            locale: "de-de"
            });
            
        </script>
        
    </xsl:template>
    
    <xsl:template match="/" name="tabulator_correspaction_js">
        <link href="https://unpkg.com/tabulator-tables@6.2.1/dist/css/tabulator_bootstrap5.min.css" rel="stylesheet"/>
        <script type="text/javascript" src="https://unpkg.com/tabulator-tables@6.2.1/dist/js/tabulator.min.js"></script>
        <script src="tabulator-js/config.js"></script>
        <script>
            var table = new Tabulator("#tabulator-table-correspaction", {
            pagination: "local",       // paginate the data
            paginationSize: 25,         // allow 25 rows per page of data
            paginationCounter: "rows", // display count of paginated rows in footer
            movableColumns: true,
            layout:"fitColumns",
            initialSort: [
            { column: "sendedatum", dir: "asc" }
            ],
            langs: {
            "de-de": { // German language definition
            "pagination": {
            "first": "Erste",
            "first_title": "Erste Seite",
            "last": "Letzte",
            "last_title": "Letzte Seite",
            "prev": "Vorige",
            "prev_title": "Vorige Seite",
            "next": "Nächste",
            "next_title": "Nächste Seite",
            "all": "Alle",
            "counter": {
            "showing": "Zeige",
            "of": "von",
            "rows": "Reihen",
            "pages": "Seiten"
            }
            }
            }
            },
            locale: "de-de"
            });
            
        </script>
        
    </xsl:template>
    
    
    <xsl:template match="/" name="tabulator-limited_js">
        <link href="https://unpkg.com/tabulator-tables@6.2.1/dist/css/tabulator_bootstrap5.min.css" rel="stylesheet"/>
        <script type="text/javascript" src="https://unpkg.com/tabulator-tables@6.2.1/dist/js/tabulator.min.js"></script>
        <script src="tabulator-js/config.js"></script>
        <script>
            var table = new Tabulator("#tabulator-table-limited", {
            pagination:"local",       //paginate the data
            paginationSize:25,         //allow 25 rows per page of data
            paginationCounter:"rows", //display count of paginated rows in footer
            layout:"fitColumns",
            langs:{
            "de-de":{ //German language definition
            "pagination":{
            "first":"Erste",
            "first_title":"Erste Seite",
            "last":"Letzte",
            "last_title":"Letzte Seite",
            "prev":"Vorige",
            "prev_title":"Vorige Seite",
            "next":"Nächste",
            "next_title":"Nächste Seite",
            "all":"Alle",
            "counter":{
            "showing": "Zeige",
            "of": "von",
            "rows": "Reihen",
            "pages": "Seiten",
            }
            },
            },
            },
            locale: "de-de"
            });
        </script>
    </xsl:template>
    
    <xsl:template match="/" name="tabulator_dl_buttons">
        <h4>Tabelle laden</h4>
        <div class="button-group">
            <button type="button" class="btn btn-outline-secondary" id="download-csv" title="Download CSV">
                <span>CSV</span>
            </button>
            <span>&#160;</span>
            <button type="button" class="btn btn-outline-secondary" id="download-json" title="Download JSON">
                <span>JSON</span>
            </button>
            <span>&#160;</span>
            <button type="button" class="btn btn-outline-secondary" id="download-html" title="Download HTML">
                <span>HTML</span>
            </button>
        </div>
    </xsl:template>
</xsl:stylesheet>