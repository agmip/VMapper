let reader;

function abortRead() {
    if (reader !== undefined) {
        reader.abort();
    }
}

function errorHandler(evt) {
    switch (evt.target.error.code) {
        case evt.target.error.NOT_FOUND_ERR:
            alert('File Not Found!');
            break;
        case evt.target.error.NOT_READABLE_ERR:
            alert('File is not readable');
            break;
        case evt.target.error.ABORT_ERR:
            break; // noop
        default:
            alert('An error occurred reading this file.');
    }
    ;
}

function readFileToBufferedArray(progressCallBack, resultHandleCallBack) {
    let files = document.getElementById('output_file').files;
    if (files.length !== 1) {
//        alert('Please select one file!');
        return;
    }
    // Reset progress indicator on new file selection.
    progressCallBack(0);
    document.getElementById('plot_options').hidden = true;
    document.getElementById('output_file_plot').hidden = true;
    reader = new FileReader();
    reader.onerror = errorHandler;
    let file = files[0];
    let unitName = file.name.slice(0, -5);
    let cache = 40960;
    let start = 0;
    let stop = Math.min(cache, file.size);
    let lineNum = 0;
    let result = [];
    result[0] = "";

    reader.onloadend = function (evt) {
        if (evt.target.readyState === FileReader.DONE) { // DONE == 2
            // Update the progress bar
            progressCallBack(stop / file.size);

            // Handle the cached content
            let tmp = evt.target.result;
            let tmpArr = tmp.split(/\r\n|\n\r|\r|\n/);
            result[lineNum] += tmpArr[0];
            for (let i = 1; i < tmpArr.length; i++) {
                lineNum++;
                result[lineNum] = tmpArr[i];
            }

            // Continue for the next pieces
            if (stop < file.size) {
                start = stop;
                stop = Math.min(stop + cache, file.size);
                let blob = file.slice(start, Math.min(stop, file.size));
                reader.readAsBinaryString(blob);
            } else {
                resultHandleCallBack(result);
            }
        }
    };

    let blob = file.slice(start, stop);
    reader.readAsBinaryString(blob);

}