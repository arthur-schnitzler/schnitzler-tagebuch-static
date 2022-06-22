const typesenseInstantsearchAdapter = new TypesenseInstantSearchAdapter({
    server: {
      apiKey: "LwgBWMJQ1Zm679fPXAk59NP6T8kifCq7",
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


const searchClient = typesenseInstantsearchAdapter.searchClient;
const search = instantsearch({
    indexName: 'stb',
    searchClient,
});

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
        templates: {
          empty: 'Keine Ergebnisse',
          item: `
              <h3><a href="{{ id }}.html">{{ title }}</a></h3>
              <h5><span class="badge badge-primary">{{ project }}</span></h5>
              <div>
              {{#persons}}
              <span class="badge badge-secondary">{{ . }}</span>
              {{/persons}}
              </div>
              {{#works}}
              <span class="badge badge-success">{{ . }}</span>
              {{/works}}
              <div>
              {{#places}}
              <span class="badge badge-info">{{ . }}</span>
              {{/places}}
              </div>
              </div>
              <p>{{#helpers.snippet}}{ "attribute": "full_text" }{{/helpers.snippet}}</p>
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
        searchable: true,
        searchablePlaceholder: 'Suche',
        cssClasses: {
          searchableInput: 'form-control form-control-sm mb-2 border-light-2',
          searchableSubmit: 'd-none',
          searchableReset: 'd-none',
          showMore: 'btn btn-secondary btn-sm align-content-center',
          list: 'list-unstyled',
          count: 'badge ml-2 badge-info',
          label: 'd-flex align-items-center text-capitalize',
          checkbox: 'mr-2',
        }
    }),

    instantsearch.widgets.refinementList({
        container: '#refinement-list-persons',
        attribute: 'persons',
        searchable: true,
        searchablePlaceholder: 'Suche',
        cssClasses: {
          searchableInput: 'form-control form-control-sm mb-2 border-light-2',
          searchableSubmit: 'd-none',
          searchableReset: 'd-none',
          showMore: 'btn btn-secondary btn-sm align-content-center',
          list: 'list-unstyled',
          count: 'badge ml-2 badge-secondary',
          label: 'd-flex align-items-center text-capitalize',
          checkbox: 'mr-2',
        }
    }),

    instantsearch.widgets.refinementList({
        container: '#refinement-list-works',
        attribute: 'works',
        searchable: true,
        searchablePlaceholder: 'Suche',
        cssClasses: {
          searchableInput: 'form-control form-control-sm mb-2 border-light-2',
          searchableSubmit: 'd-none',
          searchableReset: 'd-none',
          showMore: 'btn btn-secondary btn-sm align-content-center',
          list: 'list-unstyled',
          count: 'badge ml-2 badge-success',
          label: 'd-flex align-items-center text-capitalize',
          checkbox: 'mr-2',
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