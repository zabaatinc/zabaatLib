import QtQuick 2.4

Flipable {
    id: flipable
    width: 240
    height: 240

    property bool flipped: false
//    property alias defaultMouseArea : ms.enabled
    property int   flipSpeed : 333
//    property bool isAnimating : rotation

    transform: Rotation {
        id: rotation
        origin.x: flipable.width/2
        origin.y: flipable.height/2
        axis.x: 0; axis.y: 1; axis.z: 0     // set axis.y to 1 to rotate around y-axis
        angle: 0    // the default angle
    }

    states: State {
        name: "back"
        PropertyChanges { target: rotation; angle: 180 }
        when: flipable.flipped
    }

    transitions: Transition {
        NumberAnimation { target: rotation; property: "angle"; duration: flipSpeed }
    }

    function flip(){
        flipped = !flipped
    }



//    MouseArea {
//        id : ms
//        anchors.fill: parent
//        onClicked: flipable.flipped = !flipable.flipped
//    }
}
