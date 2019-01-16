/* global Highcharts */

function drawDailyHeatMapPlot(plotVar, plotVarName, data, soilProfile, containerId, day, zoom) {
//    let plotTitle = "Sales per employee per weekday";
//    let plotValTitle = "Sales per employee";
//    let plotData = [[0, 0, 10], [0, 1, 19], [0, 2, 8], [0, 3, 24], [0, 4, 67], [1, 0, 92], [1, 1, 58], [1, 2, 78], [1, 3, 117], [1, 4, 48], [2, 0, 35], [2, 1, 15], [2, 2, 123], [2, 3, 64], [2, 4, 52], [3, 0, 72], [3, 1, 132], [3, 2, 114], [3, 3, 19], [3, 4, 16], [4, 0, 38], [4, 1, 5], [4, 2, 8], [4, 3, 117], [4, 4, 115], [5, 0, 88], [5, 1, 32], [5, 2, 12], [5, 3, 6], [5, 4, 120], [6, 0, 13], [6, 1, 44], [6, 2, 88], [6, 3, 98], [6, 4, 96], [7, 0, 31], [7, 1, 1], [7, 2, 82], [7, 3, 32], [7, 4, 30], [8, 0, 85], [8, 1, 97], [8, 2, 123], [8, 3, 64], [8, 4, 84], [9, 0, 47], [9, 1, 114], [9, 2, 31], [9, 3, 48], [9, 4, 91]];
    let daily = data["daily"];
    let max = data["max"][plotVar];
    let min = data["min"][plotVar];
    let plotData = [];
    let plotTitle;
    let plotValTitle;
    plotTitle = plotVarName + " Heatmap Plot";
    plotValTitle = plotVarName + " Heatmap Plot";
    let vals = daily[day][plotVar];
    for (let i = 0; i < soilProfile["totRows"]; i++) {
        let limit = soilProfile["totCols"];
        if (i <= soilProfile["bedRows"]) {
            limit = soilProfile["bedCols"];
        }
        for (let j = 0; j < limit; j++) {
            plotData.push([j + 1, i + 1, vals[i][j]]);
        }
    }
    
    drawHeatMapPlot(plotTitle, plotValTitle, plotData, max, min, soilProfile, containerId, zoom);
}

function drawHeatMapPlot(plotTitle, plotValTitle, plotData, max, min, soilProfile, containerId, zoom) {

    

    Highcharts.chart(containerId, {

        chart: {
            type: 'heatmap',
            marginTop: 40,
            marginBottom: 80,
            plotBorderWidth: 1
        },

        title: {
            text: plotTitle
        },

//        xAxis: {
//            categories: ['Alexander', 'Marie', 'Maximilian', 'Sophia', 'Lukas', 'Maria', 'Leon', 'Anna', 'Tim', 'Laura']
//        },
//
//        yAxis: {
//            categories: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
//            title: null
//        },


        xAxis: {
            min: 1,
            softMax: soilProfile["totCols"],
            gridLineWidth: 1,
            tickInterval: 1,
            gridLineWidth:0,
            title: {
                text: 'Soil Column',
                align: 'low'
            }
        },
        yAxis: {
            min: 1,
            softMax: soilProfile["totRows"],
            tickInterval: 1,
            reversed: true,
            gridLineWidth:0,
            title: {
                text: 'Soil layers',
                align: 'low'
            }
        },

        colorAxis: {
            min: min,
            max: max/10,
            minColor: '#DBE5F1',
            maxColor: '#00B0F0'
//            maxColor: Highcharts.getOptions().colors[0]
        },

        legend: {
            align: 'right',
            layout: 'vertical',
            margin: 0,
            verticalAlign: 'top',
            y: 25,
            symbolHeight: 280
        },

        tooltip: {
            formatter: function () {
                return  'Row : <b>' + this.point.y + '</b><br>' +
                        'Column : <b>' + this.point.x + '</b><br>' +
                        'Value :  <b>' + Number(this.point.value).toFixed(3) + '</b>';
            }
        },

        series: [{
                name: plotValTitle,
                borderWidth: 1,
                data: plotData,
                dataLabels: {
                    enabled: true,
                    color: '#000000'
                }
            }]

    });
}