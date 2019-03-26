function readDailyOutput(rawData) {
    let data = [];
    let date = [];
    let daily = {};
    let values = {};
    let max = {};
    let min = {};
    let avg = {};
    let med = {};
    let titleFlg = false;
    let titles = [];
    let yearIdx = 0;
    let doyIdx = 1;
    let dasIdx = 2;
    let rowIdx = 3;
    let colIdx = 4;
    let year = 0;
    let doy = 0;
    let das = 0;
    let row = 0;
    let col = 0;
    for (let i = 0; i < rawData.length; i++) {
        let line = rawData[i].trim();
        if (line.startsWith("*")) {
            data = [];
            date = [];
            daily = {};
            values = {};
            max = {};
            min = {};
            avg = {};
            med = {};
            titleFlg = false;
            titles = [];
            yearIdx = 0;
            doyIdx = 1;
            dasIdx = 2;
            rowIdx = 3;
            colIdx = 4;
            year = 0;
            doy = 0;
            das = 0;
            row = 0;
            col = 0;
        } else if (line.startsWith("@")) {
            titleFlg = true;
            titles = readTitles(line);
            yearIdx = titles.indexOf("YEAR");
            doyIdx = titles.indexOf("DOY");
            dasIdx = titles.indexOf("DAS");
            rowIdx = titles.indexOf("ROW");
            colIdx = titles.indexOf("COL");
//            console.log(titles);
        } else if (line.startsWith("!") || line.length === 0) {
            continue;
        } else if (titleFlg) {
            let vals = line.split(/\s+/);
            let limit = Math.min(titles.length, vals.length);
            if (limit < vals.length) {
                console.log("line " + i + " have less data than title");
            }
            row = Number(vals[rowIdx]);
            col = Number(vals[colIdx]);
            if (das !== vals[dasIdx]) {
                year = vals[yearIdx];
                doy = vals[doyIdx];
                das = vals[dasIdx];
                date.push({YEAR: year, DOY: doy, DAS: das});
                daily = {DAS: das};
                data.push(daily);
                for (let j = 0; j < limit; j++) {
                    if (j !== yearIdx && j !== doyIdx && j !== dasIdx && j !== rowIdx && j !== colIdx) {
                        daily[titles[j]] = [[]];
                        if (values[titles[j]] === undefined) {
                            values[titles[j]] = [];
                        }
                    }
                }
            }
            for (let j = 0; j < limit; j++) {
                if (j !== yearIdx && j !== doyIdx && j !== dasIdx && j !== rowIdx && j !== colIdx) {
                    while (daily[titles[j]].length < row) {
                        daily[titles[j]].push([]);
                    }
                    let val = Number(vals[j]);
                    daily[titles[j]][row - 1][col - 1] = val;
                    values[titles[j]].push(val);
                    if (max[titles[j]] === undefined || max[titles[j]] < val) {
                        max[titles[j]] = val;
                    }
                    if (min[titles[j]] === undefined || min[titles[j]] > val) {
                        min[titles[j]] = val;
                    }
                }
            }

        }
    }
    titles.splice(titles.indexOf("YEAR"), 1);
    titles.splice(titles.indexOf("DOY"), 1);
    titles.splice(titles.indexOf("DAS"), 1);
    titles.splice(titles.indexOf("ROW"), 1);
    titles.splice(titles.indexOf("COL"), 1);
    
    for (let key in values) {
        avg[key] = average(values[key]);
        med[key] = median(values[key]);
    }
    
    return {"titles":titles, "daily":data, "max":max, "min":min, "average":avg, "median":med};
}

