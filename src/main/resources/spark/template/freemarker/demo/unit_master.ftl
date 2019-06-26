
<!DOCTYPE html>
<html>
    <head>
        <#include "../header.ftl">
        <#include "../chosen.ftl">
        
        <script>
            function lookupUnit(unit) {
                $("#unit_desc").text("Looking for " + unit + " ...");
                    $.get("/data/unit/lookup?unit=" + unit,
                        function (jsonStr) {
                            var unitInfo = JSON.parse(jsonStr);
                            $('#unit_desc').html(unitInfo.message);
                        }
                    );
            }
            
            function unitConvert() {
                $("#value_to").text("");
                var valueFrom = $("#value_from").val();
                var unitFrom = $("#unit_from").val();
                var unitTo = $("#unit_to").val();
                if (valueFrom && unitFrom && unitTo) {
                    $.get("/data/unit/convert?unit_to=" + unitTo + "&unit_from="+unitFrom + "&value_from=" + valueFrom,
                        function (jsonStr) {
                            var result = JSON.parse(jsonStr);
                            if (result.status !== "0") {
                                $('#value_to').html(result.message);
                            } else {
                                $('#value_to').html(result.value_to);
                            }
                        }
                    );
                }
            }
            
        </script>
    </head>

    <body>

        <#include "../nav.ftl">

        <div class="container">
            <h1>Unit Master</h1>
            <hr>
            <p>
                <h3>This simple tool is designed for :</h3>
                <li>unit expression quick validation and lookup</li>
                <li>value converting between two given units</li>
            </p>
            <hr>
            <div class="row">
                <div class="col-sm-6">
                    <h3>Unit Validation</h3>
                    <label class="control-label" for="unit">Unit Expression:</label>
                    <div class="input-group col-sm-12">
                        <input type="text" id="unit" class="form-control" value="" placeholder="Unit text expression" data-toggle="tooltip" title="Unit text expression" onchange="lookupUnit(this.value);">
                    </div>
                    <br>
                    <label class="control-label" for="unit">Unit Description:</label>
                    <div id="unit_desc" class="input-group col-sm-12"></div>
                </div>
                <div class="col-sm-6">
                    <h3>Unit Convert</h3>
                    <div class="col-sm-6">
                    <label class="control-label" for="unit_from">Unit From:</label>
                    <div class="input-group col-sm-12">
                        <input type="text" id="unit_from" class="form-control" value="" placeholder="Unit text expression" data-toggle="tooltip" title="Unit text expression" onchange="unitConvert();">
                    </div>
                    <br>
                    <label class="control-label" for="value_from">Value From:</label>
                    <div class="input-group col-sm-12">
                        <input type="number" id="value_from" class="form-control" value="" placeholder="orginal value" data-toggle="tooltip" title="orginal value" onchange="unitConvert();">
                    </div>
                    </div>
                    <div class="col-sm-6">
                    <label class="control-label" for="unit_to">Unit To:</label>
                    <div class="input-group col-sm-12">
                        <input type="text" id="unit_to" class="form-control" value="" placeholder="Unit text expression" data-toggle="tooltip" title="Unit text expression" onchange="unitConvert();">
                    </div>
                    <br>
                    <label class="control-label" for="value_to">Value To:</label>
                    <div id="value_to" class="input-group col-sm-12"></div>
                    </div>
                </div>
            </div>
        </div>

        <#include "../footer.ftl">
        <script type="text/javascript" src="https://code.highcharts.com/highcharts.js"></script>
        <script type="text/javascript" src="https://code.highcharts.com/modules/heatmap.js"></script>
        <script type="text/javascript" src="https://code.highcharts.com/modules/vector.js"></script>
        <script type="text/javascript" src="https://code.highcharts.com/modules/no-data-to-display.js"></script>
        <script type="text/javascript" src="https://code.highcharts.com/modules/exporting.js"></script>
        <script type="text/javascript" src="/plugins/filestyle/bootstrap-filestyle.min.js"></script>
        <script type="text/javascript" src="/plugins/chosen/chosen.jquery.min.js" ></script>
        <script type="text/javascript" src="/plugins/chosen/prism.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/chosen/init.js" charset="utf-8"></script>
        <script type="text/javascript" src="/js/dataReader/BufferedFileReader.js"></script>
        <script type="text/javascript" src="/js/dataReader/outputDataReader.js"></script>
        <script type="text/javascript" src="/js/plot/VectorFlux.js"></script>
        <script type="text/javascript" src="/js/plot/Heatmap.js"></script>
        <script>
            var progress;
            $(document).ready(function () {
                progress = document.querySelector('.percent');
                chosen_init_all();
            });
        </script>
    </body>
</html>

