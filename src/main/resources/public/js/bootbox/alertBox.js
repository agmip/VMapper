function alertBox(msg, callback) {
    if (callback) {
        bootbox.alert({
            message: msg,
            backdrop: true,
            callback: callback
        });
    } else {
        bootbox.alert({
            message: msg,
            backdrop: true
        });
    }
}

function confirmBox(msg, callback) {
    bootbox.confirm({
        message: msg,
        callback: function (result) {
            if (result) {
                callback();
            }
        }
    });
}
