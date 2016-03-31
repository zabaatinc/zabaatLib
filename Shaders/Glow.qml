import QtQuick 2.5
import QtQuick.Window 2.0
Item {
    id : rootObject
    anchors.fill: source

    property real  value           : 0
    property alias sampleStrength  : blur.sampleStrength

    property real  sampleDistMin   : 0.4
    property real  sampleDist      : 2.2
    property int   loopDuration    : 2000
    property alias loops           : animTime.loops
    property bool  varyingDist     : true


    onLoopDurationChanged: {
        animTime.stop();
        animTime.duration = loopDuration;
        animTime.start();
    }
    onLoopsChanged: {
        animTime.restart();
    }

    property var source            : null
    property real dividerValue     : 1
    property alias hideSource      : blur.hideSource
    readonly property var chainPtr : bloom.chainPtr

    RadialBlur {
        id : blur
        source : rootObject.source
        anchors.fill: parent
        dividerValue: rootObject.dividerValue
        opacity: rootObject.opacity
        sampleDist: varyingDist ? Math.max(animTime.multiplier,sampleDistMin) * rootObject.sampleDist : rootObject.sampleDist
    }

    Bloom {
        id : bloom
        source : blur.chainPtr
        anchors.fill: parent
        value: animTime.multiplier * rootObject.value
        dividerValue: rootObject.dividerValue
        opacity: rootObject.opacity
    }

    property real time : 0
    NumberAnimation on time {
        id : animTime
        loops : Animation.Infinite;
        from : 0 ;
        to :Math.PI * 2;
        duration : rootObject.loopDuration;

        property real multiplier : Math.abs(Math.sin(time))
    }


}



