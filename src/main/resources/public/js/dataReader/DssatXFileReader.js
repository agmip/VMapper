function readXFileData(rawData, fileName) {
    let expData = {};
    let culData = {};
    let fldData = {};
    let mgnData = {};
    let trtData = [];
    let trtDataRaw = [];
    let culDataRaw = {};
    let icDataRaw = {};
    let mgnDataLinkRaw = {
        planting : {},
        irrigation : {},
        fertilizer : {},
        harvest : {}
    };
    let mgnDataRaw = {};
    let mgnDataIdRaw = {};
    let irrProfileRaw = {};
    let dripDataRaw = {};
    const version = "0.0.1";
    let titleLine = "";
    let headerLine = "";
    let formats = {};
    
    expData.exname = fileName.substring(0, 8);
    expData.institute = fileName.substring(0, 2);
    expData.site = fileName.substring(2, 4);
    expData.start_year = fileName.substring(4, 6);
    if (expData.start_year) {
        if (Number(expData.start_year) > 50) {
            expData.start_year = "19" + expData.start_year;
        } else {
            expData.start_year = "20" + expData.start_year;
        }
    }
    expData.exp_no = fileName.substring(6, 8);
    expData.crid_dssat = fileName.substring(fileName.length - 3, fileName.length - 1);
    
    for (let i = 0; i < rawData.length; i++) {
        let line = rawData[i];
        let symbol = line.trim().substring(0, 1);
        
        if (symbol === "*") {
            // section title line
            line = line.substring(1);
            titleLine = line.toUpperCase();
            if (titleLine.startsWith("EXP.DETAILS")) {
                formats = {
                    "null_1" : 13,
                    "null_2" : 11, // P.S. Since exname in top line is not reliable, read from file name
                    "local_name" : 61
                };
                // Read line and save into return holder
                readLine(expData, line, formats);
            }
        } else if (symbol === "@") {
            // header line
            headerLine = line.substring(1).toUpperCase();
            
        } else if (symbol === "!") {
            // comment line
        } else if (symbol) {
            // data line
            // General section
            if (headerLine.startsWith("PEOPLE")) {
                expData["people"] = line.trim();
            } else if (headerLine.startsWith("ADDRESS")) {
                expData["address"] = line.trim();
            } else if (headerLine.startsWith("SITE")) {
                expData["site_name"] = line.trim();
            } else if (headerLine.startsWith("NOTES")) {
                if (expData["exp_narr"]) {
                    expData["exp_narr"] += line.trim() + "\r\n";
                } else {
                    expData["exp_narr"] = line.trim() + "\r\n";
                }
            }
            // TREATMENTS Section
            else if (titleLine.startsWith("TREATMENTS")) {
                trtDataRaw.push(readTreatmentLine(line));
            }
            // CULTIVARS Section
            else if (titleLine.startsWith("CULTIVARS")) {
                let tmpData = readCultivarLine(line);
                culDataRaw[tmpData.id] = tmpData;
                delete tmpData.id;
            }
            // Field Section
            else if (titleLine.startsWith("FIELDS")) {
                let tmpData = readFieldLine(line, headerLine);
                if (tmpData) {
                    let id = "field_" + tmpData.id;
                    if (fldData[id]) {
                        for (let key in tmpData) {
                            fldData[id][key] = tmpData[key];
                        }
                    } else {
                        fldData[id] = tmpData;
                        if (!tmpData.fl_name) {
                            tmpData.fl_name = "field" + tmpData.id;
                        }
                    }
                    delete fldData[id].id;
                }
            }
            // Initial Condition Section
            else if (titleLine.startsWith("INITIAL CONDITIONS")) {
                let tmpData = readICLine(line, headerLine);
                if (headerLine.startsWith("C   PCR ICDAT")) {
                    icDataRaw[tmpData.id] = tmpData;
                    if (!tmpData.name) {
                        tmpData.name = "IC" + tmpData.id;
                    }
                    delete tmpData.id;
                    tmpData.soilLayer = [];
                } else if (headerLine.startsWith("C  ICBL  SH2O")) {
                    icDataRaw[tmpData.id].soilLayer.push(tmpData);
                    delete tmpData.id;
                }
            }
            // Planting Section
            else if (titleLine.startsWith("PLANTING")) {
                cacheMgnData(readPlantingLine(line), mgnDataLinkRaw, mgnDataRaw, "planting");
            }
            // Irrigation Section
            else if (titleLine.startsWith("IRRIGATION")) {
                let tmpData = readIrrigationLine(line, headerLine);
                if (headerLine.startsWith("I  EFIR")) {
                    irrProfileRaw = tmpData;
                    dripDataRaw = {};
                } else if (headerLine.startsWith("I  IRLN")) {
                    dripDataRaw[tmpData.irln] = tmpData;
                } else if (headerLine.startsWith("I IDATE")) {
                    for (let key in irrProfileRaw) {
                        tmpData[key] = irrProfileRaw[key];
                    }
                    if (tmpData.irln && dripDataRaw[tmpData.irln]) {
                        for (let key in dripDataRaw[tmpData.irln]) {
                            tmpData[key] = dripDataRaw[tmpData.irln][key];
                        }
                    }
                    delete tmpData.irln;
                    if (!tmpData.name) {
                        if (tmpData.irop === "IR005") {
                            tmpData.name =  "drip:" + tmpData.irstr + "--Irrigation" + tmpData.id;
                        } else {
                            tmpData.name =  "Irr:" + tmpData.irval + "--Irrigation" + tmpData.id;
                        }
                        
                    }
                    cacheMgnData(tmpData, mgnDataLinkRaw, mgnDataRaw, "irrigation");
                }
            }
            // Fertilizer Section
            else if (titleLine.startsWith("FERTILIZERS")) {
                cacheMgnData(readFertilizerLine(line), mgnDataLinkRaw, mgnDataRaw, "fertilizer");
            }
            // Harvest Section
            else if (titleLine.startsWith("HARVEST")) {
                cacheMgnData(readHarvestLine(line), mgnDataLinkRaw, mgnDataRaw, "harvest");
            }
        } // end of symbol if
    } // end of loop

    // Build data structure for management events
    for (let key in mgnDataRaw) {
        let id = "mgn_" + Object.keys(mgnData).length;
        mgnData[id] = mgnDataRaw[key];
        mgnDataIdRaw[mgnDataRaw[key].mgn_name] = id;
    }
    
    // Build data link for each treatment
    for (let i in trtDataRaw) {
        let tmpData = {
            trtno : trtDataRaw[i].trtno,
            trt_name : trtDataRaw[i].trt_name
        };
        
        if (trtDataRaw[i].ge && trtDataRaw[i].ge !== "0") {
            tmpData.cul_id = culDataRaw[trtDataRaw[i].ge].cul_id;
            tmpData.cul_name = culDataRaw[trtDataRaw[i].ge].cul_name;
        }
        
        if (trtDataRaw[i].fl && trtDataRaw[i].fl !== "0") {
            tmpData.field = "field_" + trtDataRaw[i].fl;
        }
        
        if (trtDataRaw[i].ic && trtDataRaw[i].ic !== "0") {
            if (!tmpData.field) {
                // new field ID
                let cnt = Object.keys(fldData).length;
                let newId = "field_" + cnt;
                while (fldData[newId]) {
                    cnt++;
                    newId = "field_" + cnt;
                }
                fldData[newId] = {fl_name : icDataRaw[trtDataRaw[i].ic].name};
            }
            if (!fldData[tmpData.field].initial_conditions) {
                fldData[tmpData.field].initial_conditions = icDataRaw[trtDataRaw[i].ic];
            } else {
                let newFlg = true;
                for (let key in fldData) {
                    if (fldData[key].initial_conditions === icDataRaw[trtDataRaw[i].ic]) {
                        tmpData.field = key;
                        newFlg = false;
                        break;
                    }
                }
                if (newFlg) {
                    // new field ID
                    let cnt = Object.keys(fldData).length;
                    let newId = "field_" + cnt;
                    while (fldData[newId]) {
                        cnt++;
                        newId = "field_" + cnt;
                    }
                    let dataCopy = {};
                    // dulicate the current field
                    for (let key in fldData[tmpData.field]) {
                        dataCopy[key] = fldData[tmpData.field][key];
                    }
                    dataCopy.initial_conditions = icDataRaw[trtDataRaw[i].ic];
                    fldData[newId] = dataCopy;
                    tmpData.field = newId;
                }
            }
            tmpData.cul_id = culDataRaw[trtDataRaw[i].ge].cul_id;
            tmpData.cul_name = culDataRaw[trtDataRaw[i].ge].cul_name;
        }
        
        buildDataLink(tmpData, trtDataRaw[i].pl, mgnDataIdRaw, mgnDataLinkRaw.planting);
        buildDataLink(tmpData, trtDataRaw[i].ir, mgnDataIdRaw, mgnDataLinkRaw.irrigation);
        buildDataLink(tmpData, trtDataRaw[i].fe, mgnDataIdRaw, mgnDataLinkRaw.fertilizer);       
        buildDataLink(tmpData, trtDataRaw[i].ha, mgnDataIdRaw, mgnDataLinkRaw.harvest);

        trtData.push(tmpData);
    }
    
    for (let i in culDataRaw) {
        culData[culDataRaw[i].cul_id] = culDataRaw[i];
        if (!culData[culDataRaw[i].cul_id].cul_name) {
            culData[culDataRaw[i].cul_id].cul_name = culDataRaw[i].cul_id;
        }
    }
    
    return {
        experiment : expData,
        cultivar : culData,
        field : fldData,
        management : mgnData,
        treatment : trtData,
        version : version
    };
}

