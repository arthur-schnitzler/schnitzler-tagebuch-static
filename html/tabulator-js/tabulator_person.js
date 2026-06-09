var table = new Tabulator("#tabulator-table-person", {
   height: 800,
   width: "100%",
    tooltips: true,
            pagination:"local",
            paginationSize:25,
            paginationCounter:"rows",
            movableColumns:true,
            layout:"fitColumns",
            responsiveLayout:"collapse",
            dataLoader: true,
    columns:[ {
        formatter: "responsiveCollapse", width: 30, minWidth: 30, hozAlign: "center", resizable: false, headerSort: false
    }, {
        title: "Vorname", field: "vorname", sorter: "string", formatter: "html", responsive: 1, minWidth: 80
    }, {
        title: "Nachname", field: "nachname", sorter: "string", formatter: "html", responsive: 0, minWidth: 100
    }, {
        title: "Namensvarianten", field: "namensvarianten", sorter: "string", formatter: "html", responsive: 4, minWidth: 120
    }, {
        title: "Lebensdaten", field: "lebensdaten", sorter: "string", formatter: "html", responsive: 3, minWidth: 80
    }, {
        title: "Berufe", field: "berufe", sorter: "string", formatter: "html", responsive: 2, minWidth: 100
    }],
    initialSort:[ {
        column: "vorname", dir: "asc"
    }, {
        column: "nachname", dir: "asc"
    }],
    langs: {
        "de-de": {
            //German language definition
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
                    "pages": "Seiten",
                }
            },
        },
    },
    locale: "de-de"
});
