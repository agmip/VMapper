<script>
    function initRefTable(spsContainer) {
        if (!spsContainer) {
            spsContainer = $('#ref_table');
        }
        spsContainer.html("");
        let refDefList = getRefDefList();
        let tableDiv = createRefTableDiv(refDefList);
        spsContainer.append(tableDiv);
        spsContainer.find("select").each(function () {
            chosen_init_target($(this), "chosen-select-deselect");
        });
    }

    function createRefTableDiv(refDefList) {
        let ret = $("#template").find("[name='template_ref_table']").clone();
        let defListDiv = ret.find("[name='ref_def_list']");
        for (let i in refDefList) {
            let refDefDiv = creatRefDefDiv(refDefList[i]);
            defListDiv.append(refDefDiv);
        }
        initRefDefDiv(ret.find("[name='template_ref_def_new']"));
        return ret;
    }
    
    function creatRefDefDiv(refDef) {
//        return initRefDefDiv(null, refDef);
        let div = $("#template").find("[name='template_ref_def_readonly']").clone();
        let editBtn = div.find("[name='edit_btn']");
        let fromSheetDiv = div.find("[name='reference_from_sheet']");
        let toSheetDiv = div.find("[name='reference_to_sheet']");
        let fromKeyDiv = div.find("[name='reference_from_vars']");
        let toKeyDiv = div.find("[name='reference_to_vars']");
        fromSheetDiv.html(refDef.from.file + "<br>-- " + refDef.from.sheet);
        toSheetDiv.html(refDef.to.file + "<br>-- " + refDef.to.sheet);
        setRefKeysDiv(fromKeyDiv, refDef.from);
        setRefKeysDiv(toKeyDiv, refDef.to);
        div.find("[name='ref_def_json']").val(JSON.stringify(refDef));
        editBtn.on("click", function() {
            div.remove();
            let fromKeyIdxs = getKeyIdxArr(refDef.from.keys);
            let toKeyIdxs = getKeyIdxArr(refDef.to.keys);
            let references = templates[refDef.from.file][refDef.from.sheet].references;
            delete references[fromKeyIdxs][getRefDefKey(refDef.to, toKeyIdxs)];
            if (Object.keys(references[fromKeyIdxs])) {
                delete references[fromKeyIdxs];
            }
            isChanged = true;
        });
        return div;
    }
    
    function getKeyIdxArr(keys) {
        let keyIdxs = [];
        for (let i in keys) {
            keyIdxs.push(Number(keys[i].column_index));
        }
        return keyIdxs;
    }
    
    function getKeyArr(keyIdxs, mappings) {
        let keys = [];
        for (let i in keyIdxs) {
            for (let j in mappings) {
                if (Number(keyIdxs[i]) === mappings[j].column_index) {
                    keys.push(mappings[j]);
                    break;
                }
            }
        }
        return keys;
    }
    
    function setRefKeysDiv(div, refDef) {
        let mappings = templates[refDef.file][refDef.sheet].mappings;
        let text = [];
        for (let i in refDef.keys) {
            for (let j in mappings) {
                if (mappings[j].column_index === refDef.keys[i].column_index) {
                    text.push(getVarNameLabel(mappings[j]));
                    break;
                }
            }
        }
        div.html(text.join("<br>"));
    }

    function initRefDefDiv(div, refDef) {
        let isNewKeyDiv = true;
        let defListDiv;
        if (!div) {
            div = $("#template").find("[name='template_ref_def']").clone();
            isNewKeyDiv = false;
        }
        if (isNewKeyDiv) {
            defListDiv = div.prev();
        }
        let editBtn = div.find("[name='edit_btn']");
        let fromSheetSB = div.find("[name='reference_from_sheet']");
        let toSheetSB = div.find("[name='reference_to_sheet']");
        let fromKeySB = div.find("[name='reference_from_vars']");
        let toKeySB = div.find("[name='reference_to_vars']");
        let singleCB = div.find("[name='meta_table_flg']");
        
        if (refDef) {
            initSheetSB(fromSheetSB, refDef.from);
            initSheetSB(toSheetSB, refDef.to);
            initKeySB(fromKeySB, JSON.parse(fromSheetSB.val()));
            initKeySB(toKeySB, JSON.parse(toSheetSB.val()));
            setKeySB(fromKeySB, refDef.from.keys);
            setKeySB(toKeySB, refDef.to.keys);
        } else {
            initSheetSB(fromSheetSB);
            initSheetSB(toSheetSB);
        }
        
        fromSheetSB.on("change", function() {
            let val = $(this).val();
            if (!val) {
                fromKeySB.val([]).prop("disabled", true).trigger("chosen:updated").trigger("change");
                toSheetSB.find("option").prop("disabled", false).trigger("chosen:updated");
            } else {
                let refDefSheet = JSON.parse(val);
                fromKeySB.prop("disabled", singleCB.prop("checked"));
                initKeySB(fromKeySB, refDefSheet);
                if (toSheetSB.val() === val) {
                    toSheetSB.val("");
                }
                toSheetSB.find("option").each(function () {
                    $(this).prop("disabled", $(this).val() === val);
                }).trigger("chosen:updated");
            }
        });
        fromKeySB.on("change", function() {
            if (!toSheetSB.val()) {
                return;
            }
            let refDefSheet = JSON.parse(toSheetSB.val());
            let vals = $(this).val();
            if (vals.length > 0) {
                let mappingsTo = templates[refDefSheet.file][refDefSheet.sheet].mappings;
                refDefSheet = JSON.parse(fromSheetSB.val());
                let mappingsFrom = templates[refDefSheet.file][refDefSheet.sheet].mappings;
                let keys = [];
                for (let i in vals) {
                    for (let j in mappingsFrom) {
                        if (Number(vals[i]) === mappingsFrom[j].column_index) {
                            keys.push(mappingsFrom[j]);
                            break;
                        }
                    }
                }
                let valsTo = [];
                for (let i in keys) {
                    for (let j in mappingsTo) {
                        if ((keys[i].icasa
                                && (keys[i].icasa === mappingsTo[j].icasa
                                || keys[i].icasa === mappingsTo[j].column_header))
                            || (keys[i].column_header
                                && (keys[i].column_header === mappingsTo[j].icasa
                                || keys[i].column_header === mappingsTo[j].column_header)
                            )) {
                            valsTo.push(mappingsTo[j].column_index + "");
                            break;
                        }
                    }
                }
                toKeySB.val(valsTo).trigger("chosen:updated").trigger("change");
            } else {
                
            }
        });
        toSheetSB.on("change", function() {
            let val = $(this).val();
            if (!val) {
                singleCB.prop("checked", false).prop("disabled", true);
                toKeySB.val([]).prop("disabled", true).trigger("chosen:updated").trigger("change");
            } else {
                let refDefSheet = JSON.parse(val);
                if (templates[refDefSheet.file][refDefSheet.sheet].single_flg) {
                    singleCB.prop("disabled", false);
                } else {
                    singleCB.prop("disabled", true);
                    if (singleCB.prop("checked")) {
                        singleCB.prop("checked", false).trigger("change");
                    }
                }
                toKeySB.prop("disabled", singleCB.prop("checked"));
                initKeySB(toKeySB, refDefSheet);
                fromKeySB.trigger("change");
            }
        });
        toKeySB.on("change", function() {
            if (toKeySB.val().length === 0) {
                editBtn.prop("disabled", true);
            } else if (toKeySB.val().length !== fromKeySB.val().length) {
                editBtn.prop("disabled", true);
            } else if (isRefDefExistDiv(div)) {
                editBtn.prop("disabled", true);
            } else {
                editBtn.prop("disabled", false);
            }
        });
        if (isNewKeyDiv) {
            singleCB.on("change", function() {
                let isChecked = singleCB.prop("checked");
                fromKeySB.val([]).prop("disabled", isChecked).trigger("chosen:updated");
                toKeySB.val([]).prop("disabled", isChecked).trigger("chosen:updated");
                editBtn.prop("disabled", !isChecked);
            });
            editBtn.prop("disabled", true).on("click", function() {
                let fromSheet = JSON.parse(fromSheetSB.val());
                let fromKeyIdxs = fromKeySB.val();
                let toSheet = JSON.parse(toSheetSB.val());
                let toKeyIdxs = toKeySB.val();
                let newRefDef = createRefDefObj(fromSheet, fromKeyIdxs, toSheet, toKeyIdxs);
                
                let references = templates[fromSheet.file][fromSheet.sheet].references;
                if (!references[fromKeyIdxs]) {
                    references[fromKeyIdxs] = {};
                }
                references[fromKeyIdxs][getRefDefKey(toSheet, toKeyIdxs)] = newRefDef.to;
                
                defListDiv.append(creatRefDefDiv(newRefDef));
                fromSheetSB.val([]).trigger("chosen:updated").trigger("change");
                toSheetSB.val([]).trigger("chosen:updated").trigger("change");
                isChanged = true;
            });
        } else {
            editBtn.on("click", function() {
                // TODO remove the record
                isChanged = true;
            });
        }
        return div;
    }
    
    function createRefDefObj(fromSheet, fromKeyIdxs, toSheet, toKeyIdxs) {
        return {
            from:{
                file : fromSheet.file,
                sheet : fromSheet.sheet,
                keys : getKeyArr(fromKeyIdxs, templates[fromSheet.file][fromSheet.sheet].mappings)
            },
            to:{
                file : toSheet.file,
                sheet : toSheet.sheet,
                keys : getKeyArr(toKeyIdxs, templates[toSheet.file][toSheet.sheet].mappings)
            }
        };
    }
    
    function setKeySB(sb, keys) {
        let vals = [];
        for (let i in keys) {
            vals.push(keys[i].column_index);
        }
        sb.val(vals);
    }
    
    function initSheetSB(sb, refDef) {
        let val = sb.val();
        if (refDef) {
            val = createRefSheetTaregetKeyStr(refDef.file, refDef.sheet);
        }
        sb.html('<option value=""></option>');
        for (let fileName in templates) {
            let optGrp = $('<optgroup name="' + fileName+ '" label="' + fileName + '"></optgroup>');
            sb.append(optGrp);
            for (let sheetName in templates[fileName]) {
                let opt = $('<option value=\'' + createRefSheetTaregetKeyStr(fileName, sheetName) + '\'>' + sheetName + '</option>');
                optGrp.append(opt);
            }
        }
        sb.val(val).trigger("chosen:updated");
        if (refDef) {
            sb.trigger("change");
        }
    }
    
    function initKeySB(sb, refDef) {
        if (!refDef || !refDef.file || !refDef.sheet) {
            return;
        }
        let mappings = templates[refDef.file][refDef.sheet].mappings;
        let val = sb.val();
        if (refDef && refDef.keys) {
            val = createRefKeyTaregetKeyStr(refDef.keys);
        }
        sb.html('<option value=""></option>');
        for (let i in mappings) {
            let opt = $('<option value="' + mappings[i].column_index + '">' + getVarNameLabel(mappings[i]) + '</option>');
            sb.append(opt);
        }
        sb.val(val).trigger("chosen:updated");
    }
    
    function isRefDefExistDiv(refDefDiv) {
        let fromSheetSB = refDefDiv.find("[name='reference_from_sheet']");
        let toSheetSB = refDefDiv.find("[name='reference_to_sheet']");
        let fromKeySB = refDefDiv.find("[name='reference_from_var']");
        let toKeySB = refDefDiv.find("[name='reference_to_var']");
        isRefDefExist(JSON.parse(fromSheetSB.val()), fromKeySB.val(), JSON.parse(toSheetSB.val()), toKeySB.val());
    }
    
    function isRefDefExist(fromSheet, fromKeyIdxs, toSheet, toKeyIdxs) {
        let references = templates[fromSheet.file][fromSheet.sheet].references;
        return !!references[fromKeyIdxs] && !!references[fromKeyIdxs][getRefDefKey(toSheet, toKeyIdxs)];
    }
    
    function getRefDefKey(sheet, keyIdxs) {
        return "[" + sheet.file + "][" + sheet.sheet + "]:" + keyIdxs;
    }
    
    function createRefSheetTaregetKeyStr(fileName, sheetName) {
        let keyObj = {
            file : fileName,
            sheet : sheetName
        };
        return JSON.stringify(keyObj);
    }
    
    function createRefKeyTaregetKeyStr(keys) {
        let keyObj = [];
        for (let i in keys) {
            keyObj.push(keys[i].column_index);
        }
        return JSON.stringify(keyObj);
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
    
    function getRefDefList() {
        let ret = [];
        for (let fileName in templates) {
            let template = templates[fileName];
            for (let sheetName in template) {
                for (let keyIdxs in template[sheetName].references) {
                    let refDefFrom = {
                        file: fileName,
                        sheet: sheetName,
                        keys: getKeyArr(JSON.parse("[" + keyIdxs + "]"), template[sheetName].mappings)
                    };
                    let refDefTo = template[sheetName].references[keyIdxs];
                    for (let refDefKey in refDefTo) {
                        ret.push({
                            from: refDefFrom,
                            to: refDefTo[refDefKey]
                        });
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
            <div class="row" style="padding: 0px">
            <div class="col-sm-11">
                <div class="row" style="padding: 0px">
                    <div class="col-sm-6 text-left">
                        <span class="label label-primary">From</span>
                        <hr>
                        <div class="row" style="padding: 0px">
                            <div class="col-sm-6 text-left"><span class="label label-primary">Sheet</span></div>
                            <div class="col-sm-6 text-left"><span class="label label-primary">Variable</span></div>
                        </div>
                    </div>
                    <div class="col-sm-6 text-left">
                        <span class="label label-primary">To</span>
                        <hr>
                        <div class="row" style="padding: 0px">
                            <div class="col-sm-6 text-left"><span class="label label-primary">Sheet</span></div>
                            <div class="col-sm-6 text-left"><span class="label label-primary">Variable</span></div>
                        </div>
                    </div>
                </div>
                
            </div>
            <div class="col-sm-1"><span class="label label-primary">Edit</span></div>
            </div>
            
<!--            <div class="row" style="padding: 0px">
                <div class="col-sm-11">
                    <div class="col-sm-6 text-left"><span class="label label-primary">From</span></div>
                    <div class="col-sm-6 text-left"><span class="label label-primary">To</span></div>
                </div>
                <div class="col-sm-1"><span class="label label-primary">Edit</span></div>
            </div><div class="row" style="padding: 0px">
                <div class="col-sm-11">
                    <div class="col-sm-3 text-left"><span class="label label-primary">Sheet</span></div>
                    <div class="col-sm-3 text-left"><span class="label label-primary">Variable</span></div>
                    <div class="col-sm-3 text-left"><span class="label label-primary">Sheet</span></div>
                    <div class="col-sm-3 text-left"><span class="label label-primary">Variable</span></div>
                </div>
            </div>-->
        </div>
        <div class="panel-body">
            <div class="row">
                <div name="ref_def_list"></div>
                <div name="template_ref_def_new" class="row" style="padding-top: 10px">
                    <div class="col-sm-11">
                        <div class="col-sm-3">
                            <select class="form-control" name="reference_from_sheet" data-placeholder="Choose ...">
                                <option value=""></option>
                            </select>
                        </div>
                        <div class="col-sm-3">
                            <select class="form-control" name="reference_from_vars" data-placeholder="Choose ..." multiple disabled>
                                <option value=""></option>
                            </select>
                        </div>
                        <div class="col-sm-3">
                            <select class="form-control" name="reference_to_sheet" data-placeholder="Choose ...">
                                <option value=""></option>
                            </select>
                        </div>
                        <div class="col-sm-3">
                            <select class="form-control" name="reference_to_vars" data-placeholder="Choose ..." multiple disabled>
                                <option value=""></option>
                            </select>
                        </div>
                        <div class="col-sm-6 col-sm-offset-6">
                            <input type="checkbox" name="meta_table_flg" disabled> Apply the data in this table as global information to every record in "From" table.
                        </div>
                    </div>
                    <div class="col-sm-1">
                        <button type="button" name="edit_btn" class="btn btn-primary btn-sm"><span class="glyphicon glyphicon-plus"></span></button>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div name="template_ref_def" class="row">
        <div class="col-sm-11">
            <div class="col-sm-3">
                <select class="form-control" name="reference_from_sheet" data-placeholder="Choose ..." disabled>
                    <option value=""></option>
                </select>
            </div>
            <div class="col-sm-3">
                <select class="form-control" name="reference_from_vars" data-placeholder="Choose ..." multiple disabled>
                    <option value=""></option>
                </select>
            </div>
            <div class="col-sm-3">
                <select class="form-control" name="reference_to_sheet" data-placeholder="Choose ..." disabled>
                    <option value=""></option>
                </select>
            </div>
            <div class="col-sm-3">
                <select class="form-control" name="reference_to_vars" data-placeholder="Choose ..." multiple disabled>
                    <option value=""></option>
                </select>
            </div>
        </div>
        <div class="col-sm-1">
            <button type="button" name="edit_btn" class="btn btn-danger btn-sm"><span class="glyphicon glyphicon-minus"></span></button>
        </div>
    </div>
    <div name="template_ref_def_readonly" >
        <div class="row">
            <div class="col-sm-11">
                <div class="col-sm-3">
                    <div name="reference_from_sheet"></div>
                </div>
                <div class="col-sm-3">
                    <div name="reference_from_vars"></div>
                </div>
                <div class="col-sm-3">
                    <div name="reference_to_sheet"></div>
                </div>
                <div class="col-sm-3">
                    <div name="reference_to_vars"></div>
                </div>
            </div>
            <input type='hidden' name='ref_def_json'>
            <div class="col-sm-1">
                <button type="button" name="edit_btn" class="btn btn-danger btn-sm"><span class="glyphicon glyphicon-minus"></span></button>
            </div>
        </div>
        <hr>
    </div>
</div>