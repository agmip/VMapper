
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
                }
            };
            
            function readSpreadSheet(target) {
                let files = target.files;
                let f = files[0];
                if (!fileName) {
                    fileName = f.name;
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
                                        alert('Hello world!');
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
                                        data.code_display = colDef.icasa_var;
                                        data.icasa_unit = colDef.icasa_unit;
                                        data.source_unit = colDef.source_unit;
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
                                        alert('Hello world!');
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

            function showColDefineDialog(itemData, noBackFlg, editFlg) {
//                let promptClass = 'event-input-' + itemData.event;
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
                            if (!itemData.err_msg) {
                                let colDef = templates[curSheetName].headers[itemData.colIdx];
                                colDef.icasa_var = $(this).find("[name='code_display']").val();
                                colDef.icasa_unit = $(this).find("[name='icasa_unit']").val();
                                colDef.source_unit = $(this).find("[name='source_unit']").val();
                            } else {
                                itemData.icasa_var = $(this).find("[name='code_display']").val();
                                itemData.icasa_unit = $(this).find("[name='icasa_unit']").val();
                                itemData.source_unit = $(this).find("[name='source_unit']").val();
                                showColDefineDialog(itemData, noBackFlg, editFlg);
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
                    dialog.find(".col-def-input-item").each(function () {
                        $(this).val(itemData[$(this).attr("name")]);
                    });
                    dialog.find("[name='code_display']").each(function () {
                        
                        chosen_init_name($(this), "chosen-select-deselect");
                        $(this).on("change", function () {
                            var unit = icasaVarMap.management[$(this).val()].unit_or_type;
                            dialog.find("[name='icasa_unit']").val(unit);
                            dialog.find("[name='source_unit']").val(unit);
                        });
                    });
                    dialog.find("[name='source_unit']").each(function () {
                        $(this).on("input", function () {
                            $.get("/data/unit/convert?unit_to=" + dialog.find("[name='icasa_unit']").val() + "&unit_from="+ $(this).val() + "&value_from=1",
                                function (jsonStr) {
                                    var result = JSON.parse(jsonStr);
                                    if (result.status !== "0") {
                                        dialog.find("[name='unit_validate_result']").html("Not compatiable unit");
                                        itemData.err_msg = "Please fix source unit expression";
                                    } else {
                                        dialog.find("[name='unit_validate_result']").html("");
                                        delete itemData.err_msg;
                                    }
                                }
                            );
                        });
                    });
                });
            }
            
            function convertUnit() {
                // TODO
            }
            
            function initIcasaLookupSB() {
                let varSB = $("[name='code_display']");
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
            }
            
            function openExpDataFile() {
                $('<input type="file" accept=".xlsx,.xls" onchange="readSpreadSheet(this);">').click();
            }
            
            function openExpDataFolderFile() {
                alert("functionality under construction...");
            }
            
            function saveExpDataFile() {
                alert("functionality under construction...");
            }
            
            function saveAcebFile() {
                alert("functionality under construction...");
            }
            
            function openTemplateFile() {
                $('<input type="file" accept=".json,.sidecar2" onchange="readSpreadSheet(this);">').click();
            }
            
            function openTemplateFile() {
                alert("functionality under construction...");
            }
            
            function saveTemplateFile() {
                alert("functionality under construction...");
            }
        </script>
    </head>

    <body>

        <#include "../nav.ftl">

        <div class="container"></div>
        <div class="container-fluid">
            <div class="">
                <div class="btn-group">
                    <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
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
                    <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
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
            </div>
        </div>
        <!-- popup page for define column -->
        <div id="col_define_popup" hidden>
            <p name="dialog_msg"></p>
            <div class="col-sm-12">
                <!-- 1st row -->
                <div class="form-group col-sm-12">
                    <label class="control-label">Column Header</label>
                    <div class="input-group col-sm-12">
                        <input type="text" name="header" class="form-control col-def-input-item" value="" readonly>
                    </div>
                </div>
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
                <!-- 3rd row -->
<!--                <div class="form-group col-sm-4">
                    <label class="control-label" for="cul_id">ICASA Format</label>
                    <div class="input-group col-sm-12">
                        <input type="date" name="start" class="form-control col-def-input-item" value="">
                    </div>
                </div>
                <div class="form-group col-sm-4">
                    <label class="control-label" for="fedep">Original Format</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="fedep" step="1" max="300" min="0" class="form-control" value="" placeholder="Fertilizer applied depth (cm)" data-toggle="tooltip" title="Fertilizer applied depth (cm)" oninput="rangeNumInput(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="fedep" step="1" max="999" min="0" class="form-control col-def-input-item max-5" value="" oninput="rangeNumInput(this)" >
                        </div>
                    </div>
                </div>-->
            </div>
            <p>&nbsp;</p>
        </div>

        <#include "../footer.ftl">
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
            });
        </script>
    </body>
</html>

