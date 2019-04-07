<script>
    function updateExname(target) {
        let institute = $('#institute').val().toUpperCase().substring(0, 2);
//        $('#institute').val(institute);
        if (institute.length < 1) {
            institute = "??";
        } else if (institute.length < 2) {
            institute += "?";
        }
        
        let site = $('#site').val().toUpperCase().substring(0, 2);
//        $('#site').val(site);
        if (site.length < 1) {
            site = "??";
        } else if (site.length < 2) {
            site += "?";
        }
        
        let startYear = $('#start_year').val().substr(-2);
        if (startYear.trim() === "") {
            startYear = "??";
        }
        
        let expNo = $('#exp_no').val().substr(-2);
        if (expNo.trim() !== "") {
            expNo = Number(expNo);
            if (expNo === NaN) {
                expNo = "??";
            } else if (expNo < 10) {
                expNo = "0" + expNo;
            }
            $('#exp_no').val(expNo + "");
        } else {
            expNo = "??";
        }
        
        let crid;
        if (target.id === "crid") {
            crid = $('#crid').val();
            if (crid === "") {
                crid = "??";
            <#list culMetaList as culMeta>
            } else if (crid === "${culMeta.agmip_code!}") {
                crid = "${culMeta.dssat_code!}";
            </#list>
            } else {
                crid = "??";
            }
            if (crid !== "??") {
                expData.crid_dssat = crid;
            } else {
                delete expData.crid_dssat;
            }
        } else {
            if (expData.crid_dssat) {
                crid = expData.crid_dssat;
            } else {
                crid = "??";
            }
        }
        
        let exname = institute + site + startYear + expNo
        if (exname.includes("?")) {
            $('#exname').val("");
        } else {
            $('#exname').val(exname);
        }
        $('#exname').trigger('change');
        $('#exname_label').html(institute + site + startYear + expNo + "." + crid + "X");
    }
    
    function updateCulSB(target) {
        for (let i in trtData) {
            $('#tr_cul_' + trtData[i].trtno + " option").remove("[value!='']");
            $('#tr_cul_' + trtData[i].trtno).trigger("change");
        }
        if (target.value === "") {
            cultivars = {};
        } else {
            $.get("/data/cultivar?crid=" + target.value,
                function (culJsonStr) {
                    cultivars = JSON.parse(culJsonStr);
                    for (let i in trtData) {
                        let sb = $('#tr_cul_' + trtData[i].trtno);
                        for (let culId in cultivars) {
                            sb.append($('<option value="' + culId + '"></option>').append(cultivars[culId].cul_name));
                        }
                    }
                }
            );
        }
    }
</script>

<div class="subcontainer">
    <fieldset>
        <legend>Experiment Information</legend>
        <div id="output_file_group" class="form-group has-feedback col-sm-12">
            <label class="control-label" for="local_name">Experiment Name *</label>
            <div class="input-group col-sm-12">
                <!--<span class="input-group-addon glyphicon">*</span>-->
                <input type="text" id="local_name" name="local_name" class="form-control exp_data" placeholder="Locally used name for experiment" data-toggle="tooltip" title="Locally used name for experiment" required>
                <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
            </div>
        </div>
            <fieldset class="col-sm-4">
                <legend data-toggle="tooltip" title="Used for file name">Experiment Identifier</legend>
                <div class="form-group has-feedback col-sm-6">
                    <label class="control-label" for="institute">Institute *</label>
                    <div class="input-group">
                        <input type="text" id="institute" name="institute" class="form-control exp_data" onchange="updateExname(this);" placeholder="Institute code" data-toggle="tooltip" title="Institute indentifier code" required>
                        <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                    </div>
                </div>
                <div class="form-group has-feedback col-sm-6">
                    <label class="control-label" for="in">Site *</label>
                    <div class="input-group">
                        <input type="text" id="site" name="site" class="form-control exp_data" onchange="updateExname(this);" placeholder="Site code" data-toggle="tooltip" title="Site indentifier code" required>
                        <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                    </div>
                </div>
                <div class="form-group has-feedback col-sm-6">
                    <label class="control-label" for="start_year">Year *</label>
                    <div class="input-group col-sm-12">
                        <select type="year" id="start_year" name="start_year" class="form-control chosen-select-deselect exp_data" onchange="updateExname(this);" placeholder="Choose start year..." data-toggle="tooltip" title="The start year of experiment" required>
                            <option value=""></option>
                        </select>
                        <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                    </div>
                </div>
                <div class="form-group has-feedback col-sm-6">
                    <label class="control-label" for="exp_no">Crop *</label>
                    <div class="input-group col-sm-12">
                        <!--<span class="input-group-addon glyphicon">*</span>-->
                        <select id="crid" class="form-control chosen-select-deselect exp_data" onchange="updateCulSB(this);updateExname(this);" data-placeholder="Choose a Crop..." required>
                            <option value=""></option>
                            <#list culMetaList as culMeta>
                            <option value="${culMeta.agmip_code!}">${culMeta.name!}</option>
                            </#list>
                        </select>
                        <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                    </div>
                </div>
                <div class="form-group has-feedback col-sm-6">
                    <label class="control-label" for="exp_no">Experiment No. *</label>
                    <div class="input-group">
                        <input type="text" id="exp_no" name="exp_no" class="form-control exp_data" onchange="updateExname(this);" placeholder="Experiment no." data-toggle="tooltip" title="The index number of experiment" required>
                        <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                    </div>
                </div>
                <div class="form-group col-sm-6">
                    <label class="control-label">Experiment File Name:</label>
                    <div class="">
                        <p id="exname_label" class="form-control-static">????????.??X</p>
                        <input type="hidden" id="exname" class="exp_data" value="">
                    </div>
                </div>
            </fieldset>
            <fieldset id="output_file_group" class="col-sm-8">
                <legend>General Information</legend>
                <div class="form-group">
                    <label class="control-label" for="people">People</label>
                    <textarea rows="2" id="people" name="people" class="form-control exp_data" placeholder="Locally used name for experiment" data-toggle="tooltip" title="Locally used name for experiment"></textarea>
                </div>
                <div class="form-group">
                    <label class="control-label" for="address">Address</label>
                    <textarea rows="2" id="address" name="address" class="form-control exp_data" placeholder="Locally used name for experiment" data-toggle="tooltip" title="Locally used name for experiment"></textarea>
                </div>
                <div class="form-group">                    
                    <label class="control-label" for="site_name">Site</label>
                    <textarea rows="2" id="site_name" name="site_name" class="form-control exp_data" placeholder="Locally used name for experiment" data-toggle="tooltip" title="Locally used name for experiment"></textarea>
                </div>
            </fieldset>

    </fieldset>
</div>
