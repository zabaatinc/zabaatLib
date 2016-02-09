import QtQuick 2.2
import QtQuick.Window 2.1
import QtGraphicalEffects 1.0


Item
{
    width: 208
    height: 48
    
    Rectangle
    {
        id: right
        width: 20
        height: 48
        color: "black"
        anchors.right: parent.right
    }
    Rectangle
    {
        id: left
        width: 20
        height: 48
        color: "black"
        anchors.left: parent.left
    }
}
