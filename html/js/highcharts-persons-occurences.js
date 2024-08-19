// External JavaScript file
function createChartFromXSLT(csvFilename) {
    const csvURL = `https://raw.githubusercontent.com/arthur-schnitzler/schnitzler-tagebuch-charts/main/tagebuch-vorkommen-jahr/${csvFilename}`;
    
    const chart = Highcharts.chart('container', {
        data: {
            csvURL,
            seriesMapping: [{
                x: 0, // Year
                y: 1 // Value
            }]
        },
        chart: {
            type: 'column',
            inverted: false,
            // Set legend to false to hide it
            legend: {
                enabled: false
            }
        },
        title: {
            text: 'Anzahl der Erwähnungen nach Jahr'
        },
        xAxis: {
            type: 'category' // Set x-axis type to category
        },
        yAxis: {
            title: {
                text: 'Anzahl'
            },
            allowDecimals: false // Ensure y-axis displays only integers
        },
        series: [{
            color: '#037A33'
        }]
    });
}
