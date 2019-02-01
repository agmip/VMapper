
<!DOCTYPE html>
<html>
    <head>
        <#include "../header.ftl">
        <#include "../chosen.ftl">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.js"></script>
        <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.css" />
        
        <style type="text/css">
            /* Style the clicking buttons inside the tab */
            ul.nav-tabs button.tabbtns {
                float: right;
                margin: 0px 16px;
            }
            
            /* Style the add buttons inside the tab */
            ul.nav-tabs button.tabaddbtns {
                float: left;
                margin: 5px 5px;
            }
            .dropdown-menu li a.create-link{
                font-style:italic;
            }
            .align-middle{
                text-align: center;
                vertical-align: middle;
            }
            
            /* alternating column backgrounds */
            .vis-time-axis .grid.vis-odd {
                background: #f5f5f5;
            }

            /* gray background in weekends, white text color */
            .vis-time-axis .vis-grid.vis-saturday,
            .vis-time-axis .vis-grid.vis-sunday {
                background: gray;
            }
            .vis-time-axis .vis-text.vis-saturday,
            .vis-time-axis .vis-text.vis-sunday {
                color: white;
            }
            
            /* The whole thing */
            .event-menu {
                display: none;
                z-index: 1000;
                position: absolute;
                overflow: hidden;
                border: 1px solid #CCC;
                white-space: nowrap;
                font-family: sans-serif;
                background: #FFF;
                color: #333;
                border-radius: 5px;
                padding: 0;
            }

            /* Each of the items in the list */
            .event-menu li {
                padding: 8px 12px;
                cursor: pointer;
                list-style-type: none;
                transition: all .3s ease;
                user-select: none;
            }

            .event-menu li:hover {
                background-color: #DEF;
            }
        </style>
        
        <script>
            let timeline;
            let container;
            let events;
            let fstTmlFlg = true;
            
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
            
//            function openMainTab(target) {
//                let tabName = target.id;
//                if (tabName === "EventTab") {
//                    if (fstTmlFlg) {
//                        fstTmlFlg = false;
//                        initTimeline();
//                    }
////                    openEventTab("default", "event");
//                } else if (tabName === "TreatmentTab") {
//                    $("#tr_field_1").chosen("destroy");
//                    chosen_init("tr_field_1", ".chosen-select");
//                    $("#tr_management_1").chosen("destroy");
//                    chosen_init("tr_management_1", ".chosen-select");
//                    $("#tr_config_1").chosen("destroy");
//                    chosen_init("tr_config_1", ".chosen-select");
//                    $("#tr_field_2").chosen("destroy");
//                    chosen_init("tr_field_2", ".chosen-select");
//                    $("#tr_management_2").chosen("destroy");
//                    chosen_init("tr_management_2", ".chosen-select");
//                    $("#tr_config_2").chosen("destroy");
//                    chosen_init("tr_config_2", ".chosen-select");
//                }
//            }
            
            function initTimeline() {
                // DOM element where the Timeline will be attached
                container = document.getElementById('visualization');

                // Create a DataSet (allows two way data-binding)
                events = new vis.DataSet([
                  {id: "a", content: 'Fixed event 1', start: '2013-04-20', editable: false},
                  {id: "b", content: 'Weekly event 1.1', start: '2013-04-12', group:"ga"},
                  {id: "c", content: 'Weekly event 1.2', start: '2013-04-19', group:"ga"},
                  {id: "d", content: 'Daily event 4', start: '2013-04-15', end: '2013-04-19'},
                  {id: "e", content: 'Weekly event 1.3', start: '2013-04-26', group:"ga"},
                  {id: "f", content: 'Weekly event 1.4', start: '2013-05-03', group:"ga"}
                ]);
    //            events.on('*', function (event, properties, senderId) {
    //                console.log('event:', event, 'properties:', properties, 'senderId:', senderId);
    //            });
    //            events.on('add', function(event, properties, senderId) {
    //                timeline.setSelection(properties.items);
    //            });

                // Configuration for the Timeline
                var options = {
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
                timeline = new vis.Timeline(container, events, options);
                timeline.on("select", function(properties) {
                    let selections = properties.items;
                    for (let i in selections) {
                        if (events.get(selections[i]).group !== undefined) {
                            let group = events.get(selections[i]).group;
                            let groupEvents = events.getIds({
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
            
            function init() {
                chosen_init_all();
                $('.nav-tabs #EventTab').on('shown.bs.tab', function(){
                    if (fstTmlFlg) {
                        fstTmlFlg = false;
                        initTimeline();
                    }
                });
                $('.nav-tabs #TreatmentTab').on('shown.bs.tab', function(){
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
                alert("will save a XFile for you later!");
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
                <li id="FieldTab">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                        <span class="glyphicon glyphicon-link"></span>
                        Field
                        <span class="badge" id="field_badge">0</span>
                        <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu">
                        <li><a data-toggle="tab" href="#Field" class="create-link">Create new...</a></li>
                    </ul>
                <li id="EventTab" class="dropdown">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                        <span class="glyphicon glyphicon-calendar"></span>
                        Management
                        <span class="badge" id="management_badge">7</span>
                        <span class="caret"></span>
                    </a>
                    
                    <ul class="dropdown-menu">
                        <li><a data-toggle="tab" href="#Event" class="create-link">Create new...</a></li>
                        <li><a data-toggle="tab" href="#Event">Default</a></li>
                        <li><a data-toggle="tab" href="#Event">N-150</a></li>
                        <li><a data-toggle="tab" href="#Event">N-200</a></li>
                        <li><a data-toggle="tab" href="#Event">N-250</a></li>
                        <li><a data-toggle="tab" href="#Event">I-subsurface</a></li>
                        <li><a data-toggle="tab" href="#Event">I-surface</a></li>
                        <li><a data-toggle="tab" href="#Event">I-fixed</a></li>
                    </ul>
                </li>
                <li id="TreatmentTab">
                    <a data-toggle="tab" href="#Treatment"><span class="glyphicon glyphicon-link"></span> Treatments <span class="badge" id="treatment_badge">2</span></a>
                </li>
                <li id="ConfigTab">
                    <a class="dropdown-toggle" data-toggle="dropdown" href="#">
                        <span class="glyphicon glyphicon-calendar"></span>
                        Configurations
                        <span class="badge" id="config_badge">0</span>
                        <span class="caret"></span>
                    </a>
                    <ul class="dropdown-menu">
                        <li><a data-toggle="tab" href="#Config" class="create-link">Create new...</a></li>
                    </ul>
                </li>
                <button id="SaveTabBtn" type="button" class="btn btn-success tabbtns" onclick="saveFile()"><span class="glyphicon glyphicon-save"></span> Save</li>
            </ul>
            <div class="tab-content">
            <div id="SiteInfo" class="tab-pane fade in active">
                <#include "xbuilder2d_general.ftl">
            </div>
            <div id="Field" class="tab-pane fade">
                <center>
                </center>
            </div>
            <div id="Event" class="tab-pane fade">
                <#include "xbuilder2d_event.ftl">
            </div>
            <div id="Treatment" class="tab-pane fade">
                <#include "xbuilder2d_treatment.ftl">
            </div>
            <div id="Config" class="tab-pane fade">
                <center>
                </center>
            </div>
            </div>
        </div>

        <#include "../footer.ftl">
        
        <script type="text/javascript" src="/plugins/chosen/chosen.jquery.min.js" ></script>
        <script type="text/javascript" src="/plugins/chosen/prism.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/chosen/init.js" charset="utf-8"></script>
        
        <script type="text/javascript">
            $(document).ready(function () {
                init();
            });
        </script>
    </body>
</html>
