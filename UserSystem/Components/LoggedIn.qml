import QtQuick 2.5
import Zabaat.Utility 1.0
//Place holder for app specific LoginQmls!
FlexibleLoader {
    property var config
    signal action(var param);
    onLoaded: {
        if(typeof item.done === 'function')
            item.done.connect(function() {
                action({name:'done' })
            })
    }
    Timer {
        id : initTimer
        interval : 10
        running : true
        onTriggered: {
            if(config && config.onLoggedInQml) {
                src = config.onLoggedInQml;
            }
            else {
                action({name:'done'})
            }
        }
    }
}

