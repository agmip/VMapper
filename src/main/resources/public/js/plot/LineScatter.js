/* global Highcharts */

function drawSWV2DPlot(plotVar, plotVarName, data, containerId, cell, style, chart) {
    
    let subdaily = data["sim"]["subdaily"];
    let obvSubdaily = data["obv"]["subdaily"];
    let soilWatDaily = data["soilWat"]["subdaily"];
    let plotDataSim = [];
    let plotDataObv = [];
    let eventData = {PRED:[], IRRD:[]};
    let max = data["sim"]["max"][plotVar][cell.row][cell.col];
    let min = data["sim"]["min"][plotVar][cell.row][cell.col];
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
    if (obvSubdaily !== undefined) {
        for (var i = 0; i < obvSubdaily.length; i++) {
            if (obvSubdaily[i].TS < subdaily[end - 1].TS) {
                plotDataObv.push([obvSubdaily[i].TS, obvSubdaily[i][plotVar][cell.row][cell.col]]);
            }
        }
        if (data["obv"]["max"][plotVar][cell.row][cell.col]) {
            max = Math.max(max, data["obv"]["max"][plotVar][cell.row][cell.col]);
        }
        if (data["obv"]["min"][plotVar][cell.row][cell.col]) {
            min = Math.min(min, data["obv"]["min"][plotVar][cell.row][cell.col]);
        }
    }
    
    if (soilWatDaily !== undefined) {
        let incr;
        for (var i = 0; i < soilWatDaily.length; i++) {
//            eventData.PRED.push([soilWatDaily[i].TS, soilWatDaily[i].PRED]);
//            eventData.IRRD.push([soilWatDaily[i].TS, soilWatDaily[i].IRRD]);
            incr = soilWatDaily[i].INCR;
            if (incr === 0) {
                eventData.PRED.push([soilWatDaily[i].TS, soilWatDaily[i].PRED]);
                eventData.IRRD.push([soilWatDaily[i].TS, soilWatDaily[i].IRRD]);
            } else {
                eventData.PRED.push([soilWatDaily[i].TS, soilWatDaily[i].PRED/incr*1440]);
                eventData.IRRD.push([soilWatDaily[i].TS, soilWatDaily[i].IRRD/incr*1440]);
            }
        }
    }

//  console.log(plotData);

    return drawLineScatterPlot(
        plotTitle,
        plotVarName,
        {
            sim:plotDataSim,
            obv:plotDataObv,
            event:eventData,
            max:max,
            min:min
//            max:[max, data.soilWat.max.PRED, data.soilWat.max.IRRD],
//            min:[min, data.soilWat.min.PRED, data.soilWat.min.IRRD]
        },
        containerId);

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
            type: 'datetime',
//            tickInterval: 1000*3600*24,
//            title: {
//                text: "Date",
//                align: 'low'
//            },
            crosshair: true
        },
        yAxis: [{ // Primary Plot Variable yAxis
            min: plotData.min,
            max: plotData.max,
            title: {
                text: plotValTitle,
                style: {
                    color: Highcharts.getOptions().colors[0]
                }
            },
            labels: {
                style: {
                    color: Highcharts.getOptions().colors[0]
                }
            }
        },{ // Precipitation yAxis
            gridLineWidth: 0,
            title: {
                text: 'Precipitation (mm/d)',
                style: {
                    color: Highcharts.getOptions().colors[9]
                }
            },
            labels: {
                style: {
                    color: Highcharts.getOptions().colors[9]
                }
            },
            opposite: true

        }, { // Irrigation yAxis
            gridLineWidth: 0,
            title: {
                text: 'Irrigation (mm/d)',
                style: {
                    color: Highcharts.getOptions().colors[6]
                }
            },
            labels: {
                style: {
                    color: Highcharts.getOptions().colors[6]
                }
            },
            opposite: true
        }],
        credits: {
            text: "dssat2d-plot.herokuapp.com",
            href: "http://dssat2d-plot.herokuapp.com/"
        },

        tooltip: {
//            crosshairs: true,
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

        series: [
            {
                name: 'Precipitation (mm/d)',
                type: 'area',
                yAxis: 1,
                data: plotData.event.PRED,
                color: Highcharts.getOptions().colors[9]
            }, {
                name: 'Irrigation (mm/d)',
                type: 'area',
                yAxis: 2,
                data: plotData.event.IRRD,
                color: Highcharts.getOptions().colors[6]
            }, {
                type: 'line',
                name: plotValTitle,
                yAxis: 0,
                data: plotData.sim,
                color: Highcharts.getOptions().colors[0]
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
                name: 'Observed ' + plotValTitle,
                yAxis: 0,
                data: plotData.obv,
                color: Highcharts.getOptions().colors[1],
                marker: {
                    radius: 2
                },
                tooltip: {
                    headerFormat: '<span style="font-size: 10px">{point.x}</span><br/>',
                    pointFormat: '<span style="color:{point.color}">\u25CF</span> {series.name}: <b>{point.y}</b><br/>'
                }
            }
        ]
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