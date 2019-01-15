
<!DOCTYPE html>
<html>
    <head>
        <#include "../header.ftl">
        <script src="https://code.highcharts.com/highcharts.js"></script>
	<script src="https://code.highcharts.com/modules/vector.js"></script>
	<script src="https://code.highcharts.com/modules/exporting.js"></script>
        <script>
            var reader;
            var data;
            var soilProfile;
            var titles;
            var zoom = 50;
            
            function abortRead() {
                if (reader !== undefined) {
                    reader.abort();
                }
            }
            
            function errorHandler(evt) {
                switch(evt.target.error.code) {
                    case evt.target.error.NOT_FOUND_ERR:
                        alert('File Not Found!');
                        break;
                    case evt.target.error.NOT_READABLE_ERR:
                        alert('File is not readable');
                        break;
                    case evt.target.error.ABORT_ERR:
                        break; // noop
                    default:
                         alert('An error occurred reading this file.');
                };
            }
            
            function updateProgress(progressVal) {
                var pct = (Number(progressVal) * 100).toFixed(1) + "%";
                progress.style.width = pct;
                progress.textContent = pct;
                if (progressVal >= 1 || progressVal < 0) {
                    document.getElementById('progress_bar').className='';
                    setTimeout(function() {
                        document.getElementById('progress_bar').hidden = true;
                    }, 1500);
                } else if (progressVal === 0) {
                    document.getElementById('progress_bar').hidden = false;
                    document.getElementById('progress_bar').className = 'loading';
                }
            }
            
            function readFile() {
                var files = document.getElementById('output_file').files;
                if (files.length !== 1) {
//                    alert('Please select one file!');
                    return;
                }
                // Reset progress indicator on new file selection.
                updateProgress(0);
                document.getElementById('plot_options').hidden = true;
                document.getElementById('output_file_plot').hidden = true;
                reader = new FileReader();
                reader.onerror = errorHandler;
                var file = files[0];
                var unitName = file.name.slice(0, -5);
                var cache = 40960;
                var start = 0;
                var stop = Math.min(cache, file.size);
                var lineNum = 0;
                var result = [];
                result[0] = "";
                
                reader.onloadend = function (evt) {
                    if (evt.target.readyState === FileReader.DONE) { // DONE == 2
                        // Update the progress bar
                        updateProgress(stop / file.size);
                        
                        // Handle the cached content
                        var tmp = evt.target.result;
                        var tmpArr = tmp.split(/\r\n|\n\r|\r|\n/);
                        result[lineNum] += tmpArr[0];
                        for (var i = 1; i < tmpArr.length; i++) {
                            lineNum++;
                            result[lineNum] = tmpArr[i];
                        }
                        
                        // Continue for the next pieces
                        if (stop < file.size) {
                            start = stop;
                            stop = Math.min(stop + cache, file.size); 
                            var blob = file.slice(start, Math.min(stop, file.size));
                            reader.readAsBinaryString(blob);
                        } else {
                            readOutputData(result);
                        }
                    }
                };
                
                var blob = file.slice(start, stop);
                reader.readAsBinaryString(blob);
                
            }
            
            function readDailyOutput(rawData) {
                data = [];
                var date = [];
                var daily = {};
                var titleFlg = false;
                titles = [];
                var yearIdx = 0;
                var doyIdx = 1;
                var dasIdx = 2;
                var rowIdx = 3;
                var colIdx = 4;
                var year = 0;
                var doy = 0;
                var das = 0;
                var row = 0;
                var col = 0;
                for (var i = 0; i < rawData.length; i++) {
                    var line = rawData[i].trim();
                    if (line.startsWith("@")) {
                        titleFlg = true;
                        titles = line.substring(1).split(/\s+/);
                        yearIdx = titles.indexOf("YEAR");
                        doyIdx = titles.indexOf("DOY");
                        dasIdx = titles.indexOf("DAS");
                        rowIdx = titles.indexOf("ROW");
                        colIdx = titles.indexOf("COL");
//                        console.log(titles);
                    } else if (line.startsWith("!") || line.length === 0) {
                        continue;
                    } else if (titleFlg) {
                        var vals = line.split(/\s+/);
                        var limit = Math.min(titles.length, vals.length);
                        if (limit < vals.length) { console.log("line " + i + " have less data than title");}
                        row = Number(vals[rowIdx]);
                        col = Number(vals[colIdx]);
                        if (das !== vals[dasIdx]) {
                            year = vals[yearIdx];
                            doy = vals[doyIdx];
                            das = vals[dasIdx];
                            date.push({YEAR:year, DOY:doy, DAS: das});
                            daily = {DAS: das};
                            data.push(daily);
                            for (var j = 0; j < limit; j++) {
                                if (j !== yearIdx && j !== doyIdx && j !== dasIdx && j !== rowIdx && j !== colIdx) {
                                    daily[titles[j]] = [[]];
                                }
                            }
                        }
                        for (var j = 0; j < limit; j++) {
                            if (j !== yearIdx && j !== doyIdx && j !== dasIdx && j !== rowIdx && j !== colIdx) {
                                while (daily[titles[j]].length < row) {
                                    daily[titles[j]].push([]);
                                }
                                daily[titles[j]][row - 1][col - 1] = vals[j];
                            }
                        }
                        
                    }
                }
                titles.splice(titles.indexOf("YEAR"), 1);
                titles.splice(titles.indexOf("DOY"), 1);
                titles.splice(titles.indexOf("DAS"), 1);
                titles.splice(titles.indexOf("ROW"), 1);
                titles.splice(titles.indexOf("COL"), 1);
            }
            
            function getSoilStructure() {
                soilProfile = {};
                if (data.length > 0) {
                    var lastDay = data[data.length - 1];
                    var keys = Object.keys(lastDay);
                    if (keys.indexOf("DAS") > -1) {
                        keys.splice(keys.indexOf("DAS"), 1);
                    }
                    if (keys.length > 0) {
                        var randomData = lastDay[keys[0]];
                        var totRows = randomData.length;
                        var totCols = 0;
                        var bedRows = 0;
                        var bedCols = 0;
                        if (totRows > 0) {
                            totCols = randomData[totRows - 1].length;
                            bedCols = randomData[0].length;
                            while (bedRows < totRows && randomData[bedRows].length === bedCols) {
                                bedRows++;
                            }
                        }
                        soilProfile["totRows"] = totRows;
                        soilProfile["totCols"] = totCols;
                        soilProfile["bedRows"] = bedRows;
                        soilProfile["bedCols"] = bedCols;
                    }
                }
            }

            function readOutputData(rawData) {
                readDailyOutput(rawData);
                getSoilStructure();
                document.getElementById('plot_options').hidden = false;

                console.log("total_days: " + (data.length - 1));
                console.log("soil_profile: " + JSON.stringify(soilProfile));
//                document.getElementById('output_file_content_rawdata').innerHTML = JSON.stringify(titles);
                document.getElementById('das_scroll_input').max = data.length - 1;
                document.getElementById('das_scroll').max = data.length - 1;
            }
            
            function drawPlot() {
                var plotVar = document.getElementById("plot_type").value;
                var day = document.getElementById('das_scroll_input').value;
                if (day > data.length) {
                    document.getElementById("output_file_plot").hidden = true;
                    return;
                }
                document.getElementById("output_file_plot").hidden = false;
                var plotData = [];
                var plotTitle;
                var plotValTitle;
                if (plotVar === "water_flux") {
                    plotTitle = "Water Flux Vector Plot";
                    plotValTitle = "Water Vector Flux (cm3/cm3)";
                    var WFluxH = data[day]["WFluxH"];
                    var WFluxV = data[day]["WFluxV"];
                    for (var i = 0; i < soilProfile["totRows"]; i++) {
                        var limit = soilProfile["totCols"];
                        if (i <= soilProfile["bedRows"]) {
                            limit = soilProfile["bedCols"];
                        }
                        for (var j = 0; j < limit; j++) {
                            var WFluxVct = Math.sqrt(Math.pow(WFluxH[i][j],2) + Math.pow(WFluxV[i][j],2));
                            var WFluxDeg = getAngleDeg(WFluxV[i][j], WFluxH[i][j]);
                            plotData.push([j + 1, i + 1,WFluxVct, WFluxDeg]);
                        }
                    }
                    
//                    console.log(plotData);

                    Highcharts.chart('output_plot', {
                        title: {
                            text: plotTitle
                        },
                        chart: {
                            height: 500
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
//                            allowDecimals : false
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
//                            allowDecimals : false
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
            }
            
            function getAngleDeg(a, b) {
                var angleRad = Math.atan(Math.abs(a/b));
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
            
            function changeDate(target) {
                if (target.id === "das_scroll") {
                    document.getElementById('das_scroll_input').value = target.value;
                } else if (target.id === "das_scroll_input") {
                    document.getElementById('das_scroll').value = target.value;
                }
                drawPlot();
            }
            
            function zoomIn() {
                zoom -= 10;
                document.getElementById("zoom_val").textContent = zoom + "%";
                drawPlot();
            }
            
            function zoomOut() {
                zoom += 10;
                document.getElementById("zoom_val").textContent = zoom + "%";
                drawPlot();
            }
            
            var autoDas = -1;
            function AutoScroll() {
                
                document.getElementById('auto_scroll_btn').disabled = true;
                das = Number(document.getElementById('das_scroll_input').value) + 1;
                if (das < data.length && (autoDas === das - 1 || autoDas < 0) ) {
                    autoDas = das;
                    document.getElementById('das_scroll_input').value = das;
                    document.getElementById('das_scroll').value = das;
                    drawPlot();
                    setTimeout(function () {AutoScroll();}, 500);
                } else {
                    autoDas = -1;
                    document.getElementById('auto_scroll_btn').disabled = false;
                }
                
            }
            
            function scrollOne(chg) {
                
                var max = Number(document.getElementById('das_scroll_input').max);
                var min = Number(document.getElementById('das_scroll_input').min);
                var org = Number(document.getElementById('das_scroll_input').value);
                var newDas = org + chg;
                document.getElementById('das_scroll_input').value = newDas;
                document.getElementById('das_scroll').value = newDas;
                drawPlot();
            }
        </script>
    </head>

    <body>

        <#include "../nav.ftl">

        <div class="container">
            <div class="row">
                <div id="soilTypeSB_MAP" class="form-group">
                    <label class="control-label col-sm-2" for="soil_file">Select Output File :</label>
                    <div class="col-sm-5">
                        <input type="file" id="output_file" name="output_file" class="form-control" value="" accept=".out" onchange="readFile()" placeholder="Browse Output File (.out)" data-toggle="tooltip" title="Browse Output File (.out)">
                    </div>
                    <div class="col-sm-5">
                        <div id="progress_bar" class="text-left" hidden="true">
                            <div class="percent">0%</div>
                        </div>
                    </div>
                    <div id="soil_fileWarning" class="row col-sm-12 hidden">
                        <div class="col-sm-2 text-left"></div>
                        <div class="col-sm-10 text-left"><label id="soil_fileWarningMsg"></label></div>
                    </div>
                </div>
                <br/>
                <div id="plot_options" class="form-group" hidden="true">
                    <label class="control-label col-sm-2">Plot Type :</label>
                    <div class="col-sm-5 text-left">
                        <select id="plot_type" class="form-control" title="Select Plot Type">
                            <option value="water_flux">Water Flux Vector Plot</option>
                        </select>
                    </div>
                    <div class="col-sm-5">
                        <button type="button" class="btn btn-primary text-right" onclick="drawPlot()">Draw Plot</button>
                    </div>
                </div>
                <br/>
                <div id="output_file_plot" class="form-group" hidden="true">
                    <label class="control-label col-sm-1">Plot :</label>
                    <div id="output_plot" class="col-sm-11 text-left" style="overflow-y:auto;max-height:600px;"></div>
                    <label class="control-label col-sm-1"></label>
                    <label class="control-label col-sm-1">DAS</label>
                    <div class="col-sm-1 text-right">
                        <button type="button" class="btn btn-primary text-right" onclick="scrollOne(-1);"><</button>
                    </div>
                    <div class="col-sm-4 text-right">
                        <input type="range" id="das_scroll" name="das_scroll" class="form-control" value="0" step="1" max="180" min="0" placeholder="" data-toggle="tooltip" title="" onchange="changeDate(this)">
                    </div>
                    <div class="col-sm-1">
                        <button type="button" class="btn btn-primary text-right" onclick="scrollOne(1);">></button>
                    </div>
                    <div class="col-sm-1">
                        <input type="number" id="das_scroll_input" name="das_scroll_input" class="form-control" value="0" step="1" max="180" min="0" placeholder="" data-toggle="tooltip" title="" onchange="changeDate(this)">
                    </div>
                    <div class="col-sm-1">
                        <button id="auto_scroll_btn" type="button" class="btn btn-primary text-right" onclick="AutoScroll()">Auto Scroll</button>
                    </div>
                    <div class="col-sm-2 text-right">
                        <button type="button" class="btn btn-primary text-right" onclick="zoomOut()">+</button>
                        <lable id="zoom_val">50%</lable>
                        <button type="button" class="btn btn-primary text-right" onclick="zoomIn()">-</button>
                    </div>
                </div>
            </div>
        </div>

        <#include "../footer.ftl">
        
        <script>
            var progress = document.querySelector('.percent');
        </script>
    </body>
</html>