function readSubDailyOutput(rawData) {
    let data = [];
    let subdaily = {};
    let values = {};
    let max = {};
    let min = {};
    let avg = {};
    let med = {};
    let maxAll = {};
    let minAll = {};
    let titleFlg = false;
    let titles = [];
    let yearIdx = 0;
    let doyIdx = 1;
    let dasIdx = 2;
    let timeIdx = 3;
    let incrIdx = 4;
    let rowIdx = 5;
    let colIdx = 6;
    let year = 0;
    let doy = 0;
    let das = 0;
    let time = 0;
    let row = 0;
    let col = 0;
    for (let i = 0; i < rawData.length; i++) {
        let line = rawData[i].trim();
        if (line.startsWith("@")) {
            titleFlg = true;
            titles = readTitles(line);
            yearIdx = titles.indexOf("YEAR");
            doyIdx = titles.indexOf("DOY");
            dasIdx = titles.indexOf("DAS");
            timeIdx = titles.indexOf("TIME");
            incrIdx = titles.indexOf("INCR");
            rowIdx = titles.indexOf("ROW");
            colIdx = titles.indexOf("COL");
//            console.log(titles);
        } else if (line.startsWith("!") || line.length === 0) {
            continue;
        } else if (titleFlg) {
            let vals = line.split(/\s+/);
            let limit = Math.min(titles.length, vals.length);
            if (limit < vals.length) {
                console.log("line " + i + " have less data than title");
            }
            row = Number(vals[rowIdx]);
            col = Number(vals[colIdx]);
            if (das + time !== vals[dasIdx] + vals[timeIdx]) {
                year = vals[yearIdx];
                doy = vals[doyIdx];
                das = vals[dasIdx];
                time = vals[timeIdx];
                subdaily = {TS: getUTCDateFromDoy(year, doy, time), TSAS: Number(das) + Number(time) / 1440};
                data.push(subdaily);
                for (let j = 0; j < limit; j++) {
                    if (j !== yearIdx && j !== doyIdx && j !== dasIdx && j !== timeIdx && j !== incrIdx && j !== rowIdx && j !== colIdx) {
                        subdaily[titles[j]] = [[]];
                        if (values[titles[j]] === undefined) {
                            values[titles[j]] = [[[]]];
                        }
                        if (max[titles[j]] === undefined) {
                            max[titles[j]] = [[]];
                        }
                        if (min[titles[j]] === undefined) {
                            min[titles[j]] = [[]];
                        }
                    }
                }
            }
            for (let j = 0; j < limit; j++) {
                if (j !== yearIdx && j !== doyIdx && j !== dasIdx && j !== timeIdx && j !== incrIdx && j !== rowIdx && j !== colIdx) {
                    let val = Number(vals[j]);
                    while (subdaily[titles[j]].length < row) {
                        subdaily[titles[j]].push([]);
                    }
                    subdaily[titles[j]][row - 1][col - 1] = val;
                    while (values[titles[j]].length < row) {
                        values[titles[j]].push([]);
                    }
                    while (values[titles[j]][row - 1].length < col) {
                        values[titles[j]][row - 1].push([]);
                    }
                    values[titles[j]][row - 1][col - 1].push(val);
                    while (max[titles[j]].length < row) {
                        max[titles[j]].push([]);
                    }
                    if (max[titles[j]][row - 1][col - 1] === undefined || max[titles[j]][row - 1][col - 1] < val) {
                        max[titles[j]][row - 1][col - 1] = val;
                    }
                    if (!maxAll[titles[j]] || maxAll[titles[j]] < val) {
                        maxAll[titles[j]] = val;
                    }
                    while (min[titles[j]].length < row) {
                        min[titles[j]].push([]);
                    }
                    if (min[titles[j]][row - 1][col - 1] === undefined || min[titles[j]][row - 1][col - 1] > val) {
                        min[titles[j]][row - 1][col - 1] = val;
                    }
                    if (!minAll[titles[j]] || minAll[titles[j]] > val) {
                        minAll[titles[j]] = val;
                    }
                }
            }

        }
    }
    titles.splice(titles.indexOf("YEAR"), 1);
    titles.splice(titles.indexOf("DOY"), 1);
    titles.splice(titles.indexOf("DAS"), 1);
    titles.splice(titles.indexOf("TIME"), 1);
    titles.splice(titles.indexOf("INCR"), 1);
    titles.splice(titles.indexOf("ROW"), 1);
    titles.splice(titles.indexOf("COL"), 1);
    
    for (let key in values) {
        avg[key] = [];
        med[key] = [];
        for (let i in values[key]) {
            avg[key].push([]);
            med[key].push([]);
            for (let j in values[key][i]) {
                avg[key][i].push(average(values[key][i][j]));
                med[key][i].push(median(values[key][i][j]));
            }
        }
    }
    
    return {"titles":titles, "subdaily":data, "max":max, "min":min, "average":avg, "median":med, "maxAll":maxAll, "minAll":minAll};
}