function buildDataLink(trtData, eventIdx, mgnDataIdRaw, mgnDataLinkRaw) {
    if (eventIdx && eventIdx !== "0") {
        let mgnId = mgnDataIdRaw[mgnDataLinkRaw[eventIdx]];
        if (!trtData.management) {
            trtData.management = [];
        }
        if (!trtData.management.includes(mgnId)) {
            trtData.management.push(mgnId);
        }
    }
}

function readTreatmentLine(line) {
    let formats = {};
    formats = {
        "trtno" : 3, // For 3-bit treatment number (2->3)
        "null_sq" : 1,   // For 3-bit treatment number (2->1)
        "null_op" : 2,
        "null_co" : 2,
        "trt_name" : 26,
        "ge" : 3,
        "fl" : 3,
        "null_sa" : 3,
        "ic" : 3,
        "pl" : 3,
        "ir" : 3,
        "fe" : 3,
        "null_om" : 3,
        "null_ch" : 3,
        "null_ti" : 3,
        "null_em" : 3,
        "ha" : 3,
        "null_sm" : 3
    };
    // Read line and save into return holder
    let tmpData = {};
    readLine(tmpData, line, formats);
    for (let key in tmpData) {
        if (tmpData[key] === "0") {
            delete tmpData[key];
        }
    }
    return tmpData;
}

