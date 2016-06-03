import QtQuick 2.5
import Zabaat.Material 1.0
import "../components/skins/default/helpers"
import Zabaat.Utility 1.0
Item {
    id : rootObject
    property real h : height * 0.07
    property real w : h * 4
    property string coolImage : "http://img-cache.cdn.gaiaonline.com/2f45d08d3ccb85bcfbee269c8671a266/http://i155.photobucket.com/albums/s296/drunkonshadows2/Other/wolf.jpg"


//    ZImageButton {
//        source : coolImage
//        width : height
//        height : 128
//        anchors.centerIn: parent
//        z : Number.MAX_VALUE
////        radius : height/2
////        state : 'accent-circle'
//    }

    Column {
        width : parent.width / 2
        height : parent.height * 0.1
        anchors.horizontalCenter: parent.horizontalCenter
        Item {
            width : parent.width
            height : parent.height/2
            ZTextBox {
                id : chipMaker
                anchors.fill: parent
                property string name : "f1text"
                onAccepted : {
//                    console.log('on accepted')
                    var chip = chipFactory.createObject(col);
                    chip.text = text;

                    chip.state = hasClose.state !== '' ? 'close' : ""
                    chip.labelIsImage = true;
                }
                state : 'b1-f1'
            }
            ZButton {
                width : height
                height : parent.height
                anchors.left: chipMaker.right
                onClicked : chipMaker.selectWord(1);
                text : "SELECT"
            }
        }




        Row {
            width : parent.width
            height : parent.height/2
            property real w : width / 3


            ZButton {
                id : hasClose
                text : "Can Close"
                onClicked : state = state === "" ? "accent" : ""
                width : parent.w
                height : parent.height
            }
            ZButton {
                id : isLabel
                text : "Is Label"
                onClicked : state = state === "" ? "accent" : ""
                width : parent.w
                height : parent.height
            }



        }

    }
    Component {
        id : chipFactory
        ZChip {
            width : w
            height : h
        }
    }


    Column {
        id : col
        width : childrenRect.width
        height : childrenRect.height
        anchors.centerIn: parent
        spacing: 20

        ZChipBox {
            width : w
            height : h
            chipState: "square-close"
            chipCloseButtonState: "transparent-f2"
            chipCloseButtonText: "X"
//            textBoxState: "b3"

            chipModifierFunc: function(name,item) {
                if(Colors.names[name]) {
                    item.setColor(Colors.names[name])
                }
            }


        }


        ZChip {
            width : w
            height : h
            text : "hello"
            label : "H"
            onClose: destroy()
        }

        ZChip {
            width : w
            height : h
            text : "hello"
            onClose: destroy()
        }

        ZChip {
            width : w
            height : h
            text : "hello"
            state : 'close'
            onClose: destroy()
        }

        ZChip {
            width  : w
            height : h
            text   : "Wolf"
            label  : coolImage
            labelIsImage: true
            onClose: destroy()
        }

        ZChip {
            width  : w
            height : h
            text   : "hello"
            label  : "M"
            state  : 'close'
            onClose: destroy()
        }

        ZChip {
            width  : w
            height : h
            text   : "Wolf"
            label  : coolImage
            state  : 'close'
            labelIsImage: true
            onClose: destroy()
        }

    }




    Row {
        anchors.centerIn: parent
        height : parent.height * 0.25
        width : childrenRect.width
        spacing : 10
        z : Number.MAX_VALUE
        SemiCircle {
            id : sc
            width  : height/2
            height : parent.height
            state  :'right'
        }

        SemiCircle {
            width  : parent.height
            height : width/2
            state  :'up'
            radius : sc.radius
        }

        SemiCircle {
            width  : parent.height
            height : width/2
            state  :'down'
            radius : sc.radius
        }

        SemiCircle {
            width  : height/2
            height : parent.height
            radius : sc.radius
        }
        visible : false
    }




}
