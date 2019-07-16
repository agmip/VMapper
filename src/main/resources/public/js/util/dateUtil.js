const dateUtil = {};

dateUtil.toYYYYMMDDStr = function (date) {
    if (!date) {
        return "";
    }
    let year, month, day;
    if (typeof date === "string" || date instanceof String) {
        if (date.match(/\d{1,2}\/\d{1,2}\/\d{4}/)) {
            let tmp = date.split("/");
            year = tmp[2];
            month = tmp[0];
            day = tmp [1];
        } else if (date.match(/\d{4}\/\d{1,2}\/\d{1,2}/)) {
            let tmp = date.split("/");
            year = tmp[0];
            month = tmp[1];
            day = tmp [2];
        } else if (date.match(/\d{4}-\d{1,2}-\d{1,2}/)) {
            let tmp = date.split("-");
            year = tmp[0];
            month = tmp[1];
            day = tmp [2];
        } else if (date.match(/\d{5}/)) {
            year = date.substring(0, 2);
            if (Number(year) > 50) {
                year = "19" + year;
            } else {
                year = "20" + year;
            }
            let doy = Number(date.substring(2));
            let tmp = new Date(year, 0, doy);
            month = (tmp.getMonth() + 1).toString();
            day = tmp.getDate().toString();
        } else {
            return date;
        }
    } else if (date instanceof Date) {
        year = date.getFullYear().toString();
        month = (date.getMonth() + 1).toString();
        day = date.getDate().toString();
    } else {
        return "";
    }
    
    if (month.length === 1) {
        month = "0" + month;
    }
    if (day.length === 1) {
        day = "0" + day;
    }
    return year + "-" + month + "-" + day;
};

dateUtil.toLocaleDate = function (date, time) {
    if (!date) {
        return date;
    }
    let localeDate;
    let tmp = [];
    if (time) {
        tmp = time.split(":");
    }
    if (typeof date === "string" || date instanceof String) {
        let UTCDate;
        if (date.match(/\d{4}-\d{2}-\d{2}/)) {
        } else if (date.match(/\d{1,2}\/\d{1,2}\/\d{4}/) ||
                date.match(/\d{4}\/\d{1,2}\/\d{1,2}/) ||
                date.match(/\d{5}/)) {
            date = dateUtil.toYYYYMMDDStr(date);
        } else {
            return date;
        }
        UTCDate = new Date(date);
        if (tmp && tmp.length === 2) {
            localeDate = new Date(UTCDate.getUTCFullYear(), UTCDate.getUTCMonth(), UTCDate.getUTCDate(), Number(tmp[0]), Number(tmp[1]), 0, 0);
        } else {
            localeDate = new Date(UTCDate.getUTCFullYear(), UTCDate.getUTCMonth(), UTCDate.getUTCDate(), 0, 0, 0, 0);
        }
        return localeDate;
    } else {
        return date;
    }
};

dateUtil.toLocaleStr = function (date, time) {
    if (!date) {
        return "";
    }
    let localeDate = dateUtil.toLocaleDate(date, time);
    return localeDate.toLocaleDateString();
};