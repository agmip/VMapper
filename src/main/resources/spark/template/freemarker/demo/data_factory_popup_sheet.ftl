<script>
    function showSheetDefDialog(itemData, callback) {
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
                    callback({});
                    let subDiv = $(this).find("[name=" + curVarType + "]");
                    if (!itemData.err_msg) {
                        let colDef = templates[curSheetName].headers[itemData.colIdx];
                        subDiv.find(".col-def-input-item").each(function () {
                            if ($(this).val()) {
                                colDef[$(this).attr("name")] = $(this).val();
                            }
                        });
                    } else {
                        subDiv.find(".col-def-input-item").each(function () {
                            if ($(this).val()) {
                                itemData[$(this).attr("name")] = $(this).val();
                            }
                        });
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
            message: $("#sheet_define_popup").html(),
            buttons: buttons
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
                <input type="number" step="1" min="1" name="header_row_num" class="form-control col-def-input-item" value="1">
            </div>
        </div>
        <div class="form-group col-sm-3">
            <label class="control-label">Unit Row #</label>
            <div class="input-group col-sm-12">
                <input type="number" step="1" min="1" name="header_row_num" class="form-control col-def-input-item" value="">
            </div>
        </div>
        <div class="form-group col-sm-3">
            <label class="control-label">Description Row #</label>
            <div class="input-group col-sm-12">
                <input type="number" step="1" min="1" name="header_row_num" class="form-control col-def-input-item" value="">
            </div>
        </div>
        <div class="form-group col-sm-3">
            <label class="control-label">Data Start from Row #</label>
            <div class="input-group col-sm-12">
                <input type="number" step="1" min="1" name="header_row_num" class="form-control col-def-input-item" value="2">
            </div>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
