<script>
    function showEventTypePrompt(itemId, eventType) {
        if (!eventType) {
            eventType = "";
        }
        let itemData = eventData.get(itemId);
        if (!itemData.event) {
            bootbox.prompt({
                title: "Please select the event type",
                inputType: 'select',
                value: eventType,
                inputOptions: [
                        {text: 'Choose one...', value: ''},
                        {text: 'Planting',      value: 'planting'},
                        {text: 'Irrigation',    value: 'irrigation'},
                        {text: 'Fertilizer',    value: 'fertilizer'},
                        {text: 'Harvest',       value: 'harvest'}
                    ],
                callback: function(result){ 
                    if (!result) {
                        if (result === "") {
                            showEventTypePrompt(itemId);
                        } else {
                            removeEvent();
                        }
                    } else {
                        itemData.event = result;
                        showEventDataDialog(itemData);
                    }
                }
            });
        } else {
            showEventDataDialog(itemData, true);
        }
    }
    
    function showEventDataDialog(itemData, noBackFlg, editFlg) {
        let promptClass = 'event-input-' + itemData.event;
        let buttons = {
            cancel: {
                label: "Cancel",
                className: 'btn-default',
                callback: removeEvent
            },
            back: {
                label: "&nbsp;Back&nbsp;",
                className: 'btn-default',
                callback: function(){
                    showEventTypePrompt(itemData.id, itemData.event);
                }
            },
            ok: {
                label: "&nbsp;Save&nbsp;",
                className: 'btn-primary',
                callback: function(){
                    $(this).find('.event-input-item').each(function () {
                        let varName = $(this).attr("name");
                        let varValue = $(this).val();
                        if (varValue.toString().trim() !== "") {
                            if (varName === "start") {
                                varValue = dateUtil.toLocaleStr(varValue);
                            }
                            editEvent(varName, varValue);
                        } else {
                            editEvent(varName);
                        }
                    });
                    $(this).find('.event-input-global').each(function () {
                        let varName = $(this).attr("name");
                        let varValue = $(this).val();
                        if (varValue.toString().trim() !== "") {
                            if (varName === "start") {
                                varValue = dateUtil.toLocaleStr(varValue);
                            }
                            editAllEvent(itemData.event, varName, varValue);
                        } else {
                            editAllEvent(itemData.event, varName);
                        }
                        $("." + promptClass + " input[name="+ varName +"]").val(varValue);
                    });
                }
            }
        };
        if (editFlg) {
            delete buttons.cancel.callback;
        }
        if (noBackFlg) {
            delete buttons.back;
        } 
        let dialog = bootbox.dialog({
            title: "<h2>" + itemData.event + " Event Information</h2>",
            size: 'large',
            message: $("." + promptClass).html(),
            buttons: buttons
        });
        dialog.init(function(){
            if (itemData.event === "planting") {
                plmaSBHelper({value:itemData.plma});
            } else if (itemData.event === "irrigation") {
                iropSBHelper({value:itemData.irop});
            }
            for (let key in itemData) {
                
                if (key === "start") {
                    $('[name=start]').val(dateUtil.toYYYYMMDDStr(itemData.start));
                } else {
                    $('[name=' + key + ']').val(itemData[key]);
                }
            }
            if (!itemData.start) {
                $('[name=start]').val(dateUtil.toYYYYMMDDStr(new Date(defaultDate())));
            }
            
            dialog.find("input.event-input-global").each(function () {
                let varName = $(this).attr("name");
                let selections = eventData.get({
                    fields: [varName],
                    filter: function (item) {
                        return (item.event === itemData.event);
                    }
                });
                if (selections.length > 0) {
                    $(this).val(selections[0][varName]);
                }
            });
            dialog.find('.max-5').on('input', function() {
                limitLength(this, 5);
            });
        });
    }
    
    function rangeNumInput(target) {
        let value = target.value;
        $('[name=' + target.name + ']').val(value);
    }
    
    function rangeNumInputSP(target) {
        let name = target.name;
        let value;
        if (name === "hastg_num") {
            value = "GS" + target.value.padStart(3, "0");
            $('[name=hastg]').val(value);
        } else {
            rangeNumInput(target);
        }
    }
    
    function plmaSBHelper(target) {
        if (target.value === "T") {
            $("[name=pl_tran_info]").fadeIn();
        } else {
            $("[name=pl_tran_info]").fadeOut();
        }
    }
    
    function iropSBHelper(target) {
        if (target.value === "IR005") {
            $(".irr-amt").val("");
            $("[name=irr_amt]").fadeOut();
            $("[name=ir_drip_info]").fadeIn();
        } else {
            $(".drip-rate").val("");
            $("[name=irr_amt]").fadeIn();
            $("[name=ir_drip_info]").fadeOut();
        }
    }
