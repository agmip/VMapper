<script>
    function createMgnData(name, events) {
        let tmlData = new vis.DataSet(events);
//        tmlData.on('*', function (event, properties, senderId) {
//            console.log('event:', event, 'properties:', properties, 'senderId:', senderId);
//        });
        tmlData.on('add', function(event, properties, senderId) {
//            console.log('event:', event, 'properties:', properties, 'senderId:', senderId);
            if (properties.items && properties.items.length === 1) {
                let itemData = eventData.get(properties.items);
                if (!itemData[0].creator) {
                    showEventTypePrompt(properties.items[0]);
                } else {
                    delete itemData[0].creator;
                }
            } else if (properties.items) {
                let itemData = eventData.get(properties.items);
                for (let i = 0; i < itemData.length; i++) {
                    delete itemData[i].creator;
                }
            }
        });
        return {mgn_name: name, data: events, tmlData: tmlData};
    }

    function createManagement(id, rawData) {
        let description;
        if (id && rawData) {
            mgnId = id ;
            events = rawData.data;
            description = rawData.mgn_name;
        } else {
            let num = getNewCollectionNum(managements);
            mgnId = "mgn_" + num;
            description = "New Management " + (num + 1);
            events = [];
            eventId = 1;
        }
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
//        syncEventData();
        events = managements[target.id].data;
        eventData = managements[target.id].tmlData;
        mgnId = target.id;
        $('#mgn_name').val(managements[target.id]['mgn_name']);
    }
    
    function removeManagement(id) {
        if (id) {
            mgnId = id;
        }
        delete managements[mgnId];
        $('#mgn_list li a[id="' + mgnId + '"]').remove();
        for (let i in trtData) {
            $('#tr_mgn_' + trtData[i].trtno + ' option[value="' + mgnId + '"]').remove();
        }
        let mgnIds = Object.keys(managements);
        $('#mgn_badge').html(mgnIds.length);
        for (let i in trtData) {
            $('#tr_mgn_' + trtData[i].trtno).trigger("change");
        }
        if (!id) {
            if (mgnIds.length > 0) {
                $("#" + mgnIds[0]).click();
            } else {
                $("#SiteInfoTab a").click();
            }
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
        if (events.length === 0) {
            eventId = 1;
        } else {
            eventId = Number(events[events.length - 1].id) + 1;
        }
    }
    
    function test() {
        timeline.setSelection(["b", "c"]);
    }

    function newId() {
        return eventId++;
    }
    
    function isValidId(id) {
        return id.startsWith("new");
    }

    function defaultContent(target) {
        if (target.value !== undefined) {
            return 'New ' + target.value;
        } else {
            return 'New ' + target[0].textContent;
        }
    }

    function defaultEvent(target) {
        if (target.value !== undefined) {
            return target.value.replace(" Event", "").toLowerCase();
        } else {
            return target[0].textContent.replace(" Event", "").toLowerCase();
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
        let event = {id: newId(), content: defaultContent(target), start: defaultDate(), event:defaultEvent(target)}; 
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
        let event = {id: newId(), content: defaultContent(ev.target), event:defaultEvent(ev.target)}; 
        ev.dataTransfer.setData("text", JSON.stringify(event));
        timeline.setSelection(event.id);
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
            data.date = dateUtil.toYYYYMMDDStr(data.start);
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
            if (!events[i].event || events[i].event.trim() === "" ||
                    !events[i].content || events[i].content.trim() === "" ||
                    !events[i].date || events[i].date.trim() === "") {
                y++;
            } else  {
                if (y > 0) {
                    events.splice(x + 1, y);
                    i -= y;
                    y = 0;
                }
                x = i;
                events[i].start = dateUtil.toLocaleStr(events[i].date);
            }
        }
        events.splice(x + 1, y);
        for (let i = 0; i < events.length; i++) {
            if (!events[i].id) {
                events[i].id = newId();
                events[i].creator = "sps";
            }
        }
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
        <legend>
            Management Information&nbsp;&nbsp;&nbsp;
            <a href="#"><span id="mgn_remove_btn" type="button" class="btn glyphicon glyphicon-trash" onclick="removeManagement();"></span></a>
        </legend>
        <div class="row col-sm-12">
            <div class="form-group has-feedback col-sm-4">
                <label class="control-label" for="mgn_name">Management Name *</label>
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
                <button draggable="true" ondragstart="drag(event);" ondblclick="addEvent(this);" class="btn btn-primary" value="Planting Event"><span class="glyphicon glyphicon-menu-hamburger"></span> Planting Event</button>
                <button draggable="true" ondragstart="drag(event);" ondblclick="addEvent(this);" class="btn btn-primary" value="Irrigation Event"><span class="glyphicon glyphicon-menu-hamburger"></span> Irrigation Event</button>
                <button draggable="true" ondragstart="drag(event);" ondblclick="addEvent(this);" class="btn btn-primary" value="Fertilizer Event"><span class="glyphicon glyphicon-menu-hamburger"></span> Fertilizer Event</button>
                <button draggable="true" ondragstart="drag(event);" ondblclick="addEvent(this);" class="btn btn-primary" value="Harvest Event"><span class="glyphicon glyphicon-menu-hamburger"></span> Harvest Event</button>

<!--                <div class="dropdown">
                    <button class="btn btn-primary dropdown-toggle" type="button" data-toggle="dropdown">Add Event...<span class="caret"></span></button>
                    <ul class="dropdown-menu">
                        <li draggable="true" ondragstart="drag(event);" ondblclick="addEvent(this);" value="Planting Event"><a href="#"><span class="glyphicon glyphicon-menu-hamburger"></span> Planting Event</a></li>
                        <li draggable="true" ondragstart="drag(event);" ondblclick="addEvent(this);" value="Irrigation Event"><a href="#"><span class="glyphicon glyphicon-menu-hamburger"></span> Irrigation Event</a></li>
                        <li draggable="true" ondragstart="drag(event);" ondblclick="addEvent(this);" value="Fertilizer Event"><a href="#"><span class="glyphicon glyphicon-menu-hamburger"></span> Fertilizer Event</a></li>
                        <li draggable="true" ondragstart="drag(event);" ondblclick="addEvent(this);" value="Harvest Event"><a href="#"><span class="glyphicon glyphicon-menu-hamburger"></span> Harvest Event</a></li>
                        
                    </ul>
                </div>-->
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
        <ul class="nav nav-pills">
            <li class="active"><a data-toggle="pill" href="#All">&nbsp;&nbsp;&nbsp;All&nbsp;&nbsp;&nbsp;</a></li>
            <li><a data-toggle="pill" href="#Planting" onclick="alert('under construction...');">Planting</a></li>
            <li><a data-toggle="pill" href="#Irrigation" onclick="alert('under construction...');">Irrigation</a></li>
            <li><a data-toggle="pill" href="#Fertilizer" onclick="alert('under construction...');">Fertilizer</a></li>
            <li><a data-toggle="pill" href="#Harvest" onclick="alert('under construction...');">Harvest</a></li>
        </ul>
        <div id="visualization2" class="col-sm-12"></div>
    </div>
</div>
