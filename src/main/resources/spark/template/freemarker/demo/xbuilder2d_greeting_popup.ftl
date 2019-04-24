<script>
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
            title: '<h3><mark class="bg-primary">Welcome to XBuilder 2D online tool</mark><h3>',
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
                    } else {
                        showGreetingPrompt(inputType, "[" + inputType + "] is not ready to use yet...");
                    }
                }
            }
        });
    }
</script>