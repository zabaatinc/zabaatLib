//.import "./parser.js" as ParserCoder
//Qt.include('./parser.js');
//Qt.include('./derp.js');
//Qt.include('./jsuri-1.1.2.js');
//Qt.include('./after.js');

var http = function() {
};

http.request = function(options, callback) {
    var xhr = new XMLHttpRequest(),
        uri, // expects protocol (http,https), host, port, path (includes options and params)
        method,
        userAgent;

    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) { // full body received
            return;
        }
        callback({status: xhr.status, header: xhr.getAllResponseHeaders(), body: xhr.responseText});
    };

    if (typeof options ==='object'){
        uri = options
        method = options.method || 'get'
        if(uri.protocol == "http" || uri.protocol == "https") {}//you done good son!
        else uri.protocol = "http"
    }
    if (method === 'get') {
        xhr.open('GET', uri.protocol + '://' + uri.host +":"+uri.port+ '/' + uri.path);
        xhr.send(null);
    } else {
        xhr.open('POST', uri.protocol + '://' + uri.host +":"+uri.port+ '/' + uri.path);
        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        xhr.send();
    }
}

