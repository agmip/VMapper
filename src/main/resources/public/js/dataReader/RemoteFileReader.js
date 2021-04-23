class RemoteFileReader {
    constructor(path) {
        let port = "";
        if (location.port !== "") {
            port = ":" + location.port;
        }
        this.wsAddrLocal = "wss://" + location.hostname + port + path;
        if (location.protocol === "http:") {
            this.wsAddrLocal = "ws://" + location.hostname + port + path;
        }
        this.fileUrl = null;
        this.wsLocal = null;
        this.alive = false;
        this.result = null;
        this.fileName = null;
        this.fileType = null;
        this.fileSize = null;
        this.buffSize = null;
        this.textResult = false;
        this.onloadend = function () {};
        this.onload = function () {};
        this.onerror = function (msg) { alert(msg); };
    }

    keepLocalConn() {
        this.wsLocal.onmessage = $.proxy(function (msg) {
            this.processLocalMsg(msg);
        }, this);
        this.wsLocal.onclose = $.proxy(function () {
            if (this.alive) {
                this.wsLocal = new WebSocket(this.wsAddrLocal);
                this.keepLocalConn();
                this.wsLocal.onopen = $.proxy(this.sendResentRequest, this);
            } else {
                this.result = this.result.join('');
                if (this.textResult) {
                    this.result = decodeURIComponent(escape(this.result));
                }
                this.onloadend({target:this});
            }
        }, this);
    }

    sendInitRequest() {
        let request = {
            action: "Init",
            file_url: this.fileUrl
        };
        this.wsLocal.send(JSON.stringify(request));
    }

    sendResentRequest(buff_idx) {
        let request = {
            action: "Resent",
            buff_idx: buff_idx
        };
        this.wsLocal.send(JSON.stringify(request));
    }

    sendReceivedRequest(buff_idx) {
        let request = {
            action: "Received",
            buff_idx: buff_idx
        };
        this.wsLocal.send(JSON.stringify(request));
    }

    sendEndRequest() {
        let request = {
            action: "Finish"
        };
        this.wsLocal.send(JSON.stringify(request));
    }

    processLocalMsg(msg) {
        let data = JSON.parse(msg.data);
        let status = Number(data.status);
        if (data.action === "Init" && status === 200) {
            this.fileName = unescape(data.name);
            this.fileType = data.type;
            this.fileSize = data.size;
        } else if (data.action === "Sent") {
            if (status === 200) {
                this.result[data.idx] = window.atob(data.buff);
                this.buffSize += data.size;
                this.sendReceivedRequest(data.idx);
                this.onload({target:this});
            } else {
                this.sendResentRequest(data.idx);
            }
//            } else if (data.action === "AllSent" &&  status === 200) {
//                this.result[data.buff_idx] = data.buff_data;
//                this.sendReceivedRequest(data.buff_idx);
        } else if (data.action === "Finish" && status === 200) {
            this.alive = false;
            this.sendEndRequest();
            this.wsLocal.close();
        }
        else if (status === 601) {
            this.alive = false;
            this.onerror("Server connection lost, please refresh your page.");
        } else if (status === 602) {
            this.sendResentRequest(data.idx);
        } else if (status === 900) {
            this.alive = false;
            this.onerror("There is an error happened during loading your file, caused by [" + data.message + "]");
        }
    }

    readAsBinaryString(fileUrl) {
        this.fileUrl = fileUrl;
        this.alive = true;
        this.result = [];
        this.buffSize = 0;
        this.wsLocal = new WebSocket(this.wsAddrLocal);
        this.wsLocal.onopen = $.proxy(this.sendInitRequest, this);
        this.keepLocalConn();
    }
    
    readAsText(fileUrl) {
        this.readAsBinaryString(fileUrl);
        this.textResult = true;
    }
    
    getReadingProgressPct() {
        return this.buffSize / this.fileSize * 100;
    }
}
