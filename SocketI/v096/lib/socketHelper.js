/*to call this do the following in your "parent" file like the example below:
    Qt.include('./after.js');
    var derpVar = new Derp;
    derpVar.derpOut("i like waffles");   // prints:     DERP OUT TO CONSOLE! i like waffles
*/
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


var global = {} //global object used by some functions to replace what the browser / browserfied version of this used to pass garbage between functions


var Derp = (function (){
    //test function for making sure you are using this correctly
    var derpObj = {}  // create empty object to attach all the functions to

    debugMsg("DERP FUNCTION!")
    function superDerp() // optionally create private functions and vars
    {
        debugMsg("I AM SUPER DERP MAN");
    }

    derpObj.derpOut = function (derpyText) //attaching this function to the derpObj makes it so that you can use this function externally
    {
        superDerp();
        debugMsg(" DERP OUT TO CONSOLE! " + derpyText)
    }
    return derpObj // and now return the top object so that you have all the tasty goodness that was inside
})();

/**
 * The JWR (JSON WebSocket Response) received from a Sails server.
 *
 * @api private
 * @param  {Object}  responseCtx
 *         => :body
 *         => :statusCode
 *         => :headers
 * @constructor
 */
var JWR=function(responseCtx) {
    // json WEB response. this function is only for the socketio.QML file at this time for it's sails.js wrapper functions.
    jwrObj = {}
    this.body = responseCtx.body || {};
    this.headers = responseCtx.headers || {};
    this.statusCode = responseCtx.statusCode || 200;

    jwrObj.toString= function () {
        return '[ResponseFromSails]' + '  -- ' +
        'Status: ' + this.statusCode + '  -- ' +
        'Headers: ' + this.headers + '  -- ' +
        'Body: ' + this.body;
    };
    jwrObj.toPOJO=function() {
        return {
            body: this.body,
            headers: this.headers,
            statusCode: this.statusCode
        };
    };
    jwrObj.pipe=function () {
        // TODO: look at substack's stuff
        return new Error('Not implemented yet.');
    };

    return jwrObj
}


