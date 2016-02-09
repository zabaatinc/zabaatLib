import QtQuick 2.0
import Zabaat.Material 1.0
Item {
    id : rootObject

    signal accepted(string name, string oldName);
    signal rightClicked(var self, int x, int y);
    signal leftClicked(var self , int x, int y);
    signal transitionRightClicked(var transition, int x, int y)
    signal actionsClicked(var self, int x, int y);

    signal transitionsUpdated(string  type);
    signal actionsUpdated    (string  type);
    onTransitionsUpdated: transitions.len = transitions.children.length;

    property alias name    : text.text;
    property alias oldName : text.oldName;
    property alias transitions : transitions;
    property alias actions : actions;
    property var vFunc   : null
    property alias logic : logic
    property alias mode  : logic.mode

    onActiveFocusChanged: if(activeFocus)
                              text.forceActiveFocus()


    property color color : Colors.info

    function getJSON() {
        return { name : name , actions : actions.getJSON(), transitions : transitions.getJSON() }
    }

    QtObject {
        id : logic
        property int mode : 0
        property alias transitions : transitions
        property alias actions     : actions


        function addTransition(dest) {
            var obj         = transitionFactory.createObject(transitions)
            obj.origin      = rootObject
            obj.destination = dest
            return obj;
        }

        function addAction(name, rules){   //stays the same!
              var obj = { }
              obj.name = name ? name : "unnamed"
              obj.rules = rules ? rules : []

              actions.append(obj)
              return actions.get(actions.count - 1)
        }


    }


    Item {
        id : transitions
        focus : false
        anchors.fill: parent
        property int len : 0
        function getJSON(){
            var arr = []
            for(var i = 0; i < children.length; i++) {
                var item = children[i]
                arr.push(item.getJSON())
            }
            return arr;
        }
    }
    ListModel {
        id : actions;
        dynamicRoles: true;
        onRowsInserted: rootObject.actionsUpdated("added")
        onRowsRemoved : rootObject.actionsUpdated("removed")
        function getJSON(){
            var arr = []
            for(var i = 0; i < count; i++) {
                var item = get(i)
                var obj = {}
                obj.name = item.name
                obj.rules = toArray(item.rules)


                arr.push(obj)
            }
            return arr;
        }
        function toArray(lm){
            var arr = []
            for(var i = 0; i < lm.count; i++){
                var item = lm.get(i)
                var obj = {name:item.name, choices:item.choices, isRequired:item.isRequired, type:item.type}
                arr.push(obj)
            }
            return arr
        }
    }



    property Component transitionFactory : Component {
        id : transitionFactory
        StateTransition {
            id : trans
            onRightClicked: rootObject.transitionRightClicked(self,x,y)
            Component.onDestruction: rootObject.transitionsUpdated("deleted")
            Component.onCompleted: rootObject.transitionsUpdated("added")
        }
    }
//    property Component actionFactory : Component {
//        id : actionFactory
//        StateAction {
//            id : sa
//            Component.onDestruction: rootObject.actionsUpdated("deleted")
//            Component.onCompleted  : rootObject.actionsUpdated("added")
//        }
//    }


    Rectangle {
        id : background
        anchors.fill: parent
        opacity     : 0.6
        color       : rootObject.color
        border.width: 1
        radius      : height / 16
        focus : false

        SequentialAnimation on color {
            id      : colorAnim
            loops   : Animation.Infinite
            running : logic.mode !== 0 && rootObject.enabled && !restart

            property color color    : rootObject.color
            property color endColor : Colors.getContrastingColor(color)
            property bool  restart  : false;

            ColorAnimation {
                from    : colorAnim.color
                to      : colorAnim.endColor
                duration: 333
            }
            ColorAnimation {
                from    : colorAnim.endColor
                to      : colorAnim.color
                duration: 333
            }
            onStopped: background.color = rootObject.color
        }

    }
    ZTextBox {
        id    : text
        label : "State"


        property string oldName : ""
        onInputChanged: if(acceptable && text !== oldName) {
                            rootObject.accepted(text, oldName)
                        }

        anchors.centerIn: parent
        width           : parent.width * 0.9
        height          : parent.height * 0.9
        validationFunc  : vFunc
        focus           : true
    }
    MouseArea {
        id : leftClickDetector
        anchors.fill           : parent
        drag.target            : logic.mode === 0 ? rootObject : null
        propagateComposedEvents: logic.mode === 0 ? true : false
        hoverEnabled           : logic.mode !== 0 ? true : false
        onEntered              : if(logic.mode !== 0) {colorAnim.restart = true; colorAnim.color = Colors.warning  ; colorAnim.restart = false;  }
        onExited               : if(logic.mode !== 0) {colorAnim.restart = true; colorAnim.color = rootObject.color; colorAnim.restart = false;  }


        onClicked              : {
            if(logic.mode !== 0) {
                rootObject.leftClicked(rootObject,mouseX,mouseY)
            }
            else
                mouse.accepted = false;
        }
        focus : false
    }
    MouseArea {
        id                     : rightClickDetector
        anchors.fill           : parent
        drag.target            : rootObject
        acceptedButtons        : Qt.RightButton
        onClicked              : rootObject.rightClicked(rootObject,mouseX,mouseY)
        enabled : logic.mode === 0
        focus : false
    }
    Rectangle {
        anchors.right: parent.right
        anchors.top: parent.top
        width : height
        radius: height/2
        height : parent.height * 0.4

        Text {
            anchors.fill: parent
            font.family: Fonts.font1
            font.pixelSize: parent.height * 1/2
            text : actions.count
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
        border.width: 1

        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered : parent.scale = 1.1
            onExited : parent.scale = 1
            onClicked : rootObject.actionsClicked(rootObject,mouseX,mouseY)
        }
    }


//    Text {
//        anchors.top : parent.bottom
//        text : Math.floor(parent.x) + "," + Math.floor(parent.y)
//        font.pixelSize: parent.height * 1/6
//    }


//    Text {
//        anchors.top : parent.bottom
//        text : parent.width + "," + parent.height
//        font.pixelSize: parent.height * 1/6
//        anchors.right: parent.right
//    }



}