</script>

<!-- Timeline current date label for mouse tracker -->
<span class="date-label"></span>

<!-- Timeline context menu Dialog -->
<ul class='event-menu'>
    <li>Planting Event</li>
    <li>Irrigation Event</li>
    <li>Fertilizer Event</li>
    <li>Harvest Event</li>
</ul>

<!-- Planting Dialog -->
<div class="event-input-planting" hidden>
    <p></p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-12">
            <label class="control-label">Event Name</label>
            <div class="input-group col-sm-12">
                <input type="text" name="content" class="form-control event-input-item" value="" >
            </div>
        </div>
        <!-- 2nd row -->
        <div class="form-group col-sm-4">
            <label class="control-label">Event Type</label>
            <div class="input-group col-sm-12">
                <input type="text" name="event" class="form-control event-input-item" value="planting" readonly >
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="cul_id">Planting Date</label>
            <div class="input-group col-sm-12">
                <input type="date" name="start" class="form-control event-input-item" value="">
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="cul_id">Emergence Date</label>
            <div class="input-group col-sm-12">
                <input type="date" name="edate" class="form-control event-input-item" value="">
            </div>
        </div>
        <!-- 3rd row -->
        <div class="form-group col-sm-4">
            <label class="control-label" for="plma">Planting Method *</label>
            <div class="input-group col-sm-12">
                <select name="plma" class="form-control event-input-item" data-placeholder="Choose a method..." onchange="plmaSBHelper(this);" required>
                    <option value=""></option>
                    <option value="B">Bedded</option>
                    <option value="S">Dry seed</option>
                    <option value="T">Transplants</option>
                    <option value="N">Nursery</option>
                    <option value="P">Pregerminated seed</option>
                    <option value="R">Ratoon</option>
                    <option value="V">Vertically planted sticks</option>
                    <option value="H">Horizontally planted sticks</option>
                    <option value="I">Inclined (45o) sticks</option>
                    <option value="C">Cutting</option>
                </select>
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="plds">Planting Distribution *</label>
            <div class="input-group col-sm-12">
                <select name="plds" class="form-control event-input-item" data-placeholder="Choose a type of distribution..." required>
                    <option value=""></option>
                    <option value="R">Rows</option>
                    <option value="H">Hills</option>
                    <option value="U">Uniform/Broadcast</option>
                </select>
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="plrs">Row Spacing (cm) *</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="plrs" step="1" max="300" min="1" class="form-control" value="" placeholder="Row spacing (cm)" data-toggle="tooltip" title="Row spacing (cm)" oninput="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="plrs" step="1" max="999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" required >
                </div>
            </div>
        </div>
        <!-- 4th row -->
        <div class="form-group col-sm-6">
            <label class="control-label" for="plrd">Row Direction (degree from north) *</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="plrd" step="1" max="360" min="1" class="form-control" value="" placeholder="Row Direction (degree from north)" data-toggle="tooltip" title="Row Direction (degree from north)" oninput="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="plrd" step="10" max="360" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" required >
                </div>
            </div>
        </div>
        <div class="form-group col-sm-6">
            <label class="control-label" for="pldp">Planting Depth (cm) *</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="pldp" step="1" max="100" min="1" class="form-control" value="" placeholder="Planting Depth (cm)" data-toggle="tooltip" title="Planting Depth (cm)" oninput="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="pldp" step="1" max="999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" required >
                </div>
            </div>
        </div>
        <!-- 5th row -->
        <div class="form-group col-sm-6">
            <label class="control-label" for="plpop">Plant population at Seeding (plants/m2) *</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="plpop" step="0.1" max="10" min="0.1" class="form-control" value="" placeholder="Plant population at Seeding (plants/m2)" data-toggle="tooltip" title="Plant population at Seeding (plants/m2)" oninput="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="plpop" step="1" max="9999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" required >
                </div>
            </div>
        </div>
        <div class="form-group col-sm-6">
            <label class="control-label" for="plpoe">Plant population at Emergence (plants/m2)</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="plpoe" step="0.1" max="10" min="0.1" class="form-control" value="" placeholder="Plant population at Emergence (plants/m2)" data-toggle="tooltip" title="Plant population at Emergence (plants/m2)" oninput="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="plpoe" step="1" max="9999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" required >
                </div>
            </div>
        </div>
        <!-- 6th row -->
        <div class="form-group col-sm-12" name="pl_tran_info" hidden>
            <fieldset>
                <legend>Transplant Information</legend>
                <!-- 6.1th row -->
                <div class="form-group col-sm-6">
                    <label class="control-label" for="plmwt">Planting Material Dry Weight (kg/ha) *</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="plmwt" step="0.1" max="10" min="1" class="form-control" value="" placeholder="Planting Material Dry Weight (kg/ha)" data-toggle="tooltip" title="Planting Material Dry Weight (kg/ha)" oninput="rangeNumInput(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="plmwt" step="1" max="999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" required >
                        </div>
                    </div>
                </div>
                <div class="form-group col-sm-6">
                    <label class="control-label" for="plenv">Temperature of transplant environment (C) *</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="plenv" step="1" max="40" min="1" class="form-control" value="" placeholder="Temperature of transplant environment (C)" data-toggle="tooltip" title="Temperature of transplant environment (C)" oninput="rangeNumInput(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="plenv" step="1" max="999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" required >
                        </div>
                    </div>
                </div>
                <!-- 6.2th row -->
                <div class="form-group col-sm-4">
                    <label class="control-label" for="page">Transplant Age (days) *</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="page" step="1" max="50" min="1" class="form-control" value="" placeholder="Transplant Age (days)" data-toggle="tooltip" title="Transplant Age (days)" oninput="rangeNumInput(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="page" step="1" max="999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" required >
                        </div>
                    </div>
                </div>
                <div class="form-group col-sm-4">
                    <label class="control-label" for="plph">Plant per hill</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="plph" step="1" max="100" min="1" class="form-control" value="" placeholder="Plant per hill" data-toggle="tooltip" title="Plant per hill" oninput="rangeNumInput(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="plph" step="1" max="999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" required >
                        </div>
                    </div>
                </div>
                <div class="form-group col-sm-4">
                    <label class="control-label" for="plspl">Initial Sprout Length (cm)</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="plspl" step="1" max="20" min="1" class="form-control" value="" placeholder="Initial Sprout Length (cm)" data-toggle="tooltip" title="Initial Sprout Length (cm)" oninput="rangeNumInput(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="plspl" step="1" max="999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" required >
                        </div>
                    </div>
                </div>
            </fieldset>
        </div>
    </div>
    <p>&nbsp;</p>
