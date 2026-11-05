/* entity-tabs.js – Tab-Umschaltung auf Entitätsseiten */
document.addEventListener('DOMContentLoaded', function () {
    // Unterzeilen der Haupt-Tabs aus den Daten im DOM erzeugen
    function updateTabSubs() {
        var subM = document.querySelector('.entity-tab-btn .tab-sub[data-sub="mentions"]');
        if (subM) {
            var years = [];
            document.querySelectorAll('.mentions-by-year > .year-details:not([hidden]) .year-label')
                .forEach(function (el) { years.push(el.textContent.trim()); });
            if (!years.length) {
                subM.textContent = 'keine Erwähnungen';
            } else {
                years.sort();
                var n = years.length;
                subM.textContent = 'in ' + n + (n === 1 ? ' Jahr, ' : ' Jahren, ') +
                    (n === 1 ? years[0] : years[0] + '\u2013' + years[n - 1]);
            }
        }
        var subR = document.querySelector('.entity-tab-btn .tab-sub[data-sub="relations"]');
        if (subR) {
            var types = [];
            document.querySelectorAll('#tab-relationen .rel-subnav-btn').forEach(function (b) {
                var c = b.querySelector('.c');
                var t = b.textContent.replace(c ? c.textContent : '', '').trim();
                if (t) types.push(t);
            });
            subR.textContent = types.length
                ? types.slice(0, 3).join(', ') + (types.length > 3 ? ', \u2026' : '')
                : 'keine Relationen';
        }
    }
    updateTabSubs();
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
            if (buttons[next].classList.contains('is-empty') && !buttons[next].classList.contains('active')) return;
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
            if (btn.classList.contains('is-empty') && !btn.classList.contains('active')) return;
            activateTab(buttons, panels, btn, btn.getAttribute('data-tab'));
            var h = btn.getAttribute('data-hash');
            if (h && history.replaceState) history.replaceState(null, '', '#' + h);
        });
        wireTablistKeys(nav, buttons);
        function fromHash() {
            var h = location.hash.replace('#', '');
            var btn = buttons.filter(function (b) { return b.getAttribute('data-hash') === h; })[0];
            if (btn && !(btn.classList.contains('is-empty') && !btn.classList.contains('active'))) {
                activateTab(buttons, panels, btn, btn.getAttribute('data-tab'));
            }
        }
        fromHash();
        window.addEventListener('hashchange', fromHash);
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
    // Info-Popup neben dem Relationen-Tab: am ⓘ-Button ausrichten.
    // Das Popup ist position:fixed, damit es nicht vom overflow:hidden des
    // .entity-main abgeschnitten wird. Position daher hier berechnen.
    document.querySelectorAll('.relationen-info-popup').forEach(function (details) {
        var summary = details.querySelector('summary');
        var content = details.querySelector('.relationen-info-content');
        if (!summary || !content) return;
        var GAP = 4, MARGIN = 8;
        function position() {
            var r = summary.getBoundingClientRect();
            content.style.top = (r.bottom + GAP) + 'px';
            // Rechte Kante des Popups an der rechten Kante des Buttons ausrichten …
            var width = content.offsetWidth;
            var left = r.right - width;
            // … aber im Viewport halten.
            var maxLeft = window.innerWidth - width - MARGIN;
            if (left > maxLeft) left = maxLeft;
            if (left < MARGIN) left = MARGIN;
            content.style.left = left + 'px';
            content.style.right = 'auto';
        }
        details.addEventListener('toggle', function () {
            if (details.open) position();
        });
        window.addEventListener('resize', function () {
            if (details.open) position();
        });
        window.addEventListener('scroll', function () {
            if (details.open) position();
        }, true);
        // Klick außerhalb schließt das Popup.
        document.addEventListener('click', function (e) {
            if (details.open && !details.contains(e.target)) details.open = false;
        });
        // Esc schließt das Popup.
        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape' && details.open) details.open = false;
        });
    });
    // Leaflet-Karte in der Sidebar sofort initialisieren
    if (typeof window.initEntityMap === 'function') {
        window.initEntityMap();
    }
    // Mentions-Chart: Zoom auf Monate und Vollbild
    var mentionsChart = document.getElementById('mentions-chart');
    if (mentionsChart) initMentionsChart(mentionsChart);
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
        commentaryToggle.addEventListener('change', function () {
            applyCommentaryState();
            updateTabSubs();
        });
        applyCommentaryState();
        updateTabSubs();
    }
});

