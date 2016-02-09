/*
  Copyright (c) 2012, Nikolay Bondarenko <misterionkell@gmail.com>
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
  * Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
  * Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
  * Neither the name of the WebSocket++ Project nor the
  names of its contributors may be used to endorse or promote products
  derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL PETER THORSON BE LIABLE FOR ANY
  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.1
import Qt.WebSockets 1.0
import './lib/request.js' as Request
import './lib/container.js' as Container



// README / usage comments
/*
  For socketio version 0.9.6 and use with sails.js

you can manually test a send with
//                    sendTextMessage("5:1+::{\"name\":\"get\",\"args\":[{\"method\":\"get\",\"data\":{\"filter\":\"\"},\"url\":\"/customers/2\",\"headers\":{}}]}")

sample outputs of what your sendTextMessage should look like to interface with sails.js
//5:1+::{"name":"post","args":[{"method":"post","data":{"filter":""},"url":"/customers/filterList","headers":{}}]}
//5:2+::{"name":"post","args":[{"method":"post","data":{"filter":""},"url":"/vehicles/filterList","headers":{}}]}
//5:3+::{"name":"post","args":[{"method":"post","data":{"filter":""},"url":"/work_orders/filterList","headers":{}}]}

put the following in your main.qml file to call this correctly


  import Zabaat.SocketIO 1.0

SocketIO
    {
        id:socketHandler   //local id to use for the this object
         uri: "ws://10.0.0.235:1337"  //server address and port. use wss: for secure sockets (note, this doesn't necessarily guarantee the connection is encrypted

         ///////// PUT YOUR event message SUBSCRIPTIONS here
         eventFunctions: [{type:"on",eventName:"customers",cb:function (msg) {handleUserModel(msg)}}]
            // one object that includes
            //type: (on / once) on: always fires, once: dies after firing once
            // eventName: (name of event from sails server, usually the model
            // cb: (function) pass the function in here that you want to fire when this event happens

         function handleUserModel(message)
         {
             //debug.debugMsg("handleUserModel:message ",JSON.stringify(message,null,2))   //if you want to see the message
             var verb = message.verb   //verb is the case type for sails to find out what happened
                 switch (verb)
                 {
                     case "update":
                         break;
                 }
         }

         Component.onCompleted: {socketHandler.connect();}  //recommended to put this here
    }

  */

