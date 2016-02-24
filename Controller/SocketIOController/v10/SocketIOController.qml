import QtQuick 2.5
import Zabaat.SocketIO 1.0
import "../../ZController"

ZController {
    id                          : controller
    debugMode                   : false
//    externalDebugFunc           : socketHandler.externalDebugFunc
//    modelTransformerFunctions   : ({ books : priv.transformBooks })
    signal statusUpdate  (string status, int reconnectTimer)
    signal updateReceived(string updatedModel, string updatedId)
    signal createReceived(string createdModel, string createdId)


    property var    errHandler            : null          //works on postReqs
    property var    errToJsObj            : null
    property var    requestHistory        : []
    property string uri                   : ""
    property string token                 : ""
    property bool   autoAddEventListeners : true

    //SOCKETIO related
    property alias socketio : socketHandler

    function connect(uri, jsQuery){
        if(uri === null || typeof uri === 'undefined')
            uri = controller.uri

        if(jsQuery === null || typeof jsQuery === 'undefined')
            jsQuery = {__sails_io_sdk_version : "1.2.0" }

        socketHandler.connect(uri,jsQuery)
    }
    readonly property var   disconnect      : socketHandler.disconnect
    readonly property alias isConnected     : socketHandler.isConnected
    readonly property alias sessionId       : socketHandler.sessionId
    property alias          registeredEvents: socketHandler.registeredEvents
//    readonly property var   addEvents       : socketHandler.addEvents
    readonly property var   addEvent        : socketHandler.addEvent
    readonly property var   removeEvent     : socketHandler.removeEvent
//    readonly property var   removeEvents    : socketHandler.removeEvents



    onSendGetModelRequest: {
        debug.debugMsg("<-- ZController.getModelRequest SIGNAL:", modelName)
//            socketHandler.sailsGet(url,params,cb,headers)
        socketHandler.sailsGet("/" + modelName + "/", null, function (obj)
        {
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
    function postReq(url, params, callback,modelToUpdate,override,passToken){
        //decipher the mdoelname!!
        priv.req('Post', url, params, callback, modelToUpdate, override, passToken)
    }
    function putReq(url, params, callback,modelToUpdate,override,passToken) {
        priv.req('Put', url, params, callback, modelToUpdate, override, passToken)
    }
    function getReq(url, params, callback, modelToUpdate,override,passToken){
        priv.req('Get', url, params, callback, modelToUpdate, override, passToken)
    }
    function deleteReq(url, params, callback, modelToUpdate, override, passToken){
        priv.req('Delete', url, params, callback, modelToUpdate, override, passToken)
    }
    function tokenAppend(paramsA){
        var params = paramsA
        if(typeof params ==='undefined'|| params === null)           params              = {access_token:socketHandler.token }
        else                                                         params.access_token = socketHandler.token

        return params
    }

    QtObject {
        id : priv
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
        function req(type, url, params, callback, modelToUpdate, override, passToken){
            if(autoAddEventListeners)
                priv.addEvent(url)

            if(override && priv.findInHistory(params))        return    //if found in history, then don't do it
            else                                              controller.requestHistory.push(params)

            if (passToken)
                params = controller.tokenAppend(params)



//            socketHandler.sailsGet(url.toString(), params, )
            //sails + type is the typeof function we are calling. sailsGet , sailsPut
            url = correctifyUrl(url)
            socketHandler["sails" + type](url.toString(), params, function(response) {
                if(response){
                    response = priv.parseAndCheck(response,type+'req',url)
//                    console.log(JSON.stringify(response,null,2))
//                    console.log(JSON.stringify(response,null,2))
                    if(response.body)
                        response = response.body

                    if(response !== false && modelToUpdate && priv.errorCheck(response, type + 'req'))
                        controller.addModel(modelToUpdate, response.data);

                    if(typeof callback === 'function') {

                        try {
                            callback(response);
//                            if(type === 'get')    callback(response[0]);  //TODO fix this later! :)
//                            else                  callback(response);     //they should all behave the same way
                        }
                        catch(e){
                            console.log("BZZT BZZT BLOOP TI DOOP", socketHandler,type, ":","Error when executing callback for", url, e)
                        }

                    }

//                    if(response[0] !== false && modelToUpdate && priv.errorCheck(response[0], type + "req") )
//                       controller.addModel(modelToUpdate, response[0]);    //TODO, add one for delete

//                    if(typeof callback === 'function') {

//                        try {
//                            if(type === 'get')    callback(response[0]);  //TODO fix this later! :)
//                            else                  callback(response);     //they should all behave the same way
//                        }
//                        catch(e){
//                            console.log("BZZT BZZT BLOOP TI DOOP", socketHandler,type, ":","Error when executing callback for", url, e)
//                        }

//                    }


                }
            });
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
    }
    ZSocketIO {
        id : socketHandler
//        onServerResponse: logic.handleUserModel(priv.getJsObject(value) , eventName)
        property QtObject logic : QtObject {
            id : logic
            property var defaultEvents : ["message"]
            function isArray(obj) {
                return toString.call(obj) === '[object Array]'
            }
            function handleUserModel(message , modelName, depth){
//                console.log("hadnleUserMessageMdoel", JSON.stringify(message,null,2))
                if(depth === null || typeof depth === 'undefined')
                    depth = 0

//                if(depth === 0 && isArray(message) && message.length > 0 && message[0].body && message[0].body.data){
//                    var item1 = message[0]
//                    if(item1.body && item1.body.data)
//                        return handleUserModel(item1.body.data, null, depth + 1)
//                }

                modelName = message && message.model ? message.model : modelName

                if(message === null || typeof message === 'undefined'){
                    console.error("SocketIOController.handleUserModel: message is missing", message)
                    return;
                }

                if(message.data === null || typeof message.data === 'undefined'){
                    console.error("SocketIOController.handleUserModel: message.data is missing", message.data)
                    return;
                }


                if(isArray(message.data)){
//                    console.log(JSON.stringify(message,null,2))
                    for(var d = 0; d < message.data.length; d++){
                        handleUserModel({data:message.data[d] , verb:message.verb }, modelName, depth + 1)
                    }
                }
                else {
//                    console.log("made it!!", JSON.stringify(message,null,2))
                    var verb = message.verb
            //        debug.bypass(JSON.stringify(message.data,null,2))
                    switch (verb) {
                        case "updated":
                            debug.debugMsg("update message received on", modelName + "." + message.id)
                            if(typeof message.data.id === 'undefined')
                                message.data.id = message.id

                            controller.addModel(modelName, message.data)    //If one of the sets failed, that means that we either didn't have this property
                            updateReceived(modelName, message.data.id)
                            debug.debugMsg("finished handling update message received on", modelName + "." + message.id)
                            break;

                        case "update":
                                debug.debugMsg("update message received on", modelName + "." + message.id)
                                if(typeof message.data.id === 'undefined')
                                    message.data.id = message.id


                                controller.addModel(modelName, message.data)    //If one of the sets failed, that means that we either didn't have this property
                                /*if(message.model === 'deals') {
                                    console.log("DATA=", JSON.stringify(message.data,null,2),
                                                "ON MODEL=", JSON.stringify(_controller.getById("deals",message.data.id)    ))
                                }      */                                   //or the whole item. In any case, appendToModel should take care of it
                                                                                    //But it does much more instructions so we only call it if we have to
                                updateReceived(modelName, message.data.id)
                                debug.debugMsg("finished handling update message received on", modelName + "." + message.id)
                                break;

                        case "create":
                                debug.debugMsg("create message received on", modelName + "." + message.id)
                                if(!message.data.id)
                                    message.data.id = message.id

                                controller.addModel(modelName, message.data)   //If one of the sets failed, that means that we either didn't have this property
                                                                                           //or the whole item. In any case, appendToModel should take care of it
                                                                                           //But it does much more instructions so we only call it if we have to
                                createReceived(modelName, message.data.id)

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

                        case "destroy" : console.log(socketHandler, "TODO : IMPLEMENT DESTROY"); break;

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

        onRegisteredEventsChanged: socketHandler.addEvents(logic.defaultEvents)
    }
}


