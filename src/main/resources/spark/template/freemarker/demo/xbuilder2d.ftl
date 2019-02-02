
<!DOCTYPE html>
<html>
    <head>
        <#include "../header.ftl">
        <#include "../chosen.ftl">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.js"></script>
        <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.css" />
        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/handsontable-pro@latest/dist/handsontable.full.min.css">
        
        <script>
            let eventData;
            let events;
            let timeline;
            let tmlContainer;
            let fstTmlFlg = true;
            let spreadsheet;
            let spsContainer;
            let spsOptions;
            let fstSpsFlg = true;
            
            function initTimeline() {
                // DOM element where the Timeline will be attached
                tmlContainer = document.getElementById('visualization');

                // Create a DataSet (allows two way data-binding)
                events = [
                  {id: "a", content: 'Fixed event 1', start: '04/20/2013', editable: false},
                  {id: "b", content: 'Weekly event 1.1', start: '04/12/2013', group:"ga"},
                  {id: "c", content: 'Weekly event 1.2', start: '04/19/2013', group:"ga"},
                  {id: "d", content: 'Daily event 4', start: '04/15/2013', end: '04/19/2013'},
                  {id: "e", content: 'Weekly event 1.3', start: '04/26/2013', group:"ga"},
                  {id: "f", content: 'Weekly event 1.4', start: '05/03/2013', group:"ga"}
                ];
                eventData = new vis.DataSet(events);
    //            eventData.on('*', function (event, properties, senderId) {
    //                console.log('event:', event, 'properties:', properties, 'senderId:', senderId);
    //            });
    //            eventData.on('add', function(event, properties, senderId) {
    //                timeline.setSelection(properties.items);
    //            });

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
                        callback(event);
                        timeline.setSelection(event.id);
                    },
                    onDropObjectOnItem: function(objectData, event, callback) {
                        if (!event) { return; }
                        alert('dropped object with content: "' + objectData.content + '" to event: "' + event.content + '"');
                    }
                };

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
                    timeline.setCurrentTime(properties.time);
                });
                timeline.on("contextmenu", function(props) {
                    props.event.preventDefault();
                    // Show contextmenu
                    $(".event-menu").finish().toggle(100).
                    // In the right position (the mouse)
                    css({
                        top: event.pageY + "px",
                        left: event.pageX + "px"
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
                events = getEvents()
                spsContainer = document.querySelector('#visualization2');
                spsOptions = {
                    data: events,
                    columns: [
                        {
                            data: 'content',
                            type: 'text'
                        },
                        {
                            data: 'start',
                            type: 'date',
                            dateFormat: 'MM/DD/YYYY'
                        },
                        {
                            data: 'type',
                            type: 'text'
                        },
                        {
                            data: 'group',
                            type: 'text'
                        },
                        {
                            data: 'key',
                            type: 'text'
                        },
                        {
                            data: 'value',
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
                        'Type',
                        'Group',
                        'Key',
                        'Value'
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
                chosen_init_all();
                $('.nav-tabs #EventTab').on('shown.bs.tab', function(){
                    if (fstTmlFlg) {
                        fstTmlFlg = false;
                        initTimeline();
                    }
                });
                $('.nav-tabs #EventTab').on('hide.bs.tab', function(){
                    // TODO will sync the tml and sps
                });
                $('.nav-tabs #TreatmentTab').on('shown.bs.tab', function(){
                    // TODO
                    $("#tr_field_1").chosen("destroy");
                    chosen_init("tr_field_1");
                    $("#tr_management_1").chosen("destroy");
                    chosen_init("tr_management_1");
                    $("#tr_config_1").chosen("destroy");
                    chosen_init("tr_config_1");
                    $("#tr_field_2").chosen("destroy");
                    chosen_init("tr_field_2");
                    $("#tr_management_2").chosen("destroy");
                    chosen_init("tr_management_2");
                    $("#tr_config_2").chosen("destroy");
                    chosen_init("tr_config_2");
                });
            }
            
            function saveFile() {
                // TODO
                alert("[TODO] will save a XFile for you later!");
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
                <li id="TreatmentTab">
                    <a data-toggle="tab" href="#Treatment"><span class="glyphicon glyphicon-link"></span> Treatments <span class="badge" id="treatment_badge">2</span></a>
                </li>
                <li id="FieldTab" class="dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                        <span class="glyphicon glyphicon-link"></span>
                        Field
                        <span class="badge" id="field_badge">0</span>
                        <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu">
                        <li><a data-toggle="tab" href="#Field" class="create-link" id="field_create">Create new...</a></li>
                    </ul>
                <li id="EventTab" class="dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                        <span class="glyphicon glyphicon-calendar"></span>
                        Management
                        <span class="badge" id="management_badge">7</span>
                        <span class="caret"></span>
                    </a>
                    
                    <ul class="dropdown-menu">
                        <li><a data-toggle="tab" href="#Event" class="create-link" id="management_create">Create new...</a></li>
                        <li><a data-toggle="tab" href="#Event">Default</a></li>
                        <li><a data-toggle="tab" href="#Event">N-150</a></li>
                        <li><a data-toggle="tab" href="#Event">N-200</a></li>
                        <li><a data-toggle="tab" href="#Event">N-250</a></li>
                        <li><a data-toggle="tab" href="#Event">I-subsurface</a></li>
                        <li><a data-toggle="tab" href="#Event">I-surface</a></li>
                        <li><a data-toggle="tab" href="#Event">I-fixed</a></li>
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
                
                <li id="SaveTabBtn" class="tabbtns" onclick="saveFile()"><a href="#"><span class="glyphicon glyphicon-save"></span> Save</a></li>
                <li id="OpenTabBtn" class="tabbtns" onclick="openFile()"><a href="#"><span class="glyphicon glyphicon-open"></span> Load</a></li>
            </ul>
            <div class="tab-content">
            <div id="SiteInfo" class="tab-pane fade in active">
                <#include "xbuilder2d_general.ftl">
            </div>
            <div id="Treatment" class="tab-pane fade">
                <#include "xbuilder2d_treatment.ftl">
            </div>
            <div id="Field" class="tab-pane fade">
                <div class="subcontainer"><center>
                    Under construction
                </center></div>
            </div>
            <div id="Event" class="tab-pane fade">
                <#include "xbuilder2d_event.ftl">
            </div>
            <div id="Config" class="tab-pane fade">
                <div class="subcontainer"><center>
                    Under construction
                </center></div>
            </div>
            </div>
        </div>

        <#include "../footer.ftl">
        
        <script type="text/javascript" src="/plugins/chosen/chosen.jquery.min.js" ></script>
        <script type="text/javascript" src="/plugins/chosen/prism.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/chosen/init.js" charset="utf-8"></script>
        <script src="https://cdn.jsdelivr.net/npm/handsontable@latest/dist/handsontable.full.min.js"></script>
        <script type="text/javascript">
            $(document).ready(function () {
                init();
            });
        </script>
    </body>
</html>
