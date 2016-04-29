import QtQuick 2.5
import Zabaat.Material 1.0
ZSkin {
    id : rootObject
    color : graphical.fill_Default
    border.color: graphical.borderColor
    anchors.centerIn: parent

    onLogicChanged : if(logic) {

                     }


    Item {
        id : gui
        objectName : "ZSwipeView.skin"
        anchors.fill: parent


        ListView {
            id : lvHeader
            width      : parent.width
            height     : rootObject.delegateHeaderHeight
            orientation: ListView.Horizontal

            MouseArea {
                id : lvHeader_MsArea
                propagateComposedEvents: true
                preventStealing: false
                anchors.fill: parent

            }
        }

        ListView {
            id : lvContent
            width : parent.width
            height : parent.height - lvHeader.height

        }


    }

    Item  {
        id : defComponents

        Component {
            id : defaultHeader
            Rectangle {

            }
        }




    }



    states : ({
        "default" : { "rootObject" : { "border.width" : 0,



                                     }


         }



    })



//    property var delegateHeader      : defaultHeader
//    property int delegateHeaderSize  : height * 0.1

//    property alias lv          : lvContent
//    property alias currentIndex: lvContent.currentIndex
//    property alias moveSpeed   : lvContent.highlightMoveVelocity
//    property alias count       : lvContent.count
//    property int   newTabBehavior : 0   //0 = don't move currentIndex,//1 = move to lastest, //2 = move to first entry
//    property string state: "top"    //header is on top.


}
