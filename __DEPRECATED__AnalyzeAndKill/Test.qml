import QtQuick 2.5
import Zabaat.Utility 1.0
import Zabaat.Material 1.0
import Zabaat.Shaders 1.0 as Fx
import Zabaat.MVVM 1.0

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

        ZAnimator.createUniformColorAnimation("bleed" , ["red",'darkRed'])
        ZAnimator.createUniformColorAnimation("flashy", ["red","yellow",'blue','green','blue','yellow'])
//        ZAnimator.runAnimation(colorRect,"bleed",'color','500',2,function(){
//            ZAnimator.runAnimation(colorRect,"flashy",'color','500')
//        })

        var anikin = ZAnimator.factory()
        anikin(colorRect).add('bleed','color',2).add('flashy').start();

        Functions.time.setTimeOut(1000, function() {
            anikin.stop();
            anikin.start();
        })

//        then(function(f){
//            f.run('flashy')
//        })




        //(colorRect).run('bleed','color', 500).run('flashy');
//        ZAnimator.runAnimation(colorRect,"bleed",'color','500',2).then('flashy').then(function(){})




//        ZAnimator.createUniformColorAnimation()
//        var allSignalsFired = RestArrayCreator.debugOptions.all();
//        console.log(allSignalsFired.join('\n'));
    }


    function chainer(){
        var target
        var fn = function(t){
            target = t
        }

        fn.run = function(a){
            console.log("run",a)
            return fn;
        }

        return fn;
    }


    Row {
        anchors.top : colorRect.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        ZTextBox {
            id : r
            height : 32
            width  : height
            onTextChanged: colorRect.color = rgbToHex(r.text,g.text,b.text,a.text)
            state : 'standard-b1-f3'
            text : "1"
            onActiveFocusChanged: if(activeFocus)
                                      selectAll();
        }
        ZTextBox {
            id : g
            height : 32
            width  : height
            onTextChanged: colorRect.color = rgbToHex(r.text,g.text,b.text,a.text)
            state : 'standard-b1-f3'
            text : "1"
            onActiveFocusChanged: if(activeFocus)
                                      selectAll();
        }
        ZTextBox {
            id : b
            height : 32
            width  : height
            onTextChanged: colorRect.color = rgbToHex(r.text,g.text,b.text,a.text)
            state : 'standard-b1-f3'
            text : "1"
            onActiveFocusChanged: if(activeFocus)
                                      selectAll();
        }
        ZTextBox {
            id : a
            height : 32
            width  : height
            onTextChanged: colorRect.color = rgbToHex(r.text,g.text,b.text,a.text)
            state : 'standard-b1-f3'
            text : "1"
            onActiveFocusChanged: if(activeFocus)
                                      selectAll();
        }
        width : childrenRect.width
        height : childrenRect.height
    }

    CheckeredGrid {
        anchors.centerIn: parent
        width : height
        height : 64
        rows : 3
        columns: 3
    }

    Rectangle {
        id : colorRect
        anchors.centerIn: parent
        width : height
        height : 64
        border.width: 1

//        SequentialAnimation {
//            id : seqAnim
//            property var target : colorRect
//            running : true
//            loops : Animation.Infinite
//            ColorAnimation {
//                target: seqAnim && seqAnim.target ? seqAnim.target : null
//                to: "black"
//                duration: 200
//                properties: 'color'
//            }
//            ColorAnimation {
//                target: seqAnim && seqAnim.target ? seqAnim.target : null
//                to: "white"
//                duration: 200
//                properties: 'color'
//            }
//        }

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


    function rgbToHex(r,g,b,a){
        r = Math.floor(parseFloat(r) * 255);
        g = Math.floor(parseFloat(g) * 255);
        b = Math.floor(parseFloat(b) * 255);
        a = Math.floor(parseFloat(a) * 255);
        //http://stackoverflow.com/questions/5623838/rgb-to-hex-and-hex-to-rgb
        function componentToHex(c) {
            var hex = c.toString(16);
            return hex.length == 1 ? "0" + hex : hex;
        }
        return "#" + componentToHex(a) + componentToHex(r) + componentToHex(g) + componentToHex(b);
    }

    function hexToRgb(hex){
        //http://stackoverflow.com/questions/5623838/rgb-to-hex-and-hex-to-rgb
        var defaultVal = { r: 0, g : 0, b : 0, a : 1 }
        var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        if(result !== null){
            return {
                r: parseInt(result[1], 16)/255,
                g: parseInt(result[2], 16)/255,
                b: parseInt(result[3], 16)/255,
                a : 1
            }
        }

        //try regexing on 4. so we can  get a.
        result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
        return result ? {
            a: parseInt(result[1], 16)/255,
            r: parseInt(result[2], 16)/255,
            g: parseInt(result[3], 16)/255,
            b: parseInt(result[4], 16)/255
        } : defaultVal;
    }



}
