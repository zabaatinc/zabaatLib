import Zabaat.Utility 1.1
import QtQuick.Controls 1.4
import QtQuick 2.5

Item {

    function printIndexList(submodel){
        var indices = submodel.indexList
        var t = "";
        for(var i = 0; i < submodel.indexList.length; ++i) {
            t += i === submodel.indexList.length - 1 ? submodel.indexList[i] :
                                                   submodel.indexList[i] + ","
        }
        return t;
    }

    ListModel {
        id : orig
        ListElement { num : "A" ; clr : "white"     }
        ListElement { num : "B" ; clr : "green"     }
        ListElement { num : "C" ; clr : "red"       }
        ListElement { num : "D" ; clr : "lightblue" }
    }

    ListModel {
        id : orig2
        ListElement { num : "E" ; clr : "white"     }
        ListElement { num : "F" ; clr : "green"     }
        ListElement { num : "G" ; clr : "red"       }
        ListElement { num : "H" ; clr : "lightblue" }
    }

    Button {
        onClicked : sub1.sourceModel === orig ? sub1.sourceModel = orig2 : sub1.sourceModel = orig
    }


    ZSubModel {
        id : sub1;
        objectName : "sub1"
        sourceModel : orig ;
    }
    ZSubModel { id : sub2; objectName : "sub2"; sourceModel : sub1; }
    Text { text : orig.count + "\t" + sub1.count + "\t" + sub2.count }

    Row {
        anchors.fill: parent
        anchors.margins: 40
        property int w : width / 3

        ListView {
            id : lv0
            width : parent.w
            height : parent.height
            model : orig
            delegate : Rectangle {
                width  : lv.width
                height : lv.height * 0.1
                color : clr
                Text {
                    anchors.fill: parent
                    text : num + " @" + index
                    font.pixelSize: height * 1/3
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

        }

        ListView {
            id : lv
            width : parent.w
            height : parent.height
            model : sub1
            delegate : Rectangle {
                width  : lv.width
                height : lv.height * 0.1
                color : clr
                Text {
                    anchors.fill: parent
                    text : num  + "  @" + sub1.indexList[index]
                    font.pixelSize: height * 1/3
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }

            Text {
                anchors.top: lv.top
                anchors.topMargin: lv.contentHeight
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment : Text.AlignVCenter
                width : lv.width
                height : lv.height * 0.1
                font.pixelSize : height * 1/3
                text : printIndexList(sub1)
            }

        }

        ListView {
            id : lv2
            width : parent.w
            height : parent.height
            model : sub2
            delegate : Rectangle {
                width  : lv.width
                height : lv.height * 0.1
                color : sub2.get(index) ? sub2.get(index).clr : ""
                Text {
                    anchors.fill: parent
                    text : sub2.get(index) ? sub2.get(index).num + "  @" + sub2.indexList[index] : ""
                    font.pixelSize: height * 1/3
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            Text {
                anchors.top: lv2.top
                anchors.topMargin: lv2.contentHeight
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment : Text.AlignVCenter
                width : lv2.width
                height : lv2.height * 0.1
                font.pixelSize : height * 1/3
                text : printIndexList(sub2)
            }
        }
    }


    Column {
        id : menu
        height : parent.height
        width : parent.width * 0.05

        function randIdx(){
            return Math.floor(Math.random() * orig.count)
        }

        Button {
            width : parent.width
            height : width
            text : "Add"
            property color css: "red"
            onClicked : {

                orig.append({num:orig.count.toString(), clr:"white"})
            }
        }

        Button {
            width : parent.width
            height : width
            text : 'Data Change'
            onClicked : {
//                lv.model = null
                orig.get(parent.randIdx()).num += 1
//                lv.model = orig
            }
        }

        Button {
            width : parent.width
            height : width
            text : 'Delete'
            onClicked : if(orig.count > 0)  orig.remove(parent.randIdx())
        }

        Button {
            width : parent.width
            height : width
            text : 'move'
            onClicked : orig.move(0,2,2);
        }



    }




}
