// Noske Search Implementation using acdh-noske-search package
import { NoskeSearch } from "https://cdn.jsdelivr.net/npm/acdh-noske-search/dist/index.js";

class NoskeSearchImplementation {
    constructor() {
        this.search = null;
        this.initialized = false;
        this.searchResults = null;
        this.latestApiData = null;
        this.config = {
            client: {
                base: "https://corpus-search.acdh.oeaw.ac.at/",
                corpname: "schnitzlertagebuch",
                attrs: "word,id",
                structs: "doc,docTitle,head,p,imprimatur,list",
                refs: "doc.id,doc.corpus,docTitle.id,p.id,head.id,imprimatur.id,list.id"
            },
            hits: {
                id: "noske-hits",
                css: {
                    table: "table-auto",
                    kwicContainer: "kwic-container",
                    leftContext: "context-left",
                    rightContext: "context-right",
                    keyword: "keyword"
                }
            },
            pagination: {
                id: "noske-pagination",
                css: {
                    pagination: "pagination justify-content-center",
                    pageItem: "page-item",
                    pageLink: "page-link"
                }
            },
            searchInput: {
                id: "noske-input",
                css: {
                    input: "form-control form-control-lg"
                }
            },
            stats: {
                id: "noske-stats",
                css: {
                    container: "alert alert-info",
                    text: "mb-0"
                }
            }
        };
    }

    interceptNoskeAPI() {
        // Store original fetch and keep reference to 'this'
        const originalFetch = window.fetch;
        const self = this;

        // Override fetch to intercept Noske API calls
        window.fetch = async (...args) => {
            const response = await originalFetch(...args);

            // Check if this is a Noske API call
            const url = args[0];
            if (typeof url === 'string' && url.includes('corpus-search.acdh.oeaw.ac.at')) {
                console.log('Intercepted Noske API call:', url);

                // Clone response so we can read it without consuming it
                const clonedResponse = response.clone();

                try {
                    const data = await clonedResponse.json();
                    console.log('Noske API response data:', data);

                    // Store in the class instance using 'self' reference
                    self.latestApiData = data;
                    self.searchResults = data;

                    console.log('Stored API data in self.latestApiData');
                } catch (e) {
                    console.warn('Could not parse Noske API response:', e);
                }
            }

            return response;
        };

        console.log('Noske API interceptor installed');
    }

    init() {
        if (this.initialized) return;

        console.log('Initializing Noske search with acdh-noske-search package...');

        try {
            // Intercept fetch calls to capture Noske API responses
            this.interceptNoskeAPI();

            // Create new NoskeSearch instance
            this.search = new NoskeSearch({container: "noske-search"});

            // Store reference to search results for later processing
            this.searchResults = null;

            this.search.search({
                client: {
                    id: "noske-client",
                    base: "https://corpus-search.acdh.oeaw.ac.at/",
                    corpname: "schnitzlertagebuch",
                    attrs: "word",
                    structs: "chapter",
                    refs: "chapter.id",
                },
                hits: {
                    id: "hitsbox",
                    css: {
                        table: "table-auto",
                        kwicContainer: "kwic-container",
                        leftContext: "context-left",
                        rightContext: "context-right",
                        keyword: "keyword"
                    }
                },
                pagination: {
                    id: "noske-pagination-test",
                    css: {
                        pagination: "pagination justify-content-center",
                        pageItem: "page-item",
                        pageLink: "page-link"
                    }
                },
                searchInput: {
                    id: "noske-search",
                    css: {
                        input: "form-control form-control-lg"
                    }
                },
                stats: {
                    id: "noske-stats",
                    css: {
                        container: "alert alert-info",
                        text: "mb-0"
                    }
                },
            });

            // Add custom event listeners
            this.setupEventListeners();

            this.initialized = true;
            console.log('Noske search initialized successfully');

        } catch (error) {
            console.error('Error initializing Noske search:', error);
            this.showError('Fehler beim Initialisieren der Noske-Suche. Bitte versuchen Sie es später erneut.');
        }
    }

    setupEventListeners() {
        // Add Enter key support for search input
        const searchInput = document.getElementById('noske-input');
        if (searchInput) {
            searchInput.addEventListener('keypress', (e) => {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    this.performSearch(e.target.value);
                }
            });

            // Add search button
            this.addSearchButton(searchInput);
        }

        // Add clear results button
        this.addClearButton();

