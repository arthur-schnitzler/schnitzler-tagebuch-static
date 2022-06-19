const typesenseInstantsearchAdapter = new TypesenseInstantSearchAdapter({
    server: {
      apiKey: "LwgBWMJQ1Zm679fPXAk59NP6T8kifCq7", // Be sure to use an API key that only allows search operations
      nodes: [
        {
          host: "typesense.acdh-dev.oeaw.ac.at",
          port: "443",
          protocol: "https",
        },
      ],
      cacheSearchResultsForSeconds: 2 * 60, // Cache search results from server. Defaults to 2 minutes. Set to 0 to disable caching.
    },
    // The following parameters are directly passed to Typesense's search API endpoint.
    //  So you can pass any parameters supported by the search endpoint below.
    //  query_by is required.
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
    }),

    instantsearch.widgets.hits({
        container: '#hits',
        templates: {
            empty: 'No results',
            item: `
                <h4> {{ rec_id }}</h4>
                <h5><a href="{{ id }}.html">{{ title }}</a></h5>
                <p>{{#helpers.snippet}}{ "attribute": "full_text" }{{/helpers.snippet}}</p>
            `
        }
    }),

    instantsearch.widgets.stats({
        container: '#stats-container'
    }),

    instantsearch.widgets.refinementList({
        container: '#refinement-list-places',
        attribute: 'places',
        searchable: true,
    }),

    instantsearch.widgets.refinementList({
        container: '#refinement-list-persons',
        attribute: 'persons',
        searchable: true,
    }),

    instantsearch.widgets.refinementList({
        container: '#refinement-list-works',
        attribute: 'works',
        searchable: true,
    }),
    
    instantsearch.widgets.rangeInput({
        container: "#range-input",
        attribute: "year",
        // Optional parameters
      }),

    instantsearch.widgets.pagination({
        container: '#pagination',
        padding: 2,
    }),
    instantsearch.widgets.clearRefinements({
        container: '#clear-refinements',
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
        { label: "Jahr (aufsteigend)", value: "stb/sort/year:asc" },
        { label: "Jahr (absteigend)", value: "stb/sort/year:desc" },
      ],
    }),
  ]);


search.start();