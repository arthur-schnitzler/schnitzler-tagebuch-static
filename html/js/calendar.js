// Calendar initialization for schnitzler-tagebuch-static
// Uses SimpleCalendar (Jahres-, Monats- und Wochenansicht) statt js-year-calendar.

document.addEventListener('DOMContentLoaded', function () {
  const data = calendarData.map(r => ({
    startDate: r.startDate,
    endDate: r.startDate,
    name: r.name,
    linkId: r.id,
    category: r.category,
    tageszaehler: r.tageszaehler
  }));

  window.activeFilters = new Set(['entry', 'letter']);
  window.entitiesByDay = typeof entitiesByDay !== 'undefined' ? entitiesByDay : {};

  const startYear = Math.min(...data.map(e => new Date(e.startDate).getFullYear()));

  new SimpleCalendar('calendar', {
    startYear: startYear,
    dataSource: data,
    clickDay: function () {}
  });
});
