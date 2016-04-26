import "../"
import QtQuick 2.5
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import Zabaat.Utility 1.1

Rectangle {
    visible: true
    width : Screen.width
    height : Screen.height - 300
    color : "lightBlue"

    Loader {
        anchors.fill: parent
        sourceComponent: testMain

        Button {
            anchors.right : parent.right
            text : 'refresh'
            onClicked : {
                parent.sourceComponent = null
                parent.sourceComponent = testMain
            }
        }





    }

    function prettify(arr){
        function stringerify(arr){
            var s = "";
            for(var i = 0; i < arr.length ; ++i){
                s += i !== arr.length - 1 ? arr[i] + "," : arr[i]
            }
            return s;
        }

        var str = ""
        for(var a = 0; a < arr.length; ++a){
            str += a + " : " + stringerify(arr[a]) + "\n"
        }
        return str;
    }
    Component {
        id : testMain
        Item {
            ListModel {
                id : testModel
                ListElement { number : 0 }
                ListElement { number : 1 }
                ListElement { number : 2 }
                ListElement { number : 3 }
                ListElement { number : 4 }
                ListElement { number : 5 }
                ListElement { number : 6 }
                ListElement { number : 7 }
                ListElement { number : 8 }
                ListElement { number : 9 }
            }

            Row {
                width : parent.width * 0.7
                height : parent.height * 0.9
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                spacing : width/12

                ArrangableList {
                    id : al
                    width : parent.width/4
                    height : parent.height/2
                    model : testModel
                    delegateCellHeight : height * 0.1

                    delegate   : Component {
                        id : cmp
                        Rectangle {
                            property int index;
                            property var model;
                            border.width: 1
                            Text {
                                anchors.fill: parent
                                font.pixelSize : height * 1/3
                                text        : parent.model ? parent.model.number : ""
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }
                }

                ListView {
                    id     : intermediate
                    width  : parent.width/4
                    height : parent.height/2
                    model  : al.logic.zsubOrig
                    delegate : Rectangle {
                        property var model : intermediate.model.get(index)
                        width : intermediate.width
                        height : intermediate.height * 0.1
                        border.width: 1
                        Text {
                            anchors.fill: parent
                            font.pixelSize : height * 1/3
                            text        : parent.model ? parent.model.number : ""
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }

                ListView {
                    id     : orig
                    width  : parent.width/4
                    height : parent.height/2
                    model  : testModel
                    delegate : Rectangle {
                        property var model : testModel.get(index)
                        width : orig.width
                        height : orig.height * 0.1
                        border.width: 1
                        Text {
                            anchors.fill: parent
                            font.pixelSize : height * 1/3
                            text        : parent.model ? parent.model.number : ""
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }





            }


            Column {
                Row {

                    Button {
                        text: "undo"
                        onClicked : al.undo()
                    }

                    Button {
                        text : "deselect All"
                        onClicked : al.deselectAll()
                    }

                    Button {
                        text : "select All"
                        onClicked : al.selectAll()
                    }

                    Button {
                        text: "move to top"
                        onClicked : al.moveSelectedTo(0);
                    }

                    Button {
                        text: "redo"
                        onClicked : al.redo()
                    }

                    Button {
                      text : "odd filter"
                      onClicked: al.filterFunc = al.filterFunc === parent.oddFilter ? null : parent.oddFilter
                    }

                    Button {
                      text : "even filter"
                      onClicked: al.filterFunc = al.filterFunc === parent.evenFilter ? null : parent.evenFilter
                    }


                    function oddFilter(a) { return a.number % 2 === 1; }
                    function evenFilter(a) { return a.number % 2 === 0; }
                }

                Text { text : "origCount:" +  al.count_Original  }
                Text { text : "subOrigCount:" +  al.count_ZSubOrignal }
                Text { text : "subChangerCount:" +  al.count_ZSubChanger }
                Text { text : "selection:"  + JSON.stringify(al.logic.selected) + " " + al.logic.selectedLen  + "\n\t\tCtrl:"   + al.gui.ctrlModifier + "\tShift:" + al.gui.shiftModifier }
                Text { text : "undos:\n" + prettify((al.logic.undos())) ; height : paintedHeight + 5}
                Text { text : "redos:\n" + prettify((al.logic.redos())) }
            }




        }


    }




}
