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
            }
        }
        spsContainer.find("select").each(function () {
            chosen_init_target($(this), "chosen-select-deselect");
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
            varListDiv.append(createRefTableVarDiv(mappings[i]));
        }
//        varListDiv.append(createRefTableNewVarDiv(fileName, sheetName, varListDiv));
        initRefTableNewVarDiv(ret.find("[name='ref_var_new']"), fileName, sheetName, varListDiv);
        return ret;
    }

    function createRefTableVarDiv(mapping) {
        let ret = $("#template").find("[name='template_ref_var']").clone();
        ret.find("[name='var_name']").html(getVarNameLabel(mapping));
        if (mapping.reference_type) {
            ret.find("[name='reference_type']").val(Object.keys(mapping.reference_type));
        }
        ret.find("[name='reference_type']").on("change", function(){
            updateRefType(mapping, $(this).val());
        });
        
        ret.find("[name='edit_btn']").on("click", function() {
            delete mapping.reference_flg;
            delete mapping.reference_type;
            ret.remove();
        });
        return ret;
    }
    
    function initRefTableNewVarDiv(div, fileName, sheetName, varListDiv) {
//        let ret = $("#template").find("[name='template_ref_var_new']").clone();
        let varNameComp = $('<select class="form-control" data-placeholder="Select Variables/Columns" name="var_name_opt" multiple><option value="-1"></option></select>');
        let editBtn = div.find("[name='edit_btn']");
        let refTypeSB = div.find("[name='reference_type']");
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
                    if (mappings[i].column_index === Number(values[0]) && mappings[i].reference_flg) {
                        editBtn.prop("disabled", true);
                        return;
                    }
                }
                editBtn.prop("disabled", false);
            } else {
                editBtn.prop("disabled", compoundKeys.includes(values));
            }
            
        });
        editBtn.prop("disabled", true);
        editBtn.on("click", function() {
            let varIdxs = varNameComp.val();
            if (varIdxs.length === 0) {
                // TODO give a warning for let user choose a variable
            }
            for (let i in varIdxs) {
                let varIdx = Number(varIdxs[i]);
                for (let i in mappings) {
                    if (mappings[i].column_index === varIdx) {
                        mappings[i].reference_flg = true;
                        updateRefType(mappings[i], refTypeSB.val());

                        // Add raw for new reference variable
                        let newDiv = createRefTableVarDiv(mappings[i]);
                        varListDiv.append(newDiv);
                        newDiv.find("select").each(function () {
                            chosen_init_target($(this));
                        });

                        // re-init new variable raw
                        div.find("select").each(function() {
                            $(this).find("option:selected").prop("selected", false);
                            chosen_init_target($(this));
                        });
                        $(this).prop("disabled", true);
                        return;
                    }
                }
                // TODO give a warning for unrecognized var index
            }
            
            
        });
        return div;
    }
    
    function updateRefType(mapping, opts) {
        if (opts.length === 0) {
            delete mapping.reference_type;
        } else {
            mapping.reference_type = {};
            for (let i in opts) {
                mapping.reference_type[opts[i]] = true;
            }
        }
    }
    
    function getVarNameLabel(mapping) {
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
                        ret[fileName][sheetName].keys.push(mapping);
    //                                if (mapping.ref_type.primary) {
    //                                    ret[fileName][sheetName].primary.push(mapping);
    //                                }
    //                                if (mapping.ref_type.foreign) {
    //                                    ret[fileName][sheetName].foreign.push(mapping);
    //                                }
                    }
                }
            }
        }
        return ret;
    }
</script>

<div id="template" hidden>
    <div class="panel panel-info" name="template_ref_table">
        <div class="panel-heading">
            <div name="file_name" class="col-sm-12"> + fileName + </div>
            <div class="row text-center">
                <div class="col-sm-2 text-right"><span class="label label-primary">Sheet</span></div>
                <div class="col-sm-10">
                    <div class="col-sm-3 text-left"><span class="label label-primary">Variable</span></div>
                    <div class="col-sm-9">
                        <div class="col-sm-5"><span class="label label-primary">Ref Type</span></div>
                        <div class="col-sm-3"><span class="label label-primary">Ref Target</span></div>
                        <div class="col-sm-3"><span class="label label-primary">Ref other</span></div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="panel-body" name="template_ref_sheet">
        <div class="row">
            <div class="col-sm-2 text-right">
                <label name="sheet_name" class="control-label"> + sheetName + </label>
            </div>
            <div class="col-sm-10">
                <div name="var_list"></div>
                <div class="row" name="ref_var_new">
                    <div class="col-sm-3" name="var_name"></div>
                    <div class="col-sm-9">
                        <div class="col-sm-5">
                            <select name="reference_type" class="form-control" data-placeholder="Choose reference types..." multiple>
                                <option value=""></option>
                                <option value="primary">Primary</option>
                                <option value="foreign">Foreign</option>
                                <option value="compound">Compound</option>
                            </select>
                        </div>
                        <div class="col-sm-3">
                            <input type="email" name="mapping_author" class="form-control" value="">
                        </div>
                        <div class="col-sm-3">
                            <input type="email" name="mapping_author" class="form-control" value="">
                        </div>
                        <div class="col-sm-1">
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
            <div class="col-sm-5">
                <select class="form-control" name="reference_type" data-placeholder="Choose reference types..." multiple>
                    <option value=""></option>
                    <option value="primary">Primary</option>
                    <option value="foreign">Foreign</option>
                    <option value="compound">Compound</option>
                </select>
            </div>
            <div class="col-sm-3">
                <input type="email" name="mapping_author" class="form-control" value="">
            </div>
            <div class="col-sm-3">
                <input type="email" name="mapping_author" class="form-control" value="">
            </div>
            <div class="col-sm-1">
               <button type="button" name="edit_btn" class="btn btn-danger btn-sm"><span class="glyphicon glyphicon-minus"></span></button>
            </div>
        </div>
    </div>
</div>