var Utf8 = (function (globalObject) {
    debugMsg("UTF8 function start global =",globalObject)
    // Detect free variables `exports`
    var freeExports = typeof exports == 'object' && exports;

    // Detect free variable `module`
    var freeModule = typeof module == 'object' && module &&
        module.exports == freeExports && module;

    // Detect free variable `global`, from Node.js or Browserified code,
    // and use it as `globalObject`
    var freeGlobal = typeof global == 'object' && global;
    if (freeGlobal.global === freeGlobal || freeGlobal.window === freeGlobal) {
        globalObject = freeGlobal;
    }

    /*--------------------------------------------------------------------------*/

    var stringFromCharCode = String.fromCharCode;

    // Taken from http://mths.be/punycode
    function ucs2decode(string) {
        var output = [];
        var counter = 0;
        var length = string.length;
        var value;
        var extra;
        while (counter < length) {
            value = string.charCodeAt(counter++);
            if (value >= 0xD800 && value <= 0xDBFF && counter < length) {
                // high surrogate, and there is a next character
                extra = string.charCodeAt(counter++);
                if ((extra & 0xFC00) == 0xDC00) { // low surrogate
                    output.push(((value & 0x3FF) << 10) + (extra & 0x3FF) + 0x10000);
                } else {
                    // unmatched surrogate; only append this code unit, in case the next
                    // code unit is the high surrogate of a surrogate pair
                    output.push(value);
                    counter--;
                }
            } else {
                output.push(value);
            }
        }
        return output;
    }

    // Taken from http://mths.be/punycode
    function ucs2encode(array) {
        var length = array.length;
        var index = -1;
        var value;
        var output = '';
        while (++index < length) {
            value = array[index];
            if (value > 0xFFFF) {
                value -= 0x10000;
                output += stringFromCharCode(value >>> 10 & 0x3FF | 0xD800);
                value = 0xDC00 | value & 0x3FF;
            }
            output += stringFromCharCode(value);
        }
        return output;
    }

    /*--------------------------------------------------------------------------*/

    function createByte(codePoint, shift) {
        return stringFromCharCode(((codePoint >> shift) & 0x3F) | 0x80);
    }

    function encodeCodePoint(codePoint) {
        if ((codePoint & 0xFFFFFF80) == 0) { // 1-byte sequence
            return stringFromCharCode(codePoint);
        }
        var symbol = '';
        if ((codePoint & 0xFFFFF800) == 0) { // 2-byte sequence
            symbol = stringFromCharCode(((codePoint >> 6) & 0x1F) | 0xC0);
        } else if ((codePoint & 0xFFFF0000) == 0) { // 3-byte sequence
            symbol = stringFromCharCode(((codePoint >> 12) & 0x0F) | 0xE0);
            symbol += createByte(codePoint, 6);
        } else if ((codePoint & 0xFFE00000) == 0) { // 4-byte sequence
            symbol = stringFromCharCode(((codePoint >> 18) & 0x07) | 0xF0);
            symbol += createByte(codePoint, 12);
            symbol += createByte(codePoint, 6);
        }
        symbol += stringFromCharCode((codePoint & 0x3F) | 0x80);
        return symbol;
    }

    function utf8encode(string) {
        var codePoints = ucs2decode(string);

        // debugMsg(JSON.stringify(codePoints.map(function(x) {
        // 	return 'U+' + x.toString(16).toUpperCase();
        // })));

        var length = codePoints.length;
        var index = -1;
        var codePoint;
        var byteString = '';
        while (++index < length) {
            codePoint = codePoints[index];
            byteString += encodeCodePoint(codePoint);
        }
        return byteString;
    }

    /*--------------------------------------------------------------------------*/

    function readContinuationByte() {
        if (byteIndex >= byteCount) {
            debugMsg("UTF8 function: " +'Invalid byte index');
        }

        var continuationByte = byteArray[byteIndex] & 0xFF;
        byteIndex++;

        if ((continuationByte & 0xC0) == 0x80) {
            return continuationByte & 0x3F;
        }

        // If we end up here, it’s not a continuation byte
        debugMsg("UTF8 function: " +'Invalid continuation byte');
    }

    function decodeSymbol() {
        var byte1;
        var byte2;
        var byte3;
        var byte4;
        var codePoint;

        if (byteIndex > byteCount) {
            debugMsg("UTF8 function: " +'Invalid byte index');
        }

        if (byteIndex == byteCount) {
            return false;
        }

        // Read first byte
        byte1 = byteArray[byteIndex] & 0xFF;
        byteIndex++;

        // 1-byte sequence (no continuation bytes)
        if ((byte1 & 0x80) == 0) {
            return byte1;
        }

        // 2-byte sequence
        if ((byte1 & 0xE0) == 0xC0) {
            var byte2 = readContinuationByte();
            codePoint = ((byte1 & 0x1F) << 6) | byte2;
            if (codePoint >= 0x80) {
                return codePoint;
            } else {
                debugMsg("UTF8 function: " +'Invalid continuation byte');
            }
        }

        // 3-byte sequence (may include unpaired surrogates)
        if ((byte1 & 0xF0) == 0xE0) {
            byte2 = readContinuationByte();
            byte3 = readContinuationByte();
            codePoint = ((byte1 & 0x0F) << 12) | (byte2 << 6) | byte3;
            if (codePoint >= 0x0800) {
                return codePoint;
            } else {
                debugMsg("UTF8 function: " +'Invalid continuation byte');
            }
        }

        // 4-byte sequence
        if ((byte1 & 0xF8) == 0xF0) {
            byte2 = readContinuationByte();
            byte3 = readContinuationByte();
            byte4 = readContinuationByte();
            codePoint = ((byte1 & 0x0F) << 0x12) | (byte2 << 0x0C) |
            (byte3 << 0x06) | byte4;
            if (codePoint >= 0x010000 && codePoint <= 0x10FFFF) {
                return codePoint;
            }
        }

        debugMsg("UTF8 function: " +'Invalid UTF-8 detected');
    }

    var byteArray;
    var byteCount;
    var byteIndex;
    function utf8decode(byteString)
    {
        byteArray = ucs2decode(byteString);
        byteCount = byteArray.length;
        byteIndex = 0;
        var codePoints = [];
        var tmp;
        while ((tmp = decodeSymbol()) !== false) {
            codePoints.push(tmp);
        }
        return ucs2encode(codePoints);
    }

    /*--------------------------------------------------------------------------*/

    var utf8 = {
        'version' : '2.0.0',
        'encode' : utf8encode,
        'decode' : utf8decode
    };

    // Some AMD build optimizers, like r.js, check for specific condition patterns
    // like the following:
    if (
        typeof define == 'function' &&
        typeof define.amd == 'object' &&
        define.amd) {
        define(function () {
            return utf8;
        });
    } else if (freeExports && !freeExports.nodeType) {
        if (freeModule) { // in Node.js or RingoJS v0.8.0+
            freeModule.exports = utf8;
        } /*else { // in Narwhal or RingoJS v0.7.0-
            var object = {};
            var hasOwnProperty = object.hasOwnProperty;
            for (var key in utf8) {
                hasOwnProperty.call(utf8, key) && (freeExports[key] = utf8[key]);
            }
        }*/
    } else


        globalObject.utf8 = utf8;  // in Rhino or a web browser
    debugMsg("end utf8")

}(global));




