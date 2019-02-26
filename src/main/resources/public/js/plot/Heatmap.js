/* global Highcharts */

function drawDailyHeatMapPlot(plotVar, plotVarName, data, soilProfile, containerId, day, zoom, chart) {
    let daily = data["daily"];
    let max = data["max"][plotVar];
    let min = data["min"][plotVar];
    let avg = data["average"][plotVar];
    let med = data["median"][plotVar];
    let colorZoom = Math.abs((avg+med)/(max+min));
    if (isNaN(colorZoom)) {
        colorZoom = 1;
    }
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
    if (chart === undefined) {
        return drawHeatMapPlot(plotTitle, plotValTitle, plotData, max, min, soilProfile, containerId, colorZoom, zoom);
    } else {
        chart.series[0].setData(plotData);
        chart.setSize(null, zoom + "%");
        return chart;
    }
    
}

function drawHeatMapPlot(plotTitle, plotValTitle, plotData, max, min, soilProfile, containerId, colorZoom, zoom) {

    return Highcharts.chart(containerId, {

        chart: {
            type: 'heatmap',
            marginTop: 40,
            marginBottom: 60,
            plotBorderWidth: 1,
            height: zoom + '%'
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
        credits: {
            text: "dssat2d-plot.herokuapp.com",
            href: "http://dssat2d-plot.herokuapp.com/"
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
                    color: '#000000',
//                    format: '{point.value:.2f}'
                    formatter: function () {
                        let max = 4;
                        let val = this.point.value;
                        let numStr = val.toString().split(".");
                        
                        if (numStr.length < 2) {
                            return val;
                        } else {
                            let bit = Math.max(0, max - numStr[0].length);
                            bit = Math.min(bit, numStr[1].length);
                            return Number(this.point.value).toFixed(bit);
                        }
                    }
                }
            }]

    });
}