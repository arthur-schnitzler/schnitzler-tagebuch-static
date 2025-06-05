function getYear(item) {
  return item.startDate.split('-')[0];
}


function createyearcell(val) {
  return (val !== undefined) ? `<div class="col-xs-6" style="width: auto;">\
  <button id="ybtn${val}" class="btn btn-light rounded-0 yearbtn" value="${val}" onclick="updateyear(this.value)">${val}</button>\
</div>` : '';
}

var data = calendarData.map(r =>
({
  startDate: new Date(r.startDate),
  endDate: new Date(r.startDate),
  name: r.name,
  linkId: r.id,
  color: '#6c757d'
})).filter(r => r.startDate.getFullYear() === 1890);

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
    //window.location = e.events[0].linkId;

    var entries = []
    $.each(e.events, function (key, entry) {
      entries.push(entry)
    });
    //window.location = ids.join();
    if (entries.length > 1) {
      let html = "<div class='modal fade' id='dialogForLinks' tabindex='-1' aria-labelledby='modalLabel' aria-hidden='true'>";
      html += "<div class='modal-dialog' role='document'>";
      html += "<div class='modal-content'>";
      html += "<div class='modal-header'>";
      html += "<h5 class='modal-title' id='modalLabel'>Links</h5>";
      html += "<button type='button' class='btn-close' data-bs-dismiss='modal' aria-label='Close'></button>";
      html += "</div><div class='modal-body'>";
      let numbersTitlesAndIds = new Array();
      for (let i = 0; i < entries.length; i++) {
        let linkTitle = entries[i].name;
        let linkId = entries[i].linkId;
        let numberInSeriesOfLetters = entries[i].tageszaehler;
        numbersTitlesAndIds.push({ 'i': i, 'position': numberInSeriesOfLetters, 'linkTitle': linkTitle, 'id': linkId });
      }

      numbersTitlesAndIds.sort(function (a, b) {
        let positionOne = parseInt(a.position);
        let positionTwo = parseInt(b.position);
        if (positionOne < positionTwo) {
          return -1;
        }
        if (positionOne > positionTwo) {
          return 1;
        }
        return 0;
      });
      for (let k = 0; k < numbersTitlesAndIds.length; k++) {
        html += "<div class='indent'><a href='" + numbersTitlesAndIds[k].id + "'>" + numbersTitlesAndIds[k].linkTitle + "</a></div>";
      }
      html += "</div>";
      html += "<div class='modal-footer'>";
      html += "<button type='button' class='btn btn-secondary' data-bs-dismiss='modal'>Schließen</button>";
      html += "</div></div></div></div>";
      $('#dialogForLinks').remove();
      $('#loadModal').append(html);
      $('#dialogForLinks').modal('show');

    }
    else { window.location = entries.map(entry => entry.linkId).join(); }
  },
  renderEnd: function (e) {
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
    color: '#A63437'
  })).filter(r => r.startDate.getFullYear() === parseInt(year));
  calendar.setDataSource(dataSource);
}