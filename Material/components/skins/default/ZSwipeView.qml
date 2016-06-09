import QtQuick 2.5
import Zabaat.Material 1.0
ZSkin {
    id : rootObject
    color : graphical.fill_Default
    border.color: graphical.borderColor
    anchors.centerIn: parent

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
        property real   cellHeight   : 0.1
        property int    moveDuration : 300
        property string state        : "top"
        property bool vertical       : false;
        property bool headerFill     : false;
        property bool headerVisible  : true;
        property bool headerLocked   : false;
        property bool interactive    : true;

        readonly property var kidnappedElems : logic ? logic.items : null
        property int len                     : logic ? logic.count : 0
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
            width      : visible ? gui.width                          : 0
            height     : visible ? gui.height * (guiLogic.cellHeight) : 0
            orientation: isHorizontal ? ListView.Horizontal : ListView.Vertical
            visible    : guiLogic.headerVisible ? true : false

            property bool isHorizontal: guiLogic.state == 'top' || guiLogic.state == 'bottom' || guiLogic.state == ""
            property bool noSignals: false
            z : 999

            readonly property alias ss : guiLogic.state
            onSsChanged          : refreshView()
            Component.onCompleted: refreshView()
            interactive          : !guiLogic.headerFill && !guiLogic.headerLocked


            onVisibleChanged: {
                if(!visible)
                    width = height = 0;
                else
                    refreshView()
            }

            function refreshView(){
                switch(ss){
                    case "bottom" : anchors.top    = undefined
                                    anchors.left   = gui.left
                                    anchors.bottom = gui.bottom
                                    anchors.right  = undefined
                                    if(lvHeader.visible){
                                        width  = Qt.binding(function() { return gui.width })
                                        height = Qt.binding(function() { return gui.height * (guiLogic.cellHeight) } )
                                    }
                                    else {
                                        width = height = 0;
                                    }
                                    break;
                    case "left" :   anchors.top    = gui.top
                                    anchors.left   = gui.left
                                    anchors.bottom = undefined
                                    anchors.right  = undefined
                                    if(lvHeader.visible){
                                        width = Qt.binding(function() { return gui.width * (guiLogic.cellHeight) })
                                        height = Qt.binding(function() { return gui.height})
                                    }
                                    else {
                                        width = height = 0;
                                    }
                                    break;
                    case "right" :  anchors.top    = gui.top
                                    anchors.left   = undefined
                                    anchors.bottom = undefined
                                    anchors.right  = gui.right
                                    if(lvHeader.visible){
                                        width = Qt.binding(function() { return gui.width * ( guiLogic.cellHeight) })
                                        height = Qt.binding(function() { return gui.height})
                                    }
                                    else {
                                        width = height = 0;
                                    }
                                    break;
                    default      :  anchors.top    = gui.top
                                    anchors.left   = gui.left
                                    anchors.bottom = undefined
                                    anchors.right  = undefined
                                    if(lvHeader.visible){
                                        width  = Qt.binding(function() { return gui.width })
                                        height = Qt.binding(function() { return gui.height * ( guiLogic.cellHeight) } )
                                    }
                                    else {
                                        width = height = 0;
                                    }
                                    break;
                }
            }

            function delegateInstanceAt(idx){
                for(var i =0; i < contentItem.children.length; ++i) {
                    var child = contentItem.children[i]
                    if(child.imADelegate && child._index === idx)
                        return child;
                }
                return null;
            }

            property point fillPx: Qt.point(width / guiLogic.len, height / guiLogic.len)



            highlightMoveDuration: guiLogic.moveDuration  * 1.5
            onCurrentIndexChanged : {
                if(!noSignals){
                    if(lvContent.currentIndex !== currentIndex){
                        lvContent.currentIndex = currentIndex
                    }
                    if(logic ) {
                        logic.currentIndex = currentIndex
                    }
                }
//                console.log("CurrentIndex", currentIndex)
            }

            model    : guiLogic.kidnappedElems
            delegate : Loader {
                id : lvHeaderLoader
                width   : sz.x
                height  : sz.y

                property point sz : {
                    var w, h
                    if(lvHeader.isHorizontal){
                        w = guiLogic.headerFill ? lvHeader.fillPx.x :
                                                  fill ? lvHeader.width * fill : lvHeader.height * 2.5
                        h = lvHeader.height
                    }
                    else {
                        w = lvHeader.width
                        h = guiLogic.headerFill ? lvHeader.fillPx.y :
                                                  fill ? lvHeader.height * fill : lvHeader.width * 1.5
                    }
                    return Qt.point(w,h)
                }

                property var myItem :  logic && logic.items ? logic.items[index] : null
                property var fill : myItem && myItem.fill !== null && typeof myItem.fill !== 'undefined' ? myItem.fill : null
                property bool imADelegate : true
                property int _index : index

                property bool hasOnClickHandler : false

                sourceComponent: !visible ? null :
                                            (logic && logic.headerDelegate ? logic.headerDelegate :  defaultHeader )
                onLoaded : {
                    if(item){
                        item.anchors.fill = lvHeaderLoader
                        if(guiLogic.kidnappedElems.length > index) {
                            var myItem = guiLogic.kidnappedElems[index]
                            if(item.hasOwnProperty('title'))
                                item.title = Qt.binding(function() { return myItem && myItem.title ? myItem.title : "" })
                            else if(item.hasOwnProperty('text'))
                                item.text = Qt.binding(function() { return myItem && myItem.title ? myItem.title : "" })
                            if(item.hasOwnProperty('index'))
                                item.index = Qt.binding(function() { return lvHeaderLoader._index })

                            if(typeof item.clicked === 'function') {
                                item.clicked.connect(function(){
                                    if(lvHeader && index !== null && typeof index !== 'undefined'){
                                        lvHeader.currentIndex = index;
                                    }
                                    else
                                        console.error("NO index!")
                                })
//                                console.log("CONNECTED")
                                lvHeaderLoader.hasOnClickHandler = true;
                            }
                        }
                    }
                }
            }
            highlightFollowsCurrentItem : true
            highlight: Loader {
                id : lvHeaderHighlightLoader
//                x : lvHeader.currentItem ? lvHeader.currentItem.x : 0
//                y : lvHeader.currentItem ? lvHeader.currentItem.y : 0
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
                property bool isPressed : false

                onPressed: {
                    isPressed = true;
                    mouse.accepted = false;
                }
                onReleased : {
                    isPressed = false;
                    mouse.accepted = false;
                }

                onPressedChanged : isPressed = pressed;
                onIsPressedChanged:  if(!isPressed) {   //same as is released!
                    var idx = lvHeader.isHorizontal ? lvHeader.indexAt(lvHeader.contentX + mouseX, mouseY) :
                                                      lvHeader.indexAt(mouseX, lvHeader.contentY + mouseY)
//                    console.log(idx)
                    if(idx !== -1){
                        var item = lvHeader.delegateInstanceAt(idx);
                        if(!item || !item.hasOnClickHandler) {
                            lvHeader.currentIndex= idx;
//                            mouse.accepted = true;
                        }
                        else {
                            //else do nothing!
//                            mouse.accepted = false;
                        }
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
            interactive : guiLogic.interactive

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
//            highlightMoveVelocity: 1500
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
                clip : true

                Component.onCompleted: {
                    if(guiLogic.kidnappedElems.length > index) {
                        myItem = guiLogic.kidnappedElems[index]
                        if(myItem){
                            myItem.anchors.fill = myItem.parent = lvContentDelegate;
                        }
                    }
                    else
                        console.log("ZSwipeViewSkin::lvContentDelegate::err CHECK FAILED", guiLogic.len , "<=" , index)
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
                                        "headerFill" : false,
                                        "headerVisible" : true ,
                                        "headerLocked" : false,
                                        "cellHeight"    : 0.1,
                                        "interactive" : true
                                     }
                  } ,
        "headerfill": { "guiLogic" : { "headerFill" : true  } } ,
        "notabs"    : { "guiLogic" : { "headerVisible" : false   }  } ,
        "noheaders" : { "guiLogic" : { "headerVisible" : false   }  } ,
        "locked"    : { "guiLogic" : { "interactive"  : false   }  } ,
        "unlocked"  : { "guiLogic" : { "interactive"  : true   }  } ,
        "headerlocked"    : { "guiLogic" : { "headerLocked"  : true   }  } ,
        "headerunlocked"    : { "guiLogic" : { "headerLocked"  : false   }  } ,
        "headers"   : { "guiLogic" : { "headerVisible" : true   }  } ,
        "tabs"      : { "guiLogic" : { "headerVisible" : true   }  } ,


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
        "left"     : { "guiLogic" : { "state" : "left"   }  } ,
        "right"    : { "guiLogic" : { "state" : "right"   }  } ,
        "top"      : { "guiLogic" : { "state" : "top"   }  } ,
        "bottom"   : { "guiLogic" : { "state" : "bottom"   }  } ,
        "vertical" : { "guiLogic" : { "vertical" : true   }  } ,
        "fill"     : { "guiLogic" : { "headerFill" : true   }  } ,
        "nofill"   : { "guiLogic" : { "headerFill" : false   }  } ,
        "superslow": { "guiLogic" : { "moveDuration" : 3000   }  } ,
        "veryslow" : { "guiLogic" : { "moveDuration" : 1000   }  } ,
        "slow"     : { "guiLogic" : { "moveDuration" : 500    }  } ,
        "fast"     : { "guiLogic" : { "moveDuration" : 200    }  } ,
        "veryfast" : { "guiLogic" : { "moveDuration" : 100    }  } ,
        "superfast": { "guiLogic" : { "moveDuration" : 10     }  } ,
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
