import QtQuick 2.4
import Zabaat.Material 1.0
ZSkin {
    id : rootObject
    objectName       : "ZToastSimpleSkin"
    color            : graphical.fill_Default
    border.color     : graphical.borderColor
    anchors.centerIn : parent

    property alias textContainer : textContainer
    property alias font          : text.font
    property alias timerText     : timerText
    property alias closeButton   : closeButton


    MouseArea {
        anchors.fill: parent
        drag.target: logic ? logic : null
        propagateComposedEvents: true
    }
    Item {
        id : gui
        anchors.fill: parent
        Item {
            width : parent.width //- closeButton.anchors.rightMargin - closeButton.width
            height : closeButton.height
            clip   : true

            Rectangle {
                anchors.bottom: parent.bottom
                width : titleText.paintedWidth * 1.05
                height : 2
                anchors.horizontalCenter: parent.horizontalCenter
                color : Colors.getContrastingColor(graphical.fill_Default)
            }

            Text {
                id : titleText
                anchors.fill       : parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment  : Text.AlignVCenter
                font.bold:               rootObject.font.bold
                font.capitalization:      rootObject.font.capitalization
                font.family:             rootObject.font.family
                font.italic:             rootObject.font.italic
                font.letterSpacing:      rootObject.font.letterSpacing
                font.overline:           rootObject.font.overline
                font.strikeout:          rootObject.font.strikeout
                font.underline:           rootObject.font.underline
                font.weight  :            rootObject.font.weight
                font.wordSpacing:         rootObject.font.wordSpacing
                font.pixelSize     : parent.height * 1/3
                color              : text.color
                textFormat         : Text.RichText
                text               : logic.title ? logic.title : ""
            }

        }
        Item {
            id :  textContainer
            anchors.fill: parent
            clip : true
            property bool dynamicScale : true
            Text {
                id : text
                anchors.fill       : parent
                anchors.margins    : parent.height * 1/10
                horizontalAlignment: graphical.text_hAlignment
                verticalAlignment  : graphical.text_vAlignment
                font.family        : logic.font1
                font.pixelSize     : height * 1/4
                text               : logic.text
                color              : Colors.contrastingTextColor(rootObject.color)
                textFormat         : Text.RichText
                wrapMode: parent.dynamicScale ? Text.NoWrap : Text.WordWrap
                scale   : parent.dynamicScale ?  (paintedWidth > width ? width/paintedWidth : 1) : 1
            }
        }


        Item {
            width  : parent.width
            height : closeButton.height
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            clip   : true

            Text {
                id : timerText
                anchors.fill       : parent
                anchors.margins : 5
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment  : Text.AlignVCenter
                font.bold:               rootObject.font.bold
                font.capitalization:      rootObject.font.capitalization
                font.family:             rootObject.font.family
                font.italic:             rootObject.font.italic
                font.letterSpacing:      rootObject.font.letterSpacing
                font.overline:           rootObject.font.overline
                font.strikeout:          rootObject.font.strikeout
                font.underline:           rootObject.font.underline
                font.weight  :            rootObject.font.weight
                font.wordSpacing:         rootObject.font.wordSpacing
                font.pixelSize:  text.pixelSize * 0.8
                color              : text.color
                textFormat         : Text.RichText
                text               :formatSeconds(runningDuration)
                property int runningDuration : 0;
                function formatSeconds(seconds)
                {
                    var date = new Date(1970,0,1);
                    date.setSeconds(seconds);
                    return date.toTimeString().replace(/.*(\d{2}:\d{2}:\d{2}).*/, "$1");
                }
            }

            Timer {
                interval : 1000
                onTriggered : timerText.runningDuration += 1;
                running : true
                repeat : true
            }

        }


        Rectangle {
            color : graphical.fill_Empty
            anchors.fill: parent
            border.width: rootObject.border.width
            border.color: rootObject.border.color
            radius : rootObject.radius
        }
        ZButton {
            id : closeButton
            anchors.right  : parent.right
            anchors.top    : parent.top
            anchors.margins: 5
            state          : logic ? logic.closeButtonState : "default"
            text           : FA.close
            onClicked      : if(logic) logic.attemptDestruction()
            width  : height
            height : parent.height * 0.1

        }

    }

    states : ({
          "default" : { "rootObject": { "border.width" : 5,
                                      "radius"       : 0,
                                      "@width"       : [parent,"width"],
                                      "@height"      : [parent,"height"],
                                      rotation       : 0
                                     } ,
                      timerText     : {visible : false } ,
                      closeButton   : {visible : true  } ,
                      textContainer : { rotation : 0 , dynamicScale : true },

          } ,
         "notimer" : {"timerText" : {visible : false } } ,
         "noclose" : {"closeButton" : {visible:false} },
         "nodynamicscale" : {"textContainer" : { dynamicScale:false} } ,
         "multiline" : {"textContainer" : { dynamicScale:false} }
    })



}
