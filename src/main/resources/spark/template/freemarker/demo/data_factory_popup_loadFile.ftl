<script>
    function showLoadFileDialog(errMsg) {
        let dataFiles;
        let sc2Files;
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
                    if (dataFiles && dataFiles.length > 0) {
                        readSpreadSheet({files : dataFiles}, {files : sc2Files});
                    } else {
                        showLoadFileDialog("[Warn] Please select raw data file");
                    }
                }
            }
        };
        let dialog = bootbox.dialog({
            title: "<h2>Load raw data file and SC2 file</h2>",
            size: 'large',
            message: $("#loadFile_popup").html(),
            buttons: buttons
        });
        dialog.on("shown.bs.modal", function() {
            if (errMsg) {
                dialog.find("[name='dialog_msg']").text(errMsg);
            }
            dialog.find("[name='data_file']").on("change", function () {
                dataFiles = $(this).prop("files");
                let sc2FileInput = dialog.find("[name='sc2_file']");
                if (dataFiles.length > 0) {
                    sc2FileInput.prop("disabled", false);
                    sc2Files = sc2FileInput.prop("files");
                } else {
                    sc2FileInput.prop("disabled", true);
                    sc2Files = null;
                }
            });
            dialog.find("[name='sc2_file']").on("change", function () {
                sc2Files = $(this).prop("files");
            });
        });
    }
</script>

<!-- popup page for define sheet -->
<div id="loadFile_popup" hidden>
    <p name="dialog_msg"></p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-12">
            <label class="control-label">Raw Data File :</label>
            <input type="file" name="data_file" class="form-control" accept=".xlsx,.xls">
        </div>
        <!-- 2nd row -->
        <div class="form-group col-sm-12">
            <label class="control-label">SC2 Template File :</label>
            <input type="file" name="sc2_file" class="form-control" accept=".sc2.json,.json,.sc2" disabled>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
