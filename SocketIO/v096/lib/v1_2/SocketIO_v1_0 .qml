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

//import './lib/lib/manager.js' as Manager
//import './lib/socketio.js' as SocketIo
Item
{
    id: handler

    property string uri;
    property bool connected: false;
    property bool debug: false;
    property bool socketInit: true

    property int heartbeatTimeout: 15000;  //@readonly
    property int disconnectTimeout: 25000; //@readonly
    property string sid;                   //@readonly


    property string resource: 'socket.io'
    property int connectionTimeout: 10000
    property bool reconnect: true
    property int reconnectionDelay: 500
    property int reconnectionLimit: Infinity
    property int maxReconnectionAttempts: 10


//    property var global

    property variant _uri;

    /**
     * Endpoint and id don`t used usualy. So they must be last arguments. In
     * most of cases we need only data.
     */
    signal message(string data, string endPoint, int id);
    signal jsonMessage(variant args, string endPoint, int id);
    signal eventMessage(string name, variant args, string endPoint, int id);
    signal errorMessage(string reason, string advice, string endPoint);

    signal opened();
    signal closed();
    signal failed();

    /**
     * Most of real socket.io application use events(type 5) for communicate between server and client. So it`s a
     * high level api for that.
     *
     * on('chatMessage', function(fromId, toId, text) { ... });
     *
     */
    function on(name, func)     {  return _registerEvent(Container.onHandlers  , name, func)  }
    function once(name, func)   {  return _registerEvent(Container.onceHandlers, name, func)  }

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



    function connect()
    {
        if (!connected)
            _handshake()
    }

    function disconnect()
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

    function newSend(msgType,id,type,message)
    {
        if(connected)
            socket.sendTextMessage(msgType + id + "[\"" + type + "\"" +"," + "\"" + message + "\"" + "]")
    }


    function send(type, message, endpoint, id)
    {
        if (!connected)
            return;

        socket.sendTextMessage(type + ':' + (id || '') + ':' + (endpoint || '') + ':' + message);
    }

    function sendJson(data, endPoint, id)
    {
        var message = JSON.stringify(data);
         _debug('Sended Message type 4 (JSON Message): ' + message)
        send(4, message, endPoint, id);
    }

    //Emits an event based MESSAGE //TODO : look at this
    function emit(name, args, endPoint, id)
    {
        var message = JSON.stringify({ name: name, args: args });
        _debug('Sended Message type 5 (Event): ' + message)
        send(5, message, endPoint, id);
    }

    function _debug(message)
    {
        if (debug)
        {
            console.debug(message)
            debugPane.append(message)
        }
    }

    function _handshake()
    {
        var uri         = new Request.Uri(handler.uri)
        var protocol  = uri.protocol()

        uri.setProtocol(protocol === 'wss' ? 'https' : 'http')
        uri.setPath('/socket.io/1/');

        Request.http.request(uri, function(response)
        {
            console.log("RESPONSE = ", JSON.stringify(response,null,1))

            var result = JSON.parse(response.body.data)
            var sid = result.sid;
            console.log("SID = ", sid)

            if (response.status !== 200)
            {
                console.log('Socket.IO Handshake: Server rejected connection with code ' +  response.status)
                handler.failed()
                return
            }

//            result = expr.exec(response.body);
            if (result === null)
            {
                console.log('Socket.IO Handshake: Server response not match protocol ' +  response.body)
                handler.failed()
                return
            }

//            sid = result[1];
//            handler.heartbeatTimeout = parseInt(result[2], 10);
//            handler.disconnectTimeout = parseInt(result[3], 10);
            handler.heartbeatTimeout = result.pingInterval
            handler.disconnectTimeout = result.pingTimeout

            uri.setPath('/socket.io/1/websocket/' + sid);
            uri.setProtocol(protocol);

            _debug('Socket.IO Handshake: Connecting to '  + uri)
            console.log("CHECK ME OUT!",uri.toString(), socket.active)
            socket.url = uri.toString()+"?EIO=3&transport=websocket&t="+socket._generateTimestamp(true)+"&sid="+sid+"&b64=true"
        });
    }

    function _sendHeartbeat()
    {
        console.log("SENDING HEARTBEAT PING!")
        socket.sendTextMessage('2::');
    }

    /**
     * Parse response according to socket.IO rules.
     * https://github.com/LearnBoost/socket.io-spec
     */
    function _parseMessage(message)
    {
        console.log("PARSE MESSAGE CALLED!",message,typeof message)

        //WOLF : message format (of type 4)
        //<1 digit num> <0-N digit Num> <[> <"message type"> <","> <"message"> <]>
        var wolfExpr = /([0-8])([0-9]*)\[\"([^:]*)\"\,\"([^:]*)\"\]/
        var result = message
        var parsedObject

        //WOLF : the first character in a message is its type!, this is all we are doing here.
        //           the reason to get a number is so we can use a switch later (instead of .charAt(0))
        var type  = Number(message[0]);

        if (message.length === 0)
        {
            console.log('Socket.IO wrong packet data (MSG Empty) ' +  message);
            return;
        }


        if (type === NaN)
        {
            console.log('Socket.IO wrong packet type (NaN type)' + message[1]);
            return;
        }

        switch(type)    //handle message types here!!
        {
            case 0:
                _debug('Received message type 0 (Disconnect)');
                socket.disconnect();
                break;
            case 1: //Connection Acknowledgement
                _debug('Received Message type 1 (Connect)');
                break;
            case 2:
                _debug('Received Message type 2 (Heartbeat)');
                _sendHeartbeat();
                break;
            case 3:
                _debug('Received Message type 3 (Message): ' + message);
                console.log('Received Message type 3 (Message): ' + message);
                socket.sendTextMessage("5")
                break;
            case 4:
                _debug('Received Message type 4 (JSON Message): ' + message)
                try
                {
                    var newResult = wolfExpr.exec(message)
                    if (newResult != null)
                    {
                        try
                        {
                            parsedObject = JSON.parse(newResult[4]);
                        }catch(e)
                        {
                            console.log("SOCKET.io: received message not an object")
                            parsedObject = newResult[4];
                        }
                        console.log("Parsed message ",parsedObject)
                        debugPane.append(parsedObject)
                        jsonMessage(parsedObject, newResult[3] || '', newResult[2] || 0);
                    }

                }
                catch(e)
                {
                    console.log('JSON Parse Error: ' + result[3]);
                }
                break;
            case 5:
                _debug('Received Message type 5 (Event): ' + message)
                try
                {
                    parsedObject = JSON.parse(result[4]);
                }
                catch(e)
                {
                    console.log('JSON Parse Error: ' + result[4]);
                    return;
                }

                if (!parsedObject.hasOwnProperty('name'))
                {
                    console.log('Invalid socket.IO Event');
                    return;
                }

                eventMessage(parsedObject.name, parsedObject.args || {}, result[3] || '', result[2] || '');
                _handleEvents(parsedObject.name, parsedObject.args);

                break;
            case 6:
                _debug('Received Message type 6 (ACK)');
                break;
            case 7:
                _debug('Received Message type 7 (Error): ' + message);
                _sendErrorPacket(result[3] || '', result[4]);
                break;
            case 8:
                _debug('Received Message type 8 (Noop)');
                break;
            default:
                _debug('Invalid Socket.IO message type: ' + result[1]);
                break;
        }
    }

    function _handleEvents(name, args)
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
             _debug('Handler execution error: ' + e.message);
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

    WebSocket {
        id: socket
        url: "FAKEURL"
        /**
         * A counter used to prevent collisions in the timestamps used
         * for cache busting.
         */
        property int timestamps : 0
        property var functions :
            ({
                generateTimestamp : function(appendCounter) { return _generateTimestamp(appendCounter) }
             })

        onTextMessageReceived:
        {
            console.log("SOCKET ROOT: Message RCV" ,message);
            handler._parseMessage(message);

        }
//        onFailed: handler.failed();
        onStatusChanged: {
            console.log("WEBSOCKETROOT: status changed ",status)
            if (status == WebSocket.Error) {
                debugPane.append('#', 'socket error ' + socket.errorString)
                console.log("WEBSOCKET ROOT: error! ",socket.errorString)
            }else if (status == WebSocket.Connecting)
            {
                debugPane.append('#', 'connecting to',url.toString())
                console.log("WEBSOCKET ROOT: connecting to",url.toString())
//                socket.sendTextMessage(JSON.stringify({EIO:"3",transport:"polling",t:"1415921888445-17",b64:"true",sid:sid}))
            }
            else if (socketInit && status == WebSocket.Open) {
//                debugPane.append('#', 'socket open');
                    handler.connected = true;
                    handler.opened();
                    console.log("WEBSOCKET ROOT: I'm open")
//                    socket.sendTextMessage(JSON.stringify({EIO:"3",transport:"polling",t:"1415921888445-17",b64:"true",sid:sid}))
                    sendTextMessage("2probe")
                    socketInit = false; //no longer in init Mode
            } else if (status == WebSocket.Closed) {
//                debugPane.append('#', 'socket closed')
                console.log("WEBSOCKETROOT: close")
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
}