function readSubDailyObv(rawData) {
    let data = [];
    let subdaily = {};
    let values = {};
    let max = {};
    let min = {};
    let avg = {};
    let med = {};
    let maxAll = {};
    let minAll = {};
    let titleFlg = false;
    let titles = [];
    let trtnoIdx = 0;
    let dateIdx = 1;
    let date;
    for (let i = 0; i < rawData.length; i++) {
        let line = rawData[i].trim();
        if (line.startsWith("@")) {
            titleFlg = true;
            titles = readCSVTitles(line);
            trtnoIdx = titles.indexOf("TRTNO");
            dateIdx = titles.indexOf("Date");
//            console.log(titles);
        } else if (line.startsWith("!") || line.length === 0) {
            continue;
        } else if (titleFlg) {
            let vals = line.split(",");
            let limit = Math.min(titles.length, vals.length);
            if (limit < vals.length) {
                console.log("line " + i + " have less data than title");
            }
            date = vals[dateIdx];
            subdaily = {TS: new Date(date)};
            data.push(subdaily);
            for (let j = 0; j < limit; j++) {
                if (j !== trtnoIdx && j !== dateIdx) {
                    let valName = titles[j][0];
                    row = titles[j][1];
                    col = titles[j][2];
                    if (subdaily[valName] === undefined) {
                        subdaily[valName] = [[]];
                    }
                    if (values[valName] === undefined) {
                        values[valName] = [[[]]];
                    }
                    if (max[valName] === undefined) {
                        max[valName] = [[]];
                    }
                    if (min[valName] === undefined) {
                        min[valName] = [[]];
                    }
                    let val = Number(vals[j]);
                    while (subdaily[valName].length < row) {
                        subdaily[valName].push([]);
                    }
                    subdaily[valName][row - 1][col - 1] = val;
                    while (values[valName].length < row) {
                        values[valName].push([[]]);
                    }
                    while (values[valName][row - 1].length < col) {
                        values[valName][row - 1].push([]);
                    }
                    values[valName][row - 1][col - 1].push(val);
                    while (max[valName].length < row) {
                        max[valName].push([]);
                    }
                    if (max[valName][row - 1][col - 1] === undefined || max[valName][row - 1][col - 1] < val) {
                        max[valName][row - 1][col - 1] = val;
                    }
                    if (!maxAll[valName] || maxAll[valName] < val) {
                        maxAll[valName] = val;
                    }
                    while (min[valName].length < row) {
                        min[valName].push([]);
                    }
                    if (min[valName][row - 1][col - 1] === undefined || min[valName][row - 1][col - 1] > val) {
                        min[valName][row - 1][col - 1] = val;
                    }
                    if (!minAll[valName] || minAll[valName] > val) {
                        minAll[valName] = val;
                    }
                }
            }

        }
    }
    titles.splice(titles.indexOf("Date"), 1);
    titles.splice(titles.indexOf("TRTNO"), 1);
    
    for (let key in values) {
        avg[key] = [];
        med[key] = [];
        for (let i in values[key]) {
            avg[key].push([]);
            med[key].push([]);
            for (let j in values[key][i]) {
                avg[key][i].push(average(values[key][i][j]));
                med[key][i].push(median(values[key][i][j]));
            }
        }
    }
    
    return {"titles":titles, "subdaily":data, "max":max, "min":min, "average":avg, "median":med, "maxAll":maxAll, "minAll":minAll};
}

