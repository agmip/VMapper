<script>
    function showSheetDefDialog(itemData, callback) {
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
                    let ret = {};
                    $(this).find("[type='number']").each(function () {
                        ret[$(this).attr("name")] = $(this).val();
                    });
                    callback(ret);
                }
            }
        };
        let dialog = bootbox.dialog({
            title: "<h2>Row Definition</h2>",
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
                <input type="number" step="1" min="1" name="desp_row" class="form-control col-def-input-item" value="">
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
