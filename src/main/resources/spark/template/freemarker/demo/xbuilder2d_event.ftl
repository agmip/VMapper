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
            if (events.length > 0) {
                eventId = Number(events[events.length - 1].id) + 1;
            } else {
                eventId = 1;
            }
        } else {
            let num = getNewCollectionNum(managements);
            mgnId = "mgn_" + num;
            description = "New Management " + (num + 1);
            events = [];
            eventId = 1;
        }
        subEvents = [];
        managements[mgnId] = createMgnData(description, events);
        eventData = managements[mgnId].tmlData;
        $('#mgn_list').append('<li><a data-toggle="tab" href="#Event" id="' + mgnId + '" onclick="setManagement(this);">' + description + '</a></li>');
        $('#mgn_name').val(description);
        for (let i in trtData) {
            $('#tr_mgn_' + trtData[i].trtno).append('<option value="' + mgnId + '">' + description + '</option>');
        }
        $('#mgn_badge').html(Object.keys(managements).length);
    }

    function replicateManagement(rawData) {
        let num = getNewCollectionNum(managements);
        let id = "mgn_" + num;
        if (!rawData) {
            rawData = {
                mgn_name: managements[mgnId].mgn_name + " Copy",
                data: JSON.parse(JSON.stringify(getEvents()))
            };
        }
        createManagement(id, rawData);
        $("#" + id).click();
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
        return !isNaN(id);
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
            let tmp = eventData.get(selections[0]);
            if (value || (tmp && tmp[name])) {
                let updData = {id: selections[0]};
                updData[name] = value;
                eventData.update(updData);
            }
        }
    }

    function editAllEvent(eventType, name, value) {
        let selections = eventData.get({
            fields: ['id'],
            filter: function (item) {
                return (item.event === eventType);
            }
        });
        if (selections.length > 0) {
            selections.forEach(function(updData) {
                updData[name] = value;
            });
            eventData.update(selections);
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

    function dragStart(ev) {
        let event = {id: newId(), content: defaultContent(ev.target), event:defaultEvent(ev.target)}; 
        ev.dataTransfer.setData("text", JSON.stringify(event));
    }
    
    function dragging(ev) {
//        timeline.trigger('mouseMove', ev);
//        console.log("moving at" + ev.pageX + ", " + ev.pageY);
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
                    initSpreadsheet();
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
    
    function getSubEvents(eventType) {
        let arr;
        if (eventType && eventType !== "all") {
            arr = eventData.get({
                filter: function (item) {
                    return (item.event === eventType);
                }
            });
        } else {
            events = getEvents();
            return events;
        }
        arr.forEach(function (data) {
            data.date = dateUtil.toYYYYMMDDStr(data.start);
            icasaToText(data);
        });
        return arr;
    }
    
    function mergeSubEvents() {
        if (subEvents.length > 0) {
            let eventType = $('#sps_tabs').children('.active').children('a').text().trim().toLowerCase();
            
            if (eventType === "all") {
                return;
            }
            
            // remove deleted events
            let delIdx = [];
            for (let i in events) {
                if (events[i].event !== eventType) {
                    continue;
                }
                let flg = true;
                for (let j in subEvents) {
                    if (subEvents[j].id && subEvents[j].id === events[i].id) {
                        flg = false;
                        break;
                    }
                }
                if (flg) {
                    delIdx.push(i);
                }
            }
            for (let i in delIdx) {
                events.splice(delIdx[i], 1);
            }
            
            // add new created events
            subEvents.forEach(function (data) {
                icasaToCode(data);
                if (!data.event) {
                    data.event = eventType;
                }
                let updIdx;
                if (data.id) {
                    for (let i in events) {
                        if (data.id === events[i].id) {
                            updIdx = i;
                            break;
                        }
                    }
                } else {
                    data.id = newId();
                }
                if (updIdx) {
                    events[updIdx] = data;
                } else {
                    events.push(data);
                }
            });
            
            // clear subEvent list
            subEvents = [];
        }
    }
    
    function icasaToText(item) {
        for (let key in item) {
            if (icasaCode[key]) {
                item[key + "_text"] = icasaCode[key][item[key]];
            }
        }
    }
    
    function icasaToCode(item) {
        for (let key in item) {
            if (key.endsWith("_text")) {
                let codeKey = key.replace("_text", "");
                let text = item[key];
                if (icasaText[codeKey]) {
                    item[codeKey] = icasaText[codeKey][text];
                    delete item[key];
                }
            }
        }
    }

    function syncDataToSps(eventType) {
        syncDataToTml();
        initSpreadsheet(eventType);
    }

    function syncDataToTml() {
        mergeSubEvents();
        clearNullElements(events, ["event", "content", "date"]);
        for (let i = 0; i < events.length; i++) {
            events[i].start = dateUtil.toLocaleStr(events[i].date);
        }
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
        if (eventData.length !== 0) {
            timeline.fit();
        }
    }
    
    function clearNullElements(array, ids) {
        let x = -1, y = 0;
        let flg;
        for (let i = 0; i < array.length; i++) {
            flg = true;
            for (let j = 0; j < ids.length; j++) {
                if (!array[i][ids[j]] || array[i][ids[j]].toString().trim() === "") {
                    y++;
                    flg = false;
                    break;
                }
            }
            if (flg) {
                if (y > 0) {
                    array.splice(x + 1, y);
                    i -= y;
                    y = 0;
                }
                x = i;
            }
        }
        array.splice(x + 1, y);
        
        for (let i = 0; i < array.length; i++) {
            for (let key in array[i]) {
                if (!array[i][key] || array[i][key] === "") {
                    delete array[i][key];
                }
            }
        }
    }
</script>
<div class="subcontainer">
    <fieldset>
        <legend>
            Management Information&nbsp;&nbsp;&nbsp;
            <a href="#"><span id="mgn_replicate_btn" type="button" class="btn glyphicon glyphicon-duplicate" onclick="replicateManagement();"></span></a>
            <a href="#"><span id="mgn_remove_btn" type="button" class="btn glyphicon glyphicon-trash" onclick="removeManagement();"></span></a>
        </legend>
        <div class="row col-sm-12">
            <div class="form-group has-feedback col-sm-4">
                <label class="control-label" for="mgn_name">Management Name *</label>
                <div class="input-group col-sm-12">
                    <input type="text" id="mgn_name" name="mgn_name" class="form-control mgn-data" value="Default" required >
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
                <button draggable="true" ondragstart="dragStart(event);" ondrag="dragging(event);" ondblclick="addEvent(this);" class="btn btn-primary" value="Planting Event"><span class="glyphicon glyphicon-menu-hamburger"></span> Planting Event</button>
                <button draggable="true" ondragstart="dragStart(event);" ondrag="dragging(event);" ondblclick="addEvent(this);" class="btn btn-primary" value="Irrigation Event"><span class="glyphicon glyphicon-menu-hamburger"></span> Irrigation Event</button>
                <button draggable="true" ondragstart="dragStart(event);" ondrag="dragging(event);" ondblclick="addEvent(this);" class="btn btn-primary" value="Fertilizer Event"><span class="glyphicon glyphicon-menu-hamburger"></span> Fertilizer Event</button>
                <button draggable="true" ondragstart="dragStart(event);" ondrag="dragging(event);" ondblclick="addEvent(this);" class="btn btn-primary" value="Harvest Event"><span class="glyphicon glyphicon-menu-hamburger"></span> Harvest Event</button>

<!--                <div class="dropdown">
                    <button class="btn btn-primary dropdown-toggle" type="button" data-toggle="dropdown">Add Event...<span class="caret"></span></button>
                    <ul class="dropdown-menu">
                        <li draggable="true" ondragstart="dragStart(event);" ondrag="dragging(event); ondblclick="addEvent(this);" value="Planting Event"><a href="#"><span class="glyphicon glyphicon-menu-hamburger"></span> Planting Event</a></li>
                        <li draggable="true" ondragstart="dragStart(event);" ondrag="dragging(event); ondblclick="addEvent(this);" value="Irrigation Event"><a href="#"><span class="glyphicon glyphicon-menu-hamburger"></span> Irrigation Event</a></li>
                        <li draggable="true" ondragstart="dragStart(event);" ondrag="dragging(event); ondblclick="addEvent(this);" value="Fertilizer Event"><a href="#"><span class="glyphicon glyphicon-menu-hamburger"></span> Fertilizer Event</a></li>
                        <li draggable="true" ondragstart="dragStart(event);" ondrag="dragging(event); ondblclick="addEvent(this);" value="Harvest Event"><a href="#"><span class="glyphicon glyphicon-menu-hamburger"></span> Harvest Event</a></li>
                        
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
        <ul class="nav nav-pills" id="sps_tabs">
            <li class="active"><a data-toggle="pill" href="#All" onclick="syncDataToSps('all');">&nbsp;&nbsp;&nbsp;All&nbsp;&nbsp;&nbsp;</a></li>
            <li><a data-toggle="pill" href="#Planting" onclick="syncDataToSps('planting');">Planting</a></li>
            <li><a data-toggle="pill" href="#Irrigation" onclick="syncDataToSps('irrigation');">Irrigation</a></li>
            <li><a data-toggle="pill" href="#Fertilizer" onclick="syncDataToSps('fertilizer');">Fertilizer</a></li>
            <li><a data-toggle="pill" href="#Harvest" onclick="syncDataToSps('harvest');">Harvest</a></li>
        </ul>
        <div id="visualization2" class="col-sm-12"></div>
    </div>
</div>
