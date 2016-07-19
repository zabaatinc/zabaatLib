import QtQuick 2.5
import Zabaat.SocketIO 1.0
import Zabaat.Controller.ZController 1.0

/*!
   \brief an extension of the ZController that uses SocketIO to communicate
   \inqmlmodule Zabaat.Controller 1.0 \hr
   \depends Zabaat.SocketIO.v100 1.0 \hr
*/
ZController {
    id                          : controller
    debugMode                   : false
//    externalDebugFunc           : socketHandler.externalDebugFunc
//    modelTransformerFunctions   : ({ books : priv.transformBooks })
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

    /*! Function that turns err to a Js Object. Is internally assigned. Shouldn't need to override this unless
    something specific is needed. \hr */
    property var    errToJsObj            : priv.getSailsError

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
    readonly property var   disconnect          : socketHandler.disconnect

    /*! reflects whether the controller is connected to the uri or not  \hr */
    readonly property alias isConnected         : socketHandler.isConnected

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
    function postReq(url, params, callback,modelToUpdate){
        //decipher the mdoelname!!
        priv.req('Post', url, params, callback, modelToUpdate)
    }

    /*! url      : is actually the function name. Do not need to specify full path here. Only /update or something like that.  \hr
        params   : the jsObject to send out
        callback : the function to run when we get a response from the server
        override :  don't run this if already ran this. Kinda useless. should be removed perhaps.
        passToken : this is automatically token from rootObject
    */
    function putReq(url, params, callback,modelToUpdate) {
        priv.req('Put', url, params, callback, modelToUpdate)
    }

    /*! url      : is actually the function name. Do not need to specify full path here. Only /update or something like that.  \hr
        params   : the jsObject to send out
        callback : the function to run when we get a response from the server
        override :  don't run this if already ran this. Kinda useless. should be removed perhaps.
        passToken : this is automatically token from rootObject
    */
    function getReq(url, params, callback, modelToUpdate){
        priv.req('Get', url, params, callback, modelToUpdate)
    }

    /*! url      : is actually the function name. Do not need to specify full path here. Only /update or something like that.  \hr
        params   : the jsObject to send out
        callback : the function to run when we get a response from the server
        override :  don't run this if already ran this. Kinda useless. should be removed perhaps.
        passToken : this is automatically token from rootObject
    */
    function deleteReq(url, params, callback, modelToUpdate){
        priv.req('Delete', url, params, callback, modelToUpdate)
    }

    QtObject {
        id : priv
        property var cbObjects: ({})
        function now(){
            return +(new Date().getTime())
        }


        function getSailsErr(msg){
            var err  = msg[0] && msg[0].err ? msg[0].err : msg[0]
            if(msg[0] && msg[0].err){
                if(typeof err === 'string') {
                    return  { type:"legacy", code:"LEG", message : err  }
                }
                else
                {
                    err.type    = err.type ? err.type : "MISSING"
                    err.code    = err.code ? err.code : "MISSING"
                    err.message = err.msg  ? err.msg  : "MISSING"

                    return  err
                }
            }
            else if(err && err.raw) {
                var ret         = {}
                for(var r in err.raw)
                    ret[r] = err.raw[r]

                ret.code        = err.status
                ret.message     = err.summary ? err.summary : err.error
                ret.type        = err.error

                return ret
            }

            return  { type:'unknown', code:'8125', message : 'shenanigans', originPtr: 'no pointer' }
        }
        function correctifyUrl(url){
            if(url.charAt(0) !== "/") {
                return "/" + url;
            }
            return url;
        }
        function findInHistory(obj) {
            if(externalDebugFunc)
                externalDebugFunc('ZClient.qml - findInHistory(obj)- FIX COMPARiSON')

            for(var o in  controller.requestHistory)
            {
                if(JSON.stringify(obj) == JSON.stringify(controller.requestHistory[o])     )
                    return true
            }
            return false
        }
        function handleError(origin, response){
            if(!response)
                return console.warn("O__O SOCKETIO O_O @",origin, "Null response")

            var e ;
            if(isArray(response))     e = response[0].err ? response[0].err : response[0].error
            else                      e = response.err    ? response.err    : response.error

            if(e){
                if(controller.errToJsObj && controller.errHandler){
                    var errObj = controller.errToJsObj(response)
                    errObj.origin = origin
                    controller.errHandler(errObj)
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
        function errorCheck(response, errDisplay){
            if(response && (response.err || response.error) ) {
                priv.handleError('ZClient.' + errDisplay + ' (server validation error)' , response)
                return false
            }
            return true
        }
        function req(type, url, params, callback, modelToUpdate){
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
                modelToUpdate :modelToUpdate
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
//            console.log("ADDING EVENT", url)
            var uarr = url.toString().split("/")
            if(uarr.length > 0 && uarr[0] !== "")
                socketHandler.addEvent(uarr[0])
        }

        function cbHandlerFunc(response, callback, type,url, modelToUpdate){
            var retTimes = { model : 0, callback : 0 }
            var time

            if(response){
//                console.log(JSON.stringify(response,null,2))
                if(modelToUpdate && priv.errorCheck(response, type + 'req') && response.data) {
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




    }
    ZSocketIO {
        id : socketHandler
        onServerResponse: {
            var jsRes = priv.parseAndCheck(value,"",cbId)
//            if(eventName.indexOf("user") === 0 && JSON.stringify(value).indexOf("572a76c905fdb1545abab84b") !== -1) {
//                console.log(eventName, JSON.stringify(jsRes,null,2))
//            }

            if(logic.isArray(jsRes))        jsRes = jsRes[0]
            if(jsRes.statusCode && !jsRes.statusCode === "200" && !jsRes.statusCode === "201")  {
                //is error!
                if(errHandler){
                    errHandler( { msg   : "Server Error",
                                  event : eventName,
                                  code  : jsRes.statusCode
                                }
                               )
                }

                return;
            }
            if(jsRes.headers && typeof jsRes.body !== 'undefined')  //use part of the message we actually need!
                jsRes = jsRes.body
            if(jsRes.statusCode && !jsRes.statusCode === "200" && !jsRes.statusCode === "201")  {
                //is error!
                if(errHandler){
                    errHandler( { msg   : "Server Error",
                                  event : eventName,
                                  code  : jsRes.statusCode
                                }
                               )
                }

                return;
            }

            var arr = eventName.split("/")
            var mName = arr[0] !== "" ? arr[0] : arr.length > 1 ? arr[1] : ""

//            console.log(eventName)
            if(mName !== "")
                logic.handleMessage(jsRes , mName)
            else
                console.log("bad model name!")


            if(cbId !== "") {
                var cbObj = priv.cbObjects[cbId]
                if(cbObj) {
                    //emit signal that res was received!
                    resReceived(cbId, cbObj.type, cbObj.url, jsRes);
                    var time = priv.now()
                    var times = priv.cbHandlerFunc(jsRes,  cbObj.callback, cbObj.type, cbObj.url, cbObj.modelToUpdate)
                    time = priv.now() - time

                    if(time > longTime) {
                        console.warn("WARNING : handling response for ", cbObj.url, "took", (time/1000).toFixed(2), " seconds!!!! model:",
                                      times.model/1000, " secs. callback:",times.callback/1000, " secs")

//                        console.log("---------------------------------------")
//                        console.trace()
//                        console.log("---------------------------------------")
                    }
                    resProcessed(cbId, time)


                    delete priv.cbObjects[cbId]
                }
            }
        }


        property QtObject logic : QtObject {
            id : logic
            property var defaultEvents : ["message","prints"]   //todo, make prints outside


            function isArray(obj) {
                return toString.call(obj) === '[object Array]'
            }
            function handleMessage(message , modelName, depth){

//                console.log("handleMessage", modelName, JSON.stringify(message,null,2))
//                console.log("----------------------------")
//                console.log(JSON.stringify(message,null,2))
//                console.log("----------------------------")

                if(depth === null || typeof depth === 'undefined')
                    depth = 0

//                if(depth === 0 && isArray(message) && message.length > 0 && message[0].body && message[0].body.data){
//                    var item1 = message[0]
//                    if(item1.body && item1.body.data)
//                        return handleUserModel(item1.body.data, null, depth + 1)
//                }

                modelName = message && message.model ? message.model : modelName

                if(message === null || typeof message === 'undefined'){
//                    console.error("SocketIOController.handleUserModel: message is missing", message)
                    return;
                }

                if(message.data === null || typeof message.data === 'undefined'){
//                    console.error("SocketIOController.handleUserModel: message.data is missing", message.data)
                    return;
                }


                if(isArray(message.data)){
//                    console.log(JSON.stringify(message,null,2))
                    for(var d = 0; d < message.data.length; d++){
                        handleMessage({data:message.data[d] , verb:message.verb }, modelName, depth + 1)
                    }
                }
                else {
//                    console.log("made it!!", JSON.stringify(message,null,2))
                    var verb = message.verb
//                    console.log("this verb was received", verb, "on", modelName)
            //        debug.bypass(JSON.stringify(message.data,null,2))
                    switch (verb) {
                        case "updated":
                            debug.debugMsg("update message received on", modelName + "." + message.id)
                            if(typeof message.data.id === 'undefined')
                                message.data.id = message.id

//                            console.log("update message received on", modelName + "." + message.id )

                            controller.addModel(modelName, message.data)    //If one of the sets failed, that means that we either didn't have this property
                            updateReceived(modelName, message.data.id, message.data)
                            debug.debugMsg("finished handling update message received on", modelName + "." + message.id)
                            break;

                        case "update":
                                debug.debugMsg("update message received on", modelName + "." + message.id)
                                if(typeof message.data.id === 'undefined')
                                    message.data.id = message.id

//                                console.log("update message received on", modelName + "." + message.id )


                                controller.addModel(modelName, message.data)    //If one of the sets failed, that means that we either didn't have this property
                                /*if(message.model === 'deals') {
                                    console.log("DATA=", JSON.stringify(message.data,null,2),
                                                "ON MODEL=", JSON.stringify(_controller.getById("deals",message.data.id)    ))
                                }      */                                   //or the whole item. In any case, appendToModel should take care of it
                                                                                    //But it does much more instructions so we only call it if we have to
                                updateReceived(modelName, message.data.id, message.data)
                                debug.debugMsg("finished handling update message received on", modelName + "." + message.id)
                                break;

                        case "create":
                                debug.debugMsg("create message received on", modelName + "." + message.id)
                                if(!message.data.id)
                                    message.data.id = message.id

                                controller.addModel(modelName, message.data)   //If one of the sets failed, that means that we either didn't have this property
                                                                                           //or the whole item. In any case, appendToModel should take care of it
                                                                                           //But it does much more instructions so we only call it if we have to
                                createReceived(modelName, message.data.id, message.data)
                                debug.debugMsg("finished handling update message received on",modelName + "." + message.id)
                                break;

                        case "created":
                                debug.debugMsg("create message received on", modelName + "." + message.id)
                                if(!message.data.id)
                                    message.data.id = message.id

                                controller.addModel(modelName, message.data)   //If one of the sets failed, that means that we either didn't have this property
                                                                                           //or the whole item. In any case, appendToModel should take care of it
                                                                                           //But it does much more instructions so we only call it if we have to
                                createReceived(modelName, message.data.id, message.data)
                                debug.debugMsg("finished handling update message received on",modelName + "." + message.id)
                                break;

            //            case "created":
            //                    debug.debugMsg("create message received on", message.model + "." + message.id)
            //                    if(!message.data.id)
            //                        message.data.id = message.id

            //                    controller.addModel(message.model, message.data)   //If one of the sets failed, that means that we either didn't have this property
            //                                                                               //or the whole item. In any case, appendToModel should take care of it
            //                                                                               //But it does much more instructions so we only call it if we have to
            //                    createReceived(message.model, message.data.id)

            //                    debug.debugMsg("finished handling update message received on", message.model + "." + message.id)
            //                    break;

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

//        onError   : { console.log("SocketIOController::error"  , message) ; controller.error(message);     }
//        onWarning : { console.log("SocketIOController::warning", message) ; controller.warning(message);   }
//        onInfo    : { console.log("SocketIOController::info"   , message) ; controller.info(message);      }

        onRegisteredEventsChanged: {
            socketHandler.addEvents(logic.defaultEvents)
//            console.log(socketHandler.registeredEvents)
        }
    }
}


