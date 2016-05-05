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

    function readFileAsB64(source, callback) {

//        var xhr = new XMLHttpRequest;
//        xhr.open("GET",source,true);
////        xhr.overrideMimeType('text/plain; charset=x-user-defined')
//        xhr.onreadystatechange = function () {
//            if (xhr.readyState === XMLHttpRequest.DONE && callback) {
////                callback(Qt.btoa(xhr.responseText))
//               var blob = xhr.responseText ;
//               var blobarray = new Array ;
//               for (var i = 0, len = blob.length; i < len; ++i) {
//                    blobarray.push(blob.charCodeAt(i) & 0xff );
//               }
//               // then use          Image.source = "data:image/png;base64," +
//               console.log("FINISHED and now sending out")
//               callback(blobarray.join(""))   //  to show the image
//            }
//        }
//        xhr.send()
        c.cb = callback;
        c.width = 64
        c.height = 64
        c.requestPaint()
        c.loadImage(source);

    }

    property Canvas c : Canvas{
        id : c
        property var cb
        onImageLoaded: {
            if(cb){
               cb(c.toDataURL());
            }
        }
    }


}
