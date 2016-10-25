import QtQuick 2.5
import Zabaat.Material 1.0
import Zabaat.Utility.SubModel 1.1

Item {

    Component.onCompleted: msgText.forceActiveFocus()

    Row {
        width  : parent.width * 3/4
        height : parent.height * 0.1
        anchors.horizontalCenter: parent.horizontalCenter

        ZTextBox {
            id: msgText
            width : parent.width /3
            height : parent.height
            property bool alternator : false
            onAccepted: {
                if(alternator)  {
                    addNew("blue", msgText.text)
                    alternator = false;
                }else {
                    addNew("red", msgText.text)
                    alternator = true;
                }
                msgText.text = ""
            }
        }
    }

    ListModel { id : sourceModel }
    ZSubModel {
        id : sub
        sourceModel: sourceModel
        sortFunc: function(a,b) {
            if(a.date < b.date)
                return 1;
            else if(a.date > b.date)
                return -1;
            return 0;
        }
        filterFunc: function(a) { return true; }
    }


    function addNew(user,text) {
        var d = new Date();
        var obj = { id : +d , user : user, message : text, date : d  }
//        lv.model.insert(0,obj);
        sourceModel.append(obj);
    }


    ListView {
        id : lv
        width : parent.width / 2
        height : parent.height * 0.9
        anchors.bottom: parent.bottom
        property real cellHeight : height * 0.15
        model :  sub
        delegate :  Loader {
            width : lv.width
            height : lv.cellHeight
            sourceComponent : index % 2 === 0 ? cmpLeft : cmpRight
            property bool imADelegate: true
            property int _index : index
            onLoaded : {
                item.user = Qt.binding(function() { return user ? user : "" } )
                item.date = Qt.binding(function() { return date ? date : new Date(1971) } )
                item.message = Qt.binding(function() { return message ? message : "" } )
            }
        }

        Component {
            id : cmpLeft
            Item {
                id : del
                width : lv.width
                height : lv.height * 0.1
                property string user : ""
                property date date
                property string message : ""


                Rectangle {
                    id : delImage
                    height : parent.height
                    width  : parent.height
                    color       : user
                }
                Item {
                    height : parent.height
                    width  : parent.width - delImage.width
                    anchors.left: delImage.right
                    Column {
                        id : delInfo
                        anchors.fill: parent
                        Rectangle{
                            width  : delHeading.width * 1.2
                            height : parent.height * 0.4
                            color : Colors.info
                            anchors.left: parent.left
                            radius : 5
                            Text {
                                id : delHeading
                                width  : paintedWidth
                                height : parent.height
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment : Text.AlignVCenter
                                text : user + "\t" + Qt.formatDateTime(date)
                                font.pixelSize: height * 1/2
                                font.family: Fonts.font1
                                color : Colors.text2
                            }
                        }
                        Rectangle{
                            width  : delMessage.width * 1.4
                            height : parent.height * 0.6
                            color  : Colors.standard
                            radius : 5
                            anchors.left: parent.left
                            border.width: 1
                            border.color: Colors.getContrastingColor(color,2)
                            Text {
                                id : delMessage
                                width  : paintedWidth
                                height : parent.height
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment : Text.AlignVCenter
                                text : message
                                font.pixelSize: height * 1/2
                                font.family: Fonts.font1
                                color : Colors.contrastingTextColor(parent.color)
                            }
                        }
                    }
                }
            }

        }
        Component {
            id : cmpRight
            Item {
                id : del2
                width : lv.width
                height : lv.height * 0.1
                property string user : ""
                property date date
                property string message : ""

                Rectangle {
                    id : delImage
                    height : parent.height
                    width  : parent.height
                    color       : user
                    anchors.right: parent.right
                }
                Item {
                    height : parent.height
                    width  : parent.width - delImage.width
                    anchors.right: delImage.left
                    Column {
                        id : delInfo
                        anchors.fill: parent
                        Rectangle{
                            width  : delHeading.width * 1.2
                            height : parent.height * 0.4
                            color : Colors.info
                            anchors.right: parent.right
                            radius : 5
                            Text {
                                id : delHeading
                                width  : paintedWidth
                                height : parent.height
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment : Text.AlignVCenter
                                text :  Qt.formatDateTime(date) + "\t" + user
                                font.pixelSize: height * 1/2
                                font.family: Fonts.font1
                                color : Colors.text2
                            }
                        }
                        Rectangle{
                            width  : delMessage.width * 1.4
                            height : parent.height * 0.6
                            color  : Colors.standard
                            radius : 5
                            anchors.right: parent.right
                            border.width: 1
                            border.color: Colors.getContrastingColor(color,2)
                            Text {
                                id : delMessage
                                width  : paintedWidth
                                height : parent.height
                                anchors.centerIn: parent
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment : Text.AlignVCenter
                                text : message
                                font.pixelSize: height * 1/2
                                font.family: Fonts.font1
                                color : Colors.contrastingTextColor(parent.color)
                            }
                        }
                    }
                }

            }


        }

    }



}
