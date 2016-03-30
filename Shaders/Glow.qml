import QtQuick 2.5
import QtQuick.Window 2.0
Effect {
    id : rootObject
    fragmentShaderName : "fakeVolLight.fsh"


   property real  sampleDist : 1;
   property real  sampleStrength : 2.2;

    property real time : 0
    NumberAnimation on time { loops : Animation.Infinite; from : 0 ; to :Math.PI * 2; duration : 600 }

}
