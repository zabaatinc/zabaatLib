import QtQuick 2.4
import Zabaat.Material 1.0
import Zabaat.Base 1.0

ZSkin {
    id : rootObject
    objectName       : "ZToastErrorSkin"
    color            : graphical.fill_Default
    border.color     : graphical.borderColor
    anchors.centerIn : parent
//    border.width     : 1

    property alias font          : text.font
    property alias guiLogic : guiLogic
    QtObject {
        id : guiLogic
        property real cellHeight : 0.2
        property int closeBtnPos : 0
    }

    QtObject {
        id : graphicalOverride
        property TextEdit _text : TextEdit{
            id : text
            horizontalAlignment: graphical.text_hAlignment
            verticalAlignment  : graphical.text_vAlignment
            font.family        : logic.font1
            font.pixelSize     : parent ? parent.height * 1/4  : 10
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
        id : title
        width : parent.width
        height : parent.height * guiLogic.cellHeight
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
        height : parent.height - title.height
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
                text           : logic ? logic.closeButtonText  : FA.close
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
                        clip : true
                    }
                    ZTextBox {
                        enabled : false
                        disableShowsGraphically: false
                        height : parent.height
                        width  : parent.width * 0.75
                        text   : parent.m.data
                        clip : true
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
                        clip : true
                    }
                    ZTextBox {
                        enabled : false
                        disableShowsGraphically: false
                        height : parent.height
                        width  : parent.width * 0.25
                        text   : line
                        clip : true
                    }
                    ZTextBox {
                        enabled : false
                        disableShowsGraphically: false
                        height : parent.height
                        width  : parent.width * 0.5
                        text   : file
                        clip : true
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
                        clip : true
                    }
                    ZTextBox {
                        enabled : false
                        disableShowsGraphically: false
                        height : parent.height
                        width  : parent.width * 0.75
                        text   : parent.m.data
                        clip : true
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
          "default" : { "rootObject": { "border.width" : 3,
                                      "radius"       : 0,
                                      "@width"       : [parent,"width"],
                                      "@height"      : [parent,"height"],
                                      rotation       : 0
                                     } ,
                        'guiLogic' : { 'cellHeight' : 0.1 }

          },
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
          "h40"  :  { "guiLogic" : { "cellHeight" : 0.40   }  }

    })



}
