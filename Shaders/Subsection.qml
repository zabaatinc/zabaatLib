import QtQuick 2.4
Effect {
    id : rootObject
    fragmentShaderName  : "subsection.fsh"
    property rect rect  : Qt.rect(0,0,1,1);
    anchors.fill: null;

    readonly property real startX : !source ? 0 : rect.x / source.width;
    readonly property real startY : !source ? 0 : rect.y / source.height;
    readonly property real endX   : !source ? 1 : (rect.x + rect.width)/source.width;
    readonly property real endY   : !source ? 1 : (rect.y + rect.height)/source.height;

    function itemRect(item) {
        if(!Qt.isQtObject(item))
            return Qt.rect(0,0,1,1);

        var x = item.x;
        var y = item.y;
        var w = item.width  ? item.width : 1;
        var h = item.height ? item.height : 1;
        return Qt.rect(x,y,w,h);
    }
}



