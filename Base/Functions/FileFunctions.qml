import QtQuick 2.0
QtObject {
    //FILE
    function readFile(source, callback) {
        var xhr = new XMLHttpRequest;
        xhr.open("GET", source);
        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE && callback)
                callback(xhr.responseText)
        }
        xhr.send();
    }
    function readJSONFile(source, callback) {
        readFile(source, function(jsData) {
            try {
                var a = JSON.parse(jsData);
                if(callback)
                    callback(a)
            }
            catch(e){
                console.log("readJSONFile error from", source, jsData)
            }
        })
    }

    //returns the js object in "data" key or an error in "err" key if couldn't be parsed.
    function readJSONFile_v2(source, callback) {
        readFile(source, function(jsData) {
            try {
                var a = JSON.parse(jsData);
                if(typeof callback === 'function')
                    callback({data :a })
            }
            catch(e){
                console.log("readJSONFile error from", source, jsData)
                if(typeof callback === 'function')
                    callback({err : "readJSONFile error from " + source + jsData })
            }
        })
    }



}
