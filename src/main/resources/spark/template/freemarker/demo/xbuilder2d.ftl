
<!DOCTYPE html>
<html>
    <head>
        <#include "../header.ftl">
        <#include "../chosen.ftl">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.js"></script>
        <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.css" />
        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/handsontable-pro@latest/dist/handsontable.full.min.css">
        
        <script>
            let expData = {version : "0.0.1"};
            let fields = {};
            let fieldData = {};
            let fieldId;
            let cultivars = {};
            let eventData;        // Data container for current management data
            let events = [];      // Array of event object for current current management data
            let eventId = 1;
            let managements = {}; // Map for all management data (mgnId: mgnData)
            let mgnId;            // Current management ID
            let trtData = [];
            let timeline;
            let tmlContainer;
            let fstTmlFlg = true;
            let spreadsheet;
            let spsContainer;
            let spsOptions;
            let configs = {};
            let configData = {};
            let configId;
            
            function initTimeline() {
                // DOM element where the Timeline will be attached
                tmlContainer = document.getElementById('visualization');

                // Configuration for the Timeline
                let tmlOptions = {
                    stack: true,
    //                start: new Date(),
    //                end: new Date(1000*60*60*24 + (new Date()).valueOf()),
                    editable: true,
                    minHeight: 300,
                    orientation: 'top',     // set date on the top
                    horizontalScroll: true, // default scroll is to move forward/backward on timeline
                    zoomKey: 'ctrlKey',     // use ctrl key + scroll to zoom in/out
                    zoomMin: 2073600000,    // minimum zoom = 1 day
                    itemsAlwaysDraggable: true,
                    groupEditable: true,
                    showCurrentTime: false,
                    onAdd: function(event, callback) {
//                        alert(event.event);
                        if (isValidId(event.id)) {
                            callback(event);
                            timeline.setSelection(event.id);
                        }
                    },
                    onUpdate: function (item, callback) {
                        showEventDataDialog(item, true, true);
                    },
                    onDropObjectOnItem: function(objectData, event, callback) {
                        if (!event) { return; }
                        alert('dropped object with content: "' + objectData.content + '" to event: "' + event.content + '"');
                    }
                };
                
                let startYear = $('#start_year').val();
                if (startYear && !isNaN(startYear)) {
                    tmlOptions.start = new Date(startYear, 0, 1, 0, 0, 0, 0);
                    tmlOptions.end = new Date(startYear, 11, 31, 0, 0, 0, 0);
                }

                // Create a Timeline
                timeline = new vis.Timeline(tmlContainer, eventData, tmlOptions);
                timeline.on("select", function(properties) {
                    let selections = properties.items;
                    for (let i in selections) {
                        if (eventData.get(selections[i]).group !== undefined) {
                            let group = eventData.get(selections[i]).group;
                            let groupEvents = eventData.getIds({
                                filter: function (event) {
                                    return (event.group === group);
                                }
                            });
                            timeline.setSelection(groupEvents);
                            break;
                        }
                    }
                });
                
                timeline.on("mouseDown", function (properties) {
                    timeline.setCurrentTime(properties.time);
    
                    // If the clicked element is not the menu
                    if (!$(properties.event.target).parents(".event-menu").length > 0) {
                        // Hide it
                        $(".event-menu").hide(100);
                    }
                });
                timeline.on("click", function(properties) {
                    if (properties.time) {
                        timeline.setCurrentTime(properties.time);
                    }
                });
                timeline.on("contextmenu", function(props) {
                    props.event.preventDefault();
                    // Show contextmenu
                    $(".event-menu").finish().toggle(100).
                    // In the right position (the mouse)
                    css({
                        top: props.event.pageY + "px",
                        left: props.event.pageX + "px"
                    });
                });

                // If the menu element is clicked
                $(".event-menu li").click(function(){
                    // This is the triggered action name
                    addEvent($(this));
                    // Hide it AFTER the action was triggered
                    $(".event-menu").hide(100);
                });
            }
            
            function initSpreadsheet() {
                events = getEvents();
                spsContainer = document.querySelector('#visualization2');
                spsOptions = {
                    licenseKey: 'non-commercial-and-evaluation',
                    data: events,
                    columns: [
                        {
                            data: 'content',
                            type: 'text'
                        },
                        {
                            data: 'date',
                            type: 'date',
                            dateFormat: 'YYYY-MM-DD'
                        },
                        {
                            data: 'event',
                            type: 'text'
                        }
                    ],
                    stretchH: 'all',
        //                    width: 500,
                    autoWrapRow: true,
        //                    height: 450,
                    minRows: 10,
                    maxRows: 365 * 30,
                    manualRowResize: true,
                    manualColumnResize: true,
                    rowHeaders: true,
                    colHeaders: [
                        'Name',
                        'Date',
                        'Type'
                    ],
                    manualRowMove: true,
                    manualColumnMove: true,
                    contextMenu: true,
                    filters: true,
                    dropdownMenu: true
                };
                spreadsheet = new Handsontable(spsContainer, spsOptions);
            }
            
            function init() {
                initStartYearSB();
                chosen_init_all();
                $('.exp_data').on('change', function() {
                    saveData(expData, this.id, this.value);
                });
                $('.field_data').on('change', function() {
                    saveData(fieldData, this.id, this.value);
                    if (this.id === "fl_name") {
                        $('#' + fieldId).html(this.value);
                    }
                });
                $('.nav-tabs #FieldTab').on('shown.bs.tab', function(){
                    $("#field_create").parent().removeClass("active");
                    $("#" + fieldId).parent().addClass("active");
                });
                $('.nav-tabs #EventTab').on('shown.bs.tab', function(){
                    $("#event_create").parent().removeClass("active");
                    $("#" + mgnId).parent().addClass("active");
                    if (fstTmlFlg) {
                        fstTmlFlg = false;
                        initTimeline();
                        initSpreadsheet();
                    } else {
                        timeline.setItems(eventData);
                        if (events.length === 0) {
                            let startYear = $('#start_year').val();
                            if (startYear && !isNaN(startYear)) {
                                timeline.setWindow(new Date(startYear, 0, 1, 0, 0, 0, 0), new Date(startYear, 11, 31, 0, 0, 0, 0));
                            }
                        } else {
                            timeline.fit();
                        }
                        syncDataToSps();
                    }
                });
                $('.nav-tabs #EventTab').on('hide.bs.tab', function(){
                    syncEventData();
                });
                $('.nav-tabs #ConfigTab').on('shown.bs.tab', function(){
                    $("#config_create").parent().removeClass("active");
                    $("#" + configId).parent().addClass("active");
                    // TODO
                });
                $('.nav-tabs #TreatmentTab').on('shown.bs.tab', function(){
                    // TODO
                    for (let trtid in trtData) {
                        $("#tr_field_" + trtData[trtid].trtno).chosen("destroy");
                        chosen_init("tr_field_" +  + trtData[trtid].trtno);
                        $("#tr_cul_" + trtData[trtid].trtno).chosen("destroy");
                        chosen_init("tr_cul_" +  + trtData[trtid].trtno);
                        $("#tr_mgn_" + trtData[trtid].trtno).chosen("destroy");
                        chosen_init("tr_mgn_" + trtData[trtid].trtno);
                        $("#tr_config_" + trtData[trtid].trtno).chosen("destroy");
                        chosen_init("tr_config_" + trtData[trtid].trtno);
                    }
                });
                $('.nav-tabs #PreviewTab').on('shown.bs.tab', function(){
                    updatePreview();
                });
                
                // Create a DataSet (allows two way data-binding)
                events = [
                  {id: 1, content: 'Fixed event 1', start: '04/11/2013', event: 'planting', cul_id:'DRI319', editable: false},
                  {id: 2, content: 'Weekly event 1.1', start: '04/12/2013', event: 'irrigation', group:"ga"},
                  {id: 3, content: 'Weekly event 1.2', start: '04/19/2013', event: 'irrigation', group:"ga"},
                  {id: 4, content: 'Daily event 4', start: '04/15/2013', end: '04/19/2013', event: 'fertilizer'},
                  {id: 5, content: 'Weekly event 1.3', start: '04/26/2013', event: 'irrigation', group:"ga"},
                  {id: 6, content: 'Weekly event 1.4', start: '05/03/2013', event: 'irrigation', group:"ga"}
                ];
                eventId = 7;
                eventData = new vis.DataSet(events);
                managements["mgn_0"] = createMgnData("Default", events);
                eventData = managements["mgn_0"].tmlData;
//                managements["mgn_1"] = createMgnData("N150", []);
//                managements["mgn_2"] = createMgnData("N200", []);
//                managements["mgn_3"] = createMgnData("N250", []);
//                managements["mgn_4"] = createMgnData("I-subsurface", []);
//                managements["mgn_5"] = createMgnData("I-surface", []);
//                managements["mgn_6"] = createMgnData("I-fixed", []);
//                trtData.push({trtno:1});
                configData = {};
                configId = "config_0";
                configs[configId] = {config_name: "Default", data: configData};
            }
            
            function initStartYearSB() {
                let startYearSB = $('#start_year');
                for (let i = 51; i <= 99; i++) {
                    let option = document.createElement('option');
                    option.innerHTML = "19" + i;
                    option.value = "19" + i;
                    startYearSB.append(option);
                }
                for (let i = 0; i <= 9; i++) {
                    let option = document.createElement('option');
                    option.innerHTML = "200" + i;
                    option.value = "200" + i;
                    startYearSB.append(option);
                }
                for (let i = 10; i <= 50; i++) {
                    let option = document.createElement('option');
                    option.innerHTML = "20" + i;
                    option.value = "20" + i;
                    startYearSB.append(option);
                }
            }
    
            function getNewCollectionNum(collection) {
                let ret = -1;
                for (let key in collection) {
                    let keyNum = getNum(key);
                    if (ret < keyNum) {
                        ret = keyNum;
                    }
                }
                return ret + 1;
            }

            function getNum(idStr) {
                if (!idStr) {
                    return 0;
                }
                let strs = idStr.split("_");
                if (strs.length > 1) {
                    return Number(strs[1]);
                } else {
                    return 0;
                }
            }
            
            function saveData(target, id, val) {
                if (Array.isArray(val)) {
                    if (val.length > 0) {
                        target[id] = val;
                    } else {
                        delete target[id];
                    }
                } else {
                    if (val && val.trim()) {
                        target[id] = val.trim();
                    } else if (target[id]) {
                        delete target[id];
                    }
                }
                
            }
            
            function saveFile() {
                if (!$("#PreviewTab").hasClass("active")) {
                    $("#PreviewTab a").click();
                    bootbox.alert({
                        message: "Please review the result before saving the file",
                        backdrop: true
                    });
                } else {
                    let text, ext;
                    if ($("#json_swc_btn").hasClass("btn-primary")) {
                        text = getFinalJson();
                        ext = expData.crid_dssat + ".json";
                        
                    } else {
                        text = $('#dssat_preview_text').html();
                        ext = expData.crid_dssat + "X";
                        if (text === "Loading...") {
                            bootbox.alert({
                                message: "Please wait for preview content shown up...",
                                backdrop: true
                            });
                            return;
                        }
                    }
                    let blob = new Blob([text], {type: "text/plain;charset=utf-8"});
                    saveAs(blob, expData.exname + "." + ext);
                }
            }
            
            function openFile() {
                // TODO
                alert("[TODO] will show a dialog later to load an existing XFile!");
            }
        </script>
    </head>

    <body>

        <#include "../nav.ftl">

        <div class="container-fluid primary-container">
            <ul class="nav nav-tabs">
                <li id="SiteInfoTab" class="active">
                    <a data-toggle="tab" href="#SiteInfo"><span class="glyphicon glyphicon-list-alt"></span> General</a>
                </li>
                <li id="FieldTab" class="dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                        <span class="glyphicon glyphicon-link"></span>
                        Field
                        <span class="badge" id="field_badge">0</span>
                        <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu" id="field_list">
                        <li><a data-toggle="tab" href="#Field" class="create-link" id="field_create" onclick="createField();">Create new...</a></li>
                    </ul>
                <li id="EventTab" class="dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                        <span class="glyphicon glyphicon-calendar"></span>
                        Management
                        <span class="badge" id="mgn_badge">1</span>
                        <span class="caret"></span>
                    </a>
                    
                    <ul class="dropdown-menu" id="mgn_list">
                        <li><a data-toggle="tab" href="#Event" class="create-link" id="mgn_create" onclick="createManagement();">Create new...</a></li>
                        <li><a data-toggle="tab" href="#Event" id="mgn_0" onclick="setManagement(this);">Default</a></li>
