import QtQuick 2.4
import Zabaat.Material 1.0
import "helpers/Underscore"

ZSkin {
    id : rootObject
    objectName       : "ZToastErrorSkin"
    color            : graphical.fill_Default
    border.color     : graphical.borderColor
    anchors.centerIn : parent
//    border.width     : 1

    property alias graphical     : graphical
    property alias font          : text.font
    QtObject {
        id : graphical
        property color fill_Default     : Colors.standard
        property color fill_Press       : Colors.accent
        property color fill_Focus       : Colors.info
        property color text_Default     : Colors.text1
        property color text_Press       : Colors.text2
        property color text_Focus       : Colors.text2
        property int   text_hAlignment  : Text.AlignHCenter
        property int   text_vAlignment  : Text.AlignVCenter
        property color inkColor         : Colors.getContrastingColor(rootObject.color)
        property color borderColor      : Colors.text1
        property real inkOpacity        : 1

        property TextEdit _text : TextEdit{
            id : text
            horizontalAlignment: graphical.text_hAlignment
            verticalAlignment  : graphical.text_vAlignment
            font.family        : logic.font1
            font.pixelSize     : parent.height * 1/4
            text               : "@__@"
            color              : Colors.text1
            textFormat         : Text.PlainText
            opacity : 0
//            Component.onCompleted: doCopy()
            function doCopy(val){
                function replaceAll(find, replace, str) {
                    function escapeRegExp(string) {
                        return string.replace(/([.*+?^=!:${}()|\[\]\/\\])/g, "\\$1");
                    }

                  return str.replace(new RegExp(escapeRegExp(find), 'g'), replace);
                }

//                val = replaceAll("\t","<tab>",val)
//                val = replaceAll("\n","<br>",val)


                text.text = val
                text.selectAll()
                text.copy()
                text.text = ""
            }
        }

    }

    ZButton {
        width : parent.width
        height : parent.height * 0.1
        state : "f2-danger"
        text : logic && logic.title && logic.title !== "" ?  FA.exclamation + " " + logic.title : FA.exclamation + " Error"
        disableShowsGraphically: false
        enabled : false

        MouseArea {
            anchors.fill: parent
            drag.target: logic ? logic : null
            propagateComposedEvents: true
        }
    }

    Item {
        id : gui
        width : parent.width
        height : parent.height * 0.9
        anchors.bottom: parent.bottom
        property string selectedMode : 'errormodel'

        Row {
            width  : parent.width
            height : parent.height * 0.2

            property int normalW: logic && logic.saveFunc ? (width - height * 3)/3 : (width - height * 2)/3
            ZButton {
                text    : "Error"
                width   : parent.normalW
                height  : parent.height
                state   : !logic ? "default" : !enabled ? logic.filterButtonStateSelected : logic.filterButtonState
                disableShowsGraphically: false
                enabled   : gui.selectedMode !== this.text.toLocaleLowerCase() + "model"
                onClicked : gui.selectedMode = this.text.toLocaleLowerCase() + "model"
            }
            ZButton {
                text : "Stack"
                width   : parent.normalW
                height  : parent.height
                state   : !logic ? "default" : !enabled ? logic.filterButtonStateSelected : logic.filterButtonState
                disableShowsGraphically: false
                enabled :  gui.selectedMode !== this.text.toLocaleLowerCase() + "model"
                onClicked : gui.selectedMode = this.text.toLocaleLowerCase() + "model"
            }
            ZButton {
                text : "ServerStack"
                width   : parent.normalW
                height  : parent.height
                state   : !logic ? "default" : !enabled ? logic.filterButtonStateSelected : logic.filterButtonState
                disableShowsGraphically: false
                enabled :  gui.selectedMode !== this.text.toLocaleLowerCase() + "model"
                onClicked : gui.selectedMode = this.text.toLocaleLowerCase() + "model"
            }
            ZButton {
                id : copyButton
                anchors.margins: 5
                state          : logic ? logic.filterButtonStateSelected + "-warning" : "default"
                text           : FA.floppy_o
                width          : visible ? height : 0
                height         : parent.height
                visible        : logic && logic.saveFunc
                onClicked : {
                    if(logic && logic.saveFunc && logic.logic && logic.logic.toJSON){
                        logic.saveFunc(logic.logic.toJSON())
                    }
                }
            }
            ZButton {
                id : saveButton
                anchors.margins: 5
                state          : logic ? logic.filterButtonStateSelected + "-warning" : "default"
                text           : FA.copy
                onClicked      : {
                    if(logic && logic.logic && logic.logic.toJSON){
                        text.doCopy(logic.logic.toJSON())
                    }
                }
                width          : height
                height         : parent.height
            }
            ZButton {
                id : closeButton
                anchors.margins: 5
                state          : logic ? logic.closeButtonState : "default"
                text           : FA.close
                onClicked      : if(logic) logic.attemptDestruction()
                width          : height
                height         : parent.height
            }
        }

        Item {
            id : lists
            width         : parent.width
            height        : parent.height * 0.8
            anchors.bottom: parent.bottom
            clip          : true

            ListView {
                id    : lv_error
                model : logic && logic.errorModel ? logic.errorModel : null
                anchors.fill: parent
                anchors.margins: 10
                visible : gui.selectedMode === 'errormodel'

                delegate : Row {
                    width  : lv_stack.width
                    height : lv_stack.height * 0.15

                    property var m : lv_error.model.get(index)
                    ZTextBox {
                        enabled : false
                        disableShowsGraphically: false
                        height : parent.height
                        width  : parent.width * 0.25
                        text   : parent.m.key
                    }
                    ZTextBox {
                        enabled : false
                        disableShowsGraphically: false
                        height : parent.height
                        width  : parent.width * 0.75
                        text   : parent.m.data
                    }
                }
            }

            ListView {
                id    : lv_stack
                model : logic && logic.stackModel ? logic.stackModel : null
                anchors.fill: parent
                anchors.margins: 10
                visible : gui.selectedMode === 'stackmodel'


                delegate : Row {
                    width  : lv_stack.width
                    height : lv_stack.height * 0.15
                    ZTextBox {
                        enabled : false
                        disableShowsGraphically: false
                        height : parent.height
                        width  : parent.width * 0.25
                        text   : fn
                    }
                    ZTextBox {
                        enabled : false
                        disableShowsGraphically: false
                        height : parent.height
                        width  : parent.width * 0.25
                        text   : line
                    }
                    ZTextBox {
                        enabled : false
                        disableShowsGraphically: false
                        height : parent.height
                        width  : parent.width * 0.5
                        text   : file
                    }
                }
            }

            ListView {
                id    : lv_serverStack
                model : logic && logic.serverStackModel ? logic.serverStackModel : null
                anchors.fill: parent
                anchors.margins: 10
                visible : gui.selectedMode === 'serverstackmodel'

                delegate : Row {
                    width  : lv_serverStack.width
                    height : lv_serverStack.height * 0.15

                    property var m : lv_serverStack.model.get(index)
                    ZTextBox {
                        enabled : false
                        disableShowsGraphically: false
                        height : parent.height
                        width  : parent.width * 0.25
                        text   : parent.m.key
                    }
                    ZTextBox {
                        enabled : false
                        disableShowsGraphically: false
                        height : parent.height
                        width  : parent.width * 0.75
                        text   : parent.m.data
                    }
                }
            }

        }




//        Item {
//            id :  textContainer
//            anchors.fill: parent
//            clip : true
//            Text {
//                id : text
//                anchors.fill       : parent
//                anchors.margins    : parent.height * 1/10
//                horizontalAlignment: graphical.text_hAlignment
//                verticalAlignment  : graphical.text_vAlignment
//                font.family        : logic.font1
//                font.pixelSize     : parent.height * 1/4
//                text               : logic.text
//                color              : Colors.text1
//                textFormat         : Text.RichText
//            }
//        }




        Rectangle {
            color : "transparent"
            anchors.fill: parent
            border.width: rootObject.border.width
            border.color: rootObject.border.color
            radius : rootObject.radius
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
          },
          "t2" : { "graphical" : {"@borderColor"   : [Colors,"text2"],
                                  "@text_Default"   : [Colors,"text2"]
                                 }
          }
    })



}