function readSoilWat(rawData) {
    let data = [];
    let date = [];
    let daily = {};
    let values = {};
    let max = {};
    let min = {};
    let avg = {};
    let med = {};
    let titleFlg = false;
    let titles = [];
    let yearIdx = 0;
    let doyIdx = 1;
    let dasIdx = 2;
    let year = 0;
    let doy = 0;
    let das = 0;
    let perc = 0;
    let irrc = 0;
    for (let i = 0; i < rawData.length; i++) {
        let line = rawData[i].trim();
        if (line.startsWith("*")) {
            data = [];
            date = [];
            daily = {};
            values = {};
            max = {};
            min = {};
            avg = {};
            med = {};
            titleFlg = false;
            titles = [];
            yearIdx = 0;
            doyIdx = 1;
            dasIdx = 2;
            year = 0;
            doy = 0;
            das = 0;
            perc = 0;
            irrc = 0;
        } else if (line.startsWith("@")) {
            titleFlg = true;
            titles = readTitles(line);
            yearIdx = titles.indexOf("YEAR");
            doyIdx = titles.indexOf("DOY");
            dasIdx = titles.indexOf("DAS");
            for (let j = 0; j < titles.length; j++) {
                if (j !== yearIdx && j !== doyIdx && j !== dasIdx && j) {
                    if (values[titles[j]] === undefined) {
                        values[titles[j]] = [];
                    }
                }
            }
            values["PRED"] = [];
            values["IRRD"] = [];
//            console.log(titles);
        } else if (line.startsWith("!") || line.length === 0) {
            continue;
        } else if (titleFlg) {
            let vals = line.split(/\s+/);
            let limit = Math.min(titles.length, vals.length);
            if (limit < vals.length) {
                console.log("line " + i + " have less data than title");
            }
            if (das !== vals[dasIdx]) {
                year = vals[yearIdx];
                doy = vals[doyIdx];
                das = vals[dasIdx];
                date.push({YEAR: year, DOY: doy, DAS: das});
                daily = {DAS: das, DATE: getUTCDateFromDoy(year, doy)};
                data.push(daily);
            }
            for (let j = 0; j < limit; j++) {
                if (j !== yearIdx && j !== doyIdx && j !== dasIdx && j) {
                    let val = Number(vals[j]);
                    daily[titles[j]] = val;
                    values[titles[j]].push(val);
                    if (max[titles[j]] === undefined || max[titles[j]] < val) {
                        max[titles[j]] = val;
                    }
                    if (min[titles[j]] === undefined || min[titles[j]] > val) {
                        min[titles[j]] = val;
                    }
                    if (titles[j] === "PREC") {
                        let val = Number(vals[j]) - perc;
                        perc = Number(vals[j]);
                        daily["PRED"] = val;
                        values["PRED"].push(val);
                        if (max["PRED"] === undefined || max["PRED"] < val) {
                            max["PRED"] = val;
                        }
                        if (min["PRED"] === undefined || min["PRED"] > val) {
                            min["PRED"] = val;
                        }
                    } else if (titles[j] === "IRRC") {
                        let val = Number(vals[j]) - irrc;
                        irrc = Number(vals[j]);
                        daily["IRRD"] = val;
                        values["IRRD"].push(val);
                        if (max["IRRD"] === undefined || max["IRRD"] < val) {
                            max["IRRD"] = val;
                        }
                        if (min["IRRD"] === undefined || min["IRRD"] > val) {
                            min["IRRD"] = val;
                        }
                    }
                }
            }
            
        }
    }
    titles.splice(titles.indexOf("YEAR"), 1);
    titles.splice(titles.indexOf("DOY"), 1);
    titles.splice(titles.indexOf("DAS"), 1);
    titles.splice(titles.indexOf("ROW"), 1);
    titles.splice(titles.indexOf("COL"), 1);
    titles.push("PRED");
    titles.push("IRRD");
    
    for (let key in values) {
        avg[key] = average(values[key]);
        med[key] = median(values[key]);
    }
    
    return {"titles":titles, "daily":data, "max":max, "min":min, "average":avg, "median":med};
}

