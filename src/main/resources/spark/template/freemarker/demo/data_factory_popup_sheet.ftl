<script>
    function showSheetDefDialog(callback, errMsg, sc2Obj) {
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
                        for (let name in fileTypes) {
                            if (Object.keys(fileTypes).length === 1
//                                || name.startsWith(fileName) && (!contentType || fileTypes[name] === contentType)
                                ) {
                                // TODO need to revise the file auto-mapping
                                singleFileName = fileName;
                            }
                        }
                    }
                    if (!templates[fileName]) {
                        templates[fileName] = {};
                    }
                    for (let i in fileConfig.file.sheets) {
                        let sheetName = fileConfig.file.sheets[i].sheet_name;
                        if (!templates[fileName][sheetName]) {
                            templates[fileName][sheetName] = [];
                        }
                        templates[fileName][sheetName].push({
                            sheet_name : sheetName,
                            table_index : templates[fileName][sheetName].length + 1
                        });
                    }
                }
                let fileMap = {};
                for (let fileName in workbooks) {
                    let workbook = workbooks[fileName];
                    fileMap[fileName] = {};
                    if (templates[fileName]) {
                        workbook.SheetNames.forEach(function(sheetName) {
                            if (!isSheetDefExist(fileName, sheetName)) {
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
        for (let fileName in workbooks) {
            let workbook = workbooks[fileName];
            sheets[fileName] = {};
            workbook.SheetNames.forEach(function(sheetName) {
                sheets[fileName][sheetName] = {};
                sheets[fileName][sheetName].file_name = fileName;
                sheets[fileName][sheetName].sheet_name = sheetName;
                sheets[fileName][sheetName].included_flg = true;
                let tableDefs = [];
                let tableDef = {};
                tableDef.single_flg = false;
                tableDef.sheet_name = sheetName;
                let roa = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], {header:1});
                for (let i = roa.length; i >= 0; i--) {
                    if (roa[i] && roa[i].length > 0) {
                        roa.splice(i + 1, roa.length - i);
                        break;
                    }
                }

                // Pre-scan the raw data and try auto-detect the header, data start, unit and description row
                if(roa.length){
                    tableDefs.push(JSON.parse(JSON.stringify(tableDef)));
                    let lastIdx = tableDefs.length - 1;
                    for (let i in roa) {
                        if (!roa[i].length || roa[i].length === 0) {
                            continue;
                        }
                        let fstCell = String(roa[i][0]);
                        if (fstCell.startsWith("!")) {
                            if (!tableDefs[lastIdx].unit_row && fstCell.toLowerCase().includes("unit")) {
                                tableDefs[lastIdx].unit_row = Number(i) + 1;
                                if (lastIdx > 0 && !tableDefs[lastIdx - 1].data_end_row) {
                                    tableDefs[lastIdx - 1].data_end_row = Number(i) - 1;
                                }
                            } else if (!tableDefs[lastIdx].desc_row && 
                                    (fstCell.toLowerCase().includes("definition") || 
                                    fstCell.toLowerCase().includes("description"))) {
                                tableDefs[lastIdx].desc_row = Number(i) + 1;
                                if (lastIdx > 0 && !tableDefs[lastIdx - 1].data_end_row) {
                                    tableDefs[lastIdx - 1].data_end_row = Number(i) - 1;
                                }
                            }
                        } else if ((fstCell && fstCell === "#") || (fstCell && fstCell === "%")) {
                            tableDefs[lastIdx].header_row = Number(i) + 1;
                            if (lastIdx > 0 && !tableDefs[lastIdx - 1].data_end_row) {
                                tableDefs[lastIdx - 1].data_end_row = Number(i) - 1;
                            }
                        } else if (tableDefs.header_row && !tableDefs[lastIdx].data_start_row) {
                            tableDefs[lastIdx].data_start_row = Number(i) + 1;
                            tableDefs.push(JSON.parse(JSON.stringify(tableDef)));
                            lastIdx++;
                        }
                    }
                }
                sheets[fileName][sheetName].table_defs = tableDefs;

                // check and setup single record flag
                for (let i in tableDefs) {
                    if (tableDefs[i].data_start_row) {
                        tableDefs[i].single_flg = isSingleRecordTable(roa, tableDefs[i]);
                    }
                }
            });
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
                    let includedCnt = 0;
                    for (let fileName in sheets) {
                        for (let sheetName in sheets[fileName]) {
                            let sheetDef = sheets[fileName][sheetName];
                            if (sheetDef.included_flg) {
                                includedCnt++;
                                delete sheetDef.included_flg;
                            } else {
                                delete sheets[fileName][sheetName];
                            }
                        }
                    }
                    if (includedCnt === 0) {
                        showSheetDefDialog(callback, "[warning] Please select at least one sheet for reading in.", sc2Obj);
                    }  else {
                        isViewUpdated = false;
                        isDebugViewUpdated = false;
                        if (callback.name === "loadSC2Obj") {
                            isChanged = false;
                            callback(sc2Obj, sheets);
                        } else {
                            isChanged = true;
                            callback(sheets);
                        }
                    }
                }
            }
        };
        let dialog = bootbox.dialog({
            title: "<h2>Table Definition</h2>",
            size: 'large',
            message: $("#sheet_define_popup").html(),
            buttons: buttons
        });
        dialog.find(".modal-content").drags();
        dialog.on("shown.bs.modal", function() {
            if (errMsg) {
                dialog.find("[name='dialog_msg']").text(errMsg);
            }
            let data = [];
            let mergeCells = [];
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
            for (let fileName in sheets) {
                data.push({sheet_name: fileName, file_name_row:true});
                mergeCells.push({row: data.length - 1, col: 0, rowspan: 1, colspan: columns.length});
                for (let sheetName in sheets[fileName]) {
                    let sheetDef = sheets[fileName][sheetName];
                    data.push(sheetDef);
                    sheetDef.included_flg = true;
                    sheetDef.file_name = fileName;
                    if (templates[fileName]) {
                        sheetDef.file_def = fileName;
                        if (isSheetDefExist(fileName, sheetName)) {
                            sheetDef.sheet_def = sheetName;
                        }
                    } else if (templates[singleFileName]) {
                        sheetDef.file_def = singleFileName;
                        if (templates[singleFileName][sheetName]) {
                            sheetDef.sheet_def = sheetName;
                        }
                    }
                    if (!sheetDef.sheet_def) {
                        sheetDef.included_flg = callback.name !== "loadSC2Obj";
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
                        if (data[row].file_name_row) {
                            cell.style.color = "white";
                            cell.style.fontWeight = "bold";
                            cell.style.backgroundColor = "grey";
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
