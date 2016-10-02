import QtQuick 2.5
import "functions.js" as Functions
Rectangle {
    id : rootObject
    property var map : ({})
    border.width: 1
    color : 'transparent'
    onChildrenChanged: {
        if(logic.mutex)
            return;

        logic.mutex = true;
        Functions.eachRight(children, function(v,k){
            if(v === childrenArea)
                return;

            v.xChanged.connect(logic.refreshSize)
            v.yChanged.connect(logic.refreshSize)
            v.widthChanged.connect (logic.refreshSize)
            v.heightChanged.connect(logic.refreshSize)
            v.Component.onDestruction.connect(logic.refreshSize)

            v.parent = childrenArea
        })
        logic.refreshSize();
        return logic.mutex = false;
    }

    property QtObject logic : QtObject {
        id : logic
        property bool mutex : false;

        function refreshSize(){
            var boundingRect = Functions.boundingRect(childrenArea.children);
            Functions.copyProperties(rootObject, boundingRect);
        }
    }

    Item {
        id : childrenArea
        anchors.fill: parent
    }



}
