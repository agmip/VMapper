
<!DOCTYPE html>
<html>
    <head>
        <#include "../header.ftl">
        <#include "../chosen.ftl">
        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/handsontable-pro@latest/dist/handsontable.full.min.css">
        <script>
            let wbObj;
            let spsContainer;
            let spreadsheet;
            let curSheetName;
            let templates = {};
            let fileName;
            let icasaVarMap = {
                "management" : {
                    <#list icasaMgnVarMap?values?sort_by("code_display")?sort_by("group")?sort_by("subset")?sort_by("dataset") as var>
                    "${var.code_display}" : {
                        code_display : "${var.code_display}",
                        description : "${var.description}",
                        unit_or_type : "${var.unit_or_type}",
                        dataset : "${var.dataset}",
                        subset : "${var.subset}",
                        group : "${var.group}",
                        agmip_data_entry : "${var.agmip_data_entry}",
                        category : "${var.dataset} / ${var.subset} / ${var.group}"
                    }<#sep>,</#sep>
                    </#list>    
                },
                "observation" : {
                    <#list icasaObvVarMap?values?sort_by("code_display")?sort_by("group")?sort_by("subset")?sort_by("dataset") as var>
                    "${var.code_display}" : {
                        code_display : "${var.code_display}",
                        description : "${var.description}",
                        unit_or_type : "${var.unit_or_type}",
                        dataset : "${var.dataset}",
                        subset : "${var.subset}",
                        group : "${var.group}",
                        agmip_data_entry : "${var.agmip_data_entry}",
                        category : "${var.dataset} / ${var.subset} / ${var.group}"
                    }<#sep>,</#sep>
                    </#list>   
                }
            };
            
            function getFileName(fileFullName) {
                if (!fileFullName) {
                    return fileFullName;
                }
                let lastDot = fileFullName.lastIndexOf(".");
                if (lastDot < 0) {
                    return fileFullName;
                } else {
                    return fileFullName.substring(0, lastDot);
                }
            }
            
            function readSpreadSheet(target) {
                let files = target.files;
                let f = files[0];
                if (!fileName) {
                    fileName = getFileName(f.name);
                }
                let reader = new FileReader();
                reader.onload = function(e) {
                    let data = e.target.result;
//                    data = new Uint8Array(data);
                    let workbook = XLSX.read(data, {type: 'binary'});
                    
                    $("#sheet_csv_content").html(to_csv(workbook));
                    $("#sheet_json_content").html(to_json(workbook));
                    
                    wbObj = to_object(workbook);
                    $('#sheet_tab_list').empty();
                    for (let sheetName in wbObj) {
                        $('#sheet_tab_list').append('<li><a data-toggle="tab" href="#spreadshet_tab" id="' + sheetName + '" onclick="setSpreadsheet(this);">' + sheetName + '</a></li>');
                    }
//                    $("#sheet_spreadsheet_content").html("");
                    $('#sheet_tab_list').find("a").first().click();
                };
                reader.readAsBinaryString(f);
            }
            
            function to_json(workbook) {
                return JSON.stringify(to_object(workbook), 2, 2);
            }
            
            function to_object(workbook) {
                var result = {};
                workbook.SheetNames.forEach(function(sheetName) {
                    var roa = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], {header:1});
                    if (roa.length) {
                        if (roa.length > 0) {
                            // store sheet data
                            let headers = roa[0];
                            roa.shift();
                            result[sheetName] = {};
                            result[sheetName].header = headers;
                            result[sheetName].data = roa;
                            
                            // init template structure
                            if (!templates[sheetName]) {
                                templates[sheetName] = {};
                                templates[sheetName].headers = [];
                                for (let i = 0; i < headers.length; i++) {
                                    templates[sheetName].headers.push({header: headers[i]});
                                }
                            } else {
                                // Load existing template definition and do unit convertion
                                // TODO
                            }
                        }
                    }
                });
                return result;
            }
            
            function to_csv(workbook) {
                let result = [];
                workbook.SheetNames.forEach(function(sheetName) {
                    var csv = XLSX.utils.sheet_to_csv(workbook.Sheets[sheetName]);
                    if(csv.length){
                        result.push("SHEET: " + sheetName);
                        result.push("");
                        result.push(csv);
                    }
                });
                return result.join("\n");
            }
            
            function setSpreadsheet(target) {
                $("#sheet_name_selected").text(" <" + target.id + ">");
                curSheetName = target.id;
                initSpreadsheet(target.id);
            }
            
            function initSpreadsheet(sheetName, spsContainer) {
                if (!spsContainer) {
                    spsContainer = document.querySelector('#sheet_spreadsheet_content');
                }
                if (spreadsheet) {
                    spreadsheet.destroy();
                }
                let minRows = 10;
                let data = wbObj[sheetName].data;
                let headers = wbObj[sheetName].header;
                let columns = [];
                for (let i in headers) {
                    columns.push({type: 'text', id : headers[i]});
                }
                
                let spsOptions = {
                    licenseKey: 'non-commercial-and-evaluation',
                    data: data,
                    columns: columns,
                    stretchH: 'all',
        //                    width: 500,
                    autoWrapRow: true,
        //                    height: 450,
                    minRows: minRows,
                    maxRows: 365 * 30,
                    manualRowResize: true,
                    manualColumnResize: true,
                    rowHeaders: true,
                    colHeaders: headers,
//                    headerTooltips: true,
//                    afterChange: function(changes, src) {
//                        if(changes){
//                            
//                        }
//                    },
                    manualRowMove: true,
                    manualColumnMove: true,
                    filters: true,
                    dropdownMenu: true,
                    contextMenu: {
                        items: {
                            "new_column":{
                                name: "New Column",
            //                    hidden: function () { // `hidden` can be a boolean or a function
            //                        // Hide the option when the first column was clicked
            //                        return this.getSelectedLast()[1] == 0; // `this` === hot3
            //                    },
                                callback: function(key, selection, clickEvent) {
                                    setTimeout(function() {
                                        alertBox("Functionality under construction...");
                                    }, 0); // Fire alert after menu close (with timeout)
                                }
                            },
                            "define_column":{
                                name: "Define Column",
                                disabled: function () {
                                    // disable the option when the multiple columns were selected
                                    let range = this.getSelectedLast();
                                    return range[1] !== range[3];
                                },
                                callback: function(key, selection, clickEvent) {
                                    setTimeout(function() {
                                        let data = {};
                                        data.colIdx = selection[0].start.col;
                                        data.header = spreadsheet.getColHeader(data.colIdx);
                                        let colDef = templates[curSheetName].headers[data.colIdx];
                                        data.code_display = colDef.code_display;
                                        data.icasa_unit = colDef.icasa_unit;
                                        data.source_unit = colDef.source_unit;
                                        data.description = colDef.description;
                                        showColDefineDialog(data);
                                    }, 0); // Fire alert after menu close (with timeout)
                                }
                            },
                            "remove_column":{
                                name: "Remove Column",
            //                    hidden: function () { // `hidden` can be a boolean or a function
            //                        // Hide the option when the first column was clicked
            //                        return this.getSelectedLast()[1] == 0; // `this` === hot3
            //                    },
                                callback: function(key, selection, clickEvent) {
                                    setTimeout(function() {
                                        alertBox("Functionality under construction...");
                                    }, 0); // Fire alert after menu close (with timeout)
                                }
                            },
                            "sep2": '---------',
                            "row_above": {},
                            "row_below": {},
                            "remove_row": {},
                            "sep1": '---------',
                            "undo": {},
                            "redo": {},
                            "cut": {},
                            "copy": {},
                            "clear":{
                                name : "clear",
                                callback: function(key, selection, clickEvent) { // Callback for specific option
                                    setTimeout(function() {
                                        alert('Hello world!'); // Fire alert after menu close (with timeout)
                                    }, 0);
                                }}
                        }
                    }
                };
                spreadsheet = new Handsontable(spsContainer, spsOptions);
            }

            function showColDefineDialog(itemData, type) {
//                let promptClass = 'event-input-' + itemData.event;
                let curVarType;
                if (!type) {
                    if (itemData.code_display) {
                        if (icasaVarMap.management[itemData.code_display] || icasaVarMap.observation[itemData.code_display]) {
                            type = "icasa";
                        } else if (itemData.reference) {
                            type = "reference";
                        } else {
                            type = "customized";
                        }
                    } else {
                        type = "icasa";
                    }
                }
                let buttons = {
                    cancel: {
                        label: "Cancel",
                        className: 'btn-default',
                        callback: function() {}
                    },
//                    back: {
//                        label: "&nbsp;Back&nbsp;",
//                        className: 'btn-default',
//                        callback: function(){
//                            showEventTypePrompt(itemData.id, itemData.event);
//                        }
//                    },
                    ok: {
                        label: "&nbsp;Save&nbsp;",
                        className: 'btn-primary',
                        callback: function(){
                            let subDiv = $(this).find("[name=" + curVarType + "]");
                            if (!itemData.err_msg) {
                                let colDef = templates[curSheetName].headers[itemData.colIdx];
                                colDef.code_display = subDiv.find("[name='code_display']").val();
                                colDef.icasa_unit = subDiv.find("[name='icasa_unit']").val();
                                colDef.source_unit = subDiv.find("[name='source_unit']").val();
                                colDef.description = subDiv.find("[name='description']").val();
                            } else {
                                itemData.code_display = subDiv.find("[name='code_display']").val();
                                itemData.icasa_unit = subDiv.find("[name='icasa_unit']").val();
                                itemData.source_unit = subDiv.find("[name='source_unit']").val();
                                itemData.description = subDiv.find("[name='description']").val();
                                showColDefineDialog(itemData, type);
                            }
                        }
                    }
                };
//                if (editFlg) {
//                    delete buttons.cancel.callback;
//                }
//                if (noBackFlg) {
//                    delete buttons.back;
//                } 
                let dialog = bootbox.dialog({
                    title: "<h2>Column Definition</h2>",
                    size: 'large',
                    message: $("#col_define_popup").html(),
                    buttons: buttons
                });
                dialog.on("shown.bs.modal", function() {
                    if (itemData.err_msg) {
                        dialog.find("[name='dialog_msg']").text(itemData.err_msg);
                    }
                    dialog.find("[name=header]").each(function () {
                        $(this).val(itemData[$(this).attr("name")]);
                    });
                    dialog.find("[name=" + type + "_info]").find(".col-def-input-item").each(function () {
                        $(this).val(itemData[$(this).attr("name")]);
                    });
                    dialog.find("[name='icasa_info']").each(function () {
                        let subDiv = $(this);
                        subDiv.on("icasa_shown", function() {
                            chosen_init_name(subDiv.find("[name='code_display']"), "chosen-select-deselect");
                        });
                        subDiv.find("[name='code_display']").each(function () {
                            $(this).on("change", function () {
                                var unit = icasaVarMap.management[$(this).val()].unit_or_type;
                                subDiv.find("[name='icasa_unit']").val(unit);
                                subDiv.find("[name='source_unit']").val(unit);
                            });
                        });
                        subDiv.find("[name='source_unit']").each(function () {
                            $(this).on("input", function () {
                                $.get("/data/unit/convert?unit_to=" + subDiv.find("[name='icasa_unit']").val() + "&unit_from="+ $(this).val() + "&value_from=1",
                                    function (jsonStr) {
                                        var result = JSON.parse(jsonStr);
                                        if (result.status !== "0") {
                                            subDiv.find("[name='unit_validate_result']").html("Not compatiable unit");
                                            itemData.err_msg = "Please fix source unit expression";
                                        } else {
                                            subDiv.find("[name='unit_validate_result']").html("");
                                            delete itemData.err_msg;
                                        }
                                    }
                                );
                            });
                        });
                    });
                    dialog.find("[name='customized_info']").each(function () {
                        let subDiv = $(this);
                        subDiv.find("[name='source_unit']").each(function () {
                            $(this).on("input", function () {
                                $.get("/data/unit/lookup?unit=" + $(this).val(),
                                    function (jsonStr) {
                                        var unitInfo = JSON.parse(jsonStr);
                                        if (unitInfo.message === "undefined unit expression") {
                                            subDiv.find("[name='unit_validate_result']").html("Not compatiable unit");
                                            itemData.err_msg = "Please fix source unit expression";
                                        } else {
                                            subDiv.find("[name='unit_validate_result']").html("");
                                            delete itemData.err_msg;
                                        }
                                    }
                                );
                            });
                        });
                    });
                    dialog.find("[name='var_type']").each(function () {
                        $(this).on("change", function () {
                            type = $(this).val();
                            if (curVarType) {
                                dialog.find("[name=" + curVarType + "]").fadeOut("fast", function () {
                                    curVarType = type + "_info";
                                    dialog.find("[name=" + curVarType + "]").fadeIn().trigger("icasa_shown");
                                });
                            } else {
                                curVarType = type + "_info";
                                dialog.find("[name=" + curVarType + "]").fadeIn().trigger("icasa_shown");
                            }
                        });
                        $(this).val(type);
                        chosen_init_name($(this), "chosen-select");
                        $(this).trigger("change");
                    });
                });
            }
            
            function convertUnit() {
                // TODO
            }
            
            function initIcasaLookupSB() {
                let varSB = $("[name='icasa_info']").find("[name='code_display']");
                varSB.append('<option value=""></option>');
                let mgnOptgroup = $('<optgroup label="Managament variable"></optgroup>');
                varSB.append(mgnOptgroup);
//                let category = "";
//                let optgroup;
                let mgnVarMap = icasaVarMap.management;
                for (let varName in mgnVarMap) {
//                    if (!optgroup || mgnVarMap[varName].category !== category) {
//                        optgroup = $('<optgroup label="' + mgnVarMap[varName].category + '"></optgroup>');
//                        mgnOptgroup.append(optgroup);
//                        category = mgnVarMap[varName].category;
//                    }
//                    mgnOptgroup.append('<option value="' + varName + '">' + mgnVarMap[varName].category + " : " + mgnVarMap[varName].description + ' - ' + varName + ' (' + mgnVarMap[varName].unit_or_type +  ')</option>');
                    mgnOptgroup.append('<option value="' + varName + '">' + mgnVarMap[varName].description + ' - ' + varName + ' (' + mgnVarMap[varName].unit_or_type +  ')</option>');
                }
                
                let obvOptgroup = $('<optgroup label="Observation variable"></optgroup>');
                varSB.append(obvOptgroup);
                let obvVarMap = icasaVarMap.observation;
                for (let varName in obvVarMap) {
                    obvOptgroup.append('<option value="' + varName + '">' + obvVarMap[varName].description + ' - ' + varName + ' (' + obvVarMap[varName].unit_or_type +  ')</option>');
                }
            }
            
            function openExpDataFile() {
                $('<input type="file" accept=".xlsx,.xls" onchange="readSpreadSheet(this);">').click();
            }
            
            function openExpDataFolderFile() {
                alertBox("Functionality under construction...");
            }
            
            function saveExpDataFile() {
                alertBox("Functionality under construction...");
            }
            
            function saveAcebFile() {
                alertBox("Functionality under construction...");
            }
            
            function openTemplateFile() {
                alertBox("Functionality under construction...");
//                $('<input type="file" accept=".json,.sidecar2" onchange="readSpreadSheet(this);">').click();
            }
            
            function saveTemplateFile() {
                let text = JSON.stringify(templates, 2, 2);
                let ext = "sidecar2";
                let blob = new Blob([text], {type: "text/plain;charset=utf-8"});
                saveAs(blob, fileName + "." + ext);
            }
            
            function alertBox(msg) {
                bootbox.alert({
                    message: msg,
                    backdrop: true
                });
            }
        </script>
    </head>

    <body>

        <#include "../nav.ftl">

        <div class="container"></div>
        <div class="container-fluid">
            <div class="">
                <div class="btn-group">
                    <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" disabled>
                        Experiment Data <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu" role="menu">
                        <li onclick="openExpDataFile()"><a href="#"><span class="glyphicon glyphicon-open"></span> Load file</a></li>
                        <li onclick="openExpDataFolderFile()"><a href="#"><span class="glyphicon glyphicon-open"></span> Load folder</a></li>
                        <li onclick="saveExpDataFile()"><a href="#"><span class="glyphicon glyphicon-save"></span> Save</a></li>
                        <li onclick="saveAcebFile()"><a href="#"><span class="glyphicon glyphicon-export"></span> To Aceb</a></li>
                    </ul>
                </div>
                <div class="btn-group">
                    <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown" disabled>
                        Template <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu" role="menu">
                        <li onclick="openTemplateFile()"><a href="#"><span class="glyphicon glyphicon-open"></span> Load Existed Template</a></li>
                        <li onclick="saveTemplateFile()"><a href="#"><span class="glyphicon glyphicon-save"></span> Save Template</a></li>
                    </ul>
                </div>
