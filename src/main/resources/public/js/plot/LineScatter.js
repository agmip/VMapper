/* global Highcharts */

function drawSWV2DPlot(plotVar, plotVarName, data, obvData, containerId, cell, style, chart) {
    let subdaily = data["subdaily"];
    let obvSubdaily = obvData["subdaily"];
    let plotDataSim = [];
    let plotDataObv = [];
    let max = data["max"][plotVar];
    let min = data["min"][plotVar];
    let plotTitle = "Time series Plot";
    let start, end;
    if (style === undefined || style === "full") {
        start = 1;
        end = subdaily.length;
    } else if (style === "first") {
        start = 1;
        end = Number((subdaily.length/2).toFixed(0));
    } else if (style === "last") {
        start = Number((subdaily.length/2).toFixed(0));
        end = subdaily.length;
    }
    for (var i = start; i < end; i++) {
        plotDataSim.push([subdaily[i].TS, subdaily[i][plotVar][cell.row][cell.col]]);
    }
    for (var i = 0; i < obvSubdaily.length; i++) {
        if (obvSubdaily[i].TS < subdaily[end - 1].TS) {
            plotDataObv.push([obvSubdaily[i].TS, obvSubdaily[i][plotVar][cell.row][cell.col]]);
        }
    }

//  console.log(plotData);

    return drawLineScatterPlot(plotTitle, plotVarName, {sim:plotDataSim, obv:plotDataObv, max:max, min:min}, containerId);

//    if (chart === undefined) {
//        return drawLineScatterPlot(plotTitle, plotValTitle, {sim:plotDataSim, obv:plotDataObv}, containerId, zoom);
//    } else {
//        chart.series[0].setData([plotDataSim, plotDataObv], true, true, true);
//        return chart;
//    }
}

function drawLineScatterPlot(plotTitle, plotValTitle, plotData, containerId) {
    return Highcharts.chart(containerId, {
        title: {
            text: plotTitle
        },
        chart: {
            height: 500,
            zoomType: 'x'
        },
        xAxis: {
//            gridLineWidth: 1,
            type: 'datetime',
            tickInterval: 1000*3600*24,
            title: {
                text: 'Date Time',
                align: 'low'
            }
        },
        yAxis: {
            min: plotData.min,
            max: plotData.max,
//            tickInterval: 1,
//            reversed: true,
//            title: {
//                text: 'Soil layers',
//                align: 'low'
//            }
        },
        credits: {
            text: "dssat2d-plot.herokuapp.com",
            href: "http://dssat2d-plot.herokuapp.com/"
        },

        tooltip: {
            crosshairs: true,
            shared: true,
            split: true,
            distance: 30,
            padding: 5
//            formatter: function () {
//                return  'Row : <b>' + this.point.y + '</b><br>' +
//                        'Column : <b>' + this.point.x + '</b><br>' +
//                        'Value :  <b>' + this.point.length.toFixed(3) + '</b><br>' +
//                        'Direction : <b>' + this.point.direction.toFixed(1) + ' degree</b>';
//            }
        },

//        plotOptions: {
//            series: {
//                animation: false
//            }
//        },

        series: [{
                    type: 'line',
                    name: plotValTitle,
                    data: plotData.sim
//                    marker: {
//                        enabled: false
//                    },
//                    states: {
//                        hover: {
//                            lineWidth: 0
//                        }
//                    },
//                    enableMouseTracking: false
                }, {
                    type: 'scatter',
                    name: plotValTitle + '_obv',
                    data: plotData.obv,
                    marker: {
                        radius: 2
                    },
                    tooltip: {
                        headerFormat: '<span style="font-size: 10px">{point.x}</span><br/>',
                        pointFormat: '<span style="color:{point.color}">\u25CF</span> {series.name}: <b>{point.y}</b><br/>'
                    }
                }]
    });
}

function getAngleDeg(a, b) {
    var angleRad = Math.atan(Math.abs(a / b));
    var angleDeg = angleRad * 180 / Math.PI;
    if (a >= 0 && b >= 0) {
        angleDeg = 270 + angleDeg;
    } else if (a >= 0 && b < 0) {
        angleDeg = 90 - angleDeg;
    } else if (a < 0 && b >= 0) {
        angleDeg = 270 - angleDeg;
    } else {
        angleDeg = 90 + angleDeg;
    }
    return angleDeg;
}