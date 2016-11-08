import QtQuick 2.5
import Zabaat.Base 1.0
import Zabaat.Material 1.0
Rectangle {
    id : rootObject
    onChildrenChanged: logic.reparentChildren();
    property string buttonState     : "f3-b1-accent-rounded"
    property string backIcon        : FAR.chevron_circle_left
    property string backButtonState : buttonState
    property alias  spacing         : lv.spacing
    property int    animDuration    : 250
    property alias  alignment       : lv.alignment
    property alias  snapToRight     : container.snapToRight;

    QtObject {
        id : logic
        property bool mutex  : false;
        property alias model : lv.model;
        property var   map   : ({})

        function childrenNames(object) {
            var names = [];
            Lodash.each(object.children, function(v) {
                var name = getValue(v,"icon","name","title","objectName");
                if(!name)
                    name = v.toString();
                names.push(name)
            })
            return names;
        }

        function reparentChildren() {
            if(mutex)
                return;

            console.log("proceeding:", childrenNames(rootObject))
            mutex = true;
            Lodash.eachRight(rootObject.children, function(v) {
                if(v !== gui) {
                    v.parent = container;
                    v.anchors.fill = container;
                    v.visible = false;
                }
            })

            updateModel();
            return mutex = false;
        }
        function updateModel() {
            var newModel = [];
            var newMap   = {};
            Lodash.each(container.children, function(v,k){
                var icon = getValue(v,"icon","name","title","objectName");
                if(!icon)
                    return;

                var modelEntry =  { icon : icon }

                var state = getValue(v,"state");
                if(state) {
                    modelEntry.state = state;
                }

                newModel.push(modelEntry);
                newMap[icon] = v;
            })

            map = newMap;
            model = newModel;
        }

        function getValue(obj){
            var args = Array.prototype.slice.call(arguments,1);
            for(var a in args){
                var key = args[a];
                if(obj.hasOwnProperty(key))
                    return obj[key];
            }
            return null;
        }

    }

    Item {
        id : gui
        anchors.fill: parent
        objectName: "gui"
        clip : true
        ListView {
            id : lv
            objectName: "lv"
            orientation: ListView.Horizontal
            anchors.rightMargin: 5
            anchors.leftMargin: 5

            property int alignment : Text.AlignHCenter
            anchors.horizontalCenter: gui.horizontalCenter
            onAlignmentChanged: {
                lv.anchors.horizontalCenter = null;
                lv.anchors.left = undefined;
                lv.anchors.right = undefined;

                if(alignment === Text.AlignHCenter) {
                    console.log("HCENTER")
                    lv.anchors.horizontalCenter = gui.horizontalCenter;
                }
                else if(alignment === Text.AlignRight) {
                    console.log("RIGHT")
                    lv.anchors.right = gui.right;
                }
                else {
                    console.log("LEFT")
                    lv.achors.left = gui.left;
                }
            }

            width  : height * count + (spacing * (count-1));
            height : parent.height
            spacing : 5
            model : []
            onCountChanged: console.log('count', count)
            delegate: ZButton{
                id : delInstance
                width  : height;
                height : lv.height;
                property var m : modelData;
                state :m && m.state !== undefined ? m.state : buttonState
                text : m && m.icon ? m.icon : "?"

                onClicked: {
                    var pt = delInstance.mapToItem(gui,0,0);
                    hackBtn.show(pt, text, state);
                }
            }
        }

        ZButton {
            id : hackBtn
            height :parent.height
            width : height;
            visible : false;
            disableShowsGraphically: false;
            onClicked: exit.start();

            property point  storedPos;
            property string storedIcon;
            property string storedState;

            function show(pos, icon, state) {
                if(state === buttonState) {
                    this.state = backButtonState;
                }
                else {
                    this.state = state;
                }

                //store these so we can hide them.
                storedIcon  = text = icon;
                storedPos   = pos;
                storedState = state;

                //set up variables before we show
                x = pos.x;
                y = pos.y;
                visible = true;
                enabled = false;    //enable when animation finishes
                entrance.start();
            }


            NumberAnimation {
                id : entrance
                target : hackBtn
                properties: "x";
                to : !snapToRight ? 0 : rootObject.width - hackBtn.width;
                duration : animDuration;
                onStarted: {
                    lv.visible = false;
                    logic.map[hackBtn.storedIcon].visible = true;
                }

                onStopped: {
                    hackBtn.x = !snapToRight ? 0 : rootObject.width - hackBtn.width;
                    hackBtn.text = backIcon;
                    hackBtn.enabled = true;
                }
            }
            NumberAnimation {
                id : exit
                target: hackBtn
                properties: "x";
                to : hackBtn.storedPos.x;
                onStarted: {
                    hackBtn.enabled = false;
                }
                onStopped:  {
                    logic.map[hackBtn.storedIcon].visible = false;
                    hackBtn.x = hackBtn.storedPos.x;
                    hackBtn.text = "";
                    hackBtn.visible = false;
                    lv.visible = true;
                }
            }

            Item {
                id : container
                objectName: "container"
                anchors.left: parent.right
                anchors.leftMargin: 5
                anchors.rightMargin: 5
                width  : rootObject.width - parent.height;
                height : rootObject.height

                property bool snapToRight: false;

                onSnapToRightChanged: {
                    container.anchors.left = undefined;
                    container.anchors.right = undefined;
                    if(!snapToRight) {
                        container.anchors.left = parent.right
                    }
                    else {
                        container.anchors.right =  parent.left;
                    }
                }


                function hideAll() {
                    Lodash.each(children,function(v) {
                        v.visible = false
                    })
                }
            }
        }



    }




}
