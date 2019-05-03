<script>
    function createField(id, rawData) {
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
            fields[fieldId] = {fl_name: description};
        }
        let id_field = null;
        if (expData["exname"]) {
            id_field = expData["exname"].substring(0,4) + (num + 1).toString().padStart(4, "0");
        }
        fieldData = fields[fieldId];
        $('#field_list').append('<li><a data-toggle="tab" href="#Field" id="' + fieldId + '" onclick="setField(this);">' + description + '</a></li>');
        if (!id && id_field) {
            fieldData["id_field"] = id_field;
        }
        $('#id_field').val(fieldData.id_field);
        $('#soil_id').val("");
        $('#wst_id').val("");
        $('#fl_name').val(description);
        $('#2d_flg').val("N");
        $('#bdht').val("").trigger("input");
        $('#bdwd').val("").trigger("input");
        $('#pmalb').val("").trigger("input");
        for (let i in trtData) {
            $('#tr_field_' + trtData[i].trtno).append('<option value="' + fieldId + '">' + description + '</option>');
        }
        $('#field_badge').html(Object.keys(fields).length);
    }
    
    function setField(target) {
        fieldData = fields[target.id];
        fieldId = target.id;
        $('#id_field').val(fieldData['id_field']);
        $('#fl_name').val(fieldData['fl_name']);
        $('#soil_id').val(fieldData['soil_id']);
        $('#wst_id').val(fieldData['wst_id']);
        $('#bdht').val(fieldData['bdht']).trigger("input");
        $('#bdwd').val(fieldData['bdwd']).trigger("input");
        $('#pmalb').val(fieldData['pmalb']).trigger("input");
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
    
    function rangeNumInputId(target) {
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
                    <input type="text" id="id_field" name="id_field" class="form-control field_data max-8" value="" placeholder="Field identifier" data-toggle="tooltip" title="Field, identifier usually consisting of institution+site+4 digit number">
                    <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                </div>
            </div>
            <div class="form-group has-feedback col-sm-4">
                <label class="control-label" for="fl_name">Description</label>
                <div class="input-group col-sm-12">
                    <input type="text" id="fl_name" name="fl_name" class="form-control field_data" value="" placeholder="Locally used name for field" data-toggle="tooltip" title="Locally used name for field">
                    <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                </div>
            </div>
        </div>
        <div class="row col-sm-12">
            <div class="form-group has-feedback col-sm-4">
                <label class="control-label" for="soil_id">Soil ID</label>
                <div class="input-group col-sm-12">
                    <input type="text" id="soil_id" name="soil_id" class="form-control field_data max-10" value="" placeholder="Soil identifier" data-toggle="tooltip" title="Unique soil identifier linking from SOIL_PROFILES">
                    <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                </div>
            </div>
            <div class="form-group has-feedback col-sm-4">
                <label class="control-label" for="wst_id">Weather Station ID</label>
                <div class="input-group col-sm-12">
                    <input type="text" id="wst_id" name="wst_id" class="form-control field_data max-4" value="" placeholder="Weather station identifier" data-toggle="tooltip" title="Weather station identifier to link to site information">
                    <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                </div>
            </div>
        </div>
        <div class="row col-sm-12">
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
                            <input type="range" name="bdwd" step="1" max="300" min="1" class="form-control" value="" placeholder="Fertilizer applied depth (cm)" data-toggle="tooltip" title="Fertilizer applied depth (cm)" oninput="rangeNumInputId(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="bdwd" id="bdwd" step="1" max="999" min="0" class="form-control field_data max-5" value="" oninput="rangeNumInputId(this)" >
                        </div>
                    </div>
                </div>
                <div class="form-group has-feedback col-sm-12 2d-input" id="bdht_input" hidden>
                    <label class="control-label" for="bdht">Soil Bed Height (cm)</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="bdht" step="1" max="100" min="1" class="form-control" value="" placeholder="Fertilizer applied depth (cm)" data-toggle="tooltip" title="Fertilizer applied depth (cm)" oninput="rangeNumInputId(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="bdht" id="bdht" step="1" max="999" min="0" class="form-control field_data max-5" value="" oninput="rangeNumInputId(this)" >
                        </div>
                    </div>
                </div>
                <div class="form-group has-feedback col-sm-12 2d-input" id="pmalb_input" hidden>
                    <label class="control-label" for="pmalb">Albedo of plastic mulch</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="pmalb" step="0.01" max="1" min="0.01" class="form-control" value="" placeholder="Fertilizer applied depth (cm)" data-toggle="tooltip" title="Fertilizer applied depth (cm)" oninput="rangeNumInputId(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="pmalb" id="pmalb" step="0.1" max="1" min="0.01" class="form-control field_data max-5" value="" oninput="rangeNumInputId(this)" >
                        </div>
                    </div>
                </div>
            </fieldset>
        </div>
    </fieldset>
</div>