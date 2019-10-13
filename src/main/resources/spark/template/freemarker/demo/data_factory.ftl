
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
            let workbook;
            let userVarMap = {};
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
                },
                "getPrimaryGroup" : function(varName) {
                    if (this.management[varName]) {
                        return this.management;
                    } else if (this.observation[varName]) {
                        return this.observation;
                    } else {
                        return null;
                    }
                },
                "getDefinition" : function(varName) {
                    let group = this.getPrimaryGroup(varName);
                    if (group) {
                        return group[varName];
                    } else {
                        return null;
                    }
                    
                },
                "getUnit" : function(varName) {
                    let group = this.getPrimaryGroup(varName);
                    if (group) {
                        return group[varName].unit_or_type;
                    } else {
                        return null;
                    }
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
                fileName = getFileName(f.name);
                userVarMap = {};
                let reader = new FileReader();
                reader.onload = function(e) {
                    let data = e.target.result;
//                    data = new Uint8Array(data);
                    workbook = XLSX.read(data, {type: 'binary'});
                    showSheetDefDialog(processData);
                };
                reader.readAsBinaryString(f);
            }
            
            function processData(ret) {
                if (ret) templates = ret;
                if (workbook) {
                    $("#sheet_csv_content").html(to_csv(workbook));
//                        $("#sheet_json_content").html(to_json(workbook));

                    wbObj = to_object(workbook);
                    $('#sheet_tab_list').empty();
                    for (let sheetName in templates) {
                        $('#sheet_tab_list').append('<li><a data-toggle="tab" href="#spreadshet_tab" id="' + sheetName + '" onclick="setSpreadsheet(this);">' + sheetName + '</a></li>');
                    }
    //                    $("#sheet_spreadsheet_content").html("");
                    $('#sheet_tab_list').find("a").first().click();
                }
            }
            
            function to_json(workbook) {
                return JSON.stringify(to_object(workbook), 2, 2);
            }
            
            function to_object(workbook) {
                var result = {};
                workbook.SheetNames.forEach(function(sheetName) {
                    if (!templates[sheetName]) {
                        return;
                    }
                    var roa = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], {header:1});
                    let sheetDef = templates[sheetName];
                    if (roa.length) {
                        if (roa.length > 0) {
                            // store sheet data
                            let headers = roa[sheetDef.header_row - 1];
                            result[sheetName] = {};
                            result[sheetName].header = headers;
                            result[sheetName].data = roa.slice(sheetDef.data_start_row - 1);
                            
                            // init template structure
                            if (!sheetDef.mappings) {    
                                sheetDef.mappings = [];
                                for (let i = 0; i < headers.length; i++) {
                                    let headerDef = {
                                        column_header : headers[i],
                                        column_index : i + 1
                                    };
                                    if (sheetDef.unit_row) {
                                        headerDef.unit = roa[sheetDef.unit_row - 1][i];
                                    }
                                    if (sheetDef.desc_row) {
                                        headerDef.description = roa[sheetDef.desc_row - 1][i];
                                    }
                                    let headerName = String(headerDef.column_header).toUpperCase();
                                    if (icasaVarMap.getDefinition(headerName)) {
                                        headerDef.icasa = headerName;
                                    } else if (icasaVarMap.getDefinition(headerDef.column_header)) {
                                        headerDef.icasa = headerDef.column_header;
                                    }
                                    if (headerDef.icasa) {
                                        let icasa_unit = icasaVarMap.getUnit(headerDef.icasa);
                                        if (headerDef.unit && headerDef.unit !== icasa_unit) {
                                            $.get(encodeURI("/data/unit/convert?unit_to=" + icasa_unit + "&unit_from="+ headerDef.unit + "&value_from=1"),
                                                function (jsonStr) {
                                                    var result = JSON.parse(jsonStr);
                                                    if (result.status !== "0") {
                                                        headerDef.unit = icasa_unit; // TODO this should change to give warning message
                                                    }
                                                }
                                            );
                                        } else if (!headerDef.unit) {
                                            headerDef.unit = icasa_unit;
                                        }
                                    }
                                    sheetDef.mappings.push(headerDef);
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
                let mappings = templates[sheetName].mappings;
                let columns = [];
                for (let i in mappings) {
                    if (mappings[i].unit === "date") {
                        columns.push({type: 'date', id : mappings[i]});
                    } else if (mappings[i].unit === "text" || mappings[i].unit === "code") {
                        columns.push({type: 'text', id : mappings[i]});
                    } else if (mappings[i].unit !== ""){
                        columns.push({type: 'numeric', id : mappings[i]});
                    } else {
                        columns.push({type: 'text', id : mappings[i]});
                    }
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
                    colHeaders: function (col) {
                        var txt = '<input type="checkbox" name="' + sheetName + '_' + col + '"';
                        if (mappings[col].ignored_flg) {
                            txt += 'onchange=toggleIgnoreColumn(' + col + ');> ';
                        } else {
                            txt += 'checked onchange=toggleIgnoreColumn(' + col + ');> ';
                        }
                        if (mappings[col].column_header) {
                            txt += mappings[col].column_header;
                        } else {
                            txt += "N/a_" + col;
                        }
                        return txt;
                    },
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
                                    let selection = this.getSelected();
                                    return range[1] !== range[3] || selection.length !== 1;
                                },
                                callback: function(key, selection, clickEvent) {
                                    setTimeout(function() {
                                        let data = {};
                                        let colIdx = selection[0].start.col;
//                                        data.column_header = spreadsheet.getColHeader(data.colIdx);
                                        let colDef = templates[curSheetName].mappings[colIdx];
                                        Object.assign(data, colDef);
                                        showColDefineDialog(data);
                                    }, 0); // Fire alert after menu close (with timeout)
                                }
                            },
                            "ignore_column":{
                                name: "Ignore Column",
                                hidden: function () { // `hidden` can be a boolean or a function
                                    // Hide the option when it is ignored
                                    let selection = this.getSelected();
                                    for (let i in selection) {
                                        for (let j = selection[i][1]; j <= selection[i][3]; j++) {
                                            if ($("[name='" + curSheetName + "_" + j + "']").last().prop("checked")) {
                                                return false;
                                            }
                                        }
                                    }
                                    return true;
                                },
                                callback: function(key, selection, clickEvent) {
                                    setTimeout(function() {
                                        for (let i in selection) {
                                            for (let j = selection[i].start.col; j <= selection[i].end.col; j++) {
                                                let cb = $("[name='" + curSheetName + "_" + j + "']").last();
                                                cb.prop("checked", false).trigger("change");
                                            }
                                        }
                                    }, 0); // Fire alert after menu close (with timeout)
                                }
                            },
                            "include_column":{
                                name: "Include Column",
                                hidden: function () { // `hidden` can be a boolean or a function
                                    // Hide the option when it is ignored
                                    let selection = this.getSelected();
                                    for (let i in selection) {
                                        for (let j = selection[i][1]; j <= selection[i][3]; j++) {
                                            if (!$("[name='" + curSheetName + "_" + j + "']").last().prop("checked")) {
                                                return false;
                                            }
                                        }
                                    }
                                    return true;
                                },
                                callback: function(key, selection, clickEvent) {
                                    setTimeout(function() {
                                        for (let i in selection) {
                                            for (let j = selection[i].start.col; j <= selection[i].end.col; j++) {
                                                let cb = $("[name='" + curSheetName + "_" + j + "']").last();
                                                cb.prop("checked", true).trigger("change");
                                            }
                                        }
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
                                        alertBox('Hello world!'); // Fire alert after menu close (with timeout)
                                    }, 0);
                                }}
                        }
                    }
                };
                spreadsheet = new Handsontable(spsContainer, spsOptions);
            }

            function toggleIgnoreColumn(colIdx) {
                if ($("[name='" + curSheetName + "_" + colIdx + "']").last().prop("checked")) {
                    delete templates[curSheetName].mappings[colIdx].ignored_flg;
                } else {
                    templates[curSheetName].mappings[colIdx].ignored_flg = true;
                }
            }
            
            function convertUnit() {
                // TODO
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
                if (!workbook) {
                    alertBox("Please load spreadsheet file first, then apply SC2 file for it.");
                } else {
                    $('<input type="file" accept=".sc2.json,.json,.sc2" onchange="readSC2Json(this);">').click();
                }
            }

            function readSC2Json(target) {
                templates = {};
                var files = target.files;
                if (files.length !== 1) {
                    alertBox('Please select one file!');
                    return;
                }
                var file = files[0];
                var start = 0;
                var stop = file.size - 1;
                var reader = new FileReader();
                reader.onloadend = function (evt) {
                    if (evt.target.readyState === FileReader.DONE) { // DONE == 2
                        var jsonStr = evt.target.result;
//                        readSoilData(jsonStr);
                        
                        var sc2obj = JSON.parse(jsonStr);
                        if (sc2obj.agmip_translation_mappings) {
                            if (sc2obj.agmip_translation_mappings.length === 0) {
                                alertBox("No AgMIP mapping information detected, please try another file!");
                                return;
                            }
                            // Locate the correct file for reading mappings
                            let fileConfig;
                            for (let i in sc2obj.agmip_translation_mappings) {
                                fileConfig = sc2obj.agmip_translation_mappings[i];
                                if (fileConfig.file && fileConfig.file.file_metadata
                                        && fileName === fileConfig.file.file_metadata.file_name) {
                                    break;
                                } else {
                                    fileConfig = null;
                                }
                            }
                            // If no matched file name, then use first defition as default
                            if (!fileConfig) {
                                fileConfig = sc2obj.agmip_translation_mappings[0];
                            }
                            
                            if (!fileConfig.sheets) {
                                fileConfig.sheets = [];
                            }
                            // Load mapping for each sheet and fill missing column with ignore flag
                            for (let i in fileConfig.sheets) {
                                let sheetName = fileConfig.sheets[i].sheet_name;
                                if (!sheetName) sheetName = "" + i;
                                templates[sheetName] = Object.assign({}, fileConfig.sheets[i]);
                                if (!templates[sheetName].header_row) {
                                    templates[sheetName].header_row = 1;
                                }
                                if (!templates[sheetName].data_start_row) {
                                    templates[sheetName].data_start_row = templates[sheetName].header_row + 1;
                                }
                                let sc2Mappings = fileConfig.sheets[i].mappings;
                                let mappings = templates[sheetName].mappings;
                                mappings = [];
                                let curIdx = 0;
                                for (let j in sc2Mappings) {
                                    let colIdx = Number(sc2Mappings[j].column_index);
                                    for (let k = curIdx; k < colIdx; k++) {
                                        if (!mappings[k]) {
                                            mappings[k].push({
                                                column_index : k,
                                                ignored_flg : true
                                            });
                                        }
                                    }
                                    if (mappings[colIdx]) {
                                        mappings[colIdx] = sc2Mappings[j];
                                    } else {
                                        mappings.push(sc2Mappings[j]);
                                    }
                                }
                            }
                            processData();
                        }
                    }
                };

                var blob = file.slice(start, stop + 1);
                reader.readAsBinaryString(blob);
            }
            
            function saveTemplateFile() {
                if (!fileName) {
                    alertBox("Please load spreadsheet file first, then edit and save SC2 file for it.");
                } else {
                    let text = toSC2Json();
                    let ext = "-sc2.json";
                    let blob = new Blob([text], {type: "text/plain;charset=utf-8"});
                    saveAs(blob, fileName + ext);
                }
            }
            
            function toSC2Json(compressFlg) {
                if (compressFlg) {
                    return JSON.stringify(toSC2Obj());
                } else {
                    return JSON.stringify(toSC2Obj(), 2, 2);
                }
            }
            
            function toSC2Obj() {
                let sc2Obj = {
                    mapping_info : {
                        mapping_author : "data factory (http://dssat2d-plot.herokuapp.com/demo/data_factory)"
//                        source_url: ""
                    },
                    dataset_metadata : {},
                    agmip_translation_mappings : [
                        {
                            relations : [],
                            //Grab the primary keys from here if EXNAME is not defined
                            primary_ex_sheet : {
    //                            file : "",
    //                            sheet : "" 
                            },
                            file : {
                                file_metadata : {
                                    file_name : fileName,
                                    "content-type" : "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
                                    // file_url : ""
                                },
                                sheets : []
                            }
                        }
                    ],
                    xrefs : [
//                        {
//                          xref_provider : "gardian",
//                          xref_url : "https://gardian.bigdata.cgiar.org/dataset.php?id=5cd88b72317da7f1ae0cf390#!/"
//                        }
                    ]
                };
                
                for (let sheetName in templates) {
                    let tmp = Object.assign({}, templates[sheetName]);
                    tmp.mappings = [];
                    for (let i in templates[sheetName].mappings) {
                        if (!templates[sheetName].mappings[i].ignored_flg) {
                            tmp.mappings.push(templates[sheetName].mappings[i]);
                        }
                    }
                    sc2Obj.agmip_translation_mappings[0].file.sheets.push(tmp);
                }
                return sc2Obj;
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
                <li id="sheetTab" class="active dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">Spreadsheet
                        <span id="sheet_name_selected"></span>
                        <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu" id="sheet_tab_list">
                    </ul>
                </li>
                <li><a data-toggle="tab" href="#csv_tab">CSV</a></li>
                <li id="mappingTab"><a data-toggle="tab" href="#mapping_tab">Mappings Preview</a></li>
                <li id="SC2Tab"><a data-toggle="tab" href="#sc2_tab">SC2 Preview</a></li>
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
                <div id="mapping_tab" class="tab-pane fade">
                    <textarea class="form-control" rows="30" id="mapping_json_content" style="font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;" readonly></textarea>
                </div>
                <div id="sc2_tab" class="tab-pane fade">
                    <textarea class="form-control" rows="30" id="sc2_json_content" style="font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;" readonly></textarea>
                </div>
            </div>
        </div>

        <#include "data_factory_popup_row.ftl">
        <#include "data_factory_popup_column.ftl">
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
                $('.nav-tabs #sheetTab').on('shown.bs.tab', function(){
                    initSpreadsheet(curSheetName);
                });
                $('.nav-tabs #mappingTab').on('shown.bs.tab', function(){
                    $("#mapping_json_content").html(JSON.stringify(templates, 2, 2));
                });
                $('.nav-tabs #SC2Tab').on('shown.bs.tab', function(){
                    $("#sc2_json_content").html(toSC2Json());
                });
                $("button").prop("disabled", false);
            });
        </script>
    </body>
</html>

