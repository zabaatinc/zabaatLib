import QtQuick 2.4
import Zabaat.SocketIO 0.9
import Zabaat.Utility.ZController 1.0

SocketIO
{
    property alias controller : _controller

    onFailed: //occurs when connection open fails!
    {
        if     (failureType === failType.webSocketError)       debug.debugMsg("Client -- FailureOccured : webSocketError")
        else if(failureType === failType.handshakeError)       debug.debugMsg("Client -- FailureOccured : handShakeError")
        else if(failureType === failType.handshakeRejected)    debug.debugMsg("Client -- FailureOccured : handShakeRejected")
        else                                                   debug.debugMsg("Client -- FailureOccured : unknownError")
    }

    signal statusUpdate (string status,int reconnectTimer)
    signal updateReceived(string updatedModel, string updatedId)
    signal createReceived(string createdModel, string createdId)

    onReconnectingIn:
    {
        statusUpdate('socket reconnecting in',seconds)
        debug.debugMsg("Client -- Attempting to reconnect in", seconds)
    }


    id : socketHandler
//    uri: "ws://10.0.0.235:1337"
    uri: ''
// don't forget to set token!
    token: ''

//    onUriChanged:
//    {
//        if(token !== '' && uri!=='')
//            if(socketHandler.connected)
//                socketHandler.disconnect()

//        socketHandler.connect()

//    }

//    onTokenChanged: {
//        if(token !== '' && uri!==''){
//            if(socketHandler.connected) socketHandler.disconnect()

//            socketHandler.connect()
//        }
//    }


    ///////// PUT YOUR SUBSCRIPTIONS here
    eventFunctions: [{type:"on",eventName:"message",cb:function (msg) {handleUserModel(msg)}}]

    function handleUserModel(message)
    {
//        console.log(JSON.stringify(message,null,2))

        //console.log("-------------------------------------------- ",JSON.stringify(message.data,null,2))
        var verb = message.verb
//        debug.bypass(JSON.stringify(message.data,null,2))
        switch (verb)
        {
            case "update":
                    debug.debugMsg("update message received on", message.model + "." + message.id)
                    if(typeof message.data.id === 'undefined')
                        message.data.id = message.id


                    controller.addModel(message.model, message.data)    //If one of the sets failed, that means that we either didn't have this property
                    /*if(message.model === 'deals') {
                        console.log("DATA=", JSON.stringify(message.data,null,2),
                                    "ON MODEL=", JSON.stringify(_controller.getById("deals",message.data.id)    ))
                    }      */                                   //or the whole item. In any case, appendToModel should take care of it
                                                                        //But it does much more instructions so we only call it if we have to
                    updateReceived(message.model, message.data.id)




                    debug.debugMsg("finished handling update message received on", message.model + "." + message.id)
                    break;

            case "create":
                    debug.debugMsg("create message received on", message.model + "." + message.id)
                    if(!message.data.id)
                        message.data.id = message.id

                    controller.addModel(message.model, message.data)   //If one of the sets failed, that means that we either didn't have this property
                                                                               //or the whole item. In any case, appendToModel should take care of it
                                                                               //But it does much more instructions so we only call it if we have to
                    createReceived(message.model, message.data.id)

                    debug.debugMsg("finished handling update message received on", message.model + "." + message.id)
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


    ZController
    {
        id                        : _controller
        debugMode                 : false
        externalDebugFunc         : socketHandler.externalDebugFunc
        modelTransformerFunctions : ({ books : priv.transformBooks })

        property var errHandler     : null          //works on postReqs
        property var errToJsObj     : null
        property var requestHistory : []



        onSendGetModelRequest: {
            debug.debugMsg("<-- Client.controller.getModelRequest SIGNAL:", modelName)
            socketHandler.getReq("/" + modelName + "/",  function (obj)
            {
                debug.debugMsg("--> Client.controller.getModelRequest CALLBACK:", modelName)
                try
                {
                    var modelObj = JSON.parse(obj)
//                    console.log("this is the thign!!!", JSON.stringify(modelObj,null,2))
                    controller.addModel(modelName, modelObj)
                }
                catch(e) {
                    if(errHandler){
                        errHandler({
                                    msg         : "Failed to parse server response. Make sure server is running: "+  e.message,
                                    type        : "Exception",
                                    code        : "",
                                    origin      : "ZController.onSendGetModelRequest",
                                    originPtr   : _controller,
                                   })
                    }
                    else
                        debug.debugMsg("Failed to parse server response. Make sure server is running :", e.message, obj)
                }
            })
        }

        //Convenience functions
        //params must be {}
        //override:true pass all requests through the history filter
        function postReq(url, params, callback,modelToUpdate,override,passToken){
            priv.req('post', url, params, callback, modelToUpdate, override, passToken)
        }
        function putReq(url, params, callback,modelToUpdate,override,passToken) {
            priv.req('put', url, params, callback, modelToUpdate, override, passToken)
        }
        function getReq(url, params, callback, modelToUpdate,override,passToken){
            priv.req('get', url, params, callback, modelToUpdate, override, passToken)
        }
        function deleteReq(url, params, callback, modelToUpdate, override, passToken){
            priv.req('delete', url, params, callback, modelToUpdate, override, passToken)
        }



        function tokenAppend(paramsA){
            var params = paramsA
            if(typeof params ==='undefined'|| params === null){var params={access_token:socketHandler.token}}
            else{
              params['acces_token']= socketHandler.token
            }
            return params
        }

        QtObject {
            id : priv
            function findInHistory(obj) {
                if(externalDebugFunc)
                    externalDebugFunc('ZClient.qml - findInHistory(obj)- FIX COMPARiSON')

                for(var o in  _controller.requestHistory)
                {
                    if(JSON.stringify(obj) == JSON.stringify(_controller.requestHistory[o])     )
                        return true
                }
                return false
            }
            function transformBooks(data, cb){
                console.log(JSON.stringify(data,null,2))
                if(_controller.isArray(data)){
                    for(var d = 0; d < data.length; d++){
                        if(data[d].accounts)
                            data[d].accounts = arrayifyAccounts(data[d])
                    }
                }
                else
                {
                    console.log(this, 'transformBooks', 'response is not an array')
                    if(data.accounts)
                        data.accounts = arrayifyAccounts(data)
                }

                if(cb){
//                    console.log('BOOKS CB')
                    cb('books',data)
                }
            }
            function arrayifyAccounts(obj, arr, count){
                if(arr === null || typeof arr === 'undefined')
                    arr = []
                if(count === null || typeof count === 'undefined')
                    count = 0


                if(obj.accounts){
                    for(var a in obj.accounts){
                        var acct = obj.accounts[a]
                        var newObj = { id : a,
                                       type           : acct.type,
                                       name           : acct.name,
                                       accounts       : getObjectPropertyNames(acct.accounts),
                                       trialBalance   : acct.trialBalance,
                                       endingBalance  : acct.endingBalance,
                                       balanceForward : acct.balanceForward }

                        arr.push(newObj)

                        if(acct.accounts !== null && typeof acct.accounts !== 'undefined'){
//                            console.log('DEEPER we go')
                            arrayifyAccounts(acct, arr, count + 1)
                        }
                    }
                }

//                console.log('return arrayify', count)
                return arr
            }
            function handleError(origin, response){
                if(_controller.errToJsObj && _controller.errHandler && response && response[0] && (response[0].err || response[0].error) ){
                    var errObj = _controller.errToJsObj(response)
                    errObj.origin = origin
                    _controller.errHandler(errObj)
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
                        if(_controller.errHandler){
                            _controller.errHandler({
                                        msg         : "Failed to parse server response from request:" + url,
                                        type        : "Exception",
                                        code        : "",
                                        origin      : "ZController." + errDisplay + " (socketHandler.request callback. ParseAndCheck)",
                                        originPtr   : _controller,
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
                if(override && priv.findInHistory(params))        return    //if found in history, then don't do it
                else                                              _controller.requestHistory.push(params)

                if (passToken)
                    params = _controller.tokenAppend(params)

                socketHandler.request(url.toString(), params, function(response) {
                    if(response){
//                        console.log(typeof response, typeof response[0])
                        response[0] = priv.parseAndCheck(response[0], type + "req", url)

                        if(response[0] !== false && modelToUpdate && priv.errorCheck(response[0], type + "req") )
                           _controller.addModel(modelToUpdate, response[0]);    //TODO, add one for delete

                        if(typeof callback === 'function') {

                            try {
                                if(type === 'get')    callback(response[0]);  //TODO fix this later! :)
                                else                  callback(response);     //they should all behave the same way
                            }
                            catch(e){
                                console.log("BZZT BZZT BLOOP TI DOOP", socketHandler,type, ":","Error when executing callback for", url, e)
                            }

                        }
                    }
                },type);
            }
        }




    }

}

