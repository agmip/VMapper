<script>
    function initRefTable(fileName, sheetName, spsContainer) {
        if (!spsContainer) {
            spsContainer = $('#ref_table');
        }
        spsContainer.html("");
        let refVarList = getRefVarList();
        for (fileName in refVarList) {
            let fileDiv = createRefTableFileDiv(fileName);
            spsContainer.append(fileDiv);
            for (sheetName in refVarList[fileName]) {
                let sheetDiv = creatRefTableSheetDiv(fileName, sheetName, refVarList[fileName][sheetName].keys);
                fileDiv.append(sheetDiv);
                sheetDiv.on("change-var", function() {
                    spsContainer.find("[name='reference_target']").each(function () {
                        createRefTargetOptList($(this));
                        $(this).trigger("chosen:updated")
                    });
                });
            }
        }
        spsContainer.find("select").each(function () {
//            if ($(this).prop("name") === "reference_target") {
//                chosen_init_target($(this), "chosen-select-deselect-single");
//            } else {
                chosen_init_target($(this), "chosen-select-deselect");
//            }
        });
    }

    function createRefTableFileDiv(fileName) {
        let ret = $("#template").find("[name='template_ref_table']").clone();
        ret.find("[name='file_name']").html(fileName);
        return ret;
    }

    function creatRefTableSheetDiv(fileName, sheetName, mappings) {
        let ret = $("#template").find("[name='template_ref_sheet']").clone();
        ret.find("[name='sheet_name']").html(sheetName);
        let varListDiv = ret.find("[name='var_list']");
        for (let i in mappings) {
            varListDiv.append(createRefTableVarDiv(fileName, sheetName, mappings[i]));
        }
//        varListDiv.append(createRefTableNewVarDiv(fileName, sheetName, varListDiv));
        initRefTableNewVarDiv(ret.find("[name='ref_var_new']"), fileName, sheetName, varListDiv);
        return ret;
    }

    function createRefTableVarDiv(fileName, sheetName, mapping) {
        let ret = $("#template").find("[name='template_ref_var']").clone();
        let refTypeSB = ret.find("[name='reference_type']");
        let refTargetSB = ret.find("[name='reference_target']");
        ret.find("[name='var_name']").html(getVarNameLabel(mapping));
        createRefTargetOptList(refTargetSB, fileName, sheetName);
        if (mapping.reference_type) {
            refTypeSB.val(Object.keys(mapping.reference_type));
            refTargetSB.prop("disabled", !mapping.reference_type.foreign);
            if (mapping.reference_type.foreign) {
                let fkeys;
                if (mapping.reference_target) {
                    if (mapping.reference_target.source_keys.length === 1) {
                        fkeys = createRefTaregetKeyStr(
                            mapping.reference_target.source_file,
                            mapping.reference_target.source_sheet,
                            mapping.reference_target.source_keys[0]);
                    }
                    
                }
                refTargetSB.val(fkeys);
            }
        }
        refTypeSB.on("change", function(){
            updateRefType(mapping, $(this).val());
            let isForeign = $(this).val().includes("foreign");
            if (!isForeign) {
                refTargetSB.val([]).trigger("change");
            }
            refTargetSB.prop("disabled", !isForeign).trigger("chosen:updated");
        });
        refTargetSB.on("change", function() {
            updateRefTarget(mapping, $(this).val());
        });
        
        ret.find("[name='edit_btn']").on("click", function() {
            if (mapping.vars) {
                let compoundKeys = templates[fileName][sheetName].compoundKeys;
                let idx = compoundKeys.indexOf(mapping);
                compoundKeys.splice(idx, 1);
            } else {
                delete mapping.reference_flg;
                delete mapping.reference_type;
            }
            ret.remove();
        });
        return ret;
    }
    
    function initRefTableNewVarDiv(div, fileName, sheetName, varListDiv) {
//        let ret = $("#template").find("[name='template_ref_var_new']").clone();
        let varNameComp = $('<select class="form-control" data-placeholder="Select Variables/Columns" name="var_name_opt" multiple><option value="-1"></option></select>');
        let editBtn = div.find("[name='edit_btn']");
        let refTypeSB = div.find("[name='reference_type']");
        let refTargetSB = div.find("[name='reference_target']");
        let mappings = templates[fileName][sheetName].mappings;
        let compoundKeys = templates[fileName][sheetName].compoundKeys;
        for (let i in mappings) {
            varNameComp.append('<option value="' + mappings[i].column_index + '">' + getVarNameLabel(mappings[i]) + '</option>');
        }
        div.find("[name='var_name']").append(varNameComp);
        varNameComp.on('change', function() {
            let values = $(this).val();
            if (values.length === 0) {
                editBtn.prop("disabled", true);
            } else if (values.length === 1) {
                for (let i in mappings) {
                    if (mappings[i].column_index === Number(values[0]) && isRefVar(mappings[i])) {
                        editBtn.prop("disabled", true);
                        return;
                    }
                }
                editBtn.prop("disabled", false);
            } else {
                let isRepeated = false;
                for (let i in compoundKeys) {
                    if (compoundKeys[i].vars.length === values.length) {
                        for (let j in values) {
                            isRepeated = false;
                            for (let k in compoundKeys[i].vars) {
                                if (compoundKeys[i].vars[k].column_index === Number(values[j])) {
                                    isRepeated = true;
                                    break;
                                }
                            }
                            if (!isRepeated) {
                                break;
                            }
                        }
                    }
                    if (isRepeated) {
                        break;
                    }
                }
                editBtn.prop("disabled", isRepeated);
            }
            
        });
        createRefTargetOptList(refTargetSB, fileName, sheetName);
        refTypeSB.on("change", function() {
            let isForeign = $(this).val().includes("foreign");
            if (!isForeign) {
                refTargetSB.val([]);
            }
            refTargetSB.prop("disabled", !isForeign);
        });
        editBtn.prop("disabled", true);
        editBtn.on("click", function() {
            let varIdxs = varNameComp.val();
            if (varIdxs.length === 0) {
                // TODO give a warning for let user choose a variable
            } else {
                // Init reference mapping target
                let mapping;
                if (varIdxs.length === 1) {
                    let varIdx = Number(varIdxs[0]);
                    for (let i in mappings) {
                        if (mappings[i].column_index === varIdx) {
                            mapping = mappings[i];
                            break;
                        }
                    }
                    // TODO give a warning for unrecognized var index
                } else {
                    mapping = {vars : [], column_indexs : []};
                    for (let i in varIdxs) {
                        let varIdx = Number(varIdxs[i]);
                        for (let i in mappings) {
                            if (mappings[i].column_index === varIdx) {
                                mappings[i].reference_flg = true;
                                updateRefType(mappings[i], ["compound"]);
                                mapping.vars.push(mappings[i]);
                                mapping.column_indexs.push(varIdx);
                            }
                        }
                    }
                    mapping.column_index = mapping.column_indexs.join("__");
                    compoundKeys.push(mapping);
                }
                
                // Setup reference fields
                mapping.reference_flg = true;
                updateRefType(mapping, refTypeSB.val());
                updateRefTarget(mapping, refTargetSB.val());
                // Add raw for new reference variable
                let newDiv = createRefTableVarDiv(fileName, sheetName, mapping);
                varListDiv.append(newDiv).trigger("change-var");
                newDiv.find("select").each(function () {
                    chosen_init_target($(this));
                });
            }
            // re-init new variable raw
            div.find("select").each(function() {
                $(this).find("option:selected").prop("selected", false);
                chosen_init_target($(this));
            });
            $(this).prop("disabled", true);
        });
        return div;
    }
    
    function createRefTargetOptList(refTargetSB, curFile, curSheet) {
        let refVarList = getRefVarList();
        let curVal = refTargetSB.val();
        refTargetSB.html('<option value=""></option>');
        if (!curFile) {
            curFile = refTargetSB.parents("[name='template_ref_table']").find("[name='file_name']").text();
        }
        if (!curSheet) {
            curSheet = refTargetSB.parents("[name='template_ref_sheet']").find("[name='sheet_name']").text();
        }
        for (let fileName in refVarList) {
            let optGroupFile = $('<option name="' + fileName + '" style="font-weight: bold;color: darkblue" disabled>' + fileName + '</option>');
            if (fileName !== curFile || Object.keys(refVarList[fileName]).length > 1) {
                refTargetSB.append(optGroupFile);
            }
            for (let sheetName in refVarList[fileName]) {
                if (fileName === curFile && sheetName === curSheet) {
                    continue;
                }
                let optGroup = $('<optgroup name="' + sheetName+ '" label="|-' + sheetName + '"></optgroup>');
                for (let i in refVarList[fileName][sheetName].keys) {
                    if (refVarList[fileName][sheetName].keys[i].reference_type.primary) {
                        optGroup.append($('<option value=\'' + createRefTaregetKeyStr(fileName, sheetName, refVarList[fileName][sheetName].keys[i]) + '\'>' + getVarNameLabel(refVarList[fileName][sheetName].keys[i]) + '</option>'));
                    }
//                    else {
//                        optGroup.append($('<option>' + getVarNameLabel(refVarList[fileName][sheetName].keys[i]) + '</option>'));
//                    }
                }
                refTargetSB.append(optGroup);
            }
        }
        refTargetSB.val(curVal);
    }
    
    function createRefTaregetKeyStr(fileName, sheetName, mapping) {
        let keyObj = {
            column_index : mapping.column_index,
            file_name : fileName,
            sheet_name : sheetName
        };
//                        if (refVarList[fileName][sheetName].keys[i].vars) {
//                            for (let j in refVarList[fileName][sheetName].keys[i].vars) {
//                                mapping.column_index.push(refVarList[fileName][sheetName].keys[i].vars[j].column_index);
//                            }
//                        } else {
//                            mapping.column_index.push(refVarList[fileName][sheetName].keys[i].column_index);
//                        }
        return JSON.stringify(keyObj);
    }
    
    function updateRefType(mapping, opts) {
        if (opts.length === 0) {
            delete mapping.reference_type;
        } else {
            if (opts.length !== 1 || opts[0] !== "compound" || !mapping.reference_type) {
                mapping.reference_type = {};
            }
            for (let i in opts) {
                mapping.reference_type[opts[i]] = true;
            }
        }
    }
    
    function updateRefTarget(mapping, optJsonStr) {
        let targetMapping;
        let optObj;
        let isCompKey = false;
        if (optJsonStr) {
            optObj = JSON.parse(optJsonStr);
            let targetSheetDef = templates[optObj.file_name][optObj.sheet_name];
            isCompKey = isNaN(optObj.column_index);
            if (isCompKey) {
                for (let i in targetSheetDef.compoundKeys) {
                    if (optObj.column_index === targetSheetDef.compoundKeys[i].column_index) {
                        targetMapping = targetSheetDef.compoundKeys[i];
                        break;
                    }
                }
                if (!targetMapping) {
                    // TODO give warning for broken data link on index
                    return;
                }
            } else {
                for (let i in targetSheetDef.mappings) {
                    if (Number(optObj.column_index) === targetSheetDef.mappings[i].column_index) {
                        targetMapping = targetSheetDef.mappings[i];
                        break;
                    }
                }
                if (!targetMapping) {
                    // TODO give warning for broken data link on index
                    return;
                }
            }
        } else {
            targetMapping = null;
        }

        if (targetMapping) {
            mapping.reference_target = {
                source_file: optObj.file_name,
                source_sheet: optObj.sheet_name,
                source_keys: []
            };
            if (isCompKey) {
                mapping.reference_target.source_keys = targetMapping.vars;
            } else {
                mapping.reference_target.source_keys.push(targetMapping);
//                mapping.reference_target.source_keys.push({
//                    index : targetMapping.column_index,
//                    header : targetMapping.column_header,
//                    icasa : targetMapping.icasa
//                });
            }
        } else {
            delete mapping.reference_target;
        }
    }
    
    function getVarNameLabel(mapping) {
        if (mapping.vars) {
            let ret = [];
            for (let i in mapping.vars) {
                ret.push(getVarNameText(mapping.vars[i]));
            }
            return ret.join("; ");
        } else {
            return getVarNameText(mapping);
        }
    }
    
    function getVarNameText(mapping) {
        let header = mapping.column_header;
        let icasa = mapping.icasa;
        let index = mapping.column_index;
        let ret;
        if (header) {
            if (icasa && icasa.toLowerCase() !== header.toLowerCase()) {
                ret = '[' + index + '] ' + header + '->' + icasa;
            } else {
                ret = '[' + index + '] ' + header;
            }
        } else if (icasa) {
            ret = '[' + index + '] ' + icasa;
        } else {
            ret = 'Column ' + (index + 1);
        }
        return ret;
    }

    function createReferences() {
        let refVarList = getRefVarList();
    }
    
    function isRefVar(mapping) {
        return !!mapping.reference_type && (Object.keys(mapping.reference_type).length !== 1 || !mapping.reference_type.compound);
    }
    
    function getRefVarList() {
        let ret = {};
        for (let fileName in templates) {
            ret[fileName] = {};
            let template = templates[fileName];
            for (let sheetName in template) {
                ret[fileName][sheetName] = {primary: [], foreign:[], keys:[]};
                for (let i in template[sheetName].mappings) {
                    let mapping = template[sheetName].mappings[i];
                    if (mapping.reference_flg) {
                        if (isRefVar(mapping)) {
                            ret[fileName][sheetName].keys.push(mapping);
//                            if (mapping.ref_type.primary) {
//                                ret[fileName][sheetName].primary.push(mapping);
//                            }
//                            if (mapping.ref_type.foreign) {
//                                ret[fileName][sheetName].foreign.push(mapping);
//                            }
                        }
                    }
                }
                for (let i in template[sheetName].compoundKeys) {
                    let compoundKey = template[sheetName].compoundKeys[i];
                    ret[fileName][sheetName].keys.push(compoundKey);
                }
            }
        }
        return ret;
    }
