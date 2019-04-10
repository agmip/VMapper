
<!DOCTYPE html>
<html>
    <head>
        
        <#include "../header.ftl">
        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/handsontable-pro@latest/dist/handsontable.full.min.css">
        <style>
            div.sps_preview {
                height: 40px;
                overflow: scroll;
            }
        </style>
        <script>
            let data = {io:[], function:[]};
            let spreadsheets = {};
            let columnConfigs = {};
            let colHeaderConfigs = {};
            
            // Function table definition
            columnConfigs["function"] = [
                        {data: 'name',type: 'text'},
                        {data: 'language',type: 'text'},
                        {data: 'filename',type: 'text'},
                        {data: 'type',type: 'text',editor: 'select',
                            selectOptions: ['internal', 'external']},
                        {data: 'description',type: 'text'}];
            colHeaderConfigs["function"] = [
                        'Name',
                        'Language',
                        'File Name',
                        'Type',
                        'Description'
                    ];
            
            // I/O table definition
            columnConfigs["io"] = [
                        {data: 'iotype',type: 'text',editor: 'select',
                            selectOptions: ['I', 'O', 'I/O']},
                        {data: 'name',type: 'text'},
                        {data: 'datatype',type: 'text',editor: 'select',
                            selectOptions: ['STRING','STRINGARRAY','STRINGLIST','DATE','DATEARRAY','DATELIST','DOUBLE','DOUBLEARRAY','DOUBLELIST','INT','INTARRAY','INTLIST','BOOLEAN']},
                        {data: 'len',type: 'text'},
                        {data: 'description',type: 'text'},
                        {data: 'default',type: 'text'},
                        {data: 'max',type: 'text'},
                        {data: 'min',type: 'text'},
                        {data: 'inputtype',type: 'text',editor: 'select',
                            selectOptions: ['variable', 'parameter']},
                        {data: 'parametercategory',type: 'text',editor: 'select',
                            selectOptions: ['constant','species','genotypic','soil','private']},
                        {data: 'variablecategory',type: 'text',editor: 'select',
                            selectOptions: ['state','rate','auxiliary']},
                        {data: 'unit',type: 'text'},
                        {data: 'uri',type: 'text'}];
            colHeaderConfigs["io"] = [
                        'IO Type *',
                        'Name *',
                        'Data Type *',
                        'Length * (array only)',
                        'Description *',
                        'Default',
                        'Max',
                        'Min',
                        'Input Type *(Input only)',
                        'Param Category',
                        'Var Category',
                        'Unit *',
                        'Uri'
                    ];
            