</div>

<!-- Irrigation Dialog -->
<div class="event-input-irrigation" hidden>
    <p></p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-12">
            <label class="control-label">Event Name</label>
            <div class="input-group col-sm-12">
                <input type="text" name="content" class="form-control event-input-item" value="" >
            </div>
        </div>
        <!-- 2nd row -->
        <div class="form-group col-sm-4">
            <label class="control-label">Event Type</label>
            <div class="input-group col-sm-12">
                <input type="text" name="event" class="form-control event-input-item" value="fertilizer" readonly >
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="cul_id">Event Date</label>
            <div class="input-group col-sm-12">
                <input type="date" name="start" class="form-control event-input-item" value="">
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="ireff">Efficiency (fraction)</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="ireff" step="0.05" max="1" min="0" class="form-control" placeholder="Irrigation Efficiency (fraction)" data-toggle="tooltip" title="Irrigation Efficiency (fraction)" oninput="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="ireff" step="0.05" max="1" min="0" class="form-control event-input-item max-5 event-input-global" oninput="rangeNumInput(this)" >
                </div>
            </div>
        </div>
        <!-- 3rd row -->
        <div class="form-group col-sm-6">
            <label class="control-label" for="irop">Opertion *</label>
            <div class="input-group col-sm-12">
                <select name="irop" class="form-control event-input-item" data-placeholder="Choose a fertilizer material..." onchange="iropSBHelper(this);">
                    <option value=""></option>
                    <option value="IR001">Furrow, mm</option>
                    <option value="IR002">Alternating furrows, mm</option>
                    <option value="IR003">Flood, mm</option>
                    <option value="IR004">Sprinkler, mm</option>
                    <option value="IR005">Drip or trickle, mm</option>
                    <option value="IR006">Flood depth, mm</option>
                    <option value="IR007">Water table depth, mm</option>
                    <option value="IR008">Percolation rate, mm day-1</option>
                    <option value="IR009">Bund height, mm</option>
                    <option value="IR010">Puddling (for Rice only)</option>
                    <option value="IR011">Constant flood depth, mm</option>
                    <option value="IR012">Subsurface (burried) drip, mm</option>
                    <option value="IR999">Irrigation method unknown/not given</option>
                </select>
            </div>
        </div>
        <div class="form-group col-sm-4" name="irr_amt">
            <label class="control-label" for="irval">Amount of Water (mm) *</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="irval" step="0.1" max="100" min="0" class="form-control irr-amt" value="" placeholder="Irrigation amount, depth of water (mm)" data-toggle="tooltip" title="Irrigation amount, depth of water (mm)" oninput="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="irval" step="0.1" max="999" min="0" class="form-control event-input-item max-5 irr-amt" value="" oninput="rangeNumInput(this)" >
                </div>
            </div>
        </div>
        <!-- 4th row -->
        <div class="form-group col-sm-12" name="ir_drip_info" hidden>
            <fieldset>
                <legend>Drip Emitter Information</legend>
                <!-- 4.2th row -->
                <div class="form-group col-sm-4">
                    <label class="control-label" for="irrat">Drip Emitter Rate(mL/s) *</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="irrat" step="0.001" max="1" min="0.001" class="form-control drip-rate" value="" placeholder="Drip Emitter Rate(mL/s)" data-toggle="tooltip" title="Drip Emitter Rate(mL/s)" oninput="rangeNumInput(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="irrat" step="0.1" max="999" min="0.001" class="form-control event-input-item max-5 drip-rate" value="" oninput="rangeNumInput(this)" required >
                        </div>
                    </div>
                </div>
                <div class="form-group col-sm-4">
                    <label class="control-label" for="irstr">Event Starting Time (mm:ss) *</label>
                    <div class="input-group col-sm-12">
                        <input type="time" name="irstr" class="form-control event-input-item" value="" placeholder="Event Starting Time (mm:ss)" data-toggle="tooltip" title="Event Starting Time (mm:ss)">
                    </div>
                </div>
                <div class="form-group col-sm-4">
                    <label class="control-label" for="irdur">Event Duration (min) *</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="irdur" step="1" max="1440" min="1" class="form-control" value="" placeholder="Event Duration (min)" data-toggle="tooltip" title="Event Duration (min)" oninput="rangeNumInput(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="irdur" step="1" max="1440" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" required >
                        </div>
                    </div>
                </div>
                <!-- 4.2th row -->
                <div class="form-group col-sm-4">
                    <label class="control-label" for="irspc">Drip Emitter Spacing (cm) *</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="irspc" step="0.1" max="50" min="1" class="form-control" value="" placeholder="Planting Material Dry Weight (kg/ha)" data-toggle="tooltip" title="Planting Material Dry Weight (kg/ha)" oninput="rangeNumInput(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="irspc" step="1" max="999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" required >
                        </div>
                    </div>
                </div>
                <div class="form-group col-sm-4">
                    <label class="control-label" for="irofs">Drip Emitter Offset (cm) *</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="irofs" step="0.1" max="50" min="1" class="form-control" value="" placeholder="Temperature of transplant environment (C)" data-toggle="tooltip" title="Temperature of transplant environment (C)" oninput="rangeNumInput(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="irofs" step="1" max="999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" required >
                        </div>
                    </div>
                </div>
                <div class="form-group col-sm-4">
                    <label class="control-label" for="irdep">Drip Emitter Depth (cm) *</label>
                    <div class="input-group col-sm-12">
                        <div class="col-sm-7">
                            <input type="range" name="irdep" step="0.1" max="100" min="1" class="form-control" value="" placeholder="Temperature of transplant environment (C)" data-toggle="tooltip" title="Temperature of transplant environment (C)" oninput="rangeNumInput(this)">
                        </div>
                        <div class="col-sm-5">
                            <input type="number" name="irdep" step="1" max="999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" required >
                        </div>
                    </div>
                </div>
            </fieldset>
        </div>
    </div>
    <p>&nbsp;</p>
