import QtQuick 2.4
import Zabaat.Material 1.0
import Zabaat.Base 1.0
//uses model to lets us quickly toggle between button states.
//valid model = ["Up"       , { text : "", state : "" } , "Right" ]
//              [ <btnText> , { text : "", state : "" }           ]

Item {
    id : rootObject
    objectName : "ZToggleButton"
    property string state
    readonly property alias text : btn.text
    property var model
    onModelChanged: {
        if(!Lodash.isArray(model) || model.length === 0) {
            btn.idx = -1;
        }
        else {
            btn.idx = 0;
        }
    }

    ZButton {
        id : btn
        property int idx : -1
        anchors.fill: parent
        onClicked: {
            if(!Lodash.isArray(model))
                return;

            if(idx + 1 < model.length) {
                idx++
            }
            else {
                idx = 0;
            }
        }
        text : {
            if(idx === -1)
                return "";
            var m = model[idx];
            if(Lodash.isString(m))
                return m;
            else if(Lodash.isObject(m) && m.text) {
                return m.text
            }
            return "";
        }

        state : {
            if(idx === -1)
                return rootObject.state
            var m = model[idx];
            if(Lodash.isString(m))
                return rootObject.state;
            if(Lodash.isObject(m) && m.state)
                return m.state;

            return "";
        }
    }
}
