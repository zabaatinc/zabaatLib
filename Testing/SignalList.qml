import QtQuick 2.5
//Lists all the signals within a QML item!
Item {
    id : rootObject
    property var target
    onTargetChanged: priv.determineSignals()
    readonly property alias signals : priv.signals

    signal finished();

    QtObject {
        id : priv
        property var signals

        function determineSignals() {
            if(!target)
                return signals = undefined ;

            var f = function(){ console.log("I REALLY SHOULDNT BE RUNNING!") }
            var workingArr = []
            for(var t in target) {
                var item = target[t]
                if(typeof item === 'function'){
                    try {
                        item.connect(f);
                        item.disconnect(f);
                        workingArr.push(t) //should have went into exception if not a signal!
                    }
                    catch(e){ }
                }
            }
            signals = workingArr;
            finished();
        }


    }
}

