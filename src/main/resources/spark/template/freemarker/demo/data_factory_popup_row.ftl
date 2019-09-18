<script>
    function showSheetDefDialog(workbook, callback, errMsg) {
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
                    let userDef = {};
                    $(this).find("[type='number']").each(function () {
                        if ($(this).val()) {
                            userDef[$(this).attr("name")] = $(this).val();
                        }
                    });
                    if (!userDef.data_start_row || !userDef.header_row) {
                        showSheetDefDialog(workbook, callback, "[warning] Please provide header row number and data start row number.");
                    } else {
                        let sheets = {};
                        workbook.SheetNames.forEach(function(sheetName) {
                            sheets[sheetName] = {};
                            Object.assign(sheets[sheetName], userDef);
                            sheets[sheetName].sheet_name = sheetName;
                        });
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
        });
    }
</script>

<!-- popup page for define sheet -->
<div id="sheet_define_popup" hidden>
    <p name="dialog_msg"></p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-3">
            <label class="control-label">Header Row #</label>
            <div class="input-group col-sm-12">
                <input type="number" step="1" min="1" name="header_row" class="form-control col-def-input-item" value="1">
            </div>
        </div>
        <div class="form-group col-sm-3">
            <label class="control-label">Unit Row #</label>
            <div class="input-group col-sm-12">
                <input type="number" step="1" min="1" name="unit_row" class="form-control col-def-input-item" value="">
            </div>
        </div>
        <div class="form-group col-sm-3">
            <label class="control-label">Description Row #</label>
            <div class="input-group col-sm-12">
                <input type="number" step="1" min="1" name="desc_row" class="form-control col-def-input-item" value="">
            </div>
        </div>
        <div class="form-group col-sm-3">
            <label class="control-label">Data Start from Row #</label>
            <div class="input-group col-sm-12">
                <input type="number" step="1" min="1" name="data_start_row" class="form-control col-def-input-item" value="2">
            </div>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
