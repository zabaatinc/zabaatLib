import QtQuick 2.5
import Zabaat.Material 1.0
Item {
    id : rootObject
    property real h : height * 0.07
    property real w : h * 4

    Column {

        width : childrenRect.width
        height : childrenRect.height
        anchors.centerIn: parent
        spacing: 20

        ZChipBox {
            width : w
            height : h
            text : "hello"
        }


        ZChip {
            width : w
            height : h
            text : "hello"
            label : "H"
        }

        ZChip {
            width : w
            height : h
            text : "hello"
        }

        ZChip {
            width : w
            height : h
            text : "hello"
            state : 'close'
        }

        ZChip {
            width  : w
            height : h
            text   : "Wolf"
            label  : "http://img-cache.cdn.gaiaonline.com/2f45d08d3ccb85bcfbee269c8671a266/http://i155.photobucket.com/albums/s296/drunkonshadows2/Other/wolf.jpg"
            labelIsImage: true
        }

        ZChip {
            width  : w
            height : h
            text   : "hello"
            label  : "M"
            state  : 'close'
        }

        ZChip {
            width  : w
            height : h
            text   : "Wolf"
            label  : "http://img-cache.cdn.gaiaonline.com/2f45d08d3ccb85bcfbee269c8671a266/http://i155.photobucket.com/albums/s296/drunkonshadows2/Other/wolf.jpg"
            state  : 'close'
            labelIsImage: true
        }

    }



}
