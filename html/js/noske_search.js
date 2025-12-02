// Noske Search Implementation using acdh-noske-search package
import { NoskeSearch } from "https://cdn.jsdelivr.net/npm/acdh-noske-search/dist/index.js";

class NoskeSearchImplementation {
    constructor() {
        this.search = null;
        this.initialized = false;
        this.config = {
            client: {
                base: "https://corpus-search.acdh.oeaw.ac.at/",
                corpname: "schnitzlertagebuch", // Tagebuch corpus name as specified
                attrs: "word,id",
                structs: "doc,docTitle,head,p,imprimatur,list",
                refs: "doc.id,doc.corpus,docTitle.id,p.id,head.id,imprimatur.id,list.id"
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
                    corpname: "schnitzlertagebuch", // Tagebuch corpus name as specified
                    attrs: "word,id,landingPageURI",
                    structs: "doc,docTitle,head,p,imprimatur,list,chapter",
                    refs: "doc.id,doc.corpus,docTitle.id,p.id,head.id,imprimatur.id,list.id,chapter.id",
                },
                hits: {
                    id: "hitsbox",
                    css: {
                        table: "table-auto",
                    },
                    kwicRowRenderer: this.customKwicRowRenderer.bind(this)
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

    customKwicRowRenderer(hit) {
        // Extract landingPageURI from the keyword token (first token should have it)
        let landingPageURI = null;

        // Check all tokens for landingPageURI attribute
        const allTokens = [...(hit.Left || []), ...(hit.Kwic || []), ...(hit.Right || [])];
        for (const token of allTokens) {
            if (token.landingPageURI) {
                landingPageURI = token.landingPageURI;
                break;
            }
        }

        // Create the row element
        const row = document.createElement('tr');
        row.className = 'kwic-row';

        // Left context
        const leftCell = document.createElement('td');
        leftCell.className = 'text-end text-muted';
        leftCell.textContent = hit.Left?.map(item => item.word).join(' ') || '';
        row.appendChild(leftCell);

        // Keyword
        const kwicCell = document.createElement('td');
        kwicCell.className = 'fw-bold text-primary text-center';
        kwicCell.textContent = hit.Kwic?.map(item => item.word).join(' ') || '';
        row.appendChild(kwicCell);

        // Right context
        const rightCell = document.createElement('td');
        rightCell.className = 'text-start text-muted';
        rightCell.textContent = hit.Right?.map(item => item.word).join(' ') || '';
        row.appendChild(rightCell);

        // Document link
        const docCell = document.createElement('td');
        docCell.className = 'text-start';
        if (landingPageURI) {
            // Extract just the filename from the full URI
            const filename = landingPageURI.split('/').pop();
            const displayText = filename.replace('entry__', '').replace('.html', '');

            const link = document.createElement('a');
            link.href = filename;
            link.textContent = displayText;
            link.className = 'btn btn-sm btn-outline-primary';
            link.title = 'Zum Tagebucheintrag';
            docCell.appendChild(link);
        }
        row.appendChild(docCell);

        return row;
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