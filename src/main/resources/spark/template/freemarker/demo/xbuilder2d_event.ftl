<script>
    function addEventConfig() {
        alert("A tab will be created for the new operation group!");
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
            <button class="btn btn-success" onclick="addEvent()">Add</button>
            <!--<button class="btn btn-success" onclick="editEvent()">Edit</button>-->
            <!--<button class="btn btn-success" onclick="removeEvent()">Remove</button>-->
            <button class="btn btn-success" onclick="removeEvents()">Clear</button>
        </div>
    </div>
    <br/>
    <div class=""><div id="visualization"></div></div>
</div>
<ul class='event-menu'>
    <li value="One-time Event">One-time Event</li>
    <li value="Weekly Event">Weekly Event</li>
    <li value="Monthly Event">Monthly Event</li>
    <li value="Customized Event">Customized Event</li>
</ul>
