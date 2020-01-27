<script>
    function showColDefineDialog(itemData, type) {
//                let promptClass = 'event-input-' + itemData.event;
        let curVarType;
        let colDef = templates[curFileName][curSheetName].mappings[itemData.column_index - 1];
        if (!type) {
            if (itemData.icasa) {
                if (icasaVarMap.getDefinition(itemData.icasa)) {
                    type = "icasa";
                } else if (itemData.category) {
                    type = "customized";
                } else if (itemData.reference_flg) {
                    type = "reference";
                } else {
                    type = "customized";
                }
            } else if (itemData.reference_flg) {
                type = "reference";
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
//                    let isRef = $(this).find("[name=reference_flg]").is(":checked");
//                    let refTypes = $(this).find("[name=reference_type]").val();
//                    let othOpts = $(this).find("[name=other_options]").val();
                    if (curVarType === "customized_info") {
                        if (subDiv.find("[name='category']").val() === "") {
                            itemData.err_msg = "Please select the variable category.";
                        } else if (itemData.err_msg === "Please select the variable category.") {
                            delete itemData.err_msg;
                        }

                        let icasa = subDiv.find("[name='icasa']").val();
                        if (!icasa) {
                            itemData.err_msg = "Please provide a code name for your customized variable.";
                        } else if (itemData.err_msg === "Please provide a code name for your customized variable.") {
                            delete itemData.err_msg;
                        }
                        if (icasa === itemData.column_header) {
                            itemData.err_msg = itemData.column_header + " is already used by ICASA, please provide a different variable name.";
                        } else if (itemData.err_msg === itemData.column_header + " is already used by ICASA, please provide a different variable name.") {
                            delete itemData.err_msg;
                        }
                    } else if (curVarType === "icasa_info") {
                        // TODO
                    } else if (curVarType === "reference_info") {
                        // TODO
                    }
                    if (!itemData.err_msg) {
                        updateData($(this), colDef, curVarType);
                        
                        let varDef = icasaVarMap.getDefinition(colDef.icasa);
                        if (varDef) {
                            colDef.description = varDef.description;
                        }
                        if (colDef.unit_error) {
                            delete colDef.unit_error;
                        }
                        $("[name='" + curSheetName + "_" + (itemData.column_index - 1) + "_label']").last().attr("class", getColStatusClass(itemData.column_index - 1));
                        let columns = spreadsheet.getSettings().columns;
                        if (colDef.unit === "date") {
                            columns[itemData.column_index - 1].type = "date";
//                            columns[itemData.column_index - 1].dateFormat = "YYYY-MM-DD";
                        }
                        spreadsheet.updateSettings({
                            columns : columns
                        });
                    } else {
                        updateData($(this), itemData, curVarType);
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
            dialog.find("[name=column_header]").each(function () {
                $(this).val(itemData[$(this).attr("name")]);
            });
            dialog.find("[name=other_options]").each(function () {
                $(this).val([]);
                if (itemData.formula) {
                    $(this).find("option[value='" + itemData.formula + "']").prop("selected", true);
                }
                chosen_init_target($(this));
            });
            dialog.find("[name=reference_flg]").each(function () {
                $(this).prop("checked", itemData[$(this).attr("name")]);
            });
            dialog.find("[name=" + type + "_info]").find(".col-def-input-item").each(function () {
                if ($(this).attr("type") === "checkbox") {
                    $(this).prop( "checked", itemData[$(this).attr("name")]);
                } else {
                    $(this).val(itemData[$(this).attr("name")]);
                }
            });
            dialog.find("[name='icasa_info']").each(function () {
                let subDiv = $(this);
                subDiv.on("type_shown", function() {
                    chosen_init_target(subDiv.find("[name='icasa']"), "chosen-select-deselect");
                    dialog.find("[name=reference_flg]").prop("disabled", false);
                    dialog.find("[name=reference_flg]").prop("checked", !!colDef.reference_flg).trigger("change");
                    $(this).find(".col-def-input-item").each(function () {
                        if ($(this).attr("type") === "checkbox") {
                            $(this).prop( "checked", itemData[$(this).attr("name")]);
                        } else {
                            $(this).val(itemData[$(this).attr("name")]);
                        }
                    });
                });
                subDiv.find("[name='unit']").each(function () {
                    
                    $(this).on("input", function () {
                        if ($(this).val() === "" && subDiv.find("[name='icasa_unit']").val() !== "") {
                            subDiv.find("[name='unit_validate_result']").html("Require unit expression");
                            itemData.err_msg = "Please provide your unit expression";
                        } else {
                            $.get(encodeURI("/data/unit/convert?unit_to=" + subDiv.find("[name='icasa_unit']").val() + "&unit_from="+ $(this).val() + "&value_from=1"),
                                function (jsonStr) {
                                    var result = JSON.parse(jsonStr);
                                    if (result.status !== "0") {
                                        subDiv.find("[name='unit_validate_result']").html("Not compatiable unit");
                                        itemData.err_msg = "Please fix source unit expression";
                                    } else {
                                        subDiv.find("[name='unit_validate_result']").html("");
                                        if (itemData.err_msg === "Please provide your unit expression" ||
                                                itemData.err_msg === "Please fix source unit expression") {
                                            delete itemData.err_msg;
                                        }
                                    }
                                }
                            );
                        }
                    });
                });
                subDiv.find("[name='icasa']").each(function () {
                    $(this).on("change", function () {
                        let unit = icasaVarMap.getUnit($(this).val());
                        if (unit) {
                            subDiv.find("[name='icasa_unit']").val(unit);
                            let sourceUnit = subDiv.find("[name='unit']");
                            if (subDiv.find("[name='same_unit_flg']").is(':checked')) {
                                sourceUnit.val(unit);
                            } else {
                                sourceUnit.trigger("input");
                            }
                        }
                    });
                    $(this).trigger("change");
                });
                subDiv.find("[name='same_unit_flg']").each(function () {
                    $(this).on("change", function () {
                        let unit = subDiv.find("[name='icasa_unit']").val();
                        let sourceUnit = subDiv.find("[name='unit']");
                        if ($(this).is(":checked")) {
                            sourceUnit.val(unit).trigger("input").prop("readOnly", true);
                        } else {
                            sourceUnit.val("").trigger("input").prop("readOnly", false);
                        }
                    });
                });
            });
            dialog.find("[name='customized_info']").each(function () {
                let subDiv = $(this);
                subDiv.on("type_shown", function() {
                    dialog.find("[name=reference_flg]").prop("disabled", false);
                    dialog.find("[name=reference_flg]").prop("checked", !!colDef.reference_flg).trigger("change");
                    chosen_init_target(subDiv.find("[name='category']"), "chosen-select-deselect");
                    $(this).find(".col-def-input-item").each(function () {
                        if ($(this).attr("type") === "checkbox") {
                            $(this).prop( "checked", itemData[$(this).attr("name")]);
                        } else {
                            $(this).val(itemData[$(this).attr("name")]);
                            if ($(this).attr("name") === "unit") {
                                $(this).trigger("input");
                            }
                        }
                    });
//                    if (!itemData.icasa) {
//                        $(this).find("[name='icasa']").val(itemData.column_header);
//                    }
                });
                subDiv.find("[name='icasa']").each(function () {
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
                subDiv.find("[name='unit']").each(function () {
                    $(this).on("input", function () {
                        let unit = $(this).val().toLowerCase();
                        $.get(encodeURI("/data/unit/lookup?unit=" + unit),
                            function (jsonStr) {
                                var unitInfo = JSON.parse(jsonStr);
                                if (unitInfo.message === "undefined unit expression" && unit !== "text" && unit !== "code" && unit !== "date") {
                                    subDiv.find("[name='unit_validate_result']").html("Not compatiable unit");
                                    itemData.err_msg = "Please fix source unit expression";
                                } else {
                                    subDiv.find("[name='unit_validate_result']").html("");
                                    if (itemData.err_msg === "Please fix source unit expression") {
                                        delete itemData.err_msg;
                                    }
                                }
                            }
                        );
                    });
                });
            });
            dialog.find("[name='reference_info']").each(function () {
                let subDiv = $(this);
                subDiv.on("type_shown", function() {
//                    chosen_init_target(subDiv.find("[name='category']"), "chosen-select-deselect");

                    $(this).find(".col-def-input-item").each(function () {
                        if ($(this).attr("type") === "checkbox") {
                            $(this).prop( "checked", itemData[$(this).attr("name")]);
                        } else {
                            $(this).val(itemData[$(this).attr("name")]);
                        }
                    });
                    itemData.reference_flg = true;
                    dialog.find("[name=reference_flg]").prop("checked", true).trigger("change");
                    dialog.find("[name=reference_flg]").prop("disabled", true);
                });
            });
            dialog.find("[name='var_type']").each(function () {
                $(this).on("change", function () {
                    type = $(this).val();
                    if (curVarType) {
                        dialog.find("[name=" + curVarType + "]").fadeOut("fast", function () {
                            curVarType = type + "_info";
                            delete itemData.err_msg;
                            dialog.find("[name=" + curVarType + "]").fadeIn().trigger("type_shown");
                        });
                    } else {
                        curVarType = type + "_info";
                        dialog.find("[name=" + curVarType + "]").fadeIn().trigger("type_shown");
                    }
                });
                $(this).val(type);
                chosen_init_target($(this), "chosen-select");
                $(this).trigger("change");
            });
        });
    }
    
    function updateData(div, itemData, curVarType) {
        let subDiv = div.find("[name=" + curVarType + "]");
        let isRef = div.find("[name=reference_flg]").is(":checked");
        let refTypes = div.find("[name=reference_type]").val();
        let othOpts = div.find("[name=other_options]").val();
        subDiv.find(".col-def-input-item").each(function () {
            if ($(this).attr("type") === "checkbox") {
                if ($(this).is(":checked")) {
                    itemData[$(this).attr("name")] = true;
                } else {
                    delete itemData[$(this).attr("name")];
                }
            } else if ($(this).val()) {
                itemData[$(this).attr("name")] = $(this).val();
            }else {
                delete itemData[$(this).attr("name")];
            }
        });
        if (isRef) {
            itemData.reference_flg = true;
            updateRefType(itemData, refTypes);
            if (curVarType === "reference_info") {
                delete itemData.category;
            }
        } else {
            delete itemData.reference_flg;
            delete itemData.reference_type;
        }
        if (othOpts.length > 0) {
            if (othOpts.includes("fill_with_previous")) {
                itemData.formula = "fill_with_previous";
            } else if (itemData.formula === "fill_with_previous") {
                delete itemData.formula;
            }
        } else {
            delete itemData.formula;
        }
    }

    function initIcasaLookupSB() {
        let varSB = $("[name='icasa_info']").find("[name='icasa']");
        varSB.append('<option value=""></option>');
        let mgnOptgroup = $('<optgroup label="Management variable"></optgroup>');
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
                <input type="text" name="column_header" class="form-control col-def-input-item" value="" readonly>
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
            <div class="input-group col-sm-12">
                <input type="checkbox" name="reference_flg">&nbsp;Used as reference key between tables
            </div>
        </div>
        <!-- ICASA Management Variable Info -->
        <div name="icasa_info" hidden>
            <!-- 2nd row -->
            <div class="form-group col-sm-12">
                <label class="control-label">ICASA Variable</label>
                <div class="input-group col-sm-12">
                    <select name="icasa" class="form-control col-def-input-item" data-placeholder="Choose a variable...">
                    </select>
                </div>
            </div>
            <!-- 3rd row -->
            <div class="form-group col-sm-4">
                <label class="control-label">ICASA Unit</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="icasa_unit" class="form-control" value="" readonly>
                </div>
            </div>
            <div class="form-group col-sm-4">
                <label class="control-label">Original Unit</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="unit" class="form-control col-def-input-item" value="">
                </div>
            </div>
            <div class="form-group col-sm-4">
                <label class="control-label"></label>
                <div class="input-group col-sm-12">
                    <input type="checkbox" name="same_unit_flg" class="col-def-input-item"> Apply same unit as ICASA
                </div>
                <div class="input-group col-sm-12" name="unit_validate_result"></div>
            </div>
        </div>
        <!-- Customized Variable Info -->
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
            <!-- 3rd row -->
            <div class="form-group col-sm-12">
                <label class="control-label">Variable Code</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="icasa" class="form-control col-def-input-item" value="">
                </div>
            </div>
            <!-- 4th row -->
            <div class="form-group col-sm-12">
                <label class="control-label">Description</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="description" class="form-control col-def-input-item" value="">
                </div>
            </div>
            <!-- 5th row -->
            <div class="form-group col-sm-12">
                <label class="control-label">Unit</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="unit" class="form-control col-def-input-item" value="">
                </div>
            </div>
            <!-- 6th row -->
            <div class="form-group col-sm-12">
                <label class="control-label"></label>
                <div class="input-group col-sm-12" name="unit_validate_result"></div>
            </div>
        </div>
        <!-- Reference Variable Info -->
        <div name="reference_info" hidden>
            <!-- 2nd row -->
            <div class="form-group col-sm-12">
                <label class="control-label">Variable Code</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="icasa" class="form-control col-def-input-item" value="">
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
                <h6><em>
                    Please note:
                    <li>Variable defined as reference only type will not be saved into JSON data structure during translation.</li>
                    <li>If you would like to keep this variable, please define it as customized variable and check "Used as reference key between tables" option.</li>
                </em></h6>
            </div>
<!--            <div class="form-group col-sm-12">
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
            </div>-->
        </div>
        <!-- bottom row -->
        <div class="form-group col-sm-12">
            <label class="control-label">Other Options</label>
            <div class="input-group col-sm-12">
                <select name="other_options" class="form-control" data-placeholder="Choose data handling options..." multiple>
                    <option value=""></option>
                    <option value="fill_with_previous">Use previous value to fill empty cells</option>
                </select>
            </div>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
