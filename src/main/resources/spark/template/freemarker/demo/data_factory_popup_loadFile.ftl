<script>
    function showLoadFileDialog(errMsg) {
        let dataFiles = [];
        let dataUrls = [];
        let sc2Files = [];
        let sc2Urls = [];
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
                    if (!dataSwitch.is(":checked") && dataFiles.length > 0) {
                        readSpreadSheet({files : dataFiles}, {files : sc2Files, urls: sc2Urls, isRemote : dialog.find("[name='sc2_source_switch']").is(":checked")});
                    } else if (dataSwitch.is(":checked") && dataUrls.length > 0) {
                        readSpreadSheet({files : dataUrls, isRemote: true}, {files : sc2Files, urls: sc2Urls, isRemote : dialog.find("[name='sc2_source_switch']").is(":checked")});
                    } else {
                        showLoadFileDialog("[Warn] Please select raw data file");
                    }
                }
            }
        };
        let dialog = bootbox.dialog({
            title: "<h2>Load raw data file and SC2 file</h2>",
            size: 'large',
            message: $("#loadFile_popup").html(),
            buttons: buttons
        });
        dialog.find(".modal-content").drags();
        let dataFileInput = dialog.find("[name='data_file']");
        let dataUrlInput = dialog.find("[name='data_urls']");
        let dataSwitch = dialog.find("[name='data_source_switch']");
        let sc2FileInput = dialog.find("[name='sc2_file']");
        let sc2UrlInput = dialog.find("[name='sc2_urls']");
        let sc2Switch = dialog.find("[name='sc2_source_switch']");
        dialog.on("shown.bs.modal", function() {
            if (errMsg) {
                dialog.find("[name='dialog_msg']").text(errMsg);
            }
            dataFileInput.on("change", function () {
                dataFiles = $(this).prop("files");
                if (dataFiles.length > 0) {
                    sc2FileInput.filestyle('disabled', false);
                    sc2Files = sc2FileInput.prop("files");
                    sc2UrlInput.prop('disabled', false).trigger("input");
                } else {
                    sc2FileInput.filestyle('disabled', true);
                    sc2Files = [];
                    sc2UrlInput.prop('disabled', true);
                    sc2Urls = [];
                }
            }).filestyle({text:"Browse", btnClass:"btn-primary", placeholder:"Browse original data files (*.xlsx; *.xls; *.csv)", badge: true});
            sc2FileInput.on("change", function () {
                sc2Files = $(this).prop("files");
            }).filestyle({text:"Browse", btnClass:"btn-primary", placeholder:"Browse sidecar file 2 file template (*.sc2.json)", badge: true});
            sc2FileInput.filestyle('disabled', true);
            dataUrlInput.on("input", function () {
                dataUrls = [];
                if ($(this).is(":disabled")) {
                    return;
                }
                let urls = $(this).val().replace(/\r/g, "").split(/\n/);
                for (let i in urls) {
                    let url = urls[i].trim();
                    if (url !== "") {
                        dataUrls.push({name : url});
                    }
                }
                sc2Switch.trigger("change");
            }).hide();
            sc2UrlInput.on("input", function () {
                sc2Urls = [];
                if ($(this).is(":disabled")) {
                    return;
                }
                let urls = $(this).val().replace(/\r/g, "").split(/\n/);
                for (let i in urls) {
                    let url = urls[i].trim();
                    if (url !== "") {
                        sc2Urls.push({name : url});
                    }
                }
            }).hide();
            dataSwitch.on("change", function () {
                if ($(this).is(':checked')) {
                    dataUrlInput.show().trigger("input");
                    dataFileInput.filestyle("destroy");
                    dataFileInput.hide();
                    dataFiles = [];
                } else {
                    dataUrlInput.hide();
                    dataFileInput.show().filestyle({text:"Browse", btnClass:"btn-primary", placeholder:"Browse original data files (*.xlsx; *.xls; *.csv)", badge: true});
                    dataUrls = [];
                }
                sc2Switch.trigger("change");
            }).bootstrapToggle({on:"Remote", off:"Local", size:"mini"});
            sc2Switch.on("change", function () {
                if ($(this).is(':checked')) {
                    sc2UrlInput.show().prop('disabled', dataFiles.length === 0 && dataUrls.length === 0).trigger("input");
                    sc2FileInput.filestyle("destroy")
                    sc2FileInput.hide();
                    sc2Files = [];
                } else {
                    sc2UrlInput.hide();
                    sc2Urls = [];
                    sc2FileInput.show().filestyle({text:"Browse", btnClass:"btn-primary", placeholder:"Browse sidecar file 2 file template (*.sc2.json)", badge: true,});
                    sc2FileInput.filestyle('disabled', dataFiles.length === 0 && dataUrls.length === 0);
                    if (dataFiles.length > 0 || dataUrls.length > 0) {
                        sc2Files = sc2FileInput.prop("files");
                    }
                }
            }).bootstrapToggle({on:"Remote", off:"Local", size:"mini"});
        });
    }

    function readSpreadSheet(target, sc2Files) {
        let files = target.files;
        let colors = [];
        virColCnt = {};
        lastHeaderRow = {};
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
        let pct;
        userVarMap = {};
        workbooks = {};
        fileTypes = {};
        fileUrls = {};
        templates = {};
        fileColors = {};
        curFileName = null;
        curSheetName = null;
        curTableIdx = null;
        latestTableIdx = 0;
        wbObj = null;
        sc2FileName = null;
        isChanged = false;
        isViewUpdated = false;
        isDebugViewUpdated = false;
        let reader;
        if (target.isRemote) {
            reader = new RemoteFileReader("/data/util/load_file");
            reader.onerror = alertBox;
            reader.onload = function() {
                let newPct = Math.floor(reader.getReadingProgressPct());
                if (pct < newPct) {
                    pct = newPct;
                    loadingDialog.find(".loading-msg").html(' Loading ' + f.name + ' (' + idx + '/' + files.length + ') ' + pct + "%");
                }
            }
        } else {
            reader = new FileReader();
        }
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
            let fileName;
            if (target.isRemote) {
                fileName = e.target.fileName;
                fileTypes[fileName] = e.target.fileType;
                fileUrls[fileName] = e.target.fileUrl;
                fileColors[fileName] = colors.shift();
            } else {
                fileName = f.name;
                fileTypes[fileName] = getMimeType(fileName, f.type);
                fileUrls[fileName] = "";
                fileColors[fileName] = colors.shift();
            }
            virColCnt[fileName] = {};
            lastHeaderRow[fileName] = {};
            let data = e.target.result;
            if (fileName.toLowerCase().endsWith(".csv")) {
                data = data.replace(/\t/gi, "    ");
                workbook = XLSX.read(data, {type: 'binary', dateNF: "yyyy-MM-dd", raw:true});
            } else {
                workbook = XLSX.read(data, {type: 'binary', dateNF: "yyyy-MM-dd"});
            }
            workbooks[fileName] = workbook;

            if (idx < files.length) {
                f = files[idx];
                pct = 0;
                idx++;
                loadingDialog.find(".loading-msg").html(' Loading ' + f.name + ' (' + idx + '/' + files.length + ') ...');
                if (target.isRemote) {
                    reader.readAsBinaryString(f.name);
                } else {
                    reader.readAsBinaryString(f);
                }
//                        reader.readAsArrayBuffer(f);
            } else {
                loadingDialog.modal('hide');
                $(".mapping_gengeral_info").val("");
                $("#file_url_inputs").html("");
                if (sc2Files.urls.length > 0 || sc2Files.files.length > 0) {
                    readSC2Json(sc2Files);
                } else {
                    showSheetDefDialog(processData);
                }
            }
        };

        // Start to read the first file
        let f = files[idx];
        idx++;
        pct = 0;
        let loadingDialog = bootbox.dialog({
            message: '<h4><span class="glyphicon glyphicon-refresh spinning"></span><span class="loading-msg"> Loading ' + f.name + ' (1/' + files.length + ') ...</span></h4></br><p><mark>MS Excel File (> 1 MB)</mark> might experice longer loading time...</p>',
//                    centerVertical: true,
            closeButton: false
        });
        loadingDialog.on("shown.bs.modal", function() {
            if (target.isRemote) {
                reader.readAsBinaryString(f.name);
            } else {
                reader.readAsBinaryString(f);
            }
        });
    }
    
    function getMimeType(name, contentType) {
        name = name.toLowerCase();
        if (name.endsWith("csv")) {
            return "text/csv";
        } else if (name.endsWith("xlsx")){
            return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";
        } else if (name.endsWith("xls")){
            return "application/vnd.ms-excel";
        } else {
            return contentType;
        }
    }

    function readSC2Json(target) {
        // reset part of the flags for the case of only loading template
        isChanged = false;
        isViewUpdated = false;
        isDebugViewUpdated = false;
//        fileUrls = {};

        let files;
        if (target.isRemote) {
            files = target.urls;
        } else {
            files = target.files;
        }
        let idx = 0;
        let f = files[idx];
        idx++;
        let reader;
        if (target.isRemote) {
            reader = new RemoteFileReader("/data/util/load_file");
            reader.onerror = alertBox;
        } else {
            reader = new FileReader();
        }
        let sc2Objs = [];
        $(".mapping_gengeral_info").val("");
//        $("#file_url_inputs").html("");
        reader.onloadend = function (evt) {
            let jsonStr = evt.target.result.trim();
            sc2Objs.push(JSON.parse(jsonStr));
            if (idx < files.length) {
                f = files[idx];
                idx++;
                if (target.isRemote) {
                    reader.readAsText(f.name);
                } else {
                    reader.readAsText(f);
                }
            } else {
                let sc2Obj = sc2Objs[0];
                if (target.isRemote) {
                    sc2FileName = evt.target.fileName;
                } else {
                    sc2FileName = f.name;
                }
                sc2FileName = sc2FileName.replace(".json", "").replace(".JSON", "");
                hotFixIndex(sc2Obj);
                let fileNames = [];
                if (sc2Obj.agmip_translation_mappings && sc2Obj.agmip_translation_mappings.files) {
                    for (let i in sc2Obj.agmip_translation_mappings.files) {
                        let fileMeta = sc2Obj.agmip_translation_mappings.files[i].file.file_metadata;
                        if (fileMeta && getMetaFileName(fileMeta)) {
                            fileNames.push(getMetaFileName(fileMeta));
                        }
                    }
                }
                for (let i = 1; i < sc2Objs.length; i++) {
                    hotFixIndex(sc2Objs[i]);
                    for (let key in sc2Objs[i]) {
                        if (sc2Obj[key]) {
                            if (key === "agmip_translation_mappings") {
                                for (let key2 in sc2Objs[i][key]) {
                                    if (key2 === "files") {
                                        for (let j in sc2Objs[i][key].files) {
                                            let fileObj = sc2Objs[i][key].files[j];
                                            if (!fileObj.file.file_metadata) {
                                                fileObj.file.file_metadata = {};
                                            }
                                            if (!getMetaFileName(fileObj.file.file_metadata)) {
                                                saveMetaFileName(fileObj.file.file_metadata, "N/A");
                                            }
                                            let cnt = 1;
                                            let fileName = getMetaFileName(fileObj.file.file_metadata);
                                            while (fileNames.includes(fileName)) {
                                                fileName = getMetaFileName(fileObj.file.file_metadata) + "_" + cnt;
                                                cnt++;
                                            }
                                            fileObj.file.file_metadata.file_name = fileName;
                                            sc2Obj[key].files.push(fileObj);
                                        }
                                    } else if (key2 === "relations") {
                                        for (let j in sc2Objs[i][key].relations) {
                                            sc2Obj[key].relations.push(sc2Objs[i][key].relations[j]);
                                        }
                                    } else {
                                        sc2Obj[key][key2] = sc2Objs[i][key][key2];
                                    }
                                }
                            } else {
                                copyObject(sc2Objs[i][key], sc2Obj[key]);
                            }
                        } else {
                            sc2Obj[key] = sc2Objs[i][key];
                        }
                    }
                }
                if (sc2Obj.mapping_info) {
                    for (let key in sc2Obj.mapping_info) {
                        $("[name='" + key + "']").val(sc2Obj.mapping_info[key]);
                    }
                }
                for (let i in sc2Obj.agmip_translation_mappings.files) {
                    let fileMeta = sc2Obj.agmip_translation_mappings.files[i].file.file_metadata;
                    let url = getMetaFileUrl(fileMeta);
                    if (!fileUrls[getMetaFileName(fileMeta)] && (url || url === "")) {
                        fileUrls[getMetaFileName(fileMeta)] = url;
                    }
                }
                for (let key in sc2Obj) {
                    if (key !== "agmip_translation_mappings" && key !== "mapping_info") {
                        sc2ObjCache[key] = sc2Obj[key];
                    }
                }
//                initLastestTableIdx(sc2Obj);
                showSheetDefDialog(loadSC2Obj, null, sc2Obj);
            }
        };
        if (target.isRemote) {
            reader.readAsText(f.name);
        } else {
            reader.readAsText(f);
        }
    }

    function hotFixIndex(sc2Obj) {
        if (!sc2Obj.mapping_info.vmapper_version || isOlderVersion(sc2Obj.mapping_info.vmapper_version, hotfixVersion)) {
            // apply the hot fix to the sc2 data
            // change the index used in the virtual column and reference definition to relative column index rather than original column index
            let virColIdxMap = {};

            // Fix virtual column definition
            for (let i in sc2Obj.agmip_translation_mappings.files) {
                let fileName = getMetaFileName(sc2Obj.agmip_translation_mappings.files[i].file.file_metadata);
                let sheets = sc2Obj.agmip_translation_mappings.files[i].file.sheets;
                virColIdxMap[fileName] = {};
                for (let j in sheets) {
                    let mappings = sheets[j].mappings;
                    let sheetName = sheets[j].sheet_name;
                    let virColIdxArr = [];
                    virColIdxMap[fileName][sheetName] = virColIdxArr;
                    let lastColIdx;
                    for (let k in mappings) {
                        if (mappings[k].column_index) {
                            if (lastColIdx) {
                                lastColIdx++;
                            } else {
                                lastColIdx = mappings[k].column_index;
                            }
                        } else {
                            if (mappings[k].column_index_vr) {
                                virColIdxArr.push(mappings[k].column_index_vr);
                                lastColIdx = mappings[k].column_index_vr;
                            } else {
                                lastColIdx++;
                                virColIdxArr.push(lastColIdx);
                            }
                        }
                    }
                    for (let k in mappings) {
                        if (!mappings[k].column_index) {
                            let virKeys;
                            if (mappings[k].formula_info) {
                                virKeys = mappings[k].formula_info.virtual_val_keys;
                            } else if (mappings[k].formula && mappings[k].formula.function === "join_columns") {
                                virKeys = mappings[k].formula.args.virtual_val_keys;
                            }
                            if (virKeys) {
                                for (let l in virKeys) {
                                    let key = Number(virKeys[l]);
                                    let tmpKey = key;
                                    for (let m in virColIdxArr) {
                                        if (key >= virColIdxArr[m]) {
                                            tmpKey--;
                                        }
                                    }
                                    virKeys[l] = tmpKey;
                                }
                            }
                        }
                    }
                }
            }

            // Fix reference definition
//                    for (let i in sc2Obj.agmip_translation_mappings.files) {
//                        let fileName = getMetaFileName(sc2Obj.agmip_translation_mappings.files[i].file.file_metadata);
//                        virColIdxMap[fileName] = {};
//                        for (let j in sc2Obj.agmip_translation_mappings.files[i].file.relations) {
//                            
//                        }
//                    }
        }
    }

    function isOlderVersion(sc2Ver, curVer) {
        if (!curVer) {
            curVer = vmapperVersion;
        }
        let curVer2 = curVer.replace("-SNAPSHOT", "").replace("-snapshot", "");
        let sc2Ver2 = sc2Ver.replace("-SNAPSHOT", "").replace("-snapshot", "");
        if (sc2Ver2 !== curVer2) {
            return sc2Ver2 < curVer2;
        } else {
            if (sc2Ver !== sc2Ver2 && sc2Ver !== curVer) {
                return true;
            } else {
                return false;
            }
        }
    }

    function initLastestTableIdx(sc2Obj) {
        let files = sc2Obj.agmip_translation_mappings.files;
        if (!files || files.length === 0) {
            return;
        }
        for (let i in files) {
            let fileConfig = files[i];
            for (let i in fileConfig.file.sheets) {
                let tableIdx = fileConfig.file.sheets[i].table_index - 1;
                if (tableIdx && latestTableIdx < tableIdx) {
                    latestTableIdx = tableIdx + 1;
                }
            }
        }
    }

    function copyObject(from, to) {
        if (!from || !to) {
            return;
        }
        for (let key in from) {
            if (to[key] && typeof to[key] === "object") {
                copyObject(from[key], to[key]);
            } else {
                to[key] = from[key];
            }
        }
    }
</script>

<!-- popup page for define sheet -->
<div id="loadFile_popup" hidden>
    <p name="dialog_msg" class="label label-danger"></p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-12">
            <label class="control-label">Raw Data File : </label>&nbsp;&nbsp;
            <input type="checkbox" name="data_source_switch">
            <input type="file" name="data_file" class="form-control" accept=".xlsx,.xls,.csv" multiple>
            <textarea name="data_urls" class="form-control" placeholder="Provide the URLs of your raw data files, use new line to separate them..."></textarea>
        </div>
        <!-- 2nd row -->
        <div class="form-group col-sm-12">
            <label class="control-label">SC2 Template File (optional):</label>&nbsp;&nbsp;
            <input type="checkbox" name="sc2_source_switch">
            <input type="file" name="sc2_file" class="form-control" accept=".sc2.json,.json,.sc2" multiple>
            <textarea name="sc2_urls" class="form-control" placeholder="Provide the URLs of your SC2 files, use new line to separate them..."></textarea>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
