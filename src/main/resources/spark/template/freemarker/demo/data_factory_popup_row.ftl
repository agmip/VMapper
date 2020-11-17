<script>
    function showSheetDefDialog(callback, errMsg, editFlg, sc2Obj) {
        let fileMap = {};
        let singleFileName;
        if (callback.name === "loadSC2Obj") {
            templates = {};
            if (sc2Obj.agmip_translation_mappings) {
                let isFullyMatched = true;
                
                let files = sc2Obj.agmip_translation_mappings.files;
                if (!files || files.length === 0) {
                    callback(sc2Obj);
                }
                for (let i in files) {
                    
                    let fileConfig = files[i];
                    // Load mapping for each sheet and fill missing column with ignore flag
                    let fileName = getMetaFileName(fileConfig.file.file_metadata);
                    if (!fileTypes[fileName]) {
//                        let contentType = fileConfig.file.file_metadata["content-type"];
                        for (let name in fileTypes) {
                            if (Object.keys(fileTypes).length === 1
//                                || name.startsWith(fileName) && (!contentType || fileTypes[name] === contentType)
                                ) {
                                // TODO need to revise the file auto-mapping
                                singleFileName = fileName;
//                                fileName = name;
                            }
                        }
                    }
                    if (!templates[fileName]) {
                        templates[fileName] = {};
                    }
                    for (let i in fileConfig.file.sheets) {
                        let sheetName = fileConfig.file.sheets[i].sheet_name;
                        templates[fileName][sheetName] = {};
                    }
                }
                for (let fileName in workbooks) {
                    let workbook = workbooks[fileName];
                    fileMap[fileName] = {};
                    if (templates[fileName]) {
                        workbook.SheetNames.forEach(function(sheetName) {
                            if (!templates[fileName][sheetName]) {
                                isFullyMatched = false;
                            } else {
                                fileMap[fileName][sheetName] = {sheet_name: sheetName, file_name: fileName, sheet_def: sheetName, file_def: fileName};
                            }
                        });
                    } else {
                        isFullyMatched = false;
                    }
                }
                if (isFullyMatched) {
                    callback(sc2Obj, fileMap);
                    return;
                }
            } else {
                callback(sc2Obj);
                return;
            }
        }
        let sheets = {};
        let headerStr;
        if (editFlg) {
            headerStr = "<h2>Row Definition</h2>";
            sheets = JSON.parse(JSON.stringify(templates));
//            if (!sheets[curFileName][curSheetName].header_row) {
//                sheets[curFileName][curSheetName].header_row = 1;
//            }
            if (!sheets[curFileName][curSheetName].data_start_row && sheets[curFileName][curSheetName].header_row) {
                sheets[curFileName][curSheetName].data_start_row = sheets[curFileName][curSheetName].header_row + 1;
            }
        } else {
            headerStr = "<h2>Sheet Definition</h2>";
            for (let fileName in workbooks) {
                let workbook = workbooks[fileName];
                sheets[fileName] = {};
                workbook.SheetNames.forEach(function(sheetName) {
//                workbook.worksheets.forEach(function(sheet) {
//                    let sheetName = sheet.name;
                    sheets[fileName][sheetName] = {};

                    sheets[fileName][sheetName].file_name = fileName;
                    sheets[fileName][sheetName].sheet_name = sheetName;
                    sheets[fileName][sheetName].included_flg = true;
                    sheets[fileName][sheetName].single_flg = false;
                    let roa = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], {header:1});
                    for (let i = roa.length; i >= 0; i--) {
                        if (roa[i] && roa[i].length > 0) {
                            roa.splice(i + 1, roa.length - i);
                            break;
                        }
                    }
    //                let roa = sheet_to_json(sheet);
                    if(roa.length){
                        for (let i in roa) {
                            if (!roa[i].length || roa[i].length === 0) {
                                continue;
                            }
                            let fstCell = String(roa[i][0]);
                            if (fstCell.startsWith("!")) {
                                if (!sheets[fileName][sheetName].unit_row && fstCell.toLowerCase().includes("unit")) {
                                    sheets[fileName][sheetName].unit_row = Number(i) + 1;
                                } else if (!sheets[fileName][sheetName].desc_row && 
                                        (fstCell.toLowerCase().includes("definition") || 
                                        fstCell.toLowerCase().includes("description"))) {
                                    sheets[fileName][sheetName].desc_row = Number(i) + 1;
                                }
                            } else if ((fstCell && fstCell === "#") || (fstCell && fstCell === "%")) {
                                if (!sheets[fileName][sheetName].header_row) {
                                    sheets[fileName][sheetName].header_row = Number(i) + 1;
                                }
                            } else if (sheets[fileName][sheetName].header_row && !sheets[fileName][sheetName].data_start_row) {
                                sheets[fileName][sheetName].data_start_row = Number(i) + 1;
                            }
                            if (Object.keys(sheets[fileName][sheetName]).length >= 7) {
                                break;
                            }
                        }
                    }

                    if (sheets[fileName][sheetName].data_start_row) {
                        sheets[fileName][sheetName].single_flg = isSingleRecordTable(roa, sheets[fileName][sheetName]);
                    }
                });
            }
            
        }
        let buttons = {
            cancel: {
                label: "Cancel",
                className: 'btn-default',
                callback: function() {}
            },
            ok: {
                label: "Confirm",
                className: 'btn-primary',
                callback: function(){
                    let idxErrFlg = false;
                    let repeatedErrFlg = false;
                    let includedCnt = 0;
                    for (let fileName in sheets) {
                        for (let sheetName in sheets[fileName]) {
                            if (!sheets[fileName][sheetName].data_start_row || !sheets[fileName][sheetName].header_row) {
                                idxErrFlg = true;
                            }
                            if (sheets[fileName][sheetName].included_flg) {
                                includedCnt++;
                                delete sheets[fileName][sheetName].included_flg;
                                let keys = ["data_start_row", "data_end_row", "header_row", "unit_row", "desc_row"];
                                for (let i = 0; i < keys.length; i++) {
                                    if (sheets[fileName][sheetName][keys[i]]) {
                                        for (let j = i + 1; j < keys.length; j++) {
                                            if (sheets[fileName][sheetName][keys[i]] === sheets[fileName][sheetName][keys[j]]) {
                                                if ((keys[i] !== "data_start_row" || keys[j] !== "data_end_row") &&
                                                    (keys[j] !== "data_start_row" || keys[i] !== "data_end_row")) {
                                                    repeatedErrFlg = true;
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                }
                            } else {
                                delete sheets[fileName][sheetName];
                            }
                        }
                    }
                    if (editFlg && sheets[curFileName][curSheetName].data_start_row) {
                        sheets[curFileName][curSheetName].single_flg = isSingleRecordTable(wbObj[curFileName][curSheetName].data, sheets[curFileName][curSheetName]);
                    }
//                    if (idxErrFlg) {
//                        showSheetDefDialog(callback, "[warning] Please provide header row number and data start row number.", editFlg);
//                    } else
                    if (includedCnt === 0) {
                        showSheetDefDialog(callback, "[warning] Please select at least one sheet for reading in.", editFlg, sc2Obj);
                    } else if (repeatedErrFlg) {
                        showSheetDefDialog(callback, "[warning] Please select different raw for each definition.", editFlg, sc2Obj);
                    }  else {
                        isViewUpdated = false;
                        isDebugViewUpdated = false;
                        if (callback.name === "loadSC2Obj") {
                            isChanged = false;
                            callback(sc2Obj, sheets);
                        } else {
                            isChanged = true;
                            callback(sheets, editFlg);
                        }
                    }
                }
            }
        };
        let dialog = bootbox.dialog({
            title: headerStr,
            size: 'large',
            message: $("#sheet_define_popup").html(),
            buttons: buttons
        });
        dialog.find(".modal-content").drags();
        dialog.on("shown.bs.modal", function() {
            if (errMsg) {
                dialog.find("[name='dialog_msg']").text(errMsg);
            }
            if (callback.name === "loadSC2Obj") {
                dialog.find("[name='mapping_def_desc']").fadeIn(0);
            } else {
                dialog.find("[name='mapping_def_desc']").fadeOut(0);
            }
            let data = [];
            let mergeCells = [];
            let columns = [
//                {type: 'text', data : "file_name", readOnly: true},
                {type: 'text', data : "sheet_name", readOnly: true},
                {type: 'numeric', data : "header_row"},
                {type: 'numeric', data : "data_start_row"},
                {type: 'numeric', data : "data_end_row"},
                {type: 'numeric', data : "unit_row"},
                {type: 'numeric', data : "desc_row"},
                {type: 'checkbox', data : "included_flg"}
            ];
            let colHeaders = ["Sheet", "Header Row #", "Data Start Row #", "Data End Row #", "Unit Row #", "Description Row #"];
            if (!editFlg) {
                if (Object.keys(templates).length === 0) {
                    columns = [
                        {type: 'text', data : "sheet_name", readOnly: true},
                        {type: 'checkbox', data : "included_flg"}
                    ];
                    colHeaders = ["Sheet", "Included"];
                } else {
                    if (Object.keys(templates).length > 1) {
                        columns = [
                            {type: 'text', data : "sheet_name", readOnly: true},
                            {type: 'dropdown', data : "file_def", source : []},
                            {type: 'dropdown', data : "sheet_def", source : []},
                            {type: 'checkbox', data : "included_flg"}
                        ];
                        colHeaders = ["Sheet", "Predefined File", "Predefinied Sheet", "Included"];
                    } else {
                        columns = [
                            {type: 'text', data : "sheet_name", readOnly: true},
                            {type: 'dropdown', data : "sheet_def", source : []},
                            {type: 'checkbox', data : "included_flg"}
                        ];
                        colHeaders = ["Sheet", "Predefinied Sheet", "Included"];
                    }
                    
                }
            }
            for (let fileName in sheets) {
                data.push({sheet_name: fileName, file_name_row:true});
                mergeCells.push({row: data.length - 1, col: 0, rowspan: 1, colspan: columns.length});
                for (let sheetName in sheets[fileName]) {
                    data.push(sheets[fileName][sheetName]);
                    data[data.length - 1].included_flg = true;
                    data[data.length - 1].file_name = fileName;
                    if (templates[fileName]) {
                        data[data.length - 1].file_def = fileName;
                        if (templates[fileName][sheetName]) {
                            data[data.length - 1].sheet_def = sheetName;
                        }
                    } else if (templates[singleFileName]) {
                        data[data.length - 1].file_def = singleFileName;
                        if (templates[singleFileName][sheetName]) {
                            data[data.length - 1].sheet_def = sheetName;
                        }
                    }
                    if (!data[data.length - 1].sheet_def) {
                        data[data.length - 1].included_flg = callback.name !== "loadSC2Obj";
                    }
                }
            }
            let spsOptions = {
                licenseKey: 'non-commercial-and-evaluation',
                data: data,
                columns : columns,
                stretchH: 'all',
                autoWrapRow: true,
                height: 300,
                minRows: 1,
                maxRows: 365 * 30,
                manualRowResize: false,
                manualColumnResize: false,
                rowHeaders: false,
                colHeaders: colHeaders,
                manualRowMove: false,
                manualColumnMove: false,
                filters: true,
                dropdownMenu: true,
                contextMenu: false,
                mergeCells: mergeCells
            };
            $(this).find("[name='rowDefSheet']").each(function () {
                $(this).handsontable(spsOptions);
                let popSpreadsheet = $(this).handsontable('getInstance');

                popSpreadsheet.updateSettings({
                    cells: function(row, col, prop) {
                        let cell = popSpreadsheet.getCell(row,col);
                        if (!cell) {
                            return;
                        }
                        if (curSheetName === data[row].sheet_name && curFileName === data[row].file_name) {
                            cell.style.backgroundColor = "yellow";
                        } else if (data[row].file_name_row) {
                            cell.style.color = "white";
                            cell.style.fontWeight = "bold";
                            cell.style.backgroundColor = "grey";
                        } else if (editFlg) {
                            return {readOnly : true};
                        }
                        if (Object.keys(templates).length > 1) {
                            if (col === popSpreadsheet.propToCol('file_def') && !data[row].file_name_row) {
                                popSpreadsheet.setCellMeta(row, col, 'source', Object.keys(templates));
                            }
                        } else {
                            if (col === popSpreadsheet.propToCol('sheet_def') && !data[row].file_name_row) {
                                if (templates[data[row].file_def]) {
                                    popSpreadsheet.setCellMeta(row, col, 'source', Object.keys(templates[data[row].file_def]));
                                }
                            }
                        }
                    }
                });
                popSpreadsheet.addHook('beforeChange', function(changes, source) {
                    if (source === 'loadData' || source === 'internal') {
                        return;
                    }
                    for (let i in changes) {
                        let row = changes[i][0];
                        let prop = changes[i][1];
                        let value = changes[i][3];
                        if (prop === 'file_def') {
                            if (value && templates[value]) {
                                this.setCellMeta(row, this.propToCol('sheet_def'), 'source', Object.keys(templates[value]));
                            } else if (value !== null) {
                                this.setCellMeta(row, this.propToCol('sheet_def'), 'source', []);
                                this.setDataAtRowProp(row, 'sheet_def', "");
                                this.setDataAtRowProp(row, 'included_flg', false);
                            }
                        } else if (prop === 'sheet_def') {
                            this.setDataAtRowProp(row, 'included_flg', !!value);
                        }
                    }

                });
            });
        });
    }

    function showSheetDefPrompt(callback) {
        let dialog = bootbox.dialog({
            message: $("#sheet_define_init_popup").html(),
            buttons: {
                confirm: {
                    label: 'Confirm',
                    className: 'btn-primary',
                    callback: function() {
                        showSheetDefDialog(callback, null, true);
                    }
                },
                copy: {
                    label: 'Copy',
                    className: 'btn-success',
                    callback: function() {
                        showSheetDefCopyPrompt(callback);
                    }
                },
                cancel: {
                    label: 'Later',
                    className: 'btn-default',
                    callback: function() {}
                }
            }
        });
        dialog.find(".modal-content").drags();
    }
    
    function showSheetDefCopyPrompt(callback, errMsg) {
        let dialog = bootbox.dialog({
            message: $("#sheet_define_copy_popup").html(),
            buttons: {
                confirm: {
                    label: 'Confirm',
                    className: 'btn-primary',
                    callback: function() {
                        let ret = $(this).find("[name='sheet_def_from']").val();
                        if (ret) {
                            let tmp = ret.split("__");
                            let sheetDef = JSON.parse(JSON.stringify(templates[tmp[0]][tmp[1]]));
                            templates[curFileName][curSheetName] = sheetDef;
                            sheetDef.references = {};
                            callback();
                        } else {
                            showSheetDefCopyPrompt(callback, "error message");
                        }
                    }
                },
                cancel: {
                    label: 'Later',
                    className: 'btn-default',
                    callback: function() {}
                }
            }
        });
        dialog.find(".modal-content").drags();
        dialog.on("shown.bs.modal", function() {
            if (errMsg) {
                dialog.find("[name='dialog_msg']").text(errMsg);
            }
            let sb = dialog.find("[name='sheet_def_from']");
            for (let fileName in templates) {
                let optgrp = $('<optgroup label="' + fileName + '"></optgroup>');
                sb.append(optgrp);
                for (let sheetName in templates[fileName]) {
                    if (sheetName !== curSheetName || fileName !== curFileName) {
                        optgrp.append($('<option value="' + fileName + '__' + sheetName + '">' + sheetName + '</option>'));
                    }
                }
            }
            chosen_init_target(sb, "chosen-select-deselect-single");
        });
    }
</script>

<!-- popup page for define sheet -->
<div id="sheet_define_popup" hidden>
    <p name="dialog_msg" class="label label-danger"></p>
    <p name="mapping_def_desc" hidden>Your spreadsheet is not fully matched with the loaded SC2 file,<br/>please make correction on the relationship between your sheets and the sheets stored in the SC2 file.</p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-12">
            <div name="rowDefSheet"></div>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
<!-- popup page for initial define sheet -->
<div id="sheet_define_init_popup" hidden>
    <p>
        <h3>The rows of the sheet has not been defined yet, you could ...</h3>
        <li>Click confirm to manually do the definition</li>
        <li>Click copy to apply the definition from another sheet to the current one</li>
    </p>
</div>
<!-- popup page for copy sheet definition -->
<div id="sheet_define_copy_popup" hidden>
    <p name="dialog_msg" class="label label-danger"></p>
    <p>By clicking the confirm button, this will overwrite the existing mapping configuration</p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-12">
            <select name="sheet_def_from" class="form-control"></select>
        </div>
    </div>
    <p>&nbsp;</p>
</div>