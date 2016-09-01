import QtQuick 2.5
QtObject {
    function stdTimeZoneOffset() {
        var today = new Date()

        var jan = new Date(today.getFullYear(), 0, 1);
        var jul = new Date(today.getFullYear(), 6, 1);
        return Math.max(jan.getTimezoneOffset(), jul.getTimezoneOffset());
    }
    function getDateTimeZone(date) {
        //return date.getTimezoneOffset() < stdTimezoneOffset();
//            console.log(date.getTimezoneOffset(), stdTimeZoneOffset(), stdTimeZoneOffset() - date.getTimezoneOffset() )
        return stdTimeZoneOffset() - date.getTimezoneOffset();
    }

    function formatSeconds(seconds) {
        var date = new Date(1970,0,1);
        date.setSeconds(seconds);
        return date.toTimeString().replace(/.*(\d{2}:\d{2}:\d{2}).*/, "$1");
    }



    function setTimeOut(ms, fn, args) {
        var t = timerFactory.createObject(priv);
        t.fn = fn;
        t.args = args;
        t.interval = ms;
        t.start();
    }

    property Item priv : Item {

        Component {
            id : timerFactory
            Timer {
                id : timerInstance
                property var fn
                property var args
                onTriggered: {
                    if(typeof fn === 'function') {
                        if(args) {
                            if(toString.call(args) !== '[object Array]')
                                args = [args]

                            fn.apply(this,args);
                        }
                        else {
                            fn();
                        }
                    }
                    timerInstance.destroy();
                }
            }
        }
    }



}
