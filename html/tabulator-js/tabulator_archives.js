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