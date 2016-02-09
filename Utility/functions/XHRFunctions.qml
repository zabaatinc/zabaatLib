import QtQuick 2.5
QtObject  {

    function get (url, params, callback, jsonparse){ logic.genericCall("get"   ,url,params,callback,jsonparse)  }
    function post(url, params, callback, jsonparse){ logic.genericCall("post"  ,url,params,callback,jsonparse)  }
    function put (url, params, callback, jsonparse){ logic.genericCall("put"   ,url,params,callback,jsonparse)  }
    function del (url, params, callback, jsonparse){ logic.genericCall("delete",url,params,callback,jsonparse)  }


    property QtObject logic : QtObject{
        id : logic

        function isArray(obj){
            return toString.call(obj) === '[object Array]';
        }

        function genericCall(method, url, params, callback, jsonparse){
            var options = urlToOptions(url, method);
//            console.log(JSON.stringify(options,null,2))
            if(!jsonparse) {
                req(options, params, function(obj) {
        //            {status: xhr.status, header: xhr.getAllResponseHeaders(), body: xhr.responseText}
                    if(callback)
                        callback(obj.body);
                })
            }
            else {
                req(options, params, function(obj) {
                    var parsedObj = null
                    try {
                        parsedObj = JSON.parse(obj.body);
                    }
                    catch(e){
                        callback({error : "XhrFunc.genericCall.JSON.parse error", data : null, orig : obj.body })
                    }
                    if(parsedObj !== null && typeof parsedObj !== 'undefined' && callback)
                        callback(parsedObj)
                })
            }
        }
        function urlToOptions(url, method){
            if(url && typeof url === 'string'){
                var protocol, host, port, path;

                //lets first find the protocol
                var ind = url.indexOf("://");
                if(ind !== -1 && ind > 0){
                    protocol = url.substring(0,ind)
                    url      = url.slice(ind + "://".length)        //shorten the thing
                }
                else
                    protocol = "http"

                //now let's find the port
                ind      = url.indexOf(":")
                var ind2 = url.indexOf("/",ind)
                if(ind !== -1 && ind2 !== -1 && ind < ind2){
                    port = url.substring(ind+1,ind2)

                    //now we can easily divide the string into 2 sections
                    host = url.substring(0,ind)
                    path = url.substring(ind2+1,url.length)

                }
                else {
                    console.log("No PORT provided for", url)
                    return null;
                }

                return {
                    protocol : protocol,
                    port : port,
                    host : host,
                    path : path,
                    method : method
                }

    //            console.log("protocl is", protocol)
    //            console.log("port is", port)
    //            console.log("uri is", uri)
    //            console.log("path is", path)

            }
            return null;
        }
        function req (options, data, callback) {  //generic XHR request function for POST / GET
               // @params options  OBJECT    protocol (http,https), host, port, path (includes options and params)
               // @params data  OBJECT  (optional - you can send in your keys/values as a preformatted string if you really want to, but you should still send in the PATH)    {key:value , key1:value1}  these will be parsed to a string and appended to the path
               var  xhr = new XMLHttpRequest;
               var uri, method = "get";
               if (typeof options ==='object'){
                   uri    = options
                   method = options.method ? options.method : "get"

                   if(uri.protocol === null || typeof uri.protocol === "undefined")   uri.protocol = "http"
                   if(uri.port     === null || typeof uri.port     === "undefined")   uri.port     = 80
                   if(uri.path     === null || typeof uri.path     === "undefined")   uri.path     = ""
    //               if (!uri.host){uri.host = serverVars.hostName}
    //               if(!uri.port){uri.port  = serverVars.port}
    //               if(!uri.path){uri.path = ""}
               }

               if(uri.path.charAt(0) === "/")
                   uri.path = uri.path.slice(1);    //if you send in a "/Globals we remove the / for you!

               /*if(isArray(data)){

               }
               else */if (typeof data ==='object'){
                   console.log("data is an object", data);
                   var tempData = '?' //header request wants the ? before it starts processing params
                   for (var d in data){
                       var item = data[d]
                       var str = typeof item === 'object'  ? JSON.stringify(item) : item
                       tempData += d+'='+str+'&'
                   }
                   data = tempData.slice(0,tempData.length-1);
               }

               var source = uri.protocol + '://' + uri.host +":"+uri.port+ '/' + uri.path + data;

//               console.log("XHR.", method.toUpperCase(), "(" ,source, ")")
               if (method.toLowerCase() === "post" || method.toLowerCase() === "put"){
                   console.log("XHR", method, source)
                   xhr.open(method.toUpperCase(), source);
                   xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
                   xhr.send();
               }
               else {
                   console.log("XHR", method, source)
                   xhr.open(method.toUpperCase(), source);
                   xhr.send();
               }

               xhr.onreadystatechange = function() {
                   if (xhr.readyState === XMLHttpRequest.DONE && callback) {
                       callback( {status: xhr.status, header: xhr.getAllResponseHeaders(), body: xhr.responseText});
                   }
               };
       }

    }
}
