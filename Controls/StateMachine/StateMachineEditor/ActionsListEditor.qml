import QtQuick 2.4
import Zabaat.Material 1.0
Item {      //the target is a stateBox
    id : rootObject
    property var target : null
    property int cellHeight : 40

    signal finished()
    Keys.onEscapePressed: finished()


    QtObject{
        id: logic
        function addAction(){
            if(target){
                var act  = target.logic.addAction('unnamed');
            }
        }

        function deleteAction(){
            if(target && leftList.model && leftList.currentIndex !== -1){
                leftList.model.remove(leftList.currentIndex)
            }
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
        model : target ? target.actions : null
//        enabled : !right.visible

        property int sIndex   : -1
        property var currentM : model && sIndex !== -1 ? model.get(sIndex) : null

        delegate : ZButton {
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

            visible : leftList.currentM
            target  : leftList.currentM
            dontsave : true
            onFinished: {
                if(target){
                    for(var i = 0; i < target.rules.count ; i++){
                        var t= target.rules.get(i)
                        console.log(JSON.stringify(t,null,2))
                    }

                }
                leftList.sIndex = -1
            }
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

}
