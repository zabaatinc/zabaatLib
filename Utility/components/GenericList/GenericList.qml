import QtQuick 2.5
import Zabaat.Base 1.0
import QtQuick.Controls 1.4
//TODO, NOT YET FINISHED!!
Item {
    id : rootObject ;
    property var   columns
    onColumnsChanged: logic.initColumns()
    property real  headerHeight;
    property var   headerDelegate : defaultDelegate;
    property real  cellHeight   : 40;
    property alias delegate     : lv.delegate
    property alias model        : lv.model


    QtObject {
        id: logic
        property var colArr
        property var colMap

        function initColumns() {
            header.clear();

            var c = [];
            var map   = {};

            var freeWidth = 1;
            var unspecLen = columns.length;
            Lodash.each(columns, function(v,k) {
                if(Lodash.isObject(v)) {
                    var key            = Lodash.first(Lodash.keys(v));
                    var widthSpecifier = v[key];
                    freeWidth         -= widthSpecifier;
                    unspecLen--;
                    c.push({key:key, width : widthSpecifier})
                }
                else {
                    c.push({key:v})
                }
            })

            var avg = unspecLen > 0 ? freeWidth/unspecLen : 0;
            Lodash.each(c, function(v,k) {
                if(v.width === undefined)
                    c[k].width = avg;

                map[v.key] = v.width;

                var hInstance = headerFactory.createObject(header);
                hInstance.key = v.key;
            })

            colMap = map;
            colArr = Lodash.keys(map);
        }

    }

    Component {
        id : defaultDelegate
        Text {
            id : defaultDelegateInstance


        }
    }

    Component {
        id : headerFactory
        Loader {
            id : headerInstance
            width : logic.colMap && logic.colMap[key] ? header.width * logic.colMap[key] : 0
            height : headerHeight
            sourceComponent: headerDelegate
            property string key;
            onLoaded: {
                if(item.hasOwnProperty('text'))
                    item.text = Qt.binding(function(){return key })
            }
        }
    }


    SplitView {
        id : header
        anchors.fill: parent
        z : Number.MAX_VALUE

        function clear() {
            Lodash.eachRight(children, function(v) {
                v.destroy();
                v.parent = null;
            })
        }



    }



    ListView {
        id : lv
        width : parent.width
        height : parent.height - headerHeight
        anchors.bottom: parent.bottom
        interactive: contentHeight > height;
        onModelChanged : {
            Functions.log("MY MODEL CHANGED", toString.call(model), model.length)
        }


        delegate : Rectangle {
            id : del
            width          : lv.width
            height         : cellHeight
            property var m : Lodash.isArray(lv.model) ? modelData : model ;
            border.width: 1
            ListView {
                id : lvInner
                anchors.fill   : parent
                interactive    : false;
                orientation    : ListView.Horizontal
                model          : columns;
                delegate   : Text {
                    width  : del.width / columns.length;
                    height : 64
                    text   : modelData
                }
            }

        }


    }

}
