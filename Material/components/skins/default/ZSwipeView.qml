import QtQuick 2.5
import Zabaat.Material 1.0
ZSkin {
    id : rootObject
    color : graphical.fill_Default
    border.color: graphical.borderColor
    anchors.centerIn: parent

    onLogicChanged : if(logic)
                         logic.count = guiLogic.len;

    property alias guiLogic : guiLogic

    Connections {
        target : logic ? logic : null
        onCurrentIndexChanged : {
            if(logic.currentIndex !== lvHeader.currentIndex){
                if(lvHeader.noSignals)
                    guiLogic.oldIdx = logic.currentIndex
                else
                    lvHeader.currentIndex = logic.currentIndex

            }
        }
        onItemsAdded : guiLogic.handleAdd(items,startIdx,endIdx,count)
        onItemRemoved : guiLogic.handleRemove(idx)
    }

    QtObject {
        id : guiLogic
        property real   cellHeight   : 1
        property int    moveDuration : 300
        property string state        : "top"
        property bool vertical       : false;
        property bool headerFill     : false;

        readonly property var kidnappedElems : logic ? logic.items : null
        readonly property int len            : logic ? logic.count : 0
        property int oldIdx                  : -1;

        function handleRemove(){
            lvHeader.noSignals = true;

            lvHeader.model        = lvContent.model = null;
            lvHeader.model        = lvContent.model = kidnappedElems;
            lvHeader.currentIndex = lvContent.currentIndex = logic.currentIndex

            lvHeader.noSignals = false;
        }

        function handleAdd(items,start,end,count) {
            oldIdx     = oldIdx === -1 && len > 0 ? 0 : lvHeader.currentIndex

            lvHeader.noSignals = true;

            lvHeader.model        = lvContent.model = null;
            lvHeader.model        = lvContent.model = kidnappedElems;
            lvHeader.currentIndex = lvContent.currentIndex = oldIdx

            lvHeader.noSignals = false;

            if(logic && logic.currentIndex === -1) {
                logic.currentIndex = lvHeader.currentIndex
            }
        }
    }



    Item {
        id : gui
        objectName  : "ZSwipeView.skin"
        anchors.fill: parent


        ListView {
            id : lvHeader
            width      : gui.width
            height     : gui.height * (0.1 * guiLogic.cellHeight)
            orientation: isHorizontal ? ListView.Horizontal : ListView.Vertical
            property bool isHorizontal: guiLogic.state == 'top' || guiLogic.state == 'bottom' || guiLogic.state == ""
            property bool noSignals: false
            z : 999

            readonly property alias ss : guiLogic.state
            onSsChanged          : refreshView()
            Component.onCompleted: refreshView()
            interactive: !guiLogic.headerFill

            function refreshView(){
                switch(ss){
                    case "bottom" : anchors.top    = undefined
                                    anchors.left   = gui.left
                                    anchors.bottom = gui.bottom
                                    anchors.right  = undefined
                                    width  = Qt.binding(function() { return gui.width })
                                    height = Qt.binding(function() { return gui.height * (0.1 * guiLogic.cellHeight) } )

                                    break;
                    case "left" :   anchors.top    = gui.top
                                    anchors.left   = gui.left
                                    anchors.bottom = undefined
                                    anchors.right  = undefined
                                    width = Qt.binding(function() { return gui.width * (0.05 * guiLogic.cellHeight) })
                                    height = Qt.binding(function() { return gui.height})
                                    break;
                    case "right" :  anchors.top    = gui.top
                                    anchors.left   = undefined
                                    anchors.bottom = undefined
                                    anchors.right  = gui.right
                                    width = Qt.binding(function() { return gui.width * (0.05 * guiLogic.cellHeight) })
                                    height = Qt.binding(function() { return gui.height})
                                    break;
                    default      :  anchors.top    = gui.top
                                    anchors.left   = gui.left
                                    anchors.bottom = undefined
                                    anchors.right  = undefined
                                    width  = Qt.binding(function() { return gui.width })
                                    height = Qt.binding(function() { return gui.height * (0.1 * guiLogic.cellHeight) } )
                                    break;
                }
            }

            property point fillPx: Qt.point(width / guiLogic.len, height / guiLogic.len)



            highlightMoveDuration: guiLogic.moveDuration  * 1.5
            onCurrentIndexChanged : if(!noSignals){
                if(lvContent.currentIndex !== currentIndex){
                    lvContent.currentIndex = currentIndex
                }
                if(logic ) {
                    logic.currentIndex = currentIndex
                }
            }

            model    : guiLogic.kidnappedElems
            delegate : Loader {
                id : lvHeaderLoader
                width   : sz.x
                height  : sz.y

                property point sz : {
                    var w, h
                    if(lvHeader.isHorizontal){
                        w = guiLogic.headerFill ? lvHeader.fillPx.x : lvHeader.height * 2.5
                        h = lvHeader.height
                    }
                    else {
                        w = lvHeader.width
                        h = guiLogic.headerFill ? lvHeader.fillPx.y : lvHeader.width * 1.5
                    }
                    return Qt.point(w,h)
                }

                sourceComponent: logic && logic.headerDelegate ? logic.headerDelegate :  defaultHeader
                onLoaded : {
                    if(item){
                        item.anchors.fill = lvHeaderLoader
                        if(guiLogic.kidnappedElems.length > index) {
                            var myItem = guiLogic.kidnappedElems[index]
                            if(item.hasOwnProperty('title'))
                                item.title = Qt.binding(function() { return myItem && myItem.title ? myItem.title : "" })
                            else if(item.hasOwnProperty('text'))
                                item.text = Qt.binding(function() { return myItem && myItem.title ? myItem.title : "" })
                        }
                    }
                }
            }
            highlight: Loader {
                id : lvHeaderHighlightLoader
                x : lvHeader.currentItem ? lvHeader.currentItem.x : 0
                y : lvHeader.currentItem ? lvHeader.currentItem.y : 0
                z : lvHeader.count + 1
                width          : sz.x
                height         : sz.y

                property point sz : lvHeader.isHorizontal ? Qt.point(lvHeader.height * 2.5, lvHeader.height) :
                                                          Qt.point(lvHeader.width, lvHeader.width * 1.5)

                sourceComponent: logic && logic.highlightDelegate ?  logic.highlightDelegate : defaultHighlight
                onLoaded: {
                    if(item){
                        item.anchors.fill = lvHeaderHighlightLoader
                    }
                }

                Behavior on x     {  NumberAnimation { duration: 300 } }
            }

            MouseArea {
                id : lvHeader_MsArea
                propagateComposedEvents: true
                preventStealing: false
                anchors.fill: parent
                onClicked : {
                    var idx = lvHeader.isHorizontal ? lvHeader.indexAt(lvHeader.contentX + mouseX, mouseY) :
                                                    lvHeader.indexAt(mouseX, lvHeader.contentY + mouseY)
                    if(idx !== -1){
                         lvHeader.currentIndex= idx;
                    }
                }
            }
        }
        ListView {
            id : lvContent
            width  : gui.width
            height : gui.height - lvHeader.height
            clip : true

            readonly property alias ss : guiLogic.state
            onSsChanged          : refreshView()
            Component.onCompleted: refreshView()

            function refreshView(){
                switch(ss){
                    case "bottom" : anchors.top    = gui.top
                                    anchors.left   = gui.left
                                    anchors.bottom = undefined
                                    anchors.right  = undefined
                                    width = Qt.binding(function() { return gui.width } )
                                    height = Qt.binding(function() { return gui.height - lvHeader.height} )
                                    break;
                    case "left" :   anchors.top    = gui.top
                                    anchors.left   = undefined
                                    anchors.bottom = undefined
                                    anchors.right  = gui.right
                                    width = Qt.binding(function() { return gui.width - lvHeader.width} )
                                    height = Qt.binding(function() { return gui.height} )
                                    break;
                    case "right" :  anchors.top    = gui.top
                                    anchors.left   = gui.left
                                    anchors.bottom = undefined
                                    anchors.right  = undefined
                                    width = Qt.binding(function() { return gui.width - lvHeader.width} )
                                    height = Qt.binding(function() { return gui.height} )
                                    break;
                    default      :  anchors.top    = undefined
                                    anchors.left   = gui.left
                                    anchors.bottom = gui.bottom
                                    anchors.right  = undefined
                                    width = Qt.binding(function() { return gui.width } )
                                    height = Qt.binding(function() { return gui.height - lvHeader.height} )
                                    break;
                }
            }

            orientation  : guiLogic.vertical ? ListView.Vertical : ListView.Horizontal
//            snapMode          : ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: guiLogic.moveDuration  * 1.5
            highlightMoveVelocity: 1500
            model      : guiLogic.kidnappedElems
            onCurrentIndexChanged: {
                if(lvHeader.currentIndex !== currentIndex && !lvHeader.noSignals){
                    lvHeader.currentIndex = currentIndex
                }
            }

            delegate : Item {
                id : lvContentDelegate
                width : lvContent.width
                height : lvContent.height
                property var myItem : null

                Component.onCompleted: {
                    if(guiLogic.len > index) {
                        myItem = guiLogic.kidnappedElems[index]
                        if(myItem){
                            myItem.anchors.fill = myItem.parent = lvContentDelegate;
                        }
                    }
                    else
                        console.log("CHECK FAILED")
                }
                Component.onDestruction: {
                    if(myItem ){
                        myItem.parent = logic ? logic.container : logic;
//                        console.log("IM RETURNING", myItem, "to",  myItem.parent)
                        //so we don't kill the item!
                    }
                }
            }
        }

//        Text {
//            anchors.centerIn : parent
//            text : lvHeader.width + "," + lvHeader.height
//            font.pixelSize: parent.height * 1/20
//            z : 10000
//        }
    }

    Item  {
        id : defComponents

        Component {
            id : defaultHeader
            Rectangle {
                border.width: 1
                property alias text : dht.text
                Text {
                    id : dht
                    anchors.fill: parent
                    clip : true
                    font.pixelSize: Math.min(width,height) * 1/3
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    color : Colors.contrastingTextColor(graphical.fill_Focus)
                }
            }
        }

        Component {
            id : defaultHighlight
            Rectangle {
                opacity: 0.7
                color : graphical.fill_Focus
            }
        }

    }



    states : ({
        "default" : { "rootObject" : { "border.width" : 0   } ,
                      "guiLogic"   : {
                                        "moveDuration" : 300,
                                        "state" : "top",
                                        "vertical" : false ,
                                        "headerFill" : false
                                     }
                  } ,
        "left"     : { "guiLogic" : { "state" : "left"   }  } ,
        "right"    : { "guiLogic" : { "state" : "right"   }  } ,
        "top"      : { "guiLogic" : { "state" : "top"   }  } ,
        "bottom"   : { "guiLogic" : { "state" : "bottom"   }  } ,
        "vertical" : { "guiLogic" : { "vertical" : true   }  } ,
        "fill"     : { "guiLogic" : { "headerFill" : true   }  } ,
        "nofill"   : { "guiLogic" : { "headerFill" : false   }  } ,
        "veryslow" : { "guiLogic" : { "moveDuration" : 1000   }  } ,
        "slow"     : { "guiLogic" : { "moveDuration" : 500    }  } ,
        "fast"     : { "guiLogic" : { "moveDuration" : 150    }  } ,
        "veryfast" : { "guiLogic" : { "moveDuration" : 50     }  } ,
        "instant"  : { "guiLogic" : { "moveDuration" : 0      }  }



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
