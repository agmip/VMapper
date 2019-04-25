<script>
    const POPUP_TITLE = "Welcome to XBuilder 2D online tool";
    
    function showGreetingPrompt(inputType, msg) {
        if (!inputType) {
            inputType = "scratch";
        }
        if (msg) {
            msg = '<p><mark class="bg-info">Please choose a way to start your data input:</mark><br><span><mark class="bg-warning">' + msg + '</mark></span></p>';
        } else {
            msg = '<p><mark class="bg-info">Please choose a way to start your data input:</mark></p>';
        }
        bootbox.prompt({
            title: '<h3><mark class="bg-primary">' + POPUP_TITLE + '</mark><h3>',
            message: msg,
            size: 'large',
            inputType: 'radio',
            value: inputType,
            backdrop: true,
            inputOptions: [
                    {text: 'Start from scratch',        value: 'scratch'},
                    {text: 'Use a template',            value: 'template'},
                    {text: 'Load from a local file',    value: 'local'},
                    {text: 'Load from a remote record', value: 'remote'}
                ],
            callback: function(result){ 
                if (result) {
                    if (result === "scratch") {
                    } else if (result === "local") {
                        openFile();
                    } else if (result === "template") {
                        showTemplatePrompt();
                    } else {
                        showGreetingPrompt(inputType, "[" + inputType + "] is not ready to use yet...");
                    }
                }
            }
        });
    }
    
    function showTemplatePrompt(templateType, msg) {
        if (!templateType) {
            templateType = "simple";
        }
        if (msg) {
            msg = '<p><mark class="bg-info">Please choose a template to start your data input:</mark><br><span><mark class="bg-warning">' + msg + '</mark></span></p>';
        } else {
            msg = '<p><mark class="bg-info">Please choose a template to start your data input:</mark></p>';
        }
        bootbox.prompt({
            title: '<h3><mark class="bg-primary">' + POPUP_TITLE + '</mark><h3>',
            message: msg,
            size: 'large',
            inputType: 'radio',
            value: templateType,
            inputOptions: [
                    {text: 'Simple simulation with sinlge treatment ',        value: 'simple'},
                    {text: 'Multi-treatments combined by multiple factors',   value: 'factors'}
                ],
            callback: function(result){ 
                if (result) {
                    if (result === "simple") {
                        loadSimpleTemplate();
                    } else if (result === "factors") {
                        // TODO
                        showTemplatePrompt(templateType, "[" + templateType + "] is not ready to use yet...");
                    } else {
                        showTemplatePrompt(templateType, "[" + templateType + "] is not ready to use yet...");
                    }
                } else {
                    showGreetingPrompt("template");
                }
            }
        });
    }
    
    function loadSimpleTemplate() {
        loadData('{"experiment":{"local_name":"Simple simulation with single treatment"},"cultivar":{},"field":{"field_0":{"fl_name":"Default"}},"management":{"mgn_0":{"mgn_name":"Default","data":[]}},"treatment":[{"trtno":1,"management":["mgn_0"],"field":"field_0"}],"version":"0.0.1"}');
    }
</script>