function readFieldLine(line, headerLine) {
    let formats = {};
    let tmpData;
    if (headerLine.startsWith("L ID_FIELD WSTA")) {
        formats = {
            "id" :  2,
            "id_field" : 9,
            "wst_id" : 9,
//            "wst_id_suff" : 4, // ignore start year and duration
            "flsl" : 6,
            "flob" : 6,
            "fl_drntype" : 6,
            "fldrd" : 6,
            "fldrs" : 6,
            "flst" : 6,
            "sltx" : 6,
            "sldp" : 6,
            "soil_id" : 11,
            "fl_name" : line.length
        };
        tmpData = {};
        readLine(tmpData, line, formats);
    } else if (headerLine.startsWith("L ...........XCRD")) {
        // TODO
    } else if (headerLine.startsWith("L  BDWD")) {
        tmpData = {};
        formats = {
            "id" :  2,
            "bdwd" : 6,
            "bdht" : 6,
            "pmalb" : 6
        };
        readLine(tmpData, line, formats);
    }
    return tmpData;
}

function readCultivarLine(line) {
    let formats = {};
    formats = {
        "id" : 2,
        "crid" : 3,
        "cul_id" : 7,
        "cul_name" : 17
    };
    // Read line and save into return holder
    let tmpData = {};
    readLine(tmpData, line, formats);
    if (tmpData.cul_id) {
        tmpData.dssat_cul_id = tmpData.cul_id;
    }
    for (let key in tmpData) {
        if (tmpData[key] === "0") {
            delete tmpData[key];
        }
    }
    return tmpData;
}

function readICLine(line, headerLine) {
    let formats = {};
    let tmpData = {};
    if (headerLine.startsWith("C   PCR ICDAT")) {
        formats = {
            "id" :  2,
            "icpcr_dssat" :  6,
            "icdat" :  6,
            "icrt" :  6,
            "icnd" :  6,
            "icrzc" :  6,
            "icrze" :  6,
            "icwt" :  6,
            "icrag" :  6,
            "icrn" :  6,
            "icrp" :  6,
            "icrip" :  6,
            "icrdp" :  6,
            "name" : line.length
        };
    } else if (headerLine.startsWith("C  ICBL  SH2O")) {
        formats = {
            "id" :  2,
            "icbl" :  6,
            "ich2o" :  6,
            "icnh4" :  6,
            "icno3" :  6
        };
    }
    readLine(tmpData, line, formats);
    return tmpData;
}

