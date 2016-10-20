import QtQuick 2.5
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
    Component.onCompleted:  {
        if(config && config.onLoggedInQml) {
            src = config.onLoggedInQml;
        }
        else {
            action({name:'done'})
        }
    }
}