<!--                        <li><a data-toggle="tab" href="#Event" id="mgn_1" onclick="setManagement(this);">N-150</a></li>
                        <li><a data-toggle="tab" href="#Event" id="mgn_2" onclick="setManagement(this);">N-200</a></li>
                        <li><a data-toggle="tab" href="#Event" id="mgn_3" onclick="setManagement(this);">N-250</a></li>
                        <li><a data-toggle="tab" href="#Event" id="mgn_4" onclick="setManagement(this);">I-subsurface</a></li>
                        <li><a data-toggle="tab" href="#Event" id="mgn_5" onclick="setManagement(this);">I-surface</a></li>
                        <li><a data-toggle="tab" href="#Event" id="mgn_6" onclick="setManagement(this);">I-fixed</a></li>-->
                    </ul>
                </li>
                <li id="ConfigTab" class="dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                        <span class="glyphicon glyphicon-calendar"></span>
                        Configurations
                        <span class="badge" id="config_badge">0</span>
                        <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu">
                        <li><a data-toggle="tab" href="#Config" class="create-link" id="config_create">Create new...</a></li>
                    </ul>
                </li>
                <li id="TreatmentTab">
                    <a data-toggle="tab" href="#Treatment"><span class="glyphicon glyphicon-link"></span> Treatments <span class="badge" id="treatment_badge">0</span></a>
                </li>
                <li id="PreviewTab">
                    <a data-toggle="tab" href="#Preview"><span class="glyphicon glyphicon-list-alt"></span> Preview</a>
                </li>
                
                <li id="SaveTabBtn" class="tabbtns" onclick="saveFile()"><a href="#"><span class="glyphicon glyphicon-save"></span> Save</a></li>
                <li id="OpenTabBtn" class="tabbtns" onclick="openFile()"><a href="#"><span class="glyphicon glyphicon-open"></span> Load</a></li>
            </ul>
            <div class="tab-content">
                <div id="SiteInfo" class="tab-pane fade in active">
                    <#include "xbuilder2d_general.ftl">
                </div>
                <div id="Field" class="tab-pane fade">
                    <#include "xbuilder2d_field.ftl">
                </div>
                <div id="Event" class="tab-pane fade">
                    <#include "xbuilder2d_event.ftl">
                    <#include "xbuilder2d_event_popup.ftl">
                </div>
                <div id="Config" class="tab-pane fade">
                    <div class="subcontainer"><center>
                        Under construction
                    </center></div>
                </div>
                <div id="Treatment" class="tab-pane fade">
                    <#include "xbuilder2d_treatment.ftl">
                </div>
                <div id="Preview" class="tab-pane fade">
                    <#include "xbuilder2d_preview.ftl">
                </div>
            </div>
        </div>

        <#include "../footer.ftl">
        <script type="text/javascript" src='/plugins/FileSaver/FileSaver.js'></script>
        <script type="text/javascript" src="/js/util/dateUtil.js" charset="utf-8"></script>
        <script type="text/javascript" src="/plugins/chosen/chosen.jquery.min.js" ></script>
        <script type="text/javascript" src="/plugins/chosen/prism.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/chosen/init.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/bootbox/bootbox.all.min.js" charset="utf-8"></script>
        <script src="https://cdn.jsdelivr.net/npm/handsontable@6.2.2/dist/handsontable.full.min.js"></script>
        <script type="text/javascript">
            $(document).ready(function () {
                init();
            });
        </script>
    </body>
</html>
