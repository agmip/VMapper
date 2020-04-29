
<!DOCTYPE html>
<html>
    <head>
        <#include "../header.ftl">
        <#include "../chosen.ftl">
        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/handsontable-pro@latest/dist/handsontable.full.min.css">
        <link rel="stylesheet" type="text/css" href="/stylesheets/toggle/bootstrap-toggle.min.css" />
        <link rel="stylesheet" type="text/css" href="/plugins/jsonViewer/jquery.json-viewer.css" />
        <script>
            const preferColors = ["#33DBFF", "#FF5733", "#33FF57", "#BD33FF", "#802B1A", "#3383FF", "#FFAF33", "#3ADDD6"];
            let wbObj;
//            let spsContainer;
            let spreadsheet;
            let refSpreadsheet;
            let curSheetName;
            let templates = {};
            let curFileName;
            let dirName;
            let isChanged;
            let isViewUpdated;
            let isDebugViewUpdated;
//            let workbook;
            let workbooks = {};
            let fileTypes = {};
            let userVarMap = {};
            let fileColors = {};
            let virColCnt = {};
            let icasaVarMap = {
                "management" : {
                    <#list icasaMgnVarMap?values?sort_by("code_display")?sort_by("set_group_order") as var>
                    "${var.code_display}" : {
                        code_display : "${var.code_display}",
                        description : '${var.description}',
                        unit_or_type : "${var.unit_or_type}",
                        dataset : "${var.dataset}",
                        subset : "${var.subset}",
                        group : "${var.group}",
                        <#if var.subgroup??>subgroup : "${var.subgroup}",</#if>
                        order : ${var.set_group_order},
                        agmip_data_entry : "${var.agmip_data_entry}",
                        category : "${var.dataset} / ${var.subset} / ${var.group}"
                    }<#sep>,</#sep>
                    </#list>
                },
                "observation" : {
                    <#list icasaObvVarMap?values?sort_by("code_display")?sort_by("set_group_order") as var>
                    "${var.code_display}" : {
                        code_display : "${var.code_display}",
                        description : "${var.description}",
                        unit_or_type : "${var.unit_or_type}",
                        dataset : "${var.dataset}",
                        subset : "${var.subset}",
                        group : "${var.group}",
                        <#if var['sub-group']??>subgroup : "${var['sub-group']}",</#if>
                        order : ${var.set_group_order},
                        agmip_data_entry : "${var.agmip_data_entry}",
                        category : "${var.dataset} / ${var.subset} / ${var.group}"
                    }<#sep>,</#sep>
                    </#list>
                },
                "allDefs" : null,
                "getAllDefs" : function () {
                    if (!this.allDefs) {
                        this.allDefs = {};
                        for (let i in this.management) {
                            this.allDefs[i] = this.management[i];
                        }
                        for (let i in this.observation) {
                            if (this.allDefs[i]) {
                                console.log("[warning] repeated ICASA definition detected! " + this.observation[i].code_display);
                            }
                            this.allDefs[i] = this.observation[i];
                        }
                    }
                    return this.allDefs;
                },
                "groupList" : null,
                "getGroupList" : function() {
                    if (!this.groupList) {
                        this.groupList = {};
                        for (let varName in this.management) {
                            if (!this.groupList[this.management[varName].order]) {
                                this.groupList[this.management[varName].order] = this.management[varName];
                            }
                        }
                        for (let varName in this.observation) {
                            if (!this.groupList[this.observation[varName].order]) {
                                this.groupList[this.observation[varName].order] = this.observation[varName];
                            }
                        }
                    }
                    return this.groupList;
                },
                "getPrimaryGroup" : function(varName) {
                    if (this.management[varName]) {
                        return this.management;
                    } else if (this.observation[varName]) {
                        return this.observation;
                    } else {
                        return null;
                    }
                },
                "isDefined" : function(varName) {
                    return !!this.getPrimaryGroup(varName);
                },
                "getDefinition" : function(varName) {
                    let group = this.getPrimaryGroup(varName);
                    if (group) {
                        return group[varName];
                    } else {
                        return null;
                    }
                    
                },
                "getUnit" : function(varName) {
                    let group = this.getPrimaryGroup(varName);
                    if (group) {
                        return group[varName].unit_or_type;
                    } else {
                        return null;
                    }
                },
                "getDataset" : function(varName, isLower) {
                    let group = this.getPrimaryGroup(varName);
                    if (group) {
                        if (isLower) {
                            return group[varName].dataset.toLowerCase();
                        } else {
                            return group[varName].dataset;
                        }
                    } else {
                        return null;
                    }
                },
                "getSubset" : function(varName, isLower) {
                    let group = this.getPrimaryGroup(varName);
                    if (group) {
                        if (isLower) {
                            return group[varName].subset.toLowerCase();
                        } else {
                            return group[varName].subset;
                        }
                    } else {
                        return null;
                    }
                },
                "getGroup" : function(varName, isLower) {
                    let group = this.getPrimaryGroup(varName);
                    if (group) {
                        if (isLower) {
                            return group[varName].group.toLowerCase();
                        } else {
                            return group[varName].group;
                        }
                    } else {
                        return null;
                    }
                },
                "getSubGroup" : function(varName, isLower) {
                    let group = this.getPrimaryGroup(varName);
                    if (group) {
                        if (isLower) {
                            return group[varName].subgroup.toLowerCase();
                        } else {
                            return group[varName].subgroup;
                        }
                    } else {
                        return null;
                    }
                },
                "getOrder" : function(varName) {
                    let group = this.getPrimaryGroup(varName);
                    if (group) {
                        return group[varName].order;
                    } else {
                        return -1;
                    }
                },
                "getMappingOrder" : function(mapping) {
                    if (mapping.order) {
                        return mapping.order;
                    }
                    let icasa = mapping.icasa;
                    if (!icasa) {
                        icasa = mapping.column_header;
                    }
                    return this.getOrder(icasa);
                },
                "icasaDataCatDef" : null,
                "getIicasaDataCatDefMapping" : function(mapping) {
                    return this.getIicasaDataCatDef(this.getMappingOrder(mapping));
                },
                "getIicasaDataCatDef" : function(order) {
                    if (!this.icasaDataCatDef) {
                        this.initIcasaDataCatDef();
//                        console.log(this.icasaDataCatDef);
                    }
                    if (!order || !this.icasaDataCatDef[order]) {
                        return {rank: -1, category: "unknown", order: order};
                    }
                    return this.icasaDataCatDef[order];
                },
                "initIcasaDataCatDef" : function() {
                    this.icasaDataCatDef = {};
                    let relations = {};
                    let lastCat;
                    let parentCat;
                    let trtCat;// = this.getCategory(this.management["TRTNO"]);
                    let fieldCat;
//                    let metaCat = this.getCategory(this.management["EXNAME"]);
                    let soilProfileCat; // = this.getCategory(this.management["SOIL_NAME"]);
                    let defs = this.getAllDefs();
                    // Put adjusted/preload required categories processing before other categories.
                    let adjDefs = ["TRTNO", "FL_LAT", "SOIL_NAME", "SL_SOURCE"];
                    let preProcessOrders = [];
                    for (let i in adjDefs) {
                        let varName = adjDefs[i];
                        let order = defs[varName].order;
                        let curCat = this.getCategory(defs[varName]);
                        this.icasaDataCatDef[order] = curCat;
                        let category = curCat.category;
                        if (!relations[category]) {
                            relations[category] = [];
                        }
                        relations[category].push(order);
                        preProcessOrders.push(order);
                        if (varName === "TRTNO") {
                            trtCat = curCat;
                            trtCat.child = [];
                        } else if (varName === "SOIL_NAME") {
                            soilProfileCat = curCat;
                        } else if (varName === "FL_LAT") {
                            fieldCat = curCat;
                        }
                    }
                    for (let varName in defs) {
                        let order = defs[varName].order;
                        let curCat;
                        if (preProcessOrders.includes(order)) {
                            preProcessOrders.splice(preProcessOrders.indexOf(order), 1);
                            curCat = this.icasaDataCatDef[order];
                        } else if (this.icasaDataCatDef[order]) {
                            continue;
                        } else {
                            curCat = this.getCategory(defs[varName]);
                            this.icasaDataCatDef[order] = curCat;

                            let category = curCat.category;
                            if (!relations[category]) {
                                relations[category] = [];
                            } else {
                                if (this.icasaDataCatDef[relations[category][0]].parent) {
                                    curCat.parent = this.icasaDataCatDef[relations[category][0]].parent;
                                }
                                if (this.icasaDataCatDef[relations[category][0]].child) {
                                    curCat.child = this.icasaDataCatDef[relations[category][0]].child;
                                }
                            }
                            relations[category].push(order);
                        }
//                        else if (curCat.rank === 1) {
//                            metaCat = curCat;
//                        }
                        if (!parentCat) {
                            parentCat = curCat;
                        } else if (curCat.rank === 4 && curCat.order > 4000) {
                            parentCat = fieldCat;
                        } else if (curCat.rank === 6 && curCat.order < 3000) {
                            // Special handling for soil analysis category, and mark it to be child of soil profile meta (4041, 4042)
                            parentCat = soilProfileCat;
                        } else if (curCat.rank - lastCat.rank === 1) {
                            parentCat = lastCat;
                        }
                        if (curCat.rank - parentCat.rank === 1) {
                            this.buildRelation(relations, curCat, parentCat);
                        } else {
                            if (curCat.rank === 3) {
                                trtCat.child.push(curCat.order);
                                if (!curCat.parent) {
                                    curCat.parent = [trtCat.order];
                                }
                            }
//                            else if (curCat.rank === 0) {
//                                let parArr = [];
//                                curCat.child = relations[metaCat.category];
//                                for (let i in curCat.child) {
//                                    if (!this.icasaDataCatDef[curCat.child[i]].parent) {
//                                        this.icasaDataCatDef[curCat.child[i]].parent = parArr;
//                                    } else {
//                                        parArr = this.icasaDataCatDef[curCat.child[i]].parent;
//                                    }
//                                }
//                                parArr.push(curCat.order);
//                            }
                        }
                        lastCat = curCat;
                    }
                },
                "buildRelation" : function(relations, curCat, parentCat) {
                    if (!parentCat.child) {
                        parentCat.child = [];
                    }
                    if (!curCat.parent) {
                        curCat.parent = [];
                    }
                    for (let i in relations[parentCat.category]) {
                        let parCode = relations[parentCat.category][i];
                        if (!this.icasaDataCatDef[parCode].child) {
                            this.icasaDataCatDef[parCode].child = parentCat.child;
                        }
                        if (!curCat.parent.includes(parCode)) {
                            curCat.parent.push(parCode);
                        }
                    }
                    for (let i in relations[curCat.category]) {
                        let chdCode = relations[curCat.category][i];
                        if (!this.icasaDataCatDef[chdCode].parent) {
                            this.icasaDataCatDef[chdCode].parent = curCat.parent;
                        }
                        if (!parentCat.child.includes(chdCode)) {
                            parentCat.child.push(chdCode);
                        }
                    }
                },
                "getCategory" : function(mapping) {
                    let icasa = mapping.icasa;
                    if (!icasa) {
                        icasa = mapping.column_header;
                    }
                    if (!icasa) {
                        icasa = mapping.code_display;
                    }
                    let order = this.getOrder(icasa);
                    let dataset = this.getDataset(icasa, true);
                    let subset = this.getSubset(icasa, true);
                    let group = this.getGroup(icasa, true);
                    let subgroup = this.getSubGroup(icasa, true);
                    if (order < 0) {
                        return {rank: -1, category: "unknown"};
                    } else if (order > 8000 && order < 9000) {
                        return {rank: 3, category: dataset, order: order};
                    } else if (order < 2000) {
                        return {rank: 3, category: subset, order: order};
                    } else if (order < 3000) {
                        if (order === 2011) {
                            return {rank: 2, category: group, order: order};
                        } else if (order === 2041) {
                            return {rank: 6, category: group, order: order};
                        } else if (order === 2042) {
                            return {rank: 7, category: subgroup, order: order};
                        } else if (order > 2500) {
                            return {rank: 3, category: subset, order: order};
                        } else {
                            if (subgroup) {
                                return {rank: 4, category: subgroup, order: order};
                            } else {
                                return {rank: 3, category: group, order: order};
                            }
                        }
                    } else if (order < 4000) {
                        return {rank: 3, category: subset, order: order};
                    } else if (order < 5000) {
                        if (order === 4051) {
                            return {rank: 6, category: group, order: order};
                        } else if (order === 4052) {
                            return {rank: 7, category: subgroup, order: order};
                        } else if (order > 4040) {
                            return {rank: 5, category: group, order: order};
                        } else {
                            return {rank: 4, category: subset, order: order};
                        }
                    } else if (order < 6000) {
                        if (order === 5052) {
                            return {rank: 6, category: group, order: order};
                        } if (order > 5040) {
                            return {rank: 5, category: subset, order: order};
                        } else {
                            return {rank: 4, category: subset, order: order};
                        }
                    } else if (order < 8000) {
                        return {rank: 3, category: group, order: order};
                    } else if (order < 10000) {
                        return {rank: 3, category: subset, order: order};
                    } else {
                        return {rank: -1, category: "unknown", order: order};
                    }
                }
            };
            
            function getFileName(fileFullName) {
                if (!fileFullName) {
                    return fileFullName;
                }
                let lastDot = fileFullName.lastIndexOf(".");
                if (lastDot < 0) {
                    return fileFullName;
                } else {
                    return fileFullName.substring(0, lastDot);
                }
            }
            
            function readSpreadSheet(target, sc2Files) {
                let files = target.files;
                let colors = [];
                for (let i = 0; i < files.length; i++) {
                    if (i < preferColors.length) {
                        colors.push(preferColors[i]);
                    } else {
                        let color = '#'+(0x1000000+(Math.random())*0xffffff).toString(16).substr(1,6);
                        while (colors.includes(color)) {
                            color = '#'+(0x1000000+(Math.random())*0xffffff).toString(16).substr(1,6);
                        }
                        colors.push(color);
                    }
                }
                let idx = 0;
                userVarMap = {};
                workbooks = {};
                fileTypes = {};
                templates = {};
                fileColors = {};
                virColCnt = {};
                curFileName = null;
                curSheetName = null;
                wbObj = null;
                isChanged = false;
                isViewUpdated = false;
                isDebugViewUpdated = false;
                let reader = new FileReader();
//                reader.onloadend = function(e) {
//                    let data = e.target.result;
//                    console.time();
//                    
//                    workbook = new ExcelJS.Workbook();
//                    workbooks[fileName] = workbook;
//                    workbook.xlsx.load.then(function(workbook) {
//                        console.timeEnd();
//                        if (idx < files.length) {
//                            f = files[idx];
//                            idx++;
//                            loadingDialog.find(".loading-msg").html(' Loading ' + fileName + ' (' + idx + '/' + files.length + ') ...');
//                            reader.readAsArrayBuffer(f);
//                        } else {
//                            loadingDialog.modal('hide');
//                            if (sc2Files.files && sc2Files.files.length > 0) {
//                                readSC2Json(sc2Files);
//                            } else {
//                                showSheetDefDialog(processData);
//                            }
//                        }
//                    });
//                };
                reader.onloadend = function(e) {
                    let data = e.target.result;
//                    data = new Uint8Array(data);
//                    console.time();
                    workbook = XLSX.read(data, {type: 'binary'});
                    workbooks[fileName] = workbook;
//                    workbook = XLSX.read(data, {type: 'array'});
//                    console.timeEnd();
                    
                    if (idx < files.length) {
                        f = files[idx];
                        fileName = f.name;
                        fileTypes[fileName] = f.type;
                        fileColors[fileName] = colors.shift();
                        idx++;
                        loadingDialog.find(".loading-msg").html(' Loading ' + fileName + ' (' + idx + '/' + files.length + ') ...');
                        reader.readAsBinaryString(f);
//                        reader.readAsArrayBuffer(f);
                    } else {
                        loadingDialog.modal('hide');
                        if (sc2Files.files && sc2Files.files.length > 0) {
                            readSC2Json(sc2Files);
                        } else {
                            showSheetDefDialog(processData);
                        }
                    }
                };
                
                // Start to read the first file
                let f = files[idx];
                idx++;
                let fileName = f.name;
                fileTypes[fileName] = f.type;
                fileColors[fileName] = "";
                let loadingDialog = bootbox.dialog({
                    message: '<h4><span class="glyphicon glyphicon-refresh spinning"></span><span class="loading-msg"> Loading ' + fileName + ' (1/' + files.length + ') ...</span></h4></br><p>P.S. <mark>MS Excel File (> 1 MB)</mark> might experice longer loading time...</p>',
//                    centerVertical: true,
                    closeButton: false
                });
                loadingDialog.on("shown.bs.modal", function() {
//                    reader.readAsArrayBuffer(f);
                    reader.readAsBinaryString(f);
                });
            }
            
            function processData(ret) {
                if (ret) {
                    templates = ret;
                }
                if (workbooks) {
                    $("#sheet_csv_content").html(to_csv(workbooks));
//                        $("#sheet_json_content").html(to_json(workbooks));
                }

                if (!curFileName || !curSheetName) {
                    wbObj = {};
                }
                for (let name in workbooks) {
                    if (workbooks[name]) {
                        wbObj[name] = to_object(workbooks[name], name);
                    }
                }
                for (let fileName in templates) {
                    for (let sheetName in templates[fileName]) {
                        let sheetDef = templates[fileName][sheetName];
                        if (sheetDef.references) {
                            for (let fromKeyIdxs in sheetDef.references) {
                                for (let toKey in sheetDef.references[fromKeyIdxs]) {
                                    sheetDef.references[fromKeyIdxs][toKey].keys = getKeyArr(sheetDef.references[fromKeyIdxs][toKey].keys, templates[sheetDef.references[fromKeyIdxs][toKey].file][sheetDef.references[fromKeyIdxs][toKey].sheet].mappings);
                                }
                            }
                        }
                        if (sheetDef.data_start_row) {
                            sheetDef.single_flg = wbObj[fileName][sheetName].data.length === sheetDef.data_start_row;
                        }
                    }
                }

                $('#sheet_tab_list').empty();
                for (let fileName in templates) {
                    $('#sheet_tab_list').append('<li class="dropdown-header"><strong>' + fileName + '</strong></li>');
                    for (let sheetName in templates[fileName]) {
                        let cntUndefined = countUndefinedColumns(templates[fileName][sheetName].mappings);
                        if (cntUndefined > 0) {
                            $('#sheet_tab_list').append('<li><a data-toggle="tab" href="#spreadshet_tab" id="' + fileName + '__' + sheetName + '" onclick="setSpreadsheet(this);">' + sheetName + '&nbsp;&nbsp;<span class="label label-danger label-as-badge">' + cntUndefined + '</span></a></li>');
                        } else {
                            $('#sheet_tab_list').append('<li><a data-toggle="tab" href="#spreadshet_tab" id="' + fileName + '__' + sheetName + '" onclick="setSpreadsheet(this);">' + sheetName + '&nbsp;&nbsp;<span class="label label-danger label-as-badge invisible">' + cntUndefined + '</span></a></li>');
                        }
                    }
                    $('#sheet_tab_list').append('<li class="divider"></li>');
                }

                if (curFileName && curSheetName) {
//                    initSpreadsheet(curFileName, curSheetName);
                    let linkId = curFileName + "__" + curSheetName;
                    $('#sheet_tab_list').find("[id='" + linkId +"']").click();
                } else {
                    $('#sheet_tab_list').find("a").first().click();
                }
            }
            
            function countUndefinedColumns(mappings) {
                let ret = 0;
                for (let i in mappings) {
                    let classNames = getColStatusClass(i, mappings);
                    if (classNames.includes("warning") || classNames.includes("danger")) {
                        ret++;
                    }
                }
                return ret;
            }
            
            function to_json(workbooks) {
                let ret = {};
                for (let name in workbooks) {
                    ret[name] = to_object(workbook, name);
                }
                return JSON.stringify(ret, 2, 2);
            }
            
