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
        ret.find("[name='auto_detect_btn']").on("click", function() {
            detectReferences(defListDiv);
        });
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
        if (Object.keys(templates).length > 1) {
//            fromSheetDiv.html(refDef.from.file + "<br>-- " + refDef.from.sheet);
//            toSheetDiv.html(refDef.to.file + "<br>-- " + refDef.to.sheet);
//            fromSheetDiv.html('<span style="color:' + fileColors[refDef.from.file] + '"><a data-toggle="tooltip"  title="' + refDef.from.file + '" style="color:' + fileColors[refDef.from.file] + ';text-decoration: underline;">' + refDef.from.file.substring(0, 5) + "..." + '</a> -> ' + refDef.from.sheet + '</span>');
//            toSheetDiv.html('<a data-toggle="tooltip"  title="' + refDef.to.file + '">' + refDef.to.file.substring(0, 5) + "..." + '</a> -> <span style="color:' + fileColors[refDef.to.file] + '">' + refDef.to.sheet + '</span>');
            fromSheetDiv.html('<a data-toggle="tooltip" title="' + refDef.from.file + '" style="color:' + fileColors[refDef.from.file] + '">' + refDef.from.sheet + '</a>');
            toSheetDiv.html('<a data-toggle="tooltip" title="' + refDef.to.file + '" style="color:' + fileColors[refDef.to.file] + '">' + refDef.to.sheet + '</a>');
        } else {
            fromSheetDiv.html(refDef.from.sheet);
            toSheetDiv.html(refDef.to.sheet);
        }
        setRefKeysDiv(fromKeyDiv, refDef.from);
        setRefKeysDiv(toKeyDiv, refDef.to);
        
        div.find("[name='ref_def_json']").val(JSON.stringify(refDef));
        editBtn.on("click", function() {
            div.remove();
            let fromKeyIdxs = getKeyIdxArr(refDef.from.keys);
            let toKeyIdxs = getKeyIdxArr(refDef.to.keys);
            let references = templates[refDef.from.file][refDef.from.sheet].references;
            delete references[fromKeyIdxs][getRefDefKey(refDef.to, toKeyIdxs)];
            if (Object.keys(references[fromKeyIdxs]).length === 0) {
                delete references[fromKeyIdxs];
            }
            isChanged = true;
            isViewUpdated = false;
            isDebugViewUpdated = false;
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
    
    function getKeyArr(keyIdxs, mappings, isOrgIdx) {
        let keys = [];
        if (!mappings) {
            mappings = templates[curFileName][curSheetName].mappings;
        }
        for (let i in keyIdxs) {
            for (let j in mappings) {
                if (Number(keyIdxs[i]) === mappings[j].column_index) {
                    if (isOrgIdx) {
                        let tmp = Object.assign({}, mappings[j]);
                        if (tmp.column_index_org) {
                            tmp.column_index = tmp.column_index_org;
                            delete tmp.column_index_org;
                        } else {
                            delete tmp.column_index;
                        }
                        keys.push(tmp);
                    } else {
                        keys.push(mappings[j]);
                    }
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
                isViewUpdated = false;
                isDebugViewUpdated = false;
            });
        } else {
            editBtn.on("click", function() {
                // TODO remove the record
                isChanged = true;
                isViewUpdated = false;
                isDebugViewUpdated = false;
            });
        }
        return div;
    }
    
    function createRefDefObj(fromSheet, fromKeyIdxs, toSheet, toKeyIdxs, isOrgIdx) {
        return {
            from:{
                file : fromSheet.file,
                sheet : fromSheet.sheet,
                keys : getKeyArr(fromKeyIdxs, templates[fromSheet.file][fromSheet.sheet].mappings, isOrgIdx)
            },
            to:{
                file : toSheet.file,
                sheet : toSheet.sheet,
                keys : getKeyArr(toKeyIdxs, templates[toSheet.file][toSheet.sheet].mappings, isOrgIdx)
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
        let val = [];
        if (refDef && refDef.keys) {
            val = createRefKeyTaregetKeyStr(refDef.keys);
        }
        sb.html('<option value=""></option>');
        for (let i in mappings) {
            if (mappings[i].column_index_org) {
                let opt = $('<option value="' + mappings[i].column_index + '">' + getVarNameLabel(mappings[i]) + '</option>');
                sb.append(opt);
            }
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
    
    function detectReferences(defListDiv) {
        confirmBox("This process will overwrite the exisiting reference configuration.", function() {
            for (let fileName in templates) {
                for (let sheetName in templates[fileName]) {
                    templates[fileName][sheetName].references = {};
                }
            }
            defListDiv.html("");
            let tableRanks = getTableRanks();
            let rootRankArr;
            // Check general references from lowest rank to highest rank
            for (let i = tableRanks.length - 1; i >= 0; i--) {
                let tableRankArr = tableRanks[i];
                if (!tableRankArr) {
                    continue;
                }
                rootRankArr = tableRankArr;
                for (let j in tableRankArr) {
                    let tableRank = tableRankArr[j];
                    let newRefDef= detectReference(tableRanks, tableRank, tableRank.order, true);
                    if (newRefDef && newRefDef !== true) {
                        defListDiv.append(creatRefDefDiv(newRefDef));
                    }
                }
            }
            // Check global information case
            for (let i = 0; i <= tableRanks.length - 1; i++) {
                let tableRankArr = tableRanks[i];
                if (!tableRankArr) {
                    continue;
                }
                for (let j in tableRankArr) {
                    let tableRank = tableRankArr[j];
                    let newRefDef= detectReference(tableRanks, tableRank, tableRank.order, false);
                    if (newRefDef && newRefDef !== true) {
                        defListDiv.append(creatRefDefDiv(newRefDef));
                    }
                }
            }
        });
    }
    
    function detectReference(tableRanks, tableRank, order, lookForParent) {
        let newRefDef = null;
        let catDef = icasaVarMap.getIicasaDataCatDef(order);
        let lookupOrders;
        if (lookForParent) {
            lookupOrders = catDef.parent;
        } else {
            lookupOrders = catDef.child;
        }
        if (!lookupOrders) {
            return newRefDef;
        }
        // Check direct relations
        let directTableRanks;
        if (lookForParent) {
            directTableRanks = tableRanks[catDef.rank - 1];
        } else {
            directTableRanks = tableRanks[catDef.rank + 1];
        }
        if (directTableRanks) {
            for (let i in directTableRanks) {
                let lookupTableRank = directTableRanks[i];
                if (lookupOrders.includes(lookupTableRank.order)) {
                    newRefDef = createReference(lookupTableRank.file, lookupTableRank.sheet, tableRank.file, tableRank.sheet);
                    if (newRefDef) {
                        return newRefDef;
                    }
                }
            }
        }
        // Check ground relations
        for (let k in lookupOrders) {
            newRefDef = detectReference(tableRanks, tableRank, lookupOrders[k], lookForParent);
            if (newRefDef) {
                return newRefDef;
            }
        }
        return newRefDef;
    }
    
    function createReference(fromFile, fromSheet, toFile, toSheet) {
        let ret = null;
        let from = templates[fromFile][fromSheet];
        let to = templates[toFile][toSheet];
        let toKeyIdxs = [];
        let fromKeyIdxs = [];
        if (from.mappings.length === 0 || to.mappings.length === 0) {
            return ret;
        }
        // Check if global table is already linked with child table with keys
        for (let fromKeyIdx in from.references) {
            for (let toKey in from.references[fromKeyIdx]) {
                if (from.references[fromKeyIdx][toKey].file === toFile &&
                        from.references[fromKeyIdx][toKey].sheet === toSheet) {
                    return true;
                }
            }
        }
        for (let fromKeyIdx in to.references) {
            for (let toKey in to.references[fromKeyIdx]) {
                if (to.references[fromKeyIdx][toKey].file === fromFile &&
                        to.references[fromKeyIdx][toKey].sheet === fromSheet) {
                    return true;
                }
            }
        }
        for (let i in to.mappings) {
            let toIcasa = to.mappings[i].icasa;
            let toHeader = to.mappings[i].column_header;
            if (!toIcasa && !toHeader || !to.mappings[i].column_index_org) {
                continue;
            }
            for (let j in from.mappings) {
                let fromIcasa = from.mappings[j].icasa;
                let fromHeader = from.mappings[j].column_header;
                if (!fromIcasa && !fromHeader) {
                    continue;
                }
                if (fromIcasa  && (fromIcasa  === toIcasa  || fromIcasa  === toHeader)
                 || fromHeader && (fromHeader === toHeader || fromHeader === toIcasa)) {
                    fromKeyIdxs.push(from.mappings[j].column_index);
                    toKeyIdxs.push(to.mappings[i].column_index);
                    break;
                }
            }
        }
        if (fromKeyIdxs.length === 0 && !to.single_flg) {
            return ret;
        } else {
            if (!from.references) {
                from.references = {};
            }
            let references = from.references;
            if (!references[fromKeyIdxs]) {
                references[fromKeyIdxs] = {};
            }
            let newRefDef = createRefDefObj({file: fromFile, sheet: fromSheet}, fromKeyIdxs, {file: toFile, sheet: toSheet}, toKeyIdxs);
            references[fromKeyIdxs][getRefDefKey({file: toFile, sheet: toSheet}, toKeyIdxs)] = newRefDef.to;
            ret = newRefDef;
        }
        return ret;
    }
    
    function getTableRanks() {
        let ret = [];
        for (let fileName in templates) {
            for (let sheetName in templates[fileName]) {
                let catObj = getTableCategory(templates[fileName][sheetName].mappings);
                catObj.file = fileName;
                catObj.sheet = sheetName;
                if (!ret[catObj.rank]) {
                    ret[catObj.rank] = [];
                }
                ret[catObj.rank].push(catObj);
            }
        }
        return ret;
        
    }
    
    function getTableCategory(mappings) {
        let ret = {rank : -1, category : "unknown"};
        for (let i in mappings) {
            if (mappings[i].ignored_flg || !mappings[i].column_index_org || (mappings[i].icasa && ["exname", "soil_id", "wst_id"].includes(mappings[i].icasa.toLowerCase()))) {
                continue;
            }
            let retCat = icasaVarMap.getCategory(mappings[i]);
            if (retCat.rank > 0 && (ret.rank < 0 || ret.rank > retCat.rank)) {
                ret = retCat;
            }
        }
        return ret;
    }
</script>

<div id="template" hidden>
    <div name="template_ref_table">
        <div class="row text-left">
            <div class="col-sm-12 ">
                <button type="button" class="btn btn-primary" name="auto_detect_btn">
                    <span class="glyphicon glyphicon-search"></span> Auto Detect Reference 
                </button>
            </div>
        </div>
        <div class="panel panel-info" name="">
            <div class="panel-heading">
                <div class="row" style="padding: 0px">
                    <div class="col-sm-11">
                        <div class="row" style="padding: 0px">
                            <div class="col-sm-6 text-left">
                                <span class="label label-primary">From</span> (The lookup value will be read from this table)
                                <hr>
                                <div class="row" style="padding: 0px">
                                    <div class="col-sm-6 text-left"><span class="label label-primary">Sheet</span></div>
                                    <div class="col-sm-6 text-left"><span class="label label-primary">Variable</span></div>
                                </div>
                            </div>
                            <div class="col-sm-6 text-left">
                                <span class="label label-primary">To</span> (The lookup value will be used to search records in this table)
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
                    <div name="reference_from_sheet" style="overflow-wrap:break-word"></div>
                </div>
                <div class="col-sm-3">
                    <div name="reference_from_vars" style="overflow-wrap:break-word"></div>
                </div>
                <div class="col-sm-3">
                    <div name="reference_to_sheet" style="overflow-wrap:break-word"></div>
                </div>
                <div class="col-sm-3">
                    <div name="reference_to_vars" style="overflow-wrap:break-word"></div>
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