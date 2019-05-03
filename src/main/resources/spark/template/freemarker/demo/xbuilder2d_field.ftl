<script>
    function createField(id, rawData) {
        syncICData();
        let num;
        let description;
        if (id) {
            fieldId = id;
            description = rawData.fl_name;
            fields[fieldId] = rawData;
        } else {
            num = getNewCollectionNum(fields);
            fieldId = "field_" + num;
            description = "New Field " + (num + 1);
            fields[fieldId] = {fl_name: description, initial_conditions: {soilLayer:[]}};
        }
        let id_field = null;
        if (expData["exname"]) {
            id_field = expData["exname"].substring(0,4) + (num + 1).toString().padStart(4, "0");
        }
        fieldData = fields[fieldId];
        if (!fieldData.initial_conditions) {
            fieldData.initial_conditions = {soilLayer:[]};
        } else if (!fieldData.initial_conditions.soilLayer) {
            fieldData.initial_conditions.soilLayer = [];
        }
        icLayers = fieldData.initial_conditions.soilLayer;
        $('#field_list').append('<li><a data-toggle="tab" href="#Field" id="' + fieldId + '" onclick="setField(this);">' + description + '</a></li>');
        if (!id && id_field) {
            fieldData["id_field"] = id_field;
        }
        $('.field-data').val("").trigger("input");
        $('.ic-data').val("").trigger("input");
        $('#id_field').val(fieldData.id_field);
        $('#fl_name').val(description);
        $('#2d_flg').val("N");
        for (let i in trtData) {
            $('#tr_field_' + trtData[i].trtno).append('<option value="' + fieldId + '">' + description + '</option>');
        }
        $('#field_badge').html(Object.keys(fields).length);
    }
    
    function setField(target) {
        syncICData();
        fieldData = fields[target.id];
        fieldId = target.id;
        icLayers = fieldData.initial_conditions.soilLayer;
        $('.field-data').each(function() {
            $(this).val(fieldData[$(this).attr("id")]).trigger("input");
        });
        $('.ic-data').each(function() {
            $(this).val(fieldData.initial_conditions[$(this).attr("id")]).trigger("input");
        });
        if (fieldData['pmalb']) {
            if (fieldData['bdht']) {
                $('#2d_flg').val("BBP").trigger("change");
            } else if (fieldData['bdwd']) {
                $('#2d_flg').val("FPP").trigger("change");
            } else {
                $('#2d_flg').val("FFP").trigger("change");
            }
        } else {
            if (fieldData['bdht'] || fieldData['bdwd']) {
                $('#2d_flg').val("BNP").trigger("change");
            } else {
                $('#2d_flg').val("N").trigger("change");
            }
        }
    }
    
    function removeField(id) {
        if (id) {
            fieldId = id;
        }
        delete fields[fieldId];
        $('#field_list li a[id="' + fieldId + '"]').remove();
        for (let i in trtData) {
            $('#tr_field_' + trtData[i].trtno + ' option[value="' + fieldId + '"]').remove();
        }
        let fieldIds = Object.keys(fields);
        $('#field_badge').html(fieldIds.length);
        for (let i in trtData) {
            $('#tr_field_' + trtData[i].trtno).trigger("change");
        }
        if (!id) {
            if (fieldIds.length > 0) {
                $("#" + fieldIds[0]).click();
            } else {
                $("#SiteInfoTab a").click();
            }
        }
    }
    
    function rangeNumInputSync(target) {
        let type = target.type;
        if (type === "range") {
            $('#' + target.name).val(target.value).trigger("change");
        } else {
            $('[name=' + target.name + ']').val(target.value);
        }
        
    }
    
    function update2DFlg(flg) {
        if (flg === "N") {
            $("#bdwd").val("").trigger("input").trigger("change");
            $("#bdht").val("").trigger("input").trigger("change");
            $("#pmalb").val("").trigger("input").trigger("change");
            $(".2d-input").hide();
        } else if (flg === "BBP") {
            $(".2d-input").show();
            $("#bdwd_label").show();
            $("#bdwd_label2").hide();
        } else if (flg === "BNP") {
            $(".2d-input").show();
            $("#pmalb").val("").trigger("input").trigger("change");
            $("#pmalb_input").hide();
        } else if (flg === "FFP") {
            $(".2d-input").show();
            $("#bdwd").val("").trigger("input").trigger("change");
            $("#bdwd_input").hide();
            $("#bdht").val("").trigger("input").trigger("change");
            $("#bdht_input").hide();
        } else if (flg === "FPP") {
            $(".2d-input").show();
            $("#bdht").val("").trigger("input").trigger("change");
            $("#bdht_input").hide();
            $("#bdwd_label").hide();
            $("#bdwd_label2").show();
        }
    }
    
    function switchICInput(target) {
        let showBtn, hideBtn, showDiv, hideDiv;
        if (target.id === "ic_residue_swc_btn") {
            hideBtn = $("#ic_profile_swc_btn");
            hideDiv = $("#ic_profile_view");
            showBtn = $("#ic_residue_swc_btn");
            showDiv = $("#ic_residue_view");
        } else {
            hideBtn = $("#ic_residue_swc_btn");
            hideDiv = $("#ic_residue_view");
            showBtn = $("#ic_profile_swc_btn");
            showDiv = $("#ic_profile_view");
        }
        if(showBtn.hasClass("btn-primary")) {
            return;
        }
        hideBtn.removeClass("btn-primary").addClass("btn-default");
        showBtn.removeClass("btn-default").addClass("btn-primary");
        hideDiv.fadeOut("fast",function() {
            showDiv.fadeIn("fast", undateICView);
        });
    }
    
    function undateICView() {
        if ($("#ic_profile_swc_btn").hasClass("btn-primary")) {
            initSpreadsheet("ic", document.querySelector("#ic_sps_view"));
        } else {
            chosen_init("icpcr");
            syncICData();
        }
    }
    
    function syncICData() {
//        let icData = fieldData["initial_conditions"];
//        if (!icData) {
//            icData = {};
//            fieldData["initial_conditions"] = icData;
//        }
        clearNullElements(icLayers, ["icbl"]);
//        if (icLayers && icLayer.length > 0) {
//            let layers = icData["soilLayer"];
//            let addons = [];
//            let addFlg = false;
//            for (let i = 0; i < icLayer.length; i++) {
//                for (let j = 0; j < layers.length; j++) {
//                    if (layers[j].icbl === icLayer[j].icbl) {
//                        layers[j] = icLayer[i];
//                        break;
//                    }
//                }
//            }
//        } else {
//            delete idData["soilLayer"];
//        }
    }