        // Set up MutationObserver to watch for results and add links
        this.setupResultsObserver();
    }

    setupResultsObserver() {
        const hitsContainer = document.getElementById('hitsbox');
        if (!hitsContainer) {
            console.warn('hitsbox container not found, retrying in 100ms...');
            setTimeout(() => this.setupResultsObserver(), 100);
            return;
        }

        // Create observer to watch for new search results
        const observer = new MutationObserver((mutations) => {
            let hasNewTable = false;

            mutations.forEach((mutation) => {
                mutation.addedNodes.forEach(node => {
                    // Check if a table was added (the actual results)
                    if (node.nodeName === 'TABLE' || (node.querySelector && node.querySelector('table'))) {
                        hasNewTable = true;
                    }
                });
            });

            if (hasNewTable) {
                console.log('New results table detected');
                // Add a delay to ensure table is fully rendered
                setTimeout(() => {
                    // Try to find the search input - it might be created dynamically
                    const searchContainer = document.getElementById('noske-search');
                    const searchInput = searchContainer ? searchContainer.querySelector('input') : null;
                    const query = searchInput ? searchInput.value : null;

                    console.log('Search input found:', !!searchInput);
                    console.log('Query value:', query);

                    if (query) {
                        console.log('Search detected, fetching API data for query:', query);
                        this.fetchNoskeDataDirectly(query).then(() => {
                            this.addLinksToResults();
                        });
                    } else {
                        console.warn('No query found, trying to add links anyway...');
                        this.addLinksToResults();
                    }
                }, 500);
            }
        });

        // Start observing the hits container
        observer.observe(hitsContainer, {
            childList: true,
            subtree: true
        });

        console.log('Results observer set up successfully');
    }

    async fetchNoskeDataDirectly(query) {
        try {
            // Clean up query - remove extra quotes if already present
            let cleanQuery = query.trim();

            // Remove surrounding quotes if present
            if ((cleanQuery.startsWith('"') && cleanQuery.endsWith('"')) ||
                (cleanQuery.startsWith("'") && cleanQuery.endsWith("'"))) {
                cleanQuery = cleanQuery.slice(1, -1).trim();
            }

            // Detect if query is CQL (starts with [ or contains lemma=, word=, etc.)
            const isCQL = cleanQuery.startsWith('[') || /\b(lemma|word|tag|pos)=/i.test(cleanQuery);

            let q;
            if (isCQL) {
                // For CQL queries, use 'q' parameter directly
                q = `q${encodeURIComponent(cleanQuery)}`;
            } else {
                // For simple queries, wrap in quotes
                q = `q${encodeURIComponent(`"${cleanQuery}"`)}`;
            }

            // Use the correct SketchEngine API endpoint
            const url = `https://corpus-search.acdh.oeaw.ac.at/search/concordance?corpname=schnitzlertagebuch&q=${q}&attrs=word,landingPageURI&attr_allpos=kw&viewmode=sen&structs=s,g&fromp=1&pagesize=50&kwicleftctx=100&format=json`;

            console.log('Original query:', query);
            console.log('Cleaned query:', cleanQuery);
            console.log('Fetching Noske data from:', url);
            console.log('Query type:', isCQL ? 'CQL' : 'Simple');

            const response = await fetch(url);

            console.log('Response status:', response.status);
            console.log('Response ok:', response.ok);

            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }

            const data = await response.json();

            console.log('Direct fetch Noske API response:', data);
            console.log('Data has Lines?', !!data.Lines);
            console.log('Lines count:', data.Lines?.length || 0);

            // Log first line to see structure
            if (data.Lines && data.Lines.length > 0) {
                console.log('First line sample:', JSON.stringify(data.Lines[0], null, 2));

                // Check specifically for landingPageURI in different token arrays
                const firstLine = data.Lines[0];
                if (firstLine.Left && firstLine.Left.length > 0) {
                    console.log('First Left token:', JSON.stringify(firstLine.Left[0], null, 2));
                }
                if (firstLine.Kwic && firstLine.Kwic.length > 0) {
                    console.log('First Kwic token:', JSON.stringify(firstLine.Kwic[0], null, 2));
                }
                if (firstLine.Right && firstLine.Right.length > 0) {
                    console.log('First Right token:', JSON.stringify(firstLine.Right[0], null, 2));
                }
            }

            this.latestApiData = data;
            this.searchResults = data;

            return data;
        } catch (error) {
            console.error('Error fetching Noske data directly:', error);
            // Don't reject, just return null so the HTML parsing fallback can work
            return null;
        }
    }

    addLinksToResults() {
        const hitsContainer = document.getElementById('hitsbox');
        if (!hitsContainer) return;

        console.log('Adding links to results...');
        console.log('this.latestApiData available?', !!this.latestApiData);
        console.log('Latest API data:', this.latestApiData);

        // Try to access via window.noskeSearch as well
        if (!this.latestApiData && window.noskeSearch && window.noskeSearch.latestApiData) {
            console.log('Using latestApiData from window.noskeSearch');
            this.latestApiData = window.noskeSearch.latestApiData;
        }

        // Find all table rows in the results
        const rows = hitsContainer.querySelectorAll('tr');
        console.log('Found', rows.length, 'rows');

        rows.forEach((row, index) => {
            // Skip if already processed
            if (row.dataset.processed === 'true') return;

            // Mark as processed
            row.dataset.processed = 'true';

            const cells = row.querySelectorAll('td');
            if (cells.length < 3) return;

            // Try to extract document reference from various sources
            let docRef = null;

            // 1. Check row data attributes
            docRef = row.dataset.doc || row.dataset.docId || row.dataset.ref;

            // 2. Check all attributes for doc-related info
            if (!docRef) {
                const allAttrs = Array.from(row.attributes);
                const docAttr = allAttrs.find(attr =>
                    attr.name.includes('doc') || attr.name.includes('ref')
                );
                if (docAttr) {
                    docRef = docAttr.value;
                }
            }

            // 3. Try to extract from latestApiData if available
            if (!docRef && this.latestApiData) {
                const lines = this.latestApiData.Lines || this.latestApiData.lines;
                if (lines && lines[index]) {
                    const line = lines[index];
                    console.log('Line', index, 'full data:', JSON.stringify(line, null, 2));

                    // First try to get landingPageURI from the line structure
                    // The landingPageURI is in the 'attr' field of Kwic tokens
                    if (line.Kwic && Array.isArray(line.Kwic)) {
                        console.log('Kwic array length:', line.Kwic.length);
                        for (let i = 0; i < line.Kwic.length; i++) {
                            const token = line.Kwic[i];
                            console.log('Kwic token', i, ':', JSON.stringify(token));
                            if (token && typeof token === 'object' && token.attr) {
                                // The attr field contains the landingPageURI with a leading slash
                                // e.g., "/https://arthur-schnitzler.github.io/schnitzler-briefe-static/L00182.html"
                                docRef = token.attr.replace(/^\//, ''); // Remove leading slash
                                console.log('Found landingPageURI in Kwic token attr:', docRef);
                                break;
                            }
                        }
                    }

                    // Fallback: check Left tokens
                    if (!docRef && line.Left && Array.isArray(line.Left)) {
                        console.log('Left array length:', line.Left.length);
                        for (const token of line.Left) {
                            if (token && typeof token === 'object' && token.attr) {
                                docRef = token.attr.replace(/^\//, '');
                                console.log('Found landingPageURI in Left token attr:', docRef);
                                break;
                            }
                        }
                    }

                    // Fallback: check Right tokens
                    if (!docRef && line.Right && Array.isArray(line.Right)) {
                        console.log('Right array length:', line.Right.length);
                        for (const token of line.Right) {
                            if (token && typeof token === 'object' && token.attr) {
                                docRef = token.attr.replace(/^\//, '');
                                console.log('Found landingPageURI in Right token attr:', docRef);
                                break;
                            }
                        }
                    }

                    console.log('After checking all tokens, docRef:', docRef);

                    // Fallback: Check Refs for chapter.id
                    if (!docRef && line.Refs && Array.isArray(line.Refs)) {
                        console.log('Line', index, 'Refs:', line.Refs);
                        const docRefObj = line.Refs.find(ref =>
                            ref.name === 'chapter.id' || ref.name === 'chapter' || ref.name === 'doc.id' || ref.name === 'doc' || ref.name === 'text'
                        );
                        if (docRefObj) {
                            docRef = docRefObj.val || docRefObj.value;
                            console.log('Found docRef in Refs:', docRef);
                        }
                    }

                    if (!docRef && line.refs && Array.isArray(line.refs)) {
                        const docRefObj = line.refs.find(ref =>
                            ref.name === 'chapter.id' || ref.name === 'chapter' || ref.name === 'doc.id' || ref.name === 'doc' || ref.name === 'text'
                        );
                        if (docRefObj) {
                            docRef = docRefObj.val || docRefObj.value;
                        }
                    }
                }
            }

            // 4. Look in cells for hidden data or landingPageURI in the rendered HTML
            if (!docRef) {
                cells.forEach(cell => {
                    if (cell.dataset.doc || cell.dataset.docId) {
                        docRef = cell.dataset.doc || cell.dataset.docId;
                    }

                    // Also check for landingPageURI in the rendered HTML
                    // Look for <concordance-result-items> or <span> with URL
                    if (!docRef) {
                        const resultItems = cell.querySelectorAll('concordance-result-items span.itm, span.itm');
                        resultItems.forEach(item => {
                            const text = item.textContent.trim();
                            if (text.startsWith('http://') || text.startsWith('https://')) {
                                docRef = text;
                                console.log('Found landingPageURI in rendered HTML:', docRef);
                            }
                        });
                    }

                    // Also check all text content for URLs
                    if (!docRef) {
                        const text = cell.textContent;
                        const urlMatch = text.match(/(https?:\/\/[^\s]+\.html)/);
                        if (urlMatch) {
                            docRef = urlMatch[1];
                            console.log('Found URL in cell text:', docRef);
                        }
                    }
                });
            }

            // Log for debugging
            console.log('Row', index, 'final docRef:', docRef);

            if (docRef) {
                // If docRef is already a full URL (from landingPageURI), extract just the filename
                let letterUrl;
                if (docRef.startsWith('http://') || docRef.startsWith('https://')) {
                    // Extract just the filename from the full URL
                    // e.g., "https://arthur-schnitzler.github.io/schnitzler-briefe-static/L01761.html" -> "L01761.html"
                    const urlParts = docRef.split('/');
                    letterUrl = urlParts[urlParts.length - 1];
                    console.log('Row', index, 'extracted filename from URL:', letterUrl);
                } else {
                    // Otherwise, treat it as a file ID and construct the URL
                    const letterId = docRef.replace(/\.xml$/, '').replace(/^.*\//, '');
                    letterUrl = `${letterId}.html`;
                    console.log('Row', index, 'linking to:', letterUrl);
                }

                // Make the entire row clickable
                row.style.cursor = 'pointer';
                row.classList.add('clickable-row');

                // Remove any existing click handlers
                const newRow = row.cloneNode(true);
                row.parentNode.replaceChild(newRow, row);

                newRow.addEventListener('click', (e) => {
                    // Don't navigate if clicking on an existing link
                    if (e.target.tagName !== 'A') {
                        window.location.href = letterUrl;
                    }
                });

                // Add link to the keyword (middle cell)
                const newCells = newRow.querySelectorAll('td');
                const keywordCell = newCells[1];
                if (keywordCell && !keywordCell.querySelector('a')) {
                    const keyword = keywordCell.innerHTML;
                    keywordCell.innerHTML = `<a href="${letterUrl}">${keyword}</a>`;
                }
            } else {
                console.warn('No document reference found for row', index);
            }
        });
    }

    addSearchButton(searchInput) {
        // Check if button already exists
        if (searchInput.parentElement.querySelector('.noske-search-btn')) return;

        const searchButton = document.createElement('button');
        searchButton.textContent = 'Suchen';
        searchButton.className = 'btn btn-primary mt-2 noske-search-btn';
        searchButton.type = 'button';

        searchButton.addEventListener('click', () => {
            this.performSearch(searchInput.value);
        });

        searchInput.parentElement.appendChild(searchButton);
    }

    addClearButton() {
        const statsContainer = document.getElementById('noske-stats');
        if (!statsContainer || statsContainer.querySelector('.noske-clear-btn')) return;

        const clearButton = document.createElement('button');
        clearButton.textContent = 'Ergebnisse löschen';
        clearButton.className = 'btn btn-outline-secondary btn-sm ms-2 noske-clear-btn';
        clearButton.style.display = 'none';
        clearButton.type = 'button';

        clearButton.addEventListener('click', () => {
            this.clearResults();
        });

        statsContainer.appendChild(clearButton);
    }

    performSearch(query) {
        if (!query || !query.trim()) {
            this.showError('Bitte geben Sie einen Suchbegriff ein.');
            return;
        }

        console.log('Performing Noske search for:', query);

        // Show loading state
        this.showLoading();

        try {
            // Use the acdh-noske-search package's search functionality
            if (this.search && typeof this.search.performSearch === 'function') {
                this.search.performSearch(query.trim());
            } else {
                // Fallback: trigger search through the configured input
                const searchInput = document.getElementById('noske-input');
                if (searchInput) {
                    searchInput.value = query.trim();
                    searchInput.dispatchEvent(new Event('change'));
                }
            }

            // Show clear button
            const clearButton = document.querySelector('.noske-clear-btn');
            if (clearButton) {
                clearButton.style.display = 'inline-block';
            }

        } catch (error) {
            console.error('Error performing search:', error);
            this.showError('Fehler bei der Suche. Bitte überprüfen Sie Ihre Suchanfrage.');
        }
    }

    clearResults() {
        // Clear all result containers
        const containers = ['noske-hits', 'noske-stats', 'noske-pagination'];
        containers.forEach(id => {
            const container = document.getElementById(id);
            if (container) {
                container.innerHTML = '';
            }
        });

        // Clear search input
        const searchInput = document.getElementById('noske-input');
        if (searchInput) {
            searchInput.value = '';
        }

        // Hide clear button
        const clearButton = document.querySelector('.noske-clear-btn');
        if (clearButton) {
            clearButton.style.display = 'none';
        }

        console.log('Noske search results cleared');
    }

    showLoading() {
        const statsContainer = document.getElementById('noske-stats');
        const hitsContainer = document.getElementById('noske-hits');

        if (statsContainer) {
            statsContainer.innerHTML = '<div class="alert alert-info mb-0"><i class="fas fa-spinner fa-spin"></i> Suche läuft...</div>';
        }

        if (hitsContainer) {
            hitsContainer.innerHTML = `
                <div class="d-flex justify-content-center p-4">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Suche läuft...</span>
                    </div>
                </div>
            `;
        }
    }

    showError(message) {
        const statsContainer = document.getElementById('noske-stats');
        const hitsContainer = document.getElementById('noske-hits');

        if (statsContainer) {
            statsContainer.innerHTML = `<div class="alert alert-warning mb-0"><i class="fas fa-exclamation-triangle"></i> ${message}</div>`;
        }

        if (hitsContainer) {
            hitsContainer.innerHTML = `
                <div class="alert alert-warning">
                    <h6><i class="fas fa-exclamation-triangle"></i> Hinweis</h6>
                    <p class="mb-3">${message}</p>
                    <div class="mt-3">
                        <h6>Erweiterte Suchoptionen:</h6>
                        <ul class="mb-0">
                            <li><strong>Einfache Suche:</strong> <code>liebe</code> oder <code>lieb*</code> für Platzhaltersuche</li>
                            <li><strong>CQL-Suche:</strong> <code>[lemma="lieben"]</code> für Lemma-Suche</li>
                            <li><strong>Regex:</strong> <code>[word=".*ing"]</code> für komplexe Muster</li>
                        </ul>
                    </div>
                </div>
            `;
        }
    }

    show() {
        console.log('Showing Noske search...');

        // Show Noske container, hide Typesense
        const noskeContainer = document.getElementById('noske-search-container');
        const typesenseContainer = document.getElementById('typesense-search-container');

        if (noskeContainer) noskeContainer.style.display = 'block';
        if (typesenseContainer) typesenseContainer.style.display = 'none';

        // Initialize if not already done
        if (!this.initialized) {
            this.init();
        }
    }

    hide() {
        const noskeContainer = document.getElementById('noske-search-container');
        if (noskeContainer) {
            noskeContainer.style.display = 'none';
        }
    }

    // Utility method to check if the package is available
    isPackageAvailable() {
        return typeof NoskeSearch !== 'undefined';
    }
}

// Initialize global Noske search instance
try {
    window.noskeSearch = new NoskeSearchImplementation();
    console.log('Noske search module loaded successfully');
} catch (error) {
    console.error('Failed to initialize Noske search module:', error);

    // Fallback error display
    window.noskeSearch = {
        show: function() {
            const container = document.getElementById('noske-search-container');
            if (container) {
                container.innerHTML = `
                    <div class="alert alert-danger">
                        <h6><i class="fas fa-exclamation-circle"></i> Noske-Suche nicht verfügbar</h6>
                        <p>Die Noske-Suchfunktion konnte nicht geladen werden. Bitte verwenden Sie die Typesense-Suche oder kontaktieren Sie den Administrator.</p>
                    </div>
                `;
                container.style.display = 'block';
            }
        },
        hide: function() {
            const container = document.getElementById('noske-search-container');
            if (container) container.style.display = 'none';
        }
    };
}