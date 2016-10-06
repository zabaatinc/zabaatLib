import QtQuick 2.5
import Zabaat.Utility 1.0
import Zabaat.Material 1.0
import Zabaat.Shaders 1.0 as Fx
import Zabaat.MVVM 1.0

Rectangle {
    id : rootObject
    objectName : "test.qml"
    color : 'lightyellow'
    Component.onCompleted: {
        forceActiveFocus();

        var o = [
            { id : 420,
              name : "Shahan",
              hobbies : ['a',{'b':'battling'},'c'],
              pets : [{ id : 99, name : "woof"} ,
                      { id : 100 , name : "fu"}]

            } //,
//            { id : 666, name : "Fahad" , pets : [{ id : 99, name : "woof"} ,{ id : 100 , name : "fu"}]} ,
//            { id : 786, name : "Brett" , pets : [{ id : 99, name : "woof"} ,{ id : 100 , name : "fu"}]} ,
//            { id : 999, name : "Pika"  , pets : [{ id : 99, name : "woof"} ,{ id : 100 , name : "fu"}]}
        ]

//        var ms = Functions.time.mstimer()
        RestArrayCreator.debugOptions.showPaths   = true;
        RestArrayCreator.debugOptions.showData    = true;
        RestArrayCreator.debugOptions.showOldData = true;
        var arr = RestArrayCreator.create(o);

        arr[0].name = "wolf"
        arr[0].hobbies = ["derp","herp"];


        console.log("DELETES\n", RestArrayCreator.debugOptions.batchDeleteMsg.join('\n'),'\n____')
        console.log("UPDATES\n", RestArrayCreator.debugOptions.batchUpdateMsg.join('\n'),'\n____')
//        console.log(JSON.stringify(arr[0],null,2))

    }


    Text {
        id : fpsText
        property real t
        property int frame: 0
        color: "red"
        text: "? Hz"

        Timer {
            id: fpsTimer
            property real fps: 0
            repeat: true
            interval: 1000
            running: true
            onTriggered: {
                parent.text = "FPS: " + fpsTimer.fps + " Hz"
                fps = fpsText.frame
                fpsText.frame = 0
            }
        }

        NumberAnimation on t {
            id: tAnim
            from: 0
            to: 100
            loops: Animation.Infinite
        }

        onTChanged: {
            update() // force continuous animation
            ++frame
        }
    }


    function getPath(path,key,val) {
        var k = val && val.id !== null && val.id !== undefined ? val.id : key;
        return path ? path + "/" + k : k;
    }
    function convertToCool(obj) {
        if(Lodash.isArray(obj))
            return convertToCoolArray(obj);
        else if(Lodash.isObject(obj))
            return convertToCoolObject(obj);
        return obj;
    }
    function attachProperties(i, path) {
        var map   = {hurr :'durr'}
        var _path = path || "";
        Object.defineProperty(i, "_path", {
                                enumerable : true,
                                get : function() { return _path; },
                                set : function () {}
                              });
        Object.defineProperty(i, "_map", {
                                enumerable : true,
                                get : function(key) {
                                    if(!key)
                                        return map ;
                                    return map[key];
                                } ,
                                set : function(val) {
                                    if(typeof val !== 'object')
                                        return;

                                     for(var k in val) {
                                        map[k] = val;
                                     }
                                }
                              })
    }
    function blankObject(path) {
        var obj = {};
        attachProperties(obj,path);
        return obj;
    }
    function blankArray(path) {
        var arr = [];
        attachProperties(arr,path);
        return arr;
    }
    function convertToCoolArray(arr,ret,path) {
        ret  = ret || blankArray(path);
        path = path || ""
        if(!Lodash.isArray(arr))
            return ret;

        Lodash.each(arr, function(v,k) {
            var p = getPath(path,k,v);
            if(Lodash.isArray(v)) {
                ret[k] = convertToCoolArray(v,blankArray(p),p)
            }
            else if(Lodash.isObject(v)) {
                ret[k] = convertToCoolObject(v,blankObject(p),p)
            }
            else {
                var readonly = k === 'id';
                Object.defineProperty(ret,k,descriptor(v, p, readonly));
            }
        })

        return ret;
    }
    function convertToCoolObject(obj,ret, path) {
        ret = ret || {}
        path = path || ""
        if(!Lodash.isObject(obj))
            return ret;

        Lodash.each(obj, function(v,k) {
            var p = getPath(path,k,v);
            if(Lodash.isArray(v)) {
                ret[k] = convertToCoolArray(v,blankArray(p),p)
            }
            else if(Lodash.isObject(v)) {
                ret[k] = convertToCoolObject(v,blankObject(p),p)
            }
            else {
                var readonly = k === 'id';
                Object.defineProperty(ret,k,descriptor(v, p, readonly));
            }
        })


        return ret;
    }
    function descriptor(val, name, unwritable) {
        var _value = val;
        var _name  = name;

        var r = {
            enumerable : true,
            get        : function() {
//                console.log(_name, "=", _value);
                return _value;
            }
        }
        r.set = unwritable ? function() { console.error("cannot write to readonly property", _name ) ;} :
                             function(val, noUpdate) {
                                if(val != _value) {
                                    var oldVal = _value;
                                    _value = val;
                                    if(!noUpdate) {
                                        //EMIT UPDATE MSG;
                                        console.log("updated", _name , "to", _value, "from", oldVal);
                                    }
                                }

                            }

        return r;
    }




}
