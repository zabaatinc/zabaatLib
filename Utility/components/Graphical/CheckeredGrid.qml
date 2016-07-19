import QtQuick 2.5
GridView {
    property int rows    : 8
    property int columns : 8
    property color color1 : 'black'
    property color color2 : 'white'
    interactive: false
    model : rows * columns

    cellWidth  : width / columns
    cellHeight : height / rows

    delegate : Rectangle {
        width  : cellWidth
        height : cellHeight

        property int rowNum : index / columns
        property int colNum : index % columns
        color : (rowNum % 2 === colNum % 2) ? color1 : color2

    }

}
