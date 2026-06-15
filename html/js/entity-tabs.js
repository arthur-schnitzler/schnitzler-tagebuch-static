/* entity-tabs.js – Tab-Umschaltung auf Entitätsseiten */
document.addEventListener('DOMContentLoaded', function () {
    function activateTab(buttons, panels, activeBtn, activePanelId) {
        buttons.forEach(function (b) {
            var on = b === activeBtn;
            b.classList.toggle('active', on);
            b.setAttribute('aria-selected', on ? 'true' : 'false');
            b.setAttribute('tabindex', on ? '0' : '-1');
        });
        panels.forEach(function (p) {
            p.classList.toggle('active', p.id === activePanelId);
        });
    }
    function wireTablistKeys(tablist, buttons) {
        tablist.addEventListener('keydown', function (e) {
            if (e.key !== 'ArrowLeft' && e.key !== 'ArrowRight' &&
                e.key !== 'Home' && e.key !== 'End') return;
            var current = document.activeElement;
            var idx = buttons.indexOf(current);
            if (idx === -1) return;
            var next = idx;
            if (e.key === 'ArrowLeft') next = (idx - 1 + buttons.length) % buttons.length;
            else if (e.key === 'ArrowRight') next = (idx + 1) % buttons.length;
            else if (e.key === 'Home') next = 0;
            else if (e.key === 'End') next = buttons.length - 1;
            buttons[next].focus();
            buttons[next].click();
            e.preventDefault();
        });
    }
    document.querySelectorAll('.entity-tabs').forEach(function (nav) {
        var container = nav.parentElement;
        var buttons = Array.prototype.slice.call(nav.querySelectorAll('.entity-tab-btn'));
        var panels = Array.prototype.slice.call(container.querySelectorAll('.entity-tab-panel'));
        nav.addEventListener('click', function (e) {
            var btn = e.target.closest('.entity-tab-btn');
            if (!btn) return;
            activateTab(buttons, panels, btn, btn.getAttribute('data-tab'));
        });
        wireTablistKeys(nav, buttons);
    });
    // Relationen-Subnavigation (Typ-Tabs: Personen/Werke/Orte/…)
    document.querySelectorAll('.rel-subnav').forEach(function (subnav) {
        var container = subnav.parentElement;
        var buttons = Array.prototype.slice.call(subnav.querySelectorAll('.rel-subnav-btn'));
        var sections = Array.prototype.slice.call(container.querySelectorAll('.rel-section'));
        subnav.addEventListener('click', function (e) {
            var btn = e.target.closest('.rel-subnav-btn');
            if (!btn) return;
            var type = btn.getAttribute('data-rel-type');
            buttons.forEach(function (b) {
                var on = b === btn;
                b.classList.toggle('active', on);
                b.setAttribute('aria-selected', on ? 'true' : 'false');
                b.setAttribute('tabindex', on ? '0' : '-1');
            });
            sections.forEach(function (s) {
                s.classList.toggle('active', s.getAttribute('data-rel-type') === type);
            });
        });
        wireTablistKeys(subnav, buttons);
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
