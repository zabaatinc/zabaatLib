import QtGraphicalEffects 1.0
import QtQuick 2.5
LinearGradient {
    id : fakeShadow
//    width : parent.width
//    height : rootObject.height * 0.025
//    anchors.bottom: parent.top
    property bool flipped : false
    property color color1 : Qt.rgba(1,1,1,0);
    property color color2 : 'lightGray'


    property int orientation : ListView.Vertical


    start:  Qt.point(0, 0)
    end  : ListView.Vertical ? Qt.point(0, height) : Qt.point(width,0);
    gradient: Gradient {
        GradientStop { position: 0.0; color: flipped ? color2 : color1 }
        GradientStop { position: 1.0; color: flipped ? color1 : color2 }
    }
    opacity : 0.7
}
