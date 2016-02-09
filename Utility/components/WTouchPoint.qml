import QtQuick 2.4
TouchPoint {
    property point startingCoords;
    property var info;
    property point pos : Qt.point(x,y);
    property var ts;
    property color color : Qt.rgba(Math.random(), Math.random(), Math.random())
}
