<script>
    function addEventConfig() {
        alert("A tab will be created for the new operation group!");
    }
</script>
<div class="tab">
    <button type="button" class="tablinks event active" onclick="openTab('default', 'event')" id= "defaultTab"><span class="glyphicon glyphicon-grain"></span> Default</button>
    <button type="button" class="btn tabaddbtns" onclick="addEventConfig()" id = "AddEventConfigBtn"><span class="glyphicon glyphicon-plus"></span></button>
</div>
<div id="default" class="tabcontent event">
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
    <div id="visualization"></div>
    <br/>
</div>
<ul class='event-menu'>
    <li value="One-time Event">One-time Event</li>
    <li value="Weekly Event">Weekly Event</li>
    <li value="Monthly Event">Monthly Event</li>
    <li value="Customized Event">Customized Event</li>
</ul>
