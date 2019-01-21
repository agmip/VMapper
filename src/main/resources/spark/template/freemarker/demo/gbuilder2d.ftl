
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
            var autoDas = -1;
//            const plotVarExludsion = ["YEAR", "DOY", "DAS", "ROW", "COL", "NFluxR_A", "NFluxL_A", "NFluxD_A", "NFluxU_A", "NFluxR_D", "NFluxL_D", "NFluxD_D", "NFluxU_D"];
            const plotVarDic = {TotalN:"Soil N content", SWV:"Soil Water Content", AFERT:"Fertilization", IrrVol:"Irrigation", RLV:"Root Length Density", NO3UpTak:"NO3 Uptake", NH4UpTak:"NH4 Uptake", InfVol:"Infiltration", ES_RATE:"Evaporation Rate", EP_RATE:"Transpiration Rate"};
            
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
                var plotTypeSelect = document.getElementById('plot_type');
                var length = plotTypeSelect.options.length;
                for (i = length - 1; i >= 0; i--) {
                    plotTypeSelect.remove(i);
                }
                var optgroupHeatMap = document.createElement('optgroup');
                optgroupHeatMap.label = "Heatmap Plot";
                for (let key in plotVarDic) {
                    if (titles.indexOf(key) > -1) {
                        var option = document.createElement('option');
                        option.innerHTML = plotVarDic[key];
                        option.value = key;
                        optgroupHeatMap.append(option);
                    }
                }
                plotTypeSelect.append(optgroupHeatMap);
                
                var optgroupVecFlux = document.createElement('optgroup');
                optgroupVecFlux.label = "Vector Flux Plot";
                if (titles.indexOf("NFluxR_D") > -1 && titles.indexOf("NFluxL_D") > -1 && titles.indexOf("NFluxD_D") > -1 && titles.indexOf("NFluxU_D") > -1) {
                    var option = document.createElement('option');
                    option.innerHTML = "Soil N Flux";
                    option.value = "n_flux";
                    optgroupVecFlux.append(option);
                }
                if (titles.indexOf("WFluxH") > -1 && titles.indexOf("WFluxV") > -1) {
                    var option = document.createElement('option');
                    option.innerHTML = "Soil Water Flux";
                    option.value = "water_flux";
                    optgroupVecFlux.append(option);
                }
                plotTypeSelect.append(optgroupVecFlux);
                $("#plot_type").chosen("destroy");
                chosen_init("plot_type", ".chosen-select");
            }
            
            function drawPlot() {
                let options = document.getElementById("plot_type").selectedOptions;
                var day = document.getElementById('das_scroll_input').value;
                if (day > daily.length) {
                    document.getElementById("plot_ctrl").hidden = true;
                    document.getElementById("plot_content").hidden = true;
                    return;
                }
                if (options.length > 0) {
                    document.getElementById("plot_ctrl").hidden = false;
                    document.getElementById("plot_content").hidden = false;
                } else {
                    document.getElementById("plot_ctrl").hidden = true;
                    document.getElementById("plot_content").hidden = true;
                }
                
                for (let i = 1; i <= 4; i++) {
                    let plotDiv = document.getElementById("output_plot" + i);
                    if (plotDiv !== undefined && plotDiv !== null) {
                        plotDiv.innerHTML = "";
                    }
                    
                }
                
                if (options.length === 1) {
                    document.getElementById("output_plot1").className = 'col-sm-12';
                } else {
                    document.getElementById("output_plot1").className = 'col-sm-6';
                }
                
                let cnt = 1;
                for (let i in options) {
                    if (cnt > 4) break;
                    let plotVar = options[i].value;
                    if (plotVar === "water_flux") {
                        drawWaterVectorFluxPlot(data, soilProfile, 'output_plot' + cnt, day, zoom);
                    } else if (plotVar === "n_flux") {
                        drawNitroFluxVectorPlot(data, soilProfile, 'output_plot' + cnt, day, zoom);
                    } else if (plotVarDic[plotVar] !== undefined) {
                        drawDailyHeatMapPlot(plotVar, plotVarDic[plotVar], data, soilProfile, 'output_plot' + cnt, day, zoom);
                    }
                    cnt++;
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
            
            function AutoScroll() {
                
                document.getElementById('auto_scroll_btn').disabled = true;
                das = Number(document.getElementById('das_scroll_input').value) + 1;
                if (das < daily.length && (autoDas === das - 1 || autoDas < 0) ) {
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
                <div id="soilTypeSB_MAP" class="form-group">
                    <label class="control-label col-sm-2" for="soil_file">Simulated Result :</label>
                    <div class="col-sm-6">
                        <!--<input type="file" id="output_file" name="output_file" class="form-control filestyle" data-text="Browse" data-placeholder="Browse Simulation Result Directory" data-btnClass="btn-primary" onchange="readFile();" placeholder="Browse Simulation Result Directory" data-toggle="tooltip" title="Browse Simulation Result Directory" webkitdirectory  multiple>-->
                        <input type="file" id="output_file" name="output_file" class="form-control filestyle" data-text="Browse" data-placeholder="Browse Simulation Result File" data-btnClass="btn-primary" onchange="readFile();" placeholder="Browse Simulation Result File" data-toggle="tooltip" title="Browse Simulation Result File">
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
                    <label class="control-label col-sm-2">Plot Type :</label>
                    <div class="col-sm-6 text-left">
                        <select id="plot_type" data-placeholder="Select Plot Type" title="Select Plot Type" onchange="drawPlot();" class="form-control chosen-select" multiple>
                        <!--<select id="plot_type" class="form-control" title="Select Plot Type" multiple>-->
                            <!--<option value="">Select Plot Type (Up to 4)</option>-->
                        </select>
                    </div>
                    <div class="col-sm-4">
                        <button type="button" class="btn btn-primary text-right" onclick="drawPlot();">Draw Plot</button>
                    </div>
                </div>
                <br/>
                <div id="plot_ctrl" class="form-group" hidden="true">
                    <label class="control-label col-sm-1">Plot :</label>
                    <label class="control-label col-sm-1">DAS</label>
                    <div class="col-sm-1 text-right">
                        <button type="button" class="btn btn-primary text-right" onclick="scrollOne(-1);"><</button>
                    </div>
                    <div class="col-sm-4 text-right">
                        <input type="range" id="das_scroll" name="das_scroll" class="form-control" value="0" step="1" max="180" min="0" placeholder="" data-toggle="tooltip" title="" onchange="changeDate(this);">
                    </div>
                    <div class="col-sm-1">
                        <button type="button" class="btn btn-primary text-right" onclick="scrollOne(1);">></button>
                    </div>
                    <div class="col-sm-1">
                        <input type="number" id="das_scroll_input" name="das_scroll_input" class="form-control" value="0" step="1" max="180" min="0" placeholder="" data-toggle="tooltip" title="" onchange="changeDate(this);">
                    </div>
                    <div class="col-sm-1">
                        <button id="auto_scroll_btn" type="button" class="btn btn-primary text-right" onclick="AutoScroll();">Auto Scroll</button>
                    </div>
                    <div class="col-sm-2 text-right">
                        <button type="button" class="btn btn-primary text-right" onclick="zoomOut();">+</button>
                        <lable id="zoom_val">50%</lable>
                        <button type="button" class="btn btn-primary text-right" onclick="zoomIn();">-</button>
                    </div>
                </div>
            </div>
        </div>
        <div id="plot_content" class="container-fluid">
            <div id="plot_div" class="col-sm-12 text-left row" style="max-height:600px;">
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
            var progress = document.querySelector('.percent');
            chosen_init_all();
        </script>
    </body>
</html>
