import QtQuick 2.5
import Zabaat.Material 1.0
import Zabaat.Utility 1.0

Item {
    id : rootObject

    Component.onCompleted: requestMore(gv.count, gv.numElemsPerPage * 2);

    function randPerson(){
        return {
            first : Chance.first(),
            last  : Chance.last(),
            clr   : Qt.rgba(Math.random(), Math.random(), Math.random()),
            age   : Chance.age()
        }
    }
    function requestMore(skip, n){
        var arr =  Chance.n(randPerson,n)
        gv.model.append(arr)
    }

    Component {
        id : subComponent
        Rectangle {
            width : rootObject.cellDim
            height : rootObject.cellDim



            property alias text : subComponent_Text.text
            border.width: 1
            border.color : Colors.getContrastingColor(color,2)
            clip : true
            Text {
                id : subComponent_Text
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color : Colors.contrastingTextColor(parent.color)
                anchors.fill: parent
            }

        }
    }

    GridView {
        id : gv
        anchors.fill: parent
        clip : true
        cellHeight : cellWidth
        cellWidth : width / numColsPerPage
        Rectangle {
            width : childrenRect.width
            height : childrenRect.height
            color : 'black'
            Text {
                id : calcText
                font.pixelSize: 20
                color : 'red'
                width : paintedWidth
                height : paintedHeight
            }
            Text {
                id: textCount
                font.pixelSize: 20
                color : 'red'
                text : "count:" +  gv.count
                anchors.top: calcText.bottom
                width : paintedWidth
                height : paintedHeight
            }
            Text {
                font.pixelSize: 20
                color : 'red'
                text : "Threshold:" +  gv.requestWhenRemaining + " pg:" + (gv.currentPage+1) + "/" + gv.totalPages
                anchors.top: textCount.bottom
                width : paintedWidth
                height : paintedHeight
            }
        }

        property int numRowsPerPage      : height / cellHeight
        property int numColsPerPage      : 3
        property int numElemsPerPage     : numRowsPerPage * numColsPerPage
        property int requestWhenRemaining: numElemsPerPage * 2
        property int topIdx              : indexAt(0, contentY)
        property int currentPage         : topIdx / numElemsPerPage
        property int totalPages          : count / numElemsPerPage

        model : ListModel {
            id : lm
            dynamicRoles : true
        }
        delegate : Loader {
            width : gv.cellWidth
            height : gv.cellHeight
            sourceComponent: subComponent
            onLoaded : if(item) {
                           item.color = model.clr
                           item.text  = model.first + "\n" + model.last + "\n" + model.age
                       }
        }
        onWidthChanged   : getMoreIfNeeded()
        onHeightChanged  : getMoreIfNeeded()
        onContentYChanged: getMoreIfNeeded()
        onModelChanged   : if(model)
                               getMoreIfNeeded()


        function getMoreIfNeeded(){
            calcText.text = gv.model.count.toString() + " - " + topIdx.toString()
                            + " = " + (gv.model.count - topIdx).toString()
            if(topIdx !== -1 && gv.model.count - topIdx <= requestWhenRemaining){
                requestMore(count, numElemsPerPage)
            }
        }
    }



}
