/* global Highcharts */

function drawDailyHeatMapPlot(plotVar, plotVarName, data, soilProfile, containerId, day, zoom) {
    let daily = data["daily"];
    let max = data["max"][plotVar];
    let min = data["min"][plotVar];
    let avg = data["average"][plotVar];
    let med = data["median"][plotVar];
    let colorZoom = Math.abs((avg+med)/(max+min));
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
    
//    console.log("max:" + max + " min:" + min + " average:" + avg + " median:" + med + " color zoom:" + colorZoom)
    
    drawHeatMapPlot(plotTitle, plotValTitle, plotData, max, min, soilProfile, containerId, colorZoom, zoom);
}

function drawHeatMapPlot(plotTitle, plotValTitle, plotData, max, min, soilProfile, containerId, colorZoom, zoom) {

    

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

        xAxis: {
            min: 1,
            softMax: soilProfile["totCols"],
            tickInterval: 1,
            gridLineWidth: 0,
            title: {
                text: 'Soil Column',
                align: 'low'
            }
        },
        yAxis: {
            min: 1,
            softMax: soilProfile["totRows"],
            tickInterval: 1,
            gridLineWidth:0,
            reversed: true,
            title: {
                text: 'Soil layers',
                align: 'low'
            }
        },

        colorAxis: {
            min: min * colorZoom,
            max: max * colorZoom,
            minColor: '#f7f7f7',
            maxColor: '#0275d8'
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