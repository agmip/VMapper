<script>
    function createMgnData(name, events) {
        let tmlData = new vis.DataSet(events);
//        tmlData.on('*', function (event, properties, senderId) {
//            console.log('event:', event, 'properties:', properties, 'senderId:', senderId);
//        });
        tmlData.on('add', function(event, properties, senderId) {
//            console.log('event:', event, 'properties:', properties, 'senderId:', senderId);
            showEventTypePrompt();
        });
        return {mgn_name: name, data: events, tmlData: tmlData};
    }
    
    function showEventTypePrompt(eventType) {
        if (!eventType) {
            eventType = "";
        }
        bootbox.prompt({
            title: "Please select the event type",
            inputType: 'select',
            value: eventType,
            inputOptions: [
                    {text: 'Choose one...', value: ''},
                    {text: 'Planting',      value: 'planting',},
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
                    showEventDataDialog(result);
                }
            }
        });
    }
    
    function showEventDataDialog(eventType) {
        bootbox.dialog({
            title: "Please input event data",
            size: 'large',
            message: $('.event-input-' + eventType).html(),
            buttons: {
                cancel: {
                        label: "Cancel",
                        className: 'btn-default',
                        callback: removeEvent
                    },
                back: {
                        label: "&nbsp;Back&nbsp;",
                        className: 'btn-default',
                        callback: function(){
                            showEventTypePrompt(eventType);
                        }
                    },
                ok: {
                        label: "&nbsp;Save&nbsp;",
                        className: 'btn-primary',
                        callback: function(){
                            $('.event-input-item').each(function () {
                                editEvent($(this).attr("name"), $(this).val());
                            })
                        }
                    }
            }
        });
    }
    
    function createManagement() {
        let num = getNewCollectionNum(managements);
        mgnId = "mgn_" + num;
        let description = "New Management " + (num + 1);
        events = [];
        managements[mgnId] = createMgnData(description, events);
        eventData = managements[mgnId].tmlData;
        $('#mgn_list').append('<li><a data-toggle="tab" href="#Event" id="' + mgnId + '" onclick="setManagement(this);">' + description + '</a></li>');
        $('#mgn_name').val(description);
        for (let i in trtData) {
            $('#tr_mgn_' + trtData[i].trtno).append('<option value="' + mgnId + '">' + description + '</option>');
        }
        $('#mgn_badge').html(Object.keys(managements).length);
    }
    
    function setManagement(target) {
        syncEventData();
        events = managements[target.id].data;
        eventData = managements[target.id].tmlData;
        mgnId = target.id;
        $('#mgn_name').val(managements[target.id]['mgn_name']);
    }
    
    function removeManagement() {
        delete managements[mgnId];
        $('#mgn_list li a[id="' + mgnId + '"]').remove();
        for (let i in trtData) {
            $('#tr_mgn_' + trtData[i].trtno + ' option[value="' + mgnId + '"]').remove();
        }
        let mgnIds = Object.keys(managements);
        $('#mgn_badge').html(mgnIds.length);
        if (mgnIds.length > 0) {
            $("#" + mgnIds[0]).click();
        } else {
            $("#SiteInfoTab a").click();
        }
    }
    
    function syncEventData() {
        if (!mgnId) {
            return;
        }
        if ($("#spreadsheet_swc_btn").hasClass("btn-primary")) {
            syncDataToTml();
        } else {
            events = getEvents();
        }
    }
    
    function test() {
        timeline.setSelection(["b", "c"]);
    }

    function newId() {
        return "new" + (eventData.getIds().length + 1);
    }

    function defaultContent(target) {
        if (target.value !== undefined) {
            return 'New ' + target.value;
        } else {
            return 'New ' + target[0].textContent;
        }
    }

    function defaultDate() {
        if (Math.abs(timeline.getCurrentTime() - Date.now()) < 1) {
            let start = timeline.getWindow().start.valueOf();
            let end = timeline.getWindow().end.valueOf();
//                let ret = new Date();
            let ret = new Date(start + (end - start) / 8);
            return ret;
        } else {
            return timeline.getCurrentTime();
        }
    }

    function addEvent(target) {
        let event = {id: newId(), content: defaultContent(target), start: defaultDate()}; 
        eventData.add(event);
        timeline.setSelection(event.id);
    }

    function editEvent(name, value) {
        let selections = timeline.getSelection();
        if (selections.length > 0) {
            let updData = {id: selections[0]};
            updData[name] = value;
            eventData.update(updData);
        }
    }

    function removeEvent() {
        eventData.remove(timeline.getSelection());
    }

    function removeEvents() {
        if (timeline.getSelection().length === 0) {
            eventData.clear();
        } else {
            removeEvent();
        }
    }

    function drag(ev) {
        var event = {
            id: newId(),
            type: "box",
            content: defaultContent(ev.target),
            event: "irrigation"
        };
        ev.dataTransfer.setData("text", JSON.stringify(event));
    }
    
    function switchManagementViewType(target) {
        let showBtn, hideBtn, showDiv, hideDiv;
        if (!target) {
            if ($("#spreadsheet_swc_btn").hasClass("btn-primary")) {
                hideBtn = $("#timeline_swc_btn");
                hideDiv = $("#timeline_view");
                showBtn = $("#spreadsheet_swc_btn");
                showDiv = $("#spreadsheet_view");
            } else {
                hideBtn = $("#spreadsheet_swc_btn");
                hideDiv = $("#spreadsheet_view");
                showBtn = $("#timeline_swc_btn");
                showDiv = $("#timeline_view");
            }
        } else if (target.id === "timeline_swc_btn") {
            hideBtn = $("#spreadsheet_swc_btn");
            hideDiv = $("#spreadsheet_view");
            showBtn = $("#timeline_swc_btn");
            showDiv = $("#timeline_view");
        } else {
            hideBtn = $("#timeline_swc_btn");
            hideDiv = $("#timeline_view");
            showBtn = $("#spreadsheet_swc_btn");
            showDiv = $("#spreadsheet_view");
        }
        if(target && showBtn.hasClass("btn-primary")) {
            return;
        }
        if (target) {
            hideBtn.removeClass("btn-primary").addClass("btn-default");
            showBtn.removeClass("btn-default").addClass("btn-primary");
        }
        hideDiv.fadeOut("fast",function() {
            showDiv.fadeIn("fast", function() {
                if (showBtn.attr("id") === "timeline_swc_btn") {
                    syncDataToTml();
                } else {
                    syncDataToSps();
                }
                if (!mgnId) {
                    return;
                }
            });
        });
    }
    
    function getEvents() {
        let arr = eventData.get();
        arr.forEach(function (data) {
            data.start = new Date(data.start).toLocaleDateString("en-US",{year: 'numeric', month: '2-digit', day: '2-digit' });
        });
        managements[mgnId].data = arr;
        return arr;
    }
    
    function syncDataToSps() {
        events = getEvents();
        spreadsheet.loadData(events);
    }
    
    function syncDataToTml() {
        let x = -1, y = 0;
        for (let i = 0; i < events.length; i++) {
            if (events[i].id === null || events[i].id === undefined || events[i].id.trim() === "") {
                y++;
            } else if (y > 0) {
                events.splice(x + 1, y);
                y = 0;
                i -= y;
            } else {
                x = i;
            }
        }
        events.splice(x + 1, y);
        let delIds = eventData.getIds({
            filter: function (event) {
                for (let i in events) {
                    if (events[i].id === event.id) {
                        return false;
                    }
                }
                return true;
            }
        });
        eventData.remove(delIds);
        eventData.update(events);
    }
