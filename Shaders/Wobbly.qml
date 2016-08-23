import QtQuick 2.5
Effect {
    id : rootObject
    fragmentShaderName: "wobbly.fsh"
    property real amplitude : 0.04
    property real frequency: 20
    property real time: 0
    property real duration: 600

    NumberAnimation on time { loops : Animation.Infinite; from : 0; to: Math.PI * 2; duration : rootObject.duration }
//    dividerValue : 0.5
}
