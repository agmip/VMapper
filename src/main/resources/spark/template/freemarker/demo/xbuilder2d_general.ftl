<script>
    function updateExname() {
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
        
        let crid = $('#crid').val();
        if (crid === "") {
            crid = "??";
        } else if (crid === "POT") {
            crid = "PT";
        } else if (crid === "TOM") {
            crid = "TM";
        } else {
            crid = "??";
        }
        
        $('#exname').val(institute + site + startYear + expNo);
        if (!(institute + site + startYear + expNo).includes("?")) {
            $('#exname').trigger('change');
        }
        $('#exname_label').html(institute + site + startYear + expNo + "." + crid + "X");
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
                        <input type="text" id="institute" name="institute" class="form-control exp_data" onchange="updateExname();" placeholder="Institute code" data-toggle="tooltip" title="Institute indentifier code" required>
                        <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                    </div>
                </div>
                <div class="form-group has-feedback col-sm-6">
                    <label class="control-label" for="in">Site *</label>
                    <div class="input-group">
                        <input type="text" id="site" name="site" class="form-control exp_data" onchange="updateExname();" placeholder="Site code" data-toggle="tooltip" title="Site indentifier code" required>
                        <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                    </div>
                </div>
                <div class="form-group has-feedback col-sm-6">
                    <label class="control-label" for="start_year">Year *</label>
                    <div class="input-group">
                        <select type="year" id="start_year" name="start_year" class="form-control chosen-select-deselect exp_data" onchange="updateExname();" placeholder="Choose start year..." data-toggle="tooltip" title="The start year of experiment" required>
                            <option value=""></option>
                        </select>
                        <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                    </div>
                </div>
                <div class="form-group has-feedback col-sm-6">
                    <label class="control-label" for="exp_no">Experiment No. *</label>
                    <div class="input-group">
                        <input type="text" id="exp_no" name="exp_no" class="form-control exp_data" onchange="updateExname();" placeholder="Experiment no." data-toggle="tooltip" title="The index number of experiment" required>
                        <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                    </div>
                </div>
                <div class="form-group has-feedback col-sm-6">
                    <label class="control-label" for="exp_no">Crop *</label>
                    <div class="input-group col-sm-12">
                        <!--<span class="input-group-addon glyphicon">*</span>-->
                        <select id="crid" class="form-control chosen-select-deselect exp_data" onchange="updateExname();" data-placeholder="Choose a Crop..." required>
                            <option value=""></option>
                            <option value="POT">Potato</option>
                            <option value="TOM">Tomato</option>
                        </select>
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