var ParserCoder = (function () {
        //used heavily for requset.js note that this doesn't support all the features that socket io 1.2 needs for binary data and blobs.
    var ParserCoder = {}


//        var utf8 = new Utf8
    /**
     * Create a blob api even for blob builder when vendor prefixes exist
     */

//    var Blob = new Blob

        /**
         * Check if we are running an android browser. That requires us to use
         * ArrayBuffer with polling transports...
         *
         * http://ghinda.net/jpeg-blob-ajax-android/
         */

        //var isAndroid = navigator.userAgent.match(/Android/i);
        var isAndroid = false

        /**
         * Current protocol version.
         */

        var protocol = 3;

    /**
     * Packet types.
     */

    var packets = {
        open : 0 // non-ws
    ,
        close : 1 // non-ws
    ,
        ping : 2,
        pong : 3,
        message : 4,
        upgrade : 5,
        noop : 6
    };

    var packetslist = function ()
    {
        // this won't
        var array = []
        for (var c in packets)
        {
            array[packets[c]] = c
        }
        return array;
    }

    debugMsg("packetslist",packetslist)
    /**
     * Premade error packet.
     */

    var err = {
        type : 'error',
        data : 'parser error'
    };



        /**
         * Encodes a packet.
         *
         *     <packet type id> [ <data> ]
         *
         * Example:
         *
         *     5hello world
         *     3
         *     4
         *
         * Binary is encoded in an identical principle
         *
         * @api private
         */

        /**
         * Encode packet helpers for binary types
         */

    function encodeArrayBuffer(packet, supportsBinary, callback) {
        if (!supportsBinary) {
            return ParserCoder.encodeBase64Packet(packet, callback);
        }

        var data = packet.data;
        var contentArray = new Uint8Array(data);
        var resultBuffer = new Uint8Array(1 + data.byteLength);

        resultBuffer[0] = packets[packet.type];
        for (var i = 0; i < contentArray.length; i++) {
            resultBuffer[i + 1] = contentArray[i];
        }

        return callback(resultBuffer.buffer);
    }

    function encodeBlobAsArrayBuffer(packet, supportsBinary, callback) {
        if (!supportsBinary) {
            return ParserCoder.encodeBase64Packet(packet, callback);
        }

        var fr = new FileReader();
        fr.onload = function () {
            packet.data = fr.result;
            ParserCoder.encodePacket(packet, supportsBinary, true, callback);
        };
        return fr.readAsArrayBuffer(packet.data);
    }

    function encodeBlob(packet, supportsBinary, callback) {
        if (!supportsBinary) {
            return ParserCoder.encodeBase64Packet(packet, callback);
        }

        //    if (isAndroid) {
        //        return encodeBlobAsArrayBuffer(packet, supportsBinary, callback);
        //    }

        var length = new Uint8Array(1);
        length[0] = packets[packet.type];
        var blob = new Blob([length.buffer, packet.data]);

        return callback(blob);
    }

    ParserCoder.encodePacket = function (packet, supportsBinary, utf8encode, callback) {
        if ('function' == typeof supportsBinary) {
            callback = supportsBinary;
            supportsBinary = false;
        }

        if ('function' == typeof utf8encode) {
            callback = utf8encode;
            utf8encode = null;
        }

        var data = (packet.data === undefined)
         ? undefined
         : packet.data.buffer || packet.data;

        if (global.ArrayBuffer && data instanceof ArrayBuffer) {
            return encodeArrayBuffer(packet, supportsBinary, callback);
        } else if (Blob && data instanceof global.Blob) {
            return encodeBlob(packet, supportsBinary, callback);
        }

        // Sending data as a utf-8 string
        var encoded = packets[packet.type];

        // data fragment is optional
        if (undefined !== packet.data) {
            encoded += utf8encode ? utf8.encode(String(packet.data)) : String(packet.data);
        }

        return callback('' + encoded);

    };

    /**
     * Encodes a packet with binary data in a base64 string
     *
     * @param {Object} packet, has `type` and `data`
     * @return {String} base64 encoded message
     */

    ParserCoder.encodeBase64Packet = function (packet, callback) {
        var message = 'b' + ParserCoder.packets[packet.type];
        if (Blob && packet.data instanceof Blob) {
            var fr = new FileReader();
            fr.onload = function () {
                var b64 = fr.result.split(',')[1];
                callback(message + b64);
            };
            return fr.readAsDataURL(packet.data);
        }

        var b64data;
        try {
            b64data = String.fromCharCode.apply(null, new Uint8Array(packet.data));
        } catch (e) {
            // iPhone Safari doesn't let you apply with typed arrays
            var typed = new Uint8Array(packet.data);
            var basic = new Array(typed.length);
            for (var i = 0; i < typed.length; i++) {
                basic[i] = typed[i];
            }
            b64data = String.fromCharCode.apply(null, basic);
        }
        message += global.btoa(b64data);
        return callback(message);
    };

    /**
     * Decodes a packet. Changes format to Blob if requested.
     *
     * @return {Object} with `type` and `data` (if any)
     * @api private
     */

    ParserCoder.decodePacket = function (data, binaryType, utf8decode)
    {
        // String data
        if (typeof data == 'string' || data === undefined)
        {
            if (data.charAt(0) == 'b')
                return ParserCoder.decodeBase64Packet(data.substr(1), binaryType);


            if (false)//(utf8decode)
            {
                try {
//                    data = data.substr(1)
                    debugMsg("WE LOVE THE WOLFY",typeof global.utf8.decode)
                                       data  = global.utf8.decode(data)   //TODO this is where we stopped on friday! utf8 isn't putting itself in root correctly or whatever the function constructs with
                    debugMsg("decodepacket () DATA LENGTH",data.length)
                } catch (e) {
                    debugMsg("error= ")
                    console.trace()
                    console.exception()
                    return err;
                }
            }

//            var expr = /([0-9a-zA-Z_-]*):([0-9]*):([0-9]*):(.*)/,
            var regExp09  = /([0-9a-zA-Z_-]*):([0-9]*):([0-9]*):(.*)/
            var dataArray = regExp09.exec(data)
            if(dataArray != null)
            {
                debugMsg("sid",dataArray[1])
                var dataObj = {sid : dataArray[1], rest: dataArray[2] + "," + dataArray[3] + "," + dataArray[4] }
//                var dataStr = spch("sid" ) + ":" + dataObj.sid + "," +
//                              "rest" + ":" + dataObj.rest
                var dataStr = JSON.stringify(dataObj)

                var type = dataObj.rest.charAt(0)
                debugMsg("decodePacket() type",type,dataStr)

                var packetslist = []
                for (var c in packets)
                    packetslist[packets[c]] = c

                if (Number(type) != type || !packetslist[type])
                {
                    debugMsg("decodePacket() : packet type",type,"does not match specified types")
                    return err
                }

                if (dataStr.length > 1)
                {
                    debugMsg("decodePacket() - dataStr.length > 1")
                    return {
                        type : packetslist[type],
                        data : dataStr
                    };
                }
                else {
                    debugMsg("decodePacket() - dataStr.length == 0")
                    return {
                        type : packetslist[type]
                    };
                }
            }
            else
            {
                debugMsg("decodePacket() - data does not match RegExp09")
                return err
            }
        }
        else
        {
            //This never HAPPENs so if it EVER DOES this might be bad bro
            debugMsg("decodePacket() - DATA AINT A STRING!!! BROO HANDLE THIS HERE. LINE NUM 542-ish IN DERP.JS")
            var asArray = new Uint8Array(data);
            var type = asArray[0];
            var rest = ArrayBufferSlice.slice(data, 1);
            if (Blob && binaryType === 'blob')
                rest = new Blob([rest]);

            return {
                    type : packetslist[type],
                    data : rest
                    };
        }
    };

    /**
     * Decodes a packet encoded in a base64 string
     *
     * @param {String} base64 encoded message
     * @return {Object} with `type` and `data` (if any)
     */

    ParserCoder.decodeBase64Packet = function (msg, binaryType) {
        var type = packetslist[msg.charAt(0)];
        if (!global.ArrayBuffer) {
            return {
                type : type,
                data : {
                    base64 : true,
                    data : msg.substr(1)
                }
            };
        }

        var data = base64encoder.decode(msg.substr(1));

        if (binaryType === 'blob' && Blob) {
            data = new Blob([data]);
        }

        return {
            type : type,
            data : data
        };
    };

    /**
     * Encodes multiple messages (payload).
     *
     *     <length>:data
     *
     * Example:
     *
     *     11:hello world2:hi
     *
     * If any contents are binary, they will be encoded as base64 strings. Base64
     * encoded strings are marked with a b before the length specifier
     *
     * @param {Array} packets
     * @api private
     */

    ParserCoder.encodePayload = function (packets, supportsBinary, callback) {
        if (typeof supportsBinary == 'function') {
            callback = supportsBinary;
            supportsBinary = null;
        }

        if (supportsBinary) {
            if (Blob && !isAndroid) {
                return ParserCoder.encodePayloadAsBlob(packets, callback);
            }

            return ParserCoder.encodePayloadAsArrayBuffer(packets, callback);
        }

        if (!packets.length) {
            return callback('0:');
        }

        function setLengthHeader(message) {
            return message.length + ':' + message;
        }

        function encodeOne(packet, doneCallback) {
            ParserCoder.encodePacket(packet, supportsBinary, true, function (message) {
                doneCallback(null, setLengthHeader(message));
            });
        }

        map(packets, encodeOne, function (err, results) {
            return callback(results.join(''));
        });
    };

    /**
     * Async array map using after
     */

    function map(ary, each, done) {
        var result = new Array(ary.length);
        var next = after(ary.length, done);

        var eachWithIndex = function (i, el, cb) {
            each(el, function (error, msg) {
                result[i] = msg;
                cb(error, result);
            });
        };

        for (var i = 0; i < ary.length; i++) {
            eachWithIndex(i, ary[i], next);
        }
    }

    /*
     * Decodes data when a payload is maybe expected. Possible binary contents are
     * decoded from their base64 representation
     *
     * @param {String} data, callback method
     * @api public
     */

    ParserCoder.decodePayload = function (data, binaryType, callback)
    {
        if (typeof data !== 'string')
            return ParserCoder.decodePayloadAsBinary(data, binaryType, callback);

        if (typeof binaryType === 'function')
        {
            callback = binaryType;
            binaryType = null;
        }

        var packet;
        if (data == "")     // parser error - ignoring payload
        {
            debugMsg("empty packet data")
            return callback(err, 0, 1);
        }

        debugMsg("decodePayload() - data is a string")
        var length = 0,
        n,
        msg;

//        var i
//        do
//        {
//            debugMsg("looping over message")
//            i = data.indexOf(":",n+1)
//            if(i != -1)
//            {
//                n   = data.indexOf(":",i+1)
//                msg = data.substr(i+1,n-(i+1))
//                debugMsg("msg i N",i,n)
//                packet = ParserCoder.decodePacket(msg, binaryType, true);

//                if (err.type == packet.type && err.data == packet.data)
//                {
//                    debugMsg("ERROR decodePacket(), errorType -",err.type)
//                    // parser error in individual packet - ignoring payload
//                    return callback(err, 0, 1);
//                }

//                var ret = callback(packet, i + n, msg.length);
//                if (false === ret)
//                    return;

//                // "123:000:" (4,3)
//            }
//            else
//                break
//        }while(i != -1)

        debugMsg("decodePayload() - Data",data)
//        var i = data.indexOf(":")
//        msg = data.substr(i+1)
        packet = ParserCoder.decodePacket(data,binaryType,true);
        if (err.type == packet.type && err.data == packet.data)
        {
            debugMsg("ERROR decodePacket(), errorType -",err.type)
            // parser error in individual packet - ignoring payload
            return callback(err, 0, 1);
        }
        //           callback(packet, i + n, l);
        var ret = callback(packet, data.length, data.length);
        if (false === ret)
            return;
    };

    /**
     * Encodes multiple messages (payload) as binary.
     *
     * <1 = binary, 0 = string><number from 0-9><number from 0-9>[...]<number
     * 255><data>
     *
     * Example:
     * 1 3 255 1 2 3, if the binary contents are interpreted as 8 bit integers
     *
     * @param {Array} packets
     * @return {ArrayBuffer} encoded payload
     * @api private
     */

    ParserCoder.encodePayloadAsArrayBuffer = function (packets, callback) {
        if (!packets.length) {
            return callback(new ArrayBuffer(0));
        }

        function encodeOne(packet, doneCallback) {
            ParserCoder.encodePacket(packet, true, true, function (data) {
                return doneCallback(null, data);
            });
        }

        map(packets, encodeOne, function (err, encodedPackets) {
            var totalLength = encodedPackets.reduce(function (acc, p) {
                    var len;
                    if (typeof p === 'string') {
                        len = p.length;
                    } else {
                        len = p.byteLength;
                    }
                    return acc + len.toString().length + len + 2; // string/binary identifier + separator = 2
                }, 0);

            var resultArray = new Uint8Array(totalLength);

            var bufferIndex = 0;
            encodedPackets.forEach(function (p) {
                var isString = typeof p === 'string';
                var ab = p;
                if (isString) {
                    var view = new Uint8Array(p.length);
                    for (var i = 0; i < p.length; i++) {
                        view[i] = p.charCodeAt(i);
                    }
                    ab = view.buffer;
                }

                if (isString) { // not true binary
                    resultArray[bufferIndex++] = 0;
                } else { // true binary
                    resultArray[bufferIndex++] = 1;
                }

                var lenStr = ab.byteLength.toString();
                for (var i = 0; i < lenStr.length; i++) {
                    resultArray[bufferIndex++] = parseInt(lenStr[i]);
                }
                resultArray[bufferIndex++] = 255;

                var view = new Uint8Array(ab);
                for (var i = 0; i < view.length; i++) {
                    resultArray[bufferIndex++] = view[i];
                }
            });

            return callback(resultArray.buffer);
        });
    };

    /**
     * Encode as Blob
     */

    ParserCoder.encodePayloadAsBlob = function (packets, callback) {
        function encodeOne(packet, doneCallback) {
            ParserCoder.encodePacket(packet, true, true, function (encoded) {
                var binaryIdentifier = new Uint8Array(1);
                binaryIdentifier[0] = 1;
                if (typeof encoded === 'string') {
                    var view = new Uint8Array(encoded.length);
                    for (var i = 0; i < encoded.length; i++) {
                        view[i] = encoded.charCodeAt(i);
                    }
                    encoded = view.buffer;
                    binaryIdentifier[0] = 0;
                }

                var len = (encoded instanceof ArrayBuffer)
                 ? encoded.byteLength
                 : encoded.size;

                var lenStr = len.toString();
                var lengthAry = new Uint8Array(lenStr.length + 1);
                for (var i = 0; i < lenStr.length; i++) {
                    lengthAry[i] = parseInt(lenStr[i]);
                }
                lengthAry[lenStr.length] = 255;

                if (Blob) {
                    var blob = new Blob([binaryIdentifier.buffer, lengthAry.buffer, encoded]);
                    doneCallback(null, blob);
                }
            });
        }

        map(packets, encodeOne, function (err, results) {
            return callback(new Blob(results));
        });
    };

    /*
     * Decodes data when a payload is maybe expected. Strings are decoded by
     * interpreting each byte as a key code for entries marked to start with 0. See
     * description of encodePayloadAsBinary
     *
     * @param {ArrayBuffer} data, callback method
     * @api public
     */

    ParserCoder.decodePayloadAsBinary = function (data, binaryType, callback) {
        if (typeof binaryType === 'function') {
            callback = binaryType;
            binaryType = null;
        }

        var bufferTail = data;
        var buffers = [];

        var numberTooLong = false;
        while (bufferTail.byteLength > 0) {
            var tailArray = new Uint8Array(bufferTail);
            var isString = tailArray[0] === 0;
            var msgLength = '';

            for (var i = 1; ; i++) {
                if (tailArray[i] == 255)
                    break;

                if (msgLength.length > 310) {
                    numberTooLong = true;
                    break;
                }

                msgLength += tailArray[i];
            }

            if (numberTooLong)
                return callback(err, 0, 1);

            bufferTail = new ArrayBufferSlice(bufferTail, 2 + msgLength.length);
            msgLength = parseInt(msgLength);

            var msg = new ArrayBufferSlice(bufferTail, 0, msgLength);
            if (isString) {
                try {
                    msg = String.fromCharCode.apply(null, new Uint8Array(msg));
                } catch (e) {
                    // iPhone Safari doesn't let you apply to typed arrays
                    var typed = new Uint8Array(msg);
                    msg = '';
                    for (var i = 0; i < typed.length; i++) {
                        msg += String.fromCharCode(typed[i]);
                    }
                }
            }

            buffers.push(msg);
            bufferTail = new ArrayBufferSlice(bufferTail, msgLength);
        }

        var total = buffers.length;
        buffers.forEach(function (buffer, i) {
            callback(ParserCoder.decodePacket(buffer, binaryType, true), i, total);
        });
    }

    debugMsg("parser coder complete");

    return ParserCoder;
}());

