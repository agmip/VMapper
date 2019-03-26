
<!DOCTYPE html>
<html>
    <head>
        <#include "../header.ftl">
        <#include "../chosen.ftl">
        
        <script>
            
            var data;
            var daily;
            var soilProfile;
            var titles;
            var zoom = 50;
            var autoDasFlg = false;
            var selections = [];
            let charts = {};
//            const plotVarExludsion = ["YEAR", "DOY", "DAS", "ROW", "COL", "NFluxR_A", "NFluxL_A", "NFluxD_A", "NFluxU_A", "NFluxR_D", "NFluxL_D", "NFluxD_D", "NFluxU_D"];
            const plotVarDic = {SWV:"Soil Water Content", TotalN:"Soil N content", AFERT:"Fertilization", IrrVol:"Irrigation", RLV:"Root Length Density", NO3UpTak:"NO3 Uptake", NH4UpTak:"NH4 Uptake", InfVol:"Infiltration", ES_RATE:"Evaporation Rate", EP_RATE:"Transpiration Rate"};
            
            function readFile() {
                
                let files = document.getElementById('output_file').files;
                if (files.length < 1) {
            //        alert('Please select a directory!');
                    return;
                }
                document.getElementById('reload_btn').disabled = true;
                document.getElementById('plot_options').hidden = true;
                document.getElementById('plot_ctrl').hidden = true;
                document.getElementById("plot_content").hidden = true;
                resetDate();
                for (let i=0; i<files.length; i++) {
                    if (files[i].name === "CellDetailN.OUT") {
                        readFileToBufferedArray(files[i], updateProgress, handleRawData);
                        return;
                    }
                }
                alert('Does not find CellDetailN.OUT in the selected folder!');
            }
            
            function handleRawData(rawData) {
//            	console.log(JSON.stringify(rawData));
                data = readDailyOutput(rawData);
                daily = data["daily"];
                titles = data["titles"];
                soilProfile = getSoilStructure(daily);
                document.getElementById('reload_btn').disabled = false;
                document.getElementById('plot_options').hidden = false;

//                console.log("total_days: " + (data.length - 1));
//                console.log("soil_profile: " + JSON.stringify(soilProfile));
//                document.getElementById('output_file_content_rawdata').innerHTML = JSON.stringify(titles);
                document.getElementById('das_scroll_input').max = daily.length - 1;
                document.getElementById('das_scroll').max = daily.length - 1;
                updatePlotType();
                updateSelections();
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
            
            function updatePlotType() {
                selections = [];
                clearCharts();
                let plotTypeSelect = document.getElementById('plot_type');
                let length = plotTypeSelect.options.length;
                for (let i = length - 1; i >= 0; i--) {
                    plotTypeSelect.remove(i);
                }
                let optgroupHeatMap = $('<optgroup>');
                optgroupHeatMap.attr('label', 'Heatmap Plot');
                for (let key in plotVarDic) {
                    if (titles.indexOf(key) > -1) {
                        let option = document.createElement('option');
                        option.innerHTML = plotVarDic[key];
                        option.value = key;
                        optgroupHeatMap.append(option);
                        if (selections.includes(key)) {
                            option.selected = true;
                        }
                    }
                }
                $('#plot_type').append(optgroupHeatMap);
                
                let optgroupVecFlux = $('<optgroup>');
                optgroupVecFlux.attr('label', 'Vector Flux Plot');
                if (titles.indexOf("WFluxH") > -1 && titles.indexOf("WFluxV") > -1) {
                    let option = document.createElement('option');
                    option.innerHTML = "Soil Water Flux";
                    option.value = "water_flux";
                    if (selections.includes(option.value)) {
                        option.selected = true;
                    }
                    optgroupVecFlux.append(option);
                }
                if (titles.indexOf("NFluxR_D") > -1 && titles.indexOf("NFluxL_D") > -1 && titles.indexOf("NFluxD_D") > -1 && titles.indexOf("NFluxU_D") > -1) {
                    let option = document.createElement('option');
                    option.innerHTML = "Soil N Flux";
                    option.value = "n_flux";
                    if (selections.includes(option.value)) {
                        option.selected = true;
                    }
                    optgroupVecFlux.append(option);
                }
                $('#plot_type').append(optgroupVecFlux);
                $("#plot_type").chosen("destroy");
                chosen_init("plot_type");
            }
            
            function drawPlot() {
                var day = document.getElementById('das_scroll_input').value;
                if (day > daily.length) {
                    document.getElementById("plot_ctrl").hidden = true;
                    document.getElementById("plot_content").hidden = true;
                    return;
                }
                if (selections.length > 0) {
                    document.getElementById("plot_ctrl").hidden = false;
                    document.getElementById("plot_content").hidden = false;
                } else {
                    document.getElementById("plot_ctrl").hidden = true;
                    document.getElementById("plot_content").hidden = true;
                }
                
                let cnt = 1;
                for (let i in selections) {
                    if (cnt > 4) break;
                    let plotVar = selections[i];
                    if (plotVar === "water_flux") {
                        if (charts[plotVar] === undefined) {
                            charts[plotVar] = drawWaterVectorFluxPlot(data, soilProfile, 'output_plot' + cnt, day, zoom);
                        } else {
                            drawWaterVectorFluxPlot(data, soilProfile, 'output_plot' + cnt, day, zoom, charts[plotVar]);
                        }
                    } else if (plotVar === "n_flux") {
                        if (charts[plotVar] === undefined) {
                            charts[plotVar] = drawNitroFluxVectorPlot(data, soilProfile, 'output_plot' + cnt, day, zoom);
                        } else {
                            drawNitroFluxVectorPlot(data, soilProfile, 'output_plot' + cnt, day, zoom, charts[plotVar]);
                        }
                        
                    } else if (plotVarDic[plotVar] !== undefined) {
                        if (charts[plotVar] === undefined) {
                            charts[plotVar] = drawDailyHeatMapPlot(plotVar, plotVarDic[plotVar], data, soilProfile, 'output_plot' + cnt, day, zoom);
                        } else {
                            drawDailyHeatMapPlot(plotVar, plotVarDic[plotVar], data, soilProfile, 'output_plot' + cnt, day, zoom, charts[plotVar]);
                        }
                    }
                    cnt++;
                }
                
            }
            
            function updateSelections() {
                let options = document.getElementById("plot_type").options;
                let rmvIdx = selections.length;
                for(let i in options) {
                    let val = options[i].value;
                    let idx = selections.indexOf(val);
                    if (options[i].selected) {
                        if (idx < 0) {
                            selections.push(val);
                        }
                    } else {
                        if (idx >= 0) {
                            clearChart(idx);
                            selections.splice(selections.indexOf(val), 1);
                            if (idx < rmvIdx) {
                                rmvIdx = idx;
                            }
                        }
                    }
                }
                for (let i = rmvIdx; i <= selections.length; i++) {
                    clearChart(i);
                }
                
                let div1Class = document.getElementById("output_plot1").className;
                if (selections.length === 1 && div1Class === "col-sm-6") {
                    document.getElementById("output_plot1").className = 'col-sm-12';
                    reflowChart(0);
                } else if (selections.length === 2 && div1Class === "col-sm-12") {
                    document.getElementById("output_plot1").className = 'col-sm-6';
                    for (let i = 0; i <= selections.length; i++) {
                        clearChart(i);
                    }
                }
                
                drawPlot();
            }
            
            function clearChart(idx) {
                if (charts[selections[idx]] !== undefined) {
                    charts[selections[idx]].destroy();
                    delete charts[selections[idx]];
                }
            }
            
            function reflowChart(idx) {
                if (charts[selections[idx]] !== undefined) {
                    charts[selections[idx]].reflow();
                }
            }
            
            function clearCharts() {
                for (let key in charts) {
                    if (charts[key] !== undefined) {
                        charts[key].destroy();
                        delete charts[key];
                    }
                }
            }
            
            function resetDate() {
                document.getElementById('das_scroll_input').value = 0;
                document.getElementById('das_scroll').value = 0;
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
            
            function AutoScroll(activeFlg) {
                let autoScrollBtn = $("#auto_scroll_btn");
                if (activeFlg === undefined) {
                    autoDasFlg = !autoDasFlg;
                    if (autoDasFlg) {
                        autoScrollBtn.removeClass("glyphicon-play").addClass("glyphicon-pause");
                    } else {
                        autoScrollBtn.removeClass("glyphicon-pause").addClass("glyphicon-play");
                    }
                } else if (autoScrollBtn.hasClass("glyphicon-pause")) {
                    autoDasFlg = activeFlg;
                } else {
                    autoDasFlg = false;
                }
                
                das = Number(document.getElementById('das_scroll_input').value) + 1;
                if (das < daily.length && das >= 0 && autoDasFlg) {
                    document.getElementById('das_scroll_input').value = das;
                    document.getElementById('das_scroll').value = das;
                    drawPlot();
                    setTimeout(AutoScroll, autoDasFlg, 500);
                } else {
                    autoDasFlg = false;
                }
            }
            
            function scrollOne(chg) {
                
                var max = Number(document.getElementById('das_scroll_input').max);
                var min = Number(document.getElementById('das_scroll_input').min);
                var org = Number(document.getElementById('das_scroll_input').value);
                var newDas = org + chg;
                if (newDas < max && newDas > min) {
                    document.getElementById('das_scroll_input').value = newDas;
                    document.getElementById('das_scroll').value = newDas;
                    drawPlot();
                }
            }
        </script>
    </head>

    <body>

        <#include "../nav.ftl">

        <div class="container">
            <div class="row">
                <div id="output_file_group" class="form-group">
                    <label class="control-label col-sm-2" for="soil_file">Simulated Result :</label>
                    <div class="col-sm-6">
                        <!--<input type="file" id="output_file" name="output_file" class="form-control filestyle" data-text="Browse" data-placeholder="Browse Simulation Result Directory" data-btnClass="btn-primary" onchange="readFile();" placeholder="Browse Simulation Result Directory" data-toggle="tooltip" title="Browse Simulation Result Directory" webkitdirectory  multiple>-->
                        <input type="file" id="output_file" name="output_file" accept=".out" class="form-control filestyle" data-text="Browse" data-placeholder="Browse Simulation Result File" data-btnClass="btn-primary" onchange="readFile();" placeholder="Browse Simulation Result File" data-toggle="tooltip" title="Browse Simulation Result File">
                    </div>
                    <div class="col-sm-4">
                        <button id="reload_btn" type="button" class="btn btn-primary text-right" onclick="readFile();" disabled>Reload</button>
                    </div>
                    <div class="col-sm-12">
                        <div id="progress_bar" class="text-left " hidden="true">
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
                    <label class="control-label col-sm-2">Output Variable :</label>
                    <div class="col-sm-6 text-left">
                        <select id="plot_type" data-placeholder="Select Plot Type" title="Select Plot Type" onchange="updateSelections();" class="form-control chosen-select-max4" multiple>
                        </select>
                    </div>
                    <div class="col-sm-4">
                        <button type="button" class="btn btn-primary text-right" onclick="drawPlot();">Draw Plot</button>
                    </div>
                </div>
                <br/>
                <div id="plot_ctrl" class="form-group" hidden="true">
                    <label class="control-label col-sm-2">Day of Simulation :</label>
                    <div class="col-sm-5 text-right">
                        <input type="range" id="das_scroll" name="das_scroll" class="form-control" value="0" step="1" max="180" min="0" placeholder="" data-toggle="tooltip" title="" onchange="changeDate(this);">
                    </div>
                    <div class="col-sm-1">
                        <input type="number" id="das_scroll_input" name="das_scroll_input" class="form-control" value="0" step="1" max="180" min="0" placeholder="" data-toggle="tooltip" title="" onchange="changeDate(this);">
                    </div>
                    <div class="col-sm-2 btn-group">
                        <button type="button" class="btn btn-primary glyphicon glyphicon-chevron-left" onclick="scrollOne(-1);"></button>
                        <button id="auto_scroll_btn" type="button" class="btn btn-primary glyphicon glyphicon-play" onclick="AutoScroll();"></button>
                        <button type="button" class="btn btn-primary glyphicon glyphicon-chevron-right" onclick="scrollOne(1);"></button>
                    </div>
                    <div class="col-sm-2 text-right">
                        <button type="button" class="btn btn-primary glyphicon glyphicon-plus" onclick="zoomOut();"></button>
                        <label id="zoom_val" class="control-label">50%</label>
                        <button type="button" class="btn btn-primary glyphicon glyphicon-minus" onclick="zoomIn();"></button>
                    </div>
                </div>
            </div>
        </div>
        <div id="plot_content" class="container-fluid">
            <div id="plot_div" class="col-sm-12 text-left row">
                <div id="output_plot1" class="col-sm-6"></div>
                <div id="output_plot2" class="col-sm-6"></div>
                <div id="output_plot3" class="col-sm-6"></div>
                <div id="output_plot4" class="col-sm-6"></div>
            </div>
        </div>

        <#include "../footer.ftl">
        <script type="text/javascript" src="https://code.highcharts.com/highcharts.js"></script>
        <script type="text/javascript" src="https://code.highcharts.com/modules/heatmap.js"></script>
        <script type="text/javascript" src="https://code.highcharts.com/modules/vector.js"></script>
        <script type="text/javascript" src="https://code.highcharts.com/modules/no-data-to-display.js"></script>
        <script type="text/javascript" src="https://code.highcharts.com/modules/exporting.js"></script>
        <script type="text/javascript" src="/plugins/filestyle/bootstrap-filestyle.min.js"></script>
        <script type="text/javascript" src="/plugins/chosen/chosen.jquery.min.js" ></script>
        <script type="text/javascript" src="/plugins/chosen/prism.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/chosen/init.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/dataReader/BufferedFileReader.js"></script>
        <script type="text/javascript" src="/js/dataReader/outputDataReader.js"></script>
        <script type="text/javascript" src="/js/plot/VectorFlux.js"></script>
        <script type="text/javascript" src="/js/plot/Heatmap.js"></script>
        <script>
            var progress;
            $(document).ready(function () {
                progress = document.querySelector('.percent');
                chosen_init_all();
            });
        </script>
    </body>
</html>
