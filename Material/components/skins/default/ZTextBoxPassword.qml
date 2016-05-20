import QtQuick 2.4
import Zabaat.Material 1.0
ZSkin {
    id : rootObject
    color            : graphical.fill_Default
    border.color     : graphical.borderColor
    anchors.centerIn : parent
//    clip : true
//    border.width     : 1
    property alias graphicalOverride : graphicalOverride
    property alias font : text.font
    property alias gui  : gui
    readonly property alias isFocused : input.activeFocus

    QtObject {
        id : graphicalOverride
        property real  barHeight     : 4
    }

    Item {
        id: gui
        anchors.fill: parent
        property bool inputState : input.activeFocus    //when user is inputting stuff!
        property alias textArea : textArea
        focus : false

        Item {
            id : textArea
            width  : parent.width  - 5
            height : parent.height - botBar.height - label.font.pixelSize
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom          : botBar.top
            focus : false

            property alias text : text
            property alias label : label
            property alias input : input
            TextInput {
                id : text
                horizontalAlignment: graphical.text_hAlignment
                verticalAlignment  : Text.AlignVCenter
                text               : logic && logic.text ? logic.text : ""
                anchors.fill       : parent
                visible            : input.opacity === 0
                color              : input.color
                focus              : false
                onTextChanged      : input.text = text.text
                enabled            : false
                echoMode: TextInput.Password
            }

            Item {
                width  : parent.width
                height : parent.height
                clip : label.clip
                Text {
                    id : label
                    verticalAlignment  : Text.AlignVCenter
                    horizontalAlignment: graphical.text_hAlignment
                    color              : input.color
                    opacity            : 0.5    //the 0.5 opacity will give it a faded look!
                    text               : logic && logic.label ? logic.label : ""
                    font {
                        family : text.font.family
                        pixelSize: text.font.pixelSize
                    }
                    width  : parent.width
                    height : parent.height
                    anchors.left      : parent.left
                    anchors.top       : parent.top
                    anchors.topMargin : gui.inputState || (text.text !== "" && input.text !== "") ? -(height + font.pixelSize/2) : 0

                    Behavior on anchors.topMargin  { NumberAnimation { duration : 333  } }

                }
            }





            MouseArea {
                anchors.fill: parent
                onClicked   : {
                    input.text = text.text
                    input.forceActiveFocus();
                }
                focus : false
            }

            TextInput {
                id                 : input
                anchors.fill       : parent
                onAccepted         : if(logic && logic.setTextFunc && insync) {
                                         logic.setTextFunc(input.text , true);
//                                         nextItemInFocusChain();
                                     }
                echoMode: TextInput.Password
                onActiveFocusChanged : {
                    if(activeFocus && logic){
                        input.text = logic.text
                        insync = true;
                    }
                    else if(!activeFocus){
//                        input.text = Qt.binding(function() { return logic ? logic.text : "" })
                        insync = false;
                    }
                }

                Keys.onTabPressed: { logic.setTextFunc(input.text) ; event.accepted = false }
                onTextChanged      : if(logic && logic.setTextFunc && insync && gui.inputState)
                                         logic.setTextFunc(input.text);

                horizontalAlignment: graphical.text_hAlignment
                verticalAlignment  : Text.AlignVCenter
                focus              : true
                opacity            : gui.inputState ? 1 : 0
                font               : text.font
                color              : graphical.text_Default
                activeFocusOnTab   : true
                text : logic ? logic.text : ""
                property bool insync : false
            }
        }


        Rectangle {
            id : botBar
            width         : parent.width * 0.95
            height        : graphicalOverride.barHeight
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: height/2
            color         : Colors.getContrastingColor(thickerBar.color,1.2)
            focus : false

            Rectangle {
                id : thickerBar
                width : parent.width
                height : parent.height + 3      //the plus should be an odd number :)

                anchors.verticalCenter: parent.verticalCenter
                color : error.text === "" ?  graphical.fill_Focus : Colors.danger
                transform: Scale {
                    yScale : 1
                    xScale : !gui.inputState ? 0  : 1
                    Behavior on xScale{ NumberAnimation { duration : 333}}
                    origin.x : parent.width/2
                }
                focus : false
            }
            Text {
                id : error
                verticalAlignment  : Text.AlignTop
                horizontalAlignment: graphical.text_hAlignment
                color              : Colors.danger
                text               : logic && logic.error ? logic.error : ""
                font               : label.font
                width              : parent.width
                height             : parent.height * 1/2
                anchors.left       : parent.left
                anchors.top        : parent.bottom
                focus : false
//                anchors.topMargin  : height * 2
            }

        }
    }

    states : ({
          "default" : { "rootObject": { "border.width" : 0,
                                      "radius"         : 0,
                                      "@width"         : [parent,"width"],
                                      "@height"        : [parent,"height"],
                                       rotation        : 0
                                      } ,
                        graphical : { "fill_Default" : "transparent" } ,
                        "graphicalOverride" : {
                          "barHeight" : 4,
                         },
                       "gui.textArea.label" : { visible : true , clip : false }
          },
         "nolabel" : { "gui.textArea.label" : { visible : false }

                     } ,
         "cliplabel" : { "gui.textArea.label" : { clip : true }

                      } ,
    })

}
