import QtQuick 2.5
import QtQuick.Window 2.0
import Zabaat.Material 1.0
import Zabaat.Base 1.0
import QtGraphicalEffects 1.0
Item {
    id : rootObject
    property real   menuItemWidth  : 400
    property real   menuItemHeight : height;
    property string menuItemState  : mainBtn.state
    property alias  text      : mainBtn.text
    property var    menuObj   : ({ item1 : function() { console.log('item1') },
                                   item2 : function() { console.log('item2') },
                                   item3 : function() { console.log('item3') },
                                   item4 : function() { console.log('item4') },
                                })
    property var menuSortFn //allows us to sort the menuItems based on Keys
    property alias state : mainBtn.state


    QtObject {
        id : logic
        property bool menuOpen: false
        signal killmenu();
        function createDropdown(){
            return Promises.promise(function(resolve,reject) {
                var toast = Toasts.createComponentPermanent(menuComponent, null, null, 1,1);
                toast.Component.destruction.connect(resolve)
                menuOpen = true;
            }).then(function(val){ if(Lodash.isFunction(val)) val() })
            .finally(function(){ menuOpen = false })
        }
    }

    ZButton {
        id : mainBtn
        width : rootObject.width
        height : rootObject.height
        text : FAR.list
        state : 'accent-f3-t2'
        onClicked: !logic.menuOpen ? logic.createDropdown() : logic.killmenu();
    }


    Component {
        id : menuComponent
        Item {
            id: menuInstance
            signal requestDestruction();
            property point pos : Qt.point(0,0);
            property bool hasInit : false;
//            property real sLen : 3;
            onWidthChanged: if(menuInstance.hasInit) menuInstance.determinePosition();
            onHeightChanged: if(menuInstance.hasInit) menuInstance.determinePosition();
            Connections{
                target : rootObject ? rootObject : null;
                onWidthChanged : if(menuInstance.hasInit) menuInstance.determinePosition();
                onHeightChanged : if(menuInstance.hasInit) menuInstance.determinePosition();
                onMenuItemWidthChanged : if(menuInstance.hasInit) menuInstance.determinePosition();
                onMenuItemHeightChanged : if(menuInstance.hasInit) menuInstance.determinePosition();
                onMenuSortFnChanged : menuInstance.assignModel();
                onMenuObjChanged : {
                    menuInstance.assignModel();
                    menuInstance.determinePosition();
                }
            }
            Connections {
                target : logic
                onKillmenu : if(!animClose.running)
                                 animClose.closeEmpty();
            }


            function assignModel(){
                var arr = Lodash.keys(menuObj);
                if(Lodash.isFunction(menuSortFn))
                    arr.sort(menuSortFn);

                lv.model = arr;
            }

            function determinePosition(){ //Determine position of the menu!
                //clear anchors
                lv.anchors.left = lv.anchors.top = lv.anchors.bottom = lv.anchors.right = undefined;

                //set w,h
                lv.height = Math.min(menuInstance.height * 0.75 , lv.model.length * menuItemHeight);
                pos = mainBtn.mapToItem(menuInstance,0,mainBtn.height);

                //X position
                if(pos.x + lv.width < menuInstance.width) {    //its ok to be in the left
                    lv.anchors.left = menuInstance.left
                    lv.anchors.leftMargin = pos.x
//                    ds.offset.x = sLen
                }
                else {  //otherwise it should be on the right
                    lv.anchors.right = menuInstance.right
                    lv.anchors.rightMargin = menuInstance.width - mainBtn.width - pos.x;
//                    ds.offset.x = -sLen
                }

                //Y position
                if(pos.y + lv.height < menuInstance.height){
                    lv.anchors.top = menuInstance.top
                    lv.anchors.topMargin = pos.y;
                    sc.origin.y = 0;
//                    ds.offset.y = sLen
                }
                else {
                    lv.anchors.bottom       = menuInstance.bottom
                    lv.anchors.bottomMargin = menuInstance.height + mainBtn.height - pos.y;
                    sc.origin.y = lv.height;
//                    ds.offset.y = -sLen
                }
            }

            Component.onCompleted: {
                assignModel();
                determinePosition();
                hasInit = true;
            }


            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onPressed: mouse.accepted = false;
                onReleased: mouse.accepted = false;
                onPressedChanged: if(!pressed){ //is released
//                                    console.log(mainBtn, menuInstance, mainBtn.mapToItem);
                                    var btn = mainBtn.mapToItem(menuInstance,0,0);
                                    //ignore clicks on the btn that is responsible for this menu!!!
                                    if(mouseX >= btn.x && mouseX <= btn.x + mainBtn.width &&
                                       mouseY >= btn.y && mouseY <= btn.y + mainBtn.height ){
                                        return;
                                    }

                                    animClose.closeEmpty();
                                  }
            }

            ListView {
                id : lv
                width : menuItemWidth
                model : 4
                delegate: ZButton {
                    id : lvInstance
                    width : menuItemWidth
                    height : menuItemHeight
                    state : Lodash.isObject(v) && Lodash.isString(v.state)? v.state : menuItemState
                    property string icon : Lodash.isObject(v) && Lodash.isString(v.icon)? v.icon + " " : ""
                    property var v : menuObj[modelData];
                    text : modelData
                    onClicked : {
                        if(!animOpen.running && !animClose.running){
                            var fn = Lodash.isFunction(v) ? v : Lodash.isObject(v) && Lodash.isFunction(v.fn) ? v.fn : null;
                            animClose.closeWith(fn);
                        }
                    }
                    ZText {
                        anchors.fill: parent
                        anchors.margins: 5
                        state : parent.state + "-transparent-tleft"
                        text : parent.icon
                        visible : parent.icon
                    }
                }
                transform: Scale { id : sc  }
                interactive: height < contentItem.height
                NumberAnimation {
                    id : animOpen
                    target : sc
                    properties: "yScale"
                    from : 0
                    to : 1
                    duration : 150
                    Component.onCompleted: start();
                }
                NumberAnimation {
                    id : animClose
                    target : sc
                    properties: "yScale"
                    from : 1
                    to : 0
                    duration : 75
                    property var fn
                    onStopped: {
                        menuInstance.requestDestruction(undefined);
                        if(Lodash.isFunction(fn))
                            fn();
                        fn= null;
                    }
                    function closeWith(fn){
                        animClose.fn = fn;
                        start();
                    }
                    function closeEmpty(){
                        animClose.fn = null;
                        start();
                    }
                }
            }

//            DropShadow {
//                id : ds
//                anchors.fill: lv
//                source : lv
//                color : 'black'
//                spread: 0
//                property point offset: Qt.point(3,3);
//                horizontalOffset: offset.x;
//                verticalOffset: offset.y;
//                radius: 8
//                samples : radius * 2 + 1;
//            }
        }
    }


}