function readPlantingLine(line) {
    let formats = {};
    formats = {
        "id" : 2,
        "date" : 6,
        "edate" : 6,
        "plpop" : 6,
        "plpoe" : 6,
        "plma" : 6,
        "plds" : 6,
        "plrs" : 6,
        "plrd" : 6,
        "pldp" : 6,
        "plmwt" : 6,
        "page" : 6,
        "plenv" : 6,
        "plph" : 6,
        "plspl" : 6,
        "name" : line.length
    };
    // Read line and save into return holder
    let tmpData = {};
    readLine(tmpData, line, formats);
    tmpData.event = "planting";
    
    return tmpData;
}

function readIrrigationLine(line, headerLine) {
    let formats = {};
    let tmpData = {};
    if (headerLine.startsWith("I  EFIR")) {
        formats = {
            "id" :  2,
            "ireff" :  6,
            "irmdp" :  6,
            "irthr" :  6,
            "irept" :  6,
            "irstg" :  6,
            "iame" :  6,
            "iamt" :  6,
            "name" : line.length
        };
    } else if (headerLine.startsWith("I  IRLN")) {
        formats = {
            "id" :  2,
            "irln" :  6,
            "irspc" :  6,
            "irofs" :  6,
            "irdep" :  6
        };
    } else if (headerLine.startsWith("I IDATE  IROP IRVAL IRSTR")) {
        formats = {
            "id" :  2,
            "date" : 6,
            "irop" : 6,
            "irrat" : 6,
            "irstr" : 6,
            "irdur" : 6,
            "irln" : 6
        };
        tmpData.event = "irrigation";
    } else if (headerLine.startsWith("I IDATE  IROP IRVAL")) {
        formats = {
            "id" :  2,
            "date" : 6,
            "irop" : 6,
            "irval" : 6
        };
        tmpData.event = "irrigation";
    }
    readLine(tmpData, line, formats);
    return tmpData;
}

function readFertilizerLine(line) {
    let formats = {};
    formats = {
        "id" : 2,
        "date" : 6,
        "fecd" : 6,
        "feacd" : 6,
        "fedep" : 6,
        "feamn" : 6,
        "feamp" : 6,
        "feamk" : 6,
        "feamc" : 6,
        "feamo" : 6,
        "feocd" : 6,
        "name" : line.length
    };
    // Read line and save into return holder
    let tmpData = {};
    readLine(tmpData, line, formats);
    tmpData.event = "fertilizer";
    
    return tmpData;
}

function readHarvestLine(line) {
    let formats = {};
    formats = {
        "id" : 2,
        "date" : 6,
        "hastg" : 6,
        "hacom" : 6,
        "hasiz" : 6,
        "happc" : 6,
        "habpc" : 6,
        "name" : line.length
    };
    // Read line and save into return holder
    let tmpData = {};
    readLine(tmpData, line, formats);
    tmpData.event = "harvest";
    
    return tmpData;
}

function cacheMgnData(tmpData, mgnDataLinkRaw, mgnDataRaw, eventType) {
    let mgnName;
    if (!tmpData.name) {
        tmpData.content = eventType + tmpData.id;
        mgnName = tmpData.content;
    } else {
        let tmp = tmpData.name.split("--");
        delete tmpData.name;
        tmpData.content = tmp[0];
        if (tmp[1]) {
            mgnName = tmp[1];
        } else {
            mgnName = tmp[0];
        }
        
    }
    mgnDataLinkRaw[eventType][tmpData.id] = mgnName;
    if (!mgnDataRaw[mgnName]) {
        mgnDataRaw[mgnName] = {mgn_name : mgnName, data : []};
    }
    mgnDataRaw[mgnName].data.push(tmpData);
    tmpData.id = mgnDataRaw[mgnName].data.length;
}

function readLine(ret, line, formats, defVal) {
    for (let key in formats) {
        // To avoid to be over limit of string lenght
        let length = Math.min(formats[key], line.length);
        if (key !== "" && !key.startsWith("null")) {
            let tmp = line.substring(0, length).trim();
            // if the value is in valid keep blank string in it
            if (checkValidValue(tmp)) {
                ret[key] = tmp;
            } else {
                if (defVal) {
                    ret[key] = defVal;
                }
            }
        }
        line = line.substring(length);
    }
    return ret;
}

function checkValidValue(value) {
    return value && value !== "-99" && value !== -99;
}