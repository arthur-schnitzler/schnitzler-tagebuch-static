<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    
    
    <xsl:template match="/" name="tabulator_dl_buttons">
        <h4>Tabelle laden</h4>
        <div class="button-group">
            <button type="button" class="btn btn-outline-secondary" id="download-csv"
                title="Download CSV">
                <span>CSV</span>
            </button>
            <span>&#160;</span>
            <button type="button" class="btn btn-outline-secondary" id="download-json"
                title="Download JSON">
                <span>JSON</span>
            </button>
            <span>&#160;</span>
            <button type="button" class="btn btn-outline-secondary" id="download-html"
                title="Download HTML">
                <span>HTML</span>
            </button>
            <script>
                document.getElementById("download-csv").addEventListener("click", function () {
                table.download("csv", "daten.csv");
                });
                
                document.getElementById("download-json").addEventListener("click", function () {
                table.download("json", "daten.json");
                });
                
                document.getElementById("download-html").addEventListener("click", function () {
                table.download("html", "daten.html", {style: true});
                });
            </script>
        </div>
    </xsl:template>
</xsl:stylesheet>
