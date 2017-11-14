import QtQuick 2.5
import Zabaat.SocketIO 1.0
import Zabaat.Controller.ZController 1.0

/*!
   \brief an extension of the ZController that uses SocketIO to communicate
   \inqmlmodule Zabaat.Controller 1.0 \hr
   \depends Zabaat.SocketIO.v100 1.0 \hr
*/
ZController {
    id : controller
    Component.onCompleted: {
        console.log("SocketIOController Wakeup. Update date 11/13/2017");
    }

    /*! apparently never gets called \hr*/
    signal statusUpdate  (string status, int reconnectTimer)
    signal info(string msg);
    signal error(string msg);
    signal warning(string msg);
    signal reqSent    (string id, string type, string url, var params)
    signal resReceived(string id, string type, string url, var res)
    signal resProcessed(string id, var ms)

    property int longTime : 1000    //in milliseconds!

    /*! A function that can display errors if XhrController encounters any. \b default : null \hr */
    property var    errHandler            : null   //works on postReqs

    /*! Req history \hr */
    property var    requestHistory        : []

    /*! The path to which this XhrController talks to. \b default : "" \hr */
    property string uri                   : ""

    /*! The token that a server might send back for auth purposes. User shouldn't have to change this. \b default : "" \hr */
    property string token                 : ""

    /*! Automatically add listeners for every req you make ? \b default : true \hr */
    property bool   autoAddEventListeners : true

    /*! Alias to socketHandler (QML interface of the C++ plugin)  \hr */
    property alias socketio : socketHandler

    /*! Connect to server at <uri> using <jsQuery> . jsQuery can be blank but can be used to specify sails version ,etc.
        In fact, it defaults to {__sails_io_sdk_version : "1.2.0" }  \hr */
    function connect(uri, jsQuery){
        if(uri === null || typeof uri === 'undefined')
            uri = controller.uri

        if(jsQuery === null || typeof jsQuery === 'undefined')
            jsQuery = {__sails_io_sdk_version : "1.2.0" }

//         console.log(controller.uri)
        socketHandler.connect(uri, JSON.stringify(jsQuery))
    }

    /*! fn : disconnects any active connections and any attempts to reconnect  \hr */
    readonly property var   disconnect  : socketHandler.disconnect

    /*! reflects whether the controller is connected to the uri or not  \hr */
    property bool isConnected   : socketHandler.isConnected

    /*! reflects whether the controller is trying to re-establish a connection  \hr */
    readonly property alias reconnecting        : socketHandler.reconnecting

    /*! reflects the amount of attemps the controller will make to reconnect before giving up  \hr */
    readonly property alias reconnectLimit      : socketHandler.reconnectLimit

    /*! the current number of attempted reconnects since last time an attempt was made to connect  \hr */
    readonly property alias attemptedReconnects : socketHandler.attemptedReconnects

    /*! the sid is given to us by the server. Acts as our identifier \hr */
    readonly property alias sessionId       : socketHandler.sessionId

    /*! the events that we are listening on. \b default : ["message"]  \hr */
    property alias          registeredEvents: socketHandler.registeredEvents
//    readonly property var   addEvents       : socketHandler.addEvents

    /*! fn : Add event that we should listen to  \hr */
    readonly property var   addEvent        : socketHandler.addEvent

    /*! fn : Remove event that we are listening to   \hr */
    readonly property var   removeEvent     : socketHandler.removeEvent




    onSendGetModelRequest: {
        debug.debugMsg("<-- ZController.getModelRequest SIGNAL:", modelName)
//            socketHandler.sailsGet(url,params,cb,headers)
        socketHandler.sailsGet("/" + modelName + "/", null, function (obj) {
            debug.debugMsg("--> ZController.getModelRequest CALLBACK:", modelName)
            if(typeof obj === 'string'){
                try
                {
                    var modelObj = JSON.parse(obj)
                    controller.addModel(modelName, modelObj)
                }
                catch(e) {
                    if(errHandler){
                        errHandler({
                                    msg         : "Failed to parse server response. Make sure server is running: "+  e.message,
                                    type        : "Exception",
                                    code        : "",
                                    origin      : "ZController.onSendGetModelRequest",
                                    originPtr   : controller,
                                   })
                    }
                    else
                        debug.debugMsg("Failed to parse server response. Make sure server is running :", e.message, obj)
                }
            }
            else {
                controller.addModel(modelName, obj)
            }
        })
    }

    //Convenience functions
    //params must be {}
    //override:true pass all requests through the history filter

    /*! url      : is actually the function name. Do not need to specify full path here. Only /update or something like that.  \hr
        params   : the jsObject to send out
        callback : the function to run when we get a response from the server
        override :  don't run this if already ran this. Kinda useless. should be removed perhaps.
        passToken : this is automatically token from rootObject
    */
    function postReq(url, params, callback,modelToUpdate, errHandler){
        //decipher the mdoelname!!
        priv.req('Post', url, params, callback, modelToUpdate, errHandler)
    }

    /*! url      : is actually the function name. Do not need to specify full path here. Only /update or something like that.  \hr
        params   : the jsObject to send out
        callback : the function to run when we get a response from the server
        override :  don't run this if already ran this. Kinda useless. should be removed perhaps.
        passToken : this is automatically token from rootObject
    */
    function putReq(url, params, callback,modelToUpdate, errHandler) {
        priv.req('Put', url, params, callback, modelToUpdate, errHandler)
    }

    /*! url      : is actually the function name. Do not need to specify full path here. Only /update or something like that.  \hr
        params   : the jsObject to send out
        callback : the function to run when we get a response from the server
        override :  don't run this if already ran this. Kinda useless. should be removed perhaps.
        passToken : this is automatically token from rootObject
    */
    function getReq(url, params, callback, modelToUpdate, errHandler){
        priv.req('Get', url, params, callback, modelToUpdate, errHandler)
    }

    /*! url      : is actually the function name. Do not need to specify full path here. Only /update or something like that.  \hr
        params   : the jsObject to send out
        callback : the function to run when we get a response from the server
        override :  don't run this if already ran this. Kinda useless. should be removed perhaps.
        passToken : this is automatically token from rootObject
    */
    function deleteReq(url, params, callback, modelToUpdate, errHandler){
        priv.req('Delete', url, params, callback, modelToUpdate, errHandler)
    }

    QtObject {
        id : priv
        property var cbObjects: ({})
        function now(){
            return +(new Date().getTime())
        }


        function correctifyUrl(url){
            if(url.charAt(0) !== "/") {
                return "/" + url;
            }
            return url;
        }
        function findInHistory(obj) {
            for(var o in  controller.requestHistory) {
                if(JSON.stringify(obj) == JSON.stringify(controller.requestHistory[o])     )
                    return true
            }
            return false
        }
        function handleError(origin, response, errHandler){
            if(!response)
                return console.warn("O__O SOCKETIO O_O @",origin, "Null response")

            var e ;
            if(isArray(response))     e = response[0].err ? response[0].err : response[0].error
            else                      e = response.err    ? response.err    : response.error

            if(e){
                errHandler = errHandler || controller.errHandler;
                if(typeof errHandler === 'function'){
                    var errObj = { origin : origin }

                    if(typeof e === 'object') {
                        for(var k in e) {
                            errObj[k] = e[k]
                        }
                    }
                    else {
                        errObj["error"] = e;
                    }

                    errHandler(errObj)
                }
                else {
                    console.error("X__X SocketIO X__X @", origin,JSON.stringify(e,null,2))
                }
            }
        }
        function getObjectPropertyNames(obj){
            var arr = []
            if(obj !== null && typeof obj === 'object'){
                for(var o in obj)
                    arr.push(o)
            }
            return arr
        }
        function parseAndCheck(response, errDisplay, url){
            if(typeof response === 'string')
            {
                var success = false
                try {
                    response = JSON.parse(response)
                    success  = true
                }
                catch(e) {
                    if(controller.errHandler){
                        controller.errHandler({
                                    msg         : "Failed to parse server response from request:" + url,
                                    type        : "Exception",
                                    code        : "",
                                    origin      : "ZController." + errDisplay + " (socketHandler.request callback. ParseAndCheck)",
                                    originPtr   : controller,
                                   })
                    }
                    else
                        console.log(e);
                }

                if(!success){
                    console.log(socketHandler, "Failed in parsing JSON from server (parseAndCheck)", errDisplay)
                    return false
                }
            }
            return response
        }
        function errorCheck(response, errDisplay, errHandler){
//            console.log("ERROR CHECK", JSON.stringify(response,null,2))
            if(response && (response.err || response.error) ) {
                priv.handleError('ZClient.' + errDisplay + ' (server validation error)' , response, errHandler)
                return false
            }
            return true
        }
        function req(type, url, params, callback, modelToUpdate, errCallback){
            if(autoAddEventListeners){
//                console.log("ADDING EVENT LISTENER FOR", url)
                priv.addEvent(url)
            }

            if(socketHandler.token) {
                if(params)
                    params.access_token = socketHandler.token
                else
                    params = { access_token : socketHandler.token }
            }

//            socketHandler.sailsGet(url.toString(), params, )
            //sails + type is the typeof function we are calling. sailsGet , sailsPut
            url = correctifyUrl(url)


//            console.log("sails" + type, url.toString(), params ? params.id : "")
            //emit signal for debugging
            var cbId = socketHandler["sails" + type](url.toString(), JSON.stringify(params));
            reqSent(cbId,type,url,params)
            priv.cbObjects[cbId] = {
                callback : callback,
                type: type ,
                url: url,
                modelToUpdate :modelToUpdate,
                errHandler: errCallback || errHandler
            }

        }
        function getJsObject(item){
            if(typeof item === "string"){
                return JSON.parse(item)
            }
            else
                return item
        }
        function addEvent(url){
            var uarr = url.toString().split("/")
            if(uarr.length > 0 && uarr[0] !== "")
                socketHandler.addEvent(uarr[0])
        }

        function cbHandlerFunc(response, callback, type,url, modelToUpdate, errHandler){
            var retTimes = { model : 0, callback : 0 }
            var time
            errHandler = errHandler || controller.errHandler;
//            console.log("errHandler is same as root errHandler?", errHandler === controller.errHandler)
            var noerror = priv.errorCheck(response, type + 'req', errHandler)

//            if(!noerror)
//                console.log("@@ ERROR ON", url, JSON.stringify(response,null,2))
            if(response){
                if(modelToUpdate && noerror && response.data) {
                    time = priv.now()
                    controller.addModel(modelToUpdate, response.data);
                    retTimes.model = priv.now() - time;
                }

                if(typeof callback === 'function') {
                    time = priv.now()
                    callback(response);
                    retTimes.callback = priv.now() - time;
                }
            }
            return retTimes
        }

        function getErrorHandler(cbId) {
            var cbObj = priv.cbObjects[cbId];
            if(cbObj && typeof cbObj.errHandler === 'function'){
                return cbObj.errHandler;
            }
            if(typeof errHandler === 'function')
                return errHandler;
            return null;
        }



    }
    ZSocketIO {
        id : socketHandler
        onIsConnectedChanged: {
            controller.isConnected = isConnected;
        }
        onReconnectingChanged : {
            if(socketHandler.reconnecting){
               controller.isConnected = false;
            }
            else if(isConnected){
                controller.isConnected = true;
            }
        }

        property int autoServerMsgId : -1   //messages sent from server without us asking are marked with negative cbId from us!
        onServerResponse: {
//            console.log("serverResponse for cbId", cbId);
            var jsRes = priv.parseAndCheck(value,"",cbId)

            if(logic.isArray(jsRes))
                jsRes = jsRes[0]


            function error(jsRes) {
                if(jsRes.statusCode && !jsRes.statusCode === "200" && !jsRes.statusCode === "201")  {
                    //is error!
                    var errHandler = priv.getErrorHandler(cbId);
//                    console.log('GET THE ERROR HANDLER. Root error Handler?', errHandler === controller.errHandler)
                    if(typeof errHandler === 'function'){
                        errHandler({
                            msg   : "Server Error",
                            event : eventName,
                            code  : jsRes.statusCode
                        })
                    }

                    return true;
                }
                return false;
            }

            if(error(jsRes))
                return;


            if(jsRes.headers && typeof jsRes.body !== 'undefined')  //use part of the message we actually need!
                jsRes = jsRes.body

            if(error(jsRes))
                return;

            var arr = eventName.split("/")
            var mName = arr[0] !== "" ? arr[0] : arr.length > 1 ? arr[1] : ""

            if(mName)
                logic.handleMessage(jsRes , mName)
            else
                console.log("bad model name!")


            if(cbId !== "") {
                var cbObj = priv.cbObjects[cbId]
                if(cbObj) {
                    //emit signal that res was received!
                    resReceived(cbId, cbObj.type, cbObj.url, jsRes);
                    var time = priv.now()

                    //cbHandler func does err checking inside!
                    var times = priv.cbHandlerFunc(jsRes,  cbObj.callback, cbObj.type, cbObj.url, cbObj.modelToUpdate, priv.getErrorHandler(cbId))
                    time = priv.now() - time

                    if(time > longTime) {
                        console.warn("WARNING : handling response for ", cbObj.url, "took", (time/1000).toFixed(2), " seconds!!!! model:",
                                      times.model/1000, " secs. callback:",times.callback/1000, " secs")
                    }
                    resProcessed(cbId, time)


                    delete priv.cbObjects[cbId]
                }
            }
            else {
                //should always check for errors no matta what
//                console.log("CbID was empty for", mName)
                if(priv.errorCheck(jsRes)) {    //if we passed our errorCheck!
                    var id = autoServerMsgId--;
                    resReceived (id ,mName,"auto",jsRes); //we still got this thing, lets make sure we send it out.
                    resProcessed(id, time);
                }
            }
        }


        property QtObject logic : QtObject {
            id : logic
            property var defaultEvents : ["message","prints","error","progress"]   //todo, make prints outside


            function isArray(obj) {
                return toString.call(obj) === '[object Array]'
            }
            function handleMessage(message , modelName, depth){
//                console.log("handleMEssage", message, modelName, depth)
                if(depth === null || typeof depth === 'undefined')
                    depth = 0

                modelName = message && message.model ? message.model : modelName

                if(message === null || typeof message === 'undefined'){
                    return;
                }

                if(message.data === null || typeof message.data === 'undefined'){
                    return;
                }

                if(isArray(message.data)){
                    for(var d = 0; d < message.data.length; d++){
                        handleMessage({data:message.data[d] , verb:message.verb }, modelName, depth + 1)
                    }
                }
                else {
                    var verb = message.verb
                    switch (verb) {
                        case "updated":
                            if(typeof message.data.id === 'undefined')
                                message.data.id = message.id

                            controller.addModel(modelName, message.data)    //If one of the sets failed, that means that we either didn't have this property
                            updateReceived(modelName, message.data.id, message.data)
                            break;
                        case "update":
                                if(typeof message.data.id === 'undefined')
                                    message.data.id = message.id

                                controller.addModel(modelName, message.data)    //If one of the sets failed, that means that we either didn't have this property
                                updateReceived(modelName, message.data.id, message.data)
                                break;
                        case "create":
                                if(!message.data.id)
                                    message.data.id = message.id

                                controller.addModel(modelName, message.data)   //If one of the sets failed, that means that we either didn't have this property
                                                                                           //or the whole item. In any case, appendToModel should take care of it
                                                                                           //But it does much more instructions so we only call it if we have to
                                createReceived(modelName, message.data.id, message.data)
                                break;

                        case "created":
                                if(!message.data.id)
                                    message.data.id = message.id

                                controller.addModel(modelName, message.data)   //If one of the sets failed, that means that we either didn't have this property
                                                                                           //or the whole item. In any case, appendToModel should take care of it
                                                                                           //But it does much more instructions so we only call it if we have to
                                createReceived(modelName, message.data.id, message.data)
                                break;
                        case "destroy" : console.log(socketHandler, "TODO : IMPLEMENT DESTROY", JSON.stringify(message,null,2));
                            break;


                    }
                }
            }
            function indexOf(arr,val){
                for(var i = 0; i < arr.length; i++){
                    var e = arr[i]
                    if(e === val)
                        return i
                }
                return -1
            }
        }

        onRegisteredEventsChanged: {
            socketHandler.addEvents(logic.defaultEvents)
        }
    }
}


