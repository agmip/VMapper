/* global Highcharts */

function drawWaterVectorFluxPlot(data, soilProfile, containerId, day, zoom, chart) {
    var daily = data["daily"];
    var plotData = [];
    var plotTitle;
    var plotValTitle;
    plotTitle = "Soil Water Vector Flux Plot";
    plotValTitle = "Soil Water Vector Flux (cm3/cm3)";
    var WFluxH = daily[day]["WFluxH"];
    var WFluxV = daily[day]["WFluxV"];
    for (var i = 0; i < soilProfile["totRows"]; i++) {
        var limit = soilProfile["totCols"];
        if (i <= soilProfile["bedRows"]) {
            limit = soilProfile["bedCols"];
        }
        for (var j = 0; j < limit; j++) {
            var WFluxVct = Math.sqrt(Math.pow(WFluxH[i][j], 2) + Math.pow(WFluxV[i][j], 2));
            var WFluxDeg = getAngleDeg(WFluxV[i][j], WFluxH[i][j]);
            plotData.push([j + 1, i + 1, WFluxVct, WFluxDeg]);
        }
    }

//  console.log(plotData);

    if (chart === undefined) {
        return drawVectorFluxPlot(plotTitle, plotValTitle, plotData, soilProfile, containerId, zoom);
    } else {
        chart.series[0].update({vectorLength: zoom}, false);
        chart.series[0].setData(plotData, true, true, true);
        chart.setSize(null, zoom + "%");
        return chart;
    }
}

function drawNitroFluxVectorPlot(data, soilProfile, containerId, day, zoom, chart) {
    var daily = data["daily"];
    var plotData = [];
    var plotTitle;
    var plotValTitle;
    plotTitle = "Soil N Vector Flux Plot";
    plotValTitle = "Soil N Vector Flux";
    var NFluxR = daily[day]["NFluxR_D"];
    var NFluxL = daily[day]["NFluxL_D"];
    var NFluxD = daily[day]["NFluxD_D"];
    var NFluxU = daily[day]["NFluxU_D"];
    for (var i = 0; i < soilProfile["totRows"]; i++) {
        var limit = soilProfile["totCols"];
        if (i <= soilProfile["bedRows"]) {
            limit = soilProfile["bedCols"];
        }
        for (var j = 0; j < limit; j++) {
            let NFluxH = NFluxR[i][j] - NFluxL[i][j];
            let NFluxV = NFluxD[i][j] - NFluxU[i][j];
            var NFluxVct = Math.sqrt(Math.pow(NFluxH, 2) + Math.pow(NFluxV, 2));
            var NFluxDeg = getAngleDeg(NFluxV, NFluxH);
            plotData.push([j + 1, i + 1, NFluxVct, NFluxDeg]);
        }
    }

//  console.log(plotData);

    if (chart === undefined) {
        return drawVectorFluxPlot(plotTitle, plotValTitle, plotData, soilProfile, containerId, zoom);
    } else {
        chart.series[0].update({vectorLength: zoom}, false);
        chart.series[0].setData(plotData, true, true, true);
        chart.setSize(null, zoom + "%");
        return chart;
    }
    
}

function drawVectorFluxPlot(plotTitle, plotValTitle, plotData, soilProfile, containerId, zoom) {
    return Highcharts.chart(containerId, {
        title: {
            text: plotTitle
        },
        chart: {
            height: zoom + '%'
        },
        xAxis: {
            min: 1,
            softMax: soilProfile["totCols"],
            gridLineWidth: 1,
            tickInterval: 1,
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
            title: {
                text: 'Soil layers',
                align: 'low'
            }
        },
        credits: {
            text: "dssat2d-plot.herokuapp.com",
            href: "http://dssat2d-plot.herokuapp.com/"
        },

        tooltip: {
            formatter: function () {
                return  'Row : <b>' + this.point.y + '</b><br>' +
                        'Column : <b>' + this.point.x + '</b><br>' +
                        'Value :  <b>' + this.point.length.toFixed(3) + '</b><br>' +
                        'Direction : <b>' + this.point.direction.toFixed(1) + ' degree</b>';
            }
        },
        plotOptions: {
            series: {
                animation: false
            }
        },
        series: [{
                type: 'vector',
                name: plotValTitle,
                color: Highcharts.getOptions().colors[1],
                data: plotData,
                vectorLength: zoom
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