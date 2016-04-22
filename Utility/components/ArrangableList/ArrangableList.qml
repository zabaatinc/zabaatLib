import QtQuick 2.5
//import Zabaat.Material 1.0  //remove dependecy later
import Zabaat.Utility 1.1
import QtQuick.Controls 1.4


Item {
    id : rootObject
    property alias model      : zsubOrig.sourceModel
    property alias filterFunc : zsubChanger.filterFunc
    property alias lv         : lv
    property var delegate     : simpleDelegate
    property real  cellHeight : lv.height * 0.1

    readonly property var count_Original    : zsubOrig.sourceModel.count
    property alias count_ZSubOrignal : zsubOrig.count
    property alias count_ZSubChanger : zsubChanger.count

    Button {
        text : "HJERP"
        onClicked : console.log(JSON.stringify(zsubChanger.get(0),null,2) ,
                                JSON.stringify(zsubChanger.sourceGet(0),null,2) ,
                                JSON.stringify(zsubOrig.get(0),null,2))
        z : 999
    }

    QtObject {
        id: logic
        property var undos : []
        property var redos : []

        property ZSubModel zsubOrig : ZSubModel {
            id : zsubOrig
        }

        property ZSubModel zsubChanger : ZSubModel {
            objectName : "zsubchanger"
            id : zsubChanger
            debug : true
            sourceModel : zsubOrig
            sortFuncAcceptsIndices: true
//            onCountChanged: if(count > 0)
//                                console.log(JSON.stringify(get(0),null,2))
//            sortFunc : function(a,b){ return a - b }
        }

    }


    Item {
        id: gui
        anchors.fill: parent
        ListView {
            id : lv
            anchors.fill: parent
            model : zsubChanger
            delegate : Loader  {
                id : delegateLoader
                width  : lv.width
                height : cellHeight
                sourceComponent : rootObject.delegate
                onLoaded : {
                    item.anchors.fill = delegateLoader
                    if(item.model)  item.model = Qt.binding(function() { return lv.model.get(index) })
                    if(item.index)  item.index = Qt.binding(function() { return index; })
                }
            }


        }

        Component {
            id : simpleDelegate
            Rectangle {
                border.width: 1
                property int index
                property var model
                onModelChanged: console.log(JSON.stringify(model,null,2))

                Text {
                    anchors.fill: parent
                    font.pixelSize: height * 1/3
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    text             : parent.model ? JSON.stringify(parent.model,null,2) : "N/A"
                }
            }
        }


    }





}
