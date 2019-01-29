
<!DOCTYPE html>
<html>
    <head>
        <#include "../header.ftl">
        <script src="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.js"></script>
        <link rel="stylesheet" type="text/css" href="https://cdnjs.cloudflare.com/ajax/libs/vis/4.21.0/vis.min.css" />
        
        <style type="text/css">
            div.tab {
                overflow: hidden;
                border: 1px solid #ccc;
                background-color: #f1f1f1;
            }

            /* Style the buttons inside the tab */
            div.tab button {
                background-color: inherit;
                float: left;
                border: none;
                outline: none;
                cursor: pointer;
                padding: 14px 16px;
                transition: 0.3s;
                font-size: 17px;
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
        </style>
        
        <script>
            let timeline;
            let container;
            let events;
            
            function test() {
                timeline.setSelection(["b", "c"]);
            }
            
            function newId() {
                return "new" + (events.getIds().length + 1);
            }
            
            function addEvent() {
                let event = {id: newId(), content: 'event 7', start: '2013-04-23'}; 
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
                events.clear();
            }

            function drag(ev) {
                var event = {
                    id: newId(),
                    type: "box",
                    content: "New " + ev.target.value
                };
                ev.dataTransfer.setData("text", JSON.stringify(event));
            }

            function openTab(tabName) {
                var i, tabcontent, tablinks;
                tabcontent = document.getElementsByClassName("tabcontent");
                for (i = 0; i < tabcontent.length; i++) {
                    tabcontent[i].style.display = "none";
                }
                tablinks = document.getElementsByClassName("tablinks");
                for (i = 0; i < tablinks.length; i++) {
                    tablinks[i].className = tablinks[i].className.replace(" active", "");
                }
                document.getElementById(tabName).style.display = "block";
                document.getElementById(tabName + "Tab").className += " active";
                controlValidateInput(tabName);
                if (tabName === "Decoef") {
                    switchDecoef();
                    setDecoefLabels();
                }
            }
            
            function init() {
                // DOM element where the Timeline will be attached
                container = document.getElementById('visualization');

                // Create a DataSet (allows two way data-binding)
                events = new vis.DataSet([
                  {id: "a", content: 'event 1', start: '2013-04-20', editable: false},
                  {id: "b", content: 'event 2', start: '2013-04-14', group:"ga"},
                  {id: "c", content: 'event 3', start: '2013-04-18', group:"ga"},
                  {id: "d", content: 'event 4', start: '2013-04-16', end: '2013-04-19'},
                  {id: "e", content: 'event 5', start: '2013-04-25'},
                  {id: "f", content: 'event 6', start: '2013-04-27'}
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
                    orientation: 'top',
                    onAdd: function(event, callback) {
    //                    alert(event.start);
                        callback(event);
                        timeline.setSelection(event.id);
                    },
                    onDropObjectOnItem: function(objectData, event, callback) {
                        if (!event) { return; }
                        alert('dropped object with content: "' + objectData.content + '" to event: "' + event.content + '"');
                    }
                };

                // Create a Timeline
                var timeline = new vis.Timeline(container, events, options);
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
                
                openTab("SiteInfo");
            }
        </script>
    </head>

    <body>

        <#include "../nav.ftl">

        <div class="container-fluid primary-container">
            <div class="tab">
                <button type="button" class="tablinks active" onclick="openTab('SiteInfo')" id= "SiteInfoTab">General</button>
                <button type="button" class="tablinks" onclick="openTab('Irrigation')" id = "IrrigationTab">Irrigation</button>
                <button type="button" class="tablinks" onclick="openTab('SoilWater')" id = "SoilWaterTab">Soil</button>
                <button type="button" class="tablinks" onclick="openTab('Climate')" id = "ClimateTab">Climate</button>
                <button type="button" class="tablinks" onclick="openTab('Decoef')" id = "DecoefTab">Coefficient</button>
            </div>
            <div id="SiteInfo" class="tabcontent">
                <center>
                    <div class="row">
                        <div class="col-sm-8 text-left">
                            <button draggable="true" ondragstart="drag(event)" class="btn btn-primary" value="One-time Event"><span class="glyphicon glyphicon-menu-hamburger"></span> One-time Event</button>
                            <button draggable="true" ondragstart="drag(event)" class="btn btn-primary" value="Weekly Event"><span class="glyphicon glyphicon-menu-hamburger"></span> Weekly Event</button>
                            <button draggable="true" ondragstart="drag(event)" class="btn btn-primary" value="Monthly Event"><span class="glyphicon glyphicon-menu-hamburger"></span> Monthly Event</button>
                            <button draggable="true" ondragstart="drag(event)" class="btn btn-primary" value="Customized Event"><span class="glyphicon glyphicon-menu-hamburger"></span> Customized Event</button>
                        </div>
                        <div class="col-sm-4 text-right">
                            <button class="btn btn-success" onclick="test()">Test</button>
                            <button class="btn btn-success" onclick="addEvent()">Add</button>
                            <button class="btn btn-success" onclick="editEvent()">Edit</button>
                            <button class="btn btn-success" onclick="removeEvent()">Remove</button>
                            <button class="btn btn-success" onclick="removeEvents()">Clear</button>
                        </div>
                    </div>
                    <br/>
                    <div id="visualization"></div>
                    <br/>
                </center>   
            </div>
        </div>

        <#include "../footer.ftl">
        
        <script type="text/javascript">
            
            $(document).ready(function () {
                
                init();
            });
            
        </script>
    </body>
</html>
