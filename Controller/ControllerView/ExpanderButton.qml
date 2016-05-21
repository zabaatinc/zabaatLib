import QtQuick 2.5
Item {
    id: eb
    property string text : ""
    property var obj : null
    property alias contentHeight : ob.contentHeight
    property bool expanded : false
    property font font ;
    property alias color : sb.color
    property alias textColor : sb.textColor
    property real cellHeightAbsolute


    SimpleButton {
        id: sb
        width  : parent.width
        height : cellHeightAbsolute ? cellHeightAbsolute : parent.height
        onClicked: parent.expanded = !parent.expanded
        text : eb.text
        font : eb.font

        Text {
            anchors.fill: parent
            anchors.margins: parent.width * 0.025
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            font : parent.font
            color : parent.textColor
            text : !eb.expanded ? "▼" : "▲"
        }
    }
    ObjectBrowser{
        id : ob
        objectName : parent.objectName
        anchors.bottom: parent.bottom
        width : parent.width
        height : parent.expanded ? contentHeight : 0
        cellHeightAbsolute: eb.cellHeightAbsolute

        visible : parent.expanded
        obj : eb.obj
        font : eb.font
//        onObjChanged: if(objectName === 'people_0_info_children')
//                          console.log("VALUE = " ,JSON.stringify(obj))
    }
}
