//A little different, this is supposed to be loaded into ZComponentToast
import QtQuick 2.5
import Zabaat.Material 1.0
import Zabaat.Base 1.0
Item {
    id: instance
    objectName: "ZButtonMenu"
    signal requestDestruction();
    property var model
    property var pos

    property bool  hasInit : model && pos ? true : false;


    property string menuItemState
    property var  menuSortFn
    property real menuItemWidth : menuItemHeight * 3
    property real menuItemHeight: 40

    onMenuSortFnChanged: {
        instance.assignModel();
        instance.determinePosition();
    }
    onModelChanged:  {
        instance.assignModel();
        instance.determinePosition();
    }
    onWidthChanged : if(instance.hasInit) instance.determinePosition();
    onHeightChanged: if(instance.hasInit) instance.determinePosition();
    onPosChanged   : instance.determinePosition();
    Connections{
        target                  : instance && instance.parent ? instance.parent : null;
        onWidthChanged          : if(instance.hasInit) instance.determinePosition();
        onHeightChanged         : if(instance.hasInit) instance.determinePosition();
    }

    function assignModel(){
        if(!model)
            return false;

        var arr = Lodash.keys(model);
        if(Lodash.isFunction(menuSortFn))
            arr.sort(menuSortFn);

        lv.model = arr;
        return true;
    }

    function determinePosition(){ //Determine position of the menu!
        if(!pos)
            return;
        //clear anchors
        lv.anchors.left = lv.anchors.top = lv.anchors.bottom = lv.anchors.right = undefined;

        //set w,h
        lv.height = Math.min(instance.height * 0.75 , lv.model.length * menuItemHeight);

        //X position
        if(pos.x + lv.width < instance.width) {    //its ok to be in the left
            lv.anchors.left = instance.left
            lv.anchors.leftMargin = pos.x
//                    ds.offset.x = sLen
        }
        else {  //otherwise it should be on the right
            lv.anchors.right = instance.right
            lv.anchors.rightMargin = instance.width - pos.x;
//                    ds.offset.x = -sLen
        }

        //Y position
        if(pos.y + lv.height < instance.height){
            lv.anchors.top = instance.top
            lv.anchors.topMargin = pos.y;
            sc.origin.y = 0;
//                    ds.offset.y = sLen
        }
        else {
            lv.anchors.bottom       = instance.bottom
            lv.anchors.bottomMargin = instance.height - pos.y;
            sc.origin.y = lv.height;
        }
    }

    Component.onCompleted: {
        assignModel();
        determinePosition();
    }


    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.AllButtons
        propagateComposedEvents: true
        onPressed: mouse.accepted = false;
        onReleased: mouse.accepted = false;
        onPressedChanged: if(!pressed){ //is released
                            animClose.closeEmpty();
                          }
    }

    ListView {
        id : lv
        width  : menuItemWidth
        delegate: ZButton {
            id : lvInstance
            width : menuItemWidth
            height : menuItemHeight
            state : Lodash.isObject(v) && Lodash.isString(v.state)? v.state : menuItemState
            property string icon : Lodash.isObject(v) && Lodash.isString(v.icon)? v.icon + " " : ""
            property var v : instance.model[modelData];
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
            onStopped: sc.yScale = 1;
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
                sc.yScale = 0;
                instance.requestDestruction();
                if(Lodash.isFunction(fn)) {
                    fn();
                }
                fn = null;
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
}

