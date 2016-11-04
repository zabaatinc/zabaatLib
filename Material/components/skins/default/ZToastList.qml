import QtQuick 2.4
import Zabaat.Material 1.0 as M
//import QtGraphicalEffects 1.0
M.ZSkin {
    id : rootObject
    objectName : "ZToastListSkin"
    color                        : graphical.fill_Default
    border.color                 : graphical.borderColor
    anchors.centerIn             : parent
    property alias font          : titleText.font
    property alias closeButton   : closeButton
    property var mType           : logic && logic.modelType ? logic.modelType : undefined
    property alias guiLogic : guiLogic

    QtObject {
        id : guiLogic
        property real cellHeight : 0.2
        property real gridCellHeight : 0.2
        property int closeBtnPos : 0
        property bool fillGrid   : false
        onFillGridChanged: console.log("FillGrid", rootObject.state)
    }


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

            property var father : logic && logic.parent ? logic.parent : null;
            property var gFather : father && father.parent ? father.parent : null;
            property var ggFather : gFather && gFather.parent ? gFather.parent : null;
            property point pos : ggFather ? ggFather.mapToItem(rootObject, 0,0) : Qt.point(0,0);
            property point dim : ggFather ? Qt.point(ggFather.width, ggFather.height) : Qt.point(32,32);
            drag.minimumX: pos.x
            drag.minimumY: pos.y
            drag.maximumX: pos.x + dim.x - rootObject.width;
            drag.maximumY: pos.y + dim.y - rootObject.height;
        }

        Rectangle {
            id : titleContainer
            width : parent.width
            height : parent.height * guiLogic.cellHeight
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
                state          : logic ? logic.closeButtonState : "default"
                text           : logic ? logic.closeButtonText  : M.FAR.close
                onClicked      : if(logic)
                                     logic.attemptDestruction()
                width  : height
                height : parent.height
                anchors.right  : guiLogic.closeBtnPos === 0  ?  parent.right : undefined
                anchors.left   : guiLogic.closeBtnPos === 1  ?  parent.left : undefined
            }
        }

        Item {
            id : answerAndOpts
            width : parent.width
            height : parent.height - titleContainer.height
            anchors.bottom: parent.bottom

            GridView {
                id : gv
                anchors.fill            : parent
                anchors.margins         : 10
                clip                    : true
                anchors.horizontalCenter: parent.horizontalCenter
                interactive             : contentHeight > height ? true : false

                property int columns    : logic && logic.columns ? logic.columns : 1
                property int rows       : gv.count / columns

//                onColumnsChanged: console.log("GV.columns", columns)
//                onRowsChanged   : console.log("GV.rows", rows)

                cellHeight : !guiLogic.fillGrid ?  gv.height * guiLogic.gridCellHeight :
                                                   gv.height / rows
//                onCellHeightChanged: console.log("GV.CellHeight", gv.cellHeight , gv.height)

                cellWidth  : gv.width  / columns


                model : logic && logic.model && mType ? logic.model : null

                delegate : Loader  {
                    id : delLoader
                    width  : gv.cellWidth
                    height : gv.cellHeight
                    sourceComponent : logic && logic.delegate ? logic.delegate : defCmp

                    property bool hasOnClickHandler : item && typeof item.clicked === 'function' ?  true : false
                    property var  m          : mType === 'array' ? gv.model[index] : gv.model.get(index)
//                    property string isString : typeof m
//                    property string key : logic && logic.key ? logic.key : "name"

                    onLoaded : {
                        item.anchors.fill = delLoader

                        if(item.hasOwnProperty('index'))
                            item.index = Qt.binding(function() { return index })

                        if(item.hasOwnProperty('model'))
                             item.model = Qt.binding(function() { return m })

                        if(hasOnClickHandler)  //is a signal
                            item.clicked.connect(clickFunc)
                    }

                    MouseArea {
                        id : ma
                        anchors.fill: parent
                        propagateComposedEvents: true
                        preventStealing: false
                        onClicked      : parent.clickFunc()
                        enabled        : !parent.hasOnClickHandler && parent.status === Loader.Ready ?  true : false
                        z : Number.MAX_VALUE
                    }

                    function clickFunc() {
                        if(logic && mType){
                            if(logic.acceptFunc)
                                logic.acceptFunc(m)

                            logic.attemptDestruction(true);
                        }
                    }
                }


                Component {
                    id : defCmp
                    M.ZButton {
                        property var model  : null
                        property int index  : -1
                        property string key : logic && logic.key ? logic.key : "name"
                        state  : logic && logic.delegateBtnState ? logic.delegateBtnState : ""
                        text   :  {
                            if(typeof model === 'string'   )
                                return model
                            return model  && model[key] ? model[key] : "??"
                        }


                    }
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
                      "guiLogic" :  { cellHeight : 0.2, closeBtnPos : 0, fillGrid : false, gridCellHeight : 0.2 }

          } ,
         "fill" : {"guiLogic" : { "fillGrid" : true } },
         "noclose" : {"closeButton" : {visible:false} },
          "closeleft"   :  { "guiLogic" : { "closeBtnPos" : 1   }  } ,
          "closeright"  :  { "guiLogic" : { "closeBtnPos" : 0   }  } ,

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
                  "h40"  :  { "guiLogic" : { "cellHeight" : 0.40   }  }  ,
                  "c005" :  { "guiLogic" : { "gridCellHeight" : 0.05   }  } ,
                  "c006" :  { "guiLogic" : { "gridCellHeight" : 0.06   }  } ,
                  "c007" :  { "guiLogic" : { "gridCellHeight" : 0.07   }  } ,
                  "c008" :  { "guiLogic" : { "gridCellHeight" : 0.08   }  } ,
                  "c009" :  { "guiLogic" : { "gridCellHeight" : 0.09   }  } ,
                  "c01"  :  { "guiLogic" : { "gridCellHeight" : 0.10   }  } ,
                  "c010" :  { "guiLogic" : { "gridCellHeight" : 0.10   }  } ,
                  "c011" :  { "guiLogic" : { "gridCellHeight" : 0.11   }  } ,
                  "c012" :  { "guiLogic" : { "gridCellHeight" : 0.12   }  } ,
                  "c013" :  { "guiLogic" : { "gridCellHeight" : 0.13   }  } ,
                  "c014" :  { "guiLogic" : { "gridCellHeight" : 0.14   }  } ,
                  "c015" :  { "guiLogic" : { "gridCellHeight" : 0.15   }  } ,
                  "c016" :  { "guiLogic" : { "gridCellHeight" : 0.16   }  } ,
                  "c017" :  { "guiLogic" : { "gridCellHeight" : 0.17   }  } ,
                  "c018" :  { "guiLogic" : { "gridCellHeight" : 0.18   }  } ,
                  "c019" :  { "guiLogic" : { "gridCellHeight" : 0.19   }  } ,
                  "c020" :  { "guiLogic" : { "gridCellHeight" : 0.20   }  } ,
                  "c021" :  { "guiLogic" : { "gridCellHeight" : 0.21   }  } ,
                  "c022" :  { "guiLogic" : { "gridCellHeight" : 0.22   }  } ,
                  "c023" :  { "guiLogic" : { "gridCellHeight" : 0.23   }  } ,
                  "c024" :  { "guiLogic" : { "gridCellHeight" : 0.24   }  } ,
                  "c025" :  { "guiLogic" : { "gridCellHeight" : 0.25   }  } ,
                  "c11"  :  { "guiLogic" : { "gridCellHeight" : 0.11   }  } ,
                  "c12"  :  { "guiLogic" : { "gridCellHeight" : 0.12   }  } ,
                  "c13"  :  { "guiLogic" : { "gridCellHeight" : 0.13   }  } ,
                  "c14"  :  { "guiLogic" : { "gridCellHeight" : 0.14   }  } ,
                  "c15"  :  { "guiLogic" : { "gridCellHeight" : 0.15   }  } ,
                  "c16"  :  { "guiLogic" : { "gridCellHeight" : 0.16   }  } ,
                  "c17"  :  { "guiLogic" : { "gridCellHeight" : 0.17   }  } ,
                  "c18"  :  { "guiLogic" : { "gridCellHeight" : 0.18   }  } ,
                  "c19"  :  { "guiLogic" : { "gridCellHeight" : 0.19   }  } ,
                  "c20"  :  { "guiLogic" : { "gridCellHeight" : 0.20   }  } ,
                  "c20"  :  { "guiLogic" : { "gridCellHeight" : 0.20   }  } ,
                  "c21"  :  { "guiLogic" : { "gridCellHeight" : 0.21   }  } ,
                  "c22"  :  { "guiLogic" : { "gridCellHeight" : 0.22   }  } ,
                  "c23"  :  { "guiLogic" : { "gridCellHeight" : 0.23   }  } ,
                  "c24"  :  { "guiLogic" : { "gridCellHeight" : 0.24   }  } ,
                  "c25"  :  { "guiLogic" : { "gridCellHeight" : 0.25   }  } ,
                  "c26"  :  { "guiLogic" : { "gridCellHeight" : 0.26   }  } ,
                  "c27"  :  { "guiLogic" : { "gridCellHeight" : 0.27   }  } ,
                  "c28"  :  { "guiLogic" : { "gridCellHeight" : 0.28   }  } ,
                  "c29"  :  { "guiLogic" : { "gridCellHeight" : 0.29   }  } ,
                  "c30"  :  { "guiLogic" : { "gridCellHeight" : 0.30   }  } ,
                  "c31"  :  { "guiLogic" : { "gridCellHeight" : 0.31   }  } ,
                  "c32"  :  { "guiLogic" : { "gridCellHeight" : 0.32   }  } ,
                  "c33"  :  { "guiLogic" : { "gridCellHeight" : 0.33   }  } ,
                  "c34"  :  { "guiLogic" : { "gridCellHeight" : 0.34   }  } ,
                  "c35"  :  { "guiLogic" : { "gridCellHeight" : 0.35   }  } ,
                  "c36"  :  { "guiLogic" : { "gridCellHeight" : 0.36   }  } ,
                  "c37"  :  { "guiLogic" : { "gridCellHeight" : 0.37   }  } ,
                  "c38"  :  { "guiLogic" : { "gridCellHeight" : 0.38   }  } ,
                  "c39"  :  { "guiLogic" : { "gridCellHeight" : 0.39   }  } ,
                  "c40"  :  { "guiLogic" : { "gridCellHeight" : 0.40   }  }
    })



//    Rectangle {
//        anchors.fill: parent

//        color : 'transparent'
//        border.color: "Red"
//        border.width: 5
//    }

}


