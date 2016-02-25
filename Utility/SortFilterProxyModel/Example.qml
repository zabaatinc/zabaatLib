import QtQuick 2.0
import Zabaat.Utility.SortFilterProxyModel 1.0

Item {
    id : rootObject
    width : 640
    height : 480

    property int cellHeight : height * 0.1
    ListModel {
        id : original
        ListElement { name : "Wolf"            }
        ListElement { name : "Wolverine"       }
        ListElement { name : "Wolferino"       }
        ListElement { name : "Wolfasaurus"     }
        ListElement { name : "WolfasaurusRex"  }
        ListElement { name : "Brett"           }
        ListElement { name : "Bretterine"      }
        ListElement { name : "Bretterino"      }
        ListElement { name : "Brettasaurus"    }
        ListElement { name : "BrettasaurusRex" }
    }
    SortFilterProxyModel {
        id : sfpm
        source : original
        filterSyntax: SortFilterProxyModel.RegExp
        filterCaseSensitivity: Qt.CaseInsensitive
        filterRole: "name"
    }


    Row {
        anchors.fill: parent
        ListView {
            id : unfilteredList
            width : parent.width/2
            height : parent.height
            delegate : delegateComponent
            model : original
        }
        Item {
            width : parent.width/2
            height : parent.height

            Rectangle {
                width : parent.width
                height : parent.height * 0.1
                TextInput {
                    id : searchTerm
                    anchors.centerIn: parent
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    Component.onCompleted: forceActiveFocus()
                    onTextChanged : {
                        if(text !== "")
                            doSimpleSearch(text)
                        else
                            doSimpleSearch("")
                    }
                }
            }

            ListView {
                id : filteredList
                width : parent.width/2
                height : parent.height * 0.9
                anchors.bottom: parent.bottom
                model : sfpm
                delegate : delegateComponent
            }


        }
    }

    property bool exactSearch : false
    function doSimpleSearch(str){
        if(str.length === 0)
            str = "*"

        if(exactSearch)          sfpm.setFilterRegExp("^(" + str + ")$")
        else                     sfpm.setFilterWildcard(str)
    }



    Component {
        id : delegateComponent
        Rectangle {
            width : rootObject.width/2
            height : rootObject.cellHeight
            border.width: 1
            Text {
                anchors.centerIn: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text : name
            }
        }


    }
}
