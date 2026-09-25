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

  function handleDayClick(e) {
    const entryEvent = e.events.find(ev => ev.category === 'entry');
    if (entryEvent) {
      window.location.href = entryEvent.linkId;
    } else if (e.events.length) {
      window.open(e.events[0].linkId, '_blank');
    }
  }

  new SimpleCalendar('calendar', {
    startYear: 1900,
    dataSource: data,
    clickDay: handleDayClick
  });
});
