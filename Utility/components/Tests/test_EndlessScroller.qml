import QtQuick 2.0
import Zabaat.Utility 1.0

Item {

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 20
        text : 'offset ' + es.pageOffset + '\t total ' + es.gv.totalPages + "\t total count " + lm.count + '_'  + es.gv.count

        z : Number.MAX_VALUE
        font.pixelSize: parent.height * 1/40
        color : 'red'
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 20
        text : es.gv.topIdx + " - " + es.gv.requestWhenRemaining + " = " + (es.gv.topIdx - es.gv.requestWhenRemaining) + "\n" + es.pageOffset//+  es.gv.currentPage
        z : Number.MAX_VALUE
        font.pixelSize: parent.height * 1/40
        color : 'red'
    }

    Text {
        id : pages
        anchors.horizontalCenter: parent.horizontalCenter
        font.pixelSize: parent.height * 1/40
        color : 'red'
        text : es.logic.pagesRequested.sort().toString()
        z : Number.MAX_VALUE
        Connections {
            target : es
            onPageReceived : pages.text = es.logic.pagesRequested.sort().toString()
        }

    }


    EndlessScroller {
        id : es
        anchors.fill  : parent
        pageOffset    : 5
        requestOnStart: true
        columns : 2
        rows: 10

        model : ListModel {
            id : lm
        }

        onItemSelected: console.log("item selected" , JSON.stringify(model))



        onPageReceived: {
            var d = new Date();
            if(isBeginning){
//                console.log("inserted" , page ,"\t", d.getHours(), ":",  d.getMinutes(), ":", d.getSeconds() , ":" , d.getMilliseconds())
                lm.insert(0, data)

//                es.gv.contentY += 702// this will be handled inside!!
            }
            else {
//                console.log("appended" , page, "\t", d.getHours(), ":",  d.getMinutes(), ":", d.getSeconds() , ":" , d.getMilliseconds())
                lm.append(data)

            }
        }




    }

}
