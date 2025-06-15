var table = new Tabulator("#tabulator-table-work", {
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
    columns:[ {
        title: "Titel", field: "titel", sorter: "string", formatter: "html", responsive: 0, width:550
    }, {
        title: "Urheber_in", field: "urheber_in", sorter: "string", formatter: "html", responsive: 0, maxWidth: 700, width:400
    }, {title:"Datum", field:"datum", headerFilter:"input", formatter:"html", responsive:0, minWidth:100, maxWidth:120},
{title:"Typ", field:"typ", headerFilter:"input", formatter:"html", responsive:1, width:120, maxWidth:200}],
            initialSort:[
            {column:"titel", dir:"asc"},
                        {column:"urheber_in", dir:"asc"}
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
            