//            // Output table definition
//            columnConfigs["output"] = [
//                        {data: 'name',type: 'text'},
//                        {data: 'datatype',type: 'text',editor: 'select',
//                            selectOptions: ['STRING','STRINGARRAY','STRINGLIST','DATE','DATEARRAY','DATELIST','DOUBLE','DOUBLEARRAY','DOUBLELIST','INT','INTARRAY','INTLIST','BOOLEAN']},
//                        {data: 'description',type: 'text'},
//                        {data: 'max',type: 'text'},
//                        {data: 'min',type: 'text'},
//                        {data: 'variablecategory',type: 'text',editor: 'select',
//                            selectOptions: ['state','rate','auxiliary']},
//                        {data: 'unit',type: 'text'},
//                        {data: 'uri',type: 'text'}];
//            colHeaderConfigs["output"] = [
//                        'Name',
//                        'Data Type',
//                        'Description',
//                        'Max',
//                        'Min',
//                        'Var Category',
//                        'Unit',
//                        'Uri'
//                    ];
            
            function initSpreadsheet(category) {
                $('#sheet_' + category).parent("fieldset").attr("hidden", false);
                let spsContainer = document.querySelector('#sheet_' + category);
                let spsOptions = {
                    licenseKey: 'non-commercial-and-evaluation',
                    data: data[category],
                    columns: columnConfigs[category],
                    stretchH: 'all',
        //                    width: 500,
                    autoWrapRow: true,
        //                    height: 450,
                    minRows: 10,
                    maxRows: 365 * 30,
                    manualRowResize: true,
                    manualColumnResize: true,
                    rowHeaders: true,
                    colHeaders: colHeaderConfigs[category],
                    manualRowMove: true,
                    manualColumnMove: true,
                    contextMenu: true,
                    filters: true,
                    dropdownMenu: true
                };
                if(spreadsheets[category]) {
                    spreadsheets[category].destroy();
                }
                spreadsheets[category] = new Handsontable(spsContainer, spsOptions);
            }
            
            function init() {
                initSpreadsheet("io");
//                initSpreadsheet("function");
            }
            
            function switchPreviewViewType(target) {
                let showBtn, hideBtn, showDiv, hideDiv;
                if (target.id === "sps_swc_btn") {
                    hideBtn = $("#xml_swc_btn");
                    hideDiv = $("#xml_preview");
                    showBtn = $("#sps_swc_btn");
                    showDiv = $("#sps_preview");
                } else {
                    hideBtn = $("#sps_swc_btn");
                    hideDiv = $("#sps_preview");
                    showBtn = $("#xml_swc_btn");
                    showDiv = $("#xml_preview");
                }
                if(showBtn.hasClass("btn-primary")) {
                    return;
                }
                hideBtn.removeClass("btn-primary").addClass("btn-default");
                showBtn.removeClass("btn-default").addClass("btn-primary");
                hideDiv.fadeOut("fast",function() {
                    showDiv.fadeIn("fast", updateXMLPreview);
                });
            }
            
            function updateXMLPreview() {
                let json = JSON.stringify(data["io"]);
                $('#xml_preview_text').html(json);
                if($("#xml_swc_btn").hasClass("btn-primary")) {
                    $.post("/translator/xml",
                        {io : json},
                        function (xfile) {
                            $('#xml_preview_text').html(xfile);
                        }
                    );
                }
            }
            
            function saveFile() {
                let text, ext;
                text = JSON.stringify(data["io"]);
                ext = ".json";
                let blob = new Blob([text], {type: "text/plain;charset=utf-8"});
                saveAs(blob, "io_define" + ext);
            }
            
            function openFile() {
                $('<input type="file" accept=".json" onchange="readFile(this);">').click();
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
                data["io"] = rawData;
                initSpreadsheet("io");
            }
        </script>
    </head>
    <body>

        <#include "../nav.ftl">

        <div class="container-fluid primary-container">
            <fieldset>
                <legend>
                    XML Editor&nbsp;&nbsp;&nbsp;
                    <div class="btn-group slider">
                        <button id="sps_swc_btn" type="button" class="btn btn-primary" onclick="switchPreviewViewType(this);">&nbsp;&nbsp;Sheet&nbsp;&nbsp;</button>
                        <button id="xml_swc_btn" type="button" class="btn btn-default" onclick="switchPreviewViewType(this);">XML</button>
                    </div>
                    <div class="btn-group">
                        <button id="SaveTabBtn" class="btn btn-default" onclick="saveFile()">Save</button>
                        <button id="OpenTabBtn" class="btn btn-default" onclick="openFile()">Load</button>
                    </div>
                </legend>
                <div id="sps_preview" class="form-group col-sm-12">
                    <fieldset hidden>
                        <legend>I/O</legend>
                        <div id="sheet_io" class="col-sm-12"></div>
                    </fieldset>
                    <fieldset hidden>
                        <legend>Function</legend>
                        <div id="sheet_function" class="col-sm-12"></div>
                    </fieldset>
                </div>
                <div id="xml_preview" class="form-group col-sm-12" hidden><textarea class="form-control" rows="25" id="xml_preview_text" style="font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;" readonly></textarea></div>

            </fieldset>
        </div>

        <#include "../footer.ftl">
        <script type="text/javascript" src='/plugins/FileSaver/FileSaver.js'></script>
        <script type="text/javascript" src="/js/dataReader/BufferedFileReader.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/handsontable@6.2.2/dist/handsontable.full.min.js"></script>
        <script type="text/javascript">
            $(document).ready(function () {
                init();
            });
        </script>
    </body>
</html>