function readSoilWatTS(rawData) {
    let data = [];
    let date = [];
    let subdaily = {};
    let values = {};
    let max = {};
    let min = {};
    let avg = {};
    let med = {};
    let titleFlg = false;
    let titles = [];
    let yearIdx = 0;
    let doyIdx = 1;
    let dasIdx = 2;
    let timeIdx = 3;
    let incrIdx = 4;
    let year = 0;
    let doy = 0;
    let das = 0;
    let time = 0;
    let incr = 0;
    for (let i = 0; i < rawData.length; i++) {
        let line = rawData[i].trim();
        if (line.startsWith("*")) {
            data = [];
            date = [];
            subdaily = {};
            values = {};
            max = {};
            min = {};
            avg = {};
            med = {};
            titleFlg = false;
            titles = [];
            yearIdx = 0;
            doyIdx = 1;
            dasIdx = 2;
            timeIdx = 3;
            incrIdx = 4;
            year = 0;
            doy = 0;
            das = 0;
            time = 0;
            incr = 0;
        } else if (line.startsWith("@")) {
            titleFlg = true;
            titles = readTitles(line);
            yearIdx = titles.indexOf("YEAR");
            doyIdx = titles.indexOf("DOY");
            dasIdx = titles.indexOf("DAS");
            timeIdx = titles.indexOf("TIME");
            incrIdx = titles.indexOf("INCR");
            for (let j = 0; j < titles.length; j++) {
                if (j !== yearIdx && j !== doyIdx && j !== dasIdx && j) {
                    if (values[titles[j]] === undefined) {
                        values[titles[j]] = [];
                    }
                }
            }
//            console.log(titles);
        } else if (line.startsWith("!") || line.length === 0) {
            continue;
        } else if (titleFlg) {
            let vals = line.split(/\s+/);
            let limit = Math.min(titles.length, vals.length);
            if (limit < vals.length) {
                console.log("line " + i + " have less data than title");
            }
            if (das + time !== vals[dasIdx] + vals[timeIdx]) {
                year = vals[yearIdx];
                doy = vals[doyIdx];
                das = vals[dasIdx];
                time = vals[timeIdx];
                incr = vals[incrIdx];
                subdaily = {TS: getUTCDateFromDoy(year, doy, time), INCR: Number(incr)};
                data.push(subdaily);
            }
            for (let j = 0; j < limit; j++) {
                if (j !== yearIdx && j !== doyIdx && j !== dasIdx && j && j !== timeIdx && j !== incrIdx) {
                    let val = Number(vals[j]);
                    subdaily[titles[j]] = val;
                    values[titles[j]].push(val);
                    if (max[titles[j]] === undefined || max[titles[j]] < val) {
                        max[titles[j]] = val;
                    }
                    if (min[titles[j]] === undefined || min[titles[j]] > val) {
                        min[titles[j]] = val;
                    }
                }
            }
            
        }
    }
    titles.splice(titles.indexOf("YEAR"), 1);
    titles.splice(titles.indexOf("DOY"), 1);
    titles.splice(titles.indexOf("DAS"), 1);
    titles.splice(titles.indexOf("ROW"), 1);
    titles.splice(titles.indexOf("COL"), 1);
    
    for (let key in values) {
        avg[key] = average(values[key]);
        med[key] = median(values[key]);
    }
    
    return {"titles":titles, "subdaily":data, "max":max, "min":min, "average":avg, "median":med};
}

function readInfoOut(rawData) {
    let data = {};
    let profileFlg = false;
    let titleFlg = false;
    let titles = [];
    let units = {};
    let vals;
    for (let i = 0; i < rawData.length; i++) {
        let line = rawData[i].trim();
        if (line.startsWith("CONSTRUCTED BED")) {
            profileFlg = true;
        } else if (profileFlg) {
            if (line.startsWith("DS DLAYR    LL   DUL   SAT  Root    BD    OC  CLAY  SILT  SAND")) {
                titles = readTitles(" LYR " + line + " PH");
                for (let j = 0; j < titles.length; j++) {
                    data[titles[j]] = [];
                }
                titleFlg = true;
            } else if (line.startsWith("LYR  cm    cm  frac  frac  frac  Grow g/cm3     %     %     %     %    pH")) {
                let tmp = line.split(/\s+/);
                let limit = Math.min(titles.length, tmp.length);
                for (let j = 0; j < limit; j++) {
                    units[titles[j]] = tmp[j];
                }
                titleFlg = true;
            } else if (line.startsWith("SOILDYN  YEAR DOY") || line === "") {
                profileFlg = false;
                titleFlg = false;
                break;
            } else if (titleFlg) {
                vals = line.split(/\s+/);
                let limit = Math.min(titles.length, vals.length);
                if (limit < vals.length) {
                    console.log("line " + i + " have less data than title");
                }
                for (let j = 0; j < limit; j++) {
                    let val = Number(vals[j]);
                    data[titles[j]].push(val);
                }
            }
        }
    }
    return {"titles":titles, "units":units, "data":data};
}

