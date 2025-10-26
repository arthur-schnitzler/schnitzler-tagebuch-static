const indexName = "stb";
const apiKey = "LwgBWMJQ1Zm679fPXAk59NP6T8kifCq7";

const typesenseInstantsearchAdapter = new TypesenseInstantSearchAdapter({
    server: {
      apiKey: apiKey,
      nodes: [
        {
          host: "typesense.acdh-dev.oeaw.ac.at",
          port: "443",
          protocol: "https",
        },
      ],
      cacheSearchResultsForSeconds: 2 * 60,
    },
    additionalSearchParameters: {
      query_by: "full_text"
    },
  });

const DEFAULT_CSS_CLASSES = {
    searchableInput: "form-control form-control-sm m-2 border-light-2",
    searchableSubmit: "d-none",
    searchableReset: "d-none",
    showMore: "btn btn-secondary btn-sm align-content-center",
    list: "list-unstyled",
    count: "badge m-2 badge-secondary",
    label: "d-flex align-items-center text-capitalize",
    checkbox: "m-2",
};

const searchClient = typesenseInstantsearchAdapter.searchClient;
const search = instantsearch({
    indexName: indexName,
    searchClient,
});

// Add started property to track initialization state
search.started = false;

search.addWidgets([
    instantsearch.widgets.searchBox({
        container: '#searchbox',
        autofocus: true,
        cssClasses: {
          form: 'form-inline',
          input: 'form-control col-md-11',
          submit: 'btn',
          reset: 'btn'
        },
    }),

    instantsearch.widgets.hits({
        container: '#hits',
        cssClasses: {
            item: "w-100",
        },
        templates: {
          empty: 'Keine Ergebnisse',
          item: `
              <h4><a href="{{ id }}.html">{{ title }}</a></h4>
              <p>{{#helpers.snippet}}{ "attribute": "full_text" }{{/helpers.snippet}}</p>
              <div>
              {{#persons}}
              <span class="badge rounded-pill m-1 bg-warning">{{ . }}</span>
              {{/persons}}
              </div>
              {{#works}}
              <span class="badge rounded-pill m-1 bg-success">{{ . }}</span>
              {{/works}}
              <div>
              {{#places}}
              <span class="badge rounded-pill m-1 bg-info">{{ . }}</span>
              {{/places}}
              </div>
              </div>
          `
      }
    }),

    instantsearch.widgets.stats({
      container: '#stats-container',
      templates: {
        text: `
          {{#areHitsSorted}}
            {{#hasNoSortedResults}}Keine Treffer{{/hasNoSortedResults}}
            {{#hasOneSortedResults}}1 Treffer{{/hasOneSortedResults}}
            {{#hasManySortedResults}}{{#helpers.formatNumber}}{{nbSortedHits}}{{/helpers.formatNumber}} Treffer {{/hasManySortedResults}}
            aus {{#helpers.formatNumber}}{{nbHits}}{{/helpers.formatNumber}}
          {{/areHitsSorted}}
          {{^areHitsSorted}}
            {{#hasNoResults}}Keine Treffer{{/hasNoResults}}
            {{#hasOneResult}}1 Treffer{{/hasOneResult}}
            {{#hasManyResults}}{{#helpers.formatNumber}}{{nbHits}}{{/helpers.formatNumber}} Treffer{{/hasManyResults}}
          {{/areHitsSorted}}
          gefunden in {{processingTimeMS}}ms
        `,
      }
  }),

    instantsearch.widgets.refinementList({
        container: '#refinement-list-places',
        attribute: 'places',
        operator: 'and',
        searchable: true,
        searchablePlaceholder: 'Suche',
        cssClasses: {
          ...DEFAULT_CSS_CLASSES,
          count: 'badge m-2 badge-info',
        }
    }),

    instantsearch.widgets.refinementList({
        container: '#refinement-list-persons',
        attribute: 'persons',
        operator: 'and',
        searchable: true,
        searchablePlaceholder: 'Suche',
        cssClasses: {
          ...DEFAULT_CSS_CLASSES,
          count: 'badge m-2 badge-secondary',
        }
    }),

    instantsearch.widgets.refinementList({
        container: '#refinement-list-works',
        attribute: 'works',
        operator: 'and',
        searchable: true,
        searchablePlaceholder: 'Suche',
        cssClasses: {
          ...DEFAULT_CSS_CLASSES,
          count: 'badge m-2 badge-success',
        }
    }),
    
    instantsearch.widgets.rangeInput({
        container: "#range-input",
        attribute: "year",
        templates: {
          separatorText: 'bis',
          submitText: 'Suchen',
        },
        cssClasses: {
          form: 'form-inline',
          input: 'form-control',
          submit: 'btn'
        }
      }),

    instantsearch.widgets.pagination({
        container: '#pagination',
        padding: 2,
        cssClasses: {
          list: 'pagination',
          item: 'page-item',
          link: 'page-link'
        }
    }),
    instantsearch.widgets.clearRefinements({
        container: '#clear-refinements',
        templates: {
          resetLabel: 'Filter zurücksetzen',
        },
        cssClasses: {
          button: 'btn'
        }
    }),

    	

    instantsearch.widgets.currentRefinements({
      container: '#current-refinements',
      cssClasses: {
        delete: 'btn',
        label: 'badge'
      }
    })
]);



search.addWidgets([
    instantsearch.widgets.configure({
        attributesToSnippet: ['full_text'],
    })
]);

search.addWidgets([
    instantsearch.widgets.sortBy({
      container: "#sort-by",
      items: [
        { label: "Tag (aufsteigend)", value: "stb/sort/date:asc" },
        { label: "Tag (absteigend)", value: "stb/sort/date:desc" },
      ],
      cssClasses: {
        select: 'custom-select'
      }
    }),
  ]);


search.start();

// Mark as started after initialization
search.started = true;