</div>

<!-- Fertilizer Dialog -->
<div class="event-input-fertilizer" hidden>
    <p></p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-12">
            <label class="control-label">Event Name</label>
            <div class="input-group col-sm-12">
                <input type="text" name="content" class="form-control event-input-item" value="" >
            </div>
        </div>
        <!-- 2nd row -->
        <div class="form-group col-sm-4">
            <label class="control-label">Event Type</label>
            <div class="input-group col-sm-12">
                <input type="text" name="event" class="form-control event-input-item" value="fertilizer" readonly >
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="cul_id">Event Date</label>
            <div class="input-group col-sm-12">
                <input type="date" name="start" class="form-control event-input-item" value="">
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="fedep">Depth (cm)</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="fedep" step="1" max="300" min="0" class="form-control" value="" placeholder="Fertilizer applied depth (cm)" data-toggle="tooltip" title="Fertilizer applied depth (cm)" oninput="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="fedep" step="1" max="999" min="0" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" >
                </div>
            </div>
        </div>
        <!-- 3rd row -->
        <div class="form-group col-sm-6">
            <label class="control-label" for="fecd">Fertilizer Material *</label>
            <div class="input-group col-sm-12">
                <select name="fecd" class="form-control event-input-item" data-placeholder="Choose a fertilizer material...">
                    <option value=""></option>
                    <option value="FE001">Ammonium nitrate</option>
                    <option value="FE002">Ammonium sulfate</option>
                    <option value="FE003">Ammonium nitrate sulfate</option>
                    <option value="FE004">Anhydrous ammonia</option>
                    <option value="FE005">Urea</option>
                    <option value="FE006">Diammnoium phosphate</option>
                    <option value="FE007">Monoammonium phosphate</option>
                    <option value="FE008">Calcium nitrate</option>
                    <option value="FE009">Aqua ammonia</option>
                    <option value="FE010">Urea ammonium nitrate solution</option>
                    <option value="FE011">Calcium ammonium nitrate solution</option>
                    <option value="FE012">Ammonium polyphosphate</option>
                    <option value="FE013">Single super phosphate</option>
                    <option value="FE014">Triple super phosphate</option>
                    <option value="FE015">Liquid phosphoric acid</option>
                    <option value="FE016">Potassium chloride</option>
                    <option value="FE017">Potassium nitrate</option>
                    <option value="FE018">Potassium sulfate</option>
                    <option value="FE019">Urea super granules</option>
                    <option value="FE020">Dolomitic limestone</option>
                    <option value="FE021">Rock phosphate</option>
                    <option value="FE022">Calcitic limestone</option>
                    <option value="FE024">Rhizobium</option>
                    <option value="FE026">Calcium hydroxide</option>
                    <option value="FE051">Urea super granules</option>
                </select>
            </div>
        </div>
        <div class="form-group col-sm-6">
            <label class="control-label" for="feacd">Fertilizer Applications *</label>
            <div class="input-group col-sm-12">
                <select name="feacd" class="form-control event-input-item" data-placeholder="Choose a fertilizer application...">
                    <option value=""></option>
                    <option value="AP001">Broadcast, not incorporated</option>
                    <option value="AP002">Broadcast, incorporated</option>
                    <option value="AP003">Banded on surface</option>
                    <option value="AP004">Banded beneath surface</option>
                    <option value="AP005">Applied in irrigation water</option>
                    <option value="AP006">Foliar spray</option>
                    <option value="AP007">Bottom of hole</option>
                    <option value="AP008">On the seed</option>
                    <option value="AP009">Injected</option>
                    <option value="AP011">Broadcast on flooded/saturated soil, none in soil</option>
                    <option value="AP012">Broadcast on flooded/saturated soil, 15% in soil</option>
                    <option value="AP013">Broadcast on flooded/saturated soil, 30% in soil</option>
                    <option value="AP014">Broadcast on flooded/saturated soil, 45% in soil</option>
                    <option value="AP015">Broadcast on flooded/saturated soil, 60% in soil</option>
                    <option value="AP016">Broadcast on flooded/saturated soil, 75% in soil</option>
                    <option value="AP017">Broadcast on flooded/saturated soil, 90% in soil</option>
                    <option value="AP018">Band on saturated soil,2cm flood, 92% in soil</option>
                    <option value="AP019">Deeply placed urea super granules/pellets, 95% in soil</option>
                    <option value="AP020">Deeply placed urea super granules/pellets, 100% in soil</option>
                    <option value="AP999">Application method unknown/not given</option>
                </select>
            </div>
        </div>
        <!-- 3rd row -->
        <div class="form-group col-sm-4">
            <label class="control-label" for="feamn">Nitrogen (kg/ha)</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="feamn" step="1" max="999" min="1" class="form-control" value="" placeholder="Nitrogen in applied fertilizer (ka/ha)" data-toggle="tooltip" title="Nitrogen in applied fertilizer (ka/ha)" oninput="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="feamn" step="1" max="9999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" >
                </div>
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="feamp">Phosphorus (kg/ha)</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="feamp" step="1" max="999" min="1" class="form-control" value="" placeholder="Phosphorus in applied fertilizer (ka/ha)" data-toggle="tooltip" title="Phosphorus in applied fertilizer (ka/ha)" oninput="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="feamp" step="1" max="9999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" >
                </div>
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="feamk">Potassium (kg/ha)</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="feamk" step="1" max="999" min="1" class="form-control" value="" placeholder="Potassium in applied fertilizer (ka/ha)" data-toggle="tooltip" title="Potassium in applied fertilizer (ka/ha)" oninput="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="feamk" step="1" max="9999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" >
                </div>
            </div>
        </div>
        <!-- 4th row -->
        <div class="form-group col-sm-4">
            <label class="control-label" for="feamc">Calcium (kg/ha)</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="feamc" step="1" max="999" min="1" class="form-control" value="" placeholder="Calcium in applied fertilizer (ka/ha)" data-toggle="tooltip" title="Calcium in applied fertilizer (ka/ha)" oninput="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="feamc" step="1" max="9999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" >
                </div>
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="feamo">Other - amount (kg/ha)</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="feamo" step="1" max="999" min="1" class="form-control" value="" placeholder="Other elements in applied fertilizer (ka/ha)" data-toggle="tooltip" title="Other elements in applied fertilizer (ka/ha)" oninput="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="feamo" step="1" max="9999" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" >
                </div>
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="feocd">Other - name</label>
            <div class="input-group col-sm-12">
                <select name="feocd" class="form-control event-input-item" data-placeholder="Choose a type for other element...">
                    <option value=""></option>
                    <option value="Mg">Magnesium</option>
                    <option value="Mn">Manganese</option>
                    <option value="Cd">Cadmium</option>
                    <option value="Zn">Zinc</option>
                    <option value="S">Sulfur</option>
                    <option value="Fe">Iron</option>
                    <option value="Se">Selenium</option>
                    <option value="B">Boron</option>
                </select>
            </div>
        </div>
    </div>
    <p>&nbsp;</p>
