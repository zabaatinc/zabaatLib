import QtQuick 2.5
Item {
    id : rootObject
    clip : true
    width : height/2
    property alias  color  : rect.color
    property alias  border : rect.border
    property alias  radius : rect.radius
    property string state  : "left"
    onStateChanged : switch(state) {
                        case "right" :
                            rect.radius = Qt.binding(function() { return rootObject.height/2 })
                            rect.width  = Qt.binding(function() { return rootObject.width * 2} )
                            rect.height = Qt.binding(function() { return rootObject.height } )
                            rect.x = Qt.binding(function() { return -rect.width/2 });
                            rect.y = 0;
                            break;

                        case "up" :
                            rect.radius = Qt.binding(function() { return rootObject.width/2 })
                            rect.width  = Qt.binding(function() { return rootObject.width } )
                            rect.height = Qt.binding(function() { return rootObject.height * 2 } )
                            rect.x = 0;
                            rect.y = 0;
                            break;

                        case "down" :
                            rect.radius = Qt.binding(function() { return rootObject.width/2 })
                            rect.width  = Qt.binding(function() { return rootObject.width } )
                            rect.height = Qt.binding(function() { return rootObject.height * 2 } )
                            rect.x = 0;
                            rect.y = Qt.binding(function() { return -rect.height/2});
                            break;


                        default :
                            rect.radius = Qt.binding(function() { return rootObject.height/2 })
                            rect.width  = Qt.binding(function() { return rootObject.width * 2} )
                            rect.height = Qt.binding(function() { return rootObject.height } )
                            rect.x = 0;
                            rect.y = 0;
                            break;

                     }


    Rectangle {
        id : rect
        color : 'purple'
        radius : height/2
        width  : parent.width * 2
        height : parent.height
    }

    Keys.onUpPressed  : radius += 5
    Keys.onDownPressed: radius -= 5
    MouseArea {
        anchors.fill: parent
        onClicked: rootObject.forceActiveFocus()
    }



}
