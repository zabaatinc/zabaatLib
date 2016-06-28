import QtQuick 2.0
import Zabaat.Utility 1.0

Item {

    Text {
        anchors.left: parent.left
        anchors.leftMargin: 20
        text : 'offset ' + es.pageOffset + '\t total ' + es.gv.totalPages + "\t total count " + lm.count + '_'  + es.gv.count

        z : Number.MAX_VALUE
        font.pixelSize: parent.height * 1/20
        color : 'red'
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 20
        text : es.gv.topIdx + "/" + es.gv.numElemsPerPage + '=' + es.gv.currentPage
        z : Number.MAX_VALUE
        font.pixelSize: parent.height * 1/20
        color : 'red'
    }

    EndlessScroller {
        id : es
        anchors.fill  : parent
        pageOffset    : 5
        requestOnStart: true
        rows: 10

        model : ListModel {
            id : lm
        }




        onPageReceived: {
//            console.log("PAGE GOTTEN", page)
            if(isBeginning){
                console.log("inserted" , page)
                lm.insert(0, data)
//                if(isBeginning){
//                    gv.currentIndex += data.length
//                }
            }
            else {
                console.log("appended" , page)
                lm.append(data)
            }
        }




    }

}
