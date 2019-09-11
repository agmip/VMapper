<script>
    function showColDefineDialog(itemData, type) {
//                let promptClass = 'event-input-' + itemData.event;
        let curVarType;
        if (!type) {
            if (itemData.code_display) {
                if (icasaVarMap.management[itemData.code_display] || icasaVarMap.observation[itemData.code_display]) {
                    type = "icasa";
                } else if (itemData.reference) {
                    type = "reference";
                } else {
                    type = "customized";
                }
            } else if (itemData.description) {
                type = "customized";
            } else {
                type = "icasa";
            }
        }
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
            message: $("#col_define_popup").html(),
            buttons: buttons
        });
        dialog.on("shown.bs.modal", function() {
            if (itemData.err_msg) {
                dialog.find("[name='dialog_msg']").text(itemData.err_msg);
            }
            dialog.find("[name=header]").each(function () {
                $(this).val(itemData[$(this).attr("name")]);
            });
            dialog.find("[name=" + type + "_info]").find(".col-def-input-item").each(function () {
                $(this).val(itemData[$(this).attr("name")]);
            });
            dialog.find("[name='icasa_info']").each(function () {
                let subDiv = $(this);
                subDiv.on("type_shown", function() {
                    chosen_init_name(subDiv.find("[name='code_display']"), "chosen-select-deselect");
                });
                subDiv.find("[name='code_display']").each(function () {
                    $(this).on("change", function () {
                        var unit = icasaVarMap.management[$(this).val()].unit_or_type;
                        subDiv.find("[name='icasa_unit']").val(unit);
                        let sourceUnit = subDiv.find("[name='source_unit']");
                        if (sourceUnit.val() === "") {
                            sourceUnit.val(unit);
                        } else {
                            sourceUnit.trigger("input");
                        }
                    });
                });
                subDiv.find("[name='source_unit']").each(function () {
                    $(this).on("input", function () {
                        $.get(encodeURI("/data/unit/convert?unit_to=" + subDiv.find("[name='icasa_unit']").val() + "&unit_from="+ $(this).val() + "&value_from=1"),
                            function (jsonStr) {
                                var result = JSON.parse(jsonStr);
                                if (result.status !== "0") {
                                    subDiv.find("[name='unit_validate_result']").html("Not compatiable unit");
                                    itemData.err_msg = "Please fix source unit expression";
                                } else {
                                    subDiv.find("[name='unit_validate_result']").html("");
                                    delete itemData.err_msg;
                                }
                            }
                        );
                    });
                });
            });
            dialog.find("[name='customized_info']").each(function () {
                let subDiv = $(this);
                subDiv.on("type_shown", function() {
                    chosen_init_name(subDiv.find("[name='category']"), "chosen-select-deselect");
                });
                subDiv.find("[name='code_display']").each(function () {
                    $(this).on("input", function () {
                        // TODO
//                                if (userVarMap[$(this).val()]) {
//                                    subDiv.find("[name='unit_validate_result']").html("Variable has been defined");
//                                    itemData.err_msg = "Please fix source unit expression";
//                                } else {
//                                    subDiv.find("[name='unit_validate_result']").html("");
//                                    delete itemData.err_msg;
//                                }
                    });
                });
                subDiv.find("[name='source_unit']").each(function () {
                    $(this).on("input", function () {
                        $.get(encodeURI("/data/unit/lookup?unit=" + $(this).val()),
                            function (jsonStr) {
                                var unitInfo = JSON.parse(jsonStr);
                                if (unitInfo.message === "undefined unit expression") {
                                    subDiv.find("[name='unit_validate_result']").html("Not compatiable unit");
                                    itemData.err_msg = "Please fix source unit expression";
                                } else {
                                    subDiv.find("[name='unit_validate_result']").html("");
                                    delete itemData.err_msg;
                                }
                            }
                        );
                    });
                });
            });
            dialog.find("[name='var_type']").each(function () {
                $(this).on("change", function () {
                    type = $(this).val();
                    if (curVarType) {
                        dialog.find("[name=" + curVarType + "]").fadeOut("fast", function () {
                            curVarType = type + "_info";
                            dialog.find("[name=" + curVarType + "]").fadeIn().trigger("type_shown");
                        });
                    } else {
                        curVarType = type + "_info";
                        dialog.find("[name=" + curVarType + "]").fadeIn().trigger("type_shown");
                    }
                });
                $(this).val(type);
                chosen_init_name($(this), "chosen-select");
                $(this).trigger("change");
            });
        });
    }

    function initIcasaLookupSB() {
        let varSB = $("[name='icasa_info']").find("[name='code_display']");
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

        let obvOptgroup = $('<optgroup label="Observation variable"></optgroup>');
        varSB.append(obvOptgroup);
        let obvVarMap = icasaVarMap.observation;
        for (let varName in obvVarMap) {
            obvOptgroup.append('<option value="' + varName + '">' + obvVarMap[varName].description + ' - ' + varName + ' (' + obvVarMap[varName].unit_or_type +  ')</option>');
        }
    }
