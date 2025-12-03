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

    init() {
        if (this.initialized) return;

        console.log('Initializing Noske search with acdh-noske-search package for schnitzlertagebuch...');

        try {
            // Create new NoskeSearch instance
            this.search = new NoskeSearch({container: "noske-search"});

            this.search.search({
                client: {
                    base: "https://corpus-search.acdh.oeaw.ac.at/",
                    corpname: "schnitzlertagebuch",
                    attrs: "word,id,landingPageURI",
                    structs: "s",
                    refs: "doc.id,chapter.id",
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
                wordlistattr: ["word", "id", "landingPageURI"],
            });

            // Intercept API calls to capture response data
            this.interceptApiCalls();

            // Add custom event listeners
            this.setupEventListeners();

            this.initialized = true;
            console.log('Noske search initialized successfully for schnitzlertagebuch');

        } catch (error) {
            console.error('Error initializing Noske search:', error);
            this.showError('Fehler beim Initialisieren der Noske-Suche. Bitte versuchen Sie es später erneut.');
        }
    }

    interceptApiCalls() {
        // Intercept fetch calls to capture Noske API responses
        const originalFetch = window.fetch;
        const self = this;

        window.fetch = async function(...args) {
            const response = await originalFetch.apply(this, args);

            // Check if this is a Noske concordance API call
            if (args[0] && typeof args[0] === 'string' && args[0].includes('corpus-search.acdh.oeaw.ac.at')) {
                // Clone the response so we can read it without consuming it
                const clonedResponse = response.clone();
                try {
                    const data = await clonedResponse.json();
                    console.log('Intercepted Noske API response:', data);
                    self.latestApiData = data;

                    // Add links after the DOM is updated
                    setTimeout(() => {
                        self.addLinksToResults();
                    }, 100);
                } catch (e) {
                    console.log('Could not parse API response as JSON');
                }
            }

            return response;
        };
    }

    addLinksToResults() {
        const hitsContainer = document.getElementById('hitsbox');
        if (!hitsContainer) return;

        console.log('Adding links to results...');
        console.log('this.latestApiData available?', !!this.latestApiData);
        console.log('Full latestApiData:', JSON.stringify(this.latestApiData, null, 2));

        if (!this.latestApiData && window.noskeSearch && window.noskeSearch.latestApiData) {
            console.log('Using latestApiData from window.noskeSearch');
            this.latestApiData = window.noskeSearch.latestApiData;
        }

        const rows = hitsContainer.querySelectorAll('tr');
        console.log('Found', rows.length, 'rows');

        rows.forEach((row, index) => {
            if (row.dataset.processed === 'true') return;
            row.dataset.processed = 'true';

            const cells = row.querySelectorAll('td');
            if (cells.length < 3) return;

            let docRef = null;

            // Try to extract from latestApiData
            if (this.latestApiData) {
                const lines = this.latestApiData.Lines || this.latestApiData.lines;
                if (lines && lines[index]) {
                    const line = lines[index];
                    console.log('Line', index, 'full structure:', JSON.stringify(line, null, 2));

                    // Check Kwic tokens for landingPageURI - look in strc property
                    if (line.Kwic && Array.isArray(line.Kwic)) {
                        console.log('Kwic tokens:', line.Kwic);
                        for (const token of line.Kwic) {
                            console.log('Kwic token structure:', JSON.stringify(token, null, 2));
                            // The landingPageURI is in the strc.landingPageURI property
                            if (token && token.strc && token.strc.landingPageURI) {
                                docRef = token.strc.landingPageURI;
                                console.log('Found landingPageURI in Kwic strc:', docRef);
                                break;
                            }
                            // Also try the attr property as fallback
                            if (!docRef && token && token.attr) {
                                docRef = token.attr.replace(/^\//, '');
                                console.log('Found landingPageURI in Kwic attr:', docRef);
                                break;
                            }
                        }
                    }

                    // Fallback: check Left tokens
                    if (!docRef && line.Left && Array.isArray(line.Left)) {
                        console.log('Left tokens:', line.Left);
                        for (const token of line.Left) {
                            if (token && token.strc && token.strc.landingPageURI) {
                                docRef = token.strc.landingPageURI;
                                console.log('Found landingPageURI in Left strc:', docRef);
                                break;
                            }
                            if (!docRef && token && token.attr) {
                                docRef = token.attr.replace(/^\//, '');
                                console.log('Found landingPageURI in Left attr:', docRef);
                                break;
                            }
                        }
                    }

                    // Fallback: check Right tokens
                    if (!docRef && line.Right && Array.isArray(line.Right)) {
                        console.log('Right tokens:', line.Right);
                        for (const token of line.Right) {
                            if (token && token.strc && token.strc.landingPageURI) {
                                docRef = token.strc.landingPageURI;
                                console.log('Found landingPageURI in Right strc:', docRef);
                                break;
                            }
                            if (!docRef && token && token.attr) {
                                docRef = token.attr.replace(/^\//, '');
                                console.log('Found landingPageURI in Right attr:', docRef);
                                break;
                            }
                        }
                    }

                    // Fallback: check Refs for chapter.id
                    if (!docRef && line.Refs && Array.isArray(line.Refs)) {
                        console.log('Refs array:', line.Refs);
                        const chapterRef = line.Refs.find(ref => ref.name === 'chapter.id');
                        if (chapterRef) {
                            docRef = chapterRef.val || chapterRef.value;
                            console.log('Found chapter.id in Refs:', docRef);
                        }
                    }

                    // Additional fallback: check refs (lowercase)
                    if (!docRef && line.refs && Array.isArray(line.refs)) {
                        console.log('refs array (lowercase):', line.refs);
                        const chapterRef = line.refs.find(ref => ref.name === 'chapter.id');
                        if (chapterRef) {
                            docRef = chapterRef.val || chapterRef.value;
                            console.log('Found chapter.id in refs:', docRef);
                        }
                    }
                }
            }

            console.log('Row', index, 'final docRef:', docRef);

            if (docRef) {
                let entryUrl;
                if (docRef.startsWith('http://') || docRef.startsWith('https://')) {
                    const urlParts = docRef.split('/');
                    entryUrl = urlParts[urlParts.length - 1];
                    console.log('Row', index, 'extracted filename from URL:', entryUrl);
                } else {
                    const entryId = docRef.replace(/\.xml$/, '').replace(/^.*\//, '');
                    entryUrl = `${entryId}.html`;
                    console.log('Row', index, 'linking to:', entryUrl);
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