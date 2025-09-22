// Search Engine Toggle Functionality
class SearchToggle {
    constructor() {
        this.currentEngine = 'typesense'; // Default to Typesense
        this.init();
    }

    init() {
        // Set up event listeners for toggle buttons in both containers
        const typesenseBtn = document.getElementById('btn-typesense');
        const noskeBtn = document.getElementById('btn-noske');
        const typesenseBtnNoske = document.getElementById('btn-typesense-noske');
        const noskeBtnNoske = document.getElementById('btn-noske-noske');

        // Typesense container buttons
        if (typesenseBtn) {
            typesenseBtn.addEventListener('click', () => this.switchToTypesense());
        }
        if (noskeBtn) {
            noskeBtn.addEventListener('click', () => this.switchToNoske());
        }

        // Noske container buttons
        if (typesenseBtnNoske) {
            typesenseBtnNoske.addEventListener('click', () => this.switchToTypesense());
        }
        if (noskeBtnNoske) {
            noskeBtnNoske.addEventListener('click', () => this.switchToNoske());
        }

        // Initialize with Typesense by default
        this.switchToTypesense();
    }

    switchToTypesense() {
        this.currentEngine = 'typesense';

        // Show Typesense container, hide Noske container
        const typesenseContainer = document.getElementById('typesense-search-container');
        const noskeContainer = document.getElementById('noske-search-container');

        if (typesenseContainer) typesenseContainer.style.display = 'block';
        if (noskeContainer) noskeContainer.style.display = 'none';

        // Update button states
        this.updateButtonStates('typesense');

        // Hide Noske search if it exists
        if (window.noskeSearch) {
            window.noskeSearch.hide();
        }
        if (window.directNoskeSearch) {
            window.directNoskeSearch.hide();
        }

        // Ensure Typesense search is properly initialized and rendered
        if (window.search && window.search.started && typeof window.search.refresh === 'function') {
            // Wait a bit for DOM to update, then refresh
            setTimeout(() => {
                window.search.refresh();
            }, 100);
        } else if (window.search && !window.search.started) {
            // If search exists but hasn't started yet, wait and try again
            setTimeout(() => {
                if (window.search.started && typeof window.search.refresh === 'function') {
                    window.search.refresh();
                }
            }, 500);
        }

        console.log('Switched to Typesense search');
    }

    switchToNoske() {
        this.currentEngine = 'noske';

        // Show Noske container, hide Typesense container
        const typesenseContainer = document.getElementById('typesense-search-container');
        const noskeContainer = document.getElementById('noske-search-container');

        if (typesenseContainer) typesenseContainer.style.display = 'none';
        if (noskeContainer) noskeContainer.style.display = 'block';

        // Update button states
        this.updateButtonStates('noske');

        // Initialize and show Noske search
        if (window.noskeSearch) {
            window.noskeSearch.show();
        } else if (window.directNoskeSearch) {
            window.directNoskeSearch.show();
        }

        console.log('Switched to Noske search');
    }

    updateButtonStates(activeEngine) {
        // Get all button references
        const typesenseBtn = document.getElementById('btn-typesense');
        const noskeBtn = document.getElementById('btn-noske');
        const typesenseBtnNoske = document.getElementById('btn-typesense-noske');
        const noskeBtnNoske = document.getElementById('btn-noske-noske');

        const allButtons = [typesenseBtn, noskeBtn, typesenseBtnNoske, noskeBtnNoske];

        // Reset all buttons to outline style
        allButtons.forEach(btn => {
            if (btn) {
                btn.classList.remove('btn-primary');
                btn.classList.add('btn-outline-primary');
            }
        });

        // Set active buttons based on current engine
        if (activeEngine === 'typesense') {
            if (typesenseBtn) {
                typesenseBtn.classList.remove('btn-outline-primary');
                typesenseBtn.classList.add('btn-primary');
            }
            if (typesenseBtnNoske) {
                typesenseBtnNoske.classList.remove('btn-outline-primary');
                typesenseBtnNoske.classList.add('btn-primary');
            }
        } else {
            if (noskeBtn) {
                noskeBtn.classList.remove('btn-outline-primary');
                noskeBtn.classList.add('btn-primary');
            }
            if (noskeBtnNoske) {
                noskeBtnNoske.classList.remove('btn-outline-primary');
                noskeBtnNoske.classList.add('btn-primary');
            }
        }
    }
}

// Initialize search toggle when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    // Initialize Bootstrap tooltips
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });

    // Initialize search toggle
    window.searchToggle = new SearchToggle();
});