</script>
<!-- popup page for define column -->
<div id="col_define_popup" hidden>
    <p name="dialog_msg"></p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-6">
            <label class="control-label">Column Header</label>
            <div class="input-group col-sm-12">
                <input type="text" name="header" class="form-control col-def-input-item" value="" readonly>
            </div>
        </div>
        <div class="form-group col-sm-6">
            <label class="control-label">Variable Type</label>
            <div class="input-group col-sm-12">
                <select name="var_type" class="form-control" data-placeholder="Choose a variable type...">
                    <option value=""></option>
                    <option value="icasa">ICASA variable</option>
                    <option value="customized">Customized variable</option>
                    <option value="reference">Reference variable</option>
                </select>
            </div>
        </div>
        <!-- ICASA Management Variable Info -->
        <div name="icasa_info" hidden>
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
        </div>
        <div name="customized_info" hidden>
            <!-- 2nd row -->
            <div class="form-group col-sm-12">
                <label class="control-label">Variable Category</label>
                <div class="input-group col-sm-12">
                    <select name="category" class="form-control col-def-input-item" data-placeholder="Choose a variable type...">
                        <option value=""></option>
                        <option value="1011">Experiment Meta Data</option>
                        <option value="2011">Experiment Management Data</option>
                        <option value="2099">Experiment Management Event Data</option>
                        <option value="2502">Experiment Observation Summary Data</option>
                        <option value="2511">Experiment Observation Time-Series Data</option>
                        <option value="4051">Soil Profile Data</option>
                        <option value="4052">Soil Layer Data</option>
                        <option value="5041">Weather Station Profie Data</option>
                        <option value="5052">Weather Station Daily Data</option>
                    </select>
                </div>
            </div>
            <div class="form-group col-sm-12">
                <label class="control-label">Variable Code</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="code_display" class="form-control col-def-input-item" value="">
                </div>
            </div>
            <!-- 3rd row -->
            <div class="form-group col-sm-12">
                <label class="control-label">Description</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="description" class="form-control col-def-input-item" value="">
                </div>
            </div>
            <!-- 4th row -->
            <div class="form-group col-sm-12">
                <label class="control-label">Unit</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="source_unit" class="form-control col-def-input-item" value="">
                </div>
            </div>
            <div class="form-group col-sm-12">
                <label class="control-label"></label>
                <div class="input-group col-sm-12" name="unit_validate_result"></div>
            </div>
        </div>
        <div name="reference_info" hidden>
            <!-- 2nd row -->
            <div class="form-group col-sm-12">
                <label class="control-label">Reference Type</label>
                <div class="input-group col-sm-12">
                    <select name="category" class="form-control col-def-input-item" data-placeholder="Choose a variable type...">
                        <option value=""></option>
                        <option value="1011">Experiment Meta Data</option>
                        <option value="2011">Experiment Management Data</option>
                        <option value="2099">Experiment Management Event Data</option>
                        <option value="2502">Experiment Observation Summary Data</option>
                        <option value="2511">Experiment Observation Time-Series Data</option>
                        <option value="4051">Soil Profile Data</option>
                        <option value="4052">Soil Layer Data</option>
                        <option value="5041">Weather Station Profie Data</option>
                        <option value="5052">Weather Station Daily Data</option>
                    </select>
                </div>
            </div>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
