import QtQuick 2.5
import QtQuick.Controls 1.4
import "../"
Item {
    id : rootObject

    property var sourceModel
    property var model
    property var lvIdx
    property var index

    property int longTime : 3000

    property var d           : model && model._data     ? model._data  : null
    property var uid         : model && model.id        ? model.id     : ""
    property var time        : model && model.time      ? model.time   : null
    property var modelName   : model && model.model     ? model.model  : ""
    property var funcName    : model && model.func      ? model.func   : ""
    property var type        : model && model.reqType   ? model.reqType   : ""
    property var reqIdx      : model ? model.reqIdx : -1
    property var req
    property string title    : "RES"
    property var timeDiff : rootObject.time && req && req.time ? (+rootObject.time) - (+req.time)  : -1

    onSourceModelChanged: if(reqIdx !== -1 && sourceModel)   req = sourceModel.get(reqIdx)
    onReqIdxChanged     : if(reqIdx !== -1 && sourceModel)   req = sourceModel.get(reqIdx)

    property bool detailViewToggle : false

    property color bgkColor  : 'yellow'
    property color textColor : 'white'
    signal clicked()
    property string state : ""

    Loader {
        anchors.fill: parent
        sourceComponent : rootObject.state === 'detailed' ?  detailed : list
    }


    Component {
        id : list
        Item {
            anchors.fill: parent
            Column  {
                 anchors.fill: parent

                 Row {
                     width     : parent.width
                     height    : parent.height / 2

                     SimpleButton {
                         width     : (parent.width - r.width)  * 0.4
                         height    : parent.height
                         enabled   : false
                         textColor : 'white'
                         color     : 'black'
                         text      : uid + " " + modelName + "/" + funcName
                         border.width: 0
                     }

                     SimpleButton {
                         width     : (parent.width - r.width)  * 0.6
                         height    : parent.height
                         enabled   : false
                         textColor : rootObject.textColor
                         color     : lvIdx === index  ? Qt.darker(bgkColor) : bgkColor
                         text      : Qt.formatDateTime(time, "hh:mm:ss AP").toString()
                         border.width: 0
                     }

                     SimpleButton {
                         id : r
                         height : parent.height
                         width  : paintedWidth + 10
                         text   : type + " " + title
                         enabled : false
                         color       : Qt.lighter(bgkColor)
                         border.color: Qt.darker(bgkColor)
                         textColor : timeDiff > longTime ? 'red' :  Qt.darker(bgkColor)
                     }
                 }

                SimpleButton {
                     width     : parent.width
                     height    : parent.height / 2
                     enabled   : false
                     textColor : rootObject.textColor
                     color     : Qt.lighter(bgkColor)
                     text      : timeDiff === -1 ? "" : (timeDiff/1000).toFixed(2) + " s"
                     border.width: 0
                 }
            }

            Rectangle {
                border.color: Qt.darker(bgkColor)
                border.width: 1
                color : 'transparent'
                anchors.fill: parent
            }

            MouseArea {
                anchors.fill: parent
                onClicked : rootObject.clicked()
            }
        }


    }

    Component  {
        id : detailed
        Rectangle {
            id : detRect
            color : 'white'

            property var d        : rootObject.d
            property bool toggle  : rootObject.detailViewToggle
            onToggleChanged: rootObject.detailViewToggle = toggle;

            Row {
                id : detRectRow
                width : parent.width
                height : parent.height * 0.07

                SimpleButton {
                    width : parent.width / 4
                    height : parent.height
                    text : "Req"
                    visible   : rootObject.req ? true : false
                    color     : detRect.toggle ? "orange" : "transparent"
                    onClicked : {
                        detRect.d = rootObject.req._data
                        detRect.toggle = true
                    }
                }

                SimpleButton {
                    width     : parent.width / 4
                    height    : parent.height
                    text      : "Res (" + timeDiff + " ms)"
                    color     : !detRect.toggle ? "orange" : "transparent"
                    onClicked :{
                        detRect.toggle = false
                        detRect.d = rootObject.d
                    }
                }
            }

            ScrollView {
                width : parent.width
                height : parent.height - detRectRow.height
                anchors.bottom: parent.bottom
                Text {
                    id : detailedText
                    width : detRect.width
                    height : paintedHeight
                    wrapMode : Text.WordWrap
                    horizontalAlignment: Text.AlignLeft
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: detRect.height / 40
                    Component.onCompleted: {
                        text = JSON.stringify(detRect.d,null,2)
                    }
                    Connections {
                        target : detRect
                        onDChanged : {
                            detailedText.text = JSON.stringify(detRect.d,null,2)
                        }
                    }
                }
            }




        }
    }





}
