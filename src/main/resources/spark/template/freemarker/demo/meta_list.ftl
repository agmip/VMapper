<!DOCTYPE html>
<html>
    <head>
        <#include "../header.ftl">
        <link rel="stylesheet" type="text/css" href="https://cdn.jsdelivr.net/npm/handsontable-pro@latest/dist/handsontable.full.min.css">
    </head>

    <body>

        <#include "../nav.ftl">
        
        <div class="container-fluider" style="padding: 80px 10px;">
            <div style="overflow-y: auto;overflow-x: hidden;min-height: 500px">
                <div id="table" ></div>
            </div>
        </div>
        
        
        <#include "../footer.ftl">
        <script src="https://cdn.jsdelivr.net/npm/handsontable@latest/dist/handsontable.full.min.js"></script>
    </body>
    <script>
        var dataObject = [
            <#list metalist as meta>
            {
                exname: "${meta['exname']!}",
                crop: "${meta['crop']!}",
                people: "${meta['people']!}",
                address: "${meta['address']!}",
                site: "${meta['site']!}",
                notes: '${meta['notes']!}'
            }<#sep>, </#sep>
            </#list>
        ];
        var hotElement = document.querySelector('#table');
//        var hotElementContainer = hotElement.parentNode;
        var hotSettings = {
            data: dataObject,
            columns: [
                {
                    data: 'exname',
                    type: 'text'
                },
                {
                    data: 'crop',
                    type: 'text'
                },
                {
                    data: 'people',
                    type: 'text'
                },
                {
                    data: 'address',
                    type: 'text'
                },
                {
                    data: 'site',
                    type: 'text'
                },
                {
                    data: 'notes',
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
                'Experiment Name',
                'Crop',
                'People',
                'Address',
                'Site',
                'Notes'
            ],
            manualRowMove: true,
            manualColumnMove: true,
            contextMenu: true,
            filters: true,
            dropdownMenu: true
        };
        var hot = new Handsontable(hotElement, hotSettings);
    </script>
</html>