var Base64ArrayBuffer = (function (chars) {
    "use strict";

    Base64ArrayBuffer.encode = function (arraybuffer) {
        var bytes = new Uint8Array(arraybuffer),
        i,
        len = bytes.length,
        base64 = "";

        for (i = 0; i < len; i += 3) {
            base64 += chars[bytes[i] >> 2];
            base64 += chars[((bytes[i] & 3) << 4) | (bytes[i + 1] >> 4)];
            base64 += chars[((bytes[i + 1] & 15) << 2) | (bytes[i + 2] >> 6)];
            base64 += chars[bytes[i + 2] & 63];
        }

        if ((len % 3) === 2) {
            base64 = base64.substring(0, base64.length - 1) + "=";
        } else if (len % 3 === 1) {
            base64 = base64.substring(0, base64.length - 2) + "==";
        }

        return base64;
    };

    Base64ArrayBuffer.decode = function (base64) {
        var bufferLength = base64.length * 0.75,
        len = base64.length,
        i,
        p = 0,
        encoded1,
        encoded2,
        encoded3,
        encoded4;

        if (base64[base64.length - 1] === "=") {
            bufferLength--;
            if (base64[base64.length - 2] === "=") {
                bufferLength--;
            }
        }

        var arraybuffer = new ArrayBuffer(bufferLength),
        bytes = new Uint8Array(arraybuffer);

        for (i = 0; i < len; i += 4) {
            encoded1 = chars.indexOf(base64[i]);
            encoded2 = chars.indexOf(base64[i + 1]);
            encoded3 = chars.indexOf(base64[i + 2]);
            encoded4 = chars.indexOf(base64[i + 3]);

            bytes[p++] = (encoded1 << 2) | (encoded2 >> 4);
            bytes[p++] = ((encoded2 & 15) << 4) | (encoded3 >> 2);
            bytes[p++] = ((encoded3 & 3) << 6) | (encoded4 & 63);
        }

        return arraybuffer;
    };
}("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"));





