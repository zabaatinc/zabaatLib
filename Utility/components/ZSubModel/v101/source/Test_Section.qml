import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

Window {
    id : root
    visible: true
    width : Screen.width
    height : Screen.height - 300

    Test_Main_SimulatedData {
        id: simData
//        onReadyChanged : if(ready) {
//                             sub.sourceModel = simData.model
//                         }
        url : Qt.resolvedUrl("data.txt")
    }
    property alias derp : simData.model

    ZSubModel {
        id : derpSub
        sourceModel : derp
        filterFunc: function(a) { return a.state === 'inspectQueue' }
        sortFunc: function(a,b) {
            if(!a.shippingAddressee) {
                if(a.customer.categoryName < b.customer.categoryName)
                    return -1;
                else if(a.customer.categoryName > b.customer.categoryName)
                    return 1;
                return 0;
            }
            else {
                if(a.shippingAddressee < b.shippingAddressee) {
                    return -1;
                }
                else if(a.shippingAddressee > b.shippingAddressee) {
                    return 1;
                }
                return 0;
            }
        }
    }

    Row {
        anchors.fill : parent

        ListView {
            width : parent.width/2
            height : parent.height
            model : derp
            delegate: Text {
                width : root.width/2
                height : 32
                verticalAlignment : Text.AlignVCenter
                font.pixelSize: height * 1/3
                property var m : derp.get(index)
                text : m && m.customer && m.customer.name ? m.customer.name : ""
            }
            section.property: "shippingAddressee"
            section.delegate:  Rectangle {
                width : root.width/2
                height : 64
                color : "lightblue"
                Text {
                    anchors.fill: parent
                    text : section
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment  : Text.AlignVCenter
                    font.pixelSize     : height * 1/3
                    color : 'white'
                }
            }
            Rectangle {
                anchors.fill: parent
                color : "transparent"
                border.width: 1
            }
        }

        ListView {
            id : lv2
            width : parent.width/2
            height : parent.height
            model : derpSub
            delegate: Text {
                width : root.width/2
                height : 32
                verticalAlignment : Text.AlignVCenter
                font.pixelSize: height * 1/3
                property var m : derpSub.get(index)
//                text : m ? m.name : ""
                text : m ? m.customer.name + "\t" + m.shippingAddressee +  "\t" + m.state: ""
            }
            section.property: "shippingAddressee"
            section.delegate: Rectangle {
                width : root.width/2
                height : 64
                color : "lightblue"
                Text {
                    anchors.fill: parent
                    text : section
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment  : Text.AlignVCenter
                    font.pixelSize     : height * 1/3
                    color : 'white'
                }
            }
            Rectangle {
                anchors.fill: parent
                color : "transparent"
                border.width: 5
                border.color: "green"
            }
        }
    }



}
