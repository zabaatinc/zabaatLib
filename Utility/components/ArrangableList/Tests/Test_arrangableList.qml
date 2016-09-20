import QtQuick 2.5
import Zabaat.Utility 1.1
import QtQuick.Controls 1.4

Item {


    property var master : ["Zero", "One","Two","Three","Four","Five"]
    property var masterModel : ListModel {
        ListElement { text : "ZERO" }
        ListElement { text : "ONE" }
        ListElement { text : "TWO" }
        ListElement { text : "THREE" }
        ListElement { text : "FOUR" }
        ListElement { text : "FIVE" }
    }

    function f(a) {
//        return _.indexOf(["Two","Four"],a) !== -1
        if(typeof a === 'object') {
            return _.indexOf(["One","Three","Five"],a.text) !== -1
        }
        return _.indexOf(["One","Three","Five"],a) !== -1
    }
    Row {
        width : parent.width
        height : parent.height
        anchors.centerIn: parent

        ListView {
            id : orig
            width    : parent.width/2
            height   : parent.height
            delegate : Loader {
                width : orig.width
                height: arrangable.delegateCellHeight
                sourceComponent: simpleDel
                onLoaded : item.model = Qt.binding(function() { return orig.model !== masterModel ? master[index] : masterModel.get(index) })
            }

            model : master
        }
        ArrangableList {
            id     : arrangable
            width  : parent.width/2
            height : parent.height
            model  : master
//            filterFunc: f
            readonly property var il : arrangable.indexList
            onIlChanged: {
                textUndos.doUpdate()
                textRedos.doUpdate()
            }

            delegate : simpleDel


        }
    }

    Text {
        id : textUndos
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 10
        text : JSON.stringify(arrangable.undos(),null,2)

        function doUpdate() {
            var t = "Undos\n"
            _.each(arrangable.undos() , function(v,k) {
                t += JSON.stringify(v) + "\n"
            })

            text = t;
        }

        Text {
            anchors.bottom: parent.top
            text : arrangable.logic ? arrangable.logic.stateIdx : -1
        }
    }

    Text {
        id : textRedos
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.rightMargin: 10
        text : JSON.stringify(arrangable.redos())

        function doUpdate() {
            var t = "Redos\n"
            _.each(arrangable.redos() , function(v,k) {
                t += JSON.stringify(v) + "\n"
            })

            text = t;
        }

        Text {
            anchors.bottom: parent.top
            text : arrangable.logic ? arrangable.logic.stateIdx : -1
        }
    }

    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        height : parent.height * 0.1
        Button {
            height : parent.height
            anchors.bottom: parent.bottom
            text : "undo"
            onClicked : arrangable.undo()
        }

        Button {
            height : parent.height
            anchors.bottom: parent.bottom
            text : "redo"
            onClicked : arrangable.redo()
        }


        Button {
            height : parent.height
            anchors.bottom: parent.bottom
            text : "save"
            onClicked : {
                var narr = []
                _.each(arrangable.indexList, function(i,k){
                    narr[k] = master[i]
                })
                console.log(narr, master)
                master = narr;

            }
        }


        Button {
            height : parent.height
            anchors.bottom: parent.bottom
            text : "move to bottom"
            onClicked : {
                arrangable.moveToBottom();
//                al.moveSelectedTo(Constants.adminTickets.length -1, Constants.adminTickets.length -1);
            }
        }

        Button {
            height : parent.height
            anchors.bottom: parent.bottom
            text : "move to top"
            onClicked : {
                arrangable.moveToTop();
//                arrangable
//                al.moveSelectedTo(Constants.adminTickets.length -1, Constants.adminTickets.length -1);
            }
        }

        Button {
            height : parent.height
            anchors.bottom: parent.bottom
            text : arrangable.filterFunc ? "Detach filter" : "Attach Filter"
            onClicked : {
                arrangable.filterFunc = arrangable.filterFunc ? null : f
            }
        }

        Button {
            height : parent.height
            anchors.bottom: parent.bottom
            text : arrangable.model !== masterModel ? "Use LM" : "Use Arr"
            onClicked : {

                orig.model = arrangable.model = arrangable.model !== masterModel ? masterModel : master;
            }
        }


    }



    Component {
        id : simpleDel
        Rectangle {
            border.width: 1

            property int index
            property var model
            Rectangle {
                width : height
                height : parent.height * 0.8
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 5
                border.width: 1
                MouseArea {
                    anchors.fill: parent
                    onClicked : parent.color = Qt.rgba(Math.random(), Math.random(), Math.random());
                }
            }

            Text {
                anchors.fill: parent
                font.pixelSize: height * 1/3
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
//                    text             : parent.model ? JSON.stringify(parent.model) : "N/A"
                text : {
                    if(!parent.model)
                        return "N/A"
                    else if(typeof parent.model === 'string')
                        return parent.model
                    else if(parent.model.text)
                        return parent.model.text
                    return ""

                }

//                onTextChanged: console.log(text)
            }
        }
    }




}