function average(values) {
    let sum = 0;
    for (let i in values) {
        sum += values[i];
    }
    if (values.length >0 ) {
        return sum/values.length;
    } else {
        return 0;
    }
}

function median(values){
    values.sort(function(a,b){
    return a-b;
  });

  if(values.length ===0) return 0;

  var half = Math.floor(values.length / 2);

  if (values.length % 2)
    return values[half];
  else
    return (values[half - 1] + values[half]) / 2.0;
}

function readTitles(line) {
    let titles = line.substring(1).split(/\s+/);
    let repeated = ["NFluxR", "NFluxL", "NFluxD", "NFluxU"];
    let appdex = ["A", "D"];
    for (let i = 0; i < repeated.length; i++) {
        let idx = titles.indexOf(repeated[i]);
        let j = 0;
        while (idx > -1) {
            if (j < appdex.length) {
                titles[idx] = titles[idx] + "_" + appdex[j];
            } else {
                titles[idx] = titles[idx] + "_" + j;
            }
            idx = titles.indexOf(repeated[i]);
            j++;
        }
    }
    return titles;
}

function readCSVTitles(line) {
    let titles = line.split(",");
    titles[0] = "TRTNO";
    for (let i = 1; i < titles.length; i++) {
        if (titles[i].includes("_")) {
            titles[i] = titles[i].split("_");
        }
    }
    return titles;
}

function getSoilStructure(data) {
    let soilProfile = {};
    if (data.length > 0) {
        let lastDay = data[data.length - 1];
        let keys = Object.keys(lastDay);
        if (keys.indexOf("DAS") > -1) {
            keys.splice(keys.indexOf("DAS"), 1);
        }
        if (keys.indexOf("TS") > -1) {
            keys.splice(keys.indexOf("TS"), 1);
        }
        if (keys.indexOf("TSAS") > -1) {
            keys.splice(keys.indexOf("TSAS"), 1);
        }
        if (keys.length > 0) {
            let randomData = lastDay[keys[0]];
            let totRows = randomData.length;
            let totCols = 0;
            let bedRows = 0;
            let bedCols = 0;
            if (totRows > 0) {
                totCols = randomData[totRows - 1].length;
                bedCols = randomData[0].length;
                while (bedRows < totRows && randomData[bedRows].length === bedCols) {
                    bedRows++;
                }
            }
            soilProfile["totRows"] = totRows;
            soilProfile["totCols"] = totCols;
            soilProfile["bedRows"] = bedRows;
            soilProfile["bedCols"] = bedCols;
        }
    }
    return soilProfile;
}

function getDateFromDoy (year, doy, hour) {

    let date = new Date(year, 0, 0, 0, 0, 0, 0);
    if (doy === undefined) {
        return date;
    }
    let timeOfFirst = date.getTime(); // this is the time in milliseconds of 1/1/YYYY
    let dayMilli = 1000 * 60 * 60 * 24;
    doy = Number(doy);
    if (hour !== undefined) {
        doy += Number(hour) / 24;
    }
    date.setTime(timeOfFirst + doy * dayMilli);
    return date;
}

function getUTCDateFromDoy (year, doy, hour) {

    let date = Date.UTC(year, 0, 0, 0, 0, 0, 0);
    if (doy === undefined) {
        return date;
    }
    let dayMilli = 1000 * 60 * 60 * 24;
    doy = Number(doy);
    if (hour !== undefined) {
        doy += Number(hour) / 24;
    }
    return date + doy * dayMilli;
}