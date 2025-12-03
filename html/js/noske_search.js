// Noske Search Implementation using acdh-noske-search package
import { NoskeSearch } from "https://cdn.jsdelivr.net/npm/acdh-noske-search/dist/index.js";

class NoskeSearchImplementation {
    constructor() {
        this.search = null;
        this.initialized = false;
        this.latestApiData = null;
        this.config = {
            client: {
                base: "https://corpus-search.acdh.oeaw.ac.at/",
                corpname: "schnitzlertagebuch",
                attrs: "word,id,landingPageURI",
                structs: "s",
                refs: "doc.id,chapter.id"
            },
            hits: {
                id: "noske-hits",
                css: {
                    table: "table table-striped table-hover",
                    kwicContainer: "kwic-container",
                    leftContext: "text-muted",
                    rightContext: "text-muted",
                    keyword: "fw-bold text-primary"
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

                    console.log('Stored API data in self.latestApiData');

                    // Add links after DOM is updated
                    setTimeout(() => {
                        self.addLinksToResults();
                    }, 100);
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

        console.log('Initializing Noske search with acdh-noske-search package for schnitzlertagebuch...');

        try {
            // Intercept fetch calls to capture Noske API responses
            this.interceptNoskeAPI();

            // Create new NoskeSearch instance
            this.search = new NoskeSearch({container: "noske-search"});

            this.search.search({
                client: {
                    id: "noske-client",
                    base: "https://corpus-search.acdh.oeaw.ac.at/",
                    corpname: "schnitzlertagebuch",
                    attrs: "word",
                    attr_allpos: "all",
                    structs: "s",
                    refs: "doc.id",
                },
                hits: {
                    id: "hitsbox",
                    css: {
                        table: "table-auto",
                    },
                },
                pagination: {
                    id: "noske-pagination-test",
                },
                searchInput: {
                    id: "noske-search",
                },
                stats: {
                    id: "noske-stats",
                },
            });

            // Add custom event listeners
            this.setupEventListeners();

            // Set up MutationObserver to watch for results being rendered
            this.setupResultsObserver();

            this.initialized = true;
            console.log('Noske search initialized successfully for schnitzlertagebuch');

        } catch (error) {
            console.error('Error initializing Noske search:', error);
            this.showError('Fehler beim Initialisieren der Noske-Suche. Bitte versuchen Sie es später erneut.');
        }
    }

    setupResultsObserver() {
        const hitsContainer = document.getElementById('hitsbox');
        if (!hitsContainer) {
            console.warn('hitsbox not found, retrying in 100ms...');
            setTimeout(() => this.setupResultsObserver(), 100);
            return;
        }

        let processingResults = false;

        const observer = new MutationObserver(() => {
            const rows = hitsContainer.querySelectorAll('tr');
            if (rows.length > 0 && !processingResults) {
                processingResults = true;
                console.log('Results detected in DOM, fetching landingPageURI data...');
                setTimeout(() => {
                    this.fetchAndAddLinks().finally(() => {
                        processingResults = false;
                    });
                }, 300);
            }
        });

        observer.observe(hitsContainer, {
            childList: true,
            subtree: true
        });

        console.log('Results observer set up');
    }

    async fetchAndAddLinks() {
        // Get the current search query from the input
        const searchInput = document.querySelector('#noske-search input');
        if (!searchInput || !searchInput.value) {
            console.warn('No search query found');
            return;
        }

        const query = searchInput.value.trim();
        console.log('Fetching landingPageURI for query:', query);

        try {
            // Build the API URL with landingPageURI
            const encodedQuery = encodeURIComponent(query);
            const apiUrl = `https://corpus-search.acdh.oeaw.ac.at/search/concordance?corpname=schnitzlertagebuch&q=q${encodedQuery}&attrs=word,landingPageURI&viewmode=kwic&fromp=1&pagesize=50&format=json`;

            console.log('Fetching from:', apiUrl);
            const response = await fetch(apiUrl);
            const data = await response.json();

            console.log('Received data with', data.Lines?.length || 0, 'lines');
            this.latestApiData = data;

            // Now add links using the API data
            this.addLinksToResults();
        } catch (error) {
            console.error('Error fetching landingPageURI data:', error);
        }
    }

    addLinksFromDOM() {
        const hitsContainer = document.getElementById('hitsbox');
        if (!hitsContainer) return;

        console.log('Scanning DOM for landingPageURI...');
        const rows = hitsContainer.querySelectorAll('tr');
        console.log('Found', rows.length, 'rows in DOM');

        rows.forEach((row, index) => {
            if (row.dataset.processed === 'true') return;
            row.dataset.processed = 'true';

            const cells = row.querySelectorAll('td');
            if (cells.length < 3) return;

            // Look for URLs in the DOM - the package logs them as "https:"
            let entryUrl = null;

            // Check all text nodes and attributes for the landingPageURI
            const allText = row.textContent;

            // Look for entry__ pattern in the text content
            const entryMatch = allText.match(/entry__\d{4}-\d{2}-\d{2}\.html/);
            if (entryMatch) {
                entryUrl = entryMatch[0];
                console.log('Row', index, 'found entry URL in text:', entryUrl);
            }

            // If not found in text, check data attributes
            if (!entryUrl) {
                const allElements = row.querySelectorAll('*');
                for (const el of allElements) {
                    for (const attr of el.attributes || []) {
                        if (attr.value && attr.value.includes('entry__') && attr.value.includes('.html')) {
                            const match = attr.value.match(/entry__\d{4}-\d{2}-\d{2}\.html/);
                            if (match) {
                                entryUrl = match[0];
                                console.log('Row', index, 'found entry URL in attribute:', attr.name, '=', entryUrl);
                                break;
                            }
                        }
                    }
                    if (entryUrl) break;
                }
            }

            if (entryUrl) {
                console.log('Row', index, 'linking to:', entryUrl);

                row.style.cursor = 'pointer';
                row.classList.add('clickable-row');

                const newRow = row.cloneNode(true);
                row.parentNode.replaceChild(newRow, row);

                newRow.addEventListener('click', (e) => {
                    if (e.target.tagName !== 'A') {
                        window.location.href = entryUrl;
                    }
                });

                const newCells = newRow.querySelectorAll('td');
                const keywordCell = newCells[1];
                if (keywordCell && !keywordCell.querySelector('a')) {
                    const keyword = keywordCell.innerHTML;
                    keywordCell.innerHTML = `<a href="${entryUrl}">${keyword}</a>`;
                }
            } else {
                console.warn('Row', index, 'no entry URL found in DOM');
            }
        });
    }

    addLinksToResults() {
        const hitsContainer = document.getElementById('hitsbox');
        if (!hitsContainer) return;

        console.log('Adding links to results...');
        console.log('this.latestApiData available?', !!this.latestApiData);

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

            // 2. Try to extract from latestApiData if available
            if (!docRef && this.latestApiData) {
                const lines = this.latestApiData.Lines || this.latestApiData.lines;
                if (lines && lines[index]) {
                    const line = lines[index];
                    console.log('Line', index, 'data:', JSON.stringify(line, null, 2));

                    // Check Kwic tokens for landingPageURI in the 'attr' field
                    if (line.Kwic && Array.isArray(line.Kwic)) {
                        for (const token of line.Kwic) {
                            if (token && typeof token === 'object' && token.attr) {
                                docRef = token.attr.replace(/^\//, '');
                                console.log('Found landingPageURI in Kwic token attr:', docRef);
                                break;
                            }
                        }
                    }

                    // Fallback: check Left tokens
                    if (!docRef && line.Left && Array.isArray(line.Left)) {
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
                        for (const token of line.Right) {
                            if (token && typeof token === 'object' && token.attr) {
                                docRef = token.attr.replace(/^\//, '');
                                console.log('Found landingPageURI in Right token attr:', docRef);
                                break;
                            }
                        }
                    }

                    // Fallback: Check Refs for chapter.id
                    if (!docRef && line.Refs && Array.isArray(line.Refs)) {
                        const chapterRef = line.Refs.find(ref => ref.name === 'chapter.id');
                        if (chapterRef) {
                            docRef = chapterRef.val || chapterRef.value;
                            console.log('Found chapter.id in Refs:', docRef);
                        }
                    }
                }
            }

            console.log('Row', index, 'final docRef:', docRef);

            if (docRef) {
                let entryUrl;
                console.log('Row', index, 'processing docRef:', docRef);

                if (docRef.startsWith('http://') || docRef.startsWith('https://')) {
                    // Extract just the filename from the full URL
                    const urlParts = docRef.split('/');
                    entryUrl = urlParts[urlParts.length - 1];
                    console.log('Row', index, 'extracted filename from URL:', entryUrl);
                } else if (docRef.startsWith('#')) {
                    // Handle anchor links - this shouldn't happen but let's be safe
                    console.warn('Row', index, 'docRef starts with #, skipping:', docRef);
                    return;
                } else {
                    // Treat as file ID
                    const entryId = docRef.replace(/\.xml$/, '').replace(/^.*\//, '');
                    entryUrl = `${entryId}.html`;
                    console.log('Row', index, 'linking to:', entryUrl);
                }

                // Verify entryUrl is valid
                if (!entryUrl || entryUrl === 'null' || entryUrl === 'undefined' || entryUrl.includes('undefined') || entryUrl.includes('null')) {
                    console.warn('Row', index, 'invalid entryUrl generated:', entryUrl, 'from docRef:', docRef);
                    return;
                }

                row.style.cursor = 'pointer';
                row.classList.add('clickable-row');

                const newRow = row.cloneNode(true);
                row.parentNode.replaceChild(newRow, row);

                newRow.addEventListener('click', (e) => {
                    if (e.target.tagName !== 'A') {
                        window.location.href = entryUrl;
                    }
                });

                const newCells = newRow.querySelectorAll('td');
                const keywordCell = newCells[1];
                if (keywordCell && !keywordCell.querySelector('a')) {
                    const keyword = keywordCell.innerHTML;
                    keywordCell.innerHTML = `<a href="${entryUrl}">${keyword}</a>`;
                }
            } else {
                console.warn('No document reference found for row', index);
            }
        });
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

        console.log('Performing Noske search for:', query, 'in corpus: schnitzlertagebuch');

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
        const hitsContainer = document.getElementById('hitsbox');

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
        const hitsContainer = document.getElementById('hitsbox');

        if (statsContainer) {
            statsContainer.innerHTML = `<div class="alert alert-warning mb-0"><i class="fas fa-exclamation-triangle"></i> ${message}</div>`;
        }

        if (hitsContainer) {
            hitsContainer.innerHTML = `
                <div class="alert alert-warning">
                    <h6><i class="fas fa-exclamation-triangle"></i> Hinweis zur Tagebuch-Suche</h6>
                    <p class="mb-3">${message}</p>
                    <div class="mt-3">
                        <h6>Erweiterte Suchoptionen für Schnitzlers Tagebuch:</h6>
                        <ul class="mb-0">
                            <li><strong>Einfache Suche:</strong> <code>Theater</code> oder <code>theat*</code> für Platzhaltersuche</li>
                            <li><strong>CQL-Suche:</strong> <code>[lemma="Theater"]</code> für Lemma-Suche</li>
                            <li><strong>Regex:</strong> <code>[word=".*ung"]</code> für komplexe Muster</li>
                            <li><strong>Tagebuch-spezifisch:</strong> Suche nach Personen, Orten oder Werken aus dem Tagebuch</li>
                        </ul>
                    </div>
                </div>
            `;
        }
    }

    show() {
        console.log('Showing Noske search for schnitzlertagebuch...');

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
    console.log('Noske search module loaded successfully for schnitzlertagebuch');
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
                        <p>Die Noske-Suchfunktion für das Schnitzler-Tagebuch konnte nicht geladen werden. Bitte verwenden Sie die Typesense-Suche oder kontaktieren Sie den Administrator.</p>
                        <p><strong>Corpus:</strong> schnitzlertagebuch</p>
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