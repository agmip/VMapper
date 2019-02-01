<div class="subcontainer">
    <fieldset>
        <legend>Treatment Information</legend>
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
        <tbody>
          <tr>
              <td class="align-middle"><label>1</label></td>
            <td>
                <div class="input-group col-sm-11">
                    <input type="text" id="local_name" name="local_name" class="form-control" placeholder="Locally used name for experiment" data-toggle="tooltip" title="Locally used name for experiment" required>
                </div>
            </td>
            <td>
                <div class="input-group col-sm-11">
                    <select id="tr_field_1" class="form-control chosen-select-deselect" data-placeholder="Choose a field..." required>
                        <option value=""></option>
                        <option value="PT">Default</option>
                        <option value="TM">Field 2</option>
                    </select>
                </div>
            </td>
            <td>
                <div class="input-group col-sm-11">
                    <select id="tr_management_1" class="form-control chosen-select-deselect" data-placeholder="Apply management setups..." multiple required>
                        <option value="PT" selected>Default</option>
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
                    <select id="tr_config_1" class="form-control chosen-select-deselect" data-placeholder="Choose a Configuration..." required>
                        <option value=""></option>
                        <option value="PT">Default</option>
                        <option value="TM">Config 2</option>
                    </select>
                </div>
            </td>
          </tr>
          <tr>
              <td class="align-middle"><label>2</label></td>
            <td>
                <div class="input-group col-sm-11">
                    <input type="text" id="local_name" name="local_name" class="form-control" placeholder="Locally used name for experiment" data-toggle="tooltip" title="Locally used name for experiment" required>
                </div>
            </td>
            <td>
                <div class="input-group col-sm-11">
                    <select id="tr_field_2" class="form-control chosen-select-deselect" data-placeholder="Choose a field..." required>
                        <option value=""></option>
                        <option value="PT">Default</option>
                        <option value="TM">Field 2</option>
                    </select>
                </div>
            </td>
            <td>
                <div class="input-group col-sm-11">
                    <select id="tr_management_2" class="form-control chosen-select-deselect" data-placeholder="Apply management setups..." multiple required>
                        <option value="PT" selected>Default</option>
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
                    <select id="tr_config_2" class="form-control chosen-select-deselect" data-placeholder="Choose a Configuration..." required>
                        <option value=""></option>
                        <option value="PT">Default</option>
                        <option value="TM">Config 2</option>
                    </select>
                </div>
            </td>
          </tr>
        </tbody>
      </table>
    </fieldset>
</div>
