import QtQuick 2.0
import QtTest 1.0
import Zabaat.Utility.FileIO 1.0 as U
import Zabaat.Utility 1.0
import Zabaat.Testing 1.0
import Zabaat.Oaths 1.0
ZabaatTest {
    id : rootObject
    objectName : "Oath"
    testObj: Oath {
        id : oath
    }
    windowShown: true;

    function init(){

    }
    function cleanup(){
        clearSignals();
        testItemContainer.clear();
    }

    function test_01_longImage() {
        var img    = imgFactory.createObject(testItemContainer);
        var timer  = timerFactory.createObject(testItemContainer);

        oath.resolveWhen = Qt.binding(function() { return img.status === Image.Ready })
        oath.rejectWhen  = Qt.binding(function() { return timer.triggered })

        timer.interval = 100;
        timer.start();
        img.source = "https://upload.wikimedia.org/wikipedia/commons/3/3f/Fronalpstock_big.jpg"

        wait(100);



    }



    Item {
        id : testItemContainer
        function clear(){
            for(var i = children.length; i >= 0; i--) {
                var child = children[i]
                child.destroy();
                child.parent = null;
            }
            children = [];
        }
    }


    Item {
        id : components
        Component { id : imgFactory   ; Image { id:img   ; asynchronous: true } }
        Component { id : timerFactory ; Timer { id:timer                      } }
    }





}
