<script>
    function addTrt() {
        let trtno = trtData.length + 1;
        let trtRow = $("<tr></tr>");
        $("#trt_table_body").append(trtRow);
        
        let trtIdxCell = $('<td></td>');
        trtRow.append(trtIdxCell);
        let trtRemoveBtn = $('<span type="button" class="btn glyphicon glyphicon-remove" onclick="removeTrt(this);"></span>');
        trtIdxCell.append($('<a href="#"></a>').append(trtRemoveBtn)).append($("<label></label>").append(trtno));
        trtRemoveBtn.attr("id", "trt_remove_btn_" + trtno);
        
        let trtNameCell = $("<td></td>");
        trtRow.append(trtNameCell);
        let trtNameInput = $('<input type="text" name="trt_name" class="form-control" placeholder="Treatment name" data-toggle="tooltip" title="Treatment name" required>');
        trtNameCell.append($("<div class='input-group col-sm-11'></div>").append(trtNameInput));
        trtNameInput.attr("id", "trt_name_" + trtno)
        trtNameInput.on('change', function() {
            let trtid = Number(this.id.replace("trt_name_", "")) - 1;
            saveData(trtData[trtid], this.name, this.value);
        });
        
        let trtFieldCell = $("<td></td>");
        trtRow.append(trtFieldCell);
        let trtFieldSB = $('<select name="field" class="form-control chosen-select-deselect" onchange="trtOptSelect(this);" data-placeholder="Choose a field..." required></select>');
        trtFieldCell.append($('<div class="input-group col-sm-11"></div>').append(trtFieldSB));
        trtFieldSB.append('<option value=""></option>');
        trtFieldSB.append('<option value="">Create new...</option>');
        for (let fid in fields) {
            trtFieldSB.append($('<option value="' + fid + '"></option>').append(fields[fid].fl_name));
        }
        trtFieldSB.attr("id", "tr_field_" + trtno);
        
        let trtMgnCell = $("<td></td>");
        trtRow.append(trtMgnCell);
        let trtMgnSB = $('<select name="management" class="form-control chosen-select-deselect" onchange="trtOptSelect(this);" data-placeholder="Apply management setups..." multiple required></select>');
        trtMgnCell.append($('<div class="input-group col-sm-11"></div>').append(trtMgnSB));
        trtMgnSB.append('<option value=""></option>');
        trtMgnSB.append('<option value="">Create new...</option>');
        for (let mid in managements) {
            trtMgnSB.append($('<option value="' + mid + '"></option>').append(managements[mid].mgn_name));
        }
        trtMgnSB.attr("id", "tr_mgn_" + trtno);
        
        let trtCfgCell = $("<td></td>");
        trtRow.append(trtCfgCell);
        let trtCfgSB = $('<select name="config" class="form-control chosen-select-deselect" onchange="trtOptSelect(this);" data-placeholder="Choose a Configuration..." required></select>');
        trtCfgCell.append($('<div class="input-group col-sm-11"></div>').append(trtCfgSB));
        trtCfgSB.append('<option value=""></option>');
        trtCfgSB.append('<option value="">Create new...</option>');
        trtCfgSB.attr("id", "tr_config_" + trtno);
        
        $("#tr_field_" + trtno).chosen("destroy");
        chosen_init("tr_field_" + trtno);
        $("#tr_mgn_" + trtno).chosen("destroy");
        chosen_init("tr_mgn_" + trtno);
        $("#tr_config_" + trtno).chosen("destroy");
        chosen_init("tr_config_" + trtno);
        trtData.push({trtno:trtno});
        $('#treatment_badge').html(trtData.length);
    }
    
    function removeTrt(target) {
        $("#" + target.id).parent().parent().parent().remove();
        let rmvId = Number(target.id.replace("trt_remove_btn_", "")) - 1;
        trtData.splice(rmvId, 1);
        for (let trtid = rmvId; trtid < trtData.length; trtid++) {
            let newId = trtid + 1;
            $("#trt_remove_btn_" + trtData[trtid].trtno).parent().parent().children("label").html(newId);
            $("#trt_remove_btn_" + trtData[trtid].trtno).attr("id", "trt_remove_btn_" + newId);
            $("#trt_name_" + trtData[trtid].trtno).attr("id", "tr_field_" + newId);
            $("#tr_field_" + trtData[trtid].trtno).attr("id", "tr_field_" + newId);
            $("#tr_mgn_" + trtData[trtid].trtno).attr("id", "tr_field_" + newId);
            $("#tr_config_" + trtData[trtid].trtno).attr("id", "tr_field_" + newId);
            trtData[trtid].trtno = newId;
        }
        $('#treatment_badge').html(trtData.length);
    }
    
    function trtOptSelect(target) {
        if (target.selectedIndex === 1) {
            target.options[1].selected = false;
            $("#" + target.id.replace("tr_", "").replace(/_\d+/, "") + "_create").click();
        } else {
            let trtid = Number(target.id.replace(/tr_\w+_/, "")) - 1;
            if (target.name === "management") {
                let values = [];
                for (let i = 0; i < target.selectedOptions.length; i++) {
                    values.push(target.selectedOptions[i].value);
                }; 
                saveData(trtData[trtid], target.name, values);
            } else {
                saveData(trtData[trtid], target.name, target.value);
            }
            
        }
    }