//            function sheet_to_json(sheet, includeEmpty) {
//                let roa = [];
//                if (!includeEmpty) {
//                    includeEmpty = true;
//                }
//                sheet.eachRow({ includeEmpty: includeEmpty }, function(row, rowNumber) {
//                    let tmp = [];
//                    row.eachCell({ includeEmpty: includeEmpty }, function(cell, colNumber) {
//                       tmp.push(cell.text) ;
//                    });
//                    roa.push(tmp);
//                });
//                return roa;
//            }
            
            function to_object(workbook, fileName) {
                let result = {};
                workbook.SheetNames.forEach(function(sheetName) {
//                workbook.worksheets.forEach(function(sheet) {
//                    let sheetName = sheet.name;
                    if (!templates[fileName] || !templates[fileName][sheetName]) {
                        return;
                    }
                    // Only reload current sheet when editting row definition
                    if ((curFileName && curFileName !== fileName) || 
                            (curSheetName && sheetName !== curSheetName)) {
                        result[sheetName] = wbObj[fileName][sheetName];
                        if (isChanged) {
                            return;
                        }
                    }
                    let roa;
                    let sheetDef = templates[fileName][sheetName];
                    let headers;
                    if (wbObj[fileName] && wbObj[fileName][sheetName]) {
                        result[sheetName] = wbObj[fileName][sheetName];
                        roa = result[sheetName].data;
                        headers = result[sheetName].header;
                    }
                    // Do re-read data when 1, no data loaded; 2, load SC2 file with virtual column but not the case of change row define
                    if (!roa || (virColCnt[fileName][sheetName] && !isChanged)) {
                        roa = XLSX.utils.sheet_to_json(workbook.Sheets[sheetName], {header:1, raw: false});
                        for (let i = roa.length; i >= 0; i--) {
                            if (roa[i] && roa[i].length > 0) {
                                roa.splice(i + 1, roa.length - i);
                                break;
                            }
                        }
//                        let roa = sheet_to_json(sheet);
                        
                        // store sheet data
                        if (sheetDef.header_row) {
                            headers = roa[sheetDef.header_row - 1];
                        } else {
                            headers = [];
                        }
                        result[sheetName] = {};
                        result[sheetName].header = headers;
                        result[sheetName].data = roa;
                    }
                    
                    if (roa.length && roa.length > 0) {
                        // init template structure
                        if (!sheetDef.mappings || isChanged) {
                            if (!sheetDef.mappings) {
                                sheetDef.mappings = [];
                            }
                            if (!sheetDef.references) {
                                sheetDef.references = {};
                            }
                            for (let i = 0; i < headers.length; i++) {
                                let headerDef = sheetDef.mappings[i];
                                if (!headerDef) {
                                    headerDef = {
                                        column_header : "",
                                        column_index : i + 1,
                                        column_index_org : i + 1
                                    };
                                    sheetDef.mappings.push(headerDef);
                                }
                                if (!headerDef.column_index_org) {
                                    updateRawData(roa, sheetDef, headerDef);
                                    continue;
                                }
                                if (headers[i]) {
                                    headerDef.column_header = headers[i].trim();
                                }
                                if (!headerDef.unit && sheetDef.unit_row) {
                                    headerDef.unit = roa[sheetDef.unit_row - 1][i];
                                }
                                if (!headerDef.description && sheetDef.desc_row) {
                                    headerDef.description = roa[sheetDef.desc_row - 1][i];
                                }
                                if (!headerDef.icasa) {
                                    let headerName = String(headerDef.column_header).toUpperCase();
                                    if (icasaVarMap.getDefinition(headerName)) {
                                        headerDef.icasa = headerName;
                                    } else if (icasaVarMap.getDefinition(headerDef.column_header)) {
                                        headerDef.icasa = headerDef.column_header;
                                    }
                                }
                                let icasa_unit = icasaVarMap.getUnit(headerDef.icasa);
                                if (!headerDef.unit) {
                                    headerDef.unit_error = true;
                                } else if (icasa_unit && headerDef.unit !== icasa_unit) {
                                    $.get("/data/unit/convert?value_from=2&unit_to=" + encodeURIComponent(icasa_unit) + "&unit_from="+ encodeURIComponent(headerDef.unit),
                                        function (jsonStr) {
                                            let ret = JSON.parse(jsonStr);
                                            if (ret.status !== "0") {
//                                                headerDef.unit = icasa_unit; // TODO this should change to give warning message
                                                headerDef.unit_error = true;
                                            }
                                        }
                                    );
                                } else if (!icasa_unit) {
                                    $.get("/data/unit/lookup?unit=" + encodeURIComponent(headerDef.unit),
                                        function (jsonStr) {
                                            var unitInfo = JSON.parse(jsonStr);
                                            if (unitInfo.message === "undefined unit expression" && headerDef.unit !== "text" && headerDef.unit !== "code" && headerDef.unit !== "date") {
                                                headerDef.unit_error = true;
                                            }
                                        }
                                    );
                                }
                            }
                            for (let i in roa) {
                                while (sheetDef.mappings.length < roa[i].length) {
                                    sheetDef.mappings.push({column_index : sheetDef.mappings.length, column_index_org : sheetDef.mappings.length});
                                }
                            }
                        } else {
                            for (let i in sheetDef.mappings) {
                                let mapping = sheetDef.mappings[i];
                                if (!mapping.column_index_org) {
                                    shiftRefFromKeyIdx(sheetDef, i);
                                    shiftRawData(roa, i);
                                    updateRawData(roa, sheetDef, mapping);
                                }
                            }
                            // check if header is matched with given spreadsheet
                            let tmpMappings = [];
                            for (let i in sheetDef.mappings) {
                                if (sheetDef.mappings[i].column_header !== headers[i]) {
                                    tmpMappings[i] = sheetDef.mappings[i];
                                    delete sheetDef.mappings[i];
                                }
                            }
                            // check if there is header matched columns
                            for (let i in tmpMappings) {
                                for (let j = 0; j < headers.length; j++) {
                                    if (tmpMappings[i].column_header === headers[j]) {
                                        sheetDef.mappings[j] = tmpMappings[i];
                                        delete tmpMappings[i];
                                        break;
                                    }
                                }
                            }
                            // check if there is undefined columns with matched index
                            for (let i in tmpMappings) {
                                if (!sheetDef.mappings[i]) {
                                    sheetDef.mappings[i] = tmpMappings[i];
                                    delete tmpMappings[i];
                                }
                            }
                            // fill missing column definition with ignored flag
                            let vrColCnt = 0;
                            for (let i = 0; i < headers.length; i++) {
                                let headerDef = sheetDef.mappings[i];
                                if(!headerDef) {
                                    headerDef = {
                                        column_header : "",
                                        column_index : i + 1,
                                        column_index_org : i + 1 - vrColCnt,
                                        ignored_flg : true
                                    }
                                    if (headers[i]) {
                                        headerDef.column_header = headers[i].trim();
                                    }
                                    // Load existing template definition
                                    if (sheetDef.unit_row) {
                                        headerDef.unit = roa[sheetDef.unit_row - 1][i];
                                    }
                                    if (sheetDef.desc_row) {
                                        headerDef.description = roa[sheetDef.desc_row - 1][i];
                                    }
                                    let headerName = String(headerDef.column_header).toUpperCase();
                                    if (icasaVarMap.getDefinition(headerName)) {
                                        headerDef.icasa = headerName;
                                    } else if (icasaVarMap.getDefinition(headerDef.column_header)) {
                                        headerDef.icasa = headerDef.column_header;
                                    }
                                    sheetDef.mappings[i] = headerDef;
                                } else {
                                    if (!headerDef.column_index_org) {
                                        vrColCnt++;
                                    }
                                    if (sheetDef.mappings[i].column_header !== headers[i]) {
                                        sheetDef.mappings[i].column_header = headers[i].trim();
                                        // TODO deal with sc2 mappings is not fully matched with given spreadsheet columns
                                    }
                                }
                                if (headerDef.icasa) {
                                    let icasa_unit = icasaVarMap.getUnit(headerDef.icasa);
                                    if (!headerDef.unit) {
                                        headerDef.unit_error = true;
                                    } else if (icasa_unit && headerDef.unit !== icasa_unit) {
                                        $.get("/data/unit/convert?value_from=1&unit_to=" + encodeURIComponent(icasa_unit) + "&unit_from="+ encodeURIComponent(headerDef.unit),
                                            function (jsonStr) {
                                                let ret = JSON.parse(jsonStr);
                                                if (ret.status !== "0") {
//                                                    headerDef.unit = icasa_unit; // TODO this should change to give warning message
                                                    headerDef.unit_error = true;
                                                } else {
                                                    delete headerDef.unit_error;
                                                }
                                            }
                                        );
                                    } else if (!icasa_unit) {
                                        $.get("/data/unit/lookup?unit=" + encodeURIComponent(headerDef.unit),
                                            function (jsonStr) {
                                                var unitInfo = JSON.parse(jsonStr);
                                                if (unitInfo.message === "undefined unit expression" && headerDef.unit !== "text" && headerDef.unit !== "code" && headerDef.unit !== "date") {
                                                    headerDef.unit_error = true;
                                                } else {
                                                    delete headerDef.unit_error;
                                                }
                                            }
                                        );
                                    } else {
                                         delete headerDef.unit_error;
                                    }
                                }
                            }
                        }
                    }
                });
                workbook.SheetNames.forEach(function(sheetName) {
                    shiftRefToKeyIdx(templates[fileName][sheetName]);
                });
                return result;
            }
            
            function to_csv(workbooks) {
                let result = [];
                for (let name in workbooks) {
                    result.push("File: " + name);
                    result.push("");
                    let workbook = workbooks[name];
                    workbook.SheetNames.forEach(function(sheetName) {
                        var csv = XLSX.utils.sheet_to_csv(workbook.Sheets[sheetName], {raw: false});
                        if(csv.length){
                            result.push("SHEET: " + sheetName);
                            result.push("");
                            result.push(csv);
                        }
                    });
                }
                return result.join("\n");
            }
            
            function setSpreadsheet(target) {
//                $("#sheet_name_selected").text(" <" + target.id + ">");
                let tmp = target.id.split("__");
                curFileName = tmp[0];
                curSheetName = tmp[1];
                $("#sheet_name_selected").text(" <" + curSheetName + ">");
            }

            function getColumnDef(mapping) {
                if (mapping.unit === "date") {
                    return {type: 'date', readOnly: true};
                } else if (mapping.unit === "text" || mapping.unit === "code") {
                    return {type: 'text', readOnly: true};
                } else if (mapping.unit !== ""){
                    return {type: 'numeric', readOnly: true};
                } else {
                    return {type: 'text', readOnly: true};
                }
            }
            
            function initSpreadsheet(fileName, sheetName, spsContainer) {
                if (!spsContainer) {
                    spsContainer = document.querySelector('#sheet_spreadsheet_content');
                }
//                let minRows = 10;
                let data = wbObj[fileName][sheetName].data;
                let sheetDef = templates[fileName][sheetName];
//               let mappings = getMappings(fileName, sheetName);
                let mappings = sheetDef.mappings;
                let columns = [];
//                if (data.length < minRows) {
//                    data = JSON.parse(JSON.stringify(data)); // TODO set raw data as read only for a temprory solution
//                }
                for (let i in mappings) {
                    columns.push(getColumnDef(mappings[i]));
                }
                for (let i in data) {
                    while (columns.length < data[i].length) {
                        columns.push({type: 'text', readOnly: true});
                    }
                }

                let spsOptions = {
                    licenseKey: 'non-commercial-and-evaluation',
                    data: data,
                    columns: columns,
                    stretchH: 'all',
                    width: '100%',
                    autoWrapRow: true,
                    height: $(window).height() - $("body").height() + $("#sheet_spreadsheet_content").height(),
//                    minRows: minRows,
                    maxRows: 365 * 30,
                    manualRowResize: true,
                    manualColumnResize: true,
                    rowHeaders: function (row) {
                        let txt;
                        let idx = row + 1;
                        if (!$('#tableViewSwitch').prop("checked")) {
                            txt = sheetDef.data_start_row + row;
                        } else if (row === sheetDef.header_row - 1) {
                            txt = "<span data-toggle='tooltip' title='Header (Varible Code Name)'><Strong>Var</Strong> " + idx + "</span>";
                        } else if (row === sheetDef.unit_row - 1) {
                            txt = "<span data-toggle='tooltip' title='Unit Expression'><Strong>Unit</Strong> " + idx + "</span>";
                        } else if (row === sheetDef.desc_row - 1) {
                            txt = "<span data-toggle='tooltip' title='Description/Definition'><Strong>Desc</Strong> " + idx + "</span>";
                        } else if (!sheetDef.data_start_row) {
                            txt = idx;
                        } else if (row < sheetDef.data_start_row - 1) {
                            txt = "<span data-toggle='tooltip' title='Comment/Ignored raw'><em>C</em> " + idx + "</span>";;
                        } else {
//                            txt = row - sheetDef.data_start_row + 2;
                            txt = idx;
                        }
                        return txt;
                    },
                    colHeaders: function (col) {
                        let checkBox = '<input type="checkbox" name="' + fileName + "_" + sheetName + '_' + col + '"';
                        if (mappings[col] && mappings[col].ignored_flg) {
                            checkBox += 'onchange=toggleIgnoreColumn(' + col + ');> ';
                        } else {
                            checkBox += 'checked onchange=toggleIgnoreColumn(' + col + ');> ';
                        }
                        let title = getColHeaderComp(mappings, col, fileName + "_" + sheetName + '_' + col + "_label").prop('outerHTML');
                        return "<h4>" + checkBox + title + "</h4>";
                    },
//                    headerTooltips: true,
//                    afterChange: function(changes, src) {
//                        if(changes){
//                            
//                        }
//                    },
                    manualRowMove: false,
                    manualColumnMove: false,
                    filters: true,
                    dropdownMenu: true,
                    contextMenu: {
                        items: {
                            "define_column":{
                                name: '<span class="glyphicon glyphicon-edit"></span> Define Column',
                                disabled: function () {
                                    // disable the option when the multiple columns were selected
                                    let range = this.getSelectedLast();
                                    let selection = this.getSelected();
                                    return range[1] !== range[3] || selection.length !== 1;
                                },
                                callback: function(key, selection, clickEvent) {
                                    setTimeout(function() {
                                        let itemData = {};
                                        let colIdx = selection[0].start.col;
//                                        data.column_header = spreadsheet.getColHeader(data.colIdx);
                                        let colDef = mappings[colIdx];
                                        Object.assign(itemData, colDef);
                                        showColDefineDialog(itemData);
                                    }, 0); // Fire alert after menu close (with timeout)
                                }
                            },
                            "ignore_column":{
                                name: '<span class="glyphicon glyphicon-ban-circle"></span> Ignore Column',
                                hidden: function () { // `hidden` can be a boolean or a function
                                    // Hide the option when it is ignored
                                    let selection = this.getSelected();
                                    for (let i in selection) {
                                        let start = Math.min(selection[i][1], selection[i][3]);
                                        let end = Math.max(selection[i][1], selection[i][3]);
                                        for (let j = start; j <= end; j++) {
                                            if ($("[name='" + fileName + "_" + sheetName + "_" + j + "']").last().prop("checked")) {
                                                return false;
                                            }
                                        }
                                    }
                                    return true;
                                },
                                callback: function(key, selection, clickEvent) {
                                    setTimeout(function() {
                                        for (let i in selection) {
                                            for (let j = selection[i].start.col; j <= selection[i].end.col; j++) {
                                                let cb = $("[name='" + fileName + "_" + sheetName + "_" + j + "']").last();
                                                cb.prop("checked", false).trigger("change");
                                            }
                                        }
                                    }, 0); // Fire alert after menu close (with timeout)
                                }
                            },
                            "include_column":{
                                name: '<span class="glyphicon glyphicon-ok-circle"></span> Include Column',
                                hidden: function () { // `hidden` can be a boolean or a function
                                    // Hide the option when it is ignored
                                    let selection = this.getSelected();
                                    for (let i in selection) {
                                        let start = Math.min(selection[i][1], selection[i][3]);
                                        let end = Math.max(selection[i][1], selection[i][3]);
                                        for (let j = start; j <= end; j++) {
                                            if (!$("[name='" + fileName + "_" + sheetName + "_" + j + "']").last().prop("checked")) {
                                                return false;
                                            }
                                        }
                                    }
                                    return true;
                                },
                                callback: function(key, selection, clickEvent) {
                                    setTimeout(function() {
                                        for (let i in selection) {
                                            for (let j = selection[i].start.col; j <= selection[i].end.col; j++) {
                                                let cb = $("[name='" + fileName + "_" + sheetName + "_" + j + "']").last();
                                                cb.prop("checked", true).trigger("change");
                                            }
                                        }
                                    }, 0); // Fire alert after menu close (with timeout)
                                }
                            },
                            "new_column":{
                                name: '<span class="glyphicon glyphicon-plus-sign"></span> Add Column',
//                                hidden: function () { // `hidden` can be a boolean or a function
//                                    // Hide the option when the first column was clicked
////                                    return this.getSelectedLast()[1] == 0; // `this` === hot3
//                                    return true;
//                                },
                                callback: function(key, selection, clickEvent) {
                                    setTimeout(function() {
                                        let itemData = {
                                            column_index_prev : selection[0].start.col
                                        };
                                        showColDefineDialog(itemData);
                                    }, 0); // Fire alert after menu close (with timeout)
                                }
                            },
                            "edit_row":{
                                name: '<span class="glyphicon glyphicon-edit"></span> Edit Row Definition',
                                callback: function(key, selection, clickEvent) {
                                    setTimeout(function() {
                                        showSheetDefDialog(processData, null, true);
                                    }, 0); // Fire alert after menu close (with timeout)
                                }
                            },
                            "apply_same_unit" : {
                                name : '<span class="glyphicon glyphicon-check"></span> Apply ICASA Unit',
                                hidden: function () { // `hidden` can be a boolean or a function
                                    // Hide the option when it is ignored
                                    let selection = this.getSelected();
                                    for (let i in selection) {
                                        let start = Math.min(selection[i][1], selection[i][3]);
                                        let end = Math.max(selection[i][1], selection[i][3]);
                                        for (let j = start; j <= end; j++) {
                                            if (mappings[j].unit_error) {
                                                return false;
                                            }
                                        }
                                    }
                                    return true;
                                },
                                callback : function(key, selection, clickEvent) {
                                    setTimeout(function() {
//                                        let mappings = templates[fileName][sheetName].mappings;
                                        for (let i in selection) {
                                            for (let j = selection[i].start.col; j <= selection[i].end.col; j++) {
                                                if (mappings[j].unit_error) {
                                                    let icasaUnit = icasaVarMap.getUnit(mappings[j].icasa);
                                                    if (icasaUnit) {
                                                        mappings[j].unit = icasaUnit;
                                                        delete mappings[j].unit_error;
                                                        let newHeader = getColHeaderComp(mappings, j);
                                                        let header = $("[name='" + fileName + "_" + sheetName + "_" + j + "_label']").last();
                                                        header.attr("class", newHeader.attr("class"));
                                                        header.html(newHeader.html());
                                                        isChanged = true;
                                                        isViewUpdated = false;
                                                        isDebugViewUpdated = false;
                                                    }
                                                }
                                            }
                                        }
                                    }, 0); // Fire alert after menu close (with timeout)
                                }
                            }
//                            "sep2": '---------',
//                            "row_above": {},
//                            "row_below": {},
//                            "remove_row": {},
//                            "sep1": '---------',
//                            "undo": {},
//                            "redo": {},
//                            "cut": {},
//                            "copy": {},
//                            "clear":{
//                                name : "clear",
//                                callback: function(key, selection, clickEvent) { // Callback for specific option
//                                    setTimeout(function() {
//                                        alertBox('Hello world!'); // Fire alert after menu close (with timeout)
//                                    }, 0);
//                                }}
                        }
                    }
                };
                if (!$('#tableViewSwitch').prop("checked")) {
                    spsOptions.data = spsOptions.data.slice(sheetDef.data_start_row - 1);
//                    spsOptions.rowHeaders = true;
                }
                if (spreadsheet) {
                    spreadsheet.destroy();
                }
                spreadsheet = new Handsontable(spsContainer, spsOptions);
                if ($('#tableViewSwitch').prop("checked")) {
                    spreadsheet.updateSettings({
                        cells: function(row, col, prop) {
                            var cell = spreadsheet.getCell(row,col);
                            if (!cell) {
                                return;
                            }
                            if (row === sheetDef.header_row - 1) {
    //                            cell.style.color = "white";
    //                            cell.style.fontWeight = "bold";
                                cell.style.fontStyle = "italic";
                                cell.style.backgroundColor = "lightgrey";
                                return {readOnly : true};
                            } else if (row === sheetDef.unit_row - 1) {
    //                            cell.style.color = "white";
    //                            cell.style.textDecoration = "underline";
                                cell.style.fontStyle = "italic";
                                cell.style.backgroundColor = "lightgrey";
                                return {readOnly : true};
                            } else if (row === sheetDef.desc_row - 1) {
    //                            cell.style.color = "white";
                                cell.style.fontStyle = "italic";
                                cell.style.backgroundColor = "lightgrey";
                                return {readOnly : true};
                            } else if (row < sheetDef.data_start_row - 1) {
    //                            cell.style.color = "white";
                                cell.style.backgroundColor = "lightgrey";
                                return {readOnly : true};
                            }
                        },
                    });
                }
                $('.table_switch_cb').bootstrapToggle('enable');
                if (!sheetDef.data_start_row) {
                    $('#tableViewSwitch').bootstrapToggle('disable');
                }
            }

            function getColHeaderComp(mappings, col,  name) {
                let mapping = mappings[col];
                let title = $("<span></span>");
                if (!name) {
                    name = curFileName + "_" + curSheetName + "_" + col + "_label";
                }
                title.attr("name", name);

                let refMark = "";
                if (mapping && mapping.reference_flg) {
                    refMark = "<span class='glyphicon glyphicon-flag'></span> ";
                }
//                let colIdx = " <span class='badge'>" + (col + 1) + "</span>";
                let colIdx = col + 1;
                
                let text;
                let classes = getColStatusClass(col, mappings);
                let tooltip;
                if (mapping && mapping.ignored_flg) {
                    text = refMark + "[" + colIdx + "] " + mapping.column_header;
                } else if (!mapping || (!mapping.column_header && !mapping.icasa)) {
                    text = refMark + colIdx;
//                } else if (!mapping.icasa) {
//                    text = refMark + mapping.column_header + "[" + colIdx + "]";
                } else if (mapping.icasa) {
                    let varDef = icasaVarMap.getDefinition(mapping.icasa);
                    text = refMark + "[" + colIdx + "] ";
                    if (mapping.column_header && mapping.icasa.toLowerCase() !== mapping.column_header.toLowerCase()) {
                       text += "<em>" +  mapping.column_header + "->" + mapping.icasa + "</em> ";
                    } else if (mapping.column_header) {
                        text += mapping.column_header;
                    } else {
                        text += "<em>" +  mapping.icasa + "</em> ";
                    }
                    if (varDef) {
                        tooltip = "<" + mapping.icasa + "> " + varDef.description + " [" + varDef.unit_or_type + "]";
                        if (!mapping.unit) {
                            text += "<br/><em>[?->" + varDef.unit_or_type + "]</em>"
                        } else if (mapping.unit.toLowerCase() !== varDef.unit_or_type.toLowerCase()) {
                            text += "<br/><em>[" + mapping.unit + "->" + varDef.unit_or_type + "]</em>"
                        } else {
//                            text += " [" + varDef.unit_or_type + "]'>";
                        }

                    } else {
                        tooltip ="<" + mapping.icasa + "> " + mapping.description + " [" + mapping.unit + "]";
                    }
                } else if (mapping.reference_flg) {
                    text = refMark + "[" + colIdx + "] " + mapping.column_header;
                } else {
                    text = refMark + "[" + colIdx + "] " + mapping.column_header;
                }
                title.prop("class", classes);
                if (tooltip) {
                    title.attr("data-toggle", "tooltip");
                    title.prop("title", tooltip);
                }
                title.html(text);
                return title;
            }

            function toggleIgnoreColumn(colIdx) {
                let key = curFileName + "_" + curSheetName + "_" + colIdx;
                let headerCB = $("[name='" + key + "']").last();
                let header = $("[name='" + key + "_label']").last();
                let mapping = templates[curFileName][curSheetName].mappings[colIdx];
                if (headerCB.prop("checked")) {
                    delete mapping.ignored_flg;
//                    header.html("class", getColStatusClass(colIdx));
                } else {
                    mapping.ignored_flg = true;
//                    header.attr("class", "label label-default");
                }
                let newHeader = getColHeaderComp(templates[curFileName][curSheetName].mappings, colIdx);
                header.attr("class", newHeader.attr("class"));
                header.html(newHeader.html());
                isChanged = true;
                isViewUpdated = false;
                isDebugViewUpdated = false;
            }
            
            function getColStatusClass(col, mappings) {
                if (!mappings) {
                    mappings = templates[curFileName][curSheetName].mappings;
                }
                if (mappings[col]) {
                     if (mappings[col].ignored_flg) {
                        return "label label-default";
                    } else if (mappings[col].unit_error) {
                        return "label label-danger";
                    } else if (!mappings[col].column_index_org) {
                        return "label label-primary";
                    } else if (mappings[col].icasa) {
                        if (icasaVarMap.getDefinition(mappings[col].icasa)) {
                            return "label label-success";
                        } else {
                            return "label label-info";
                        }
                    } if (mappings[col].reference_flg) {
                        return "label label-info";
                    }
                }
                return "label label-warning";
            }
            
            function convertUnit() {
                // TODO
            }
            
            function openExpDataFile() {
                showLoadFileDialog();
            }
            
            function openExpDataFolderFile() {
                alertBox("Functionality under construction...");
            }
            
            function saveExpDataFile() {
                alertBox("Functionality under construction...");
            }
            
            function saveAcebFile() {
                alertBox("Functionality under construction...");
            }
            
            function openTemplateFile() {
                if (Object.keys(workbooks).length === 0) {
                    alertBox("Please load spreadsheet file first, then apply SC2 file for it.");
                } else {
                    $('<input type="file" accept=".sc2.json,.json,.sc2" onchange="readSC2Json(this);">').click();
                }
            }

            function readSC2Json(target) {
                // reset part of the flags for the case of only loading template
                isChanged = false;
                isViewUpdated = false;
                isDebugViewUpdated = false;

                var files = target.files;
                if (files.length !== 1) {
                    alertBox('Please select one file!');
                    return;
                }
                var file = files[0];
                var start = 0;
                var stop = file.size - 1;
                var reader = new FileReader();
                reader.onloadend = function (evt) {
                    if (evt.target.readyState === FileReader.DONE) { // DONE == 2
                        var jsonStr = evt.target.result;
//                        readSoilData(jsonStr);
                        
                        var sc2Obj = JSON.parse(jsonStr);
                        $(".mapping_gengeral_info").val("");
                        if (sc2Obj.mapping_info) {
                            for (let key in sc2Obj.mapping_info) {
                                $("[name='" + key + "']").val(sc2Obj.mapping_info[key]);
                            }
                        }
                        if (sc2Obj.agmip_translation_mappings) {
                            let files = sc2Obj.agmip_translation_mappings.files;
                            let relations = sc2Obj.agmip_translation_mappings.relations;
                            if (!files || files.length === 0) {
                                alertBox("No AgMIP mapping information detected, please try another file!");
                                return;
                            }
                            if (!relations) {
                                relations = [];
                            }
                            // Locate the correct file for reading mappings
                            let fileConfigs = [];
                            if (curFileName) {
                                // If spreadsheet is already loaded, then only pick up the config for the loaded file
                                for (let fileName in wbObj) {
                                    for (let i in files) {
                                        let fileConfig = files[i];
                                        if (fileConfig.file && fileConfig.file.file_metadata
                                                && (fileName === fileConfig.file.file_metadata.file_name
                                                    || getFileName(fileName) === getFileName(fileConfig.file.file_metadata.file_name)
                                                )) {
                                            fileConfigs.push(fileConfig);
                                        }
                                    }
                                }
                                // If not found matched config
                                if (fileConfigs.length === 0) {
                                    // TODO then use default first records to apply
                                    if (files.length === Object.keys(wbObj).length) {
                                        fileConfigs = files;
                                    } else {
                                        // TODO give warning?
                                    }
                                    
                                }
                            } else {
                                // Load all the configs
                                fileConfigs = files;
                            }
                            
                            let refConfigs = {};
                            for (let i in relations) {
                                let fromSheet = relations[i].from.sheet;
                                if (!refConfigs[fromSheet]) {
                                    refConfigs[fromSheet] = [];
                                }
                               refConfigs[fromSheet].push(relations[i]);
                            }
                            
                            for (let i in fileConfigs) {
                                let fileConfig = fileConfigs[i];
                                if (!fileConfig.file.sheets) {
                                    fileConfig.file.sheets = [];
                                }
                                // Load mapping for each sheet and fill missing column with ignore flag
                                let fileName = fileConfig.file.file_metadata.file_name;
                                if (!fileTypes[fileName]) {
                                    let contentType = fileConfig.file.file_metadata["content-type"];
                                    for (let name in fileTypes) {
                                        if (name.startsWith(fileName) && (!contentType || fileTypes[name] === contentType)) {
                                            fileName = name;
                                        }
                                    }
                                }
                                templates[fileName] = {};
                                for (let i in fileConfig.file.sheets) {
                                    let sheetName = fileConfig.file.sheets[i].sheet_name;
                                    let refConfig;
                                    if (!sheetName) {
                                        sheetName = "" + i;
                                        refConfig = fileConfig.relations[i];
                                    } else {
                                        refConfig = refConfigs[sheetName];
                                    }
                                    // If load SC2 separatedly and have excluding sheets, then skip the mapping for those sheets
                                    if (curFileName && !wbObj[fileName][sheetName]) {
                                        continue;
                                    }
                                    templates[fileName][sheetName] = Object.assign({}, fileConfig.file.sheets[i]);
//                                    if (!templates[fileName][sheetName].header_row) {
//                                        templates[fileName][sheetName].header_row = 1;
//                                    }
//                                    if (!templates[fileName][sheetName].data_start_row) {
//                                        templates[fileName][sheetName].data_start_row = templates[fileName][sheetName].header_row + 1;
//                                    }
                                    let sc2Mappings = fileConfig.file.sheets[i].mappings;
                                    templates[fileName][sheetName].mappings = [];
                                    templates[fileName][sheetName].references = {};
                                    if (!virColCnt[fileName]) {
                                        virColCnt[fileName] = {};
                                    }
                                    let mappings = templates[fileName][sheetName].mappings;
                                    sc2Mappings.sort(function (m1, m2) {
                                        let idx1 = m1.column_index;
                                        if (!idx1) {
                                            idx1 = m1.column_index_vr;
                                        }
                                        if (!idx1) {
                                            idx1 = -1;
                                        }
                                        let idx2 = m1.column_index;
                                        if (!idx2) {
                                            idx2 = m1.column_index_vr;
                                        }
                                        if (!idx2) {
                                            idx2 = -1;
                                        }
                                        return idx1 - idx2;
                                    });
                                    let vrColCnt = 0;
                                    for (let j in sc2Mappings) {
                                        j = Number(j);
                                        if (sc2Mappings[j].column_index_vr) {
                                            vrColCnt++;
                                            sc2Mappings[j].column_index = sc2Mappings[j].column_index_vr;
                                            delete sc2Mappings[j].column_index_vr;
                                        } else if (sc2Mappings[j].column_index) {
                                            sc2Mappings[j].column_index_org = sc2Mappings[j].column_index;
                                            sc2Mappings[j].column_index = sc2Mappings[j].column_index + vrColCnt;
                                        } else {
                                            vrColCnt++;
                                            if (j === 0) {
                                                sc2Mappings[j].column_index = 1;
                                            } else {
                                                sc2Mappings[j].column_index = sc2Mappings[j - 1].column_index + 1;
                                            }
                                        }
                                        
                                        let colIdx = Number(sc2Mappings[j].column_index);
                                        for (let k = mappings.length; k < colIdx - 1; k++) {
                                            if (!mappings[k]) {
                                                mappings.push({
                                                    column_index : k + 1,
                                                    column_index_org : k + 1,
                                                    ignored_flg : true
                                                });
                                            }
                                        }
                                        mappings[colIdx - 1] = sc2Mappings[j];
                                        
//                                        mappings[sc2Mappings[j].column_index - 1] = sc2Mappings[j];
                                        if (sc2Mappings[j].formula_info) {
                                            for (let key in sc2Mappings[j].formula_info) {
                                                sc2Mappings[j][key] = sc2Mappings[j].formula_info[key];
                                            }
                                            delete sc2Mappings[j].formula_info;
                                        }
                                    }
                                    if (vrColCnt > 0) {
                                        virColCnt[fileName][sheetName] = vrColCnt;
                                    }
                                    let references = templates[fileName][sheetName].references;
                                    for (let j in refConfig) {
                                        let refDef = refConfig[j];
                                        let fromKeyIdxs = getKeyIdxArr(refDef.from.keys);
                                        let toKeyIdxs = getKeyIdxArr(refDef.to.keys);
                                        let toKey = getRefDefKey(refDef.to, toKeyIdxs);
                                        if (!references[fromKeyIdxs]) {
                                            references[fromKeyIdxs] = {};
                                        }
                                        references[fromKeyIdxs][toKey] = {
                                            file: refDef.to.file,
                                            sheet: refDef.to.sheet,
                                            keys: toKeyIdxs //getKeyArr(toKeyIdxs, mappings)
                                        };
                                    }
                                }
                                
                            }
                        } else {
                            alertBox("No AgMIP mapping information detected, please try another file!");
                            return;
                        }
                        processData();
                    }
                };

                var blob = file.slice(start, stop + 1);
                reader.readAsText(blob);
            }
            
            function saveTemplateFile() {
                if (!curFileName) {
                    alertBox("Please load spreadsheet file first, then edit and save SC2 file for it.");
                } else {
                    let text = toSC2Json();
                    let ext = "-sc2.json";
                    let blob = new Blob([text], {type: "text/plain;charset=utf-8"});
                    saveAs(blob, getFileName(curFileName) + ext);
                    isChanged = false;
                }
            }
            
            function toSC2Json(compressFlg) {
                if (compressFlg) {
                    return JSON.stringify(toSC2Obj());
                } else {
                    return JSON.stringify(toSC2Obj(), 2, 2);
                }
            }
            
            function toSC2Obj() {
                let sc2Obj = {
                    mapping_info : {
//                        mapping_author : "data factory (http://dssat2d-plot.herokuapp.com/demo/data_factory)",
//                        source_url: ""
                    },
                    dataset_metadata : {},
                    agmip_translation_mappings : {
                        primary_ex_sheet : {
                            file : null,
                            sheet : null,
                        },
                        relations : [],
                        files : []
                    },
                    xrefs : [
//                        {
//                          xref_provider : "gardian",
//                          xref_url : "https://gardian.bigdata.cgiar.org/dataset.php?id=5cd88b72317da7f1ae0cf390#!/"
//                        }
                    ]
                };
                let agmipTranslationMappingTemplate = JSON.stringify({
                    //Grab the primary keys from here if EXNAME is not defined
                    file : {
                        file_metadata : {
                            file_name : "",
                            "content-type" : ""
                            // file_url : ""
                        },
                        sheets : []
                    }
                });
                
                $(".mapping_gengeral_info").each(function () {
                   sc2Obj.mapping_info[$(this).attr("name") ] = $(this).val();
                });

                for (let fileName in templates) {
                    let tmp2 = JSON.parse(agmipTranslationMappingTemplate);
                    tmp2.file.file_metadata.file_name = fileName;
                    tmp2.file.file_metadata["content-type"] = fileTypes[fileName];
//                    if (fileName.toLowerCase().endsWith(".csv")) {
//                        tmp2.file.file_metadata["content-type"] = "text/csv";
//                    } else if (fileName.toLowerCase().endsWith(".xlsx")) {
//                        tmp2.file.file_metadata["content-type"] = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
//                    } else if (fileName.toLowerCase().endsWith(".xls")) {
//                        tmp2.file.file_metadata["content-type"] = "application/vnd.ms-excel";
//                    } else {
//                        // TODO add default content-type key word here
//                    }
                    
                    sc2Obj.agmip_translation_mappings.files.push(tmp2);
                    for (let sheetName in templates[fileName]) {
                        let tmp = Object.assign({}, templates[fileName][sheetName]);
                        tmp.mappings = [];
                        delete tmp.references;
                        for (let i in templates[fileName][sheetName].mappings) {
                            let mapping = templates[fileName][sheetName].mappings[i];
                            if (!mapping.ignored_flg) {
                                let mappingCopy = Object.assign({}, mapping);
                                if (!mappingCopy.column_index_org) {
                                    mappingCopy.column_index_vr = mappingCopy.column_index;
                                    delete mappingCopy.column_index;
                                    mappingCopy.formula_info = {};
                                    for (let key in mappingCopy) {
                                        if (key.startsWith("virtual")) {
                                            mappingCopy.formula_info[key] = mappingCopy[key];
                                            delete mappingCopy[key];
                                        }
                                    }
                                } else {
                                    mappingCopy.column_index = mappingCopy.column_index_org;
                                    delete mappingCopy.column_index_org;
                                }
                                tmp.mappings.push(mappingCopy);
                                if (mapping.reference_flg) {
                                    delete mappingCopy.reference_type;
                                    delete mappingCopy.reference_flg;
                                }
                                if (mapping.format_customized) {
                                    mappingCopy.format = mapping.format_customized;
                                    delete mappingCopy.format_customized;
                                }
                            }
                        }
                        if (templates[fileName][sheetName].references) {
                            for (let fromKeyIdxs in templates[fileName][sheetName].references) {
                                let refDefs = templates[fileName][sheetName].references[fromKeyIdxs];
                                for (let toRefDefStr in refDefs) {
                                    let toRefDef = refDefs[toRefDefStr];
                                    let refDef = createRefDefObj({file: fileName, sheet: sheetName},
                                        JSON.parse("[" + fromKeyIdxs + "]"),
                                        toRefDef,
                                        getKeyIdxArr(toRefDef.keys), true);
                                    sc2Obj.agmip_translation_mappings.relations.push(refDef);
                                }
                            }
                        }
                        tmp2.file.sheets.push(tmp);
                    }
                }
                return sc2Obj;
            }

            function alertBox(msg, callback) {
                if (callback) {
                    bootbox.alert({
                        message: msg,
                        backdrop: true,
                        callback: callback
                    });
                } else {
                    bootbox.alert({
                        message: msg,
                        backdrop: true
                    });
                }
            }
            
            function confirmBox(msg, callback) {
                bootbox.confirm({
                    message: msg,
                    callback: function (result) {
                        if (result) {
                            callback();
                        }
                    }
                });
            }
            
            String.prototype.capitalize = function() {
                return this.charAt(0).toUpperCase() + this.slice(1).toLowerCase();
            }
        </script>
    </head>

    <body>

        <#include "../nav.ftl">

        <div class="container"></div>
        <div class="container-fluid">
            <div class="">
                <div class="btn-group">
                    <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
                        Experiment Data <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu" role="menu">
                        <li onclick="openExpDataFile()" id="openFileMenu"><a href="#"><span class="glyphicon glyphicon-open"></span> Load file</a></li>
                        <li onclick="openExpDataFolderFile()"><a href="#"><span class="glyphicon glyphicon-open"></span> Load folder</a></li>
                        <li onclick="saveExpDataFile()"><a href="#"><span class="glyphicon glyphicon-save"></span> Save</a></li>
                        <li onclick="saveAcebFile()"><a href="#"><span class="glyphicon glyphicon-export"></span> To Aceb</a></li>
                    </ul>
                </div>
                <div class="btn-group">
                    <button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
                        Template <span class="caret"></span>
                    </button>
                    <ul class="dropdown-menu" role="menu">
                        <li onclick="openTemplateFile()"><a href="#"><span class="glyphicon glyphicon-open"></span> Load Existing Template</a></li>
                        <li onclick="saveTemplateFile()"><a href="#"><span class="glyphicon glyphicon-save"></span> Save Template</a></li>
                    </ul>
                </div>
