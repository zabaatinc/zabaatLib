import QtGraphicalEffects 1.0
import QtQuick 2.5
Loader {
    id : fakeShadow
    property bool flipped : false
    property color color1 : Qt.rgba(1,1,1,0);
    property color color2 : 'lightGray'
    property int orientation : ListView.Vertical
    opacity: 0.7
    sourceComponent: orientation === ListView.Vertical ? ver : hor;
    Component {
        id : hor
        LinearGradient {
            start:  Qt.point(0, 0)
            end  :  Qt.point(fakeShadow.width,0);
            gradient: Gradient {
                GradientStop { position: 0.0; color: fakeShadow.flipped ? fakeShadow.color2 : fakeShadow.color1 }
                GradientStop { position: 1.0; color: fakeShadow.flipped ? fakeShadow.color1 : fakeShadow.color2 }
            }
        }
    }
    Component {
        id : ver
        LinearGradient {
            start:  Qt.point(0, 0)
            end  :  Qt.point(0,fakeShadow.height);
            gradient: Gradient {
                GradientStop { position: 0.0; color: fakeShadow.flipped ? fakeShadow.color2 : fakeShadow.color1 }
                GradientStop { position: 1.0; color: fakeShadow.flipped ? fakeShadow.color1 : fakeShadow.color2 }
            }
        }
    }

}