var ArrayBufferSlice
{
    function slice (arraybuffer, start, end) {
        debugMsg("ArrayBufferSlice");
        var bytes = arraybuffer.byteLength;
        start = start || 0;
        end = end || bytes;

        if (arraybuffer.slice) {

            return arraybuffer.slice(start, end);
        }

        if (start < 0) {
            start += bytes;
        }
        if (end < 0) {
            end += bytes;
        }
        if (end > bytes) {
            end = bytes;
        }

        if (start >= bytes || start >= end || bytes === 0) {
             debugMsg("fun ArrayBuffer.Slice  ");
            return new ArrayBuffer(0);
        }

        var abv = new Uint8Array(arraybuffer);
        var result = new Uint8Array(end - start);
        for (var i = start, ii = 0; i < end; i++, ii++) {
            result[ii] = abv[i];
        }
            debugMsg("ArrayBufferSlice 2 ");
        return result.buffer;
    }
};



var After= (function (count, callback, err_cb) {
    var bail = false
        err_cb = err_cb || noop
        proxy.count = count

        return (count === 0) ? callback() : proxy

    function proxy(err, result) {
        if (proxy.count <= 0) {
            throw new Error('after called too many times')
        }
        --proxy.count

        // after first error, rest are passed to err_cb
        if (err) {
            bail = true
                callback(err)
                // future error callbacks will go to error handler
                callback = err_cb
        } else if (proxy.count === 0 && !bail) {
            callback(null, result)
        }
    }

    function noop() {}
});


