<!DOCTYPE html>
<html>
    <head>
        <#include "../header.ftl">
        <#include "../chosen.ftl">
        
        <script>
            
            let data;
            let obvData;
            let daily;
            let obvDaily;
            let soilWatData;
            let soilProfile;
            let titles;
            let obvTitles;
            let selections = [];
            let charts = {};
            let loadTargets = [];
            let curFileIdx = 0;
//            const plotVarExludsion = ["YEAR", "DOY", "DAS", "ROW", "COL", "NFluxR_A", "NFluxL_A", "NFluxD_A", "NFluxU_A", "NFluxR_D", "NFluxL_D", "NFluxD_D", "NFluxU_D"];
            const plotVarDic = {SWV:"Soil Water Content (cm3/cm3)", TotalN:"Soil N content", AFERT:"Fertilization", IrrVol:"Irrigation", RLV:"Root Length Density", NO3UpTak:"NO3 Uptake", NH4UpTak:"NH4 Uptake", InfVol:"Infiltration", ES_RATE:"Evaporation Rate", EP_RATE:"Transpiration Rate"};
            
            function readFile() {
                
                if (curFileIdx === loadTargets.length) {
                    let files = document.getElementById('output_file').files;
                    if (files.length < 1) {
                //        alert('Please select a directory!');
                        return;
                    }
                    document.getElementById('reload_btn').disabled = true;
                    document.getElementById('plot_options').hidden = true;
                    document.getElementById("plot_content").hidden = true;
                    loadTargets = [];
                    curFileIdx = -1;
                    for (let i = 0; i < files.length; i++) {
                        if (files[i].name === "CellDetail.OUT" 
                                || files[i].name === "SWV_2dobv.csv"
//                                || files[i].name === "Weather.OUT"
//                                || files[i].name === "SoilWat.OUT"
                                || files[i].name === "INFO.OUT"
                                || files[i].name === "SoilWat_ts.OUT") {
                            loadTargets.push(files[i]);
                        }
                    }
                    data = {};
                    obvData = {};
                    soilWatData = {};
                    soilProfile = {};
                    soilProfile["LL"] = [];
                    soilProfile["DUL"] = [];
                    soilProfile["SAT"] = [];
                    soilProfile["DS"] = [];
                    readFile();
//                    alert('Does not find CellDetailN.OUT in the selected folder!');
                } else {
                    curFileIdx++;
                    if (curFileIdx === loadTargets.length - 1) {
                        readFileToBufferedArray(loadTargets[curFileIdx], updateProgress, handleRawData, {idx:curFileIdx, total:loadTargets.length});
                    } else if (curFileIdx < loadTargets.length) {
                        readFileToBufferedArray(loadTargets[curFileIdx], updateProgress, cacheData, {idx:curFileIdx, total:loadTargets.length});
                    }
                }
            }
            
            function cacheData(rawData) {
                if (rawData.length === 0) {
                    return;
                } else if (rawData[0].startsWith("*WATER BALANCE FOR CELL")) {
                    data = readSubDailyOutput(rawData);
                    daily = data["subdaily"];
                    titles = data["titles"];
                    let tmp = getSoilStructure(daily);
                    tmp["LL"] = soilProfile["LL"];
                    tmp["DUL"] = soilProfile["DUL"];
                    tmp["SAT"] = soilProfile["SAT"];
                    tmp["DS"] = soilProfile["DS"];
                    soilProfile = tmp;
                } else if (rawData[0].startsWith("*INFO DETAIL FILE")) {
                    let tmp = readInfoOut(rawData);
                    soilProfile["LL"] = tmp["data"]["LL"];
                    soilProfile["DUL"] = tmp["data"]["DUL"];
                    soilProfile["SAT"] = tmp["data"]["SAT"];
                    soilProfile["DS"] = tmp["data"]["DS"];
                    soilProfile["units"] = tmp["unit"];
                } else if (rawData[0].startsWith("!,Subdaily Observation Data for 2D")) {
                    obvData = readSubDailyObv(rawData);
                    obvDaily = obvData["subdaily"];
                    obvTitles = obvData["titles"];
                } else if (rawData[0].startsWith("*SOIL WATER DAILY OUTPUT FILE")) {
                    soilWatData = readSoilWat(rawData);
                } else if (rawData[0].startsWith("*WATER BALANCE OUTPUT FILE")) {
                    soilWatData = readSoilWatTS(rawData);
                }
                readFile();
            }
            
            function handleRawData(rawData) {
                cacheData(rawData);
                document.getElementById('reload_btn').disabled = false;
                document.getElementById('plot_options').hidden = false;

//                console.log(JSON.stringify(daily));
//                console.log("total_days: " + (data.length - 1));
//                console.log("soil_profile: " + JSON.stringify(soilProfile));
//                document.getElementById('output_file_content_rawdata').innerHTML = JSON.stringify(titles);
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
                selections = [];
                clearCharts();
                let plotTypeSelect = document.getElementById('plot_type');
                let length = plotTypeSelect.options.length;
                for (let i = length - 1; i >= 0; i--) {
                    plotTypeSelect.remove(i);
                }
                let optgroupHeatMap = $('<optgroup>');
                optgroupHeatMap.attr('label', 'Time Series Line Plot');
                for (let key in plotVarDic) {
                    if (titles.indexOf(key) > -1) {
                        for (let i = 0; i < soilProfile.totRows; i++) {
                            for (let j = 0; j < soilProfile.totCols; j++) {
                                if (daily[1][key][i][j] !== undefined) {
                                    let option = document.createElement('option');
                                    if (obvDaily && obvDaily[1][key][i] && obvDaily[1][key][i][j]) {
                                        option.innerHTML = "<strong>" + plotVarDic[key] + " at [" + (i+1) + ", " + (j+1) + "]</strong>";
                                    } else {
                                        option.innerHTML = plotVarDic[key] + " at [" + (i+1) + ", " + (j+1) + "]";
                                    }
                                    option.value = key + "_" + i + "_" + j;
                                    optgroupHeatMap.append(option);
                                    if (selections.includes(key)) {
                                        option.selected = true;
                                    }
                                }
                            }
                        }
                    }
                }
                $('#plot_type').append(optgroupHeatMap);
                
                chosen_init("plot_type");
            }
            
            function drawPlot() {
                if (selections.length > 0) {
//                    document.getElementById("plot_ctrl").hidden = false;
                    document.getElementById("plot_content").hidden = false;
                } else {
//                    document.getElementById("plot_ctrl").hidden = true;
                    document.getElementById("plot_content").hidden = true;
                }
                
                for (let i in selections) {
                    let plotVar = selections[i];
                    let plotVarInfo = plotVar.split("_");
                    if (plotVarDic[plotVarInfo[0]] !== undefined) {
                        if (charts[plotVar] === undefined || charts[plotVar] === null) {
                            drawSWV2DPlot(plotVarInfo[0], plotVarDic[plotVarInfo[0]], {sim:data, obv:obvData, soilWat:soilWatData, soilProfile:soilProfile}, 'output_plot' + 1, {row:plotVarInfo[1], col:plotVarInfo[2]}, "full");
//                            drawSWV2DPlot(plotVarInfo[0], plotVarDic[plotVarInfo[0]], data, obvData, 'output_plot' + 2, {row:plotVarInfo[1], col:plotVarInfo[2]}, "last");
                        } else {
                            drawSWV2DPlot(plotVarInfo[0], plotVarDic[plotVarInfo[0]], {sim:data, obv:obvData, soilWat:soilWatData, soilProfile:soilProfile}, 'output_plot' + 1, {row:plotVarInfo[1], col:plotVarInfo[2]}, "full");
//                            drawSWV2DPlot(plotVarInfo[0], plotVarDic[plotVarInfo[0]], data, obvData, 'output_plot' + 2, {row:plotVarInfo[1], col:plotVarInfo[2]}, "last");
                        }
                    }
                }
                
            }
            
            function updateSelections() {
                let options = document.getElementById("plot_type").options;
//                let rmvIdx = selections.length;
                for(let i in options) {
                    let val = options[i].value;
                    let idx = selections.indexOf(val);
                    if (options[i].selected) {
                        if (idx < 0) {
                            selections.push(val);
                        }
                    } else {
                        if (idx >= 0) {
//                            clearChart(i);
                            selections.splice(selections.indexOf(val), 1);
//                            charts[val].destroy();
//                            charts[val] = null;
//                            if (idx < rmvIdx) {
//                                rmvIdx = idx;
//                            }
                        }
                    }
                }
//                for (let i = rmvIdx; i <= selections.length; i++) {
//                    clearChart(i);
//                }
//                
//                let div1Class = document.getElementById("output_plot1").className;
//                if (selections.length === 1 && div1Class === "col-sm-6") {
//                    document.getElementById("output_plot1").className = 'col-sm-12';
//                    reflowChart(0);
//                } else if (selections.length === 2 && div1Class === "col-sm-12") {
//                    document.getElementById("output_plot1").className = 'col-sm-6';
//                    for (let i = 0; i <= selections.length; i++) {
//                        clearChart(i);
//                    }
//                }
                
                drawPlot();
            }
            
            function clearChart(idx) {
                if (charts[selections[idx]] !== undefined && charts[selections[idx]] !== null) {
                    charts[selections[idx]].destroy();
                    charts[selections[idx]] = null;
                }
            }
            
            function reflowChart(idx) {
                if (charts[selections[idx]] !== undefined && charts[selections[idx]] !== null) {
                    charts[selections[idx]].reflow();
                }
            }
            
            function clearCharts() {
                for (let key in charts) {
                    charts[key].destroy();
                    charts[key] = null;
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
                        <input type="file" id="output_file" name="output_file" class="form-control filestyle" data-text="Browse" data-placeholder="Browse Simulation Result Directory" data-btnClass="btn-primary" onchange="readFile();" placeholder="Browse Simulation Result Directory" data-toggle="tooltip" title="Browse Simulation Result Directory" webkitdirectory multiple >
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
                <div id="plot_options" class="form-group" hidden="true">
                    <label class="control-label col-sm-2">Output Variable :</label>
                    <div class="col-sm-6 text-left">
                        <select id="plot_type" data-placeholder="Select Plot Type" title="Select Plot Type" onchange="updateSelections();" class="form-control chosen-select-deselect-single" multiple>
                        </select>
                    </div>
                    <div class="col-sm-4">
                        <button type="button" class="btn btn-primary text-right" onclick="drawPlot();">Draw Plot</button>
                    </div>
                </div>
            </div>
        </div>
        <div id="plot_content" class="container-fluid">
            <div id="plot_div" class="col-sm-12 text-left row" style="max-height:600px;">
                <div id="output_plot1" class="col-sm-12"></div>
                <div id="output_plot2" class="col-sm-12"></div>
            </div>
        </div>

        <#include "../footer.ftl">
        <script type="text/javascript" src="https://code.highcharts.com/highcharts.js"></script>
        <script type="text/javascript" src="https://code.highcharts.com/modules/heatmap.js"></script>
        <script type="text/javascript" src="https://code.highcharts.com/modules/vector.js"></script>
        <script src="https://code.highcharts.com/modules/no-data-to-display.js"></script>
        <script type="text/javascript" src="https://code.highcharts.com/modules/exporting.js"></script>
        <script type="text/javascript" src="https://code.highcharts.com/modules/export-data.js"></script>
        <script type="text/javascript" src="/plugins/filestyle/bootstrap-filestyle.min.js"></script>
        <script type="text/javascript" src="/plugins/chosen/chosen.jquery.min.js" ></script>
        <script type="text/javascript" src="/plugins/chosen/prism.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/chosen/init.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/dataReader/BufferedFileReader.js"></script>
        <script type="text/javascript" src="/js/dataReader/outputDataReader.js"></script>
        <script type="text/javascript" src="/js/plot/VectorFlux.js"></script>
        <script type="text/javascript" src="/js/plot/Heatmap.js"></script>
        <script type="text/javascript" src="/js/plot/LineScatter.js"></script>
        <script>
            var progress;
            $(document).ready(function () {
                progress = document.querySelector('.percent');
                chosen_init_all();
            });
        </script>
    </body>
</html>