</script>
<div class="subcontainer">
    <fieldset>
        <legend>
            Field Information&nbsp;&nbsp;&nbsp;
            <a href="#"><span id="field_remove_btn" type="button" class="btn glyphicon glyphicon-trash" onclick="removeField();"></span></a>
        </legend>
        <div class="row col-sm-12">
            <div class="form-group has-feedback col-sm-4">
                <label class="control-label" for="id_field">Field ID</label>
                <div class="input-group col-sm-12">
                    <input type="text" id="id_field" name="id_field" class="form-control field-data max-8" value="" placeholder="Field identifier" data-toggle="tooltip" title="Field, identifier usually consisting of institution+site+4 digit number">
                    <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                </div>
            </div>
            <div class="form-group has-feedback col-sm-4">
                <label class="control-label" for="fl_name">Description</label>
                <div class="input-group col-sm-12">
                    <input type="text" id="fl_name" name="fl_name" class="form-control field-data" value="" placeholder="Locally used name for field" data-toggle="tooltip" title="Locally used name for field">
                    <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                </div>
            </div>
        </div>
        <div class="row col-sm-12">
            <div class="form-group has-feedback col-sm-4">
                <label class="control-label" for="soil_id">Soil ID</label>
                <div class="input-group col-sm-12">
                    <input type="text" id="soil_id" name="soil_id" class="form-control field-data max-10" value="" placeholder="Soil identifier" data-toggle="tooltip" title="Unique soil identifier linking from SOIL_PROFILES">
                    <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                </div>
            </div>
            <div class="form-group has-feedback col-sm-4">
                <label class="control-label" for="wst_id">Weather Station ID</label>
                <div class="input-group col-sm-12">
                    <input type="text" id="wst_id" name="wst_id" class="form-control field-data max-4" value="" placeholder="Weather station identifier" data-toggle="tooltip" title="Weather station identifier to link to site information">
                    <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                </div>
            </div>
        </div>
        <div class="row col-sm-12">
            <fieldset class="col-sm-7">
                <legend>
                    Initial Conditions&nbsp;&nbsp;&nbsp;
                    <div class="btn-group slider">
                        <button id="ic_residue_swc_btn" type="button" class="btn btn-primary" onclick="switchICInput(this);">&nbsp;&nbsp;Residue&nbsp;&nbsp;</button>
                        <button id="ic_profile_swc_btn" type="button" class="btn btn-default" onclick="switchICInput(this);">Profile</button>
                    </div>
                </legend>
                <div class="row col-sm-12">
                    <div class="form-group col-sm-4">
                        <label class="control-label" for="icdat">Measurement Date</label>
                        <div class="input-group col-sm-12">
                            <input type="date" id="icdat" name="icdat" class="form-control ic-data" value="">
                        </div>
                    </div>
                    <div class="form-group col-sm-4">
                        <label class="control-label" for="icwt">Water table depth (cm)</label>
                        <div class="input-group col-sm-12">
                            <div class="col-sm-7">
                                <input type="range" name="icwt" step="1" max="200" min="0" class="form-control" value="" placeholder="Initial water table depth (cm)" data-toggle="tooltip" title="Initial water table depth (cm)" oninput="rangeNumInputSync(this)">
                            </div>
                            <div class="col-sm-5">
                                <input type="number" name="icwt" id="icwt" step="1" max="999" min="0" class="form-control ic-data max-5" value="" oninput="rangeNumInputSync(this)" >
                            </div>
                        </div>
                    </div>
                </div>
                <fieldset class="col-sm-12" id="ic_residue_view">
                    <legend>
                        Residue Information&nbsp;&nbsp;&nbsp;
                    </legend>
                    <div class="row col-sm-12">
                        <div class="form-group col-sm-4">
                            <label class="control-label" for="icpcr">Previous Crop</label>
                            <div class="input-group col-sm-12">
                                <select id="icpcr" class="form-control chosen-select-deselect ic-data" data-placeholder="Choose a Crop...">
                                    <option value=""></option>
                                    <#assign category = "">
                                    <#list culMetaList as culMeta>
                                        <#if category != culMeta.category>
                                            <#if culMeta?index != 0>
                                    </optgroup>
                                            </#if>
                                    <optgroup label="${culMeta.category!}">
                                        </#if>
                                        <option value="${culMeta.agmip_code!}">${culMeta.name!}</option>
                                        <#assign category = culMeta.category>
                                    </#list>
                                   </optgroup>
                                </select>
                            </div>
                        </div>
                        <div class="form-group col-sm-4">
                            <label class="control-label" for="icrt">Root weight (kg/ha)</label>
                            <div class="input-group col-sm-12">
                                <div class="col-sm-7">
                                    <input type="range" name="icrt" step="1" max="300" min="0" class="form-control" value="" placeholder="Root weight from previous crop (kg/ha)" data-toggle="tooltip" title="Root weight from previous crop (kg/ha)" oninput="rangeNumInputSync(this)">
                                </div>
                                <div class="col-sm-5">
                                    <input type="number" name="icrt" id="icrt" step="1" max="999" min="0" class="form-control ic-data max-5" value="" oninput="rangeNumInputSync(this)" >
                                </div>
                            </div>
                        </div>
                        <div class="form-group col-sm-4">
                            <label class="control-label" for="icnd">Nodule weight (kg/ha)</label>
                            <div class="input-group col-sm-12">
                                <div class="col-sm-7">
                                    <input type="range" name="icnd" step="1" max="300" min="0" class="form-control" value="" placeholder="Nodule weight from previous crop (kg/ha)" data-toggle="tooltip" title="Nodule weight from previous crop (kg/ha)" oninput="rangeNumInputSync(this)">
                                </div>
                                <div class="col-sm-5">
                                    <input type="number" name="icnd" id="icnd" step="1" max="999" min="0" class="form-control ic-data max-5" value="" oninput="rangeNumInputSync(this)" >
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row col-sm-12">
                        <div class="form-group col-sm-4">
                            <label class="control-label" for="icrag">Crop, above-ground (kg/ha)</label>
                            <div class="input-group col-sm-12">
                                <div class="col-sm-7">
                                    <input type="range" name="icrag" step="1" max="300" min="0" class="form-control" value="" placeholder="Residue above-ground weight, dry weight basis (kg/ha)" data-toggle="tooltip" title="Residue above-ground weight, dry weight basis (kg/ha)" oninput="rangeNumInputSync(this)">
                                </div>
                                <div class="col-sm-5">
                                    <input type="number" name="icrag" id="icrag" step="1" max="999" min="0" class="form-control ic-data max-5" value="" oninput="rangeNumInputSync(this)" >
                                </div>
                            </div>
                        </div>
                        <div class="form-group col-sm-4">
                            <label class="control-label" for="icrn">Nitrogen, above-ground (%)</label>
                            <div class="input-group col-sm-12">
                                <div class="col-sm-7">
                                    <input type="range" name="icrn" step="1" max="100" min="0" class="form-control" value="" placeholder="Residue, above-ground, nitrogen concentration (%)" data-toggle="tooltip" title="Residue, above-ground, nitrogen concentration (%)" oninput="rangeNumInputSync(this)">
                                </div>
                                <div class="col-sm-5">
                                    <input type="number" name="icrn" id="icrn" step="1" max="100" min="0" class="form-control ic-data max-5" value="" oninput="rangeNumInputSync(this)" >
                                </div>
                            </div>
                        </div>
                        <div class="form-group col-sm-4">
                            <label class="control-label" for="icrp">Phosphorus , above-ground (%)</label>
                            <div class="input-group col-sm-12">
                                <div class="col-sm-7">
                                    <input type="range" name="icrp" step="1" max="100" min="0" class="form-control" value="" placeholder="Residue, above-ground, phosphorus concentration (%)" data-toggle="tooltip" title="Residue, above-ground, phosphorus concentration (%)" oninput="rangeNumInputSync(this)">
                                </div>
                                <div class="col-sm-5">
                                    <input type="number" name="icrp" id="icrp" step="1" max="100" min="0" class="form-control ic-data max-5" value="" oninput="rangeNumInputSync(this)" >
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row col-sm-12">
                        <div class="form-group col-sm-4">
                            <label class="control-label" for="icrip">Incorporation percentage (%)</label>
                            <div class="input-group col-sm-12">
                                <div class="col-sm-7">
                                    <input type="range" name="icrip" step="1" max="100" min="0" class="form-control" value="" placeholder="Residue incorporation percentage (%)" data-toggle="tooltip" title="Residue incorporation percentage (%)" oninput="rangeNumInputSync(this)">
                                </div>
                                <div class="col-sm-5">
                                    <input type="number" name="icrip" id="icrip" step="1" max="100" min="0" class="form-control ic-data max-5" value="" oninput="rangeNumInputSync(this)" >
                                </div>
                            </div>
                        </div>
                        <div class="form-group col-sm-4">
                            <label class="control-label" for="icrdp">Incorporation depth (cm)</label>
                            <div class="input-group col-sm-12">
                                <div class="col-sm-7">
                                    <input type="range" name="icrdp" step="1" max="200" min="0" class="form-control" value="" placeholder="Residue incorporation depth (cm)" data-toggle="tooltip" title="Residue incorporation depth (cm)" oninput="rangeNumInputSync(this)">
                                </div>
                                <div class="col-sm-5">
                                    <input type="number" name="icrdp" id="icrdp" step="1" max="999" min="0" class="form-control ic-data max-5" value="" oninput="rangeNumInputSync(this)" >
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row col-sm-12">
                        <div class="form-group col-sm-4">
                            <label class="control-label" for="icrzc">Rhizobia number</label>
                            <div class="input-group col-sm-12">
                                <div class="col-sm-7">
                                    <input type="range" name="icrzc" step="1" max="200" min="0" class="form-control" value="" placeholder="Rhizobia number (count)" data-toggle="tooltip" title="Rhizobia number (count)" oninput="rangeNumInputSync(this)">
                                </div>
                                <div class="col-sm-5">
                                    <input type="number" name="icrzc" id="icrzc" step="1" max="999" min="0" class="form-control ic-data max-5" value="" oninput="rangeNumInputSync(this)" >
                                </div>
                            </div>
                        </div>
                        <div class="form-group col-sm-4">
                            <label class="control-label" for="icrze">Rhizobia effectiveness (0-1)</label>
                            <div class="input-group col-sm-12">
                                <div class="col-sm-7">
                                    <input type="range" name="icrze" step="0.1" max="1" min="0" class="form-control" value="" placeholder="Rhizobia effectiveness on 0-1 scale" data-toggle="tooltip" title="Rhizobia effectiveness on 0-1 scale" oninput="rangeNumInputSync(this)">
                                </div>
                                <div class="col-sm-5">
                                    <input type="number" name="icrze" id="icrze" step="0.01" max="1" min="0" class="form-control ic-data max-5" value="" oninput="rangeNumInputSync(this)" >
                                </div>
                            </div>
                        </div>
                    </div>
                </fieldset>
                <fieldset class="col-sm-12" id="ic_profile_view" hidden>
                    <legend>
                        Soil Profile&nbsp;&nbsp;&nbsp;
                    </legend>
                    <div id="ic_sps_view" class="col-sm-12"></div>
                </fieldset>    
            </fieldset>
            <fieldset class="col-sm-4">
                <legend>
                    2D Model features&nbsp;&nbsp;&nbsp;
                </legend>
                <div class="form-group has-feedback col-sm-12">
                    <label class="control-label" for="2d_flg">Use case selection</label>
                    <div class="input-group col-sm-12">
                        <select id="2d_flg" class="form-control chosen-select-deselect" onchange="update2DFlg(this.value);" data-placeholder="Choose a use case..." required>
                            <option value="N" selected>Not used</option>
                            <option value="BBP">Bed and furrow, bed covered with plastic mulch</option>
                            <option value="BNP">Bed and furrow, bed not covered with plastic mulch</option>
                            <option value="FFP">Flat surface, fully covered with plastic mulch</option>
                            <option value="FPP">Flat surface, partially covered with plastic mulch</option>
                        </select>
                    </div>
                </div>
                <div class="form-group has-feedback col-sm-12 2d-input" id="bdwd_input" hidden>
                    <label class="control-label" id="bdwd_label" for="bdwd">Soil Bed Width (cm)</label>
                    <label class="control-label" id="bdwd_label2" for="bdwd" hidden>Plastic Mulch Width (cm)</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="bdwd" step="1" max="300" min="1" class="form-control" value="" placeholder="Fertilizer applied depth (cm)" data-toggle="tooltip" title="Fertilizer applied depth (cm)" oninput="rangeNumInputSync(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="bdwd" id="bdwd" step="1" max="999" min="0" class="form-control field-data max-5" value="" oninput="rangeNumInputSync(this)" >
                        </div>
                    </div>
                </div>
                <div class="form-group has-feedback col-sm-12 2d-input" id="bdht_input" hidden>
                    <label class="control-label" for="bdht">Soil Bed Height (cm)</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="bdht" step="1" max="100" min="1" class="form-control" value="" placeholder="Fertilizer applied depth (cm)" data-toggle="tooltip" title="Fertilizer applied depth (cm)" oninput="rangeNumInputSync(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="bdht" id="bdht" step="1" max="999" min="0" class="form-control field-data max-5" value="" oninput="rangeNumInputSync(this)" >
                        </div>
                    </div>
                </div>
                <div class="form-group has-feedback col-sm-12 2d-input" id="pmalb_input" hidden>
                    <label class="control-label" for="pmalb">Albedo of plastic mulch</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="pmalb" step="0.01" max="1" min="0.01" class="form-control" value="" placeholder="Fertilizer applied depth (cm)" data-toggle="tooltip" title="Fertilizer applied depth (cm)" oninput="rangeNumInputSync(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="pmalb" id="pmalb" step="0.1" max="1" min="0.01" class="form-control field-data max-5" value="" oninput="rangeNumInputSync(this)" >
                        </div>
                    </div>
                </div>
            </fieldset>
        </div>
    </fieldset>
</div>