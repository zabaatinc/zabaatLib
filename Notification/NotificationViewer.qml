import QtQuick 2.5
import Zabaat.Base 1.0
import Zabaat.Notification 1.0
import QtQuick.Controls 1.4
import "Components"
Item {
    id : rootObject
    Component.onCompleted: logic.readGroups();
    Connections {
        target          : Notification
        onNewGroupAdded : groups.append({ name : group })
    }

    property alias style : styleSettings;
    QtObject {
        id : logic

        function readGroups() {
            var obj = Notification.getAllNotificationLists();
            Lodash.each(obj,function(v,k) {
                groups.append({ name: v.objectName })
            })
        }

        property ListModel groups : ListModel {  id : groups ; }
    }

    NotificationViewerStyle { id : styleSettings }

    SplitView {
        id : gui
        anchors.fill: parent

        Item {
            id : groupArea
            width  : parent.width * 0.25
            height : parent.height
            ZTracer { state : 'r' }

            ListView {
                id : groupList
                anchors.fill: parent
                clip : true
                model : groups
                property var selectedItem : currentItem && currentItem.name ? currentItem.name : ""
                delegate: Rectangle {
                    id : groupDel
                    width : groupList.width
                    height: groupList.height * styleSettings.cellHeight
                    color : groupList.currentIndex === index ? styleSettings.success : styleSettings.standard
                    property color textColor : groupList.currentIndex === index ? styleSettings.text2 : styleSettings.text1
                    ZTracer { state : "b"; color : "#CCCCCC" }

                    property var m           : model;
                    property string name     : m && m.name ? m.name : "??";
                    property int unseenCount : !name ? -1 : Notification.getNotificationList(name).unseen

                    MouseArea {
                        anchors.fill: parent
                        onClicked   : groupList.currentIndex = index;
                    }
                    Text {
                        id : groupName
                        font.pixelSize: parent.height * 0.5
                        font.family: rootObject.style.font;
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        anchors.verticalCenter: parent.verticalCenter
                        color : groupDel.textColor
                        text : groupDel.name
                    }
                    Text {
                        id : unseenNumber;
                        font.pixelSize: parent.height * 0.5
                        font.family: styleSettings.font;
                        anchors.right: parent.right
                        anchors.rightMargin: 5
                        anchors.verticalCenter: parent.verticalCenter
                        color : groupDel.textColor
                        text : groupDel.unseenCount
                    }
                }
            }
        }

        Item {
            id : msgViewerContainer
            width         : parent.width * 0.75
            height        : parent.height
            MessageViewer {
                anchors.fill: parent
                anchors.margins: 10
                model         : !groupList.selectedItem ? null : Notification.getNotificationList(groupList.selectedItem);
                styleSettings : styleSettings;
                fontSize      : groupList.height * styleSettings.cellHeight * 0.5
            }
        }



    }


}
