import QtQuick 2.5
import "promise.js" as P
pragma Singleton

QtObject {
    function promise(fn) {
        if(!P.setTimeout)
            P.setTimeout = priv.setTimeOut

        return new P.Promise(fn);
    }

    Component.onCompleted: {
        P.setTimeout = priv.setTimeOut
    }

    property Item priv : Item {
        id : priv

        function setTimeOut(fn, ms, args) {
            var t = timerFactory.createObject(priv);
            t.fn = fn;
            t.args = args;
            t.interval = ms;
            t.start();
        }

        Component {
            id : timerFactory
            Timer {
                id : timerInstance
                property var fn
                property var args
                onTriggered: {
                    if(typeof fn === 'function') {
                        if(args) {
                            fn.apply(this,args);
                        }
                        else {
//                            console.log("calling fn")
                            fn();
                        }
                    }
                    timerInstance.destroy();
                }
            }
        }

    }

}
