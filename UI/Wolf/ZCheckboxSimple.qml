import QtQuick 2.4
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import Zabaat.Misc.Global 1.0
import "zbaseComponents"


FocusScope {
    id : rootObject
    property alias state         : cb.checked
    property alias checked       : cb.checked
    property alias label         : lbl.text
    property alias labelName     : lbl.text
    property alias textAlignment : lbl.horizontalAlignment
    onFocusChanged               : cb.focus = focus
    activeFocusOnTab             : true
    property int borderWidth     : 1

    ZTracer {
        color       : "black"
        bgColor     : ZGlobal.style._default
        anchors.fill: null
        height      : parent.height
        width       : parent.width - cb.width
        anchors.left: cb.right
        borderWidth: rootObject.borderWidth
        ZBase_Text {
            id : lbl
            width : parent.width - 10
            height : parent.height
            color : "transparent"

            onClicked   : cb.checked = !cb.checked
            horizontalAlignment: Text.AlignLeft
            anchors.horizontalCenter: parent.horizontalCenter
            enabled : false
            activeFocusOnTab: false
            outlineColor : 'transparent'
            outlineThickness : 0
        }
    }
    CheckBox {
        id : cb
        height : parent.height
        width  : height
        onFocusChanged : borderWidth = focus ? 3 : 1
        style : CheckBoxStyle {
            indicator: Rectangle {
                        implicitWidth : cb.width
                        implicitHeight: cb.height
                        border.width: 1
                            Rectangle {
                                color: control.checked ? ZGlobal.style.accent : ZGlobal.style._default
                                radius: 1
                                anchors.margins: 4
                                anchors.fill: parent
                                border.width: rootObject.borderWidth
                            }
                        }
        }
        onCheckedChanged: { if(checked) rootObject.checked;
                            else        rootObject.unchecked }

        Keys.onEnterPressed : checked = !checked
        Keys.onReturnPressed: checked = !checked
        Keys.onEscapePressed: checked = false
    }
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        onEntered : borderWidth = 3
        onExited  : borderWidth = 1
        onClicked : checked     = !checked
        propagateComposedEvents: false
    }
}
