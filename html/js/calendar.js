function getYear(item) {
  return item['startDate'].split('-')[0]
}

function createyearcell(val) {
  return (val !== undefined) ? `<div class="col-xs-6">\
  <button id="ybtn${val}" class="btn btn-light rounded-0 yearbtn" value="${val}" onclick="updateyear(this.value)">${val}</button>\
</div>` : '';
}

var data = calendarData.map(r =>
({
  startDate: new Date(r.startDate),
  endDate: new Date(r.startDate),
  name: r.name,
  linkId: r.id,
  color: '#037a33'
})).filter(r => r.startDate.getFullYear() === 1900);




years = Array.from(new Set(calendarData.map(getYear))).sort();
var yearsTable = document.getElementById('years-table');
for (var i = 0; i <= years.length; i++) {
  yearsTable.insertAdjacentHTML('beforeend', createyearcell(years[i]));
}

//document.getElementById("ybtn1900").classList.add("focus");

const calendar = new Calendar('#calendar', {
  startYear: 1900,
  language: "de",
  dataSource: data,
  displayHeader: false,
  clickDay: function (e) {
    window.location = e.events[0].linkId;
  },
  renderEnd: function(e) {
    const buttons = document.querySelectorAll(".yearbtn");
    for (var i = 0; i < buttons.length; i++) {
      buttons[i].classList.remove('focus');
   }
    document.getElementById(`ybtn${e.currentYear}`).classList.add("focus");
}
});

function updateyear(year) {
  calendar.setYear(year);
  const dataSource = calendarData.map(r =>
  ({
    startDate: new Date(r.startDate),
    endDate: new Date(r.startDate),
    name: r.name,
    linkId: r.id,
    color: '#037a33'
  })).filter(r => r.startDate.getFullYear() === parseInt(year));
  calendar.setDataSource(dataSource);
}