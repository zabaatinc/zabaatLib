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

    readonly property int count_Original  : zsubOrig.sourceModel.count
    property alias count_ZSubOrignal      : zsubOrig.count
    property alias count_ZSubChanger      : zsubChanger.count

    QtObject {
        id: logic
        property var undos   : []
        property var redos   : []
        property var selected: []

        property ZSubModel zsubOrig    : ZSubModel {  id : zsubOrig   }
        property ZSubModel zsubChanger : ZSubModel {
            id : zsubChanger
            sourceModel : zsubOrig
//            sortFuncAcceptsIndices: true
//            sortFunc : function(a,b){ return a - b }
        }


        function moveSelectedTo(idx){
            if(selected && selected.length > 0){
                if(selected.length === 1){
                    //we only have one element. So this should be essy.
                    var len = zsubChanger.indexList.length
                    var s = zsubChanger.indexList[selected[0]] //this is the index in zsubOrig!

                    //find the dest index in the origin! if idx is lte 0, means we move to the start of our
                    //subChanger, if it's greater than that, we move to the end.
                    var t = idx <= 0 ? zsubChanger.indexList[0] :
                                       idx >= len ? zsubChanger.indexList[len - 1] : zsubChanger.indexList[idx]


                    zsubOrig.move(s,t,1);
                }
                else {

                }
            }
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
                    console.log(index, "LOADED" , number, JSON.stringify(zsubChanger.get(index)) , JSON.stringify(zsubOrig.get(index)))
                    if(item.model)  item.model = Qt.binding(function() { return lv.model.get(index) })
                    if(item.index)  item.index = Qt.binding(function() { return index; })
                }
//                Component.onCompleted: console.log("MODELDATA:", JSON.stringify(modelData,null,2))
            }
        }

        Component {
            id : simpleDelegate
            Rectangle {
                border.width: 1
                property int index
                property var model
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
