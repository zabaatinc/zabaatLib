//Give it a ZController object (or something inherited from it) & it
//will give you the view of all the models and let you walk through them!
import QtQuick 2.5
import QtQuick.Controls 1.4


Item {
    id : rootObject
    property var   controller : null
    property real  cellHeight : 0.1
    property color color1     : 'white'
    property color color2     : 'orange'
    property font  font       : Qt.font({ pixelSize : 16 })
    property int   longTime   : 3000

    Row {
        id : btns
        width : parent.width
        height : parent.height * 0.05
        Button {
            height : parent.height
            text   : "Models"
            onClicked: {
                models.visible = true;
                messages.visible = false;
            }
        }

        Button {
            height : parent.height
            text   : "Messages"
            onClicked: {
                models.visible = false;
                messages.visible = true;
            }
        }
    }

    Item {
        id : shower
        width : parent.width
        height : parent.height - btns.height
        anchors.bottom: parent.bottom
        Models {
            id : models
            anchors.fill: parent
            controller : rootObject.controller
            cellHeight : rootObject.cellHeight
            color1     : rootObject.color1
            color2     : rootObject.color2
            font       : rootObject.font
            visible : true
        }
        Messages {
            id : messages
            anchors.fill: parent
            controller : rootObject.controller
            cellHeight : rootObject.cellHeight
            color1     : rootObject.color1
            color2     : rootObject.color2
            font       : rootObject.font
            longTime   : rootObject.longTime
            visible : false
        }
    }



}
