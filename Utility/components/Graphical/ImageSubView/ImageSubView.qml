import QtQuick 2.5

//Displays the part of the image determined by the subRect property
Item {
    id : rootObject

    //is in percentage of the image!
    property rect subRect : Qt.rect(0,0,1,1)    //full
    property alias source : img.source
    property alias cache  : img.cache
    clip : true

    Image {
        id       : img
        fillMode : Image.Stretch
        property real w: rootObject.width
        property real h: rootObject.height

        width    : (2-subRect.width)      * w
        height   : (2-subRect.height)     * h
        x        : -subRect.x          * w
        y        : -subRect.y          * h
    }


//    Text {
//         text : subRect.toString()
//         color : 'red'
//         anchors.centerIn: parent
//    }

}
