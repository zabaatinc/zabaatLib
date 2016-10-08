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
    Component.onCompleted: {
        forceActiveFocus();

        var o = [
            { id : 420,
              name : "Shahan",
              hobbies : ['a',{'b':'battling'},'c'],
              pets : [{ id : 99, name : "woof"} ,
                      { id : 100 , name : "fu"}]

            } //,
//            { id : 666, name : "Fahad" , pets : [{ id : 99, name : "woof"} ,{ id : 100 , name : "fu"}]} ,
//            { id : 786, name : "Brett" , pets : [{ id : 99, name : "woof"} ,{ id : 100 , name : "fu"}]} ,
//            { id : 999, name : "Pika"  , pets : [{ id : 99, name : "woof"} ,{ id : 100 , name : "fu"}]}
        ]

//        var ms = Functions.time.mstimer()
//        RestArrayCreator.debugOptions.showPaths   = true;
//        RestArrayCreator.debugOptions.showData    = true;
//        RestArrayCreator.debugOptions.showOldData = true;
//        var arr = RestArrayCreator.create(o);

//        arr[0].name = "wolf"
//        arr[0].hobbies = ["derp","herp"];

//        console.log(JSON.stringify(hexToRgb("#ff00ff")));
//        console.log(JSON.stringify(hexToRgb("#9900ffff")));

        ZAnimator.createColorAnimation ("bleed" , ["red",'darkRed'])
        ZAnimator.createColorAnimation ("flashy", ["white","black"])
        ZAnimator.createNumberAnimation('shake' , [20, 0 , -20, 0]);
//        ZAnimator.runAnimation(colorRect,"bleed",'color','500',2,function(){
//            ZAnimator.runAnimation(colorRect,"flashy",'color','500')
//        })

        ani = ZAnimator.sequentialAnimationRunner(colorRect)
                    .add('bleed')
                    .add('shake','x,y',333,3)
                    .start().onEnd(function(){
                        console.log("animation finished")
                    });






//        ZAnimator.createUniformColorAnimation()
//        var allSignalsFired = RestArrayCreator.debugOptions.all();
//        console.log(allSignalsFired.join('\n'));
    }

    property var ani
    SequentialAnimation {
        id : seq
    }


    Rectangle {
        id : colorRect
        x : (parent.width - width)/2
        y : (parent.height - height)/2
        width : height
        height : 64
        border.width: 1
        property color c2

        Column {
            anchors.left: parent.right
            Button {
                text : "Pause"
                onClicked: ani.pause();
            }
            Button {
                text : "Stop"
                onClicked: ani.stop();
            }
            Button {
                text : "Start"
                onClicked: ani.start();
            }
        }
    }




    Text {
        id : fpsText
        property real t
        property int frame: 0
        color: "red"
        text: "? Hz"

        Timer {
            id: fpsTimer
            property real fps: 0
            repeat: true
            interval: 1000
            running: true
            onTriggered: {
                parent.text = "FPS: " + fpsTimer.fps + " Hz"
                fps = fpsText.frame
                fpsText.frame = 0
            }
        }

        NumberAnimation on t {
            id: tAnim
            from: 0
            to: 100
            loops: Animation.Infinite
        }

        onTChanged: {
            update() // force continuous animation
            ++frame
        }
    }





}
