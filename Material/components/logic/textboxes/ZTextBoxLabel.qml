import QtQuick 2.5
import Zabaat.Material 1.0
Item {
    id : rootObject
    objectName : "ZTextBoxLabel"
    property string state : "left" // right, top, bottom
    onStateChanged: logic.update()
    Component.onCompleted: logic.update()

    signal inputChanged(string text, string oldText, bool acceptable);
    signal accepted(string text, string oldText);

    //aliases that take from both the things
    property alias state_Label   : label.state
    property alias label       : label.text

    property alias state_TextBox : input.state
    property alias description : input.label
    property alias text        : input.text
    property alias error               : input.error
    property alias changeOnlyOnAccept  : input.changeOnlyOnAccept
    property alias strictValidation    : input.strictValidation
    property var validationFunc
    property alias setAcceptedTextFunc : input.setAcceptedTextFunc

    property alias logic         : logic

    QtObject {
        id : logic
        readonly property bool horizontal   : !vertical
        readonly property bool vertical     : rootObject.state === "top" || rootObject.state === "bottom"
        property alias labelPtr             : label
        property alias inputPtr             : input

        property real wConst  : 0.3
        property real hConst  : 0.3

        function update(){
            switch(rootObject.state) {
                case "left"   :
                    label.anchors.left   =  rootObject.left
                    label.anchors.right  =  undefined
                    label.anchors.top    =  rootObject.top
                    label.anchors.bottom =  undefined

                    input.anchors.left   =   undefined
                    input.anchors.right  =   rootObject.right
                    input.anchors.top    =   rootObject.top
                    input.anchors.bottom =   undefined

                    break;
                case "right"  :
                    label.anchors.left   =   undefined
                    label.anchors.right  =  rootObject.right
                    label.anchors.top    =  rootObject.top
                    label.anchors.bottom =  undefined

                    input.anchors.left   =   rootObject.left
                    input.anchors.right  =   undefined
                    input.anchors.top    =   rootObject.top
                    input.anchors.bottom =   undefined


                    break;
                case "top"    :
                    label.anchors.left   =  rootObject.left
                    label.anchors.right  =  undefined
                    label.anchors.top    =  rootObject.top
                    label.anchors.bottom =  undefined

                    input.anchors.left   =   rootObject.left
                    input.anchors.right  =   undefined
                    input.anchors.top    =   undefined
                    input.anchors.bottom =   rootObject.bottom

                    break;
                case "bottom" :
                    label.anchors.left   =  rootObject.left
                    label.anchors.right  =  undefined
                    label.anchors.top    =  undefined
                    label.anchors.bottom =  rootObject.bottom

                    input.anchors.left   =   rootObject.left
                    input.anchors.right  =   undefined
                    input.anchors.top    =   rootObject.top
                    input.anchors.bottom =   undefined

                    break;
            }
        }

    }

    ZText {
        id    : label
        width : logic.horizontal ? parent.width * logic.wConst : parent.width
        height :logic.vertical   ? parent.height * logic.hConst :  parent.height

    }

    ZTextBox {
        id : input
        width :  logic.horizontal ? parent.width  - label.width     : parent.width
        height : logic.vertical   ? parent.height - label.height    : parent.height
        clip : true

        validationFunc: rootObject.validationFunc
        onInputChanged: rootObject.inputChanged(text,oldText,acceptable);
        onAccepted    : rootObject.accepted(text, oldText);
        state : "ghost"
    }



}
