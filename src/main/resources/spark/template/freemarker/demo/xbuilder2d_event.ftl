<script>
    function createManagementSetup() {
        alert("[TODO] A tab will be created for the new operation group!");
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

    function editEvent() {
        let selections = timeline.getSelection();
        if (selections.length > 0) {
            eventData.update({id: selections[0], content: "event 2"});
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
        if (target.id === "timeline_swc_btn") {
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
        if(showBtn.hasClass("btn-primary")) {
            return;
        }
        hideBtn.removeClass("btn-primary").addClass("btn-default");
        showBtn.removeClass("btn-default").addClass("btn-primary");
        hideDiv.fadeOut("fast",function() {
            showDiv.fadeIn("fast", function() {
                if (target.id === "timeline_swc_btn") {
                    syncDataToTml();
                } else {
                    if (fstSpsFlg) {
                        fstSpsFlg = false;
                        initSpreadsheet();
                    } else {
                        syncDataToSps();
                    }
                }
            });
        });
    }
    
    function getEvents() {
        let arr = eventData.get();
        arr.forEach(function (data) {
            data.start = new Date(data.start).toLocaleDateString("en-US",{year: 'numeric', month: '2-digit', day: '2-digit' });
        });
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
                <label class="control-label" for="management_name">Management Setup Name *</label>
                <div class="input-group col-sm-12">
                    <input type="text" id="management_name" name="management_name" class="form-control" value="Default" required >
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
