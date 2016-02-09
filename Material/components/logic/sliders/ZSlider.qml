import Zabaat.Material 1.0
import QtQuick 2.4
ZObject {
    id : rootObject
    objectName: "ZSlider"
    debug : false
    transformOrigin : Item.TopLeft

    property double value          : 0.0
    property double max            : 1
    property double min            : 0
    property string label          : ""
    property bool   isInt          : false
    property var    labelDispFunc  : null
    property var    valueDispFunc  : null


    onMinChanged  : privates.keepInRange(value)
    onMaxChanged  : privates.keepInRange(value)
    onIsIntChanged: if(isInt) {
                        value = Math.floor(value)
                    }

    onValueChanged: {
        log(rootObject, ".value : ", value, "_hasInit:", privates.hasInit)

        if(!privates.lock && privates.hasInit){
            privates.lock = true

            var snapShot, tVal;
            tVal = snapShot = value;

            if(isInt) {
                tVal = Math.floor(value)
                log(rootObject, ".value was floored to : ", tVal)
            }

            if(privates.hasInit)
                tVal = privates.keepInRange(tVal)

            if(snapShot !== tVal)
                value = tVal;

            privates.lock = false
        }
    }

    Component.onCompleted: {
        value = privates.keepInRange(value)
        privates.hasInit = true
    }

    QtObject {
        id : privates
        property bool hasInit: false
        property bool lock   : false

        function keepInRange(val){
            return val > max ? max : val < min ? min : val
        }

    }

}
