<script>
    function showCodeMappingDialog(mapping, codeDefs, isCustomized, errMsg) {
        let userCodeMappings = {};
        if (!codeDefs) {
            codeDefs = {};
        }
        if (!isCustomized) {
            initIcasaCodeSB(codeDefs, "template_code_mappings");
            initIcasaCodeSB(codeDefs, "codeMapping_popup");
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
                    let codeMappingListDiv = $(this).find("[name='code_mapping_list']");
                    let validation = true;
                    if (validation) {
                        let mappingDivList;
                        if (isCustomized) {
                            mappingDivList = codeMappingListDiv.find("[name='template_code_mapping_customized']");
                        } else {
                            mappingDivList = codeMappingListDiv.find("[name='template_code_mapping']");
                        }
                        delete mapping.code_mappings;
                        delete mapping.code_descriptions;
                        mappingDivList.each(function (){
                            let userCode = $(this).find("[name='user_code']").val().trim();
                            let userCodeDesc = $(this).find("[name='user_code_desc']").val().trim();
                            // Save icasa code mapping
                            if (!isCustomized) {
                                let icasaCode = $(this).find("[name='icasa_code']").val();
                                if (!mapping.code_mappings) {
                                    mapping.code_mappings = {};
                                }
                                if (icasaCode && icasaCode !== userCode) {
                                    mapping.code_mappings[userCode] = icasaCode;
                                } else {
                                    delete mapping.code_mappings[userCode];
                                }
                            }
                            if (mapping.code_mappings && Object.keys(mapping.code_mappings).length === 0) {
                                delete mapping.code_mappings;
                            }
                            // Save user code description
                            if (!mapping.code_descriptions) {
                                mapping.code_descriptions = {};
                            }
                            if (userCodeDesc && userCode) {
                                mapping.code_descriptions[userCode] = userCodeDesc;
                            } else {
                                delete mapping.code_descriptions[userCode];
                            }
                            if (Object.keys(mapping.code_descriptions).length === 0) {
                                delete mapping.code_descriptions;
                            }
                        });
                        delete mapping.code_mappings_undefined_flg;
                        if (isCustomized) {
                            delete mapping.code_mappings;
                        }
                    } else {
                        showCodeMappingDialog(mapping, codeDefs, isCustomized, "[Warn] Fix the error");
                    }
                }
            }
        };
        let dialog = bootbox.dialog({
            title: "<h2>Map your code with ICASA code</h2>",
            size: 'large',
            message: $("#codeMapping_popup").html(),
            buttons: buttons
        });
        dialog.find(".modal-content").drags();
        dialog.on("shown.bs.modal", function() {
            if (errMsg) {
                dialog.find("[name='dialog_msg']").text(errMsg);
            }
            
            if (isCustomized) {
                dialog.find("[name='code_mapping_input_panel']").append($("#template_code_mappings").find("[name='template_code_mapping_customized_panel']").clone());
            } else {
                dialog.find("[name='code_mapping_input_panel']").append($("#template_code_mappings").find("[name='template_code_mapping_panel']").clone());
            }
            
            userCodeMappings = getUserCodeMappings(mapping);
            let codeMappingListDiv = dialog.find("[name='code_mapping_list']");
            let newDiv = dialog.find("[name='template_code_mapping_new']");
            
            codeMappingListDiv.on("change", function(){
                if ($(this).height() >= window.innerHeight*0.45) {
                    $(this).css("max-height", window.innerHeight*0.5 + "px");
                    $(this).css("overflow-y", "auto");
                } else {
                    $(this).css("max-height", undefined);
                    $(this).css("overflow-y", "visible");
                }
            });
            for (let i in userCodeMappings) {
                createCodeMappingDiv(codeMappingListDiv, userCodeMappings[i], userCodeMappings, isCustomized);
            }
            
            chosen_init_target(newDiv.find("select"), "chosen-select-deselect-single");
            newDiv.find("[name='edit_btn']").attr("disabled", true);
            newDiv.find("[name='user_code']").on("input", function() {
                newDiv.find("[name='edit_btn']").attr("disabled", !$(this).val().trim() || !!userCodeMappings[$(this).val().trim()]);
            });
            
            newDiv.find("[name='edit_btn']").on("click", function() {
                let userCodeMapping = {};
                newDiv.find(".code-mapping-input").each(function() {
                    userCodeMapping[$(this).attr("name")] = $(this).val();
                    $(this).val("").trigger("input");
                });
                createCodeMappingDiv(codeMappingListDiv, userCodeMapping, userCodeMappings, isCustomized);
                userCodeMappings[$(this).attr("name")] = userCodeMapping;
            });
            
        });
    }
    
    function initIcasaCodeSB(codeDefs, templateId) {
        let sb = $("#" + templateId).find("[name='icasa_code']");
        sb.html('<option value=""></option>');
        for (let code in codeDefs) {
            sb.append($('<option value="' + code + '">' + codeDefs[code] + ' (' + code + ')</option>'));
        }
    }
    
    function getUserCodeMappings(mapping, fileName, sheetName) {
        let ret = {};
        if (!fileName) {
            fileName = curFileName;
        }
        if (!sheetName) {
            sheetName = curSheetName;
        }
        let tableDef = getCurTableDef();
        let data = getCurTableData();
        let codeMappings = mapping.code_mappings;
        if (!codeMappings) {
            codeMappings = {}; // TODO wait for the final style of code mapping in SC2
        }
        let codeDescs = mapping.code_descriptions;
        if (!codeDescs) {
            codeDescs = {}; // TODO wait for the final style of code mapping in SC2
        }
        data = getSheetDataContent(data, tableDef);
        for (let i in data) {
            let val = data[i][mapping.column_index - 1];
            if (val) {
                val = val.trim();
            }
            if (val && !ret[val]) {
                ret[val] = {user_code : val};
                if (codeMappings[val]) {
                    ret[val].icasa_code = codeMappings[val];
                }
                if (codeDescs[val]) {
                    ret[val].user_code_desc = codeDescs[val];
                }
            }
        }
        for (let key in codeMappings) {
            if (!ret[key]) {
                ret[key] = {user_code : key};
                if (codeMappings[key]) {
                    ret[key].icasa_code = codeMappings[key];
                }
                if (codeDescs[key]) {
                    ret[key].user_code_desc = codeDescs[key];
                }
            }
        }
        for (let key in codeDescs) {
            if (!ret[key]) {
                ret[key] = {user_code : key};
                if (codeMappings[key]) {
                    ret[key].icasa_code = codeMappings[key];
                }
                if (codeDescs[key]) {
                    ret[key].user_code_desc = codeDescs[key];
                }
            }
        }
        return ret;
    }
    
    function createCodeMappingDiv(codeMappingListDiv, codeMapping, userCodeMappings, isCustomized) {
        let div;
        if (isCustomized) {
            div = $("#template_code_mappings").find("[name='template_code_mapping_customized']").clone();
        } else {
            div = $("#template_code_mappings").find("[name='template_code_mapping']").clone();
        }
        for (let key in codeMapping) {
            div.find("[name='" + key + "']").val(codeMapping[key]);
        }
        if (!isCustomized && !codeMapping.icasa_code) {
            div.find("[name='icasa_code']").val(codeMapping.user_code);
        }
        div.find("[name='edit_btn']").on("click", function() {
            div.remove();
            codeMappingListDiv.trigger("change");
            delete userCodeMappings[codeMapping.user_code];
        });
        codeMappingListDiv.append(div).trigger("change");
        chosen_init_target(div.find("select"), "chosen-select-deselect-single");
        return div;
    }
