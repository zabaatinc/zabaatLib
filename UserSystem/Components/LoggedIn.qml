import QtQuick 2.5
import Zabaat.UserSystem 1.0
//Place holder for app specific LoginQmls!
FlexibleLoader {
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
            if(UserSystem.componentsConfig && UserSystem.componentsConfig.onLoggedInQml) {
                src = UserSystem.componentsConfig.onLoggedInQml;
            }
            else {
                action({name:'done'})
            }
        }
    }
}

