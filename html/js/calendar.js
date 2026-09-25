// Calendar initialization for schnitzler-tagebuch-static
// Uses SimpleCalendar (Jahres-, Monats- und Wochenansicht) statt js-year-calendar.
// Bei mehreren Ereignissen an einem Tag oeffnet sich seitlich ein Auswahlfenster
// (Drawer), analog zu schnitzler-briefe-static.

document.addEventListener('DOMContentLoaded', function () {
  const data = calendarData.map(r => ({
    startDate: r.startDate,
    endDate: r.startDate,
    name: r.name,
    linkId: r.id,
    category: r.category,
    categoryLabel: r.categoryLabel,
    tageszaehler: r.tageszaehler,
    bibliographic: r.bibliographic
  }));

  window.activeFilters = new Set(['entry', 'letter', 'gedruckt', 'fischer']);
  window.entitiesByDay = typeof entitiesByDay !== 'undefined' ? entitiesByDay : {};

  function handleDayClick(e) {
    if (e.events.length === 1) {
      e.calendar.handleEventClick(e.events[0]);
      return;
    }
    openDayDrawer(e);
  }

  new SimpleCalendar('calendar', {
    startYear: 1900,
    dataSource: data,
    clickDay: handleDayClick
  });
});

/* ---------- Auswahlfenster (Drawer) bei mehreren Ereignissen an einem Tag ---------- */

function addDrawerStyles() {
  if (document.getElementById('calendar-drawer-styles')) return;
  const style = document.createElement('style');
  style.id = 'calendar-drawer-styles';
  style.textContent = `
    .cal-drawer-backdrop {
      position: fixed;
      inset: 0;
      background: rgba(0, 0, 0, 0.35);
      z-index: 1000;
      display: flex;
      justify-content: flex-end;
    }
    .cal-drawer {
      width: min(380px, 90vw);
      height: 100%;
      background: white;
      box-shadow: -4px 0 16px rgba(0, 0, 0, 0.2);
      display: flex;
      flex-direction: column;
      overflow-y: auto;
    }
    .cal-drawer-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      padding: 16px;
      border-bottom: 1px solid #dee2e6;
    }
    .cal-drawer-header h3 {
      margin: 0;
      font-size: 16px;
    }
    .cal-drawer-close {
      background: none;
      border: none;
      font-size: 22px;
      line-height: 1;
      cursor: pointer;
      color: #6c757d;
    }
    .cal-drawer-list {
      display: flex;
      flex-direction: column;
      gap: 10px;
      padding: 16px;
    }
    .cal-drawer-item {
      border-left: 4px solid #999;
      padding: 8px 12px;
      background: #f8f9fa;
      border-radius: 0 4px 4px 0;
    }
    .cal-drawer-item-clickable {
      cursor: pointer;
    }
    .cal-drawer-item-clickable:hover {
      background: #eef1f4;
    }
    .cal-drawer-item-title {
      font-weight: 600;
      font-size: 14px;
    }
    .cal-drawer-item-label {
      font-size: 12px;
      color: #6c757d;
      margin-top: 2px;
    }
    .cal-drawer-item-bibl {
      font-size: 12px;
      color: #495057;
      margin-top: 6px;
      font-style: italic;
    }
  `;
  document.head.appendChild(style);
}

function closeDayDrawer() {
  const existing = document.querySelector('.cal-drawer-backdrop');
  if (existing) existing.remove();
}

function openDayDrawer(e) {
  closeDayDrawer();
  addDrawerStyles();

  const backdrop = document.createElement('div');
  backdrop.className = 'cal-drawer-backdrop';
  backdrop.addEventListener('click', closeDayDrawer);

  const drawer = document.createElement('div');
  drawer.className = 'cal-drawer';
  drawer.addEventListener('click', ev => ev.stopPropagation());

  const header = document.createElement('div');
  header.className = 'cal-drawer-header';
  const dateLabel = e.date.toLocaleDateString('de-AT', {
    weekday: 'long', year: 'numeric', month: 'long', day: 'numeric'
  });
  const heading = document.createElement('h3');
  heading.textContent = dateLabel;
  const closeBtn = document.createElement('button');
  closeBtn.className = 'cal-drawer-close';
  closeBtn.setAttribute('aria-label', 'Schließen');
  closeBtn.textContent = '×';
  closeBtn.addEventListener('click', closeDayDrawer);
  header.appendChild(heading);
  header.appendChild(closeBtn);
  drawer.appendChild(header);

  const list = document.createElement('div');
  list.className = 'cal-drawer-list';

  e.calendar.sortDayEvents(e.events).forEach(event => {
    const item = document.createElement('div');
    item.className = 'cal-drawer-item';
    item.style.borderLeftColor = e.calendar.eventCategories[event.category] || '#999';

    const title = document.createElement('div');
    title.className = 'cal-drawer-item-title';
    title.textContent = event.name;
    item.appendChild(title);

    const label = document.createElement('div');
    label.className = 'cal-drawer-item-label';
    label.textContent = event.categoryLabel || e.calendar.categoryLabels[event.category] || '';
    item.appendChild(label);

    if (event.bibliographic) {
      const bibl = document.createElement('div');
      bibl.className = 'cal-drawer-item-bibl';
      bibl.textContent = event.bibliographic;
      item.appendChild(bibl);
    }

    if (event.category !== 'gedruckt') {
      item.classList.add('cal-drawer-item-clickable');
      item.addEventListener('click', () => e.calendar.handleEventClick(event));
    }

    list.appendChild(item);
  });

  drawer.appendChild(list);
  backdrop.appendChild(drawer);
  document.body.appendChild(backdrop);
  closeBtn.focus();
}

document.addEventListener('keydown', e => {
  if (e.key === 'Escape') closeDayDrawer();
});
