import QtQuick 2.0
import Zabaat.Material 1.0
import "../StateTransition"
import "../Functions"
Item {
    id : rootObject
    property var m                      : null       //the model
    readonly property alias name        : logic.name
    readonly property alias modelId     : logic.modelId
    property var           getStateItemFunc : null
    property alias         transitionsView : transitionsView

    signal accepted(string id, string name);
    signal rightClicked(var self, int x, int y);
    signal leftClicked(var self , int x, int y);
    signal transitionRightClicked(var transition, int x, int y)
    signal functionsClicked(var self, int x, int y);
    signal transitionsUpdated(string  type);
    signal makeDefaultClicked(string modelId, string name);

//    onTransitionsUpdated: transitionsView.len = transitionsView.children.length;
//    property alias actions : actions;
    property var vFunc   : null
    property alias logic : logic
    property alias mode  : logic.mode
    property color color : Colors.info

    onActiveFocusChanged: if(activeFocus)
                              text.forceActiveFocus()



    function getJSON() {
        return {  id          : logic.modelId ,
                  name        : logic.name ,
                  functions   : functionsView.getJSON(),
                  transitions : transitionsView.getJSON() ,
                  x : x,
                  y : y,
                  w : width,
                  h : height
               }
    }

    QtObject {
        id : logic
        property int mode : 0
        property string modelId    : m && m.id          ? m.id          : ""
        property string name       : m && m.name        ? m.name        : ""
        property var   transitions : m && m.transitions ? m.transitions : null
        property var   functions   : m && m.functions   ? m.functions   : null
        property bool  isDefault   : m && m.isDefault   ? m.isDefault   : false
//        property alias transitions : transitionsView
        property alias actions     : functionsView


        function addAction(name, rules){   //stays the same!
              var obj = { }
              obj.name = name ? name : "unnamed"
              obj.rules = rules ? rules : []

              functionsView.append(obj)
              return functionsView.get(functionsView.count - 1)
        }
    }


//    clip : true
    ListView {
        id : functionsView
        anchors.top: parent.bottom
        anchors.topMargin: height/10
        height : 16
        width  : parent.width
        model  : logic.functions
        orientation: ListView.Horizontal
        spacing : height/8

        function getJSON(){
            var arr = []
            for(var i = 0; i < count; i++) {
                var item = logic.functions.get(i)
                var obj = {}
                obj.name = item.name
                obj.rules = GFuncs.toArray(item.rules)
                arr.push(obj)
            }
            return arr;
        }

        delegate : Rectangle{
            width : functionsView.height
            height : width
            color : GFuncs.colorhashFunc(name)
            border.width: 1
        }
    }
    Repeater {
        id          : transitionsView
        anchors.fill: parent
        model       : logic.transitions ? logic.transitions : null


        function getJSON(){
            var arr = []
            for(var i = 0; i < logic.transitions.count; i++) {
                var t = transitionsView.itemAt(i)
                if(t){
                    arr.push(t.getJSON())
                }
            }
            return arr;
        }

        delegate : StateTransition {
            id                    : trans
            name : model.name
            origin                 : rootObject
            destination            : rootObject.getStateItemFunc ? rootObject.getStateItemFunc(dest) : null
            onRightClicked         : {
                var obj = _.clone(transitionsView.model.get(index))
                obj.origin = logic.name
                obj.toString = function() { return "statetransitionmodelobject" }
                var coords = rootObject.mapToItem(null)
                rootObject.transitionRightClicked(obj,coords.x,coords.y)
            }

            Component.onDestruction: rootObject.transitionsUpdated("deleted")
            Component.onCompleted  : rootObject.transitionsUpdated("added")
        }
    }

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
        property alias name : logic.name
        onInputChanged: if(acceptable && text !== name) {
                            rootObject.accepted(logic.modelId, text)
                        }

        anchors.centerIn: parent
        width           : parent.width * 0.9
        height          : parent.height * 0.9
        validationFunc  : vFunc
        focus           : true
        text            : logic.name
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
    ZButton {
        state  : "b1-f2-t1"
        text    : functionsView.count
        width : height
        height : 16
        onClicked : rootObject.functionsClicked(rootObject,0,0)
        disableShowsGraphically: false
//        anchors.right: parent.left
        anchors.right: parent.right
    }
    ZButton {
        state  : enabled ? "b1" : "success-b1"
        enabled : !logic.isDefault
        width : height
        height : 16
        onClicked : rootObject.makeDefaultClicked(modelId, name)
        disableShowsGraphically: false
//        anchors.right: parent.left

    }
    DropArea {
        id : dropArea
        objectName : "stateBoxFunctionDropArea"
        property var root : rootObject
        anchors.fill: parent
        keys: ['function']
        onEntered:  {
//            console.log(drag.source, drag.keys)
            if(!colorAnim.running)
                colorAnim.start()
        }
        onExited : {
            colorAnim.stop()
        }
    }


}
