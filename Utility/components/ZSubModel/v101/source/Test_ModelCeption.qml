import Zabaat.Utility 1.1
import QtQuick.Controls 1.4
import QtQuick 2.5

Item {
    ListModel {
        id : orig
        ListElement { num : 1 ; clr : "white"     }
        ListElement { num : 2 ; clr : "green"     }
        ListElement { num : 3 ; clr : "red"       }
        ListElement { num : 4 ; clr : "lightblue" }
    }

    ListModel {
        id : orig2
        ListElement { num : 5 ; clr : "white"     }
        ListElement { num : 6 ; clr : "green"     }
        ListElement { num : 7 ; clr : "red"       }
        ListElement { num : 8 ; clr : "lightblue" }
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
                    text : num
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
                    text : num
                    font.pixelSize: height * 1/3
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
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
                color : clr
                Text {
                    anchors.fill: parent
                    text : num
                    font.pixelSize: height * 1/3
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
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
            onClicked : orig.append({num:orig.count})
        }

        Button {
            width : parent.width
            height : width
            text : 'Data Change'
            onClicked : {
                lv.model = null
                orig.get(parent.randIdx()).num += 1
                lv.model = orig
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