</div>

<!-- Harvest Dialog -->
<div class="event-input-harvest" hidden>
    <p></p>
    <div class="col-sm-12">
        <!-- 1st row -->
        <div class="form-group col-sm-12">
            <label class="control-label">Event Name</label>
            <div class="input-group col-sm-12">
                <input type="text" name="content" class="form-control event-input-item" value="" >
            </div>
        </div>
        <!-- 2nd row -->
        <div class="form-group col-sm-4">
            <label class="control-label">Event Type</label>
            <div class="input-group col-sm-12">
                <input type="text" name="event" class="form-control event-input-item" value="harvest" readonly >
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="cul_id">Event Date</label>
            <div class="input-group col-sm-12">
                <input type="date" name="start" class="form-control event-input-item" value="">
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="hastg">Stage</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="hastg_num" step="1" max="20" min="1" class="form-control" value="" placeholder="Harvest Stage (code)" data-toggle="tooltip" title="Row spacing (cm)" oninput="rangeNumInputSP(this)">
                </div>
                <div class="col-sm-5">
                    <input type="text" name="hastg" class="form-control event-input-item" value="" readonly>
                </div>
            </div>
        </div>
        <!-- 3rd row -->
        <div class="form-group col-sm-6">
            <label class="control-label" for="hacom">Component</label>
            <div class="input-group col-sm-12">
                <select name="hacom" class="form-control event-input-item" data-placeholder="Choose a harvest component...">
                    <option value=""></option>
                    <option value="C">Canopy</option>
                    <option value="L">Leaves</option>
                    <option value="H">Harvest product</option>
                </select>
            </div>
        </div>
        <div class="form-group col-sm-6">
            <label class="control-label" for="hasiz">Size Group</label>
            <div class="input-group col-sm-12">
                <select name="hasiz" class="form-control event-input-item" data-placeholder="Choose a size group of harvest...">
                    <option value=""></option>
                    <option value="A">All</option>
                    <option value="S">Small - less than 1/3 full size</option>
                    <option value="M">Medium - from 1/3 to 2/3 full size</option>
                    <option value="L">Large - greater than 2/3 full size</option>
                </select>
            </div>
        </div>
        <!-- 4th row -->
        <div class="form-group col-sm-6">
            <label class="control-label" for="happc">Grain Harvest (%)</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="happc" step="1" max="100" min="1" class="form-control" value="" placeholder="Product Harvest (%)" data-toggle="tooltip" title="Grain harvest (%)" oninput="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="happc" step="1" max="100" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)" >
                </div>
            </div>
        </div>
        <div class="form-group col-sm-6">
            <label class="control-label" for="habpc">Byproduct takeoff (%)</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="habpc" step="1" max="100" min="1" class="form-control" value="" placeholder="Byproduct takeoff (%)" data-toggle="tooltip" title="Byproduct takeoff (%)" oninput="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="habpc" step="1" max="100" min="1" class="form-control event-input-item max-5" value="" oninput="rangeNumInput(this)">
                </div>
            </div>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
