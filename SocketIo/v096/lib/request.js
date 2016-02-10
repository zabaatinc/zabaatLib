Qt.include('./socketHelper.js'); //functions currently used only for incoming XHR request. all the other functions are contained directly in socket.io
Qt.include('./jsuri-1.1.2.js'); //parse and query functions for URI

var debug = false
function debugMsg()
{
	if(debug)
	{
		var str = ""
		for(var i = 0; i < arguments.length; i++)
			str += arguments[i] + " "
		console.log(str)
	}
}


var http = function() {
};

function showRequestInfo(text) {
    log.text = log.text + "\n" + text
    
	
	debugMsg(text);
}

http.request = function(options,header, callback) {
    //
    var xhr = new XMLHttpRequest(),
        method = options.method || 'get',
        uri,
        userAgent;
    debugMsg("requests.js: options=",options);
    if (options instanceof Uri) {
        uri = options;
    } else if (typeof options === 'string') {
        uri =  new Uri(options);
    } else if (options.hasOwnProperty('uri') && options.uri instanceof Uri) {
        uri = options.uri;
        if (options.hasOwnProperty('userAgent')) {
            userAgent = options.userAgent;
        }
    } else {
        throw new Exception('Wrong options');
    }

    xhr.onreadystatechange = function() {
        if (xhr.readyState !== 4) { // full body received  the number here corresponds to typical HTTP XHR request ready state, 4 means all transactions complete
            return;
        }

        debugMsg("request.js: xhr : " + xhr.status);

//        Derp.derpOut("derp derp")  you can use this to see if your sockethelper is linked correctly

        var callback2 = function (packet,index,total)  //this callback is really the end of the function
        {
//            debugMsg(JSON.stringify(packet,null,2))
//            debugMsg("CALLED BACK BOYO: "+packet + " " + index + " " + total);
            callback({status: xhr.status, header: xhr.getAllResponseHeaders(), body: packet}); //finally return to original callback with the response
        }

//        This passes the response from the XHR into the parsercoder to decode and the above callback so it's response can be sent to the main thread
          ParserCoder.decodePayload(xhr.responseText,false,callback2);

    };

    if (method === 'get') {
        xhr.open('GET', uri.toString()+"?EIO=3&transport=polling&t="+socket._generateTimestamp(true)+"&b64=true"); //b64 herre is hard coding binary mode to off
//        xhr.open('GET', "/socket.io/?EIO=3&transport=polling&t=1415921888445-17");

        if (userAgent) {
            xhr.setRequestHeader('QtBug', 'QTBUG-20473\r\nUser-Agent: ' + userAgent);
            for (var h in header){
                xhr.setRequestHeader(h,header[h])
            }
        }
        xhr.send(null);

    } else {
        xhr.open('POST', uri.protocol() + '://' + uri.host()  + uri.path());

        if (userAgent) {
            xhr.setRequestHeader('QtBug', 'QTBUG-20473\r\nUser-Agent: ' + userAgent);
        }

        xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        for (var h in header){
            xhr.setRequestHeader(h,header[h])
        }
        xhr.send(uri.query().toString().substring(1)); //jsuri return query with '?' always
    }
}

