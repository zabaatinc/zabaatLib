import QtQuick 2.4
import Zabaat.Material 1.0 as M
//import QtGraphicalEffects 1.0
M.ZSkin {
    id : rootObject
    objectName : "ZToastListSkin"
    color            : graphical.fill_Default
    border.color     : graphical.borderColor
    anchors.centerIn : parent
    property alias font          : titleText.font
    property alias closeButton   : closeButton
    property var mType : logic && logic.modelType ? logic.modelType : undefined


    Rectangle {
        id : gui
        anchors.fill: parent
        color : 'transparent'
        radius : parent.radius
        clip : true
//        visible  : radius === 0

        MouseArea {
            anchors.fill: parent
            drag.target: logic ? logic : null
            propagateComposedEvents: true
        }

        Rectangle {
            id : titleContainer
            width : parent.width
            height : parent.height * 0.2
            clip: true
            color : M.Colors.getContrastingColor(rootObject.color,1.2)
            border.width: 1
            border.color: rootObject.border.color

            Item {
                //tContainer
                width : parent.width - closeButton.width
                height : parent.height

                Text {
                    id : titleText
                    anchors.fill: parent
                    anchors.margins: 5
                    horizontalAlignment: graphical.text_hAlignment
                    verticalAlignment  : graphical.text_vAlignment
                    font.family        : logic.font1
                    font.pixelSize     : parent.height * 1/2.5
                    color              : graphical.text_Default
                    textFormat         : Text.RichText
                    scale   :  (paintedWidth > width ? width/paintedWidth : 1)
                    text    : logic.title ? logic.title : ""
                }
            }





            M.ZButton {
                id : closeButton
                anchors.right  : parent.right
                state          : logic ? logic.closeButtonState : "default"
                text           : M.FA.close
                onClicked      : if(logic)
                                     logic.attemptDestruction()
                width  : height
                height : parent.height
            }
        }

        Item {
            id : answerAndOpts
            width : parent.width
            height : parent.height - titleContainer.height
            anchors.bottom: parent.bottom

            GridView {
                id : gv
                anchors.fill: parent
                anchors.margins: 10

                clip   : true
                anchors.horizontalCenter: parent.horizontalCenter
                interactive : contentHeight > height ? true : false


                property int columns    : logic && logic.columns ? logic.columns : 1
                cellHeight : gv.height * 0.2
                cellWidth  : width  / columns
                model : logic && logic.model && mType ? logic.model : null

                delegate : M.ZButton {
                    width  : gv.cellWidth
                    height : gv.cellHeight
                    state  : logic && logic.delegateBtnState ? logic.delegateBtnState : ""
                    onClicked : if(logic && mType){
                        if(logic.acceptFunc)
                            logic.acceptFunc(m)

                        logic.attemptDestruction(true);
                    }
                    property var    m   : mType === 'array' ? gv.model[index] : gv.model.get(index)
                    property string key : logic && logic.key ? logic.key : "name"
                    text : m ? m[key] : "??"
                }
                z : 999


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
                      font : { "@pixelSize" : [titleContainer,'height',1/3] } ,
                      closeButton   : {visible : true  } ,

          } ,
         "noclose" : {"closeButton" : {visible:false} }
    })



//    Rectangle {
//        anchors.fill: parent

//        color : 'transparent'
//        border.color: "Red"
//        border.width: 5
//    }

}


