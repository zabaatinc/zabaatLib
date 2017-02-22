import QtQuick 2.5
//lets you drag the target inside the parent
//but the target cannot be dragged past its parent's bounds
Item {
    id : rootObject
    anchors.fill: target
    property var target : parent
    property var constraintItem : target && target.parent ? target.parent : null;
    property alias indicator: indi.visible
    property color color    : 'steelblue';
    Rectangle {
        id : indi
        color : 'transparent'
        border.width: 1
        border.color: rootObject.color
        visible: false
        anchors.fill: parent
    }

    MouseArea {
        id : ma
        anchors.fill: parent
        drag.target : target
        drag.minimumX: {
            if(!target || !constraintItem || target.parent === constraintItem)
                return 0;
            return constraintItem.x;
        }
        drag.minimumY: {
            if(!target || !constraintItem || target.parent === constraintItem)
                return 0;
            return constraintItem.y;
        }

        drag.maximumX: {
            if(!target || !constraintItem)
                return Number.MAX_VALUE
            if(target.parent === constraintItem)
                return constraintItem.width  - target.width
            return (constraintItem.x + constraintItem.width) - target.width;
        }
        drag.maximumY: {
            if(!target || !constraintItem)
                return Number.MAX_VALUE
            if(target.parent === constraintItem)
                return constraintItem.height  - target.height
            return (constraintItem.y + constraintItem.height) - target.height;
        }
    }
}
