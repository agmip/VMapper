/* global FileReader */

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
}

function readFileToBufferedArray(file, progressCallBack, resultHandleCallBack, filesInfo) {
    
    // Reset progress indicator on new file selection.
    if (filesInfo === undefined) {
        progressCallBack(0);
    } else {
        progressCallBack(filesInfo.idx/filesInfo.total);
    }
    
    reader = new FileReader();
    reader.onerror = errorHandler;
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
            if (filesInfo === undefined) {
                progressCallBack(stop / file.size);
            } else {
                progressCallBack((stop / file.size + filesInfo.idx)/filesInfo.total);
            }

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
                resultHandleCallBack(result, file);
            }
        }
    };

    let blob = file.slice(start, stop);
    reader.readAsBinaryString(blob);

}