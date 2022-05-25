<#ftl strip_whitespace = true>
<#assign title="Data Factory">

<!DOCTYPE html>
<html>
    <head>
        <#include "../header.ftl">
        <title>${title}</title>
        <#include "../chosen.ftl">
        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/handsontable-pro@latest/dist/handsontable.full.min.css">
        <link rel="stylesheet" type="text/css" href="${env_path_web_root}stylesheets/toggle/bootstrap-toggle.min.css" />
        <link rel="stylesheet" type="text/css" href="${env_path_web_root}plugins/jsonViewer/jquery.json-viewer.css" />
        <script>
            let result;
            let dataSetName;
            
            function saveFile(key, isText) {
                if (isText) {
                    let blob = new Blob([result[key]], {type: "text/plain;charset=utf-8"});
                    saveAs(blob, dataSetName + "." + key);
                } else {
                    
                }
            }
        
            function executeJobs() {
                result = null;
                dataSetName = null;
                let formData = new FormData();
                Array.from($('#agmip_data_files').prop("files")).forEach(function (file) {
                    formData.append("raw_data", file);
                });
                Array.from($('#agmip_field_overlay_dome_file').prop("files")).forEach(function (file) {
                    formData.append("field_overlay_dome", file);
                });
                Array.from($('#agmip_seasonal_strategy_dome_file').prop("files")).forEach(function (file) {
                    formData.append("seasonal_strategy_dome", file);
                });
                Array.from($('#agmip_linkage_file').prop("files")).forEach(function (file) {
                    formData.append("linkage", file);
                });
                
                formData.append("models", $('#agmip_output_models').val());
                $("#agmip_json_content_text").html("");
                
                fetch('/data/translate', {method: "POST", body: formData}).then(function (response) {
                    if (response.ok) {
                        return response.json();
                    } else {
                        alertBox(response.statusText);
                    }
                }).then(function(data) {
                    if (data && data.errors) {
                        alertBox(data.errors);
                    } else if (data) {
                        result = data;
                        dataSetName = data.data_set_name;
                        let jsonObj = JSON.parse(result.json);
                        $("#agmip_json_content_text").html(JSON.stringify(jsonObj, 2, 2));
                        $("#agmip_json_content_tree").jsonViewer(jsonObj, JSON.parse('{"collapsed":true,"rootCollapsable":false}'));
                        $("#agmip_log_content_text").html(result.log);
                        
                        $("#AgMIPResultTab").fadeIn("fast", function() {
                            $("#AgMIPResultTab a").click();
                            $("#AgMIPJsonTab").fadeIn("fast", function () {$("#AgMIPJsonTab a").click();});
                        });
                    }
                }).catch(function(err) {
                    console.log('Fetch problem show: ' + err.message);
                });
            }
        </script>
    </head>
    <body>
        <#include "../nav.ftl">

        <div class="container"></div>
        <div class="container-fluid">
            <ul class="nav nav-tabs">
                <li id="TransTab" class="active"><a data-toggle="tab" href="#translation_tab">General Info</a></li>
                <li id="AgMIPJsonTab" class="fade"><a data-toggle="tab" href="#agmip_json_tab">ACE Data Preview</a></li>
                <li id="AgMIPResultTab" class="fade"><a data-toggle="tab" href="#agmip_result_tab">Translation Result</a></li>
            </ul>
            <div class="tab-content">
                
                <div id="translation_tab" class="tab-pane fade in active">
                    <div class="subcontainer">
                        <fieldset class="col-sm-6">
                            <legend>Source Data To Convert:<span class="glyphicon glyphicon-info-sign btn" data-toggle="tooltip" title="Please provide source Data with ICASA compitable format. You can run VMapper to process your data into such format."></span></legend>
                            <div class="form-group col-sm-12">
                                <label class="control-label">Source Data Files :</label>&nbsp;&nbsp;
                                <!--<input type="checkbox" name="agmip_data_switch">-->
                                <input type="file" id="agmip_data_files" class="form-control" accept=".xlsx,.xls,.csv,.zip,.aceb" placeholder="Provide AgMIP input package or files here" multiple>
                                <!--<textarea name="agmip_data_urls" class="form-control" placeholder="Provide the URLs of your AgMIP input package or files, use new line to separate them..."></textarea>-->
                            </div>
                        </fieldset>
                        <fieldset class="col-sm-6">
                            <legend>DOME setting:<span class="glyphicon glyphicon-info-sign btn" data-toggle="tooltip" title="Provide DOME file to revise data"></span></legend>
                            <div class="form-group col-sm-12">
                                <label class="control-label">DOME Files:</label>&nbsp;&nbsp;
                                <!--<input type="checkbox" name="agmip_dome_switch">-->
                                <input type="file" id="agmip_field_overlay_dome_file" class="form-control" accept=".xlsx,.xls,.csv,.zip,.dome" placeholder="Provide field overlay DOME file here">
                                <input type="file" id="agmip_seasonal_strategy_dome_file" class="form-control" accept=".xlsx,.xls,.csv,.zip,.dome" placeholder="Provide seasonal strategy DOME file here">
                                <!--<textarea name="agmip_dome_urls" class="form-control" placeholder="Provide the URLs of your AgMIP DOMNE files, use new line to separate them..."></textarea>-->
                            </div>
                            <div class="form-group col-sm-12">
                                <label class="control-label">Linkage Files:</label>&nbsp;&nbsp;
                                <!--<input type="checkbox" name="agmip_linkage_switch">-->
                                <input type="file" id="agmip_linkage_file" class="form-control" accept=".xlsx,.xls,.csv,.alnk" placeholder="Provide linkage file here">
                                <!--<textarea name="agmip_linkage_url" class="form-control" placeholder="Provide the URLs of your AgMIP linkage file, use new line to separate them..."></textarea>-->
                            </div>
                        </fieldset>
                        <fieldset class="col-sm-12">
                            <legend>Output setting:<span class="glyphicon glyphicon-info-sign btn" data-toggle="tooltip" title="Provide output configuration"></span></legend>
                            <div class="form-group col-sm-6">
                                <label class="control-label">Output to :</label>
                                <div class="input-group col-sm-12">
                                    <select id="agmip_output_models" class="form-control chosen-select" data-placeholder="Choose one or more data format..." multiple>
                                        <option value=""></option>
                                        <option value="ACEB">ACE Binary</option>
                                        <option value="DSSAT">DSSAT</option>
                                        <option value="APSIM">APSIM</option>
                                        <option value="InfoCrop">InfoCrop</option>
                                        <option value="CropGrow-NAU">CropGrow-NAU</option>
                                        <!--<option value="JSON">JSON</option>-->
                                    </select>
                                </div>
                            </div>
                            <div class="form-group col-sm-6">
                                <label class="control-label">Options :</label>
                                <div class="col-sm-12">
                                    <label class="col-sm-5" >Run validation<span class="glyphicon glyphicon-info-sign btn" data-toggle="tooltip" title="Run validation to check if dataset is fulfilled minimum requirements for running model"></span></label>
                                    <input type="checkbox" id="agmip_dome_validation_switch" class="col-sm-7" data-toggle="toggle" data-size="mini" data-on="On" data-off="Off" disabled>
                                </div>
                            </div>
                        </fieldset>
                        <hr/>
                        <div class="col-sm-12">
                            <button type="button" name="submit_btn" class="btn btn-primary" onclick="executeJobs()"><span class="glyphicon glyphicon-cloud-upload"></span>&nbsp;&nbsp;Submit</button>
                        </div>
                    </div>
                </div>
                <div id="agmip_json_tab" class="tab-pane fade">
                    <div class="col-sm-6" style="overflow: auto;height: 600px">
                        <div id="agmip_json_content_tree"></div>
                    </div>
                    <div class="col-sm-6">
                        <textarea class="form-control" rows="30" id="agmip_json_content_text" style="font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;" readonly></textarea>
                    </div>
                </div>
                
                <div id="agmip_result_tab" class="tab-pane fade">
                    <div class="subcontainer">
                        <fieldset class="col-sm-6">
                            <legend>Translated Model Input Files: (click to save the files)</legend>
                            <div id="agmip_result_files">
                                <button id="dssat_file_btn" type="button" class="btn btn-success">DSSAT</button>
                                <button id="apsim_file_btn" type="button" class="btn btn-success">APSIM</button>
                            </div>
                        </fieldset>
                        <fieldset class="col-sm-6">
                            <legend>ACE Files: (click to save the files)</legend>
                            <div id="agmip_result_files">
                                <button id="aceb_file_btn" type="button" class="btn btn-success">ACEB</button>
                                <button id="dome_file_btn" type="button" class="btn btn-success">DOME</button>
                                <button id="alnk_file_btn" type="button" class="btn btn-success" onclick="saveFile('alnk', true)">Linkage</button>
                                <button id="json_file_btn" type="button" class="btn btn-success" onclick="saveFile('json', true)">JSON</button>
                            </div>
                        </fieldset>
                        <fieldset class="col-sm-12">
                            <legend>Tranlation Process Log:</legend>
                            <textarea class="form-control" rows="30" id="agmip_log_content_text" style="font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;" readonly></textarea>
                        </fieldset>
                    </div>
                </div>
            </div>
        </div>

        <#include "../footer.ftl">
        <script type="text/javascript" src="${env_path_web_root}js/bootbox/dragable.js" charset="utf-8"></script>
        <script type="text/javascript" src='${env_path_web_root}plugins/FileSaver/FileSaver.min.js'></script>
        <script type="text/javascript" src='${env_path_web_root}plugins/jszip/jszip.min.js'></script>
        <script type="text/javascript" src="${env_path_web_root}js/sheetjs/shim.js" charset="utf-8"></script>
        <script type="text/javascript" src="${env_path_web_root}js/sheetjs/xlsx.full.min.js"></script>
        <script type="text/javascript" src="${env_path_web_root}plugins/filestyle/bootstrap-filestyle.min.js"></script>
        <script type="text/javascript" src="${env_path_web_root}plugins/chosen/chosen.jquery.min.js" ></script>
        <script type="text/javascript" src="${env_path_web_root}plugins/chosen/prism.js" charset="utf-8"></script>
        <script type="text/javascript" src="${env_path_web_root}plugins/jsonViewer/jquery.json-viewer.js" charset="utf-8"></script>
        <script type="text/javascript" src="${env_path_web_root}js/chosen/init.js" charset="utf-8"></script>
        <script type="text/javascript" src="${env_path_web_root}js/dataReader/BufferedFileReader.js"></script>
        <script type="text/javascript" src="${env_path_web_root}js/dataReader/RemoteFileReader.js"></script>
        <script type="text/javascript" src="${env_path_web_root}js/util/dateUtil.js"></script>
        <script type="text/javascript" src="${env_path_web_root}js/toggle/bootstrap-toggle.min.js" charset="utf-8"></script>
        <script>
            $(document).ready(function () {
                chosen_init_all();
//                chosen_init_all($("#translation_tab"));
                $(":file").each(function () {
                    $(this).filestyle({htmlIcon: '<span class="glyphicon glyphicon-folder-open"></span>', text:'&nbsp;&nbsp;Browse', btnClass:'btn-primary', badge:true, placeholder:$(this).prop("placeholder")});
                });
                $('[data-toggle="tooltip"]').tooltip();
//                $("#openFileMenu").click();
            });
        </script>    
    </body>
</html>
