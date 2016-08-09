import QtTest 1.0
import QtQuick 2.5

//basically auto hooks up all the signals of testObj for us in a neat manner!
TestCase {
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

    function init() {
        clearSignals()
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


        property SignalList sl : SignalList {
            id : sl
            onFinished : {
                if(signals) {
                    for(var s in sl.signals){
                        var sigName = sl.signals[s]
                        var f = function() {
                            if(!priv.signalMap)
                                priv.signalMap = {}
                            if(!priv.signalMap[sigName])
                                priv.signalMap[sigName] = []

                            var args = Array.prototype.slice.call(arguments);
                            priv.signalMap[sigName].push(args);
                        }
                        try {
                            testObj[sigName].connect(f);
                        }
                        catch(e) {
                            console.error("Cannot connect to", sigName, "because it is not a signal!")
                        }


                    }
                }
                priv.okToRunTests = true;
            }
        }

    }


}
