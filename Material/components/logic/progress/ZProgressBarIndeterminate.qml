import Zabaat.Material 1.0
import Zabaat.Base 1.0
import QtQuick 2.5
Rectangle {
    id : rootObject
    width  : 500
    height : 100
    color  : Colors.standard

    property alias barColor : progressBar.color
    property int   duration : 1000;
    property real  barSize  : 0.3

    onDurationChanged: priv.reEvalAnim();
    onWidthChanged   : priv.reEvalAnim();



    Rectangle {
        id : progressBar
        width : parent.width * barSize
        onWidthChanged: priv.reEvalAnim();
        height : parent.height
        color : Colors.info
        NumberAnimation on x {
            id : numAnim
            loops    : Animation.Infinite
            from     : 0
            to       : rootObject.width + progressBar.width
            running  : rootObject.visible;
            duration : 1000
        }
    }

    QtObject {
        id : priv
        function reEvalAnim() {
            if(numAnim.running) {
                numAnim.stop();
                numAnim.to = rootObject.width + progressBar.width;


                Functions.time.setTimeOut(0,numAnim.start);
            }
            else {
                numAnim.to = rootObject.width + progressBar.width;
            }
        }

    }

}