</script>

<!-- popup page for define sheet -->
<div id="codeMapping_popup" hidden>
    <p name="dialog_msg" class="label label-danger"></p>
    <div class="col-sm-12" name="code_mapping_input_panel">
<!--        <div class="row text-left">
            <div class="col-sm-12 ">
                <button type="button" class="btn btn-primary" name="auto_detect_btn">
                    <span class="glyphicon glyphicon-search"></span> Auto Detect Mappings 
                </button>
            </div>
        </div>-->
    </div>
    <p>&nbsp;</p>
</div>
<div id="template_code_mappings" hidden>
    <div class="panel panel-info" name="template_code_mapping_panel">
        <div class="panel-heading">
            <div class="row" style="padding: 0px">
                <div class="col-sm-11">
                    <div class="row" style="padding: 0px">
                        <div class="col-sm-4 text-left">
                            <div class="row" style="padding: 0px">
                                <div class="col-sm-12 text-left"><span class="label label-primary">User Code</span></div>
                            </div>
                        </div>
                        <div class="col-sm-4 text-left">
                            <div class="row" style="padding: 0px">
                                <div class="col-sm-12 text-left"><span class="label label-primary">ICASA Definition</span></div>
                            </div>
                        </div>
                        <div class="col-sm-4 text-left">
                            <div class="row" style="padding: 0px">
                                <div class="col-sm-12 text-left"><span class="label label-primary">User Description</span></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-1"><span class="label label-primary">Edit</span></div>
            </div>
        </div>
        <div class="panel-body">
            <div class="row">
                <div name="code_mapping_list"></div>
                <div name="template_code_mapping_new" class="row" style="padding-top: 10px">
                    <div class="col-sm-11">
                        <div class="col-sm-4">
                            <input type="text" class="form-control code-mapping-input" name="user_code" data-placeholder="User Code...">
                        </div>
                        <div class="col-sm-4">
                            <select class="form-control code-mapping-input" name="icasa_code" data-placeholder="Choose ...">
                            </select>
                        </div>
                        <div class="col-sm-4">
                            <input type="text" class="form-control code-mapping-input" name="user_code_desc" data-placeholder="User Code Description...">
                        </div>
                    </div>
                    <div class="col-sm-1">
                        <button type="button" name="edit_btn" class="btn btn-primary btn-sm" disabled><span class="glyphicon glyphicon-plus"></span></button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="panel panel-info" name="template_code_mapping_customized_panel">
        <div class="panel-heading">
            <div class="row" style="padding: 0px">
                <div class="col-sm-11">
                    <div class="row" style="padding: 0px">
                        <div class="col-sm-6 text-left">
                            <div class="row" style="padding: 0px">
                                <div class="col-sm-12 text-left"><span class="label label-primary">User Code</span></div>
                            </div>
                        </div>
                        <div class="col-sm-6 text-left">
                            <div class="row" style="padding: 0px">
                                <div class="col-sm-12 text-left"><span class="label label-primary">User Description</span></div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-1"><span class="label label-primary">Edit</span></div>
            </div>
        </div>
        <div class="panel-body">
            <div class="row">
                <div name="code_mapping_list"></div>
                <div name="template_code_mapping_new" class="row" style="padding-top: 10px">
                    <div class="col-sm-11">
                        <div class="col-sm-6">
                            <input type="text" class="form-control code-mapping-input" name="user_code" data-placeholder="User Code...">
                        </div>
                        <div class="col-sm-6">
                            <input type="text" class="form-control code-mapping-input" name="user_code_desc" data-placeholder="User Code Description...">
                        </div>
                    </div>
                    <div class="col-sm-1">
                        <button type="button" name="edit_btn" class="btn btn-primary btn-sm" disabled><span class="glyphicon glyphicon-plus"></span></button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div name="template_code_mapping" class="row" style="padding-top: 10px">
        <div class="col-sm-11">
            <div class="col-sm-4">
                <input type="text" class="form-control" name="user_code" data-placeholder="User Code..." readonly>
            </div>
            <div class="col-sm-4">
                <select class="form-control" name="icasa_code" data-placeholder="Choose ...">
                </select>
            </div>
            <div class="col-sm-4">
                <input type="text" class="form-control" name="user_code_desc" data-placeholder="User Code Description...">
            </div>
        </div>
        <div class="col-sm-1">
            <button type="button" name="edit_btn" class="btn btn-primary btn-sm"><span class="glyphicon glyphicon-minus"></span></button>
        </div>
    </div>
    <div name="template_code_mapping_customized" class="row" style="padding-top: 10px">
        <div class="col-sm-11">
            <div class="col-sm-6">
                <input type="text" class="form-control" name="user_code" data-placeholder="User Code..." readonly>
            </div>
            <div class="col-sm-6">
                <input type="text" class="form-control" name="user_code_desc" data-placeholder="User Code Description...">
            </div>
        </div>
        <div class="col-sm-1">
            <button type="button" name="edit_btn" class="btn btn-primary btn-sm"><span class="glyphicon glyphicon-minus"></span></button>
        </div>
    </div>
</div>