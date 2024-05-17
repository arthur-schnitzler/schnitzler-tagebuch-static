<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    <xsl:template match="/" name="tabulator_js">
        <link href="https://unpkg.com/tabulator-tables@6.2.1/dist/css/tabulator_bootstrap5.min.css" rel="stylesheet"/>
        <script type="text/javascript" src="https://unpkg.com/tabulator-tables@6.2.1/dist/js/tabulator.min.js"></script>
        <script src="tabulator-js/config.js"></script>
        <script>
            var table = new Tabulator("#tabulator-table", {
            pagination:"local",       //paginate the data
            paginationSize:25,         //allow 25 rows per page of data
            paginationCounter:"rows", //display count of paginated rows in footer
            movableColumns:true,
            initialSort:[{column:"verfasser:in", dir:"asc"}, 
            {column:"titel", dir:"asc"}],
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
    
    <xsl:template match="/" name="tabulator-limited_js">
        <link href="https://unpkg.com/tabulator-tables@6.2.1/dist/css/tabulator_bootstrap5.min.css" rel="stylesheet"/>
        <script type="text/javascript" src="https://unpkg.com/tabulator-tables@6.2.1/dist/js/tabulator.min.js"></script>
        <script src="tabulator-js/config.js"></script>
        <script>
            var table = new Tabulator("#tabulator-table-limited", {
            pagination:"local",       //paginate the data
            paginationSize:25,         //allow 25 rows per page of data
            paginationCounter:"rows", //display count of paginated rows in footer
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