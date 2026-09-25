/**
 * Simple, sustainable calendar implementation for Schnitzler Tagebuch
 * Ported from the SimpleCalendar implementation in schnitzler-briefe-static,
 * adapted for diary entries plus letters written by Arthur Schnitzler,
 * and extended with a per-day list of mentioned entities in the week view.
 */

class SimpleCalendar {
  constructor(containerId, options = {}) {
    this.container = document.getElementById(containerId);
    this.currentYear = options.startYear || 1900;
    this.currentMonth = new Date().getMonth();
    this.currentWeek = this.getWeekOfYear(new Date());
    this.events = options.dataSource || [];
    this.onDayClick = options.clickDay || (() => {});
    this.onPrintedLetterClick = options.onPrintedLetterClick || (() => {});

    // View modes: 'year', 'month', 'week'
    this.currentView = 'year';

    // Event type categories and colors (Brief-Farben identisch mit schnitzler-briefe-static)
    this.eventCategories = {
      'entry': '#037A33',           // Tagebucheintrag (grün)
      'letter': '#A63437',          // Brief von Arthur Schnitzler (rot)
      'gedruckt': 'rgb(101, 67, 33)', // Gedruckter Brief von Schnitzler (braun)
      'fischer': '#3D4F9F'          // Brief von Schnitzler an S. Fischer (blau)
    };

    this.categoryLabels = {
      'entry': 'Tagebucheintrag',
      'letter': 'Brief von Schnitzler',
      'gedruckt': 'Gedruckte Briefe',
      'fischer': 'S. Fischer'
    };

    // Tagebucheinträge stehen an einem Tag immer vor Briefen, gedruckte
    // Briefe und S.-Fischer-Briefe (ohne eigene Edition) zuletzt
    this.categoryOrder = {
      'entry': 0,
      'letter': 1,
      'gedruckt': 2,
      'fischer': 3
    };

    // Entitätsfarben für die Wochenansicht, identisch mit schnitzler-briefe-static
    // (abgedunkelte Varianten der Entitätsfarben, Kontrast >= 4.5:1 auf Weiß)
    this.entityColors = {
      persons: '#c0392b',
      places: '#2874a6',
      works: '#9c6408'
    };


    this.monthNames = [
      'Jänner', 'Februar', 'März', 'April', 'Mai', 'Juni',
      'Juli', 'August', 'September', 'Oktober', 'November', 'Dezember'
    ];

    this.dayNames = ['So', 'Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa'];

    // Create initialization
    this.init();
  }

  init() {
    this.container.innerHTML = '';
    this.loadStateFromURL();

    // Calculate available years from events
    this.availableYears = [...new Set(this.events.map(event =>
      new Date(event.startDate).getFullYear()
    ))].sort((a, b) => a - b);

    this.createCalendarStructure();

    // Initialize view button states
    this.container.querySelectorAll('.view-btn').forEach(btn => {
      btn.classList.remove('active');
      if (btn.dataset.view === this.currentView) {
        btn.classList.add('active');
      }
    });

    // Initialize filter button states
    if (typeof window.activeFilters !== 'undefined') {
      this.container.querySelectorAll('.filter-toggle').forEach(btn => {
        const category = btn.dataset.category;
        if (window.activeFilters.has(category)) {
          btn.classList.add('active');
        } else {
          btn.classList.remove('active');
        }
      });
    }

    this.render();
  }


  // Check if event should be visible based on external activeFilters
  isEventVisible(event) {
    // Check if window.activeFilters exists (defined in calendar.js)
    if (typeof window.activeFilters !== 'undefined') {
      return event.category && window.activeFilters.has(event.category);
    }
    // Fallback: show all events
    return true;
  }

  // Toggle category filter
  toggleCategoryFilter(category) {
    if (typeof window.activeFilters !== 'undefined') {
      const button = this.container.querySelector(`[data-category="${category}"]`);

      if (window.activeFilters.has(category)) {
        window.activeFilters.delete(category);
        button.classList.remove('active');
      } else {
        window.activeFilters.add(category);
        button.classList.add('active');
      }

      // Update calendar display
      this.renderCalendar();
    }
  }

