import QtTest 1.0
import QtQuick 2.5
import "Lodash"

//basically auto hooks up all the signals of testObj for us in a neat manner!
TestCase {
    id : rootObject
    property var testObj
    when : priv.okToRunTests
    onTestObjChanged: priv.doSetup();

    readonly property alias signalList : sl.signals
    readonly property alias signals    : priv.signalMap
    function clearSignals() {
        if(!priv.signalMap)
            return;

        for(var s in priv.signalMap){
            priv.signalMap[s] = []
        }
    }

    function initTestCase(){
        if(rootObject.objectName)
            console.log("@@ ----- TESTING" , rootObject.objectName, " ------ @@")
    }

    function init() {
        clearSignals()
    }

    function compareObjects(obj1,obj2, msg){
        msg = msg || "Objects don't match";
        verify(priv.softObjectMatch(obj1,obj2), msg)
    }

    function compareArrays(arr1,arr2,msg){
        msg = msg || "Arrays don't match";
        verify(priv.arrEq(arr1,arr2), msg);
    }

    function arrayContains(arr,val,instances){
        var contains = priv.arrayContains(arr,val,instances);
        verify(contains,"Array does not contain " + val);
    }




    QtObject {
        id : priv
        property bool okToRunTests : false;
        property var  signalMap : ({})

        function doSetup(){
            if(!testObj)
                okToRunTests = false;

            else {
                sl.target = testObj;
            }
        }

        function arrayIndexOf(arr,str,startIndex){
            startIndex = startIndex || 0
            for(var a = startIndex; a < arr.length; a++){
                var e = arr[a]
//                console.log("(",e, ")INDEX OF(", str, ")=" , e.indexOf(str))
                if(e.indexOf(str) !== -1)
                    return a;
            }
            return -1;
        }

        function arrEq(a,b, badRetFn){
            badRetFn = typeof badRetFn === 'function' ? badRetFn : function(a,b) { return false ; }

            if(!Lodash.isArray(a) || !Lodash.isArray(b))
                return badRetFn(a,b);

            if(a.length !== b.length){
                return badRetFn(a,b);
            }

            for(var i = 0; i < a.length; ++i){
                var v  = a[i]
                var v2 = b[i]

                if(Lodash.isObject(v) && Lodash.isObject(v2)) {
                    if(!softObjectMatch(v,v2)){
                        return badRetFn(a,b);
                    }
                }
                else if(Lodash.isArray(v) && Lodash.isArray(v2)){
                    if(!arrEq(v,v2)) {
                        return badRetFn(a,b);
                    }
                }
                else if(v != v2) {
                    return badRetFn(a,b);
                }
            }
            return true;
        }

        function arrayContains(arr, str, instances,print){
            var exact = true;
            if(!instances || typeof instances !== 'number') {
                instances = 1;
                exact = false;
            }

            instances = Math.max(instances,1);
            var s     = 0;
            var count = 0;
            while(exact || count < instances) {
                var idx = arrayIndexOf(arr,str,s)
                if(idx !== -1) {
                    s = idx+1;
                    count++;
                }
                else {
                    break;
                }
            }

            if(print)
                console.log("--->" , count + "/" + instances)


            return exact ? count === instances :
                           count >=  instances;

        }

        function softObjectMatch(obj1,obj2, badRetFn){
            badRetFn = typeof badRetFn === 'function' ? badRetFn : function(a,b) { return false ; }

            if(Qt.isQtObject(obj1) || Qt.isQtObject(obj2)){
                if(obj1 === obj2)
                    return true;
                return badRetFn(obj1,obj2);
            }


            if(!Lodash.isObject(obj1) && !Lodash.isObject(obj2))
                return badRetFn(obj1,obj2);

            if(!arrEq(Lodash.keys(obj1).sort() , Lodash.keys(obj2).sort())) {
                return badRetFn(obj1,obj2);
            }

            for(var k in obj1){
                var v  = obj1[k]
                var v2 = obj2[k]
                if(Lodash.isObject(v) && Lodash.isObject(v2)) {
                    if(!softObjectMatch(v,v2))
                        return badRetFn(obj1,obj2);
                }
                else if(Lodash.isArray(v) && Lodash.isArray(v2)) {
                    if(!arrEq(v,v2))
                        return badRetFn(obj1,obj2);
                }
                else if(v != v2){
                    return badRetFn(obj1,obj2);
                }
            }
            return true;
        }


        property SignalList sl : SignalList {
            id : sl
            onFinished : {
                if(signals) {

                    //first let's create all the signals !
                    Lodash.each(sl.signals, function(sigName){
                        if(!priv.signalMap)
                            priv.signalMap = {}
                        if(!priv.signalMap[sigName])
                            priv.signalMap[sigName] = []
                    })

                    //now let's connect them all
                    Lodash.each(sl.signals, function(sigName){
                        var f = function() {
                            var args = Array.prototype.slice.call(arguments);
                            priv.signalMap[sigName].push(args);
                        }
                        try {
                            testObj[sigName].connect(f);
                        }
                        catch(e) {
                            console.error("Cannot connect to", sigName, "because it is not a signal!")
                        }
                    })



                }
                priv.okToRunTests = true;
            }
        }

    }


}
