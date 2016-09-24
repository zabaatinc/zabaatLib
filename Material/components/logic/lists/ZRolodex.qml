import QtQuick 2.5
import "../../Lodash"
Item {
    id : rootObject
    property var model  //can be array or ListModel
    property var groupFunc //each elem from model is shoved here. this function should return a groupname;
    signal pressed(int index);  //move the original list to this index

    onModelChanged    : logic.reset();
    onGroupFuncChanged: logic.reset();
    property bool hoverMode    : Qt.platform.os !== "windows" &&
                                 Qt.platform.os !== "linux"   &&
                                 Qt.platform.os !== "osx"   &&
                                 Qt.platform.os !== "unix"  &&
                                 Qt.platform.os !== "winrt" &&
                                 Qt.platform.os !== "wince"

    property var   delegate              : defaultDel
    property alias orientation           : lv.orientation
    property real  prefferedDelegateSize : 0

    QtObject {
        id : logic
        property bool isArray : Lodash.isArray(model)
        property int  len     : isArray ? model.length : model ? model.count : 0
        onLenChanged: reset();

        property var mapArr : []

        function reset() {
            mapArr = []
            if(!typeof groupFunc !== 'function')
                return;

            //Lodash.reduce()
            var map = {}
            for(var i = 0; i < len; ++i) {
                var item = isArray ? model[i] : model.get(i);
                var grpName = groupFunc(item);

                if(!grpName)
                    continue

                if(!map[grpName])       map[grpName] = { start: i, count : 1 }
                else                    map[grpName].count++
            }

            var arr = []
            Lodash.each(map, function(v,k){
                arr.push({group:k, len:v.count, start:v.start })
            })
            mapArr = arr;
        }
    }

    ListView {
        id : lv
        anchors.centerIn: parent
        width  : dw !== psize || orientation === ListView.Vertical  ? rootObject.width : pSizeTotal
        height : dh !== psize || orientation === ListView.Horizontal? rootObject.height: pSizeTotal
        model : logic.mapArr

        property real spacingSize : (spacing * (count-1))
        property real psize : prefferedDelegateSize
        property real fillW : rootObject.width /count + spacingSize
        property real fillH : rootObject.height/count + spacingSize
        property real pSizeTotal : psize * count + spacingSize
        property real dw    : pSizeTotal > rootObject.width  || psize <= 0 ? fillW : psize
        property real dh    : pSizeTotal > rootObject.height || psize <= 0 ? fillH : psize
        orientation : ListView.Horizontal
        interactive : false
        delegate : Loader {
            id : loaderInstance
            width  : rootObject.orientation === ListView.Vertical   ? rootObject.width   : lv.dw
            height : rootObject.orientation === ListView.Horizontal ? rootObject.height  : lv.dh
            sourceComponent: rootObject.delegate
            property int _index : index
            property var m : logic.mapArr[index];
            onLoaded : {
                if(item.hasOwnProperty('index'))
                    item.index = Qt.binding(function() { return index })
                if(item.hasOwnProperty('model'))
                    item.model = Qt.binding(function() { return loaderInstance.m })
            }
        }
        MouseArea {
            anchors.fill: parent
//            hoverEnabled: rootObject.hoverMode
            property point mouseCoords : Qt.point(mouseX,mouseY)
            onMouseCoordsChanged: {
                if(!containsPress && !hoverMode)
                    return;

                var item = lv.itemAt(mouseX,mouseY);
                if(item) {
//                    console.log(item, JSON.stringify(logic.mapArr[item._index],null,2))
                    var pt    = mapToItem(item,mouseX,mouseY);
                    var percX = pt.x / item.width;
                    var percY = pt.y / item.height;
//                    console.log("PERC", percX, percY)

                    var m = logic.mapArr[item._index];
                    //figure out the diff between start and len
                    var diff = m.len;
                    if(diff > 0) {
                        if(orientation === ListView.Horizontal) {
                            rootObject.pressed(Math.floor(percX * m.len + m.start) )
                        }
                        else {
                            rootObject.pressed(Math.floor(percY * m.len + m.start) )
                        }
                    }
                    else {
                        rootObject.pressed(m.start)
                    }

                }
            }


        }
        Component {
            id : defaultDel
            Rectangle {
                property int index
                property var model
                border.width: 1
                color : index % 2 === 0 ? 'gray' : 'white'
            }
        }
    }
}