<!--                <button type="button" class="btn btn-primary" onclick="openFile()"><span class="glyphicon glyphicon-open"></span> Load</button>
                <button type="button" class="btn btn-primary" onclick="saveFile()"><span class="glyphicon glyphicon-save"></span> Save</button>-->
            </div>
            <br/>
            <ul class="nav nav-tabs">
                <li id="sheetTab" class="active dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">Spreadsheet
                        <span id="sheet_name_selected"></span>
                        <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu" id="sheet_tab_list">
                    </ul>
                </li>
                <li id="genTab"><a data-toggle="tab" href="#general_tab">General Info</a></li>
                <li id="refTab"><a data-toggle="tab" href="#reference_tab">Table Relations</a></li>
                <li id="SC2Tab"><a data-toggle="tab" href="#sc2_tab">SC2 Preview</a></li>
                <li><a data-toggle="tab" href="#csv_tab"><em> CSV [debug]</em></a></li>
                <li id="mappingTab"><a data-toggle="tab" href="#mapping_tab"><em>Mappings Cache [debug]</em></a></li>
            </ul>
            <div class="tab-content">
                <div id="spreadshet_tab" class="tab-pane fade in active">
                    <div class="">
    <!--                        <span class="label label-info"><strong>&nbsp;Header Row&nbsp;</strong></span>
                            <span class="label label-info"><u>&nbsp;&nbsp;&nbsp;&nbsp;Unit Row&nbsp;&nbsp;&nbsp;&nbsp;</u></span>
                            <span class="label label-info"><em>Description Row</em></span>
                            <span class="label label-default">Ignored Row</span>-->
                        <label>View Style: </label>
                        <input type="checkbox" id="tableViewSwitch" class="table_switch_cb" data-toggle="toggle" data-size="mini" data-on="Full View" data-off="Data Only">
                        <label>Column Marker : </label>
                        <span class="label label-success">ICASA Mapped</span>
                        <span class="label label-info">Customized</span>
                        <span class="label label-primary">Virtual</span>
                        <span class="label label-warning">Undefined</span>
                        <span class="label label-danger"><em>Warning</em></span>
                        <span class="label label-default">Ignored</span>
                    </div>
                    <div id="sheet_spreadsheet_content" class="col-sm-12" style="overflow: hidden"></div>
                </div>
                <div id="csv_tab" class="tab-pane fade">
                    <textarea class="form-control" rows="30" id="sheet_csv_content" style="font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;" readonly></textarea>
                </div>
                <div id="general_tab" class="tab-pane fade">
                    <div class="subcontainer">
                        <fieldset class="col-sm-12">
                            <legend data-toggle="tooltip" title="Used for file name">Data Information</legend>
                            <div class="form-group col-sm-12">
                                <label class="control-label">Mapping Author Email:</label>
                                <div class="input-group col-sm-12">
                                    <input type="email" name="mapping_author" class="form-control mapping_gengeral_info" value="">
                                </div>
                            </div>
                            <div class="form-group col-sm-12">
                                <label class="control-label">Oringal Data URL:</label>
                                <div class="input-group col-sm-12">
                                    <input type="url" name="source_url" class="form-control mapping_gengeral_info" value="">
                                </div>
                            </div>
                        </fieldset>
                    </div>
                </div>
                <div id="reference_tab" class="tab-pane fade">
                    <div id="ref_table" class="subcontainer panel-group"></div>
                </div>
                <div id="mapping_tab" class="tab-pane fade">
                    <div class="col-sm-6" style="overflow: auto;height: 600px">
                        <div id="mapping_json_content_tree"></div>
                    </div>
                    <div class="col-sm-6">
                        <textarea class="form-control" rows="30" id="mapping_json_content_text" style="font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;" readonly></textarea>
                    </div>
                </div>
                <div id="sc2_tab" class="tab-pane fade">
                    <div class="col-sm-6" style="overflow: auto;height: 600px">
                        <div id="sc2_json_content_tree"></div>
                    </div>
                    <div class="col-sm-6">
                        <textarea class="form-control" rows="30" id="sc2_json_content_text" style="font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;" readonly></textarea>
                    </div>
                </div>
            </div>
        </div>

        <#include "data_factory_popup_loadFile.ftl">
        <#include "data_factory_popup_row.ftl">
        <#include "data_factory_popup_column.ftl">
        <#include "data_factory_table_reference.ftl">
        <#include "../footer.ftl">
        <script type="text/javascript" src='/plugins/FileSaver/FileSaver.js'></script>
        <script type="text/javascript" src="/js/sheetjs/shim.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/sheetjs/xlsx.full.min.js"></script>
        <script type="text/javascript" src="/plugins/filestyle/bootstrap-filestyle.min.js"></script>
        <script type="text/javascript" src="/plugins/chosen/chosen.jquery.min.js" ></script>
        <script type="text/javascript" src="/plugins/chosen/prism.js" charset="utf-8"></script>
        <script type="text/javascript" src="/plugins/jsonViewer/jquery.json-viewer.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/chosen/init.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/dataReader/BufferedFileReader.js"></script>
        <script type="text/javascript" src="/js/bootbox/bootbox.all.min.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/toggle/bootstrap-toggle.min.js" charset="utf-8"></script>
        <script src="https://cdn.jsdelivr.net/npm/handsontable@6.2.2/dist/handsontable.full.min.js"></script>
        <!--<script src="https://cdn.jsdelivr.net/npm/exceljs@1.13.0/dist/exceljs.min.js"></script>-->
        
        <script>
            $(document).ready(function () {
                initIcasaLookupSB();
                initIcasaCategorySB();
                chosen_init_all();
                $('input').on("blur", function(event) {
                    event.target.checkValidity();
                }).bind('invalid', function(event) {
                    alertBox(event.target.value + " is an invalid " + event.target.type, function () {
                        setTimeout(function() { $(event.target).focus();}, 50);
                    });
                });
                $(".mapping_gengeral_info").on("change", function () {
                    isChanged = true;
                    isViewUpdated = false;
                    isDebugViewUpdated = false;
                });
                $('.nav-tabs #sheetTab').on('shown.bs.tab', function(){
                    $('.table_switch_cb').bootstrapToggle('enable');
                    if (templates[curFileName][curSheetName].data_start_row) {
                        $('#tableViewSwitch').bootstrapToggle('off');
                    } else {
                        showSheetDefPrompt(processData);
                        $('#tableViewSwitch').bootstrapToggle('on');
                    }
                });
                $('.nav-tabs #genTab').on('shown.bs.tab', function(){
//                    chosen_init_all($("#general_tab"));
                });
                $('.nav-tabs #refTab').on('shown.bs.tab', function(){
                    initRefTable();
                });
                $('.nav-tabs #mappingTab').on('shown.bs.tab', function(){
                    $("#mapping_json_content_text").html(JSON.stringify(templates, 2, 2));
                    if (!isDebugViewUpdated) {
                        $("#mapping_json_content_tree").jsonViewer(templates, {collapsed: true, rootCollapsable: false});
                        isDebugViewUpdated = true;
                    }
                });
                $('.nav-tabs #SC2Tab').on('shown.bs.tab', function(){
                    $("#sc2_json_content_text").html(toSC2Json());
                    if (!isViewUpdated) {
                        $("#sc2_json_content_tree").jsonViewer(toSC2Obj(), {collapsed: true, rootCollapsable: false});
                        isViewUpdated = true;
                    }
                });
                $("button").prop("disabled", false);
                $('#tableViewSwitch').change(function () {
                    initSpreadsheet(curFileName, curSheetName);
                });
//                $('#tableColSwitchSuccess').change(function () {
//                    let plugin = spreadsheet.getPlugin('hiddenColumns');
//                    let hiddenArr = [];
//                    let isShown = $('#tableColSwitchSuccess').prop('checked');
//                    let sheetDef = templates[curFileName][curSheetName];
//                    let mappings = sheetDef.mappings;
//                    for (let i = 0; i < mappings.length; i++) {
//                        if (mappings[i].icasa) {
//                            if (isShown) {
//                                plugin.showColumn(i);
//                            } else {
//                                plugin.hideColumn(i);
//                            }
//                            
//                        }
//                    };
//                });
                $('#sheetTab').on("click", function() {
                    $('#sheet_tab_list').find("a").each(function () {
                        let tmp = $(this).attr('id').split("__");
                        let cntUndefined = countUndefinedColumns(templates[tmp[0]][tmp[1]].mappings);
                        if (cntUndefined > 0) {
                            $(this).find("span").html(cntUndefined).removeClass("invisible");
                        } else {
                            $(this).find("span").html(cntUndefined).addClass("invisible");
                        }
                    });
                });
                $('.table_switch_cb').bootstrapToggle('disable');
                $(window).resize(function(){
                    if (spreadsheet) {
                        spreadsheet.updateSettings({
                            height: $(window).height() - $("body").height() + $("#sheet_spreadsheet_content").height()
                        });
                    }
                });
                $("#openFileMenu").click();
                $(window).on('beforeunload',function(){
                    if (isChanged) {
                        return "There are changes have not been saved yet";
                    }
                });
//                window.addEventListener('beforeunload', (event) => {
//                    if (isChanged) {
//                        event.preventDefault();
//                        event.returnValue = "There are changes have not been saved yet";
//                    } else {
//                        delete event['returnValue'];
//                    }
//                });
            });
        </script>
    </body>
</html>

