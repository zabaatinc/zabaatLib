import QtQuick 2.4
import Zabaat.Material 1.0
import Zabaat.Utility 1.0
Item {      //the target is a stateBox
    id : rootObject
    property var target : null
    property int cellHeight : 40


    signal addFunction   (string name, var rules)
    signal editFunction  (string id, var rules, string name)
    signal deleteFunction(string id, string name)
    signal finished()

    property var vFunc : null
    Keys.onEscapePressed: finished()


    QtObject{
        id: logic
        function addAction(){
            textPopupBlocker.visible = true;
        }

        function deleteAction(){
            if(leftList.currentM && !leftList.currentM.readOnly){
                return rootObject.deleteFunction(leftList.currentM.id, leftList.currentM.name)
            }
            console.log("unable to delete. function may be readonly", JSON.stringify(leftList.currentM))
        }


    }
    Row {
        width  : parent.width * 0.2
        height : cellHeight
//        enabled : !right.visible
        ZButton {
            width  : parent.width/2
            height : parent.height
            text   : "-"
            onClicked : logic.deleteAction()
            state : "danger-f2"
//            enabled :
        }
        ZButton {
            width  : parent.width/2
            height : parent.height
            text   : "+"
            onClicked : logic.addAction()
            state : "success-f2"
        }
    }
    ListView{
        id : leftList
        width  : parent.width * 0.2
        height : parent.height - cellHeight
        anchors.bottom: parent.bottom
        model : target
//        enabled : !right.visible

        property int sIndex   : -1
        property var currentM : model && sIndex !== -1 ? model.get(sIndex) : null

        delegate : ZButton {
            id : leftDel
            width : leftList.width
            height: cellHeight
            state : index === leftList.sIndex ? "success-f2-t2" : "ghost-f2-t2"
            text  : name
//            property var m : leftList.model ? leftList.model.get(index) : null
            onActiveFocusChanged: if(activeFocus)
                                      leftList.sIndex = leftList.currentIndex = index
            onClicked: leftList.sIndex = leftList.currentIndex = index
//            Component.onCompleted: state = "ghost-f2-t2"
//            setAcceptedTextFunc: function(val) { if(m) m.name = val }
        }
    }
    Rectangle {
        width : parent.width * 0.7
        height : parent.height
        border.width: 1
        color : 'transparent'
        anchors.right: parent.right

        RulesEditor {
            id : right
            anchors.fill: parent
            scale : 0.9

            enabled : leftList.currentM && !leftList.currentM.readOnly ? true : false
            visible : leftList.currentM
            target  : leftList.currentM
            vFunc   : rootObject.vFunc
            dontsave : true
            onFinished: leftList.sIndex = -1
            onNameChanged: rootObject.editFunction(id, rules ,name)
            onRulesChanged : rootObject.editFunction(id, rules ,name)
        }
    }
    ZButton {
        width  : parent.width * 0.2
        height : cellHeight
        anchors.top: parent.bottom
        anchors.left: parent.left
        text   : "Done"
        onClicked : rootObject.finished()
        state : "success-f2"
        visible : !right.visible
        enabled : !right.visible
    }
    UIBlocker {
        id : textPopupBlocker
        text : ""
        anchors.fill: parent
        visible : false
        color : "black"
        solidBackGround: false

        ZTextBox {
            id : textPopupEntry
            anchors.centerIn: parent
            width  : cellHeight * 4
            height : cellHeight
            label : "Enter name for new function"
            state : "f2-t2"
            text  : ""
            validationFunc: vFunc
            onAccepted : {
                parent.visible = false;
                rootObject.addFunction(text,[]);
            }
        }

        ZButton {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 5
            text : "X"
            state : 'ghost-circle-t2'
            width : cellHeight
            height : width
            onClicked : parent.visible = false;
        }

        Keys.onEscapePressed: visible = false;
    }

}
