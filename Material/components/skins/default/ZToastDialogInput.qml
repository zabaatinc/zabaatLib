import QtQuick 2.4
import Zabaat.Material 1.0 as M
M.ZSkin {
    id : rootObject
    objectName : "ZToastDialogInputSkin"
    color            : graphical.fill_Default
    border.color     : graphical.borderColor
    anchors.centerIn : parent
    property alias textContainer : ztoastsimple.textContainer
    property alias font          : ztoastsimple.font
    property alias timerText     : ztoastsimple.timerText
    property alias closeButton   : ztoastsimple.closeButton

    onLogicChanged: {
        if(logic) {
            answerText.text = logic.answer
        }
    }

    Connections {
        target : logic
        onAnswerChanged : if(answer != answerText.text)
                              answerText.text = answer
    }



    ZToastSimple {
        id : ztoastsimple
        anchors.centerIn: undefined
        anchors.fill    : undefined
        color           : "transparent"
        border.width: 0
        logic : parent.logic
        Component.onCompleted: {
            injectState("default","rootObject", { rootObject: { "border.width" : 0,"@width": [rootObject,"width"], "@height":[rootObject,"height",0.6] } } );
        }
    }

    Item {
        id : answerAndOpts
        width : parent.width
        height : parent.height - ztoastsimple.height
        anchors.bottom: parent.bottom

        M.ZTextBox {
            id : answerText
            clip : true
            label : logic && logic.label ? logic.label : ""
            width : parent.width * 0.8
            height : parent.height * 0.55
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            state : logic && logic.textboxState ? logic.textboxState : "standard-b1-f3";
            Component.onCompleted:  {
                if(logic)
                    text = logic.answer

                focusTimer.start()
            }

            Timer {
                id : focusTimer
                interval : 50
                repeat : false
                onTriggered: answerText.forceActiveFocus()

            }

            onTextChanged: if(logic && logic.answer !== text){
                logic.answer = text
            }
            onAccepted : if(logic) {
                             if(logic.acceptFunc)
                                 logic.acceptFunc(answerText.text);

                             logic.attemptDestruction(true);
                         }
            onActiveFocusChanged: if(activeFocus && logic && logic.focusFunc)
                                      logic.focusFunc()
        }

        Item {
            id : opts
            width   : parent.width - rootObject.radius * 2
            height  : parent.height * 0.4

            anchors.bottom: parent.bottom
            anchors.margins: 5
            anchors.right : parent.right
            anchors.rightMargin: rootObject.radius

            M.ZButton {
                id : cancelBtn
                width  : parent.width / 3
                height : parent.height
                state  : !logic || !logic.cancelBtnState ? "default" : logic.cancelBtnState
                onClicked: if(logic)
                               logic.attemptDestruction();
                text : logic ? logic.textCancel : M.FA.close
                anchors.left: parent.left
                anchors.leftMargin: 5
                clip : true
            }

            M.ZButton {
                id : okBtn
                width  : parent.width / 3
                height : parent.height
                state  : !logic || !logic.okBtnState ? "default" : logic.okBtnState
                onClicked : if(logic) {
                                if(logic.acceptFunc)
                                    logic.acceptFunc(answerText.text);

                                logic.attemptDestruction(true);
                            }

                text : logic ? logic.textAccept : M.FA.check
                anchors.right: parent.right
                anchors.rightMargin: 5
                clip : true
            }
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


