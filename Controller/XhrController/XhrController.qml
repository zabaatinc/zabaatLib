import QtQuick 2.5
import "../ZController"
import Zabaat.Base 1.0

/*!
   \brief an extension of the ZController that uses Xhr requests to communicate.
   \inqmlmodule Zabaat.Controller 1.0 \hr
*/
ZControllerDebug {
    id                          : controller
    debugMode                   : false
//    externalDebugFunc           : socketHandler.externalDebugFunc
//    modelTransformerFunctions   : ({ books : priv.transformBooks })

    /*! apparently never gets called \hr*/
    signal statusUpdate  (string status, int reconnectTimer)

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

    /*! Connect to uri using jsQuery \hr */
    function connect(uri, jsQuery){  //do make sure we have same APi as socketIOController. This sets the uri to this.
        if(uri === null || typeof uri === 'undefined')
            return console.log(controller,"cannot store", uri, "uri")
        controller.uri = uri;
    }

    onSendGetModelRequest: {
        debug.debugMsg("<-- ZController.getModelRequest SIGNAL:", modelName)
        priv.req("get",modelName,null,modelName)
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
    function postReq(url, params, callback,modelToUpdate,override,passToken){
        //decipher the mdoelname!!
        priv.req('post', url, params, callback, modelToUpdate, override, passToken)
    }

    /*! url      : is actually the function name. Do not need to specify full path here. Only /update or something like that.  \hr
        params   : the jsObject to send out
        callback : the function to run when we get a response from the server
        override :  don't run this if already ran this. Kinda useless. should be removed perhaps.
        passToken : this is automatically token from rootObject
    */
    function putReq(url, params, callback,modelToUpdate,override,passToken) {
        priv.req('put', url, params, callback, modelToUpdate, override, passToken)
    }

    /*! url      : is actually the function name. Do not need to specify full path here. Only /update or something like that.  \hr
        params   : the jsObject to send out
        callback : the function to run when we get a response from the server
        override :  don't run this if already ran this. Kinda useless. should be removed perhaps.
        passToken : this is automatically token from rootObject
    */
    function getReq(url, params, callback, modelToUpdate,override,passToken){
        priv.req('get', url, params, callback, modelToUpdate, override, passToken)
    }

    /*! url      : is actually the function name. Do not need to specify full path here. Only /update or something like that.  \hr
        params   : the jsObject to send out
        callback : the function to run when we get a response from the server
        override :  don't run this if already ran this. Kinda useless. should be removed perhaps.
        passToken : this is automatically token from rootObject
    */
    function deleteReq(url, params, callback, modelToUpdate, override, passToken){
        priv.req('delete', url, params, callback, modelToUpdate, override, passToken)
    }


    /*! Returns an object with {access_token:<token> } \hr */
    function tokenAppend(paramsA){
        var params = paramsA
        if(params === null || typeof params ==='undefined')
            params = {access_token:token }
        else
          params.access_token = token

        return params
    }

    QtObject {
        id : priv
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

        function cleanPath(uri,funcName){
            if(uri && funcName){
                if(uri.charAt(uri.length - 1) === "/")
                    uri = uri.slice(0,-1)
                if(funcName.charAt(0) === "/")
                    funcName = funcName.slice(1)

                return uri + "/" + funcName
            }
            return ""
        }

        function findInHistory(obj) {
            if(externalDebugFunc)
                externalDebugFunc('ZClient.qml - findInHistory(obj)- FIX COMPARiSON')

            for(var o in  controller.requestHistory) {
                if(JSON.stringify(obj) == JSON.stringify(controller.requestHistory[o])     )
                    return true
            }
            return false
        }
        function handleError(origin, response){
            if(controller.errToJsObj && controller.errHandler && response && response[0] && (response[0].err || response[0].error) ){
                var errObj = controller.errToJsObj(response)
                errObj.origin = origin
                controller.errHandler(errObj)
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
            if(typeof response === 'string'){
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
                                    origin      : "XhrController." + errDisplay + " (socketHandler.request callback. ParseAndCheck)",
                                    originPtr   : controller,
                                   })
                    }
                    else
                        console.log(e);
                }

                if(!success){
                    console.log(controller, "Failed in parsing JSON from server (parseAndCheck)", errDisplay)
                    return false
                }
            }
            return response
        }
        function errorCheck(response, errDisplay){
            if(response && (response.err || response.error) ) {
                priv.handleError('XhrController.' + errDisplay + ' (server validation error)' , response)
                return false
            }
            return true
        }

        function req(type, url, params, callback, modelToUpdate, override, passToken){
            if(override && priv.findInHistory(params))        return    //if found in history, then don't do it
            else                                              controller.requestHistory.push(params)

            if (passToken)
                params = controller.tokenAppend(params)

            var cp = cleanPath(uri,url)
//            console.log(cp)
            if(cp === null || typeof cp === 'undefined' || cp === "")
                return console.error("something is wrong with the path")

            Functions.xhr[type](cp , params, function(response) {
//                console.log(JSON.stringify(response,null,2))
                if(response){
                    response = getJsObject(response);
                    response = priv.parseAndCheck(response, type + "req", url)
//                    console.log(JSON.stringify(response[0],null,2))

                    if(response !== false && modelToUpdate && priv.errorCheck(response, type + "req") )
                       controller.addModel(modelToUpdate, response.data);    //TODO, add one for delete

                    if(typeof callback === 'function') {
                        try {
                            callback(response);
                        }
                        catch(e){
                            console.log("BZZT BZZT BLOOP TI DOOP", controller,type, ":","Error when executing callback for", url, e)
                        }
                    }
                }
            }, true);
        }
        function getJsObject(item){
            if(typeof item === "string"){
                return JSON.parse(item)
            }
            else
                return item
        }

        function isArray(obj) {
           return toString.call(obj) === '[object Array]'
       }
        function handleUserModel(message , modelName){
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
//                     console.log(JSON.stringify(message,null,2))
                for(var d = 0; d < message.data.length; d++){
                    handleUserModel({data:message.data[d] , verb:message.verb }, modelName)
                }
            }
            else {
//                     console.log("made it!!", JSON.stringify(message,null,2))
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
}
