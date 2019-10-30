
<!DOCTYPE html>
<html>
    <head>
        <#include "../header.ftl">
        <#include "../chosen.ftl">
        
        <script>
            function lookupUnit(output, unit) {
                if (!unit) {
                    $("#" + output).text("");
                    if (output.endsWith("validate")) {
                        $("#unit_category").text("");
                    }
                } else {
                    $("#" + output).text("Looking for " + unit + " ...");
                    if (output.endsWith("validate")) {
                        $("#unit_category").text("");
                    }
                    $.get(encodeURI("/data/unit/lookup?unit=" + unit),
                        function (jsonStr) {
                            var unitInfo = JSON.parse(jsonStr);
                            $('#'+ output).html(unitInfo.message);
                            if (output.endsWith("validate")) {
                                $("#unit_category").text(unitInfo.category);
                            }
                        }
                    );
                }
            }
            
            function unitConvert() {
                $("#value_to").text("");
                var valueFrom = $("#value_from").val();
                var unitFrom = $("#unit_from").val();
                var unitTo = $("#unit_to").val();
                if (valueFrom && unitFrom && unitTo) {
                    $.get(encodeURI("/data/unit/convert?unit_to=" + unitTo + "&unit_from="+unitFrom + "&value_from=" + valueFrom),
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
            
            function updateUnitType(unitType) {
                
                $.get(encodeURI("/data/unit/lookup?type=" + unitType),
                    function (jsonStr) {
                        var units = JSON.parse(jsonStr);
                        var sb = $('#unit_sublist').empty().append('<option value=""></option>');
                        for (let i in units) {
                            let option = document.createElement('option');
                            option.innerHTML = units[i].name;
                            option.value = units[i].symbol;
                            sb.append(option);
                        }
                        chosen_init("unit_sublist");
                        lookupUnit("unit_desc_lookup");
                        showSymbol();
                    }
                );
            }
            
            function showSymbol(symbol) {
                if (symbol) {
                    $("#unit_symbol").text(symbol);
                } else {
                    $("#unit_symbol").text("");
                }
            }
            
            function updatePrefix(symbol) {
                if (!symbol) {
                    $("#prefix_desc").text("");
                    $("#prefix_symbol").text("");
                } else {
                    $("#prefix_symbol").text(symbol);
                    let value;
                    <#list prefixes as prefix>
                    if (symbol === "${prefix.symbol}") {
                        value = '${prefix.value!"undefined"}';
                    } else 
                    </#list>
                    { value = "undefined"; }
                    $("#prefix_desc").text(value);
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
                <div class="col-sm-8">
                    <div class="col-sm-4">
                        <h3>Unit Validation</h3>
                        <label class="control-label" for="unit">Unit Expression:</label>
                        <div class="input-group col-sm-12">
                            <input type="text" id="unit" class="form-control" value="" placeholder="Unit text expression" data-toggle="tooltip" title="Unit text expression" oninput="lookupUnit('unit_desc_validate', this.value);">
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <h3>Unit Lookup</h3>
                        <label class="control-label" for="unit">Unit Primary Category:</label>
                        <div class="input-group col-sm-12">
                            <select id="unit_type" class="form-control chosen-select-deselect exp-data" onchange="updateUnitType(this.value);" data-placeholder="Choose a Unit Type..." required>
                                <option value=""></option>
                                <#list baseUnits?keys as code>
                                <option value="${code!}">${baseUnits[code]!}</option>
                                </#list>
                            </select>
                        </div>
                        <label class="control-label" for="unit">Unit Sublist:</label>
                        <div class="input-group col-sm-12">
                            <select id="unit_sublist" class="form-control chosen-select-deselect exp-data" onchange="lookupUnit('unit_desc_lookup', this.value);showSymbol(this.value)" data-placeholder="Choose a Unit Type..." required>
                            </select>
                        </div>
                    </div>
                    <div class="col-sm-4">
                        <h3>Prefix Lookup</h3>
                        <label class="control-label" for="unit">Prefix list:</label>
                        <div class="input-group col-sm-12">
                            <select id="unit_type" class="form-control chosen-select-deselect exp-data" onchange="updatePrefix(this.value);" data-placeholder="Choose a Prefix..." required>
                                <option value=""></option>
                                <#list prefixes as prefix>
                                <option value="${prefix.symbol!}">${prefix.name!} - ${prefix.value!"N/a"}</option>
                                </#list>
                            </select>
                        </div>
                    </div>
                    <div class="col-sm-12">
                        <hr>
                        <div class="col-sm-4">
                            <h3>Validation Result</h3>
                            <label class="control-label" for="unit">Unit Standard Expression:</label>
                            <div id="unit_desc_validate" class="input-group col-sm-12"></div>
                            <label class="control-label" for="unit">Unit Category Code:</label>
                            <div id="unit_category" class="input-group col-sm-12"></div>
                        </div>
                        <div class="col-sm-4">
                            <h3>Lookup Result</h3>
                            <label class="control-label" for="unit">Unit Standard Expression:</label>
                            <div id="unit_desc_lookup" class="input-group col-sm-12"></div>
                            <label class="control-label" for="unit">Unit Symbol:</label>
                            <div id="unit_symbol" class="input-group col-sm-12"></div>
                        </div>
                        <div class="col-sm-4">
                            <h3>Lookup Result</h3>
                            <label class="control-label" for="unit">Prefix Standard Expression:</label>
                            <div id="prefix_desc" class="input-group col-sm-12"></div>
                            <label class="control-label" for="unit">Prefix Symbol:</label>
                            <div id="prefix_symbol" class="input-group col-sm-12"></div>
                        </div>
                    </div>
                </div>
                <div class="col-sm-4">
                    <h3>Unit Convert</h3>
                    <div class="col-sm-6">
                    <label class="control-label" for="unit_from">Unit From:</label>
                    <div class="input-group col-sm-12">
                        <input type="text" id="unit_from" class="form-control" value="" placeholder="Unit text expression" data-toggle="tooltip" title="Unit text expression" oninput="unitConvert();">
                    </div>
                    <br>
                    <label class="control-label" for="value_from">Value From:</label>
                    <div class="input-group col-sm-12">
                        <input type="number" id="value_from" class="form-control" value="" placeholder="orginal value" data-toggle="tooltip" title="orginal value" oninput="unitConvert();">
                    </div>
                    </div>
                    <div class="col-sm-6">
                    <label class="control-label" for="unit_to">Unit To:</label>
                    <div class="input-group col-sm-12">
                        <input type="text" id="unit_to" class="form-control" value="" placeholder="Unit text expression" data-toggle="tooltip" title="Unit text expression" oninput="unitConvert();">
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