</script>
<div class="subcontainer">
    <fieldset>
        <legend>Management Information</legend>
        <div class="row col-sm-12">
            <div class="form-group has-feedback col-sm-4">
                <label class="control-label" for="management_name">Management Name *</label>
                <div class="input-group col-sm-12">
                    <input type="text" id="mgn_name" name="mgn_name" class="form-control" value="Default" required >
                    <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
                </div>
            </div>
            <div class="form-group has-feedback col-sm-4">
                <label class="control-label">View Type</label>
                <div class="input-group">
                    <div class="btn-group slider">
                        <button id="timeline_swc_btn" type="button" class="btn btn-primary" onclick="switchManagementViewType(this);">&nbsp;&nbsp;&nbsp;&nbsp;Timeline&nbsp;&nbsp;&nbsp;&nbsp;</button>
                        <button id="spreadsheet_swc_btn" type="button" class="btn btn-default" onclick="switchManagementViewType(this);">SpreadSheet</button>
                    </div>
                </div>
            </div>
        </div>
        
    </fieldset>
    <div id="timeline_view">
        <div class="row col-sm-12">
            <div class="col-sm-8 text-left">
                <button draggable="true" ondragstart="drag(event);" ondblclick="addEvent(this);" class="btn btn-primary" value="One-time Event"><span class="glyphicon glyphicon-menu-hamburger"></span> One-time Event</button>
                <button draggable="true" ondragstart="drag(event);" ondblclick="addEvent(this);" class="btn btn-primary" value="Weekly Event"><span class="glyphicon glyphicon-menu-hamburger"></span> Weekly Event</button>
                <button draggable="true" ondragstart="drag(event);" ondblclick="addEvent(this);" class="btn btn-primary" value="Monthly Event"><span class="glyphicon glyphicon-menu-hamburger"></span> Monthly Event</button>
                <button draggable="true" ondragstart="drag(event);" ondblclick="addEvent(this);" class="btn btn-primary" value="Customized Event"><span class="glyphicon glyphicon-menu-hamburger"></span> Customized Event</button>
            </div>
            <div class="col-sm-4 text-right">
                <!--<button class="btn btn-success" onclick="test()">Test</button>-->
                <!--<button class="btn btn-success" onclick="addEvent({value:'One-time Event'})">Add</button>-->
                <!--<button class="btn btn-success" onclick="editEvent()">Edit</button>-->
                <!--<button class="btn btn-success" onclick="removeEvent()">Remove</button>-->
                <button class="btn btn-danger" onclick="removeEvents()"><span class='glyphicon glyphicon-trash'></span> Clear</button>
            </div>
        </div>
        <div id="visualization" class="col-sm-12"></div>
    </div>
    <div id="spreadsheet_view" class="col-sm-12" hidden>
        <div id="visualization2" class="col-sm-12"></div>
    </div>
