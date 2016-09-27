import QtQuick 2.4
Effect {
    id : rootObject
    fragmentShaderName  : "waterReflection.fsh"
    property real time      : 0;
    property real amplitude : 0.5;
    property int duration   : 1000;
    property bool flipX: false;
    property bool flipY: true;

    NumberAnimation on time {
        id : timeAnim;
        running : true ; loops : Animation.Infinite; from : 0; to: Math.PI * 2; duration : rootObject.duration
    }
    onDurationChanged: timeAnim.restart();

    anchors.fill: null;
    width       : source ? source.width : 100
    height      : source ? source.height : 100
    anchors.top : source ? source.bottom : undefined
    hideSource  : false;
    anchors.horizontalCenter: source ? source.horizontalCenter : undefined
}
