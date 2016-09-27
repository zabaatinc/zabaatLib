import QtQuick 2.5
Effect {
    id : rootObject
    fragmentShaderName: "ripple.fsh"
    property vector2d resolution : Qt.vector2d(width,height);
    property vector2d center     : Qt.vector2d(0.5, 0.5);
    property real time           : 0
    property real freq           : 2;
    Behavior on time { NumberAnimation { duration : 999 } }

    Timer {
        id : timeCounter
        interval: 1000
        repeat: true
        running : true
        triggeredOnStart: true
        onTriggered: {
            var t = rootObject.time;
            t++;
            if(t < 0)   //overflow protection
                t = 0;

            rootObject.time = t;
        }
    }
}
