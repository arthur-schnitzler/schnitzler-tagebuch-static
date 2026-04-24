/* entity-tabs.js – Tab-Umschaltung auf Entitätsseiten */
document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('.entity-tabs').forEach(function (nav) {
        nav.addEventListener('click', function (e) {
            var btn = e.target.closest('.entity-tab-btn');
            if (!btn) return;
            var tabId = btn.getAttribute('data-tab');
            var container = nav.parentElement;
            // Buttons
            nav.querySelectorAll('.entity-tab-btn').forEach(function (b) {
                b.classList.remove('active');
            });
            btn.classList.add('active');
            // Panels
            container.querySelectorAll('.entity-tab-panel').forEach(function (p) {
                p.classList.remove('active');
            });
            var panel = container.querySelector('#' + tabId);
            if (panel) panel.classList.add('active');
        });
    });
    // Relationen-Subnavigation (Typ-Tabs: Personen/Werke/Orte/…)
    document.querySelectorAll('.rel-subnav').forEach(function (subnav) {
        var container = subnav.parentElement;
        subnav.addEventListener('click', function (e) {
            var btn = e.target.closest('.rel-subnav-btn');
            if (!btn) return;
            var type = btn.getAttribute('data-rel-type');
            subnav.querySelectorAll('.rel-subnav-btn').forEach(function (b) {
                b.classList.remove('active');
            });
            btn.classList.add('active');
            container.querySelectorAll('.rel-section').forEach(function (s) {
                s.classList.toggle('active', s.getAttribute('data-rel-type') === type);
            });
        });
    });
    // Leaflet-Karte in der Sidebar sofort initialisieren
    if (typeof window.initEntityMap === 'function') {
        window.initEntityMap();
    }
    // Mentions-Chart: Vollbild-Umschaltung
    document.querySelectorAll('#mentions-chart').forEach(function (chart) {
        function toggle(on) {
            var active = typeof on === 'boolean'
                ? on
                : !chart.classList.contains('is-fullscreen');
            chart.classList.toggle('is-fullscreen', active);
            document.body.classList.toggle('mentions-chart-fs-open', active);
        }
        chart.addEventListener('click', function (e) {
            if (e.target.closest('.mentions-chart-fs-btn') ||
                e.target.closest('svg')) {
                toggle();
            }
        });
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' && chart.classList.contains('is-fullscreen')) {
                toggle(false);
            }
        });
    });
    // Kommentar-Toggle: blendet Kommentar-Erwähnungen aus und aktualisiert Jahresliste
    var commentaryToggle = document.getElementById('toggle-commentary-mentions');
    if (commentaryToggle) {
        var mentionsRoot = document.getElementById('mentions');
        function applyCommentaryState() {
            var showCommentary = commentaryToggle.checked;
            if (mentionsRoot) mentionsRoot.classList.toggle('hide-commentary', !showCommentary);
            var list = mentionsRoot && mentionsRoot.querySelector('.mentions-by-year');
            if (!list) return;
            var yearDetails = list.querySelectorAll(':scope > .year-details');
            var stats = [];
            yearDetails.forEach(function (details) {
                var lis = details.querySelectorAll('.year-content li');
                var visible = 0;
                lis.forEach(function (li) {
                    if (showCommentary || !li.classList.contains('mention-commentary')) visible++;
                });
                stats.push({ details: details, visible: visible });
            });
            var maxVisible = 1;
            stats.forEach(function (s) { if (s.visible > maxVisible) maxVisible = s.visible; });
            var totalMentions = 0, visibleYears = 0, firstVisible = null;
            stats.forEach(function (s) {
                var d = s.details, n = s.visible;
                if (n === 0) {
                    d.hidden = true;
                    d.removeAttribute('open');
                    return;
                }
                d.hidden = false;
                totalMentions += n;
                visibleYears++;
                if (!firstVisible) firstVisible = d;
                var entries = d.querySelector('.year-entries');
                if (entries) entries.textContent = n + ' Eintr' + (n === 1 ? 'ag' : 'äge');
                var countPill = d.querySelector('.year-count');
                if (countPill) countPill.textContent = n;
                var bar = d.querySelector('.year-bar i');
                if (bar) bar.style.width = Math.round(100 * n / maxVisible) + '%';
                d.querySelectorAll('.month-details').forEach(function (month) {
                    var monthLis = month.querySelectorAll('li');
                    var monthVisible = 0;
                    monthLis.forEach(function (li) {
                        if (showCommentary || !li.classList.contains('mention-commentary')) monthVisible++;
                    });
                    month.hidden = monthVisible === 0;
                });
            });
            if (firstVisible && !list.querySelector(':scope > .year-details[open]:not([hidden])')) {
                firstVisible.setAttribute('open', 'open');
            }
            var msMentions = mentionsRoot.querySelector('.ms-mentions');
            if (msMentions) {
                msMentions.innerHTML = '';
                var b = document.createElement('b');
                b.textContent = totalMentions;
                msMentions.appendChild(b);
                msMentions.appendChild(document.createTextNode(' Erwähnung' + (totalMentions === 1 ? '' : 'en')));
            }
            var msYears = mentionsRoot.querySelector('.ms-years');
            if (msYears) {
                msYears.innerHTML = '';
                var by = document.createElement('b');
                by.className = 'neutral';
                by.textContent = visibleYears;
                msYears.appendChild(by);
                msYears.appendChild(document.createTextNode(' Jahr' + (visibleYears === 1 ? '' : 'e')));
            }
        }
        commentaryToggle.addEventListener('change', applyCommentaryState);
        applyCommentaryState();
    }
});
