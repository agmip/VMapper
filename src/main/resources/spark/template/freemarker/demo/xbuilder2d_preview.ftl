<script>    
    function switchPreviewViewType(target) {
        let showBtn, hideBtn, showDiv, hideDiv;
        if (target.id === "json_swc_btn") {
            hideBtn = $("#dssat_swc_btn");
            hideDiv = $("#dssat_preview");
            showBtn = $("#json_swc_btn");
            showDiv = $("#json_preview");
        } else {
            hideBtn = $("#json_swc_btn");
            hideDiv = $("#json_preview");
            showBtn = $("#dssat_swc_btn");
            showDiv = $("#dssat_preview");
        }
        if(showBtn.hasClass("btn-primary")) {
            return;
        }
        hideBtn.removeClass("btn-primary").addClass("btn-default");
        showBtn.removeClass("btn-default").addClass("btn-primary");
        hideDiv.fadeOut("fast",function() {
            showDiv.fadeIn("fast", updatePreview);
        });
    }
    
    function updatePreview() {
        if ($("#json_swc_btn").hasClass("btn-primary")) {
            updateJsonPreview();
        } else {
            updateDssatPreview();
        }
    }
    
    function updateJsonPreview() {
        $('#json_preview').html("<div><h3>Experiment Data</h3>" +
                JSON.stringify(expData) +
                "</div><div><h3>Field List</h3>" +
                JSON.stringify(fields) +
                "</div><div><h3>Treatment List</h3>" +
                JSON.stringify(trtData) +
                "</div>");
    }
    
    function updateDssatPreview() {
        $.post("/translator/dssat_exp",
            {
                exp: JSON.stringify(expData),
                field: JSON.stringify(fieldData),
                treatment: JSON.stringify(trtData)
            },
            function (xfile) {
                $('#dssat_preview_text').html(xfile);
            }
        );
    }
</script>

<div class="subcontainer">
    <fieldset>
        <legend>
            Experiment Data&nbsp;&nbsp;&nbsp;
            <div class="btn-group slider">
                <button id="json_swc_btn" type="button" class="btn btn-primary" onclick="switchPreviewViewType(this);">&nbsp;&nbsp;JSON&nbsp;&nbsp;</button>
                <button id="dssat_swc_btn" type="button" class="btn btn-default" onclick="switchPreviewViewType(this);">DSSAT</button>
            </div>
        </legend>
        <div id="json_preview" class="form-group col-sm-12"></div>
        <div id="dssat_preview" class="form-group col-sm-12" hidden><textarea class="form-control" rows="25" id="dssat_preview_text" style="font-family:Consolas,Monaco,Lucida Console,Liberation Mono,DejaVu Sans Mono,Bitstream Vera Sans Mono,Courier New, monospace;" readonly></textarea></div>

    </fieldset>
</div>

