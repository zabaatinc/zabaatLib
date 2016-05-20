import QtQuick 2.4
import Zabaat.Misc.Global 1.0
import "../"


ZButton{
    id : rootObject

//    clip : true
    property int    btnSize   : 64
    property string label     : label.text
    property string icon      : "\uf212"
    property string miniIcon  : ""
    property alias labelPtr: label

    property var clickFunc 	  : null
    property var clickArgs    : null

    width 					  : btnSize ;
    height 					  : btnSize;
    fontFamily			 	  : "fontAwesome"
    text				      : rootObject.icon
    fontSize 				  : btnSize * 0.33
    textPtr.y 				  : -label.height/2
    border.width              : 1

    onBtnClicked : {
        if(clickFunc) {
            if(ZGlobal._.isArray(clickArgs))       clickFunc.apply(this,clickArgs)
            else                                   clickFunc(clickArgs)
        }
    }



    ZText {
        id : label
        anchors.bottom: parent.bottom
        width : parent.width; height: parent.height * 0.15;
        color : ZGlobal.style.text.color2
        fontColor : ZGlobal.style.text.color1
        text : rootObject.label
        showOutlines: false
        border.width: 1
        radius : parent.radius
    }
    Loader {
        anchors.right  : parent.right
        anchors.bottom : label.top
        anchors.margins: 5
        sourceComponent: rootObject.miniIcon ? miniIcon : null
        onLoaded : item.text = rootObject.miniIcon

        Component {
            id : miniIcon
            Text {
                font.family: "FontAwesome"
                font.pointSize: rootObject.fontSize / 3
                verticalAlignment:  Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                text : ""
                color: rootObject.textColor
            }
        }
    }

}