  createCalendarStructure() {
    this.container.innerHTML = `
      <div class="calendar">
        <div class="calendar-header">
          <button class="nav-btn prev" data-direction="-1">&lt;</button>
          <div class="current-period">
            <div class="period-navigation">
              <div class="calendar-controls">
                <div class="view-buttons">
                  <button class="view-btn active" data-view="year">Jahr</button>
                  <button class="view-btn" data-view="month">Monat</button>
                  <button class="view-btn" data-view="week">Woche</button>
                </div>
                <div class="period-dropdowns">
                  <!-- Dropdowns will be added dynamically -->
                </div>
                <div class="category-filters">
                  <button class="filter-toggle active" data-category="entry" title="Tagebucheinträge">
                    <span class="filter-dot"></span>
                    Tagebucheintrag
                  </button>
                  <button class="filter-toggle active" data-category="letter" title="Briefe von Arthur Schnitzler">
                    <span class="filter-dot"></span>
                    Brief von Schnitzler
                  </button>
                  <button class="filter-toggle active" data-category="gedruckt" title="Gedruckte Briefe von Arthur Schnitzler">
                    <span class="filter-dot"></span>
                    Gedruckte Briefe
                  </button>
                  <button class="filter-toggle active" data-category="fischer" title="Briefe von Arthur Schnitzler an S. Fischer">
                    <span class="filter-dot"></span>
                    S. Fischer
                  </button>
                </div>
              </div>
            </div>
          </div>
          <button class="nav-btn next" data-direction="1">&gt;</button>
        </div>
        <div class="calendar-grid"></div>
      </div>
    `;

    // Add CSS
    this.addStyles();

    // Add event listeners
    this.container.querySelectorAll('.nav-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const direction = parseInt(e.target.dataset.direction);
        this.navigatePeriod(direction);
      });
    });

    // Add view button listeners
    this.container.querySelectorAll('.view-btn').forEach(btn => {
      btn.addEventListener('click', (e) => {
        this.switchView(e.target.dataset.view);
      });
    });

    // Add category filter listeners
    this.container.querySelectorAll('.filter-toggle').forEach(btn => {
      btn.addEventListener('click', (e) => {
        const category = e.currentTarget.dataset.category;
        this.toggleCategoryFilter(category);
      });
    });

    // Create dropdown navigation
    this.createDropdownNavigation();
  }

  addStyles() {
    if (!document.getElementById('simple-calendar-styles')) {
      const style = document.createElement('style');
      style.id = 'simple-calendar-styles';
      style.textContent = `
        .calendar {
          width: 100%;
          max-width: none;
          margin: 0 auto;
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
        }

        .calendar-header {
          display: flex;
          justify-content: space-between;
          align-items: center;
          margin-bottom: 20px;
        }

        .current-period {
          flex: 1;
          text-align: center;
          position: relative;
        }

        .period-navigation {
          display: flex;
          flex-direction: column;
          align-items: center;
          gap: 10px;
        }

        .period-dropdowns {
          display: flex;
          gap: 10px;
          align-items: center;
          flex-wrap: wrap;
        }

        .period-dropdown {
          padding: 6px 12px;
          border: 1px solid #dee2e6;
          border-radius: 4px;
          font-size: 14px;
          background: white;
          cursor: pointer;
          min-width: 100px;
          box-sizing: border-box;
        }

        .period-dropdown:hover {
          border-color: #007bff;
        }

        .period-dropdown:focus {
          outline: none;
          border-color: #007bff;
          box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
        }

        .calendar-controls {
          display: flex;
          gap: 20px;
          margin-top: 10px;
          flex-wrap: wrap;
          justify-content: center;
          align-items: center;
        }

        .view-buttons {
          display: flex;
          gap: 4px;
        }

        .category-filters {
          display: flex;
          gap: 8px;
          flex-wrap: wrap;
        }

        .view-btn {
          background: #f8f9fa;
          border: 1px solid #dee2e6;
          border-radius: 4px;
          padding: 6px 12px;
          cursor: pointer;
          font-size: 14px;
          transition: all 0.2s;
          color: #495057;
          box-sizing: border-box;
        }

        .view-btn:hover {
          background: #e9ecef;
        }

        .view-btn.active {
          background: #007bff;
          color: white;
          border-color: #007bff;
        }

        .filter-toggle {
          background: #f8f9fa;
          border: 1px solid #dee2e6;
          border-radius: 4px;
          padding: 6px 12px;
          cursor: pointer;
          font-size: 14px;
          transition: all 0.2s;
          display: flex;
          align-items: center;
          gap: 6px;
          box-sizing: border-box;
        }

        .filter-toggle:hover {
          background: #e9ecef;
        }

        .filter-toggle .filter-dot {
          display: inline-block;
          width: 12px;
          height: 12px;
          border-radius: 50%;
          background-color: white;
          border: 2px solid #ddd;
        }

        .filter-toggle[data-category="entry"] .filter-dot {
          border-color: #037A33;
        }

        .filter-toggle[data-category="letter"] .filter-dot {
          border-color: #A63437;
        }

        .filter-toggle[data-category="gedruckt"] .filter-dot {
          border-color: rgb(101, 67, 33);
        }

        .filter-toggle[data-category="fischer"] .filter-dot {
          border-color: #3D4F9F;
        }

        .filter-toggle.active[data-category="entry"] {
          background: #037A33;
          color: white;
          border-color: #037A33;
        }

        .filter-toggle.active[data-category="letter"] {
          background: #A63437;
          color: white;
          border-color: #A63437;
        }

        .filter-toggle.active[data-category="gedruckt"] {
          background: rgb(101, 67, 33);
          color: white;
          border-color: rgb(101, 67, 33);
        }

        .filter-toggle.active[data-category="fischer"] {
          background: #3D4F9F;
          color: white;
          border-color: #3D4F9F;
        }

        .filter-toggle:not(.active) {
          opacity: 0.6;
        }

        .nav-btn {
          background: #f8f9fa;
          border: 1px solid #dee2e6;
          border-radius: 4px;
          padding: 6px 12px;
          cursor: pointer;
          font-size: 14px;
          min-width: 40px;
          box-sizing: border-box;
        }

        .nav-btn:hover {
          background: #e9ecef;
        }

        .period-title {
          margin: 0;
          font-size: 24px;
          font-weight: 600;
          color: #333;
        }

        .calendar-grid {
          display: grid;
          gap: 20px;
        }

        .calendar-grid.year-view {
          grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
        }

        .calendar-grid.month-view {
          grid-template-columns: 1fr;
          overflow-x: auto;
        }

        .calendar-grid.week-view {
          grid-template-columns: 1fr;
        }

        .month {
          border: 1px solid #dee2e6;
          border-radius: 8px;
          overflow: hidden;
          background: white;
        }

        .month-header {
          background: #f8f9fa;
          padding: 12px;
          text-align: center;
          font-weight: 600;
          color: #495057;
          border-bottom: 1px solid #dee2e6;
          transition: background-color 0.2s, color 0.2s;
        }

        .month-header:hover {
          background: #e9ecef;
          color: #007bff;
        }

        .month-days {
          display: grid;
          grid-template-columns: repeat(7, 1fr);
        }

        .day-header {
          background: #f8f9fa;
          padding: 8px 4px;
          text-align: center;
          font-size: 12px;
          font-weight: 500;
          color: #6c757d;
          border-bottom: 1px solid #dee2e6;
        }

        .day {
          position: relative;
          aspect-ratio: 1;
          border: 1px solid #f1f3f4;
          cursor: pointer;
          transition: background-color 0.2s;
          display: flex;
          flex-direction: column;
          justify-content: flex-start;
          align-items: center;
          padding: 4px 2px 2px 2px;
          min-height: 40px;
        }

        .day:hover {
          background-color: #f8f9fa;
        }

        .day.other-month {
          color: #adb5bd;
          background-color: #fafbfc;
        }

        .day.has-events {
          font-weight: 600;
        }

        .day-number {
          font-size: 13px;
          line-height: 1;
          margin-bottom: 3px;
          z-index: 2;
        }

        /* Kompakte Balken direkt unter der Ziffer */
        .event-bars {
          display: flex;
          flex-direction: column;
          gap: 1px;
          width: 100%;
          max-width: 24px;
        }

        .event-bar {
          height: 3px;
          width: 100%;
          border-radius: 1px;
        }

        .events-count {
          display: none !important;
        }

        /* Month view styles */
        .month-large {
          width: 100%;
          overflow-x: auto;
          border: 1px solid #dee2e6;
          border-radius: 8px;
          background: white;
        }

        .calendar-grid.month-view {
          overflow-x: auto;
          max-width: 100%;
        }

        /* Hide sidebar and expand calendar for month view */
        .calendar-grid.month-view ~ * #sidebar-col,
        body:has(.calendar-grid.month-view) #sidebar-col {
          display: none;
        }

        body:has(.calendar-grid.month-view) #calendar-col {
          flex: 0 0 100%;
          max-width: 100%;
        }


        .month-large .month-header {
          background: #f8f9fa;
          padding: 12px;
          text-align: center;
          font-weight: 600;
          color: #495057;
          border-bottom: 1px solid #dee2e6;
        }

        .month-days-large {
          display: grid;
          grid-template-columns: repeat(7, minmax(135px, 1fr));
          gap: 1px;
          background: #dee2e6;
          min-width: 945px;
        }

        .day-header-large {
          background: #f8f9fa;
          padding: 12px;
          text-align: center;
          font-weight: 600;
          color: #495057;
          font-size: 14px;
        }

        .day-large {
          min-height: 140px;
          background: white;
          padding: 8px;
          display: flex;
          flex-direction: column;
          cursor: pointer;
          transition: background-color 0.2s;
        }

        .day-large:hover {
          background: #f8f9fa;
        }

        .day-large.other-month {
          background: #fafbfc;
          color: #adb5bd;
        }

        .day-number-large {
          font-weight: 600;
          margin-bottom: 6px;
          font-size: 16px;
        }

        .events-container-large {
          flex: 1;
          display: flex;
          flex-direction: column;
          gap: 2px;
          overflow: hidden;
        }

        .event-item-large {
          background: #007bff;
          color: white;
          padding: 4px 6px;
          border-radius: 3px;
          font-size: 11px;
          line-height: 1.3;
          cursor: pointer;
          white-space: normal;
          word-wrap: break-word;
          word-break: break-word;
          hyphens: auto;
          min-height: 20px;
          max-height: none;
          border: 1px solid rgba(255,255,255,0.2);
          display: block;
        }

        .event-item-large:hover {
          opacity: 0.8;
        }

        .more-events-large {
          font-size: 10px;
          color: #6c757d;
          font-style: italic;
          margin-top: 2px;
        }

        /* Week view styles */
        .week-view {
          width: 100%;
          border: 1px solid #dee2e6;
          border-radius: 8px;
          background: white;
          overflow: hidden;
        }

        .week-days-header {
          display: grid;
          grid-template-columns: repeat(7, 1fr);
          gap: 1px;
          background: #dee2e6;
        }

        .week-day-header {
          background: #f8f9fa;
          padding: 12px;
          text-align: center;
        }

        .week-day-name {
          font-weight: 600;
          color: #495057;
          font-size: 14px;
        }

        .week-day-date {
          font-size: 12px;
          color: #6c757d;
          margin-top: 4px;
        }

        .week-days-container {
          display: grid;
          grid-template-columns: repeat(7, 1fr);
          gap: 1px;
          background: #dee2e6;
          min-height: 500px;
        }

        .week-day-column {
          background: white;
          padding: 8px;
          display: flex;
          flex-direction: column;
          gap: 4px;
        }

        .week-event {
          background: #007bff;
          color: white;
          padding: 6px 8px;
          border-radius: 4px;
          font-size: 12px;
          cursor: pointer;
          white-space: normal;
          word-wrap: break-word;
          word-break: break-word;
          hyphens: auto;
          line-height: 1.4;
          min-height: 24px;
          border: 1px solid rgba(255,255,255,0.2);
          transition: opacity 0.2s;
          display: block;
        }

        .week-event:hover {
          opacity: 0.8;
        }

        .week-entities {
          margin-top: 8px;
          padding-top: 8px;
          border-top: 1px dashed #dee2e6;
          display: flex;
          flex-direction: column;
          gap: 6px;
        }

        .week-entity-group {
          display: flex;
          flex-direction: column;
          gap: 2px;
        }

        .week-entity-label {
          font-size: 10px;
          font-weight: 600;
          text-transform: uppercase;
          letter-spacing: 0.02em;
          color: #6c757d;
        }

        .week-entity-link {
          font-size: 12px;
          color: #495057;
          text-decoration: none;
        }

        .week-entity-link:hover {
          text-decoration: underline;
          color: #007bff;
        }

        /* Responsive design */
        @media (max-width: 1400px) {
          .calendar-grid.year-view {
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
          }
        }

        @media (max-width: 900px) {
          .calendar-grid.year-view {
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
          }
        }

        @media (max-width: 600px) {
          .calendar-grid.year-view {
            grid-template-columns: 1fr;
          }
        }
      `;
      document.head.appendChild(style);
    }
  }

  createDropdownNavigation() {
    const dropdownContainer = this.container.querySelector('.period-dropdowns');

    // Clear existing dropdowns
    dropdownContainer.innerHTML = '';

    // Month dropdown for month view goes left of the year dropdown
    if (this.currentView === 'month') {
      this.createMonthDropdown(dropdownContainer);
    }

    // Year dropdown for all views
    this.createYearDropdown(dropdownContainer);

    // Week dropdown for week view
    if (this.currentView === 'week') {
      this.createWeekDropdown(dropdownContainer);
    }
  }

  createYearDropdown(container) {
    const yearSelect = document.createElement('select');
    yearSelect.className = 'period-dropdown year-dropdown';

    // Use pre-calculated available years
    this.availableYears.forEach(year => {
      const option = document.createElement('option');
      option.value = year;
      option.textContent = year;
      option.selected = year === this.currentYear;
      yearSelect.appendChild(option);
    });

    yearSelect.addEventListener('change', (e) => {
      this.currentYear = parseInt(e.target.value);
      this.renderCalendar();
      this.updateURL();
    });

    container.appendChild(yearSelect);
  }

  createMonthDropdown(container) {
    const monthSelect = document.createElement('select');
    monthSelect.className = 'period-dropdown month-dropdown';

    this.monthNames.forEach((monthName, index) => {
      const option = document.createElement('option');
      option.value = index;
      option.textContent = monthName;
      option.selected = index === this.currentMonth;
      monthSelect.appendChild(option);
    });

    monthSelect.addEventListener('change', (e) => {
      this.currentMonth = parseInt(e.target.value);
      this.renderCalendar();
      this.updateURL();
    });

    container.appendChild(monthSelect);
  }

  createWeekDropdown(container) {
    const weekSelect = document.createElement('select');
    weekSelect.className = 'period-dropdown week-dropdown';

    for (let week = 1; week <= 53; week++) {
      const option = document.createElement('option');
      option.value = week;
      const weekStart = this.getWeekStart(this.currentYear, week);
      const weekEnd = this.addDays(weekStart, 6);
      option.textContent = `Woche ${week} (${weekStart.getDate()}.${weekStart.getMonth() + 1}. - ${weekEnd.getDate()}.${weekEnd.getMonth() + 1}.)`;
      option.selected = week === this.currentWeek;
      weekSelect.appendChild(option);
    }

    weekSelect.addEventListener('change', (e) => {
      this.currentWeek = parseInt(e.target.value);
      this.renderCalendar();
      this.updateURL();
    });

    container.appendChild(weekSelect);
  }

  getPeriodTitle() {
    if (this.currentView === 'year') {
      return this.currentYear.toString();
    } else if (this.currentView === 'month') {
      return `${this.monthNames[this.currentMonth]} ${this.currentYear}`;
    } else if (this.currentView === 'week') {
      const weekStart = this.getWeekStart(this.currentYear, this.currentWeek);
      const weekEnd = this.addDays(weekStart, 6);
      return `${weekStart.getDate()}.${weekStart.getMonth() + 1}. - ${weekEnd.getDate()}.${weekEnd.getMonth() + 1}.${weekEnd.getFullYear()}`;
    }
  }

  navigatePeriod(direction) {
    if (this.currentView === 'year') {
      // Navigate to next/previous available year
      const currentIndex = this.availableYears.indexOf(this.currentYear);
      const newIndex = currentIndex + direction;

      // Only navigate if there is a next/previous year
      if (newIndex >= 0 && newIndex < this.availableYears.length) {
        this.currentYear = this.availableYears[newIndex];
      }
    } else if (this.currentView === 'month') {
      this.currentMonth += direction;
      if (this.currentMonth > 11) {
        this.currentMonth = 0;
        // Navigate to next available year
        const currentIndex = this.availableYears.indexOf(this.currentYear);
        if (currentIndex + 1 < this.availableYears.length) {
          this.currentYear = this.availableYears[currentIndex + 1];
        }
      } else if (this.currentMonth < 0) {
        this.currentMonth = 11;
        // Navigate to previous available year
        const currentIndex = this.availableYears.indexOf(this.currentYear);
        if (currentIndex - 1 >= 0) {
          this.currentYear = this.availableYears[currentIndex - 1];
        }
      }
    } else if (this.currentView === 'week') {
      this.currentWeek += direction;
      if (this.currentWeek > 52) {
        this.currentWeek = 1;
        // Navigate to next available year
        const currentIndex = this.availableYears.indexOf(this.currentYear);
        if (currentIndex + 1 < this.availableYears.length) {
          this.currentYear = this.availableYears[currentIndex + 1];
        }
      } else if (this.currentWeek < 1) {
        this.currentWeek = 52;
        // Navigate to previous available year
        const currentIndex = this.availableYears.indexOf(this.currentYear);
        if (currentIndex - 1 >= 0) {
          this.currentYear = this.availableYears[currentIndex - 1];
        }
      }
    }
    this.renderCalendar();
    this.updateURL();
  }

  switchView(view) {
    const previousView = this.currentView;
    this.currentView = view;

    // When switching from year to month view, always go to January (month 0)
    if (previousView === 'year' && view === 'month') {
      this.currentMonth = 0; // Januar = 0
    }

    // When switching from year to week view, always go to first week of year
    if (previousView === 'year' && view === 'week') {
      this.currentWeek = 1; // Erste Kalenderwoche = 1
    }

    // Update view button states
    this.container.querySelectorAll('.view-btn').forEach(btn => {
      btn.classList.remove('active');
      if (btn.dataset.view === view) {
        btn.classList.add('active');
      }
    });

    this.renderCalendar();
    this.updateURL();
  }

  render() {
    this.renderCalendar();
  }

  renderCalendar() {
    const grid = this.container.querySelector('.calendar-grid');
    grid.innerHTML = '';

    // Remove all view classes and add current view
    grid.className = `calendar-grid ${this.currentView}-view`;

    // Update dropdown navigation for current view
    this.createDropdownNavigation();

    switch(this.currentView) {
      case 'year':
        this.renderYearView(grid);
        break;
      case 'month':
        this.renderMonthView(grid);
        break;
      case 'week':
        this.renderWeekView(grid);
        break;
    }
  }

  renderYearView(grid) {
    // Filter events by enabled categories and current year
    const filteredEvents = this.events.filter(event => {
      const eventDate = new Date(event.startDate);
      const eventYear = eventDate.getFullYear();

      return eventYear === this.currentYear &&
             this.isEventVisible(event);
    });

    // Group events by date
    const eventsByDate = {};
    filteredEvents.forEach(event => {
      const date = event.startDate;
      if (!eventsByDate[date]) {
        eventsByDate[date] = [];
      }
      eventsByDate[date].push(event);
    });

    // Render 12 months
    for (let month = 0; month < 12; month++) {
      const monthEl = this.createMonth(month, eventsByDate);
      grid.appendChild(monthEl);
    }
  }

  renderMonthView(grid) {
    // Filter events by enabled categories, current year and month
    const filteredEvents = this.events.filter(event => {
      const eventDate = new Date(event.startDate);

      return eventDate.getFullYear() === this.currentYear &&
             eventDate.getMonth() === this.currentMonth &&
             this.isEventVisible(event);
    });

    // Group events by date
    const eventsByDate = {};
    filteredEvents.forEach(event => {
      const date = event.startDate;
      if (!eventsByDate[date]) {
        eventsByDate[date] = [];
      }
      eventsByDate[date].push(event);
    });

    const monthEl = this.createLargeMonth(this.currentMonth, eventsByDate);
    grid.appendChild(monthEl);
  }

  renderWeekView(grid) {
    // Filter events by enabled categories and current week
    const filteredEvents = this.events.filter(event => {
      const eventDate = new Date(event.startDate);
      const weekOfYear = this.getWeekOfYear(eventDate);

      return eventDate.getFullYear() === this.currentYear &&
             weekOfYear === this.currentWeek &&
             this.isEventVisible(event);
    });

    // Group events by date
    const eventsByDate = {};
    filteredEvents.forEach(event => {
      const date = event.startDate;
      if (!eventsByDate[date]) {
        eventsByDate[date] = [];
      }
      eventsByDate[date].push(event);
    });

    const weekEl = this.createWeekView(this.currentYear, this.currentWeek, eventsByDate);
    grid.appendChild(weekEl);
  }

  createMonth(monthIndex, eventsByDate) {
    const monthEl = document.createElement('div');
    monthEl.className = 'month';

    // Month header
    const headerEl = document.createElement('div');
    headerEl.className = 'month-header';
    headerEl.textContent = `${this.monthNames[monthIndex]} ${this.currentYear}`;
    headerEl.style.cursor = 'pointer';
    headerEl.title = `Zu ${this.monthNames[monthIndex]} ${this.currentYear} wechseln`;

    // Add click handler to switch to month view
    headerEl.addEventListener('click', (e) => {
      e.stopPropagation();
      this.currentMonth = monthIndex;
      this.switchView('month');
    });

    monthEl.appendChild(headerEl);

    // Days container
    const daysEl = document.createElement('div');
    daysEl.className = 'month-days';

    // Day headers
    this.dayNames.forEach(dayName => {
      const dayHeaderEl = document.createElement('div');
      dayHeaderEl.className = 'day-header';
      dayHeaderEl.textContent = dayName;
      daysEl.appendChild(dayHeaderEl);
    });

    // Days
    const firstDay = new Date(this.currentYear, monthIndex, 1);
    const lastDay = new Date(this.currentYear, monthIndex + 1, 0);
    const firstWeekday = firstDay.getDay();
    const daysInMonth = lastDay.getDate();

    // Previous month padding
    const prevMonth = new Date(this.currentYear, monthIndex - 1, 0);
    for (let i = firstWeekday - 1; i >= 0; i--) {
      const dayEl = this.createDay(
        prevMonth.getDate() - i,
        monthIndex - 1 < 0 ? 11 : monthIndex - 1,
        monthIndex - 1 < 0 ? this.currentYear - 1 : this.currentYear,
        true,
        eventsByDate
      );
      daysEl.appendChild(dayEl);
    }

    // Current month days
    for (let day = 1; day <= daysInMonth; day++) {
      const dayEl = this.createDay(day, monthIndex, this.currentYear, false, eventsByDate);
      daysEl.appendChild(dayEl);
    }

    // Next month padding
    const cellsUsed = firstWeekday + daysInMonth;
    const cellsNeeded = Math.ceil(cellsUsed / 7) * 7;
    for (let day = 1; day <= cellsNeeded - cellsUsed; day++) {
      const dayEl = this.createDay(
        day,
        monthIndex + 1 > 11 ? 0 : monthIndex + 1,
        monthIndex + 1 > 11 ? this.currentYear + 1 : this.currentYear,
        true,
        eventsByDate
      );
      daysEl.appendChild(dayEl);
    }

    monthEl.appendChild(daysEl);
    return monthEl;
  }

  createDay(day, month, year, isOtherMonth, eventsByDate) {
    const dayEl = document.createElement('div');
    dayEl.className = 'day';
    if (isOtherMonth) dayEl.classList.add('other-month');

    const dayNumberEl = document.createElement('div');
    dayNumberEl.className = 'day-number';
    dayNumberEl.textContent = day;
    dayEl.appendChild(dayNumberEl);

    // Check for events on this day
    const dateStr = `${year}-${String(month + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    const dayEvents = eventsByDate[dateStr] || [];

    if (dayEvents.length > 0 && !isOtherMonth) {
      dayEl.classList.add('has-events');

      // Calculate background color based on event categories and count
      const backgroundColor = this.calculateDayBackgroundColor(dayEvents);
      if (backgroundColor) {
        dayEl.style.backgroundColor = backgroundColor;
      }

      const sortedEvents = this.sortDayEvents(dayEvents);

      // Create event bars
      const barsEl = document.createElement('div');
      barsEl.className = 'event-bars';

      sortedEvents.forEach(event => {
        const barEl = document.createElement('div');
        barEl.className = 'event-bar';
        barEl.style.backgroundColor = this.eventCategories[event.category] || '#999';
        barEl.title = event.name;
        barsEl.appendChild(barEl);
      });

      dayEl.appendChild(barsEl);

      // Add click handler for days with events (use sorted events)
      dayEl.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();

        const date = new Date(year, month, day);
        this.onDayClick({ events: sortedEvents, date: date, calendar: this });
      });
    }

    return dayEl;
  }

  calculateDayBackgroundColor(dayEvents) {
    if (!dayEvents || dayEvents.length === 0) return null;

    // Count events per category
    const categoryCounts = {
      'entry': 0,
      'letter': 0,
      'gedruckt': 0,
      'fischer': 0
    };

    dayEvents.forEach(event => {
      if (categoryCounts.hasOwnProperty(event.category)) {
        categoryCounts[event.category]++;
      }
    });

    // Parse RGB colors from hex
    const parseColor = (hex) => {
      // Handle both formats: #A63437 and rgb(101, 67, 33)
      if (hex.startsWith('rgb')) {
        const matches = hex.match(/\d+/g);
        return { r: parseInt(matches[0]), g: parseInt(matches[1]), b: parseInt(matches[2]) };
      }
      const r = parseInt(hex.slice(1, 3), 16);
      const g = parseInt(hex.slice(3, 5), 16);
      const b = parseInt(hex.slice(5, 7), 16);
      return { r, g, b };
    };

    // Calculate weighted average color
    let totalR = 0, totalG = 0, totalB = 0;
    let totalEvents = 0;

    Object.keys(categoryCounts).forEach(category => {
      const count = categoryCounts[category];
      if (count > 0) {
        const color = parseColor(this.eventCategories[category]);
        totalR += color.r * count;
        totalG += color.g * count;
        totalB += color.b * count;
        totalEvents += count;
      }
    });

    if (totalEvents === 0) return null;

    const avgR = Math.round(totalR / totalEvents);
    const avgG = Math.round(totalG / totalEvents);
    const avgB = Math.round(totalB / totalEvents);

    // Calculate opacity: 5% per event, max 25% at 5+ events
    const opacity = Math.min(0.05 + (totalEvents - 1) * 0.05, 0.25);

    return `rgba(${avgR}, ${avgG}, ${avgB}, ${opacity})`;
  }

  // Tagebucheintrag: interne Navigation. Brief/S. Fischer: externer Link.
  // Gedruckter Brief: keine eigene Edition, daher kein Link, stattdessen
  // die bibliographische Angabe anzeigen (siehe onPrintedLetterClick).
  handleEventClick(event) {
    if (event.category === 'entry') {
      window.location.href = event.linkId;
    } else if (event.category === 'gedruckt') {
      this.onPrintedLetterClick(event);
    } else if (event.linkId) {
      window.open(event.linkId, '_blank');
    }
  }

  // Bei gedruckten Briefen den bibliographischen Nachweis mit anzeigen,
  // da es dafür keine eigene Edition bzw. keinen Link gibt.
  getEventTooltip(event) {
    if (event.category === 'gedruckt' && event.bibliographic) {
      return `${event.name}\n${event.bibliographic}`;
    }
    return event.name;
  }

  // Tagebucheinträge stehen an einem Tag immer vor Briefen; innerhalb
  // derselben Kategorie wird nach tageszaehler sortiert.
  sortDayEvents(dayEvents) {
    return [...dayEvents].sort((a, b) => {
      const catA = this.categoryOrder[a.category] ?? 99;
      const catB = this.categoryOrder[b.category] ?? 99;
      if (catA !== catB) return catA - catB;
      const posA = parseInt(a.tageszaehler) || 999;
      const posB = parseInt(b.tageszaehler) || 999;
      return posA - posB;
    });
  }

  // Kalendertage zwischen zwei Terminen, unabhaengig von Zeitzone/Sommerzeit-
  // Umstellungen (die bei reiner Millisekunden-Differenz zwischen zwei
  // lokalen Date-Objekten zu Off-by-one-Fehlern fuehren koennen).
  daysBetween(a, b) {
    const utcA = Date.UTC(a.getFullYear(), a.getMonth(), a.getDate());
    const utcB = Date.UTC(b.getFullYear(), b.getMonth(), b.getDate());
    return Math.round((utcB - utcA) / 86400000);
  }

  // Kalendertag + n Tage, ueber die Datumsfelder (nicht ueber Millisekunden),
  // damit historische Zeitzonen-/Sommerzeit-Umstellungen keinen Tag verschieben.
  addDays(date, n) {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate() + n);
  }

  // Muss die exakte Umkehrung von getWeekStart sein, sonst landen Tage in der
  // falschen Kalenderwoche und fehlen dort in der Wochenansicht.
  getWeekOfYear(date) {
    const week1Start = this.getWeekStart(date.getFullYear(), 1);
    const diffDays = this.daysBetween(week1Start, date);
    return Math.floor(diffDays / 7) + 1;
  }

  getWeekStart(year, week) {
    // ISO week calculation: week starts on Monday
    const jan1 = new Date(year, 0, 1);
    const jan1Day = jan1.getDay(); // 0 = Sunday, 1 = Monday, etc.

    // Calculate days to first Monday of the year
    const daysToFirstMonday = jan1Day === 0 ? 1 : (8 - jan1Day);

    // Calculate the start of the requested week
    const weekStartDate = new Date(year, 0, 1 + daysToFirstMonday + (week - 2) * 7);

    return weekStartDate;
  }

  createLargeMonth(monthIndex, eventsByDate) {
    const monthEl = document.createElement('div');
    monthEl.className = 'month-large';

    // Month header
    const headerEl = document.createElement('div');
    headerEl.className = 'month-header';
    headerEl.textContent = `${this.monthNames[monthIndex]} ${this.currentYear}`;
    monthEl.appendChild(headerEl);

    // Days container
    const daysEl = document.createElement('div');
    daysEl.className = 'month-days-large';

    // Day headers
    this.dayNames.forEach(dayName => {
      const dayHeaderEl = document.createElement('div');
      dayHeaderEl.className = 'day-header-large';
      dayHeaderEl.textContent = dayName;
      daysEl.appendChild(dayHeaderEl);
    });

    // Days
    const firstDay = new Date(this.currentYear, monthIndex, 1);
    const lastDay = new Date(this.currentYear, monthIndex + 1, 0);
    const firstWeekday = firstDay.getDay();
    const daysInMonth = lastDay.getDate();

    // Previous month padding
    const prevMonth = new Date(this.currentYear, monthIndex - 1, 0);
    for (let i = firstWeekday - 1; i >= 0; i--) {
      const dayEl = this.createDayLarge(
        prevMonth.getDate() - i,
        monthIndex - 1 < 0 ? 11 : monthIndex - 1,
        monthIndex - 1 < 0 ? this.currentYear - 1 : this.currentYear,
        true,
        eventsByDate
      );
      daysEl.appendChild(dayEl);
    }

    // Current month days
    for (let day = 1; day <= daysInMonth; day++) {
      const dayEl = this.createDayLarge(day, monthIndex, this.currentYear, false, eventsByDate);
      daysEl.appendChild(dayEl);
    }

    // Next month padding
    const cellsUsed = firstWeekday + daysInMonth;
    const cellsNeeded = Math.ceil(cellsUsed / 7) * 7;
    for (let day = 1; day <= cellsNeeded - cellsUsed; day++) {
      const dayEl = this.createDayLarge(
        day,
        monthIndex + 1 > 11 ? 0 : monthIndex + 1,
        monthIndex + 1 > 11 ? this.currentYear + 1 : this.currentYear,
        true,
        eventsByDate
      );
      daysEl.appendChild(dayEl);
    }

    monthEl.appendChild(daysEl);
    return monthEl;
  }

  createDayLarge(day, month, year, isOtherMonth, eventsByDate) {
    const dayEl = document.createElement('div');
    dayEl.className = 'day-large';
    if (isOtherMonth) dayEl.classList.add('other-month');

    const dayNumberEl = document.createElement('div');
    dayNumberEl.className = 'day-number-large';
    dayNumberEl.textContent = day;
    dayEl.appendChild(dayNumberEl);

    const eventsContainer = document.createElement('div');
    eventsContainer.className = 'events-container-large';

    // Check for events on this day
    const dateStr = `${year}-${String(month + 1).padStart(2, '0')}-${String(day).padStart(2, '0')}`;
    const dayEvents = eventsByDate[dateStr] || [];

    if (dayEvents.length > 0 && !isOtherMonth) {
      const sortedEvents = this.sortDayEvents(dayEvents);

      sortedEvents.slice(0, 5).forEach(event => {
        const eventEl = document.createElement('div');
        eventEl.className = 'event-item-large';
        eventEl.style.backgroundColor = this.eventCategories[event.category] || '#999';
        eventEl.textContent = event.name;
        eventEl.title = this.getEventTooltip(event);
        eventEl.addEventListener('click', (e) => {
          e.stopPropagation();
          this.handleEventClick(event);
        });
        eventsContainer.appendChild(eventEl);
      });

      if (sortedEvents.length > 5) {
        const moreEl = document.createElement('div');
        moreEl.className = 'more-events-large';
        moreEl.textContent = `+${sortedEvents.length - 5} weitere`;
        eventsContainer.appendChild(moreEl);
      }

      // Add click handler for the day (use sorted events)
      dayEl.addEventListener('click', (e) => {
        e.preventDefault();
        e.stopPropagation();
        const date = new Date(year, month, day);
        this.onDayClick({ events: sortedEvents, date: date, calendar: this });
      });

      dayEl.style.cursor = 'pointer';
    }

    dayEl.appendChild(eventsContainer);
    return dayEl;
  }

  createWeekView(year, week, eventsByDate) {
    const weekEl = document.createElement('div');
    weekEl.className = 'week-view';

    const weekStart = this.getWeekStart(year, week);

    // Week days header
    const headerEl = document.createElement('div');
    headerEl.className = 'week-days-header';

    for (let i = 0; i < 7; i++) {
      const date = this.addDays(weekStart, i);
      const headerDay = document.createElement('div');
      headerDay.className = 'week-day-header';
      headerDay.innerHTML = `
        <div class="week-day-name">${this.dayNames[i]}</div>
        <div class="week-day-date">${date.getDate()}.${date.getMonth() + 1}.${date.getFullYear()}</div>
      `;
      headerEl.appendChild(headerDay);
    }

    weekEl.appendChild(headerEl);

    // Week days container
    const daysContainer = document.createElement('div');
    daysContainer.className = 'week-days-container';

    for (let i = 0; i < 7; i++) {
      const date = this.addDays(weekStart, i);
      const dateStr = `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
      const dayEvents = eventsByDate[dateStr] || [];

      const sortedEvents = this.sortDayEvents(dayEvents);

      const dayColumn = document.createElement('div');
      dayColumn.className = 'week-day-column';

      // Add events for this specific day
      sortedEvents.forEach(event => {
        const eventEl = document.createElement('div');
        eventEl.className = 'week-event';
        eventEl.style.backgroundColor = this.eventCategories[event.category] || '#999';
        eventEl.textContent = event.name;
        eventEl.title = this.getEventTooltip(event);
        eventEl.addEventListener('click', (e) => {
          e.stopPropagation();
          this.handleEventClick(event);
        });
        dayColumn.appendChild(eventEl);
      });

      // Erwähnte Personen/Orte/Werke dieses Tages
      const entities = (window.entitiesByDay && window.entitiesByDay[dateStr]) || null;
      if (entities && (entities.persons.length || entities.places.length || entities.works.length)) {
        const entitiesEl = document.createElement('div');
        entitiesEl.className = 'week-entities';

        [
          { label: 'Personen', items: entities.persons, color: this.entityColors.persons },
          { label: 'Orte', items: entities.places, color: this.entityColors.places },
          { label: 'Werke', items: entities.works, color: this.entityColors.works }
        ].forEach(group => {
          if (!group.items.length) return;

          const groupEl = document.createElement('div');
          groupEl.className = 'week-entity-group';

          const labelEl = document.createElement('div');
          labelEl.className = 'week-entity-label';
          labelEl.textContent = group.label;
          labelEl.style.color = group.color;
          groupEl.appendChild(labelEl);

          group.items.forEach(item => {
            const linkEl = document.createElement('a');
            linkEl.className = 'week-entity-link';
            linkEl.href = item.url;
            linkEl.textContent = item.name;
            groupEl.appendChild(linkEl);
          });

          entitiesEl.appendChild(groupEl);
        });

        dayColumn.appendChild(entitiesEl);
      }

      daysContainer.appendChild(dayColumn);
    }

    weekEl.appendChild(daysContainer);
    return weekEl;
  }

  loadStateFromURL() {
    const params = new URLSearchParams(window.location.search);
    if (params.has('year')) {
      this.currentYear = parseInt(params.get('year')) || this.currentYear;
    }
    if (params.has('month')) {
      // Convert from URL format (1-12) to internal format (0-11)
      const urlMonth = parseInt(params.get('month'));
      if (urlMonth >= 1 && urlMonth <= 12) {
        this.currentMonth = urlMonth - 1;
      }
    }
    if (params.has('week')) {
      this.currentWeek = parseInt(params.get('week')) || this.currentWeek;
    }
    if (params.has('view')) {
      this.currentView = params.get('view') || this.currentView;
    }
  }

  updateURL() {
    const params = new URLSearchParams(window.location.search);
    params.set('year', this.currentYear);

    if (this.currentView === 'month') {
      // Convert from internal format (0-11) to URL format (1-12)
      params.set('month', this.currentMonth + 1);
      params.delete('week');
    } else if (this.currentView === 'week') {
      params.set('week', this.currentWeek);
      params.delete('month');
    } else {
      params.delete('month');
      params.delete('week');
    }

    params.set('view', this.currentView);
    window.history.replaceState({}, '', `${window.location.pathname}?${params}`);
  }

  // Public API methods
  setYear(year) {
    this.currentYear = year;
    this.renderCalendar();
    this.updateURL();
  }

  getYear() {
    return this.currentYear;
  }

  setView(view) {
    if (['year', 'month', 'week'].includes(view)) {
      this.switchView(view);
    }
  }

  setDataSource(newData) {
    this.events = newData || [];
    this.renderCalendar();
  }
}
