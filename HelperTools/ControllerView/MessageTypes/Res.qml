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
    property var procTime : model && model.procTime ? model.procTime : 0


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
                         SequentialAnimation on color {
                             running : rootObject.procTime > longTime
                             loops : Animation.Infinite
                             ColorAnimation {
                                 from: "darkRed"
                                 to: "black"
                                 duration: 200
                             }
                             ColorAnimation {
                                 from: "black"
                                 to: "darkRed"
                                 duration: 200
                             }
                             onStopped : r.color  = Qt.lighter(bgkColor)
                         }
                     }
                 }

                 Rectangle {
                      id: timeReporter
                      width     : parent.width
                      height    : parent.height / 2
                      color     : Qt.lighter(bgkColor)
                      border.width: 0
                      property var rtt : timeDiff === -1 ? "" : "RTT: "  + (timeDiff/1000).toFixed(2) + "s"
                      property var proc: procTime === -1 ? "" : "PROC: " + (procTime/1000).toFixed(2) + "s"

                      Text {
                          anchors.fill: parent
                          anchors.margins: 5
                          font.pixelSize: height * 1/2
                          color       : rootObject.textColor
                          text        : parent.rtt
                          verticalAlignment: Text.AlignVCenter
                          horizontalAlignment: Text.AlignLeft
                      }
                      Text {
                          anchors.fill: parent
                          anchors.margins: 5
                          font.pixelSize: height * 1/2
                          color       : rootObject.textColor
                          text        : parent.proc
                          verticalAlignment: Text.AlignVCenter
                          horizontalAlignment: Text.AlignRight
                      }
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
            onDChanged: detailedText.text = JSON.stringify(d,null,2)
            onToggleChanged: {
                rootObject.detailViewToggle = toggle;
                if(toggle) {
                    detRect.d = rootObject.req._data
                }
                else {
                    detRect.d = rootObject.d
                }
            }

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
                    onClicked : detRect.toggle = true
                }

                SimpleButton {
                    width     : parent.width / 4
                    height    : parent.height
                    text      : "Res (RTT: " + timeDiff + " ms) (PROC: " + procTime + " ms)"
                    color     : !detRect.toggle ? "orange" : "transparent"
                    onClicked : detRect.toggle = false
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
                }
            }




        }
    }





}
