import QtQuick 2.5
//assumes this item is target's sibling
Item {
    id : rootObject
    property var target
    property color color      : 'black'
    property real  barOpacity : 0.4
    property string state     : "tblr"
    anchors.fill: parent
    Rectangle {
        id : topBar
        color   : rootObject.color
        opacity : barOpacity
        visible : target && f.hasState('t')
        width   : rootObject.width
        height  : target ? target.y : 0
    }
    Rectangle {
        id : botBar
        color : rootObject.color
        opacity : barOpacity
        visible: target && f.hasState('b')
        width   : rootObject.width
        height  : {
            if(!target)
                return 0;

            return rootObject.height - (target.y + target.height);
        }

        anchors.bottom: parent.bottom
    }
    Rectangle {
        id : lfBar
        color : rootObject.color
        opacity : barOpacity
        visible: target && f.hasState('l')
        width  : target ? target.x : 0
        anchors.top: topBar.bottom
        anchors.bottom: botBar.top
    }
    Rectangle {
        id : rtBar
        color : rootObject.color
        opacity : barOpacity
        visible : target && f.hasState('r')
        width  : {
            if(!target)
                return 0;
            return rootObject.width - (target.x + target.width);
        }

        anchors.right: parent.right
        anchors.top: topBar.bottom
        anchors.bottom: botBar.top
    }

    QtObject {
        id : f
        function hasState(s) {
            s = s.toLowerCase();
            var rootState = rootObject.state.toLowerCase();
            return rootState.indexOf(s) !== -1
        }
    }

}
