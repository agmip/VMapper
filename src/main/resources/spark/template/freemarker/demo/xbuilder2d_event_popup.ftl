<script>
    function showEventTypePrompt(itemId, eventType) {
        if (!eventType) {
            eventType = "";
        }
        let itemData = eventData.get(itemId);
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
                        showEventTypePrompt();
                    } else {
                        removeEvent();
                    }
                } else {
                    itemData.event = result;
                    showEventDataDialog(itemData);
                }
            }
        });
    }
    
    function showEventDataDialog(itemData, editFlg) {
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
                    $('.event-input-item').each(function () {
                        if ($(this).val().toString().trim() !== "") {
                            let varName = $(this).attr("name");
                            let varValue = $(this).val();
                            if (varName === "start") {
                                varValue = dateUtil.toLocaleStr(varValue);
                            }
                            editEvent(varName, varValue);
                        }
                    });
                }
            }
        };
        if (editFlg) {
            delete buttons.cancel.callback;
            delete buttons.back;
        }
        let promptClass = 'event-input-' + itemData.event;
        let dialog = bootbox.dialog({
            title: "Please input event data",
            size: 'large',
            message: $("." + promptClass).html(),
            buttons: buttons
        });
        dialog.init(function(){
//            $('[name=crop_name]').val($('#crid').find(":selected").text());
//            $('[name=crid]').val($('#crid').val());
            $("." + promptClass + " input").val("");
            for (let key in itemData) {
                $('[name=' + key + ']').val(itemData[key]);
            }
            if (itemData.start) {
                $('[name=start]').val(dateUtil.toYYYYMMDDStr(itemData.start));
            } else {
                $('[name=start]').val(dateUtil.toYYYYMMDDStr(new Date(defaultDate())));
            }
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
</script>
<ul class='event-menu'>
    <li>One-time Event</li>
    <li>Weekly Event</li>
    <li>Monthly Event</li>
    <li>Customized Event</li>
</ul>
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
                <select name="plma" class="form-control event-input-item" data-placeholder="Choose a method..." required>
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
                    <input type="range" name="plrs" step="1" max="300" min="1" class="form-control" value="" placeholder="Row spacing (cm)" data-toggle="tooltip" title="Row spacing (cm)" onchange="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="plrs" step="1" max="999" min="1" class="form-control event-input-item" value="" onchange="rangeNumInput(this)" required >
                </div>
            </div>
        </div>
        <!-- 4th row -->
        <div class="form-group col-sm-6">
            <label class="control-label" for="plrd">Row Direction (degree from north) *</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="plrd" step="1" max="360" min="1" class="form-control" value="" placeholder="Row spacing (cm)" data-toggle="tooltip" title="Row spacing (cm)" onchange="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="plrd" step="90" max="360" min="1" class="form-control event-input-item" value="" onchange="rangeNumInput(this)" required >
                </div>
            </div>
        </div>
        <div class="form-group col-sm-6">
            <label class="control-label" for="pldp">Planting Depth (cm) *</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="pldp" step="1" max="100" min="1" class="form-control" value="" placeholder="Row spacing (cm)" data-toggle="tooltip" title="Row spacing (cm)" onchange="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="pldp" step="1" max="999" min="1" class="form-control event-input-item" value="" onchange="rangeNumInput(this)" required >
                </div>
            </div>
        </div>
        <!-- 5th row -->
        <div class="form-group col-sm-6">
            <label class="control-label" for="plpop">Plant population at Seeding (plants/m2) *</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="plpop" step="0.1" max="10" min="0.1" class="form-control" value="" placeholder="Row spacing (cm)" data-toggle="tooltip" title="Row spacing (cm)" onchange="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="plpop" step="1" max="9999" min="1" class="form-control event-input-item" value="" onchange="rangeNumInput(this)" required >
                </div>
            </div>
        </div>
        <div class="form-group col-sm-6">
            <label class="control-label" for="plpoe">Plant population at Emergence (plants/m2)</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="plpoe" step="0.1" max="10" min="0.1" class="form-control" value="" placeholder="Row spacing (cm)" data-toggle="tooltip" title="Row spacing (cm)" onchange="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="plpoe" step="1" max="9999" min="1" class="form-control event-input-item" value="" onchange="rangeNumInput(this)" required >
                </div>
            </div>
        </div>
        <!-- 6th row -->
<!--        <div class="form-group col-sm-4">
            <label class="control-label" for="cul_id">Crop</label>
            <div class="input-group col-sm-12">
                <input type="text" name="crop_name" class="form-control" value="" readonly >
                <input type="hidden" name="crid" class="form-control event-input-item" value="" >
            </div>
        </div>
        <div class="form-group has-feedback col-sm-4">
            <label class="control-label" for="cul_id">Cultivar ID *</label>
            <div class="input-group col-sm-12">
                <input type="text" name="cul_id" class="form-control event-input-item" value="" required >
            </div>
        </div>-->
    </div>
    <p>&nbsp;</p>
</div>
<div class="event-input-irrigation" hidden>
    <p></p>
    <div class="col-sm-12">
        <div class="form-group">
            <label class="control-label">Event Type</label>
            <div class="input-group col-sm-12">
                <input type="text" name="event" class="form-control event-input-item" value="irrigation" readonly >
            </div>
        </div>
        Under construction...
    </div>
    <p>&nbsp;</p>
</div>
<div class="event-input-fertilizer" hidden>
    <p></p>
    <div class="col-sm-12">
        <div class="form-group">
            <label class="control-label">Event Type</label>
            <div class="input-group col-sm-12">
                <input type="text" name="event" class="form-control event-input-item" value="fertilizer" readonly >
            </div>
        </div>
        Under construction...
    </div>
    <p>&nbsp;</p>
</div>
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
        <div class="form-group col-sm-6">
            <label class="control-label">Event Type</label>
            <div class="input-group col-sm-12">
                <input type="text" name="event" class="form-control event-input-item" value="harvest" readonly >
            </div>
        </div>
        <div class="form-group col-sm-6">
            <label class="control-label" for="cul_id">Harvest Date</label>
            <div class="input-group col-sm-12">
                <input type="date" name="start" class="form-control event-input-item" value="">
            </div>
        </div>
        <!-- 3rd row -->
        <div class="form-group col-sm-4">
            <label class="control-label" for="hastg">Stage</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="hastg_num" step="1" max="20" min="1" class="form-control" value="" placeholder="Row spacing (cm)" data-toggle="tooltip" title="Row spacing (cm)" onchange="rangeNumInputSP(this)">
                </div>
                <div class="col-sm-5">
                    <input type="text" name="hastg" class="form-control event-input-item" value="" readonly>
                </div>
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="hacom">Component</label>
            <div class="input-group col-sm-12">
                <select name="hacom" class="form-control event-input-item" data-placeholder="Choose a method...">
                    <option value=""></option>
                    <option value="C">Canopy</option>
                    <option value="L">Leaves</option>
                    <option value="H">Harvest product</option>
                </select>
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="hasiz">Size Group</label>
            <div class="input-group col-sm-12">
                <select name="hasiz" class="form-control event-input-item" data-placeholder="Choose a type of distribution...">
                    <option value=""></option>
                    <option value="A">All</option>
                    <option value="S">Small - less than 1/3 full size</option>
                    <option value="M">Medium - from 1/3 to 2/3 full size</option>
                    <option value="L">Large - greater than 2/3 full size</option>
                </select>
            </div>
        </div>
        <!-- 4th row -->
        <div class="form-group col-sm-4">
            <label class="control-label" for="happc">Grain Harvest (%)</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="happc" step="1" max="100" min="1" class="form-control" value="" placeholder="Row spacing (cm)" data-toggle="tooltip" title="Row spacing (cm)" onchange="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="happc" step="1" max="100" min="1" class="form-control event-input-item" value="" onchange="rangeNumInput(this)" >
                </div>
            </div>
        </div>
        <div class="form-group col-sm-4">
            <label class="control-label" for="habpc">Byproduct takeoff (%)</label>
            <div class="input-group col-sm-12">
                <div class="col-sm-7">
                    <input type="range" name="habpc" step="1" max="100" min="1" class="form-control" value="" placeholder="Row spacing (cm)" data-toggle="tooltip" title="Row spacing (cm)" onchange="rangeNumInput(this)">
                </div>
                <div class="col-sm-5">
                    <input type="number" name="habpc" step="1" max="100" min="1" class="form-control event-input-item" value="" onchange="rangeNumInput(this)">
                </div>
            </div>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
