import QtQuick 2.5
import Zabaat.Material 1.0
import Zabaat.Base 1.0
//expects model or array of types
//["oh","man"]
//{text:<sometext>}
//{llabel:<somelabel>}
//{text:<sometext>,label:<someLabel> }
ListView {
    id : rootObject
    property bool labelsAreImages : true
    property string closeButtonState : "danger-circle-f2"
    property string closeButtonText  : FAR.close
    property real chipImplicitWidth  : chipHeight * 1.5
    property real chipHeight         : priv.isHorizontal ? rootObject.height * 0.9 : rootObject.height * 0.1
    property real chipMaxWidth       : priv.isHorizontal ? Number.MAX_VALUE : rootObject.width * 0.95

    signal elementRemoved();

    property QtObject priv : QtObject {
        id : priv
        property bool isArray : Lodash.isArray(model)
        property bool isHorizontal : rootObject.orientation === ListView.Horizontal
        function rem(idx) {
            if(isArray) {
                var a = model;
                a.splice(idx,1);
                model = a;
            }
            else {
                model.remove(idx);
            }
            elementRemoved();
        }
    }

    delegate : Item {
        width  : priv.isHorizontal ? chippers.width    : rootObject.width
        height : priv.isHorizontal ? rootObject.height : rootObject.chipHeight
        ZChip {
            id : chippers
            property var m  : priv.isArray ? modelData : model
            anchors.centerIn: parent
            closeButtonText: rootObject.closeButtonText
            text : {
                if(Lodash.isString(m))
                    return m;
                if(Lodash.isObject(m) && m.hasOwnProperty('text'))
                    return m.text ;
                return "";
            }
            label : {
                if(Lodash.isObject(m) && m.hasOwnProperty('label'))
                    return m.label;
                return "";
            }
            closeButtonState: rootObject.closeButtonState
            implicitWidth: rootObject.chipImplicitWidth
            maxWidth: rootObject.chipMaxWidth
            height : rootObject.chipHeight
            onClose : {
//                rootObject.remove(index);
                priv.rem(index)
            }
        }

    }



}
