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
        $('#json_preview').html(JSON.stringify(expData));
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
        <div id="dssat_preview" class="form-group col-sm-12" hidden>
            under construction...
        </div>

    </fieldset>
</div>