</script>
<div class="subcontainer">
    <fieldset>
        <legend>
            Treatment Information&nbsp;&nbsp;&nbsp;
            <a href="#"><span id="trt_add_btn" type="button" class="btn glyphicon glyphicon-plus" onclick="addTrt();"></span></a>
        </legend>
        <table class="table table-hover table-striped table-condensed">
            <thead>
                <tr class="info">
                    <th class="col-sm-1 text-center">Index</th>
                    <th class="col-sm-3">Name</th>
                    <th class="col-sm-2">Field</th>
                    <th class="col-sm-4">Management</th>
                    <th class="col-sm-2">Configuration</th>
                </tr>
            </thead>
            <tbody id='trt_table_body'>
<!--                <tr>
                    <td><a href="#"><span id="trt_remove_btn_1" type="button" class="btn glyphicon glyphicon-remove" onclick="removeTrt(this);"></span></a><label>1</label></td>
                    <td>
                        <div class="input-group col-sm-11">
                            <input type="text" id="trt_name_1" name="trt_name" class="form-control" placeholder="Treatment name" data-toggle="tooltip" title="Treatment name" required>
                        </div>
                    </td>
                    <td>
                        <div class="input-group col-sm-11">
                            <select id="tr_field_1" name="field" class="form-control chosen-select-deselect" onchange="trtOptSelect(this);" data-placeholder="Choose a field..." required>
                                <option value=""></option>
                                <option value="">Create new...</option>
                            </select>
                        </div>
                    </td>
                    <td>
                        <div class="input-group col-sm-11">
                            <select id="tr_mgn_1" name="management" class="form-control chosen-select-deselect" onchange="trtOptSelect(this);" data-placeholder="Apply management setups..." multiple required>
                                <option value=""></option>
                                <option value="">Create new...</option>
                                <option value="PT">Default</option>
                                <option value="TM">N-150</option>
                                <option value="TM">N-200</option>
                                <option value="TM">N-250</option>
                                <option value="TM">I-subsurface</option>
                                <option value="TM">I-surface</option>
                                <option value="TM">I-fixed</option>
                            </select>
                        </div>
                    </td>
                    <td>
                        <div class="input-group col-sm-11">
                            <select id="tr_config_1" name="config" class="form-control chosen-select-deselect" onchange="trtOptSelect(this);" data-placeholder="Choose a Configuration..." required>
                                <option value=""></option>
                                <option value="">Create new...</option>
                            </select>
                        </div>
                    </td>
                </tr>-->
            </tbody>
        </table>
    </fieldset>
</div>
