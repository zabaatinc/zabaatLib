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

}
