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

    function mstimer() {
        var r = { start : +(new Date().getTime()) }
        r.stop = function() {
            return (+new Date().getTime()) - r.start;
        }
        return r;
    }


    function setTimeOut(ms, fn, args) {
        var t = timerFactory.createObject(_members);
        t.fn = fn;
        t.args = args;
        t.interval = ms;
        t.start();
    }

    //runs this function forever @ interval. Returns the id of the timer.
    //so we can stop it later.
    function setInterval(ms, fn, args) {
        var t      = timerFactory.createObject(_members);
        t.fn       = fn;
        t.args     = args;
        t.interval = ms;
        t.repeat   = true;
        t.dontDestroy = true;
        t.start();

        var timerId = _members.infiniteTimerNum++;
        _members.infiniteTimers[timerId] = t;
        return timerId;
    }

    //stops a forever timer
    function stopTimer(timerId) {
        if(!_members.infiniteTimers || !_members.infiniteTimers[timerId])
            return false;

        var timer = _members.infiniteTimers[timerId];
        if(v && Qt.isQtObject(v) && v.hasOwnProperty && v.hasOwnProperty("dontDestroy")) {
            timer.stop();
            timer.destroy();
            delete _members.infiniteTimers[timerId];
            return true;
        }

        return false;
    }

    //returns list of forever timers
    function timerList() {
        var arr = []
        for(var k in _members.infiniteTimers) {
            var v = _members.infiniteTimers[k]
            if(v && Qt.isQtObject(v) && v.hasOwnProperty && v.hasOwnProperty("dontDestroy"))
                arr.push(k);
        }
        return arr;
    }


    property Item _members : Item {
        id : _members
        property var infiniteTimers   : ({})
        property int infiniteTimerNum : 0

        Component {
            id : timerFactory
            Timer {
                id : timerInstance
                property var fn
                property var args
                property bool dontDestroy : false
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
                    if(!dontDestroy)
                        timerInstance.destroy();
                }
            }
        }
    }



}
