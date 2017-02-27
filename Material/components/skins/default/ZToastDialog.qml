import QtQuick 2.4
import Zabaat.Material 1.0 as M
M.ZSkin {
    id : rootObject
    objectName : "ZToastDialog"
    color            : graphical.fill_Default
    border.color     : graphical.borderColor
    anchors.centerIn : parent
    property alias textContainer : ztoastsimple.textContainer
    property alias font          : ztoastsimple.font
    property alias timerText     : ztoastsimple.timerText
    property alias closeButton   : ztoastsimple.closeButton

    ZToastSimple {
        id : ztoastsimple
        anchors.centerIn: undefined
        anchors.fill    : undefined
        color           : "transparent"
        border.width: 0
        logic : parent.logic
        Component.onCompleted: {
            injectState("default","rootObject", { rootObject: { "border.width" : 0,"@width": [rootObject,"width"], "@height":[rootObject,"height",0.8] } } );
        }

    }

    Item {
        id : opts
        width  : parent.width * 0.9
        height : parent.height - ztoastsimple.height
        anchors.bottom: parent.bottom
        anchors.margins: 5
        anchors.horizontalCenter: parent.horizontalCenter

        M.ZButton {
            id : cancelBtn
            width  : parent.width / 3
            height : parent.height
            state  : !logic || !logic.cancelBtnState ? "default" : logic.cancelBtnState
            onClicked: if(logic)
                           logic.attemptDestruction();
            text : logic ? logic.textCancel : M.FA.close
            clip : true
        }

        M.ZButton {
            id : okBtn
            width  : parent.width / 3
            height : parent.height
            state  : !logic || !logic.okBtnState ? "default" : logic.okBtnState
            onClicked : if(logic) {
                            if(logic.acceptFunc)
                                logic.acceptFunc();

                            logic.attemptDestruction(true);
                        }
            anchors.right: parent.right
            text : logic ? logic.textAccept : M.FA.check
            clip : true
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
                      textContainer : { rotation : 0 },
          } ,
         "notimer" : {"timerText" : {visible : false } } ,
         "noclose" : {"closeButton" : {visible:false} }
    })



//    Rectangle {
//        anchors.fill: parent

//        color : 'transparent'
//        border.color: "Red"
//        border.width: 5
//    }

}