/* Erwähnungs-Chart: Klick auf ein Jahr zoomt auf dessen Monate, ⤢ schaltet das Vollbild.
   Die Jahresansicht kommt fertig aus entities.xsl (Template list-all-mentions), die
   Monatsansicht entsteht hier aus data-m und data-k. Zeichenfläche und Achsenstufen
   müssen mit der XSLT übereinstimmen. */
function initMentionsChart(chart) {
    var SVG_NS = 'http://www.w3.org/2000/svg';
    var LEFT = 50, RIGHT = 580, TOP = 14, BASE = 160, LABEL_Y = 175;
    var BAR_WIDTH = 18, BAR_RADIUS = 2, MIN_BAR_HEIGHT = 1.5, STACK_GAP = 1;
    var AXIS_STEPS = [1, 2, 5, 10, 20, 50, 100, 200, 500, 1000, 2000, 5000, 10000];
    var MONTHS = ['Jänner', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli', 'August',
        'September', 'Oktober', 'November', 'Dezember'];

    var svg = chart.querySelector('svg');
    var years = chart.querySelector('.chart-years');
    var range = chart.querySelector('.chart-range');
    // Noch nicht neu gebaute Seiten behalten ihr statisches Chart
    if (!years || !range) return;
    var toggle = document.getElementById('toggle-commentary-mentions');
    var overviewText = range.textContent;
    var zoomedCol = null;
    var monthsGroup = null;

    var back = document.createElement('button');
    back.type = 'button';
    back.className = 'mentions-chart-back';
    back.hidden = true;
    back.textContent = '← ' + overviewText;
    back.setAttribute('aria-label', 'Zurück zur Übersicht ' + overviewText);
    range.parentNode.insertBefore(back, range);
    var hint = document.createElement('span');
    hint.className = 'chart-hint';
    hint.textContent = 'Jahr wählen für Monatsansicht';
    range.parentNode.insertBefore(hint, range);
    var tip = document.createElement('div');
    tip.className = 'chart-tip';
    tip.hidden = true;
    chart.appendChild(tip);

    function commentaryVisible() {
        return !toggle || toggle.checked;
    }
    function shownCount(col) {
        return Number(col.dataset.text) + (commentaryVisible() ? Number(col.dataset.comment) : 0);
    }
    function mentionsLabel(n) {
        return n + ' Erwähnung' + (n === 1 ? '' : 'en');
    }
    function commentNote(col) {
        var k = commentaryVisible() ? Number(col.dataset.comment) : 0;
        return k ? ', davon ' + k + ' im Kommentar' : '';
    }
    function describeColumn(col) {
        col.setAttribute('aria-label', col.dataset.label + ': ' +
            mentionsLabel(shownCount(col)) + commentNote(col) +
            (col.classList.contains('year-col') ? '. Monate anzeigen' : ''));
    }
    // Spalten der aktuellen Ansicht; reine Kommentar-Jahre fallen bei ausgeblendetem Kommentar weg
    function columns() {
        var all = (monthsGroup || years).querySelectorAll('.chart-col');
        return Array.prototype.filter.call(all, function (col) {
            return commentaryVisible() || col.dataset.type !== 'commentary';
        });
    }
    // Das Diagramm ist ein einziger Tab-Stopp, die Pfeiltasten wechseln die Spalte
    function setTabStop(target) {
        columns().forEach(function (col) {
            col.setAttribute('tabindex', col === target ? '0' : '-1');
        });
    }

    function hideTip() {
        tip.hidden = true;
    }
    function showTip(col) {
        var n = shownCount(col);
        tip.textContent = '';
        tip.appendChild(document.createElement('b')).textContent = n;
        tip.appendChild(document.createTextNode(n === 1 ? ' Erwähnung' : ' Erwähnungen'));
        tip.appendChild(document.createElement('span')).textContent =
            col.dataset.label + commentNote(col);
        tip.hidden = false;
        var box = chart.getBoundingClientRect();
        var hit = col.querySelector('.chart-hit').getBoundingClientRect();
        var half = tip.offsetWidth / 2;
        var center = hit.left + hit.width / 2 - box.left;
        tip.style.left = Math.min(Math.max(center, half), box.width - half) + 'px';
        tip.style.top = (hit.top - box.top + chart.scrollTop) + 'px';
    }

    function addSvg(parent, name, attrs) {
        var node = parent.appendChild(document.createElementNS(SVG_NS, name));
        Object.keys(attrs).forEach(function (key) {
            node.setAttribute(key, attrs[key]);
        });
        return node;
    }
    function monthCounts(attr) {
        return attr
            ? attr.split(',').map(Number)
            : MONTHS.map(function () { return 0; });
    }
    // Balkensegment: unten eckig, oben optional abgerundet
    function addBar(col, className, x, y, height, radius) {
        var r = Math.min(radius, height);
        addSvg(col, 'path', {
            class: className,
            d: 'M' + x + ' ' + (y + height) + 'V' + (y + r) +
                'Q' + x + ' ' + y + ' ' + (x + r) + ' ' + y +
                'H' + (x + BAR_WIDTH - r) +
                'Q' + (x + BAR_WIDTH) + ' ' + y + ' ' + (x + BAR_WIDTH) + ' ' + (y + r) +
                'V' + (y + height) + 'Z'
        });
    }
    function drawMonths(animate) {
        if (monthsGroup) monthsGroup.remove();
        var withComments = commentaryVisible();
        var year = zoomedCol.dataset.year;
        var text = monthCounts(zoomedCol.dataset.m);
        var comment = monthCounts(zoomedCol.dataset.k);
        var totals = text.map(function (t, i) {
            return t + (withComments ? comment[i] : 0);
        });
        var peak = Math.max.apply(null, totals);
        var axisMax = Math.max(peak, 1);
        var step = AXIS_STEPS.filter(function (s) { return s * 4 >= axisMax; })[0];
        var axisTop = Math.ceil(axisMax / step) * step;
        var unit = (BASE - TOP) / axisTop;
        var band = (RIGHT - LEFT) / MONTHS.length;

        monthsGroup = addSvg(svg, 'g', { class: 'chart-months' });
        if (animate) {
            // Die Monate klappen aus der Position des gewählten Jahres auf
            var hit = zoomedCol.querySelector('.chart-hit');
            var originX = Number(hit.getAttribute('x')) + Number(hit.getAttribute('width')) / 2;
            monthsGroup.style.transformOrigin = originX + 'px ' + BASE + 'px';
            monthsGroup.classList.add('is-entering');
        }
        for (var tick = 0; tick <= axisTop; tick += step) {
            var tickY = BASE - tick * unit;
            addSvg(monthsGroup, 'line', {
                class: tick === 0 ? 'chart-baseline' : 'chart-grid',
                x1: LEFT, x2: RIGHT, y1: tickY, y2: tickY
            });
            addSvg(monthsGroup, 'text', {
                class: 'chart-tick', x: 44, y: tickY + 3.5, 'text-anchor': 'end'
            }).textContent = tick;
        }
        MONTHS.forEach(function (name, i) {
            var x = LEFT + i * band;
            var barX = x + (band - BAR_WIDTH) / 2;
            var col = addSvg(monthsGroup, 'g', {
                class: 'chart-col', role: 'img', tabindex: '-1',
                'data-label': name + ' ' + year,
                'data-text': text[i], 'data-comment': comment[i]
            });
            addSvg(col, 'rect', {
                class: 'chart-hit', x: x, y: TOP, width: band, height: BASE - TOP,
                fill: 'transparent'
            });
            var hasComment = withComments && comment[i] > 0;
            var barTop = BASE;
            if (text[i] > 0) {
                var textHeight = Math.max(MIN_BAR_HEIGHT, text[i] * unit);
                barTop -= textHeight;
                addBar(col, 'chart-bar', barX, barTop, textHeight, hasComment ? 0 : BAR_RADIUS);
            }
            if (hasComment) {
                var commentHeight = Math.max(MIN_BAR_HEIGHT, comment[i] * unit);
                barTop -= commentHeight + (text[i] > 0 ? STACK_GAP : 0);
                addBar(col, 'chart-bar chart-bar-k', barX, barTop, commentHeight, BAR_RADIUS);
            }
            // Nur der Höchstwert trägt eine Zahl, die übrigen zeigt der Tooltip
            if (peak > 0 && totals[i] === peak) {
                addSvg(col, 'text', {
                    class: 'chart-value', x: x + band / 2, y: barTop - 3, 'text-anchor': 'middle'
                }).textContent = peak;
            }
            addSvg(monthsGroup, 'text', {
                class: 'chart-tick', x: x + band / 2, y: LABEL_Y, 'text-anchor': 'middle'
            }).textContent = name.slice(0, 3);
            describeColumn(col);
        });
        setTabStop(monthsGroup.querySelector('.chart-col'));

        var shown = shownCount(zoomedCol);
        var undated = shown - totals.reduce(function (sum, n) { return sum + n; }, 0);
        range.textContent = year + ': ' + mentionsLabel(shown) + commentNote(zoomedCol) +
            (undated > 0 ? ' (' + undated + ' ohne Monatsangabe)' : '');
    }

    // Klappt das Jahr in der Liste unter dem Chart auf
    function openYearInList(year) {
        var target = null;
        document.querySelectorAll('.mentions-by-year > .year-details').forEach(function (details) {
            var isTarget = details.querySelector('.year-label').textContent.trim() === year;
            details.open = isTarget;
            if (isTarget) target = details;
        });
        if (target && !chart.classList.contains('is-fullscreen')) {
            target.querySelector('summary').scrollIntoView({ block: 'nearest' });
        }
    }
    function zoomIn(col) {
        zoomedCol = col;
        hideTip();
        chart.classList.add('is-zoomed');
        back.hidden = false;
        drawMonths(true);
        openYearInList(col.dataset.year);
        back.focus();
    }
    function zoomOut() {
        var col = zoomedCol;
        zoomedCol = null;
        hideTip();
        monthsGroup.remove();
        monthsGroup = null;
        chart.classList.remove('is-zoomed');
        back.hidden = true;
        range.textContent = overviewText;
        setTabStop(col);
        col.focus();
    }
    function setFullscreen(on) {
        hideTip();
        chart.classList.toggle('is-fullscreen', on);
        document.body.classList.toggle('mentions-chart-fs-open', on);
    }

    years.querySelectorAll('.chart-col').forEach(function (col) {
        var nativeTitle = col.querySelector('title');
        if (nativeTitle) nativeTitle.remove();
        col.dataset.label = col.dataset.year;
        col.setAttribute('role', 'button');
        describeColumn(col);
    });
    svg.setAttribute('role', 'group');
    setTabStop(columns()[0]);

    back.addEventListener('click', zoomOut);
    chart.querySelector('.mentions-chart-fs-btn').addEventListener('click', function () {
        setFullscreen(!chart.classList.contains('is-fullscreen'));
    });
    svg.addEventListener('click', function (e) {
        var col = e.target.closest('.year-col');
        if (col) zoomIn(col);
    });
    svg.addEventListener('keydown', function (e) {
        var col = e.target.closest('.chart-col');
        if (!col) return;
        if ((e.key === 'Enter' || e.key === ' ') && col.classList.contains('year-col')) {
            e.preventDefault();
            zoomIn(col);
            return;
        }
        var move = e.key === 'ArrowRight' ? 1 : e.key === 'ArrowLeft' ? -1 : 0;
        if (!move) return;
        e.preventDefault();
        var visible = columns();
        var next = visible[visible.indexOf(col) + move];
        if (next) {
            setTabStop(next);
            next.focus();
        }
    });
    document.addEventListener('keydown', function (e) {
        if (e.key !== 'Escape') return;
        var fullscreen = chart.classList.contains('is-fullscreen');
        if (zoomedCol && (fullscreen || chart.contains(document.activeElement))) {
            zoomOut();
        } else if (fullscreen) {
            setFullscreen(false);
        }
    });

    svg.addEventListener('pointerover', function (e) {
        var col = e.target.closest('.chart-col');
        if (col) showTip(col); else hideTip();
    });
    // Beim Antippen bleibt der Tooltip stehen, bis woanders hingetippt wird
    svg.addEventListener('pointerleave', function (e) {
        if (e.pointerType !== 'touch') hideTip();
    });
    document.addEventListener('pointerdown', function (e) {
        if (!svg.contains(e.target)) hideTip();
    });
    svg.addEventListener('focusin', function (e) {
        var col = e.target.closest('.chart-col');
        if (col && col.matches(':focus-visible')) showTip(col);
    });
    svg.addEventListener('focusout', hideTip);

    if (toggle) {
        toggle.addEventListener('change', function () {
            hideTip();
            years.querySelectorAll('.chart-col').forEach(describeColumn);
            if (zoomedCol) {
                if (shownCount(zoomedCol) > 0) drawMonths(false); else zoomOut();
            } else {
                setTabStop(columns()[0]);
            }
        });
    }
}