Item
{
    id: handler

    //added our Zabaat.Misc.Debug here like this because I didn't want SocketIO to be dependent on ZDebug
    property var externalDebugFunc : null
    property bool debugMode        : true
    property alias debug           : _debug



    QtObject
    {
        id : _debug
        function debugMsg()
        {
            if(debugMode)
            {
                if(externalDebugFunc)   externalDebugFunc.apply(this,arguments)
                else                    console.log.apply(this,arguments)
            }
        }

        function bypass()
        {
            if(externalDebugFunc)       externalDebugFunc.apply(this,arguments)
            else                        console.log.apply(this,arguments)
        }
    }

    property string uri;  //public   server connection string (url / port)
    property bool connected: false;
    onConnectedChanged: if(connected) privates.handleRequestQueue()


    property bool socketInit: true // true means we are doing our "run once" init operations

    property int heartbeatTimeout: 15000;  //@readonly
    property int disconnectTimeout: 25000; //@readonly
    property int requestInterval : 500
    property string sid;                   //@readonly
    property string token : '';     //passed in from above as a result of a login function being sucessful
    property string resource: 'socket.io'  // part of the connection string
    property int connectionTimeout: 10000
    property bool reconnect: true   //auto reconnect
    property alias reconnectionDelay : reconnectTimer.reconnectDelay
    property int reconnectionLimit: Infinity
    property int maxReconnectionAttempts: 10

    property var eventFunctions: null  //this store the functions that you bind to events that are triggered from the sails server. these are set outside of this file
    onEventFunctionsChanged: refreshEventFunctions()

//    property var global
    property var _uri;  //possibly unused?

    /**
     * Endpoint and id aren't usually used. So they must be last arguments. In
     * most of cases we need only data.
     */
    // IMPORTANT NOTE! These functions are not compatible with sails.js!
    signal message(string data, string endPoint, int id);
    signal jsonMessage(variant args, string endPoint, int id);
    signal eventMessage(string name, variant args, string endPoint, int id);
    signal errorMessage(string reason, string advice, string endPoint);

    signal opened();
    signal closed();
    signal failed(string failureType);      //added failure type so we can see and possibly handle it on the outside (WOLF)
    signal reconnectingIn(int seconds);     //The reconnectTimer will signal this out every second as it is running. This should let the gui know we are going to try to reconnect (WOLF)

    readonly property alias status: socket.status //exposes the status of the socket

    property var failType : ({ webSocketError    : "webSocketError",
                               handshakeError    : "handshakeError",
                               handshakeRejected : "handshakeRejected"
                            })


    Timer
    {
        id : reconnectTimer // this only occurs on webSocketError and handshakeError (on the failed signal)
        property int reconnectDelay : 5000 // starts off trying to reconnect in 5 seconds
        property int timeRunning    : 0
        interval : 1000
        repeat : true
        running : false

        function begin()
        {
            timeRunning = 0
            reconnectDelay *= 2
            debug.debugMsg("SocketIO -- Setting reconnect time to", reconnectDelay/1000 , "seconds")
            running = true
        }

        onTriggered :
        {
            timeRunning += interval
            debug.debugMsg("SocketIO -- Going to reconnect in", (reconnectDelay - timeRunning)/1000 , "seconds")
            reconnectingIn((reconnectDelay - timeRunning)/1000)

            if(timeRunning >= reconnectDelay)
            {
                running = false
                debug.debugMsg("SocketIO -- Attempting to reconnect after",reconnectDelay / 1000, "seconds of waiting...")
                handler.connect()
            }
        }
    }

    WebSocket {
        id: socket
        url: "FAKEURL"   //leave this as your main will pass in the right string, this can be changed to allow the server to load balance.

        /**
         * A counter used to prevent collisions in the timestamps used
         * for cache busting.
         */
        property int timestamps : 0  // this is generated from the current time in ms from Date.Now and then attached to your XHR requests to ensure no conflicts
        property int ackPackets: 0 /* important! this number is incremented to hold the index of each transmission so that the server can let you know which message it's responding to and then
        // pass the reply to the callback which is held in the next variable.
        */
        property var acks: ({}) //wolf is sad and wanted to call this axe. this is the array that holds the pendings ACKS ids<>callbacks table so that the messages can tell the rest of the program what to do
        property string name:"" //this holds  the endpoint and could be used to create separate instances of the socket, this info is inside the header  of the websocket after the message type and counter 5:2+:name:{}
        property var functions :
            ({
                generateTimestamp : function(appendCounter) { return _generateTimestamp(appendCounter) }
             })

        onTextMessageReceived:
        {
//            if (debug) debug.debugMsg("socket root rcv msg: " ,message);
            handler._parseMessage(message);

        }
//        onFailed: handler.failed();
        onStatusChanged: {
            console.log("SocketIO: status",status)
            debug.debugMsg("socket root: status changed ",status)
            if (status == WebSocket.Error)
            {
                debug.debugMsg("SocketIO -- onStatusChanged : WebSocket.Error! ",socket.errorString)
                handler.failed(failType.webSocketError)
                reconnectTimer.begin()
            }
            else if (status == WebSocket.Connecting)
            {
                debug.debugMsg("socket root: connecting to",url.toString())
            }

            else if (socketInit && status == WebSocket.Open) {
                    handler.connected = true;
                    handler.opened();
                    debug.debugMsg("socket root: I'm open")
                    sendTextMessage("2probe")  //this is for socket.io 1.2 but seems to not interfere with .9.6


                    reconnectTimer.running = false
                    reconnectTimer.reconnectDelay = 5000    //set the delay back to 5000 (so when we multiply it , it becomes 10 seconds from the timer's begin() function)


                    socketInit = false; //no longer in init Mode
            } else if (status == WebSocket.Closed) {
//                debugPane.append('#', 'socket closed')
                debug.debugMsg("socket root: close")
                handler.connected = false;
                handler.closed();
                socketInit = true;
            }
        }

        function _generateTimestamp(appendCounter)
        {
            var str = new Date().getTime()
            if (appendCounter) str+= "-"+timestamps
            timestamps++
            return str
        }
    }




/******************************************************************************
  //child private functions of handler class  */

    Item
    {
        id : privates
        property var requestQueue : []

        function handleRequestQueue(){

            console.time('handleRequestQueue')
            for(var r  = privates.requestQueue.length - 1; r >= 0 ; r--)
            {
                if(privates.requestQueue[r] !== null && typeof privates.requestQueue[r] !== 'undefined')
                {
                    var spliced = (privates.requestQueue.splice(r,1))[0]
                    if(!emit(spliced.req)){
                        console.log("request failed", spliced.url)
                        privates.requestQueue.push(spliced)
                    }
                }
            }
            console.timeEnd('handleRequestQueue')
        }

    }



    function refreshEventFunctions()  //when new functions are added to our handlers we refresh the containers
    {
        if (eventFunctions)
        {
            for (var i = 0; i < eventFunctions.length; i++)
            {
                if (eventFunctions[i].type == "once")onceEvent(eventFunctions[i].eventName,eventFunctions[i].cb);
                else onEvent(eventFunctions[i].eventName,eventFunctions[i].cb);
            }
        }
    }

    function onEvent(name, func)     {  return _registerEvent(Container.onHandlers  , name, func)  }
    function onceEvent(name, func)   {  return _registerEvent(Container.onceHandlers, name, func)  }



    function _registerEvent(container, name, func)
    {
        //Check if we have the "SIGNAL" name already. If we do, append the "SLOT" func to
        //the end of the respective container (passed from on or once function)
        if (container.hasOwnProperty(name))
        {
            //This is checking if this particular function ("SLOT") is already registered
            //to this this name ("SIGNAL") - Unique slot functionality
            if (container[name].filter(function(e) { return e === func; }).length)
                return false;

            container[name].push(func);
        }
        //Otherwise, make a new array and dump that "SLOT" into the respective container
        else
            container[name] = [func];

        return true;
    }


    function _handshake()  //initial request for the server to connect this generates a XHR request via the request.js file and it's dependency (socketHelper.js)
    {
        reconnectTimer.running = false      //we have sort of a redundant thing here , this is just to make sure if we manually reconnect we shut off the reconnect timer


        var uri         = new Request.Uri(handler.uri)    //send in the connection string to our request.js file
        var protocol  = uri.protocol()

        uri.setProtocol(protocol === 'wss' ? 'https' : 'http')
        uri.setPath('/socket.io/1/');     //statically set, could get this from the top instead
        console.log('socketIO debug access_token',token)
        var headerObj = {"acces_token":token}

        Request.http.request(uri, headerObj, function(response) //pass in uri to the request.js file, the request.js file will run it through it's parser and then pass to this call back
        {
            debug.debugMsg("XHR RESPONSE = ", JSON.stringify(response,null,1))

            var result = null
            try
            {
                result = JSON.parse(response.body.data)
            }
            catch(e)
            {
                debug.debugMsg("SocketIO -- _handShake()", e.message)
            }

            if (result === null)
            {
                debug.debugMsg('Socket.IO Handshake: Server response not match protocol ' +  response.body)  //you got weird data that we couldn't parse
                handler.failed(failType.handshakeError)
                reconnectTimer.begin()
                return
            }

            var sid = result.sid;

            if (response.status !== 200) //this is a HTTP request, so 200 is happy
            {
                debug.debugMsg('Socket.IO Handshake: Server rejected connection with code ' +  response.status)
                handler.failed(failType.handshakeRejected)
                return
            }

//            result = expr.exec(response.body);


            handler.heartbeatTimeout  = heartbeatTimeout //result.pingInterval
            handler.disconnectTimeout = disconnectTimeout //result.pingTimeout

            uri.setPath('/socket.io/1/websocket/' + sid);
            uri.setProtocol(protocol);

            debug.debugMsg('Socket.IO Handshake: Connecting to '  + uri)

            //if everything went well with the XHR request we now can connect via a websocket. We retain the data from our happy XHR request (sid) so that we can reassociate with the server.
            //TODO need authentication here / encryption?
            socket.url = uri.toString()+"?EIO=3&transport=websocket&t="+socket._generateTimestamp(true)+"&sid="+sid+"&b64=true" //b64=true sets us to base64 encoded mode and ensures
            //compatibility with the newer socket.io servers that implement binary functions
        });
    }

    function _sendHeartbeat()
    //TODO reset heartbeat timer upon other messages as it might not be needed if the server already knows we are alive still
    {
        socket.sendTextMessage('2::');
    }

    function _handleEvents(name, args)
    // fancy function to match up the events passed in from main.qml    DO NOT EDIT
    {
        if (Container.onceHandlers.hasOwnProperty(name))
        {
            Container.onceHandlers[name].forEach(function(e)
                                                 {
                                                     _executeHandler(e, args);
                                                 });
            delete Container.onceHandlers[name];
        }

        if (!Container.onHandlers.hasOwnProperty(name))
            return;


        Container.onHandlers[name] = Container.onHandlers[name].filter(function(e)
                                                                       {
                                                                            return _executeHandler(e, args);
                                                                       });
    }

    function _executeHandler(handler, args)
    {
        if (!handler)
            return false;

        try
        {
            handler.apply(this, args);  //just like call. Call this function with this and args
        }
        catch (e)
        {
             debug.debugMsg('Handler execution error: ' + e.message);
            return false;
        }

        return true;
    }

    function _sendErrorPacket(endPoint, rawString)
    {
        var plusPos = rawString.search('+');
        if (-1 === plusPos)
            return;

        errorMessage(rawString.substring(0, plusPos),
                     rawString.substring(plusPos + 1, rawString.length),
                     endPoint || '');
    }




    /************************************/





    //TODO, think of a better way to do this bropal.
//    Timer
//    {
//        id : requestQueueHandler
//        interval : requestInterval
//        running : handler.connected
//        repeat : true
//        property int totalRequestsHandled: 0
//        onTriggered:
//        {
//            var moreLeft = false
//            for(var r in privates.requestQueue) //we are breaking the for loop as soon as we find a valid request entry. This will only send ONE request per timer triggered!
//            {
//                if(privates.requestQueue[r] != null)
//                {
//                    moreLeft = true
//                    console.log("requesting",privates.requestQueue[r].url)
//                    emit(privates.requestQueue[r])
//                    debug.debugMsg("Handled Requests in Queue : " + (++totalRequestsHandled))
//                    break
//                }
//            }

//            privates.requestQueue[r] = null

//            if(!moreLeft)
//            {
//                privates.requestQueue = []
//            }
//        }
//    }






    function connect()
    {
        if(reconnectTimer.running)
            reconnectTimer.stop()

        if (!connected)
            _handshake()
    }

    function disconnect() //not tested
    {
        if (connected)
            socket.disconnect();
    }

    function forceDisconnect()
    {
        if (connected)
        {
            var uri = new Request.Uri(handler.uri);
            uri.global = handler.global
            uri.setProtocol(protocol === 'wss' ? 'https' : 'http');
            uri.setPath('/socket.io/1/websocket/' + sid);
            uri.addQueryItem('disconnect', '');

            Request.http.request(uri, function(response) {});
        }
    }

    // ***************  manual builder for socketio 1.2
//    function newSend(msgType,id,type,message)
//    {
//        if(connected)
//            socket.sendTextMessage(msgType + id + "[\"" + type + "\"" +"," + "\"" + message + "\"" + "]")
//    }

//****************** not used in sails.js
//    function sendJson(data, endPoint, id)
//    {
//        var message = JSON.stringify(data);
//         debug.debugMsg('Sended Message type 4 (JSON Message): ' + message)
//        send(4, message, endPoint, id);
//    }

    /**********    SAILS.js fake REST commands      *******/
    /**
     * Simulate a GET request to sails
     * e.g.
     *    `socket.get('/user/3', Stats.populate)`
     *
     * @api public
     * @param {String} url    ::    destination URL
     * @param {Object} params ::    parameters to send with the request [optional]
     * @param {Function} cb   ::    callback function to call when finished [optional]
     */

      function getReq(url,data,cb)
      {
        // `data` is optional
            if (typeof data === 'function') {
              cb = data;
              data = {};
            }
//            debug.debugMsg("cb =",cb)

//              cb({derp:"derp"})

            return _request({
              method: 'get',
              data: data,
              url: url
            }, cb);


      }
      /**
       * Simulate a POST request to sails
       * e.g.
       *    `socket.post('/event', newMeeting, $spinner.hide)`
       *
       * @api public
       * @param {String} url    ::    destination URL
       * @param {Object} params ::    parameters to send with the request [optional]
       * @param {Function} cb   ::    callback function to call when finished [optional]
       */
      function postReq(url,data,cb)
      {
          // `data` is optional
                if (typeof data === 'function') {
                  cb = data;
                  data = {};
                }

                return _request({
                  method: 'post',
                  data: data,
                  url: url
                }, cb);
      }
      /*path of execution:




        */

      /**
        * Simulate a PUT request to sails
        * e.g.
        *    `socket.post('/event/3', changedFields, $spinner.hide)`
        *
        * @api public
        * @param {String} url    ::    destination URL
        * @param {Object} params ::    parameters to send with the request [optional]
        * @param {Function} cb   ::    callback function to call when finished [optional]
        */
      function putReq(url,data,cb)
      {
          // `data` is optional
          if (typeof data === 'function') {
            cb = data;
            data = {};
          }

          return _request({
            method: 'put',
            data: data,
            url: url
          }, cb);
      }

      function deleteReq(url,data,cb)
      {
          // `data` is optional
          if (typeof data === 'function') {
            cb = data;
            data = {};
          }

          return _request({
            method: 'delete',
            data: data,
            url: url
          }, cb);
      }

      /**
       * Simulate an HTTP request to sails
       * e.g.
       *    `socket.request('/user', newUser, $spinner.hide, 'post')`
       *
       * @api public
       * @param {String} url    ::    destination URL
       * @param {Object} params ::    parameters to send with the request [optional]
       * @param {Function} cb   ::    callback function to call when finished [optional]
       * @param {String} method ::    HTTP request method [optional]
       */
    function request(url,data,cb,method)
    //this is the result of all the CRUD requests above, we pack them all nicely into a happy little message to be encoded
    {
//        debug.bypass('SOCKETIO ->  request ->', url, JSON.stringify(data))

        // `cb` is optional
        if (typeof cb === 'string') {
          method = cb;
          cb = null;
        }

        // `data` is optional
        if (typeof data === 'function') {
          cb = data;
          data = {};
        }

        return _request({
          method: method || 'get',
          data: data,
          url: url
        }, cb); //callback is still being passed
    }

    /**
     * Socket.prototype._request
     *
     * Simulate HTTP over Socket.io.
     *
     * @api private
     * @param  {[type]}   options [description]
     * @param  {Function} cb      [description]
     */
    function _request(options,cb)
    {

        // Sanitize options (also data & headers)
        var usage = 'Usage:\n socket.' +
          (options.method || 'request') +
          '( destinationURL, [dataToSend], [fnToCallWhenComplete] )';

        options = options || {};
        options.data = options.data || {};
        options.headers = options.headers || {};

        // Remove trailing slashes and spaces to make packets smaller.
        options.url = options.url.replace(/^(.+)\/*\s*$/, '$1');
        if (typeof options.url !== 'string') {
          throw new Error('Invalid or missing URL!\n' + usage);
        }

        // Build a simulated request object.
        var request = {
          method: options.method,
          data: options.data,
          url: options.url,
          headers: options.headers,
          cb: cb
        };

        // If this socket is not connected yet, queue up this request
        // instead of sending it.
        // (so it can be replayed when the socket comes online.)
//        if (!connected)
//        {
//            //we should handle the case of if the client is spamming us for requests while we are not yet up
////            debug.debugMsg("===============================================")
////            debug.debugMsg(request.url)
////            debug.debugMsg("===============================================")

//            privates.requestQueue[request.url] = request        //This will make it so we only have one request for a model at a time!! revisit this if you wish to change where this gets handled!
//            //privates.requestQueue.push(request)     //Just dump this request here. we'll send the requests out when we connect!


//          // If no queue array exists for this socket yet, create it.
////          this.requestQueue = this.requestQueue || [];
////          this.requestQueue.push(request);
//          return;
//        }
//         privates.requestQueue[request.url] = request

        if(!handler.connected){
            privates.requestQueue.push({url : request.url, req : request } )
        }
        else
            emit(request)

        //debug.bypass('SOCKETIO --> _request', JSON.stringify(privates.requestQueue))


        // Otherwise, our socket is ok!
        // Send the request.
//        emit(request);
    }


   //TODO implement more functionality for rooms
    function _emit(requestCtx)  // this is the _emitFrom function in sails.js This is for dynamic "namespace" rooms
//    http://socket.io/docs/rooms-and-namespaces/
    {
        // Since callback is embedded in requestCtx,
                    // retrieve it and delete the key before continuing.
                    var cb = requestCtx.cb;
                    delete requestCtx.cb;

                    // Name of socket request listener on the server
                    // ( === the request method, e.g. 'get', 'post', 'put', etc. )
                    var sailsEndpoint = requestCtx.method;
                    socket.emit(sailsEndpoint, requestCtx, function serverResponded(responseCtx) {

                        // Adds backwards-compatibility for 0.9.x projects
                        // If `responseCtx.body` does not exist, the entire
                        // `responseCtx` object must actually be the `body`.
                        var body;
                        if (!responseCtx.body) {
                            body = responseCtx;
                        } else {
                            body = responseCtx.body;
                        }

                        // Send back (emulatedHTTPBody, jsonWebSocketResponse)
                        if (cb) {
                            cb(body, new JWR(responseCtx));
                        }
                    });
    }

    function emit(a)
    {
        var b =[]  //stores the "arguements" this is basically all the data of your message but it's held in a single object array for later JSON stringify

        b[0] = {method:a.method,
                    data: a.data,
                    url:a.url,
                    headers:a.headers}


        var c = a.cb  //c stores your callback at this point
        var d = {
                type: "event",
                name: a.method
            };
        if ("function" === typeof c){   //so if your callback made it all the way down we are good to go now! note: this means we can't really send anything unless there is a cb attached
            socket.ackPackets++; // increment the message counter so we can insert into outgoing message for later matching
            d.id = socket.ackPackets;
            d.ack = "data";

            socket.acks[d.id] = c; // add callback to array so we can match the reply from server to our exterior callback
//            for(var k in socket.acks){
//                debug.bypass('SOCKETIO -> emit()', 'socket.acks :',  k, socket.acks[k])
//            }



            d.args = b  //
            return _packetSender(d)  //packet it shaping up - preparing to send out //returns true or false
        }
        return false
    }

    function _packetSender (a) {   //you finally found it! this is where the packets finally are sent from our socket to the server (after being encoded)
        a.endpoint = socket.name
        var encodedPacket = encodePacket(a)
//        debug.debugMsg("socket tx:",JSON.stringify(encodedPacket,null,1))

        return socket.sendTextMessage(encodedPacket)//a.flags = {}
    }


    function encodePacket(a){

        var c = a.parser = {},
        d = c.packets = ["disconnect", "connect", "heartbeat", "message", "json", "event", "ack", "error", "noop"],
        e = c.reasons = ["transport not supported", "client not handshaken", "unauthorized"],
        f = c.advice = ["reconnect"],
        g = JSON,
        h = indexOf
        return encodePacketCeption(a)

        function encodePacketCeption(a) {
            var b = h(d, a.type),
            c = a.id || "",
            i = a.endpoint || "",
            j = a.ack,
            k = null;
            switch (a.type) {
            case "error":
                var l = a.reason ? h(e, a.reason) : "",
                m = a.advice ? h(f, a.advice) : "";
                if (l !== "" || m !== "")
                    k = l + (m !== "" ? "+" + m : "");
                break;
            case "message":
                if (a.data !== "") k = a.data
                break;
            case "event":
                var n = {
                    name : a.name
                };
                if (a.args && a.args.length) {n.args = a.args; k = g.stringify(n)}
                break;
            case "json":
                k = g.stringify(a.data);
                break;
            case "connect":
                if (a.qs) k = a.qs;
                break;
            case "ack":
                k = a.ackId + (a.args && a.args.length ? "+" + g.stringify(a.args) : "")
            }
            var o = [b, c + (j == "data" ? "+" : ""), i];
            return k !== null && k !== undefined && o.push(k),o.join(":")
        }
    }

    function indexOf(arr,value){
        for (var i =0; i < arr.length;i++)
        {
            if (arr[i]===value) return i
        }
        return -1
    }



    /**
     * Parse response according to socket.IO rules.
     * https://github.com/LearnBoost/socket.io-spec
     */
    function _parseMessage(message)
    {
        debug.debugMsg("PARSE MESSAGE CALLED!",message)


        var packets = [  //fake enum of all the function types
            'disconnect'
          , 'connect'
          , 'heartbeat'
          , 'message'
          , 'json'
          , 'event'
          , 'ack'
          , 'error'
          , 'noop'
        ];

        //WOLF : message format (of type 4)
        //<1 digit num> <0-N digit Num> <[> <"message type"> <","> <"message"> <]>

        //Version .7 regex
        //        var expr = /([0-9a-zA-Z_-]*):([0-9]*):([0-9]*):(.*)/,

        //socket.io client regex
        // this is taken from the sails server dir
        //  node_modules/sails/node_modules/socket.io/node_modules/socket.io-client/lib/parser.js
        var socketRegex = /([^:]+):([0-9]+)?(\+)?:([^:]+)?:?([\s\S]*)?/
        var pieces = message.match(socketRegex);

        //////// wednesday commenting ended here

        var id = pieces[2] || ''
          , data = pieces[5] || ''
          , packet = {
                type: packets[pieces[1]]
              , endpoint: pieces[4] || ''
            };

        if (id) {
          packet.id = id;
          if (pieces[3])
            packet.ack = 'data';

          else
            packet.ack = true;
        }
//        var wolfExpr = /([0-8])([0-9]*)\[\"([^:]*)\"\,\"([^:]*)\"\]/
//        var result = message
//        var parsedObject

        //WOLF : the first character in a message is its type!, this is all we are doing here.
        //           the reason to get a number is so we can use a switch later (instead of .charAt(0))
//        var type  = Number(message[0]);

        if (message.length === 0)
        {
            debug.debugMsg('Socket.IO wrong packet data (MSG Empty) ' +  message);
            return;
        }


        if (packet.type === NaN)
        {
            debug.debugMsg('Socket.IO wrong packet type (NaN type)' + message[1]);
            return;
        }
        debug.debugMsg("TYPE:",packet.type)
        //equivalent of onPacket in socket.io
        switch(packet.type)    //handle message types here!!
        {
            case "disconnect":
                debug.debugMsg('Received message type 0 (Disconnect)');
                socket.disconnect();
                break;
            case "connect": //Connection Acknowledgement
                debug.debugMsg('Received Message type 1 (Connect)');
                packet.qs = data || '';
                break;
            case "heartbeat":
                debug.debugMsg('Received Message type 2 (Heartbeat)');
                _sendHeartbeat();
                break;
            case "message":
                debug.debugMsg('Received Message type 3 (Message): ' + message);
                socket.sendTextMessage("5")
                break;
            case "json":
                debug.debugMsg('Received Message type 4 (JSON Message): ' + data)
                try {
                    packet.data = JSON.parse(data);
                } catch (e) {
                    debug.debugMsg("SOCKET.io: received message not an object")
                    packet = pieces[4];
                }
                debug.debugMsg("Parsed message ", packet)
//                debugPane.append(packet)
                jsonMessage(packet, pieces[3] || '', pieces[2] || 0);
//                catch(e)
//                {
//                    debug.debugMsg('JSON Parse Error: ' + result[3]);
//                }
                break;

            case "event":
                debug.debugMsg('Received Message type 5 (Event): ' + message)
                try {
                  var opts = JSON.parse(data);
                  packet.name = opts.name;
                  packet.args = opts.args;
                  packet.args = packet.args || [];
                } catch (e) {
                    debug.debugMsg('JSON Parse Error: ' + message);
                    return;
                }

                if (!packet.hasOwnProperty('name'))
                {
                    debug.debugMsg('Invalid socket.IO Event');
                    return;
                }
                debug.debugMsg(JSON.stringify(opts,null,2))
//                eventMessage(packet.name, packet.args || {}, opts[3] || '', opts[2] || '');  //TODO check web data events after it returns

                    _handleEvents(packet.name, packet.args);

                break;
            case "ack":
                pieces = data.match(/^([0-9]+)(\+)?(.*)/);
                    if (pieces) {
                      packet.ackId = pieces[1];
                      packet.args = [];

                      if (pieces[3]) {
                        try {
                          packet.args = pieces[3] ? JSON.parse(pieces[3]) : [];
                        } catch (e) { }
                      }
                    }

//                    debug.bypass('SOCKETIO -> _parsePacket, case "ack"' , packet.ackId, JSON.stringify(socket.acks[packet.ackId]) )
                    if (typeof socket.acks[packet.ackId] === "function"){
                        socket.acks[packet.ackId](packet.args) //run the stored cb function from the acks array
                        delete socket.acks[packet.ackId]
                        //socket.acks.splice(packet.ackId,1)//remove the callback
                    }


                debug.debugMsg('Received Message type 6 (ACK)');
                break;
            case "error":
                debug.debugMsg('Received Message type 7 (Error): ' + message);
                pieces = data.split('+');
                packet.reason = reasons[pieces[0]] || '';
                packet.advice = advice[pieces[1]] || '';
                _sendErrorPacket(result[3] || '', result[4]);
                break;
            case "noop":
                debug.debugMsg('Received Message type 8 (Noop)');
                break;
            default:
                debug.debugMsg('Invalid Socket.IO message type: ' + pieces[1]);
                break;
        }
    }




}
