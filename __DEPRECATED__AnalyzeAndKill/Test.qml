import QtQuick 2.5
import Zabaat.Utility 1.0
import Zabaat.Material 1.0
import Zabaat.Shaders 1.0 as Fx
import Zabaat.MVVM 1.0
import QtQuick.Controls 1.4

Rectangle {
    id : rootObject
    objectName : "test.qml"
    color : 'lightyellow'

    Button {
        anchors.centerIn: parent
        onClicked : testThis();
        text : "Test Splice"
    }


    function testThis(){
        var myFish = RestArrayCreator.create(['angel', 'clown', 'mandarin', 'surgeon']);

        function dispMsg(actual,expected){
            return "\nactual: ["  + actual + "]\nexpected: [" +  expected + "]\n";
        }

        // removes 0 elements from index 2, and inserts 'drum'
        var removed = myFish.splice(2, 0, 'drum');
        // myFish is ['angel', 'clown', 'drum', 'mandarin', 'surgeon']
        // removed is [], no elements removed

        // myFish is ['angel', 'clown', 'drum', 'mandarin', 'surgeon']
        // removes 1 element from index 3
        removed = myFish.splice(3, 1);
        // myFish is ['angel', 'clown', 'drum', 'surgeon']
        // removed is ['mandarin']

        // myFish is ['angel', 'clown', 'drum', 'surgeon']
        // removes 1 element from index 2, and inserts 'trumpet'
        removed = myFish.splice(2, 1, 'trumpet');       //<-- THIS IS WHERE IT FAILS !
        // myFish is ['angel', 'clown', 'trumpet', 'surgeon']
        // removed is ['drum']

        // myFish is ['angel', 'clown', 'trumpet', 'surgeon']
        // removes 2 elements from index 0, and inserts 'parrot', 'anemone' and 'blue'
        //removed = myFish.splice(0, 2, 'parrot', 'anemone', 'blue');
        // myFish is ['parrot', 'anemone', 'blue', 'trumpet', 'surgeon']
        // removed is ['angel', 'clown']

        // myFish is ['parrot', 'anemone', 'blue', 'trumpet', 'surgeon']
        // removes 2 elements from index 2
        //removed = myFish.splice(myFish.length -3, 2);
        // myFish is ['parrot', 'anemone', 'surgeon']
        // removed is ['blue', 'trumpet']
    }



//    Text {
//        id : fpsText
//        property real t
//        property int frame: 0
//        color: "red"
//        text: "? Hz"

//        Timer {
//            id: fpsTimer
//            property real fps: 0
//            repeat: true
//            interval: 1000
//            running: true
//            onTriggered: {
//                parent.text = "FPS: " + fpsTimer.fps + " Hz"
//                fps = fpsText.frame
//                fpsText.frame = 0
//            }
//        }

//        NumberAnimation on t {
//            id: tAnim
//            from: 0
//            to: 100
//            loops: Animation.Infinite
//        }

//        onTChanged: {
//            update() // force continuous animation
//            ++frame
//        }
//    }





}
