
<!DOCTYPE html>
<html>
    <head>
        <#include "../header.ftl">
        <#include "../chosen.ftl">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.js"></script>
        <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.css" />
        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/handsontable-pro@latest/dist/handsontable.full.min.css">
        
        <script>
            let expData = {};
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
                    showCurrentTime: true,
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
                    // If the clicked element is not the menu
                    if (!$(properties.event.target).parents(".event-menu").length > 0) {
                        // Hide it
                        $(".event-menu").hide(100);
                    }
                });
                timeline.on("mouseMove", function (properties) {
                    let date = new Date(properties.time.getFullYear(), properties.time.getMonth(), properties.time.getDate(), 0, 0, 0, 0);
//                    if (Math.abs(timeline.getCurrentTime() - date) < (24 * 3600 * 1000)) {
//                       return; 
//                    }
                    timeline.setCurrentTime(date);
                    $('.date_label').html(dateUtil.toYYYYMMDDStr(date)).finish().fadeIn(100).css({
//                        top: properties.event.pageY + "px",
                        left: properties.event.pageX + "px"
                    });
                });
                timeline.on("click", function(properties) {
                    if (properties.time) {
                        timeline.setCurrentTime(properties.time);
                    }
                });
                timeline.on("contextmenu", function(properties) {
                    properties.event.preventDefault();
                    // Show contextmenu
                    $(".event-menu").finish().toggle(100).
                    // In the right position (the mouse)
                    css({
                        top: properties.event.pageY + "px",
                        left: properties.event.pageX + "px"
                    });
                });

                // If the menu element is clicked
                $(".event-menu li").click(function(){
                    // This is the triggered action name
                    addEvent($(this));
                    // Hide it AFTER the action was triggered
                    $(".event-menu").hide(100);
                    $('.date_label').hide(100);
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
            
            function reset() {
                initStartYearSB();
                chosen_init_all();
            }
            
            function init() {
                reset();
                $('.exp_data').on('change', function() {
                    saveData(expData, this.id, this.value);
                });
                $('.field_data').on('change', function() {
                    saveData(fieldData, this.id, this.value);
                    if (this.id === "fl_name") {
                        $('#' + fieldId).html(this.value);
                        for (let i in trtData) {
                            $('#tr_field_' + trtData[i].trtno).children('option[value=' + fieldId + ']').html(this.value);
                        }
                    }
                });
                $('.max-2').on('input', function() {
                    limitLength(this, 2);
                });
                $('.max-4').on('input', function() {
                    limitLength(this, 4);
                });
                $('.max-5').on('input', function() {
                    limitLength(this, 5);
                });
                $('.max-8').on('input', function() {
                    limitLength(this, 8);
                });
                $('.max-10').on('input', function() {
                    limitLength(this, 10);
                });
                $('.mgn_data').on('change', function() {
                    saveData(managements[mgnId], this.id, this.value);
                    if (this.id === "mgn_name") {
                        $('#' + mgnId).html(this.value);
                        for (let i in trtData) {
                            $('#tr_mgn_' + trtData[i].trtno).children('option[value=' + mgnId + ']').html(this.value);
                        }
                    }
                });
                $('.nav-tabs #SiteInfoTab').on('shown.bs.tab', function(){
                    chosen_init("start_year");
                    chosen_init("crid");
                });
                $('.nav-tabs #FieldTab').on('shown.bs.tab', function(){
                    $("#field_create").parent().removeClass("active");
                    $("#" + fieldId).parent().addClass("active");
                });
                $('.nav-tabs #EventTab').on('shown.bs.tab', function(){
                    $("#mgn_create").parent().removeClass("active");
                    $("#" + mgnId).parent().addClass("active");
                    if (fstTmlFlg) {
                        fstTmlFlg = false;
                        initTimeline();
                        initSpreadsheet();
                        if (events.length !== 0) {
                            timeline.fit();
                        }
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
                    for (let trtid in trtData) {
                        chosen_init("tr_field_" +  + trtData[trtid].trtno);
                        chosen_init("tr_cul_" +  + trtData[trtid].trtno);
                        chosen_init("tr_mgn_" + trtData[trtid].trtno);
                        chosen_init("tr_config_" + trtData[trtid].trtno);
                    }
                });
                $('.nav-tabs #PreviewTab').on('shown.bs.tab', function(){
                    updatePreview();
                });
            }
            
            function limitLength(target, maxLength) {
                if (target.value.toString().length > maxLength) {
                    let value = Number(target.value);
                    if (isNaN(value)) {
                        target.value = target.value.toString().substring(0, maxLength);
                    } else {
                        let intNum = value.toFixed(0);
                        let decBit = maxLength - intNum.length - 1;
                        if (decBit > 0) {
                            target.value = value.toFixed(decBit);
                        } else {
                            target.value = intNum.substring(0, maxLength);
                        }
                    }
                }
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
                        ext = expData.crid_dssat + "J";
                        
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
                $('<input type="file" accept=".json, .??J" onchange="readFile(this);">').click();
            }
            
            function readFile(target) {
                let files = target.files;
                if (files.length < 1) {
                    return;
                }
                for (let i=0; i<files.length; i++) {
                    readFileToBufferedArray(files[i], updateProgress, loadData);
                }
            }
            
            function updateProgress() {
                // TODO
            }
            
            function loadData(rawData) {
                rawData = JSON.parse(rawData);
                
                // Load meta data
                expData = rawData.experiment;
                $('.exp_data').each(function() {
                    $(this).val(expData[$(this).attr("id")]);
                });
                updateExname();
                
                // Load cultivars
                cultivars = rawData.cultivar;
                
                // Load fields
                for (let id in fields) {
                    removeField(id);
                }
                for (let id in rawData.field) {
                    createField(id, rawData.field[id]);
                }
                
                // Load managements
                for (let id in managements) {
                    removeManagement(id);
                }
                for (let id in rawData.management) {
                    createManagement(id, rawData.management[id]);
                }
                
                // Load configs
                // TODO
                configs = {};
                configData = {};
                configId;
                
                // Load treatments
                for (let id = trtData.length; id > 0 ; id--) {
                    removeTrt(Number(id));
                }
                for (let id in rawData.treatment) {
                    addTrt(Number(id) + 1, rawData.treatment[id]);
                }
                
                reset();
                $("#SiteInfoTab a").click();
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
                        <span class="badge" id="mgn_badge">0</span>
                        <span class="caret"></span>
                    </a>
                    
                    <ul class="dropdown-menu" id="mgn_list">
                        <li><a data-toggle="tab" href="#Event" class="create-link" id="mgn_create" onclick="createManagement();">Create new...</a></li>
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
        <script type="text/javascript" src="/js/dataReader/BufferedFileReader.js"></script>
        <script type="text/javascript" src="/js/bootbox/bootbox.all.min.js" charset="utf-8"></script>
        <script src="https://cdn.jsdelivr.net/npm/handsontable@6.2.2/dist/handsontable.full.min.js"></script>
        <script type="text/javascript">
            $(document).ready(function () {
                init();
            });
        </script>
    </body>
</html>
