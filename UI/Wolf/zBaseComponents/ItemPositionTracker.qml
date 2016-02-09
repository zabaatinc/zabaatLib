//http://stackoverflow.com/questions/17927714/qml-tracking-global-position-of-a-component
////use
//ItemPositionTracker {
//    trackedItem: rectGreen
//    movedItem: rectBlue
//}


import QtQuick 2.3

Item {
    id: root

    property var trackedItem
    property var movedItem
    property int xOffset : 0
    property int yOffset : 0


    Component.onCompleted:
    {
        movedItem.x = Qt.binding(function()
                                {
                                    if (trackedItem === null || movedItem.visible == false || trackedItem.visible == false)
                                        return 0;

                                    var docRoot = trackedItem;
                                    var x = trackedItem.x;

                                    while(docRoot.parent)
                                    {
                                        docRoot = docRoot.parent;
                                        x += docRoot.x
                                    }

                                    return x + xOffset;
                                })

        movedItem.y = Qt.binding(function()
                                {
                                    if (trackedItem === null || movedItem.visible == false || trackedItem.visible == false)
                                        return 0

                                    var docRoot = trackedItem;
                                    var y = trackedItem.y

                                    while(docRoot.parent)
                                    {
                                        docRoot = docRoot.parent;
                                        y += docRoot.y
                                    }

                                    return y + yOffset;
                                })
    }
}
