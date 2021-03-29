<script>
    function showColDefineDialog(itemData, type) {
//                let promptClass = 'event-input-' + itemData.event;
        let curVarType;
        let isVirtual = !itemData.column_index_org;
//        let colDef = getCurTableDef().mappings[itemData.column_index - 1];
        let colDef;
        if (isVirtual && !itemData.column_index) {
            colDef = itemData;
        } else {
            colDef = getCurTableDef().mappings[itemData.column_index - 1];
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
                        if (colDef.unit === "code" && !itemData.code_mappings_undefined_flg) {
                            if (itemData.code_mappings) {
                                colDef.code_mappings = itemData.code_mappings;
                            } else if (colDef.code_mappings) {
                                delete colDef.code_mappings;
                            }
                            if (itemData.code_descriptions) {
                                colDef.code_descriptions = itemData.code_descriptions;
                            } else if (colDef.code_descriptions) {
                                delete colDef.code_descriptions;
                            }
                        }

                        if (colDef.unit_error) {
                            delete colDef.unit_error;
                        }
                        
                        let columns = spreadsheet.getSettings().columns;
                        if (!colDef.column_index) {
                            // handle new virtual column
                            insertVRData(colDef);
                            updateVRData(colDef);
                            virColCnt[curFileName][curSheetName][curTableIdx - 1]++;
                        } else if (!colDef.column_index_org) {
                            // handle editted virtual column
                            updateVRData(colDef);
                        } else if (colDef.unit && colDef.unit.includes("date")) {
                            // handle data type -> date
                            columns[itemData.column_index - 1].type = "date";
//                            columns[itemData.column_index - 1].format = "YYYY-MM-DD";
                        }
                        $("[name='" + curFileName + "_" + curSheetName + "_" + (itemData.column_index - 1) + "_label']").last().attr("class", getColStatusClass(itemData.column_index - 1));
                        spreadsheet.updateSettings({
                            columns : columns
                        });
                        if (!itemData.code_mappings_undefined_flg) {
                            if ($('#tableViewSwitch2').prop("checked")) {
                                let tableDef = getCurTableDef();
                                let rawData = wbObj[curFileName][curSheetName].data;
                                if (!$('#tableViewSwitch').prop("checked")) {
                                    rawData = getSheetDataContent(rawData, tableDef);
                                }
                                spreadsheet.updateSettings({
                                    data : replaceOrgCode(rawData, tableDef)
                                });
                            }
                        }
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
        dialog.find(".modal-content").drags();
        dialog.on("shown.bs.modal", function() {
            if (itemData.err_msg) {
                dialog.find("[name='dialog_msg']").text(itemData.err_msg);
            }
            let colHeaderInput = dialog.find("[name='column_header']");
            colHeaderInput.val(itemData.column_header);
            dialog.find("[name=other_options]").each(function () {
                $(this).val([]);
                if (itemData.formula && itemData.formula.function === "fill_with_previous") {
                    $(this).find("option[value='" + itemData.formula.function + "']").prop("selected", true);
                }
                chosen_init_target($(this));
            });
            dialog.find("[name=" + type + "_info]").find(".col-def-input-item").each(function () {
                if ($(this).attr("type") === "checkbox") {
                    $(this).prop( "checked", itemData[$(this).attr("name")]);
                } else if ($(this).attr("name") === "unit") {
                    if (itemData.unit && itemData.unit.includes("date") && itemData.unit !== "date") {
                        $(this).val("date");
                    } else {
                        $(this).val(itemData.unit);
                    }
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
                    $(this).find("[name='icasa']").trigger("change");
                });
                subDiv.find("[name='unit']").each(function () {
                    
                    $(this).on("input", function () {
                        if ($(this).val() === "" && subDiv.find("[name='icasa_unit']").val() !== "") {
                            subDiv.find("[name='unit_validate_result']").html("Require unit expression");
                            itemData.err_msg = "Please provide your unit expression";
                        } else {
                            subDiv.find("[name='unit_validate_result']").html('<img alt="loading" src="/images/loading.gif" height="40pt">validating...</img>');
                            $.get("/data/unit/convert?value_from=3&unit_to=" + encodeURIComponent(subDiv.find("[name='icasa_unit']").val()) + "&unit_from="+ encodeURIComponent($(this).val()),
                                function (jsonStr) {
                                    let result = JSON.parse(jsonStr);
                                    if (result.status !== "0") {
                                        subDiv.find("[name='unit_validate_result']").html("Incompatible unit");
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
                        if ($(this).val().toLowerCase() !== "date") {
                            subDiv.find("[name='format']").val("").prop("disabled", true).trigger("change");
                        } else {
                            subDiv.find("[name='format']").prop("disabled", false).trigger("change");
                        }
                    });
                });
                subDiv.find("[name='format']").each(function () {
                    $(this).on("change", function () {
                        if ($(this).val() === "icasa") {
                            subDiv.find("[name='format_customized']").prop("disabled", true).val(icasaVarMap.getFormat(subDiv.find("[name='icasa']").val())).trigger("change");
                        } else if ($(this).val() !== "customized") {
                            subDiv.find("[name='format_customized']").prop("disabled", true).val($(this).val()).trigger("change");
                        } else {
                            subDiv.find("[name='format_customized']").prop("disabled", false).trigger("change");
                        }
                    });
                });
                subDiv.find("[name='icasa_code_mapping_btn']").each(function () {
                    $(this).on("click", function () {
                        showCodeMappingDialog(itemData, icasaVarMap.getCodeMap(subDiv.find("[name='icasa']").val())); 
                    });
                });
                subDiv.find("[name='icasa']").each(function () {
                    $(this).on("chosen:showing_dropdown", function() {
                        if (!$(this).val()) {
                            subDiv.find(".chosen-search-input").val(itemData.column_header).trigger("paste");
                        }
                    });
                    $(this).on("change", function () {
                        let icasa = $(this).val();
                        let desc = icasaVarMap.getDesc(icasa);
                        if (!itemData.description || itemData.icasa !== icasa) {
                            subDiv.find("[name='description']").val(desc);
                        } else if (itemData.description !== desc) {
                            subDiv.find("[name='description']").val(itemData.description);
                        }
                        let unit = icasaVarMap.getUnit(icasa);
                        if (unit && unit.includes("date")) {
                            unit = "date";
                        }
                        let sourceUnit = subDiv.find("[name='unit']");
                        if (unit) {
                            subDiv.find("[name='icasa_unit']").val(unit);
                            if (unit === "code" && itemData.icasa !== icasa) {
                                itemData.code_mappings_undefined_flg = true;
                            }
                            if (!isNumericUnit(unit)) {
                                subDiv.find(".value-type-control").fadeOut(0);
                                subDiv.find(".value-type-" + unit).fadeIn(0);
                                sourceUnit.val(unit).trigger("input");
                            } else {
                                subDiv.find(".value-type-control").fadeOut(0);
                                subDiv.find(".value-type-numeric").fadeIn(0);
                            }
                            if (subDiv.find("[name='same_unit_flg']").is(':checked')) {
                                sourceUnit.val(unit);
                            } else {
                                sourceUnit.trigger("input");
                            }
                        } else {
                            subDiv.find(".value-type-control").fadeOut(0);
                        }
                        if (["FEAMP", "FEP_TOT"].includes(icasa)) {
                            subDiv.find("[name='fert_amnt_unit_pk_div']").fadeIn(0);
                            subDiv.find("[name='raw_data_unit_div']").removeClass("col-sm-4").addClass("col-sm-3");
                            subDiv.find("[name='fert_amnt_unit_pk_cb']").data("on", "P2O5").bootstrapToggle({on:"P2O5", off:"P", offstyle:"success", size:"mini"});
                            if (sourceUnit.val().replace(/\[.*[Pp]2[Oo]5.*\]/g, "").toLowerCase().includes("p2o5")) {
                                subDiv.find("[name='fert_amnt_unit_pk_cb']").bootstrapToggle("on");
                            } else {
                                subDiv.find("[name='fert_amnt_unit_pk_cb']").bootstrapToggle("off");
                            }
                        } else if (["FEAMK", "FEK_TOT"].includes(icasa)) {
                            subDiv.find("[name='fert_amnt_unit_pk_div']").fadeIn(0);
                            subDiv.find("[name='raw_data_unit_div']").removeClass("col-sm-4").addClass("col-sm-3");
                            subDiv.find("[name='fert_amnt_unit_pk_cb']").data("on", "K2O").bootstrapToggle({on:"K2O", off:"K", offstyle:"success", size:"mini"});
                            if (sourceUnit.val().replace(/\[.*[Kk]2[Oo].*\]/g, "").toLowerCase().includes("k2o")) {
                                subDiv.find("[name='fert_amnt_unit_pk_cb']").bootstrapToggle("on");
                            } else {
                                subDiv.find("[name='fert_amnt_unit_pk_cb']").bootstrapToggle("off")
                            }
                        } else {
                            subDiv.find("[name='fert_amnt_unit_pk_div']").fadeOut(0);
                            subDiv.find("[name='raw_data_unit_div']").removeClass("col-sm-3").addClass("col-sm-4");
                            subDiv.find("[name='fert_amnt_unit_pk_cb']").data("on", "");
                        }
                        if (isVirtual) {
                            colHeaderInput.val($(this).val());
                        }
                    });
                });
                subDiv.find("[name='same_unit_flg']").each(function () {
                    $(this).on("change", function () {
                        let unit = subDiv.find("[name='icasa_unit']").val();
                        let sourceUnit = subDiv.find("[name='unit']");
                        if ($(this).is(":checked")) {
                            sourceUnit.val(unit).trigger("input").prop("readOnly", true);
                        } else {
                            let unitRow = getCurTableDef().unit_row;
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
                subDiv.find("[name='val_type']").each(function () {
                    $(this).on("change", function () {
                        subDiv.find(".value-type-control").fadeOut(0);
                        subDiv.find(".value-type-" + $(this).val()).fadeIn(0);
                        let valType = $(this).val();
                        if (valType !== "numeric") {
                            subDiv.find("[name='unit']").val(valType);
                        }
                    });
                });
                subDiv.find("[name='unit']").each(function () {
                    $(this).on("input", function () {
                        let unit = $(this).val().toLowerCase();
                        subDiv.find("[name='unit_validate_result']").html('<img alt="loading" src="/images/loading.gif" height="40pt">validating...</img>');
                        $.get("/data/unit/lookup?unit=" + encodeURIComponent(unit),
                            function (jsonStr) {
                                let unitInfo = JSON.parse(jsonStr);
                                if (unitInfo.message === "undefined unit expression" && isNumericUnit(unit)) {
                                    subDiv.find("[name='unit_validate_result']").html("Incompatible unit");
                                    itemData.err_msg = "Please fix source unit expression";
                                } else {
                                    subDiv.find("[name='unit_validate_result']").html("");
                                    if (itemData.err_msg === "Please fix source unit expression") {
                                        delete itemData.err_msg;
                                    }
                                }
                            }
                        );
                        if (!isNumericUnit(unit)) {
                            subDiv.find("[name='val_type']").val(unit).trigger("change");
                        } else {
                            subDiv.find("[name='val_type']").val("numeric").trigger("change");
                        }
                        if ($(this).val().toLowerCase() !== "date") {
                            subDiv.find("[name='format']").val("").prop("disabled", true).trigger("change");
                        } else {
                            subDiv.find("[name='format']").prop("disabled", false).trigger("change");
                        }
                    });
                });
                subDiv.find("[name='customized_code_mapping_btn']").each(function () {
                    $(this).on("click", function () {
                        showCodeMappingDialog(itemData, icasaVarMap.getCodeMap(subDiv.find("[name='icasa']").val()), true); 
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
                    chosen_init_target(subDiv.find("[name='virtual_val_rule']"), "chosen-select");
                    let vrValType = $(this).find("[name='virtual_val_type']");
                    vrValType.on("change", function () {
                        subDiv.find(".col-def-input-item-vr-control").fadeOut(0);
                        subDiv.find(".col-def-input-item-vr-" + $(this).val()).fadeIn(0);
                    });
                    
                    subDiv.find(".col-def-input-item-vr-control").on("type_shown", function() {
                        chosen_init($(this).find("select"), "chosen-select-deselect");
                        $(this).find("input[type='checkbox']").bootstrapToggle({on:"Yes", off:"No", size:"mini"});
                    });
                    
                    if (itemData.virtual_val_fixed) {
                        vrValType.val("fixed").trigger("change");
                    } else if (itemData.virtual_val_keys) {
                        vrValType.val("string").trigger("change");
                    } else {
                        vrValType.val("string").trigger("change");
                    }
                    
                    $(this).find(".col-def-input-item-vr").each(function () {
                        if ($(this).prop("tagName").toLowerCase() === "select") {
                            if ($(this).attr("name") === "virtual_val_keys") {
                                chosen_init_target($(this), "chosen-select-deselect");
                                initKeySB($(this), {file: curFileName, sheet: curSheetName});
                                if (itemData.virtual_val_keys) {
                                    $(this).val(itemData.virtual_val_keys).trigger("chosen:updated");
                                }
                            } else if ($(this).attr("name") === "virtual_val_type") {
                                chosen_init_target($(this), "chosen-select-deselect");
                                if (itemData.virtual_val_fixed !== undefined && itemData.virtual_val_fixed !== null) {
                                    $(this).val("fixed").trigger("chosen:updated");
                                } else {
                                    $(this).val("string").trigger("chosen:updated");
                                }
                            } else {
                                chosen_init_target($(this), "chosen-select-deselect");
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
        let tableDef = getCurTableDef();
        let mappings = tableDef.mappings;

        // generate column index for the new column
        let idx = colDef.column_index_prev;
        colDef.column_index = idx + 1;
        delete colDef.column_index_prev;
        if (!idx && idx !== 0) {
            idx = columns.length;
        }

        // Shift references index
        shiftRefFromKeyIdx(tableDef, idx);

        // shift value component keys
        if (colDef.virtual_val_keys) {
            let vrKeys = [];
            for (let i in colDef.virtual_val_keys) {
                if (colDef.virtual_val_keys[i] > idx) {
                    vrKeys.push(Number(colDef.virtual_val_keys[i]) + 1 + "");
                } else {
                    vrKeys.push(colDef.virtual_val_keys[i]);
                }
            }
            colDef.virtual_val_keys = vrKeys;
        }
        
        // shift mapping and spreadsheet column index
        shiftRawData(data, idx, tableDef);
        for (let i = columns.length; i > idx; i--) {    
            columns[i] = columns[i - 1];
            mappings[i] = mappings[i - 1];
            mappings[i].column_index = mappings[i].column_index + 1;
        }
    }
    
    function shiftRefFromKeyIdx(tableDef, idx, shiftVal) {
        let references = {};
        if (!shiftVal) {
            shiftVal = 1;
        }
        for (let keyStr in tableDef.references) {
            let keys = JSON.parse("[" + keyStr + "]");
            let newKeys = [];
            for (let i in keys) {
                if (keys[i] > idx) {
                    newKeys.push(keys[i] + shiftVal);
                } else {
                    newKeys.push(keys[i]);
                }
            }
            references[newKeys.join()] = tableDef.references[keyStr];
        }
        tableDef.references = references;
    }
    
    function shiftRefToKeyIdx(tableDef) {
        for (let i in tableDef.references) {
            let references = {};
            for (let keyStr in tableDef.references[i]) {
                let refDef = tableDef.references[i][keyStr];
                let keys = refDef.keys;
                let mappings = templates[refDef.file][refDef.sheet][refDef.table_index].mappings;
                for (let j in keys) {
                    for (let k in mappings) {
                        if (keys[j].column_index === mappings[k].column_index_org) {
                            keys[j] = mappings[k];
                            break;
                        }
                    }
                }
                references[getRefDefKey(refDef, keys)] = tableDef.references[i][keyStr];
            }
            tableDef.references[i] = references;
        }
    }
    
    function shiftRawData(data, idx, tableDef) {
        let dataStartRow = 1;
        let dataEndRow = data.length;
        if (tableDef) {
            dataStartRow = Math.min(tableDef.data_start_row, tableDef.header_row, tableDef.desc_row, tableDef.unit_row);
            if (!dataStartRow) {
                dataStartRow = 1;
            }
            if (tableDef.data_end_row) {
                dataEndRow = tableDef.data_end_row;
            }
        }
        for (let j = dataStartRow - 1; j < dataEndRow; j++) {
            for (let i = data[j].length; i > idx; i--) {
                data[j][i] = data[j][i - 1];
            }
        }
    }
    
    function updateRawData(data, tableDef, colDef) {
        let idx = colDef.column_index - 1;
        let vrKeys = colDef.virtual_val_keys;
        let vrValFixed = colDef.virtual_val_fixed;
        let valSet = {};
        
        let dataStartRow = 0;
        let dataEndRow = data.length;
        if (tableDef.data_start_row) {
            dataStartRow = tableDef.data_start_row - 1;
        }
        if (tableDef.data_end_row) {
            dataEndRow = tableDef.data_end_row;
        }
        for (let j = dataStartRow; j < dataEndRow; j++) {
            let vals = [];
            if (vrValFixed) {
                vals.push(vrValFixed);
            } else if (vrKeys) {
                for (let i in vrKeys) {
                    let vrKey = vrKeys[i];
//                    for (let k in tableDef.mappings) {
//                        if (tableDef.mappings[k].column_index === vrKeys[i]) {
//                            vrKey = tableDef.mappings[k].column_index;
//                            break;
//                        }
//                    }
                    if (colDef.virtual_ignore_null_flg && (!data[j][Number(vrKey) - 1] || !data[j][Number(vrKey) - 1].trim())) {
                        vals = [];
                        break;
                    }
                    if (colDef.virtual_val_rule && data[j][Number(vrKey) - 1]) {
                        vals.push(data[j][Number(vrKey) - 1].substring(0, Number(colDef.virtual_val_rule)));
                    } else {
                        vals.push(data[j][Number(vrKey) - 1]);
                    }
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
                    valSet[data[j][idx]]++;
                    data[j][idx] = vals.join(divider);
                }
            }
        }
        if (tableDef.header_row) {
            data[tableDef.header_row - 1][idx] = colDef.column_header;
        }
        if (tableDef.unit_row) {
            data[tableDef.unit_row - 1][idx] = colDef.unit;
        }
        if (tableDef.desc_row) {
            data[tableDef.desc_row - 1][idx] = colDef.description;
        }
    }
    
    function updateVRData(colDef) {
        let idx = colDef.column_index - 1;
        let data = wbObj[curFileName][curSheetName].data;
        let isDataOnly = !$('#tableViewSwitch').prop("checked");
        let tableDef = getCurTableDef();
        let mappings = tableDef.mappings;
        let columns = spreadsheet.getSettings().columns;

        updateRawData(data, tableDef, colDef);

        columns[idx] = getColumnDef(colDef);
        mappings[idx] = colDef;
        if (isDataOnly) {
            data = getSheetDataContent(data, tableDef);
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
            } else {
                delete itemData[$(this).attr("name")];
            }
        });
        let unitPKCB = subDiv.find("[name='fert_amnt_unit_pk_cb']");
        if (unitPKCB.data("on")) {
            if (unitPKCB.prop("checked")) {
                if (!itemData.unit.toUpperCase().startsWith(unitPKCB.data("on"))) {
                    itemData.unit = unitPKCB.data("on") + itemData.unit;
                }
            } else {
                if (itemData.unit.toUpperCase().startsWith(unitPKCB.data("on"))) {
                    itemData.unit = itemData.unit.replace(unitPKCB.data("on"), "");
                }
            }
        }
        if (!itemData.column_index_org) {
            let valType = div.find("[name='virtual_val_type']").val();
            itemData.column_header = div.find("[name='column_header']").val();
            div.find(".col-def-input-item-vr-" + valType).each(function () {
                $(this).find(".col-def-input-item-vr").each(function () {
                    if ($(this).attr("type") === "checkbox") {
                        if ($(this).is(":checked")) {
                            itemData[$(this).attr("name")] = true;
                        } else {
                            delete itemData[$(this).attr("name")];
                        }
                    } else if ($(this).val()) {
                        itemData[$(this).attr("name")] = $(this).val();
                    } else {
                        delete itemData[$(this).attr("name")];
                    }
                });
            });
        }
        if (othOpts.length > 0) {
            if (othOpts.includes("fill_with_previous")) {
                itemData.formula = {"function" : "fill_with_previous"};
            } else if (itemData.formula && itemData.formula.function === "fill_with_previous") {
                delete itemData.formula;
            }
        } else if (itemData.formula && itemData.formula.function === "fill_with_previous") {
            delete itemData.formula;
        }
    }

    function initIcasaLookupSB() {
        let varSB = $("[name='icasa_info']").find("[name='icasa']");
        varSB.append('<option value=""></option>');
        let optGroups = {};
        createOpt(icasaVarMap.management, optGroups, varSB);
        createOpt(icasaVarMap.observation, optGroups, varSB);
    }
    
    function createOpt(varMap, optGroups, varSB) {
        for (let varName in varMap) {
            let order = icasaVarMap.getOrder(varName);
            let category = icasaVarMap.getIcasaDataCatDef(order).category;
            if (category.toUpperCase() === "MEASURED_DATA") {
                category = category.capitalize() + " - " + icasaVarMap.getGroup(varName).capitalize() + " - " + icasaVarMap.getSubGroup(varName).capitalize();
            } else {
                category = category.capitalize();
            }
            if (!optGroups[category]) {
                optGroups[category] = $('<optgroup label="' + category + '"></optgroup>');
                varSB.append(optGroups[category]);
            }
            optGroups[category].append('<option value="' + varName + '">' + varMap[varName].description + ' - ' + varName + ' (' + varMap[varName].unit_or_type +  ')</option>');
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
    <p name="dialog_msg" class="label label-danger"></p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-4">
            <label class="control-label">Raw Data Header</label>
            <div class="input-group col-sm-12">
                <input type="text" name="column_header" class="form-control" value="" readonly>
            </div>
        </div>
        <div class="form-group col-sm-4">
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
            <div class="form-group col-sm-4">
                <label class="control-label">Value Type:</label>
                <div class="input-group col-sm-12">
                    <select name="virtual_val_type" class="form-control col-def-input-item-vr">
                        <!--<option value=""></option>-->
                        <option value="string" checked>Compound String</option>
                        <option value="number" disabled>Calculated Number</option>
                        <option value="fixed">Fixed Content</option>
                    </select>
                </div>
            </div>
            <div class="form-group col-sm-12 col-def-input-item-vr-control col-def-input-item-vr-string">
                <label class="control-label">Value From:</label>
                <div class="input-group col-sm-12">
                    <select name="virtual_val_keys" class="form-control col-def-input-item-vr" multiple>
                        <option value=""></option>
                    </select>
                </div>
            </div>
            <div class="form-group col-sm-2 col-def-input-item-vr-control col-def-input-item-vr-string">
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
            <div class="form-group col-sm-2 col-def-input-item-vr-control col-def-input-item-vr-string">
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
            <div class="form-group col-sm-2 col-def-input-item-vr-control col-def-input-item-vr-string">
                <label class="control-label">Uniqueness:</label>
                <div class="input-group col-sm-12">
                    <input type="checkbox" name="virtual_unique_flg" class="virtual_switch_cb form-control col-def-input-item-vr">
                </div>
            </div>
            <div class="form-group col-sm-2 col-def-input-item-vr-control col-def-input-item-vr-string">
                <label class="control-label">Ignore Null:</label>
                <div class="input-group col-sm-12">
                    <input type="checkbox" name="virtual_ignore_null_flg" class="virtual_switch_cb form-control col-def-input-item-vr">
                </div>
            </div>
            <div class="form-group col-sm-12 col-def-input-item-vr-control col-def-input-item-vr-fixed">
                <label class="control-label">Variable Value:</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="virtual_val_fixed" class="form-control col-def-input-item-vr">
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
            <div class="form-group col-sm-3 value-type-control value-type-numeric" name="raw_data_unit_div">
                <label class="control-label">Raw Data Unit</label>
                <div class="input-group col-sm-11">
                    <input type="text" name="unit" class="form-control col-def-input-item" value="">
                    <div class="label label-danger" name="unit_validate_result"></div>
                </div>
            </div>
            <div class="form-group col-sm-1 value-type-control value-type-numeric" name="fert_amnt_unit_pk_div">
                <label class="control-label">Element</label>
                <div class="input-group col-sm-12">
                    <input type="checkbox" name="fert_amnt_unit_pk_cb">
                </div>
            </div>
            <div class="form-group col-sm-4 value-type-control value-type-numeric">
                <label class="control-label">ICASA Unit</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="icasa_unit" class="form-control" value="" readonly>
                </div>
            </div>
            <div class="form-group col-sm-3 value-type-control value-type-code">
                <div class="input-group col-sm-12">
                    <span class="btn btn-primary" name="icasa_code_mapping_btn"><span class="glyphicon glyphicon-edit"></span> Edit Code Mapping</span>
                </div>
            </div>
            <div class="form-group col-sm-4 value-type-control value-type-date">
                <label class="control-label">Format</label>
                <div class="input-group col-sm-12">
                    <select name="format" class="form-control col-def-input-item" value="" disabled>
                        <option value="">MS Excel Default</option>
                        <option value="icasa">ICASA Default</option>
                        <option value="yyyyDDD">Year + DOY</option>
                        <option value="customized">Customized format</option>
                    </select>
                </div>
            </div>
            <div class="form-group col-sm-4 value-type-control value-type-date">
                <label class="control-label">Standardized Expression</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="format_customized" class="form-control col-def-input-item" value="" disabled>
                </div>
            </div>
            <!-- 4th row -->
            <div class="form-group col-sm-12">
                <label class="control-label">Description</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="description" class="form-control col-def-input-item" value="">
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
            <div class="form-group col-sm-3">
                <label class="control-label">Value Type</label>
                <div class="input-group col-sm-12">
                    <select name="val_type" class="form-control col-def-input-item">
                        <option value="numeric" checked>Numeric</option>
                        <option value="date">Date</option>
                        <option value="code">Code</option>
                        <option value="text">Text</option>
                        <option value="number">Number/Index</option>
                    </select>
                </div>
            </div>
            <div class="form-group col-sm-3 value-type-control value-type-numeric">
                <label class="control-label">Unit</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="unit" class="form-control col-def-input-item" value="">
                    <div class="label label-danger" name="unit_validate_result"></div>
                </div>
            </div>
            <div class="form-group col-sm-3 value-type-control value-type-code">
                <label class="control-label">&nbsp;</label>
                <div class="input-group col-sm-12">
                    <span class="btn btn-primary" name="customized_code_mapping_btn"><span class="glyphicon glyphicon-edit"></span> Edit Code Description</span>
                </div>
            </div>
            <div class="form-group col-sm-3 value-type-control value-type-date">
                <label class="control-label">Format</label>
                <div class="input-group col-sm-12">
                    <select name="format" class="form-control col-def-input-item" value="" disabled>
                        <option value="">MS Excel Default</option>
                        <option value="icasa">ICASA Default</option>
                        <option value="yyyyDDD">Year + DOY</option>
                        <option value="customized">Customized format</option>
                    </select>
                </div>
            </div>
            <div class="form-group col-sm-3 value-type-control value-type-date">
                <label class="control-label">Standardized Expression</label>
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