</div>
<ul class='event-menu'>
    <li>One-time Event</li>
    <li>Weekly Event</li>
    <li>Monthly Event</li>
    <li>Customized Event</li>
</ul>
<div class="event-input-planting" hidden>
    <p ></p>
    <div class="col-sm-12">
        <div class="form-group">
            <label class="control-label">Event Type</label>
            <div class="input-group col-sm-12">
                <input type="text" name="event" class="form-control event-input-item" value="planting" readonly >
            </div>
        </div>
        <div class="form-group has-feedback">
            <label class="control-label" for="cul_id">Cultivar ID *</label>
            <div class="input-group col-sm-12">
                <input type="text" name="cul_id" class="form-control event-input-item" value="" required >
            </div>
        </div>
        <div class="form-group has-feedback">
            <label class="control-label" for="plds">Row Spacing *</label>
            <div class="input-group col-sm-12">
                <input type="text" name="plds" class="form-control event-input-item" value="" required >
            </div>
        </div>
    </div>
    <p>&nbsp;</p>
</div>
<div class="event-input-irrigation" hidden>
    <p ></p>
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
    <p ></p>
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
    <p ></p>
    <div class="col-sm-12">
        <div class="form-group">
            <label class="control-label">Event Type</label>
            <div class="input-group col-sm-12">
                <input type="text" name="event" class="form-control event-input-item" value="harvest" readonly >
            </div>
        </div>
        Under construction...
    </div>
    <p>&nbsp;</p>
</div>
