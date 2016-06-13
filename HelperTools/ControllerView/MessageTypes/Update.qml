import QtQuick 2.5
import QtQuick.Controls 1.4
import "../"
Item {
   id : rootObject
   property var model
   property var lvIdx

   property var index
   property var d       : model && model._data   ? model._data   : null
   property var uid         : model && model.id     ? model.id     : ""
   property var time        : model && model.time   ? model.time   : null
   property var modelName   : model && model.model  ? model.model  : ""
   property var type        : model && model.type   ? model.type   : ""
   property color bgkColor  : "teal"
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
                        text      : modelName
                        border.width: 0
                    }

                    SimpleButton {
                        width     : (parent.width - r.width) * 0.6
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
                        text   : type
                        enabled : false
                        color : Qt.lighter(bgkColor)
                        border.color: Qt.darker(bgkColor)
                        textColor : Qt.darker(bgkColor)
                    }
                }

               SimpleButton {
                    width     : parent.width
                    height    : parent.height / 2
                    enabled   : false
                    textColor : rootObject.textColor
                    color     : Qt.lighter(bgkColor)
                    text      : uid
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
           ScrollView {
               anchors.fill: parent
               Text {
                   id : detailedText
                   width : detRect.width
                   height : paintedHeight
                   wrapMode : Text.WordWrap
                   horizontalAlignment: Text.AlignLeft
                   verticalAlignment: Text.AlignVCenter
                   font.pixelSize: detRect.height / 40
                   Component.onCompleted: {
                       text = JSON.stringify(rootObject.d,null,2)
                   }
                   Connections {
                       target : rootObject
                       onDChanged : {
                           detailedText.text = JSON.stringify(rootObject.d,null,2)
                       }
                   }
               }
           }




       }
   }







}
