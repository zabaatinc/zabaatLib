import QtQuick 2.5
import Zabaat.Utility 1.0
import QtGraphicalEffects 1.0
import Zabaat.Material 1.0
Item {
    id : rootObject

    Component.onCompleted:  {
        var m = Moment.create("12/12/2006");
        var m2 = Moment.create("12/12/2008");

        var dur = Moment.duration(Moment.diff(m,"year",true,m2) , "year");
        console.log(dur, dur.humanize());
    }

    ZSlider {
        id : slider
        anchors.bottom: parent.bottom
        value : 0
        min : 0
        max : 1
        width : parent.width *0.5
        height : parent.height * 0.1
        anchors.bottomMargin: 32
    }


    property color fillColor : 'red'


    Item {
        id : circ
        property var d : Math.min(parent.width,parent.height)/2;
        width : d
        height : d
        anchors.centerIn: parent

        Rectangle {
            id : outerRing
            anchors.fill: parent
            radius : Math.max(width,height)/2
            color : 'transparent'
            border.width: 16
            border.color: 'gray'
        }

        Rectangle {
            id : innerRing
            anchors.fill: parent
            radius : Math.max(width,height)/2
            color : 'transparent'
            border.width: Math.max(outerRing.border.width - 2 , 1);
            border.color: Qt.darker(outerRing.border.color)
            anchors.margins: (outerRing.border.width - border.width)/2

            ConicalGradient {
                source : innerRing
                anchors.fill: parent
                gradient : Gradient {
                    GradientStop { position : 0.0         ; color : "white"}
                    GradientStop { position : slider.value; color : "white"}
                    GradientStop { position : slider.value+0.01; color :  'transparent'}
                    GradientStop { position : 1           ; color : 'transparent'}
                }
            }
        }



    }




}
