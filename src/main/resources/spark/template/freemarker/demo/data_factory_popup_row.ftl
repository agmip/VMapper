<script>
    function showSheetDefDialog(callback, errMsg, editFlg) {
        let sheets = {};
        if (editFlg) {
            sheets = JSON.parse(JSON.stringify(templates));
            if (!sheets[curFileName][curSheetName].header_row) {
                sheets[curFileName][curSheetName].header_row = 1;
            }
            if (!sheets[curFileName][curSheetName].data_start_row) {
                sheets[curFileName][curSheetName].data_start_row = sheets[curFileName][curSheetName].header_row + 1;
            }
        } else {
            for (let fileName in workbooks) {
                let workbook = workbooks[fileName];
                sheets[fileName] = {};
                workbook.SheetNames.forEach(function(sheetName) {1
//                workbook.worksheets.forEach(function(sheet) {
//                    let sheetName = sheet.name;
                    sheets[fileName][sheetName] = {};

//                    sheets[fileName][sheetName].file_name = fileName;
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
                            } else if (fstCell.startsWith("#") || fstCell.startsWith("%")) {
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
                        sheets[fileName][sheetName].single_flg = roa.length === sheets[fileName][sheetName].data_start_row;
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
                                let keys = ["data_start_row", "header_row", "unit_row", "desc_row"];
                                for (let i = 0; i < keys.length; i++) {
                                    if (sheets[fileName][sheetName][keys[i]]) {
                                        for (let j = i + 1; j < keys.length; j++) {
                                            if (sheets[fileName][sheetName][keys[i]] === sheets[fileName][sheetName][keys[j]]) {
                                                repeatedErrFlg = true;
                                                break;
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
                        sheets[curFileName][curSheetName].single_flg = wbObj[curFileName][curSheetName].data.length === sheets[curFileName][curSheetName].data_start_row;
                    }
//                    if (idxErrFlg) {
//                        showSheetDefDialog(callback, "[warning] Please provide header row number and data start row number.", editFlg);
//                    } else
                    if (includedCnt === 0) {
                        showSheetDefDialog(callback, "[warning] Please select at least one sheet for reading in.", editFlg);
                    } else if (repeatedErrFlg) {
                        showSheetDefDialog(callback, "[warning] Please select different raw for each definition.", editFlg);
                    }  else {
                        isChanged = true;
                        isViewUpdated = false;
                        isDebugViewUpdated = false;
                        callback(sheets);
                    }
                }
            }
        };
        let dialog = bootbox.dialog({
            title: "<h2>Row Definition</h2>",
            size: 'large',
            message: $("#sheet_define_popup").html(),
            buttons: buttons
        });
        dialog.on("shown.bs.modal", function() {
            if (errMsg) {
                dialog.find("[name='dialog_msg']").text(errMsg);
            }
            let data = [];
            let mergeCells = [];
            let columns = [
//                {type: 'text', data : "file_name", readOnly: true},
                {type: 'text', data : "sheet_name", readOnly: true},
                {type: 'numeric', data : "header_row"},
                {type: 'numeric', data : "data_start_row"},
                {type: 'numeric', data : "unit_row"},
                {type: 'numeric', data : "desc_row"},
                {type: 'checkbox', data : "included_flg"}
            ];
            let colHeaders = ["Sheet", "Header Row #", "Data start Row #", "Unit Row #", "Description Row #", "Included"];
            if (!editFlg) {
                columns = [
                    {type: 'text', data : "sheet_name", readOnly: true},
                    {type: 'checkbox', data : "included_flg"}
                ];
                colHeaders = ["Sheet","Included"];
            }
            for (let fileName in sheets) {
                data.push({sheet_name: fileName, flie_name_row:true});
                mergeCells.push({row: data.length - 1, col: 0, rowspan: 1, colspan: columns.length});
                for (let sheetName in sheets[fileName]) {
                    data.push(sheets[fileName][sheetName]);
                    data[data.length - 1].included_flg = true;
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
                            var cell = popSpreadsheet.getCell(row,col);
                            if (!cell) {
                                return;
                            }
                            if (curSheetName === data[row].sheet_name) {
                                cell.style.backgroundColor = "yellow";
                            } else if (data[row].flie_name_row) {
                                cell.style.color = "white";
                                cell.style.fontWeight = "bold";
                                cell.style.backgroundColor = "grey";
                            } else if (curSheetName) {
                                return {readOnly : true};
                            }
                        }
                    });
                });
        });
    }

    function showSheetDefPrompt(callback) {
        bootbox.confirm({
            message: "The rows of the sheet has not been defined yet, do you want to do that?",
            buttons: {
                confirm: {
                    label: 'Confirm',
                    className: 'btn-primary'
                },
                cancel: {
                    label: 'Later',
                    className: 'btn-default'
                }
            },
            callback: function (result) {
                if (result) {
                    showSheetDefDialog(callback, null, true);
                }
            }
        });
    }
</script>

<!-- popup page for define sheet -->
<div id="sheet_define_popup" hidden>
    <p name="dialog_msg"></p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-12">
            <div name="rowDefSheet"></div>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
