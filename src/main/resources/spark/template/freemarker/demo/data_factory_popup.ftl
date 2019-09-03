<!-- popup page for define sheet -->
<div id="col_define_popup" hidden>
    <p name="dialog_msg"></p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-6">
            <label class="control-label">Header Row #</label>
            <div class="input-group col-sm-12">
                <input type="number" step="1" min="1" name="header_row_num" class="form-control col-def-input-item" value="1">
            </div>
        </div>
        <div class="form-group col-sm-6">
            <label class="control-label">Unit Row #</label>
            <div class="input-group col-sm-12">
                <input type="number" step="1" min="1" name="header_row_num" class="form-control col-def-input-item" value="">
            </div>
        </div>
        <div class="form-group col-sm-6">
            <label class="control-label">Description Row #</label>
            <div class="input-group col-sm-12">
                <input type="number" step="1" min="1" name="header_row_num" class="form-control col-def-input-item" value="">
            </div>
        </div>
        <div class="form-group col-sm-6">
            <label class="control-label">Data Start from Row #</label>
            <div class="input-group col-sm-12">
                <input type="number" step="1" min="1" name="header_row_num" class="form-control col-def-input-item" value="2">
            </div>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
<!-- popup page for define column -->
<div id="col_define_popup" hidden>
    <p name="dialog_msg"></p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-6">
            <label class="control-label">Column Header</label>
            <div class="input-group col-sm-12">
                <input type="text" name="header" class="form-control col-def-input-item" value="" readonly>
            </div>
        </div>
        <div class="form-group col-sm-6">
            <label class="control-label">Variable Type</label>
            <div class="input-group col-sm-12">
                <select name="var_type" class="form-control" data-placeholder="Choose a variable type...">
                    <option value=""></option>
                    <option value="icasa">ICASA variable</option>
                    <option value="customized">Customized variable</option>
                    <option value="reference">Reference variable</option>
                </select>
            </div>
        </div>
        <!-- ICASA Management Variable Info -->
        <div name="icasa_info" hidden>
            <!-- 2nd row -->
            <div class="form-group col-sm-12">
                <label class="control-label">ICASA Variable</label>
                <div class="input-group col-sm-12">
                    <select name="code_display" class="form-control col-def-input-item" data-placeholder="Choose a variable...">
                    </select>
                </div>
            </div>
            <!-- 3rd row -->
            <div class="form-group col-sm-4">
                <label class="control-label">ICASA Unit</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="icasa_unit" class="form-control col-def-input-item" value="" readonly>
                </div>
            </div>
            <div class="form-group col-sm-4">
                <label class="control-label">Original Unit</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="source_unit" class="form-control col-def-input-item" value="">
                </div>
            </div>
            <div class="form-group col-sm-4">
                <label class="control-label"></label>
                <div class="input-group col-sm-12" name="unit_validate_result"></div>
            </div>
        </div>
        <div name="customized_info" hidden>
            <!-- 2nd row -->
            <div class="form-group col-sm-12">
                <label class="control-label">Variable Category</label>
                <div class="input-group col-sm-12">
                    <select name="category" class="form-control col-def-input-item" data-placeholder="Choose a variable type...">
                        <option value=""></option>
                        <option value="1011">Experiment Meta Data</option>
                        <option value="2011">Experiment Management Data</option>
                        <option value="2099">Experiment Management Event Data</option>
                        <option value="2502">Experiment Observation Summary Data</option>
                        <option value="2511">Experiment Observation Time-Series Data</option>
                        <option value="4051">Soil Profile Data</option>
                        <option value="4052">Soil Layer Data</option>
                        <option value="5041">Weather Station Profie Data</option>
                        <option value="5052">Weather Station Daily Data</option>
                    </select>
                </div>
            </div>
            <div class="form-group col-sm-12">
                <label class="control-label">Variable Code</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="code_display" class="form-control col-def-input-item" value="">
                </div>
            </div>
            <!-- 3rd row -->
            <div class="form-group col-sm-12">
                <label class="control-label">Description</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="description" class="form-control col-def-input-item" value="">
                </div>
            </div>
            <!-- 4th row -->
            <div class="form-group col-sm-12">
                <label class="control-label">Unit</label>
                <div class="input-group col-sm-12">
                    <input type="text" name="source_unit" class="form-control col-def-input-item" value="">
                </div>
            </div>
            <div class="form-group col-sm-12">
                <label class="control-label"></label>
                <div class="input-group col-sm-12" name="unit_validate_result"></div>
            </div>
        </div>
        <div name="reference_info" hidden>
            <!-- 2nd row -->
            <div class="form-group col-sm-12">
                <label class="control-label">Reference Type</label>
                <div class="input-group col-sm-12">
                    <select name="category" class="form-control col-def-input-item" data-placeholder="Choose a variable type...">
                        <option value=""></option>
                        <option value="1011">Experiment Meta Data</option>
                        <option value="2011">Experiment Management Data</option>
                        <option value="2099">Experiment Management Event Data</option>
                        <option value="2502">Experiment Observation Summary Data</option>
                        <option value="2511">Experiment Observation Time-Series Data</option>
                        <option value="4051">Soil Profile Data</option>
                        <option value="4052">Soil Layer Data</option>
                        <option value="5041">Weather Station Profie Data</option>
                        <option value="5052">Weather Station Daily Data</option>
                    </select>
                </div>
            </div>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
