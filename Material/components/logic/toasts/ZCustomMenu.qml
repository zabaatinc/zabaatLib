//A little different, this is supposed to be loaded into ZComponentToast
import QtQuick 2.5
import Zabaat.Material 1.0
import Zabaat.Base 1.0
Item {
    id: instance
    objectName: "ZButtonMenu"
    signal requestDestruction();

    property var pos
    property var cmp
    property bool warn: true
    onCmpChanged: {
        var f= function() {
            if(!cmp) {
                loader.source = "";
                loader.sourceComponent = null;
            }

             if(Lodash.isString(cmp)) {
                 loader.sourceComponent = null;
                 loader.source = cmp;
             }
             else {
                loader.source = ""
                loader.sourceComponent = cmp;
             }
        }
        f();
        //Functions.time.setTimeOut(5, f);
    }

    property alias args : loader.args
    property bool  hasInit : loader.item && pos ? true : false;

    onWidthChanged : if(instance.hasInit) instance.determinePosition();
    onHeightChanged: if(instance.hasInit) instance.determinePosition();
    onPosChanged   : instance.determinePosition();
    Component.onCompleted:  determinePosition();
    Connections{
        target                  : instance && instance.parent ? instance.parent : null;
        onWidthChanged          : if(instance.hasInit) instance.determinePosition();
        onHeightChanged         : if(instance.hasInit) instance.determinePosition();
    }

    function determinePosition(){ //Determine position of the menu!
        if(!pos)
            return;
        //clear anchors
        loader.anchors.left = loader.anchors.top = loader.anchors.bottom = loader.anchors.right = undefined;

        //set w,h
        //lv.height = Math.min(instance.height * 0.75 , lv.model.length * menuItemHeight);

        //X position
        if(pos.x + loader.width < instance.width) {    //its ok to be in the left
            loader.anchors.left = instance.left
            loader.anchors.leftMargin = pos.x
//                    ds.offset.x = sLen
        }
        else {  //otherwise it should be on the right
            loader.anchors.right = instance.right
            loader.anchors.rightMargin = instance.width - pos.x;
//                    ds.offset.x = -sLen
        }

        //Y position
        if(pos.y + loader.height < instance.height){
            loader.anchors.top = instance.top
            loader.anchors.topMargin = pos.y;
            sc.origin.y = 0;
//                    ds.offset.y = sLen
        }
        else {
            loader.anchors.bottom       = instance.bottom
            loader.anchors.bottomMargin = instance.height - pos.y;
            sc.origin.y = loader.height;
        }
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

    Loader {
        id : loader
        property var args
        width : item && item.implicitWidth  ? item.implicitWidth  : parent.width / 10
        height: item && item.implicitHeight ? item.implicitHeight : parent.height/ 20
        property point dim : Qt.point(width,height);
        onDimChanged: determinePosition();
        onArgsChanged: attachArgs();
        onLoaded:  {
            attachArgs();
            animOpen.start();
            if(Lodash.isFunction(item.requestDestruction))
                item.requestDestruction.connect(instance.requestDestruction)
            else if(warn)
                Functions.log(item, "has no requestDestruction signal!");
            item.Component.destruction.connect(instance.requestDestruction);
        }

        function attachArgs() {
            if(typeof args !== 'object' || !item)
                return;

            var getFirstPair = function (obj) {
                for(var k in obj) {
                    return {
                        key : k,
                        val : obj[k]
                    }
                }
            }
            var tryAssign = function(key,value) {
                if(item.hasOwnProperty(key))
                    try {
                        item[key] = value;
                    }
                    catch(e) {
                        Functions.log("Exception: ", e , "\nAssignemnt on", item + "." + key, "failed. Type:", toString.call(value) ,"JSON:", JSON.stringify(value));
                    }
            }
            if(typeof args === 'object') {
                if (Lodash.isArray(args)) {
                    Lodash.each(args, function(i) {
                        var pair = getFirstPair(i);
                        tryAssign(pair.key, pair.val);
                    })
                }
                else {
                    Lodash.each(args,function(v,k) {
                        tryAssign(k,v);
                    })
                }
            }
        }



        transform: Scale { id : sc  }
        NumberAnimation {
            id : animOpen
            target : sc
            properties: "yScale"
            from : 0
            to : 1
            duration : 150
            onStopped: sc.yScale = 1;
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

//    ListView {
//        id : lv
//        width  : menuItemWidth
//        delegate: ZButton {
//            id : lvInstance
//            width : menuItemWidth
//            height : menuItemHeight
//            state : Lodash.isObject(v) && Lodash.isString(v.state)? v.state : menuItemState
//            property string icon : Lodash.isObject(v) && Lodash.isString(v.icon)? v.icon + " " : ""
//            property var v : instance.model[modelData];
//            text : modelData
//            onClicked : {
//                if(!animOpen.running && !animClose.running){
//                    var fn = Lodash.isFunction(v) ? v : Lodash.isObject(v) && Lodash.isFunction(v.fn) ? v.fn : null;
//                    animClose.closeWith(fn);
//                }
//            }
//            ZText {
//                anchors.fill: parent
//                anchors.margins: 5
//                state : parent.state + "-transparent-tleft"
//                text : parent.icon
//                visible : parent.icon
//            }
//        }
//        transform: Scale { id : sc  }
//        interactive: height < contentItem.height
//        NumberAnimation {
//            id : animOpen
//            target : sc
//            properties: "yScale"
//            from : 0
//            to : 1
//            duration : 150
//            onStopped: sc.yScale = 1;
//            Component.onCompleted: start();
//        }
//        NumberAnimation {
//            id : animClose
//            target : sc
//            properties: "yScale"
//            from : 1
//            to : 0
//            duration : 75
//            property var fn
//            onStopped: {
//                sc.yScale = 0;
//                instance.requestDestruction();
//                if(Lodash.isFunction(fn)) {
//                    fn();
//                }
//                fn = null;
//            }
//            function closeWith(fn){
//                animClose.fn = fn;
//                start();
//            }
//            function closeEmpty(){
//                animClose.fn = null;
//                start();
//            }
//        }
//    }


}

