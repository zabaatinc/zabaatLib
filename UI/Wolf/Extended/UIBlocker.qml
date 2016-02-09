import QtQuick 2.0
import Zabaat.UI.Fonts 1.0
import Zabaat.Misc.Global 1.0

Rectangle { //easy to use blocker ! This
    id : animationAndBlocker
    color : 'lightGray'
    opacity : 0.6
    property alias icon       : spinner.text
    property alias fontFamily : spinner.font.family
    property int   animSpeed  : 1000
    property alias iconColor  : spinner.color

//    visible : functions.loginState === 2    //connecting state
    MouseArea{
        anchors.fill: parent
        hoverEnabled: true
    }

    Text {
        id : spinner
        font.family: "FontAwesome"
        text : FontAwesome.refresh
        anchors.centerIn: parent
        horizontalAlignment : Text.AlignHCenter
        verticalAlignment : Text.AlignVCenter
        font.pointSize : parent.height * 0.33
        color : ZGlobal.style.warning
        NumberAnimation on rotation { from : 0; to: 360;  duration: animSpeed; running : animationAndBlocker.visible;
                                      loops : Animation.Infinite }
    }
}

