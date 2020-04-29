<script>
    function showColDefineDialog(itemData, type) {
//                let promptClass = 'event-input-' + itemData.event;
        let curVarType;
        let isVirtual = !itemData.column_index_org;
//        let colDef = templates[curFileName][curSheetName].mappings[itemData.column_index - 1];
        let colDef;
        if (isVirtual && !itemData.column_index) {
            colDef = itemData;
        } else {
            colDef = templates[curFileName][curSheetName].mappings[itemData.column_index - 1];
        }
        if (!type) {
            if (itemData.icasa) {
                if (icasaVarMap.getDefinition(itemData.icasa)) {
                    type = "icasa";
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
                        if (icasaVarMap.isDefined(icasa)) {
                            itemData.err_msg = icasa + " is already used by ICASA, please provide a different variable name.";
                        } else if (itemData.err_msg === icasa + " is already used by ICASA, please provide a different variable name.") {
                            delete itemData.err_msg;
                        }
                    } else if (curVarType === "icasa_info") {
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
                        
                        if (!colDef.column_index) {
                            // handle new virtual column
                            insertVRData(colDef);
                            updateVRData(colDef);
                        } else if (!colDef.column_index_org) {
                            // handle editted virtual column
                            updateVRData(colDef);
                        } else if (colDef.unit === "date") {
                            // handle data type -> date
                            let columns = spreadsheet.getSettings().columns;
                            columns[itemData.column_index - 1].type = "date";
//                            columns[itemData.column_index - 1].format = "YYYY-MM-DD";
                            spreadsheet.updateSettings({
                                columns : columns
                            });
                        }
                        $("[name='" + curSheetName + "_" + (itemData.column_index - 1) + "_label']").last().attr("class", getColStatusClass(itemData.column_index - 1));
                        isChanged = true;
                        isViewUpdated = false;
                        isDebugViewUpdated = false;
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
            let colHeaderInput = dialog.find("[name='column_header']");
            colHeaderInput.val(itemData.column_header);
            dialog.find("[name=other_options]").each(function () {
                $(this).val([]);
                if (itemData.formula) {
                    $(this).find("option[value='" + itemData.formula + "']").prop("selected", true);
                }
                chosen_init_target($(this));
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
                    $(this).find(".col-def-input-item").each(function () {
                        if ($(this).attr("type") === "checkbox") {
                            if (itemData[$(this).attr("name")]) {
                                $(this).prop("checked", itemData[$(this).attr("name")]).trigger("change");
                            }
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
                            $.get("/data/unit/convert?value_from=3&unit_to=" + encodeURIComponent(subDiv.find("[name='icasa_unit']").val()) + "&unit_from="+ encodeURIComponent($(this).val()),
                                function (jsonStr) {
                                    var result = JSON.parse(jsonStr);
                                    if (result.status !== "0") {
                                        subDiv.find("[name='unit_validate_result']").html("Incompatiable unit");
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
                        subDiv.find("[name='format']").prop("disabled", $(this).val().toLowerCase() !== "date").trigger("change");
                    });
                });
                subDiv.find("[name='format']").each(function () {
                    $(this).on("change", function () {
                        if ($(this).val() !== "customized") {
                            subDiv.find("[name='format_customized']").prop("disabled", true).val($(this).val()).trigger("change");
                        } else {
                            subDiv.find("[name='format_customized']").prop("disabled", false).trigger("change");
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
                        if (isVirtual) {
                            colHeaderInput.val($(this).val());
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
                            let unitRow = templates[curFileName][curSheetName].unit_row;
                            let orgUnit = colDef.unit;
                            if (orgUnit === unit) {
                                if (unitRow && unitRow > 0) {
                                    orgUnit = wbObj[curFileName][curSheetName].data[unitRow - 1][colDef.column_index - 1];
                                } else {
                                    orgUnit = "";
                                }
                            }
                            sourceUnit.val(orgUnit).trigger("input").prop("readOnly", false);
                        }
                    });
                });
            });
            dialog.find("[name='customized_info']").each(function () {
                let subDiv = $(this);
                subDiv.on("type_shown", function() {
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
                        if (isVirtual) {
                            colHeaderInput.val($(this).val());
                        }
                    });
                });
                subDiv.find("[name='unit']").each(function () {
                    $(this).on("input", function () {
                        let unit = $(this).val().toLowerCase();
                        $.get("/data/unit/lookup?unit=" + encodeURIComponent(unit),
                            function (jsonStr) {
                                var unitInfo = JSON.parse(jsonStr);
                                if (unitInfo.message === "undefined unit expression" && unit !== "text" && unit !== "code" && unit !== "date") {
                                    subDiv.find("[name='unit_validate_result']").html("Incompatiable unit");
                                    itemData.err_msg = "Please fix source unit expression";
                                } else {
                                    subDiv.find("[name='unit_validate_result']").html("");
                                    if (itemData.err_msg === "Please fix source unit expression") {
                                        delete itemData.err_msg;
                                    }
                                }
                            }
                        );
                        subDiv.find("[name='format']").prop("disabled", $(this).val().toLowerCase() !== "date").trigger("change");
                    });
                });
                subDiv.find("[name='format']").each(function () {
                    $(this).on("change", function () {
                        if ($(this).val() !== "customized") {
                            subDiv.find("[name='format_customized']").prop("disabled", true).val($(this).val()).trigger("change");
                        } else {
                            subDiv.find("[name='format_customized']").prop("disabled", false).trigger("change");
                        }
                    });
                });
            });
            dialog.find("[name='virtual_info']").each(function () {
                let subDiv = $(this);
                subDiv.on("type_shown", function() {
                    chosen_init_target(subDiv.find("[name='virtual_val_rule']"), "chosen-select-deselect-single");
                    
                    
                    $(this).find(".col-def-input-item-vr").each(function () {
                        if ($(this).prop("tagName").toLowerCase() === "select") {
                            if ($(this).attr("name") === "virtual_val_keys") {
                                chosen_init_target($(this), "chosen-select-deselect");
                                initKeySB($(this), {file: curFileName, sheet: curSheetName});
                                if (itemData.virtual_val_keys) {
                                    $(this).val(itemData.virtual_val_keys).trigger("chosen:updated");
                                }
                            } else {
                                chosen_init_target($(this), "chosen-select-deselect-single");
                                $(this).val(itemData[$(this).attr("name")]).trigger("chosen:updated");
                            }
                        } else if ($(this).attr("type") === "checkbox") {
                            $(this).bootstrapToggle({on:"Yes", off:"No", size:"mini"});
                            $(this).prop("checked", itemData[$(this).attr("name")]).change();
                        } else {
                            $(this).val(itemData[$(this).attr("name")]);
                        }
                    });
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
            if (isVirtual) {
                dialog.find("[name='virtual_info']").fadeIn().trigger("type_shown");
//                colHeaderInput.attr("readOnly", false);
            }
        });
    }
    
    function insertVRData(colDef) {
        let columns = spreadsheet.getSettings().columns;
        let data = wbObj[curFileName][curSheetName].data;
        let sheetDef = templates[curFileName][curSheetName];
        let mappings = sheetDef.mappings;

        // generate column index for the new column
        let idx = colDef.column_index_prev;
        colDef.column_index = idx + 1;
        delete colDef.column_index_prev;
        if (!idx && idx !== 0) {
            idx = columns.length;
        }

        // Shift references index
        shiftRefFromKeyIdx(sheetDef, idx);

        // shift value component keys
        let vrKeys = [];
        for (let i in colDef.virtual_val_keys) {
            if (colDef.virtual_val_keys[i] > idx) {
                vrKeys.push(Number(colDef.virtual_val_keys[i]) + 1 + "");
            } else {
                vrKeys.push(colDef.virtual_val_keys[i]);
            }
        }
        colDef.virtual_val_keys = vrKeys;
        
        // shift mapping and spreadsheet column index
        shiftRawData(data, idx);
        for (let i = columns.length; i > idx; i--) {    
            columns[i] = columns[i - 1];
            mappings[i] = mappings[i - 1];
            mappings[i].column_index = mappings[i].column_index + 1;
        }
    }
    
    function shiftRefFromKeyIdx(sheetDef, idx) {
        let references = {};
        for (let keyStr in sheetDef.references) {
            let keys = JSON.parse("[" + keyStr + "]");
            let newKeys = [];
            for (let i in keys) {
                if (keys[i] > idx) {
                    newKeys.push(keys[i] + 1);
                } else {
                    newKeys.push(keys[i]);
                }
            }
            references[newKeys.join()] = sheetDef.references[keyStr];
        }
        sheetDef.references = references;
    }
    
    function shiftRefToKeyIdx(sheetDef) {
        for (let i in sheetDef.references) {
            let references = {};
            for (let keyStr in sheetDef.references[i]) {
                let refDef = sheetDef.references[i][keyStr];
                let keys = refDef.keys;
                let mappings = templates[refDef.file][refDef.sheet].mappings;
                for (let j in keys) {
                    for (let k in mappings) {
                        if (keys[j].column_index === mappings[k].column_index_org) {
                            keys[j] = mappings[k];
                            break;
                        }
                    }
                }
                references[getRefDefKey(refDef, keys)] = sheetDef.references[i][keyStr];
            }
            sheetDef.references[i] = references;
        }
    }
    
    function shiftRawData(data, idx) {
        for (let j = 0; j < data.length; j++) {
            for (let i = data[j].length; i > idx; i--) {
                data[j][i] = data[j][i - 1];
            }
        }
    }
    
    function updateRawData(data, sheetDef, colDef) {
        let idx = colDef.column_index - 1;
        let vrKeys = colDef.virtual_val_keys;
        let valSet = {};
        
        let dataStartRow = 0;
        if (sheetDef.data_start_row) {
            dataStartRow = sheetDef.data_start_row - 1;
        }
        for (let j = dataStartRow; j < data.length; j++) {
            let vals = [];
            for (let i in vrKeys) {
                if (colDef.virtual_val_rule) {
                    vals.push(data[j][Number(vrKeys[i]) - 1].substring(0, Number(colDef.virtual_val_rule)));
                } else {
                    vals.push(data[j][Number(vrKeys[i]) - 1]);
                }
            }
            let divider = colDef.virtual_divider;
            if (!divider) {
                divider = "";
            }
            data[j][idx] = vals.join(divider);
            if (colDef.virtual_unique_flg) {
                if (!valSet[data[j][idx]]) {
                    valSet[data[j][idx]] = 1;
                } else {
                    vals.push(valSet[data[j][idx]]);
                    data[j][idx] = vals.join(divider);
                    valSet[data[j][idx]]++;
                }
            }
        }
        if (sheetDef.header_row) {
            data[sheetDef.header_row - 1][idx] = colDef.column_header;
        }
        if (sheetDef.unit_row) {
            data[sheetDef.unit_row - 1][idx] = colDef.unit;
        }
        if (sheetDef.desc_row) {
            data[sheetDef.desc_row - 1][idx] = colDef.description;
        }
    }
    
    function updateVRData(colDef) {
        let idx = colDef.column_index - 1;
        let data = wbObj[curFileName][curSheetName].data;
        let isDataOnly = !$('#tableViewSwitch').prop("checked");
        let sheetDef = templates[curFileName][curSheetName];
        let mappings = sheetDef.mappings;
        let columns = spreadsheet.getSettings().columns;

        updateRawData(data, sheetDef, colDef);

        columns[idx] = getColumnDef(colDef);
        mappings[idx] = colDef;
        if (isDataOnly) {
            data = data.slice(sheetDef.data_start_row - 1);
        }
        spreadsheet.updateSettings({
            data : data,
            columns : columns
        });

    }
    
    function updateData(div, itemData, curVarType) {
        let subDiv = div.find("[name=" + curVarType + "]");
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
        if (!itemData.column_index_org) {
            div.find(".col-def-input-item-vr").each(function () {
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
    
    function initIcasaCategorySB() {
        let varSB = $("[name='customized_info']").find("[name='category']");
        varSB.append('<option value=""></option>');
        let defOptgroups = {};
        let icasaGroupList = icasaVarMap.getGroupList();
        for (let order in icasaGroupList) {
            let subset = icasaGroupList[order].subset;
            if (!defOptgroups[subset]) {
                defOptgroups[subset] = $('<optgroup label="' + subset.capitalize() + ' variable"></optgroup>');
            }
            if (icasaGroupList[order].subgroup && !icasaGroupList[order].subgroup.toLowerCase().includes(icasaGroupList[order].group.toLowerCase())) {
                defOptgroups[subset].append('<option value="' + order + '">' + icasaGroupList[order].group.capitalize() + ' ' + icasaGroupList[order].subgroup.capitalize() +  '</option>');
            } else if (!icasaGroupList[order].subgroup) {
                defOptgroups[subset].append('<option value="' + order + '">' + icasaGroupList[order].group.capitalize() +  '</option>');
            } else {
                defOptgroups[subset].append('<option value="' + order + '">' + icasaGroupList[order].subgroup.capitalize() +  '</option>');
            }
        }
        for (let subset in defOptgroups) {
            varSB.append(defOptgroups[subset]);
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
                <input type="text" name="column_header" class="form-control col-def-input-item-vr" value="" readonly>
            </div>
        </div>
        <div class="form-group col-sm-6">
            <label class="control-label">Variable Type</label>
            <div class="input-group col-sm-12">
                <select name="var_type" class="form-control" data-placeholder="Choose a variable type...">
                    <option value=""></option>
                    <option value="icasa">ICASA variable</option>
                    <option value="customized">Customized variable</option>
                </select>
            </div>
        </div>
        <!-- 1.1st row -->
        <div name="virtual_info" hidden>
            <div class="form-group col-sm-12">
                <label class="control-label">Value From:</label>
                <div class="input-group col-sm-12">
                    <select name="virtual_val_keys" class="form-control col-def-input-item-vr" multiple>
                        <option value=""></option>
                    </select>
                </div>
            </div>
            <div class="form-group col-sm-2">
                <label class="control-label">Value Rule:</label>
                <div class="input-group col-sm-12">
                    <select name="virtual_val_rule" class="form-control col-def-input-item-vr">
                        <option value="">Use full text</option>
                        <option value="2">Use first 2-bit characters</option>
                        <option value="4">Use first 4-bit characters</option>
                        <option value="8">Use first 8-bit characters</option>
                    </select>
                </div>
            </div>
            <div class="form-group col-sm-2">
                <label class="control-label">Divider:</label>
                <div class="input-group col-sm-12">
                    <select name="virtual_divider" class="form-control col-def-input-item-vr">
                        <option value="">None</option>
                        <option value=".">. (dot)</option>
                        <option value=",">, (comma)</option>
                        <option value="_">_ (underscore)</option>
                        <option value="-">- (dash)</option>
                        <option value="+">+ (plus)</option>
                        <option value="|">| (vertical bar)</option>
                        <option value=";">; (semicolon)</option>
                    </select>
                </div>
            </div>
            <div class="form-group col-sm-2">
                <label class="control-label">Uniqueness:</label>
                <div class="input-group col-sm-12">
                    <input type="checkbox" name="virtual_unique_flg" class="virtual_switch_cb form-control col-def-input-item-vr">
                </div>
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
            <div class="form-group col-sm-3">
                <label class="control-label">Data Unit</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="unit" class="form-control col-def-input-item" value="">
                    <div class="label label-danger" name="unit_validate_result"></div>
                </div>
            </div>
            <div class="form-group col-sm-3">
                <label class="control-label">ICASA Unit</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="icasa_unit" class="form-control" value="" readonly>
                </div>
            </div>
            <div class="form-group col-sm-3">
                <label class="control-label">Format</label>
                <div class="input-group col-sm-12">
                    <select name="format" class="form-control col-def-input-item" value="" disabled>
                        <option value="">MS Excel Default</option>
                        <option value="yyyyDDD">Year + DOY</option>
                        <option value="customized">Customized format</option>
                    </select>
                </div>
            </div>
            <div class="form-group col-sm-3">
                <label class="control-label">Standardized Expression</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="format_customized" class="form-control col-def-input-item" value="" disabled>
                </div>
            </div>
        </div>
        <!-- Customized Variable Info -->
        <div name="customized_info" hidden>
            <!-- 2nd row -->
            <div class="form-group col-sm-12">
                <label class="control-label">Variable Category</label>
                <div class="input-group col-sm-12">
                    <select name="category" class="form-control col-def-input-item" data-placeholder="Choose a variable type...">
<!--                        <option value=""></option>
                        <option value="1011">Experiment Meta Data</option>
                        <option value="2011">Experiment Management Data</option>
                        <option value="2099">Experiment Management Event Data</option>
                        <option value="2502">Experiment Observation Summary Data</option>
                        <option value="2511">Experiment Observation Time-Series Data</option>
                        <option value="4051">Soil Profile Data</option>
                        <option value="4052">Soil Layer Data</option>
                        <option value="5046">Weather Station Profie Data</option>
                        <option value="5052">Weather Station Daily Data</option>-->
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
            <div class="form-group col-sm-4">
                <label class="control-label">Unit</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="unit" class="form-control col-def-input-item" value="">
                    <div class="label label-danger" name="unit_validate_result"></div>
                </div>
            </div>
            <div class="form-group col-sm-4">
                <label class="control-label">Format</label>
                <div class="input-group col-sm-12">
                    <select name="format" class="form-control col-def-input-item" value="" disabled>
                        <option value="">MS Excel Default</option>
                        <option value="yyyyDDD">Year + DOY</option>
                        <option value="customized">Customized format</option>
                    </select>
                </div>
            </div>
            <div class="form-group col-sm-4">
                <label class="control-label">&nbsp;</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="format_customized" class="form-control col-def-input-item" value="" disabled>
                </div>
            </div>
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
