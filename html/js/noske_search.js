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
                    attrs: "word,landingPageURI",
                    attr_allpos: "all",
                    structs: "chapter",
                    refs: "chapter.id",
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

            this.initialized = true;
            console.log('Noske search initialized successfully for schnitzlertagebuch');

        } catch (error) {
            console.error('Error initializing Noske search:', error);
            this.showError('Fehler beim Initialisieren der Noske-Suche. Bitte versuchen Sie es später erneut.');
        }
    }


    addLinksToResults() {
        const hitsContainer = document.getElementById('hitsbox');
        if (!hitsContainer) {
            console.log('hitsbox not found, cannot add links');
            return;
        }

        console.log('Adding links to results...');
        console.log('API data available?', !!this.latestApiData);

        if (!this.latestApiData) {
            console.warn('No API data available, cannot add links');
            return;
        }

        const lines = this.latestApiData.Lines || this.latestApiData.lines;
        if (!lines || !Array.isArray(lines)) {
            console.warn('No Lines array in API data');
            return;
        }

        console.log('Processing', lines.length, 'lines from API data');

        // Find all table rows in the results
        const rows = hitsContainer.querySelectorAll('tr');
        console.log('Found', rows.length, 'rows in DOM');

        rows.forEach((row, index) => {
            // Skip if already processed
            if (row.dataset.processed === 'true') return;
            row.dataset.processed = 'true';

            const cells = row.querySelectorAll('td');
            if (cells.length < 3) return;

            // Get the corresponding line from API data
            const line = lines[index];
            if (!line) {
                console.warn('Row', index, 'has no corresponding line in API data');
                return;
            }

            // Extract landingPageURI from token attributes
            let landingPageURI = null;

            // Search through all token arrays (Left, Kwic, Right)
            const tokenArrays = [line.Left, line.Kwic, line.Right].filter(arr => Array.isArray(arr));

            for (const tokens of tokenArrays) {
                for (const token of tokens) {
                    if (token && token.attr) {
                        landingPageURI = token.attr;
                        console.log('Row', index, 'found landingPageURI:', landingPageURI);
                        break;
                    }
                }
                if (landingPageURI) break;
            }

            if (!landingPageURI) {
                console.warn('Row', index, 'no landingPageURI found in token attributes');
                return;
            }

            // Remove leading slash if present (e.g., "/https://..." -> "https://...")
            landingPageURI = landingPageURI.replace(/^\//, '');

            // Extract filename from full URL
            let entryUrl;
            if (landingPageURI.startsWith('http://') || landingPageURI.startsWith('https://')) {
                const urlParts = landingPageURI.split('/');
                entryUrl = urlParts[urlParts.length - 1];
                console.log('Row', index, 'extracted entry URL:', entryUrl);
            } else {
                console.warn('Row', index, 'unexpected landingPageURI format:', landingPageURI);
                return;
            }

            // Validate entry URL format
            if (!entryUrl.match(/^entry__\d{4}-\d{2}-\d{2}\.html$/)) {
                console.warn('Row', index, 'invalid entry URL format:', entryUrl);
                return;
            }

            // Make the row clickable
            row.style.cursor = 'pointer';
            row.classList.add('clickable-row');

            // Clone and replace row to remove old event listeners
            const newRow = row.cloneNode(true);
            row.parentNode.replaceChild(newRow, row);

            // Add click handler to row
            newRow.addEventListener('click', (e) => {
                if (e.target.tagName !== 'A') {
                    window.location.href = entryUrl;
                }
            });

            // Add link to keyword cell (middle column)
            const newCells = newRow.querySelectorAll('td');
            const keywordCell = newCells[1];
            if (keywordCell && !keywordCell.querySelector('a')) {
                const keyword = keywordCell.innerHTML;
                keywordCell.innerHTML = `<a href="${entryUrl}">${keyword}</a>`;
                console.log('Row', index, 'added link to keyword:', entryUrl);
            }
        });

        console.log('Finished adding links to', rows.length, 'rows');
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