
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
            let icSpreadsheet;
            let icLayers = [];
            let cultivars = {};
            let eventData;        // Data container for current management data
            let events = [];      // Array of event object for current management data
            let subEvents = [];   // Array of event object for current type of management data
            let eventId = 1;
            let managements = {}; // Map for all management data (mgnId: mgnData)
            let mgnId;            // Current management ID
            let trtData = [];
            let timeline;
            let tmlContainer;
            let fstTmlFlg = true;
            let spreadsheet;
            let configs = {};
            let configData = {};
            let configId;

            const soilInfoMap = {
                <#list soils as soilFile>
                <#list soilFile.soils as soil>
                '${soil.soil_id!}' : {sllb : [<#if soil.soilLayer??><#list soil.soilLayer as layer>${layer.sllb}<#sep>,</#sep></#list></#if>]},
                </#list>
                </#list>
            };
            let soilInfoUserMap = {};
            
            const soilFileInfoList = [
                <#list soils as soilFile>
                {
                    sl_notes : '${soilFile.sl_notes!}',
                    file_name : '${soilFile.file_name!}',
                    soils : [
                        <#list soilFile.soils as soil>
                        {soil_id : '${soil.soil_id!}', soil_name : '${soil.soil_name!}'}<#sep>,</#sep>
                        </#list>
                    ]
                }<#sep>,</#sep>
                </#list>
            ];

            const icasaCode = {
                <#list icasaMgnCodeMap?keys as key>
                ${key}:{
                <#list icasaMgnCodeMap[key]?keys as code>
                    ${code} : "${icasaMgnCodeMap[key][code]}"<#sep>,</#sep>
                </#list>
                }<#sep>,</#sep>
                </#list>
            };

            const icasaText = {
                <#list icasaMgnCodeMap?keys as key>
                ${key}:{
                <#list icasaMgnCodeMap[key]?keys as code>
                    "${icasaMgnCodeMap[key][code]}" : "${code}"<#sep>,</#sep>
                </#list>
                }<#sep>,</#sep>
                </#list>
            };

            const tableConfig = {
                all: {
                    columns: [
                        {type: 'text', data: 'content'},
                        {type: 'date', data: 'date', dateFormat: 'YYYY-MM-DD'},
                        {type: 'text', data: 'event'}
                    ],
                    headers: ['Name', 'Date', 'Type']
                },
                planting: {
                    columns: [
                        {type: 'text', data: 'content'},
                        {type: 'date', data: 'date', dateFormat: 'YYYY-MM-DD'},
                        {type: 'date', data: 'edate', dateFormat: 'YYYY-MM-DD'},
                        {type: 'dropdown', data: 'plma_text',
                            source: [<#list icasaMgnCodeMap.plma?keys?sort as code>"${icasaMgnCodeMap.plma[code]}"<#sep>,</#sep></#list>]
                        },
                        {type: 'dropdown', data: 'plds_text',
                            source: [<#list icasaMgnCodeMap.plds?keys?sort as code>"${icasaMgnCodeMap.plds[code]}"<#sep>,</#sep></#list>]
                        },
                        {type: 'numeric', data: 'plrs'},
                        {type: 'numeric', data: 'plrd',
                            validator: function (value, callback) {
                                var valid = value <= 360 && value >= 0;
                                return callback(valid);
                            }
                        },
                        {type: 'numeric', data: 'pldp'},
                        {type: 'numeric', data: 'plpop'},
                        {type: 'numeric', data: 'plpoe'},
                        {type: 'numeric', data: 'plmwt'},
                        {type: 'numeric', data: 'plenv'},
                        {type: 'numeric', data: 'page'},
                        {type: 'numeric', data: 'plph'},
                        {type: 'numeric', data: 'plspl'}
                    ],
                    headers: ['Name', 'Date', 'Emergence Date', 'Planting Method', 'Planting Distribution','Row Spacing',
                        'Row Direction', 'Planting Depth', 'Plant Population at Seeding', 'Plant Population at Emerngence',
                        'Planting Material Dry Weight', 'Temperature of Transplant Environment', 'Transplant Age', 'Plant per hill', 'Initial Sprout Length']
                },
                irrigation: {
                    columns: [
                        {type: 'text', data: 'content'},
                        {type: 'date', data: 'date', dateFormat: 'YYYY-MM-DD'},
                        {type: 'numeric', data: 'ireff',
                            validator: function (value, callback) {
                                var valid = value <= 1 && value >= 0;
                                return callback(valid);
                            }
                        },
                        {type: 'dropdown', data: 'irop_text',
                            source: [<#list icasaMgnCodeMap.irop?keys?sort as code>"${icasaMgnCodeMap.irop[code]}"<#sep>,</#sep></#list>]
                        },
                        {type: 'numeric', data: 'irval'},
                        {type: 'numeric', data: 'irrat'},
                        {type: 'time', data: 'irstr', timeFormat: 'HH:mm', correctFormat: true},
                        {type: 'numeric', data: 'irdur'},
                        {type: 'numeric', data: 'irspc'},
                        {type: 'numeric', data: 'irofs'},
                        {type: 'numeric', data: 'irdep'}
                    ],
                    headers: ['Name', 'Date', 'Efficiency', 'Operation', 'Amount of  Water','Drip Emitter Rate',
                        'Event Starting Time', 'Event Duration', 'Drip Emitter Spacing', 'Drip Emitter Offset', 'Drip Emitter Depth']
                },
                fertilizer: {
                    columns: [
                        {type: 'text', data: 'content'},
                        {type: 'date', data: 'date', dateFormat: 'YYYY-MM-DD'},
                        {type: 'dropdown', data: 'fecd_text',
                            source: [<#list icasaMgnCodeMap.fecd?keys?sort as code>"${icasaMgnCodeMap.fecd[code]}"<#sep>,</#sep></#list>]
                        },
                        {type: 'dropdown', data: 'feacd_text',
                            source: [<#list icasaMgnCodeMap.feacd?keys?sort as code>"${icasaMgnCodeMap.feacd[code]}"<#sep>,</#sep></#list>]
                        },
                        {type: 'numeric', data: 'fedep'},
                        {type: 'numeric', data: 'feamn'},
                        {type: 'numeric', data: 'feamp'},
                        {type: 'numeric', data: 'feamk'},
                        {type: 'numeric', data: 'feamc'},
                        {type: 'numeric', data: 'feamo'},
                        {type: 'dropdown', data: 'feocd_text',
                            source: [<#list icasaMgnCodeMap.feocd?keys?sort as code>"${icasaMgnCodeMap.feocd[code]}"<#sep>,</#sep></#list>]
                        }
                    ],
                    headers: ['Name', 'Date','Fertilizer Material', 'Fertilizer Applications', 'Depth', 'Nitrogen', 'Phosphorus', 'Potassium', 'Calcium',
                        'Other - amount', 'Other - name']
                },
                harvest: {
                    columns: [
                        {type: 'text', data: 'content'},
                        {type: 'date', data: 'date', dateFormat: 'YYYY-MM-DD'},
                        {type: 'text', data: 'hastg'},
                        {type: 'dropdown', data: 'hacom_text',
                            source: [<#list icasaMgnCodeMap.hacom?keys?sort as code>"${icasaMgnCodeMap.hacom[code]}"<#sep>,</#sep></#list>]
                        },
                        {type: 'dropdown', data: 'hasiz_text',
                            source: [<#list icasaMgnCodeMap.hasiz?keys?sort as code>"${icasaMgnCodeMap.hasiz[code]}"<#sep>,</#sep></#list>]
                        },
                        {type: 'numeric', data: 'happc',
                            validator: function (value, callback) {
                                var valid = value <= 100 && value >= 0;
                                return callback(valid);
                            }
                        },
                        {type: 'numeric', data: 'habpc',
                            validator: function (value, callback) {
                                var valid = value <= 100 && value >= 0;
                                return callback(valid);
                            }
                        }
                    ],
                    headers: ['Name', 'Date', 'Stage', 'Component', 'Size Group', 'Product Harvest Percentage', 'Byproduct Takeoff Percentage']
                },
                ic: {
                    columns: [
                        {type: 'numeric', data: 'icbl'},
                        {type: 'numeric', data: 'ich2o'},
                        {type: 'numeric', data: 'icnh4'},
                        {type: 'numeric', data: 'icno3'},
                    ],
                    headers: ['Depth, base of layer<br>( cm )', 'Volumetric Water<br>( cm3/cm3 )', 'Ammonium (NH4)<br>( g[N]/Mg[Soil] )', 'Nitrate (NO3)<br>( g[N]/Mg[Soil] )']
                }
            };

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
                    // If the clicked element is not the menu
                    if (!$(properties.event.target).parents(".event-menu").length > 0) {
                        // Hide it
                        $(".event-menu").hide(100);
                    }
                });
                timeline.on("mouseMove", function (properties) {
                    timeline.setOptions({showCurrentTime: true});
                    let date = new Date(properties.time.getFullYear(), properties.time.getMonth(), properties.time.getDate(), 0, 0, 0, 0);
//                    if (Math.abs(timeline.getCurrentTime() - date) < (24 * 3600 * 1000)) {
//                       return; 
//                    }
                    timeline.setCurrentTime(date);
                    $('.date-label').html(dateUtil.toYYYYMMDDStr(date)).finish().fadeIn(100).css({
//                        top: properties.event.pageY + "px",
                        left: properties.event.pageX + "px"
                    });
                });
                $('#visualization').mouseout(function (properties) {
                   $(".date-label").hide('slow');
                   timeline.setOptions({showCurrentTime: false});
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
            
            function initSpreadsheet(eventType, spsContainer) {
                if (!eventType) {
                    eventType = $('#sps_tabs').children('.active').children('a').text().trim().toLowerCase();
                }
                if (!spsContainer) {
                    spsContainer = document.querySelector('#visualization2');
                }
                if (spreadsheet) {
                    spreadsheet.destroy();
                }
                let data;
                let minRows = 10;
                if (eventType === "ic") {
                    data = icLayers;
                } else {
                    events = getEvents();
                    subEvents = getSubEvents(eventType);
                    data = subEvents;
                }
                if (eventType === "ic" && icLayers.length > 0 && $("#soil_id").val() !== "") {
                    minRows = icLayers.length;
                }
                let spsOptions = {
                    licenseKey: 'non-commercial-and-evaluation',
                    data: data,
                    columns: tableConfig[eventType].columns,
                    stretchH: 'all',
        //                    width: 500,
                    autoWrapRow: true,
        //                    height: 450,
                    minRows: minRows,
                    maxRows: 365 * 30,
                    manualRowResize: true,
                    manualColumnResize: true,
                    rowHeaders: true,
                    colHeaders: tableConfig[eventType].headers,
//                    headerTooltips: true,
//                    afterChange: function(changes, src) {
//                        if(changes){
//                            
//                        }
//                    },
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
                if (Object.keys(soilInfoUserMap).length === 0) {
                    initSoilProfileSB(soilFileInfoList);
                }
                chosen_init_all();
            }
            
            function init() {
                reset();
                $('.exp-data').on('change', function() {
                    saveData(expData, this.id, this.value);
                });
                $('.field-data').on('change', function() {
                    saveData(fieldData, this.id, this.value);
                    if (this.id === "fl_name") {
                        $('#' + fieldId).html(this.value);
                        for (let i in trtData) {
                            $('#tr_field_' + trtData[i].trtno).children('option[value=' + fieldId + ']').html(this.value);
                        }
                    }
                });
                $('.ic-data').on('change', function() {
                    saveData(fieldData.initial_conditions, this.id, this.value);
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
                $('.mgn-data').on('change', function() {
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
                    chosen_init("soil_id");
                    chosen_init("wst_id");
                    chosen_init("2d_flg");
                    undateICView();
                });
                $('.nav-tabs #FieldTab').on('hide.bs.tab', function(){
                    syncICData();
                });
                $('.nav-tabs #EventTab').on('shown.bs.tab', function(){
                    $("#mgn_create").parent().removeClass("active");
                    $("#" + mgnId).parent().addClass("active");
                    if (fstTmlFlg) {
                        fstTmlFlg = false;
                        initTimeline();
                        initSpreadsheet();
                        if (eventData.length !== 0) {
                            timeline.fit();
                        }
                    } else {
                        timeline.setItems(eventData);
                        if (eventData.length === 0) {
                            let startYear = $('#start_year').val();
                            if (startYear && !isNaN(startYear)) {
                                timeline.setWindow(new Date(startYear, 0, 1, 0, 0, 0, 0), new Date(startYear, 11, 31, 0, 0, 0, 0));
                            }
                        } else {
                            timeline.fit();
                        }
                        initSpreadsheet();
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
                        if (expData.crid_dssat) {
                            ext = expData.crid_dssat + "J";
                        } else {
                            ext = "XXJ";
                        }
                        
                        
                    } else {
                        text = $('#dssat_preview_text').html();
                        if (expData.crid_dssat) {
                            ext = expData.crid_dssat + "X";
                        } else {
                            ext = "XXX";
                        }
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
                $('<input type="file" accept=".json, .??J, .??X" onchange="readFile(this);">').click();
            }
            
            function readFile(target) {
                let files = target.files;
                if (files.length < 1) {
                    return;
                }
                let loadedFiles = [];
                for (let i=0; i<files.length; i++) {
                    if (files[i].name.toUpperCase().endsWith("X")) {
                        loadedFiles.push(files[i].name);
                        readFileToBufferedArray(files[i], updateProgress, readXFile);
                    } else if (files[i].name.toUpperCase().endsWith("SOL")) {
                        loadedFiles.push(files[i].name);
                        readFileToBufferedArray(files[i], updateProgress, readSoilFile);
                    } else if (files[i].name.toUpperCase().endsWith("WTH")) {
                        readFileToBufferedArray(files[i], updateProgress, readWthFile);
                        loadedFiles.push(files[i].name);
                    } else if (files[i].name.toUpperCase().endsWith("J") || 
                            files[i].name.toUpperCase().endsWith("JSON")) {
                        loadedFiles.push(files[i].name);
                        readFileToBufferedArray(files[i], updateProgress, readJFile);
                    }
                }
                if (loadedFiles.length > 0) {
                    bootbox.alert({
                        message: "Load data from " + JSON.stringify(loadedFiles),
                        backdrop: true
                    });
                }
            }
            
            function updateProgress() {
                // TODO
            }
            
            function readXFile (rawData, file) {
                let data = readXFileData(rawData, file.name);
                data.experiment.crid = convertCropCode2(data.experiment.crid_dssat);
                let soilFile = {
                    sl_notes : "Unknown data",
                    file_name : "??.SOL",
                    soils:[]
                };
                let soilMap = {};
                
                for (let id in data.field) {
                    if (data.field[id].initial_conditions) {
                        let ic = data.field[id].initial_conditions;
                        if (!ic.icpcr && ic.icpcr_dssat) {
                            ic.icpcr = convertCropCode2(ic.icpcr_dssat);
                        }
                        if (ic.icdat) {
                            ic.icdat = dateUtil.toYYYYMMDDStr(ic.icdat);
                        }
                    }
                    if (data.field[id].soil_id) {
                        if (!soilInfoMap[data.field[id].soil_id] && !soilMap[data.field[id].soil_id]) {
                            soilFile.soils.push({
                                soil_id : data.field[id].soil_id,
                                soil_name : "Unknown name",
                                soilLayer: []
                            });
                            soilMap[data.field[id].soil_id] = true;
                            if (data.field[id].initial_conditions && data.field[id].initial_conditions.soilLayer) {
                                for (let j in data.field[id].initial_conditions.soilLayer) {
                                    soilFile.soils[0].soilLayer.push({sllb: data.field[id].initial_conditions.soilLayer[j].icbl});
                                }
                            }
                        }
                    }
                    if (data.field[id].wst_id) {
                        if ($("#wst_id").find("option[value='" + data.field[id].wst_id + "']").length === 0) {
                            let customizedGroup = $("#wst_id").find("optgroup[label='Customized']");
                            if (customizedGroup.length === 0) {
                                customizedGroup = $('<optgroup label="Customized"></>');
                                $("#wst_id").append(customizedGroup);
                            } else {
                                customizedGroup = result[0];
                            }
                            customizedGroup.append("<option value='" + data.field[id].wst_id + "'>Customized Data - " + data.field[id].wst_id + "</option>");
                        }
                    }
                    
                }
                if (soilFile.soils.length > 0) {
                    updateSoilProfileSB(soilFile);
                }

                for (let id in data.management) {
                    if (data.management[id].data) {
                        for (let j in data.management[id].data) {
                            if (data.management[id].data[j].date) {
                                data.management[id].data[j].date = dateUtil.toYYYYMMDDStr(data.management[id].data[j].date);
                                data.management[id].data[j].start = dateUtil.toLocaleDate(data.management[id].data[j].date, data.management[id].data[j].irstr);
                            }
                            if (data.management[id].data[j].edate) {
                                data.management[id].data[j].edate = dateUtil.toYYYYMMDDStr(data.management[id].data[j].edate);
                            }
                        }
                    }
                }
                loadData(data);
                let cumstomizedCulData = cultivars;
                getCulData(data.experiment.crid, cumstomizedCulData);
            }
            
            function readJFile(rawData, file) {
                let data = JSON.parse(rawData);
                loadData(data);
            }
            
            function loadData(rawData, ) {
                
                // Load meta data
                expData = rawData.experiment;
                $('.exp-data').each(function() {
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
                <li id="GuideTabBtn" class="tabbtns" onclick="showGreetingPrompt()"><a href="#"><span class="glyphicon glyphicon-question-sign"></span> Guide</a></li>
            </ul>
            <div class="tab-content">
                <div id="SiteInfo" class="tab-pane fade in active">
                    <#include "xbuilder2d_general.ftl">
                    <#include "xbuilder2d_greeting_popup.ftl">
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
        <script type="text/javascript" src="/js/dataReader/DssatXFileReader.js"></script>
        <script type="text/javascript" src="/js/dataReader/DssatSoilReader.js"></script>
        <script type="text/javascript" src="/js/bootbox/bootbox.all.min.js" charset="utf-8"></script>
        <script src="https://cdn.jsdelivr.net/npm/handsontable@6.2.2/dist/handsontable.full.min.js"></script>
        <script type="text/javascript">
            $(document).ready(function () {
                init();
                showGreetingPrompt();
            });
        </script>
    </body>
</html>
