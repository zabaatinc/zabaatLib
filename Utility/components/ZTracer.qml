import QtQuick 2.4
Item {
    id : rootObject
    property string state : ""
    property alias border : infoRect.border
    property alias color  : infoRect.color


    Rectangle {
        id : infoRect
        visible : false
        border.width: 1
        border.color: 'black'
        function match() {
            if(rootObject.state === 'all' || rootObject.state === "")
                return true;

            for(var i = 0; i < arguments.length; ++i) {
                var arg = arguments[i]
                if(rootObject.state.indexOf(arg) !== -1)
                    return true;
            }
            return false;
        }
    }

    Rectangle{
        id  : l
        color   : infoRect.border.color
        width  : infoRect.border.width
        height : parent.height
        visible : infoRect.match('left','l')
    }


    Rectangle{
        id : r
        color   : infoRect.border.color
        width   : infoRect.border.width
        height  : parent.height
        visible : infoRect.match('right','r')
        anchors.right: parent.right
    }


    Rectangle{
        id : t
        color   : infoRect.border.color
        width   : parent.width
        height  : infoRect.border.width
        visible : infoRect.match('top','t')
    }

    Rectangle{
        id : b
        color   : infoRect.border.color
        width   : parent.width
        height  : infoRect.border.width
        visible : infoRect.match('bottom','b')
        anchors.bottom: parent.bottom
    }


}


