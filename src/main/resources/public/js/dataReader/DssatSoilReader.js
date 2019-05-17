function readSoilFileData(rawData, fileName) {
    
    let ret = {soils:[]};
    let profile = {};
    let dataFlg;
    
    ret.file_name = fileName;
    
    for (let i = 0; i < rawData.length; i++) {
        let line = rawData[i];
        let symbol = line.trim().substring(0, 1);
        
        if (symbol === "*") {
            line = line.substring(1);
            dataFlg = 0;
            if (line.toUpperCase().startsWith("SOILS")) {
                ret.sl_notes = line.replace(/\*[Ss][Oo][Ii][Ll][Ss]?\s*:?/, "").trim();
            } else {
                profile = {soilLayer:[]};
                ret.soils.push(profile);
                profile.soil_id = line.substring(0, 10);
                profile.soil_name = line.substring(36).trim();
                if (profile.soil_name === "-99") {
                    profile.soil_name = "Unknown name";
                }
            }
        } else if (symbol === "@") {
            line = line.substring(1);
            if (line.toUpperCase().trim().startsWith("SLB")) {
                dataFlg = 2;
            }
        } else if (symbol === "!") {
            // comment line
        } else if (symbol !== "") {
            if (dataFlg === 2) {
                profile.soilLayer.push({sllb: line.substring(0, 6).trim()});
            }
        }
    }
    
    return ret;
}
