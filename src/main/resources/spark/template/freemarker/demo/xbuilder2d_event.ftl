<script>
    function createManagementSetup() {
        alert("[TODO] A tab will be created for the new operation group!");
    }
    
    function test() {
        timeline.setSelection(["b", "c"]);
    }

    function newId() {
        return "new" + (events.getIds().length + 1);
    }

    function defaultContent(target) {
        return '<span class="glyphicon glyphicon-tint"></span> New ' + target.value;
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
        events.add(event);
        timeline.setSelection(event.id);
    }

    function editEvent() {
        let selections = timeline.getSelection();
        if (selections.length > 0) {
            events.update({id: selections[0], content: "event 2"});
        }
    }

    function removeEvent() {
        events.remove(timeline.getSelection());
    }

    function removeEvents() {
        if (timeline.getSelection().length === 0) {
            events.clear();
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
</script>
<div class="subcontainer">
    <fieldset>
        <legend>Management Information</legend>
        <div id="output_file_group2" class="form-group has-feedback">
            <label class="control-label" for="op_group_name">Management Setup Name *</label>
            <div class="input-group">
                <input type="text" id="op_group_name" name="op_group_name" class="form-control" value="Default" required >
                <!--<span class="glyphicon glyphicon-asterisk form-control-feedback" aria-hidden="true"></span>-->
            </div>
        </div>
    </fieldset>
    <div class="row">
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
    <div id="visualization"></div>
</div>
<ul class='event-menu'>
    <li value="One-time Event">One-time Event</li>
    <li value="Weekly Event">Weekly Event</li>
    <li value="Monthly Event">Monthly Event</li>
    <li value="Customized Event">Customized Event</li>
</ul>
