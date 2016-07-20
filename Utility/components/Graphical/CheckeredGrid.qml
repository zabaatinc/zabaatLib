import QtQuick 2.5
GridView {
    id : rootObject
    property int rows    : 8
    property int columns : 8
    property color color1 : 'black'
    property color color2 : 'white'
    property var delegateComponent : rectCmp

    interactive: false
    model : rows * columns

    cellWidth  : width / columns
    cellHeight : height / rows

    delegate : Loader {
        width  : cellWidth
        height : cellHeight
        property int  rowNum : index / columns
        property int  colNum : index % columns
        property bool alt    : (rowNum % 2 === colNum % 2)
        onLoaded : {
            if(item.hasOwnProperty("index"))
                item.index = alt;
        }
        sourceComponent:rootObject.delegateComponent
    }



    Component {
        id : rectCmp
        Rectangle {
            property int index : 0;
            color : index ? color1 : color2
        }
    }

}
