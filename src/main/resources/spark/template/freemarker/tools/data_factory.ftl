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
        <link rel="stylesheet" type="text/css" href="${env_path_web_root}plugins/fancytree/skin-xp/ui.fancytree.min.css" />
        <script>
            let result = {};
            let dataSetName;
            let curContent;
            
            function str2bytes (str) {
                let byteCharacters = window.atob(str);
                let byteNumbers = new Array(byteCharacters.length);
                for (let i = 0; i < byteCharacters.length; i++) {
                    byteNumbers[i] = byteCharacters.charCodeAt(i);
                }
                let byteArray = new Uint8Array(byteNumbers);
                 return byteArray;
             }
            
            function saveFile(key, isText) {
                if (isText) {
                    let content = result[key];
                    let blob = new Blob([content], {type: "text/plain;charset=utf-8"});
                    if (key === "linkage") {
                        saveAs(blob, dataSetName + ".alnk");
                    } else {
                        saveAs(blob, dataSetName + "." + key);
                    }
                } else {
                    let blob = new Blob([str2bytes(result[key])], {type: "application/octet-stream"});
                    let fileName = dataSetName + ".";
                    if (["aceb", "dome"].includes(key)) {
                        fileName = fileName + key;
                    } else {
                        fileName = key + "_input.zip";
                    }
                    saveAs(blob, fileName);
                }
            }
            
            function viewFile(key, isText) {
                $(":ui-fancytree").fancytree("destroy");
                if (isText) {
                    if (key === "json" || key === "dome_json") {
                        let jsonObj = JSON.parse(result[key]);
                        $("#agmip_preview_content_text").html(result[key]).fadeIn();
                        $("#agmip_preview_content_tree").jsonViewer(jsonObj, JSON.parse('{"collapsed":true,"rootCollapsable":false}')).fadeIn();
                    } else if (key === "linkage") {
                        $("#agmip_preview_content_text").html(result[key]).fadeIn();
                        $("#agmip_preview_content_tree").fadeOut();
                    } else {
                        $("#agmip_preview_content_text").html(result[key]).fadeIn();
                        $("#agmip_preview_content_tree").fadeOut();
                    }
                } else {
                    let blob = new Blob([str2bytes(result[key])], {type: "application/octet-stream"});
                    if (key === "dome") {
                        $("#agmip_preview_content_text").html(result[key]).fadeIn();
                        $("#agmip_preview_content_tree").fadeOut();
                    } else {
                        JSZip.loadAsync(blob).then(function(content){
                            curContent = content.files;
                            treeViewData = [{"title" : key + "_input.zip", "folder" : true, "expanded" : true, "children":zipFolderToTree(curContent)}];

                            $("#agmip_preview_content_tree").html("").fadeIn();
                            $("#agmip_preview_content_text").html("").fadeIn();
                            $("#agmip_preview_content_tree").fancytree({
                                checkbox: false,
                                autoScroll: true,
                                selectMode: 1,
                                source : treeViewData,
                                activate: function(event, data) {
                                    if (data.node.folder) {
                                        $("#agmip_preview_content_text").text("");
                                    } else if (data.node.data.content_text) {
                                        $("#agmip_preview_content_text").text(data.node.data.content_text);
                                    } else {
                                        data.node.data.content.async("text").then(function (text) {
                                            $("#agmip_preview_content_text").text(text);
                                            data.node.data.content_text = text;
                                        });
                                    }
                                    
                                }
                            });
                            $("#agmip_preview_content_text").html("").fadeIn();
                        });
                    }
                }
                
                function zipFolderToTree (content) {
                    let files = [];
                    let fileNames = Object.keys(content).sort();
                    for (let i = 0; i < fileNames.length; i++) {
                        let key = fileNames[i];
                        let node = {
                            "title" : key,
                            "folder" : content[key].dir,
                            "content" : ""
                        };
                        if (node.folder) {
                            node.children = zipFolderToTree(content[key]);
                        } else {
                            node.content = content[key];
                        }
                        files.push(node);
                    }
                    return files;
                }
                
                $("#AgMIPPreviewTab").fadeIn("fast", function () {$("#AgMIPPreviewTab a").click();});
            }
        
            function executeJobs() {
                result = null;
                dataSetName = null;
                curContent = null;
                let dialog = bootbox.dialog({
                    title: 'A translation job has been submitted',
                    message: '<p><img src="${env_path_web_root}images/loading.gif" alt="" style="width:10%;height:10%;"> Processing...</p>',
                    closeButton: false
                });
                $(":ui-fancytree").fancytree("destroy");
                $("#ace_result_files div").fadeOut();
                $("#model_result_files div").fadeOut();

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
                    $("#linkage_file_btn").fadeIn();
                });
                
                formData.append("models", $('#agmip_output_models').val());
                $("#agmip_preview_content_text").html("");
                
                fetch('${env_path_web_root}${env_path_web_data.getTRANSLATE()}', {method: "POST", body: formData}).then(function (response) {
                    if (response.ok) {
                        return response.json();
                    } else {
                        dialog.modal('hide');
                        alertBox(response.statusText);
                    }
                }).then(function(data) {
                    if (data) {
                        dialog.find('.bootbox-body').html('Translation is finished!');
                    }
                    if (!data || data.errors) {
                        dialog.modal('hide');
                        if (data && data.errors) {
                            alertBox(data.errors);
                        }
                    } else if (data) {
                        result = data;
                        dataSetName = data.data_set_name;
                        let jsonObj = JSON.parse(result.json);
                        result.json = JSON.stringify(jsonObj, 2, 2);
                        if (result.dome_json) {
                            let domeJsonObj = JSON.parse(result.dome_json);
                            result.dome_json = JSON.stringify(domeJsonObj, 2, 2);
                        }
                        $("#agmip_preview_content_text").html(result.json);
                        $("#agmip_preview_content_tree").jsonViewer(jsonObj, JSON.parse('{"collapsed":true,"rootCollapsable":false}'));
                        $("#agmip_log_content_text").html(result.log);
                        
                        for (key in result) {
                            if (!["log", "data_set_name", "aceb", "json"].includes(key)) {
                                $("#" + key + "_file_btn").fadeIn();
                            } else if (result.json) {
                                $("#ace_file_btn").fadeIn();
                            }
                        }
                        
                        dialog.modal('hide');
                        $("#AgMIPResultTab a").click();
                    }
                }).catch(function(err) {
                    dialog.modal('hide');
                    alertBox(err.message);
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
                <li id="TransTab" class="active"><a data-toggle="tab" href="#translation_tab">Setup</a></li>
                <li id="AgMIPResultTab" class="fade"><a data-toggle="tab" href="#agmip_result_tab">Result</a></li>
                <li id="AgMIPPreviewTab" class="fade"><a data-toggle="tab" href="#agmip_preview_tab">Data Preview</a></li>
            </ul>
            <div class="tab-content">
                
                <div id="translation_tab" class="tab-pane fade in active">
                    <div class="subcontainer">
                        <fieldset class="col-sm-6">
                            <legend>Source Data To Convert:<span class="glyphicon glyphicon-info-sign btn" data-toggle="tooltip" title="Please provide source Data with ICASA compitable format. You can run VMapper to process your data into such format."></span></legend>
                            <div class="form-group col-sm-12">
                                <label class="control-label">Source Data Files :</label>&nbsp;&nbsp;
                                <!--<input type="checkbox" name="agmip_data_switch">-->
                                <input type="file" id="agmip_data_files" class="form-control" accept=".wth,.agmip,.csv,.zip,.aceb" placeholder="Provide AgMIP input package or files here" multiple>
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
                                        <option value="JSON">ACE</option>
                                        <option value="DSSAT">DSSAT</option>
                                        <option value="APSIM">APSIM</option>
                                        <option value="SarraHV33">SarraH V33</option>
                                        <option value="InfoCrop">InfoCrop</option>
                                        <option value="STICS">STICS</option>
                                        <option value="WOFOST">WOFOST</option>
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
                <div id="agmip_result_tab" class="tab-pane fade">
                    <div class="subcontainer">
                        <fieldset class="col-sm-4">
                            <legend>ACE Files: <span class="glyphicon glyphicon-info-sign btn" data-toggle="tooltip" title="Click dropdown menu to see available operations for each type of result"></span></legend>
                            <form id="ace_result_files" class="form-inline">
                                <div id="ace_file_btn" class="dropdown form-group">
                                    <button class="btn btn-success dropdown-toggle" type="button" data-toggle="dropdown">Data
                                    <span class="caret"></span></button>
                                    <ul class="dropdown-menu">
                                        <li><a href="#" onclick="viewFile('json', true)">View</a></li>
                                        <li><a href="#" onclick="saveFile('aceb', false)">Save as ACE Binary (.aceb)...</a></li>
                                        <li><a href="#" onclick="saveFile('json', true)">Save as uncompressed JSON (.json)...</a></li>
                                    </ul>
                                </div>
                                <div id="dome_file_btn" class="dropdown form-group">
                                    <button class="btn btn-success dropdown-toggle" type="button" data-toggle="dropdown">DOME
                                    <span class="caret"></span></button>
                                    <ul class="dropdown-menu">
                                        <li><a href="#" onclick="viewFile('dome_json', true)">View</a></li>
                                        <li><a href="#" onclick="saveFile('dome')">Save as ...</a></li>
                                    </ul>
                                </div>
                                <div id="linkage_file_btn" class="dropdown form-group">
                                    <button class="btn btn-success dropdown-toggle" type="button" data-toggle="dropdown">Linkage
                                    <span class="caret"></span></button>
                                    <ul class="dropdown-menu">
                                        <li><a href="#" onclick="viewFile('linkage', true)">View</a></li>
                                        <li><a href="#" onclick="saveFile('linkage', true)">Save as ...</a></li>
                                    </ul>
                                </div>
                            </form>
                        </fieldset>
                        <fieldset class="col-sm-8">
                            <legend>Translated Model Input Files: <span class="glyphicon glyphicon-info-sign btn" data-toggle="tooltip" title="Click dropdown menu to see available operations for each type of result"></span></legend>
                            <form id="model_result_files" class="form-inline">
                                <div id="dssat_file_btn" class="dropdown form-group">
                                    <button class="btn btn-success dropdown-toggle" type="button" data-toggle="dropdown">DSSAT
                                    <span class="caret"></span></button>
                                    <ul class="dropdown-menu">
                                        <li><a href="#" onclick="viewFile('dssat')">View</a></li>
                                        <li><a href="#" onclick="saveFile('dssat')">Save as ...</a></li>
                                    </ul>
                                </div>
                                <div id="apsim_file_btn" class="dropdown form-group">
                                    <button class="btn btn-success dropdown-toggle" type="button" data-toggle="dropdown">APSIM
                                    <span class="caret"></span></button>
                                    <ul class="dropdown-menu">
                                        <li><a href="#" onclick="viewFile('apsim')">View</a></li>
                                        <li><a href="#" onclick="saveFile('apsim')">Save as ...</a></li>
                                    </ul>
                                </div>
                                <div id="sarrahv33_file_btn" class="dropdown form-group">
                                    <button class="btn btn-success dropdown-toggle" type="button" data-toggle="dropdown">SarraH V33
                                    <span class="caret"></span></button>
                                    <ul class="dropdown-menu">
                                        <li><a href="#" onclick="viewFile('sarrahv33')">View</a></li>
                                        <li><a href="#" onclick="saveFile('sarrahv33')">Save as ...</a></li>
                                    </ul>
                                </div>
                                <div id="infocrop_file_btn" class="dropdown form-group">
                                    <button class="btn btn-success dropdown-toggle" type="button" data-toggle="dropdown">InfoCrop
                                    <span class="caret"></span></button>
                                    <ul class="dropdown-menu">
                                        <li><a href="#" onclick="viewFile('infocrop')">View</a></li>
                                        <li><a href="#" onclick="saveFile('infocrop')">Save as ...</a></li>
                                    </ul>
                                </div>
                                <div id="stics_file_btn" class="dropdown form-group">
                                    <button class="btn btn-success dropdown-toggle" type="button" data-toggle="dropdown">STICS
                                    <span class="caret"></span></button>
                                    <ul class="dropdown-menu">
                                        <li><a href="#" onclick="viewFile('stics')">View</a></li>
                                        <li><a href="#" onclick="saveFile('stics')">Save as ...</a></li>
                                    </ul>
                                </div>
                                <div id="wofost_file_btn" class="dropdown form-group">
                                    <button class="btn btn-success dropdown-toggle" type="button" data-toggle="dropdown">WOFOST
                                    <span class="caret"></span></button>
                                    <ul class="dropdown-menu">
                                        <li><a href="#" onclick="viewFile('wofost')">View</a></li>
                                        <li><a href="#" onclick="saveFile('wofost')">Save as ...</a></li>
                                    </ul>
                                </div>
                                <div id="cropgrownau_file_btn" class="dropdown form-group">
                                    <button class="btn btn-success dropdown-toggle" type="button" data-toggle="dropdown">CropGrowNAU
                                    <span class="caret"></span></button>
                                    <ul class="dropdown-menu">
                                        <li><a href="#" onclick="viewFile('cropgrownau')">View</a></li>
                                        <li><a href="#" onclick="saveFile('cropgrownau', true)">Save as ...</a></li>
                                    </ul>
                                </div>
                            </form>
                        </fieldset>
                        <fieldset class="col-sm-12">
                            <legend>Translation Process Log:</legend>
                            <textarea class="form-control" rows="30" id="agmip_log_content_text" style="font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;" readonly></textarea>
                        </fieldset>
                    </div>
                </div>
                <div id="agmip_preview_tab" class="tab-pane fade">
                    <div class="col-sm-5" style="overflow: auto;height: 600px">
                        <div id="agmip_preview_content_tree"></div>
                    </div>
                    <div class="col-sm-7">
                        <textarea class="form-control" rows="30" id="agmip_preview_content_text" style="font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;" readonly></textarea>
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
        <script type="text/javascript" src="${env_path_web_root}plugins/fancytree/jquery.fancytree-all-deps.min.js" charset="utf-8"></script>
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
