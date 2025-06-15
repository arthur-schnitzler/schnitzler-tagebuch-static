var table = new Tabulator("#tabulator-table-org", {
   height: 800,
   width: "100%",
    tooltips: true,
            pagination:"local",
            paginationSize:25,
            paginationCounter:"rows",
            movableColumns:true,
            layout:"fitColumns",
            responsiveLayout:"hide", // automatisch Spalten ausblenden bei Platzmangel
            dataLoader: true,
    columns:[ 
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
            