<!--                <button type="button" class="btn btn-primary" onclick="openFile()"><span class="glyphicon glyphicon-open"></span> Load</button>
                <button type="button" class="btn btn-primary" onclick="saveFile()"><span class="glyphicon glyphicon-save"></span> Save</button>-->
            </div>
            <br/>
            <ul class="nav nav-tabs">
                <li class="active dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">Spreadsheet
                        <span id="sheet_name_selected"></span>
                        <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu" id="sheet_tab_list">
                    </ul>
                </li>
                <li><a data-toggle="tab" href="#csv_tab">CSV</a></li>
                <li><a data-toggle="tab" href="#json_tab">JSON</a></li>
                <li id="templateTab"><a data-toggle="tab" href="#template_tab">Template</a></li>
            </ul>
            <div class="tab-content">
                <div id="spreadshet_tab" class="tab-pane fade in active">
                    <!--<div class="row">-->
                    <div id="sheet_spreadsheet_content" class="col-sm-12"></div>
                    <!--</div>-->
                </div>
                <div id="csv_tab" class="tab-pane fade">
                    <textarea class="form-control" rows="30" id="sheet_csv_content" style="font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;" readonly></textarea>
                </div>
                <div id="json_tab" class="tab-pane fade">
                    <textarea class="form-control" rows="30" id="sheet_json_content" style="font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;" readonly></textarea>
                </div>
                <div id="template_tab" class="tab-pane fade">
                    <textarea class="form-control" rows="30" id="template_json_content" style="font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;" readonly></textarea>
                </div>
            </div>
        </div>
        <!-- popup page for define column -->
        <div id="col_define_popup" hidden>
            <p name="dialog_msg"></p>
            <div class="col-sm-12">
                <!-- 1st row -->
                <div class="form-group col-sm-6">
                    <label class="control-label">Column Header</label>
                    <div class="input-group col-sm-12">
                        <input type="text" name="header" class="form-control col-def-input-item" value="" readonly>
                    </div>
                </div>
                <div class="form-group col-sm-6">
                    <label class="control-label">Variable Type</label>
                    <div class="input-group col-sm-12">
                        <select name="var_type" class="form-control" data-placeholder="Choose a variable type...">
                            <option value=""></option>
                            <option value="icasa">ICASA variable</option>
                            <option value="customized">Customized variable</option>
                            <option value="reference">Reference variable</option>
                        </select>
                    </div>
                </div>
                <!-- ICASA Management Variable Info -->
                <div name="icasa_info" hidden>
                    <!-- 2nd row -->
                    <div class="form-group col-sm-12">
                        <label class="control-label">ICASA Variable</label>
                        <div class="input-group col-sm-12">
                            <select name="code_display" class="form-control col-def-input-item" data-placeholder="Choose a variable...">
                            </select>
                        </div>
                    </div>
                    <!-- 3rd row -->
                    <div class="form-group col-sm-4">
                        <label class="control-label">ICASA Unit</label>
                        <div class="input-group col-sm-12">
                            <input type="text" name="icasa_unit" class="form-control col-def-input-item" value="" readonly>
                        </div>
                    </div>
                    <div class="form-group col-sm-4">
                        <label class="control-label">Original Unit</label>
                        <div class="input-group col-sm-12">
                            <input type="text" name="source_unit" class="form-control col-def-input-item" value="">
                        </div>
                    </div>
                    <div class="form-group col-sm-4">
                        <label class="control-label"></label>
                        <div class="input-group col-sm-12" name="unit_validate_result"></div>
                    </div>
                </div>
                <div name="customized_info" hidden>
                    <!-- 2nd row -->
                    <div class="form-group col-sm-12">
                        <label class="control-label">Variable Code</label>
                        <div class="input-group col-sm-12">
                            <input type="text" name="code_display" class="form-control col-def-input-item" value="">
                        </div>
                    </div>
                    <!-- 3rd row -->
                    <div class="form-group col-sm-12">
                        <label class="control-label">Description</label>
                        <div class="input-group col-sm-12">
                            <input type="text" name="description" class="form-control col-def-input-item" value="">
                        </div>
                    </div>
                    <!-- 4th row -->
                    <div class="form-group col-sm-12">
                        <label class="control-label">Unit</label>
                        <div class="input-group col-sm-12">
                            <input type="text" name="source_unit" class="form-control col-def-input-item" value="">
                        </div>
                    </div>
                    <div class="form-group col-sm-12">
                        <label class="control-label"></label>
                        <div class="input-group col-sm-12" name="unit_validate_result"></div>
                    </div>
                </div>
                <div name="reference_info" hidden>
                    reference under construction...
                </div>
            </div>
            <p>&nbsp;</p>
        </div>

        <#include "../footer.ftl">
        <script type="text/javascript" src='/plugins/FileSaver/FileSaver.js'></script>
        <script src="http://oss.sheetjs.com/js-xlsx/shim.js"></script>
        <script src="http://oss.sheetjs.com/js-xlsx/xlsx.full.min.js"></script>
        <script type="text/javascript" src="/plugins/filestyle/bootstrap-filestyle.min.js"></script>
        <script type="text/javascript" src="/plugins/chosen/chosen.jquery.min.js" ></script>
        <script type="text/javascript" src="/plugins/chosen/prism.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/chosen/init.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/dataReader/BufferedFileReader.js"></script>
        <script type="text/javascript" src="/js/bootbox/bootbox.all.min.js" charset="utf-8"></script>
        <script src="https://cdn.jsdelivr.net/npm/handsontable@6.2.2/dist/handsontable.full.min.js"></script>
        
        <script>
            $(document).ready(function () {
                initIcasaLookupSB();
                chosen_init_all();
                $('.nav-tabs #templateTab').on('shown.bs.tab', function(){
                    $("#template_json_content").html(JSON.stringify(templates, 2, 2));
                });
                $("button").prop("disabled", false);
            });
        </script>
    </body>
</html>

