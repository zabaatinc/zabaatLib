import QtQuick 2.4
import Zabaat.Material 1.0
ZSkin {
    id : rootObject
    objectName       : "ZToastSimpleSkin"
    color            : graphical.fill_Default
    border.color     : graphical.borderColor
    anchors.centerIn : parent
//    border.width     : 1

    property alias graphical     : graphical
    property alias textContainer : textContainer
    property alias font          : text.font
    QtObject {
        id : graphical
        property color fill_Default: Colors.standard
        property color fill_Press  : Colors.accent
        property color fill_Focus  : Colors.info
        property color text_Default: Colors.text1
        property color text_Press  : Colors.text2
        property color text_Focus  : Colors.text2
        property int   text_hAlignment  : Text.AlignHCenter
        property int   text_vAlignment  : Text.AlignVCenter
        property color inkColor    : Colors.getContrastingColor(rootObject.color)
        property color borderColor : Colors.text1
        property real inkOpacity   : 1
    }


    MouseArea {
        anchors.fill: parent
        drag.target: logic ? logic : null
        propagateComposedEvents: true
    }
    Item {
        id : gui
        anchors.fill: parent
        Rectangle {
            width : parent.width //- closeButton.anchors.rightMargin - closeButton.width
            height : closeButton.height
            clip   : true

            Text {
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
                font.pixelSize: height * 1/3
                color              : Colors.text1
                textFormat         : Text.RichText
                text               : logic.title ? logic.title : ""
            }

        }
        Item {
            id :  textContainer
            anchors.fill: parent
            clip : true
            Text {
                id : text
                anchors.fill       : parent
                anchors.margins    : parent.height * 1/10
                horizontalAlignment: graphical.text_hAlignment
                verticalAlignment  : graphical.text_vAlignment
                font.family        : logic.font1
                font.pixelSize     : parent.height * 1/4
                text               : logic.text
                color              : Colors.text1
                textFormat         : Text.RichText
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
                font.pixelSize: height * 1/4
                color              : Colors.text1
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
            color : "transparent"
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
            width : height
            height : parent.height * 0.2

        }

    }

    states : ({
          "default" : { "rootObject": { "border.width" : 5,
                                      "radius"       : 0,
                                      "@width"       : [parent,"width"],
                                      "@height"      : [parent,"height"],
                                      rotation       : 0
                                     } ,
                        "graphical" : {
                             "@fill_Default": [Colors,"standard"],
                             "@text_Default": [Colors,"text1"],
                             "@fill_Press"  : [Colors,"standard"],
                             "@text_Press"  : [Colors,"info"],
                             "@fill_Focus"  : [Colors,"info"],
                             "@text_Focus"  : [Colors,"text2"],
                             "@inkColor"    : [Colors,"accent"],
                             "@borderColor" : [Colors,"text1"],
                             inkOpacity : 1,
                             text_hAlignment : Text.AlignHCenter,
                             text_vAlignment : Text.AlignVCenter
                      },
                      textContainer : { rotation : 0 },
          },
          "t2" : { "graphical" : {"@borderColor"   : [Colors,"text2"],
                                  "@text_Default"   : [Colors,"text2"]
                                 }
          }
    })



}