</script>

<div id="template" hidden>
    <div class="panel panel-info" name="template_ref_table">
        <div class="panel-heading">
            <div name="file_name" class="col-sm-12"></div>
            <div class="row text-center">
                <div class="col-sm-2 text-right"><span class="label label-primary">Sheet</span></div>
                <div class="col-sm-10">
                    <div class="col-sm-3 text-left"><span class="label label-primary">Variable</span></div>
                    <div class="col-sm-9">
                        <div class="col-sm-4"><span class="label label-primary">Ref Type</span></div>
                        <div class="col-sm-5"><span class="label label-primary">Ref Target</span></div>
                        <!--<div class="col-sm-3"><span class="label label-primary">Ref other</span></div>-->
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="panel-body" name="template_ref_sheet">
        <div class="row">
            <div class="col-sm-2 text-right">
                <label name="sheet_name" class="control-label"></label>
            </div>
            <div class="col-sm-10">
                <div name="var_list"></div>
                <div class="row" name="ref_var_new">
                    <div class="col-sm-3" name="var_name"></div>
                    <div class="col-sm-9">
                        <div class="col-sm-4">
                            <select name="reference_type" class="form-control" data-placeholder="Choose reference types..." multiple>
                                <option value=""></option>
                                <option value="primary">Primary</option>
                                <option value="foreign">Foreign</option>
                                <!--<option value="compound">Compound</option>-->
                            </select>
                        </div>
                        <div class="col-sm-5">
                            <select class="form-control" name="reference_target" data-placeholder="Choose reference target..." disabled>
                                <option value=""></option>
                            </select>
                        </div>
<!--                        <div class="col-sm-3">
                            <input type="text" name="reference_other" class="form-control" value="">
                        </div>-->
                        <div class="col-sm-2">
                            <button type="button" name="edit_btn" class="btn btn-info btn-sm"><span class="glyphicon glyphicon-plus"></span></button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="row" name="template_ref_var">
        <div class="col-sm-3" name="var_name"></div>
        <div class="col-sm-9">
            <div class="col-sm-4">
                <select class="form-control" name="reference_type" data-placeholder="Choose reference types..." multiple>
                    <option value=""></option>
                    <option value="primary">Primary</option>
                    <option value="foreign">Foreign</option>
                    <!--<option value="compound">Compound</option>-->
                </select>
            </div>
            <div class="col-sm-5">
                <select class="form-control" name="reference_target" data-placeholder="Choose reference target...">
                    <option value=""></option>
                </select>
            </div>
<!--            <div class="col-sm-3">
                <input type="text" name="reference_other" class="form-control" value="">
            </div>-->
            <div class="col-sm-2">
               <button type="button" name="edit_btn" class="btn btn-danger btn-sm"><span class="glyphicon glyphicon-minus"></span></button>
            </div>
        </div>
    </div>
</div>