import QtQuick 2.0
import Zabaat.SocketIO 1.0
import Zabaat.Misc.Debug 1.0


SocketIO
{
    property alias controller : _controller


    onFailed: //occurs when connection open fails!
    {
        if(failureType == failType.webSocketError)
        {
            debug.debugMsg("Client -- FailureOccured : webSocketError")
        }
        else if(failureType == failType.handshakeError)
        {
            debug.debugMsg("Client -- FailureOccured : handShakeError")
        }
        else if(failureType == failType.handshakeRejected)
        {
            debug.debugMsg("Client -- FailureOccured : handShakeRejected")
        }
        else
            debug.debugMsg("Client -- FailureOccured : unknownError")
    }

    onReconnectingIn:
    {
        debug.debugMsg("Client -- Attempting to reconnect in", seconds)
    }

    id : socketHandler
    uri: "ws://10.0.0.235:1337"
//    uri: "ws://10.0.0.70:1337"
//  uri: "ws://10.0.0.235:3000"
//  uri: "ws//10.0.0.102:1337"

    property var map : []       //this is the map that lets us know the structure of the objects we receive (the table), we
                                //should get this from the server!

    function evalStringUsingMap(parentArr, restArr)
    {
        if(map[parentArr[0]] === restArr[0])    return evalStringUsingMap(restArr.slice(0,2), restArr.slice(2))
        else                                    return parentArr.concat(restArr)
    }



    ///////// PUT YOUR SUBSCRIPTIONS here
    eventFunctions: [{type:"on",eventName:"message",cb:function (msg) {handleUserModel(msg)}}]

    function handleUserModel(message)
    {
        //console.log("-------------------------------------------- ",JSON.stringify(message.data,null,2))
        var verb = message.verb

        switch (verb)
        {
            case "update":
                    var id        = message.id
                    var modelName = message.model

                    debug.debugMsg("update message received on", modelName + "." + id)
                    debug.debugMsg(JSON.stringify(message.data,null,2))

                    for(var d in message.data)
                    {
                        if(!controller.set(modelName, id + "/" + d, message.data[d], true))  //the true means dont echo back this change to the server
                        {
                            controller.__appendToModel(modelName, message.data)   //If one of the sets failed, that means that we either didn't have this property
                                                                        //or the whole item. In any case, appendToModel should take care of it
                                                                        //But it does much more instructions so we only call it if we have to
                            break
                        }
                    }

                    break;
        }


        debug.debugMsg("finished handling update message received on", modelName + "." + id)
    }




    Component.onCompleted: socketHandler.connect()



    ZController
    {
        id : _controller
        debugMode : false
        externalDebugFunc: socketHandler.externalDebugFunc
//        readonly property alias socket : socketHandler

        onSendGetModelRequest:
        {
            debug.debugMsg("<-- Client.controller.getModelRequest SIGNAL:", modelName)
            socketHandler.getReq("/" + modelName + "/",  function (obj)
            {
                debug.debugMsg("--> Client.controller.getModelRequest CALLBACK:", modelName)
                try
                {
                    var modelObj = JSON.parse(obj)
                    controller.addModel(modelName, modelObj)
                }
                catch(e) { debug.debugMsg("Failed to parse server response. Make sure server is running :", e.message, obj) }
            })
        }

        onSendUpdateRequest:
        {
            var sendStr = ""
            var arr = mapStr.split("/")

            //Extract the object from this updateRequest!
            var key = arr[arr.length-1]
            var obj = {}
            obj[key] = value

            arr.splice(arr.length - 1, 1)       //the last entry is just the name of the property, which we package into the object so we wont be sending that out

            if(arr.length > 2)      sendStr = evalStringUsingMap(arr.slice(0,2) , arr.slice(2)).join("/")
            else                    sendStr = arr.join("/")

            debug.debugMsg(sendStr, key, obj[key])

            socketHandler.putReq("/" + sendStr, obj, function(response) { /*empty function*/ } )
        }

        function postReq(url, params, callback,modelToUpdate) //params must be {}
        {
          socketHandler.request(url.toString(), params, function(response)
          {
            callback(response);
            if (modelToUpdate) __appendToModel(modelToUpdate, response[0]);
          },"post");
        }

        function getReq(url, params, callback, modelToUpdate) //params must be {}
        {
          socketHandler.request(url.toString(), params, function(response) {
            callback(response[0]);
            if (modelToUpdate) addModel(modelToUpdate, response[0]);
          },"get");
        }

        function partialGet()
        {
            socketHandler.putReq("/customers/partialGet", {},
                                 function(response)
                                 {
                                     try
                                     {
                                        var resObj = JSON.parse(response)
                                        addModel("customers", resObj)
                                     }
                                     catch(e) { console.log("error while parsing server response to customers/partialGet,",e.message) }


                                 })
        }


        function deepSubCb(responseObj)
        {
            for (var r in responseObj)
                addModel(r,responseObj[r])
        }
    }

}

