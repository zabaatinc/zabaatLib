import QtQuick 2.5
Item {
    id : rootObject
    property var model
    property var filterFunc
    readonly property var lv    : loader.item ? loader.item.lv    : null
    readonly property var logic : loader.item ? loader.item.logic : null
    readonly property var gui   : loader.item ? loader.item.gui   : null

    readonly property var indexList : loader.item ? loader.item.indexList : null
    readonly property var indexListFiltered : loader.item ? loader.item.indexListFiltered : null

    function undo           ()            { if(loader.item) loader.item[arguments.callee.name].apply(this,arguments) }
    function redo           ()            { if(loader.item) loader.item[arguments.callee.name].apply(this,arguments) }
    function deselect       ()            { if(loader.item) loader.item[arguments.callee.name].apply(this,arguments) }
    function select         ()            { if(loader.item) loader.item[arguments.callee.name].apply(this,arguments) }
    function selectAll      ()            { if(loader.item) loader.item[arguments.callee.name].apply(this,arguments) }
    function deselectAll    ()            { if(loader.item) loader.item[arguments.callee.name].apply(this,arguments) }
    function moveSelectedTo (idx,destIdx) { if(loader.item) loader.item[arguments.callee.name].apply(this,arguments) }
    function resetState     ()            { if(loader.item) loader.item[arguments.callee.name].apply(this,arguments) }
    function undos          ()            { return (loader.item && loader.item.logic) ? loader.item.logic[arguments.callee.name].apply(this,arguments) : []}
    function redos          ()            { return (loader.item && loader.item.logic) ? loader.item.logic[arguments.callee.name].apply(this,arguments) : []}
    function runFilterFunc  ()            { if(loader.item) loader.item[arguments.callee.name].apply(this,arguments) }
    function get(idx)                     { return (loader.item) ? loader.item[arguments.callee.name].apply(this,arguments) : undefined }



    property var   selectionDelegate             : selectionDelegate
    property color selectionDelegateDefaultColor : "green"
    property var   highlightDelegate             : rootObject.selectionDelegate //will normally just change by changing selectionDelegate!
    property var   delegate                      : simpleDelegate
    property real  delegateCellHeight            : height * 0.1
    property var   blankDelegate                 : blankDelegate

    readonly property var selected : loader.item ? loader.item.logic.selected : {}
    readonly property int selectedLen : loader.item ? loader.item.logic.selectedLen : 0


    Loader {
        id : loader
        anchors.fill: parent
        Connections{
            target         : rootObject
            onModelChanged : loader.updateLoader()
        }

        Component.onCompleted:  loader.updateLoader();

        function updateLoader() {
            if(!model){
                loader.source = ""
            }
            var type = toString.call(model)
//            console.log("gonna call", type)
            loader.source = type === '[object Array]' ?  "ArrangableListArray.qml": "ArrangableListModel.qml"
        }


        onLoaded : {
            item.model                          = Qt.binding(function() { return rootObject.model                         } )
            item.filterFunc                     = Qt.binding(function() { return rootObject.filterFunc                    } )
            item.selectionDelegate              = Qt.binding(function() { return rootObject.selectionDelegate             } )
            item.selectionDelegateDefaultColor  = Qt.binding(function() { return rootObject.selectionDelegateDefaultColor } )
            item.highlightDelegate              = Qt.binding(function() { return rootObject.highlightDelegate             } )
            item.delegate                       = Qt.binding(function() { return rootObject.delegate                      } )
            item.delegateCellHeight             = Qt.binding(function() { return rootObject.delegateCellHeight            } )
            item.blankDelegate                  = Qt.binding(function() { return rootObject.blankDelegate                 } )
        }


    }



    Component {
        id : blankDelegate
        Rectangle {
            border.width: 1
            color : 'transparent'
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
//                    text             : parent.model ? JSON.stringify(parent.model) : "N/A"
                text : typeof parent.model === 'string' ? parent.model : "x_x"
//                onTextChanged: console.log(text)
            }
        }
    }
    Component {
        id : selectionDelegate
        Rectangle {
            color : selectionDelegateDefaultColor
            opacity : 0.5
        }
    }
}
