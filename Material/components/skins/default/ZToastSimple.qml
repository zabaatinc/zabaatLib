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
    property alias notext : textContainer.notext
    property alias notitle : textContainer.notitle
    property alias guiLogic : guiLogic
    QtObject {
        id : guiLogic
        property real cellHeight : 0.2
        property int closeBtnPos : 0
        property bool closeAnywhere : false
    }

    MouseArea {
        anchors.fill: parent
        drag.target: logic ? logic : null
        propagateComposedEvents: true
        onClicked : if(guiLogic.closeAnywhere) {
                        logic.attemptDestruction();
                    }
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
                anchors.horizontalCenter: parent.horizontalCenter
                color : Colors.getContrastingColor(graphical.fill_Default)

                visible : !textContainer.notitle
                width   : visible ? titleText.paintedWidth * 1.05 : 0
                height  : visible ? 2 : 0
            }

            Text {
                id : titleText
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
                font.pixelSize     : rootObject.font.pixelSize
                color              : text.color
                textFormat         : Text.RichText
                text               : logic.title ? logic.title : ""

                visible : !textContainer.notitle
                width   : visible ? parent.width : 0
                height  : visible ? parent.height : 0
            }

        }
        Item {
            id :  textContainer
            width   : visible ? parent.width : 0
            height  : visible ? parent.height : 0
            visible : !notext
            clip    : true
            property bool dynamicScale : true
            property bool notitle : false
            property bool notext : false

            Text {
                id : text
                anchors.fill       : parent
                anchors.margins    : parent.height * 1/10
                horizontalAlignment: graphical.text_hAlignment
                verticalAlignment  : graphical.text_vAlignment
                font.family        : logic.font1
//                font.pixelSize     : height * 1/4
                text               : logic.text
                color              : Colors.contrastingTextColor(rootObject.color)
                textFormat         : Text.RichText
                wrapMode: Text.WordWrap
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
            anchors.right  : guiLogic.closeBtnPos === 0  ?  parent.right : undefined
            anchors.left   : guiLogic.closeBtnPos === 1  ?  parent.left : undefined
            anchors.top    : parent.top
            anchors.margins: 5
            state          : logic ? logic.closeButtonState : "default"
            text           : logic ? logic.closeButtonText  : FA.close
            onClicked      : if(logic) logic.attemptDestruction()
            width  : height
            height : parent.height * guiLogic.cellHeight

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
                      textContainer : { rotation : 0 , dynamicScale : true, notext:false,notitle:false },

          } ,
         "notimer" : {"timerText" : {visible : false } } ,
         "noclose" : {"closeButton" : {visible:false} },
         "nodynamicscale" : {"textContainer" : { dynamicScale:false} } ,
         "multiline" : {"textContainer" : { dynamicScale:false} } ,
         "notext"    : {"textContainer" : { notext:true} } ,
         "notitle"   : {"textContainer" : { notitle:true} } ,
          "closeleft"   :  { "guiLogic" : { "closeBtnPos" : 0   }  } ,
          "closeright"  :  { "guiLogic" : { "closeBtnPos" : 1   }  } ,
          "h005"  :  { "guiLogic" : { "cellHeight" : 0.05   }  } ,
          "h006"  :  { "guiLogic" : { "cellHeight" : 0.06   }  } ,
          "h007"  :  { "guiLogic" : { "cellHeight" : 0.07   }  } ,
          "h008"  :  { "guiLogic" : { "cellHeight" : 0.08   }  } ,
          "h009"  :  { "guiLogic" : { "cellHeight" : 0.09   }  } ,
          "h01"   :  { "guiLogic" : { "cellHeight" : 0.10   }  } ,
          "h010"  :  { "guiLogic" : { "cellHeight" : 0.10   }  } ,
          "h011"  :  { "guiLogic" : { "cellHeight" : 0.11   }  } ,
          "h012"  :  { "guiLogic" : { "cellHeight" : 0.12   }  } ,
          "h013"  :  { "guiLogic" : { "cellHeight" : 0.13   }  } ,
          "h014"  :  { "guiLogic" : { "cellHeight" : 0.14   }  } ,
          "h015"  :  { "guiLogic" : { "cellHeight" : 0.15   }  } ,
          "h016"  :  { "guiLogic" : { "cellHeight" : 0.16   }  } ,
          "h017"  :  { "guiLogic" : { "cellHeight" : 0.17   }  } ,
          "h018"  :  { "guiLogic" : { "cellHeight" : 0.18   }  } ,
          "h019"  :  { "guiLogic" : { "cellHeight" : 0.19   }  } ,
          "h020"  :  { "guiLogic" : { "cellHeight" : 0.20   }  } ,
          "h021"  :  { "guiLogic" : { "cellHeight" : 0.21   }  } ,
          "h022"  :  { "guiLogic" : { "cellHeight" : 0.22   }  } ,
          "h023"  :  { "guiLogic" : { "cellHeight" : 0.23   }  } ,
          "h024"  :  { "guiLogic" : { "cellHeight" : 0.24   }  } ,
          "h025"  :  { "guiLogic" : { "cellHeight" : 0.25   }  } ,
          "h11"  :  { "guiLogic" : { "cellHeight" : 0.11   }  } ,
          "h12"  :  { "guiLogic" : { "cellHeight" : 0.12   }  } ,
          "h13"  :  { "guiLogic" : { "cellHeight" : 0.13   }  } ,
          "h14"  :  { "guiLogic" : { "cellHeight" : 0.14   }  } ,
          "h15"  :  { "guiLogic" : { "cellHeight" : 0.15   }  } ,
          "h16"  :  { "guiLogic" : { "cellHeight" : 0.16   }  } ,
          "h17"  :  { "guiLogic" : { "cellHeight" : 0.17   }  } ,
          "h18"  :  { "guiLogic" : { "cellHeight" : 0.18   }  } ,
          "h19"  :  { "guiLogic" : { "cellHeight" : 0.19   }  } ,
          "h20"  :  { "guiLogic" : { "cellHeight" : 0.20   }  } ,
          "h20"  :  { "guiLogic" : { "cellHeight" : 0.20   }  } ,
          "h21"  :  { "guiLogic" : { "cellHeight" : 0.21   }  } ,
          "h22"  :  { "guiLogic" : { "cellHeight" : 0.22   }  } ,
          "h23"  :  { "guiLogic" : { "cellHeight" : 0.23   }  } ,
          "h24"  :  { "guiLogic" : { "cellHeight" : 0.24   }  } ,
          "h25"  :  { "guiLogic" : { "cellHeight" : 0.25   }  } ,
          "h26"  :  { "guiLogic" : { "cellHeight" : 0.26   }  } ,
          "h27"  :  { "guiLogic" : { "cellHeight" : 0.27   }  } ,
          "h28"  :  { "guiLogic" : { "cellHeight" : 0.28   }  } ,
          "h29"  :  { "guiLogic" : { "cellHeight" : 0.29   }  } ,
          "h30"  :  { "guiLogic" : { "cellHeight" : 0.30   }  } ,
          "h31"  :  { "guiLogic" : { "cellHeight" : 0.31   }  } ,
          "h32"  :  { "guiLogic" : { "cellHeight" : 0.32   }  } ,
          "h33"  :  { "guiLogic" : { "cellHeight" : 0.33   }  } ,
          "h34"  :  { "guiLogic" : { "cellHeight" : 0.34   }  } ,
          "h35"  :  { "guiLogic" : { "cellHeight" : 0.35   }  } ,
          "h36"  :  { "guiLogic" : { "cellHeight" : 0.36   }  } ,
          "h37"  :  { "guiLogic" : { "cellHeight" : 0.37   }  } ,
          "h38"  :  { "guiLogic" : { "cellHeight" : 0.38   }  } ,
          "h39"  :  { "guiLogic" : { "cellHeight" : 0.39   }  } ,
          "h40"  :  { "guiLogic" : { "cellHeight" : 0.40   }  } ,
          "closeanywhere" : { "guiLogic" : { "closeAnywhere" : true   }  }
    })



}
