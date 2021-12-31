function getYear(item) {
  return item['startDate'].split('-')[0]
}

function createyearcell(val) {
  return (val !== undefined) ? '<div class="col-xs-6">\
          <button class="btn btn-light yearbtn" value="' + val + '" onclick="updateyear(this.value)">' + val + '</button>\
      </div>' : ''
}

var data = calendarData.map(r => ({
  startDate: new Date(r.startDate),
  endDate: new Date(r.startDate),
  name: r.name,
  linkId: r.id,
  color: '#037a33'
}));

years = Array.from(new Set(calendarData.map(getYear))).sort();
var yearsTable = document.getElementById('years-table');
for (var i = 0; i <= years.length; i++) {
  yearsTable.insertAdjacentHTML('beforeend', createyearcell(years[i]));
}

const calendar = new Calendar('#calendar', {
  startYear: 1888,
  language: "de",
  dataSource: data,
  clickDay: function (e) {
    window.location = e.events[0].linkId;
  },
});

function updateyear(year) {
  calendar.setYear(year);
}