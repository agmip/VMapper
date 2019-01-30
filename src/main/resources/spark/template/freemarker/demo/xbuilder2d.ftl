
<!DOCTYPE html>
<html>
    <head>
        <#include "../header.ftl">
        <#include "../chosen.ftl">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.js"></script>
        <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.css" />
        
        <style type="text/css">
            div.tab {
                overflow: hidden;
                border: 1px solid #ccc;
                background-color: #f1f1f1;
            }

            /* Style the switch buttons inside the tab */
            div.tab button.tablinks {
                background-color: inherit;
                float: left;
                border: none;
                outline: none;
                cursor: pointer;
                padding: 9px 16px;
                transition: 0.3s;
                font-size: 13px;
                letter-spacing: 2px;
            }

            /* Style the clicking buttons inside the tab */
            div.tab button.tabbtns {
                float: right;
                margin: 3px 16px;
            }

            /* Style the add buttons inside the tab */
            div.tab button.tabaddbtns {
                float: left;
                margin: 3px 16px;
            }

            /* Change background color of buttons on hover */
            div.tab button:hover {
                background-color: #ddd;
            }

            /* Create an active/current tablink class */
            div.tab button.active {
                background-color: #ccc;
            }

            /* Style the tab content */
            .tabcontent {
                display: none;
                padding: 10px 10px;
                border: 1px solid #ccc;
                border-top: none;
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

            function openTab(tabName, tabType) {
                if (tabType === undefined) {
                    tabType = "main";
                }
                let i, tabcontent, tablinks;
                tabcontent = document.getElementsByClassName("tabcontent");
                for (i = 0; i < tabcontent.length; i++) {
                    if (tabcontent[i].className.includes(tabType)) {
                        tabcontent[i].style.display = "none";
                    }
                }
                tablinks = document.getElementsByClassName("tablinks");
                for (i = 0; i < tablinks.length; i++) {
                    if (tablinks[i].className.includes(tabType)) {
                        tablinks[i].className = tablinks[i].className.replace(" active", "");
                    }
                }
                document.getElementById(tabName).style.display = "block";
                document.getElementById(tabName + "Tab").className += " active";
//                controlValidateInput(tabName);
                if (tabName === "Event") {
                    openTab("default", "event");
                    if (fstTmlFlg) {
                        fstTmlFlg = false;
                        initTimeline();
                    }
                }
            }
            
            function initTimeline() {
                // DOM element where the Timeline will be attached
                container = document.getElementById('visualization');

                // Create a DataSet (allows two way data-binding)
                events = new vis.DataSet([
                  {id: "a", content: 'event 1', start: '2013-04-20', editable: false},
                  {id: "b", content: 'event 2', start: '2013-04-14', group:"ga"},
                  {id: "c", content: 'event 3', start: '2013-04-18', group:"ga"},
                  {id: "d", content: 'event 4', start: '2013-04-16', end: '2013-04-19'},
                  {id: "e", content: 'event 5', start: '2013-04-25', group:"ga"},
                  {id: "f", content: 'event 6', start: '2013-04-27', group:"ga"}
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
                openTab("SiteInfo");
                chosen_init_all();
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
            <div class="tab">
                <button type="button" class="tablinks main active" onclick="openTab('SiteInfo')" id= "SiteInfoTab"><span class="glyphicon glyphicon-grain"></span> General</button>
                <button type="button" class="tablinks main" onclick="openTab('Event')" id = "EventTab"><span class="glyphicon glyphicon-calendar"></span> Operations</button>
                <button type="button" class="tablinks main" onclick="openTab('Treatment')" id = "TreatmentTab"><span class="glyphicon glyphicon-link"></span> Treatments</button>
                <button type="button" class="tablinks main" onclick="openTab('Config')" id = "ConfigTab"><span class="glyphicon glyphicon-cog"></span> Configurations</button>
                <button type="button" class="btn btn-success tabbtns" onclick="saveFile()" id = "SaveTabBtn"><span class="glyphicon glyphicon-save"></span> Save</button>
            </div>
            <div id="SiteInfo" class="tabcontent main">
                <#include "xbuilder2d_general.ftl">
            </div>
            <div id="Event" class="tabcontent main">
                <#include "xbuilder2d_event.ftl">
            </div>
            <div id="Treatment" class="tabcontent main">
                <center>
                </center>
            </div>
            <div id="Config" class="tabcontent main">
                <center>
                </center>
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
