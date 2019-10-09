<script>
    function showSheetDefDialog(workbook, callback, errMsg) {
        let sheets = {};
        workbook.SheetNames.forEach(function(sheetName) {
            sheets[sheetName] = {};
            sheets[sheetName].sheet_name = sheetName;
            sheets[sheetName].included_flg = true;
            var roa = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], {header:1});
            if(roa.length){
                for (let i in roa) {
                    if (!roa[i].length || roa[i].length === 0) {
                        continue;
                    }
                    let fstCell = String(roa[i][0]);
                    if (fstCell.startsWith("!")) {
                        if (!sheets[sheetName].unit_row && fstCell.toLowerCase().includes("unit")) {
                            sheets[sheetName].unit_row = Number(i) + 1;
                        } else if (!sheets[sheetName].desc_row && 
                                (fstCell.toLowerCase().includes("definition") || 
                                fstCell.toLowerCase().includes("description"))) {
                            sheets[sheetName].desc_row = Number(i) + 1;
                        }
                    } else if (fstCell.startsWith("#") || fstCell.startsWith("%")) {
                        if (!sheets[sheetName].header_row) {
                            sheets[sheetName].header_row = Number(i) + 1;
                        }
                    } else if (sheets[sheetName].header_row && !sheets[sheetName].data_start_row) {
                        sheets[sheetName].data_start_row = Number(i) + 1;
                    }
                    if (Object.keys(sheets[sheetName]).length >= 6) {
                        break;
                    }
                }
            }
            if (!sheets[sheetName].header_row) {
                sheets[sheetName].header_row = 1;
            }
            if (!sheets[sheetName].data_start_row) {
                sheets[sheetName].data_start_row = 2;
            }
        });
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
                    let includedCnt = 0;
                    for (sheetName in sheets) {
                        if (!sheets[sheetName].data_start_row || !sheets[sheetName].header_row) {
                            idxErrFlg = true;
                        }
                        if (sheets[sheetName].included_flg) {
                            includedCnt++;
                            delete sheets[sheetName].included_flg;
                        } else {
                            delete sheets[sheetName];
                        }
                    }
                    if (idxErrFlg) {
                        showSheetDefDialog(workbook, callback, "[warning] Please provide header row number and data start row number.");
                    } else if (includedCnt === 0) {
                        showSheetDefDialog(workbook, callback, "[warning] Please select at least one sheet for reading in.");
                    } else {
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
            for (sheetName in sheets) {
                data.push(sheets[sheetName]);
            }
            let spsOptions = {
                    licenseKey: 'non-commercial-and-evaluation',
                    data: data,
                    columns: [
                        {type: 'text', data : "sheet_name", readOnly: true},
                        {type: 'numeric', data : "header_row"},
                        {type: 'numeric', data : "data_start_row"},
                        {type: 'numeric', data : "unit_row"},
                        {type: 'numeric', data : "desc_row"},
                        {type: 'checkbox', data : "included_flg"}
                    ],
                    stretchH: 'all',
                    autoWrapRow: true,
                    height: 300,
                    minRows: 1,
                    maxRows: 365 * 30,
                    manualRowResize: false,
                    manualColumnResize: false,
                    rowHeaders: false,
                    colHeaders: ["Sheet", "Header Row #", "Data start Row #", "Unit Row #", "Description Row #", "Included"],
                    manualRowMove: false,
                    manualColumnMove: false,
                    filters: true,
                    dropdownMenu: true,
                    contextMenu: false
                };
                $(this).find("[name='rowDefSheet']").each(function () {
                    $(this).handsontable(spsOptions);
                });
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
