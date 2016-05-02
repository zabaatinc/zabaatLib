import Zabaat.Material 1.0
import QtQuick 2.0
import Zabaat.Utility 1.0
import QtQuick.Controls 1.4
Item {
    id : rootObject
    anchors.fill: parent

    Keys.onReleased: {
        switch(event.key){
            case Qt.Key_Delete: del(herp.currentIndex); break;
            case Qt.Key_Minus : del(herp.currentIndex); break;
            case Qt.Key_Plus  : create();               break;

        }
        event.accepted = true;
    }


    Text {
        property string itemStr: herp.currentItem ? herp.currentItem.toString() : ""

        anchors.right: parent.right
        text : herp.currentIndex + " out of " + herp.count + "\n" + itemStr
        font.pixelSize: herp.height * 1/20
    }

    function create(name){
        var r = rectFactory.createObject(null);
        r.objectName = name ? name : Chance.color({format:"hex"})
        r.parent = herp;
    }

    function del(i){
        if(i < herp.count) {
            var item = herp.get(i)
            if(item){
                item.destroy()
            }
        }
    }

    Component.onCompleted: {
        forceActiveFocus()
        create('red')
        create('blue')
    }


    Row {
        Button {
            text : "+"
            onClicked : create()
        }

        Button {
            text : "-"
            onClicked : {
                del(Math.floor(Math.random() * ims.length))
            }
        }

        Button {
            text : herp.state !== 'instant' ? "instant" : "default"
            onClicked : {
                herp.state = herp.state !== 'instant' ? 'instant' : 'default'
            }
        }

        Button {  text : 'left';   onClicked : herp.state += "-" + text;  }
        Button {  text : 'right';  onClicked : herp.state += "-" + text;  }
        Button {  text : 'top';    onClicked : herp.state += "-" + text;  }
        Button {  text : 'bottom'; onClicked : herp.state += "-" + text;  }

        Button {  text : 'fill'; onClicked : herp.state += "-" + text;  }
        Button {  text : 'nofill'; onClicked : herp.state += "-" + text;  }

    }


    Text {
        text : herp.currentItem ? herp.currentItem.title : ""
        anchors.centerIn: parent
        font.pixelSize : parent.height * 1/3
        z : 999
    }


    ZSwipeView {
        id : herp
        width : parent.width/2
        height : parent.height/2
        anchors.centerIn: parent
        state : "fill-vertical-superslow"


    }

    Rectangle {
        anchors.fill: herp
        border.width: 1
        color : 'transparent'
    }


    Component {
        id : rectFactory
        Rectangle {
            property string title : objectName
            color : objectName
//            Component.onDestruction: console.log(objectName,"IS DYING")
        }
    }


}
