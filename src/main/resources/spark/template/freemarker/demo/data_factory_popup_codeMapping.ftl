<script>
    function showCodeMappingDialog(mapping, codeDefs, errMsg) {
        let userCodeMappings = {};
        if (!codeDefs) {
            codeDefs = icasaVarMap.getCodeMap(mapping.icasa);
        }
        initIcasaCodeSB(codeDefs, "template_code_mappings");
        initIcasaCodeSB(codeDefs, "codeMapping_popup");
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
                        codeMappingListDiv.find("[name='template_code_mapping']").each(function (){
                            let userCode = $(this).find("[name='user_code']").val().trim();
                            let icasaCode = $(this).find("[name='icasa_code']").val();
                            if (!mapping.code_mappings) {
                                mapping.code_mappings = {};
                            }
                            if (icasaCode && icasaCode !== userCode) {
                                mapping.code_mappings[userCode] = icasaCode;
                            } else {
                                delete mapping.code_mappings[userCode];
                            }
                            if (Object.keys(mapping.code_mappings).length === 0) {
                                delete mapping.code_mappings;
                            }
                        });
                        delete mapping.code_mappings_undefined_flg;
                    } else {
                        showCodeMappingDialog(mapping, "[Warn] Fix the error");
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
            
            userCodeMappings = getUserCodeMappings(mapping);
            let codeMappingListDiv = dialog.find("[name='code_mapping_list']");
            let newDiv = dialog.find("[name='template_code_mapping_new']");
            
            codeMappingListDiv.on("change", function(){
                if ($(this).height() > window.innerHeight*0.45) {
                    $(this).css("max-height", window.innerHeight*0.45 + "px");
                    $(this).css("overflow-y", "scroll");
                } else {
                    $(this).css("max-height", undefined);
                    $(this).css("overflow-y", "visible");
                }
            });
            for (let i in userCodeMappings) {
                createCodeMappingDiv(codeMappingListDiv, userCodeMappings[i]);
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
                createCodeMappingDiv(codeMappingListDiv, userCodeMapping);
                userCodeMappings[$(this).attr("name")] = userCodeMapping;
            });
            
        });
    }
    
    function initIcasaCodeSB(codeDefs, templateId) {
        let sb = $("#" + templateId).find("[name='icasa_code']");
        sb.html('<option value=""></option>');
        for (let code in codeDefs) {
            sb.append($('<option value="' + code + '">' + codeDefs[code] + '</option>'));
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
        let sheetDef = templates[fileName][sheetName];
        let data = wbObj[fileName][sheetName].data;
        let codeMappings = mapping.code_mappings;
        if (!codeMappings) {
            codeMappings = {}; // TODO wait for the final style of code mapping in SC2
        }
        if (sheetDef.data_start_row) {
            data = data.slice(sheetDef.data_start_row - 1);
        }
        for (let i in data) {
            let val = data[i][mapping.column_index - 1].trim();
            if (val && !ret[val]) {
                ret[val] = {user_code : val};
                if (codeMappings[val]) {
                    ret[val].icasa_code = codeMappings[val];
                }
            }
        }
        return ret;
    }
    
    function createCodeMappingDiv(codeMappingListDiv, codeMapping) {
        let div = $("#template_code_mappings").find("[name='template_code_mapping']").clone();
        for (let key in codeMapping) {
            div.find("[name='" + key + "']").val(codeMapping[key]);
        }
        if (!codeMapping.icasa_code) {
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
    <div class="col-sm-12">
<!--        <div class="row text-left">
            <div class="col-sm-12 ">
                <button type="button" class="btn btn-primary" name="auto_detect_btn">
                    <span class="glyphicon glyphicon-search"></span> Auto Detect Mappings 
                </button>
            </div>
        </div>-->
        <div class="panel panel-info">
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
                                    <div class="col-sm-12 text-left"><span class="label label-primary">ICASA Code</span></div>
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
                                <select class="form-control code-mapping-input" name="icasa_code" data-placeholder="Choose ...">
                                </select>
                            </div>
                        </div>
                        <div class="col-sm-1">
                            <button type="button" name="edit_btn" class="btn btn-primary btn-sm" disabled><span class="glyphicon glyphicon-plus"></span></button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
<div id="template_code_mappings" hidden>
    <div name="template_code_mapping" class="row" style="padding-top: 10px">
        <div class="col-sm-11">
            <div class="col-sm-6">
                <input type="text" class="form-control" name="user_code" data-placeholder="User Code..." readonly>
            </div>
            <div class="col-sm-6">
                <select class="form-control" name="icasa_code" data-placeholder="Choose ...">
                </select>
            </div>
        </div>
        <div class="col-sm-1">
            <button type="button" name="edit_btn" class="btn btn-primary btn-sm"><span class="glyphicon glyphicon-minus"></span></button>
        </div>
    </div>
</div>