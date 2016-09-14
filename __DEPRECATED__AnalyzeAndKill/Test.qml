import QtQuick 2.5
import Zabaat.Utility 1.0
import QtQuick.Controls 1.4
import Zabaat.Material 1.0
Item {
    id : rootObject

    property real physDpi:81.66564967695622  //96
    property real logicDpi : 96
    property real dpi : 96

    //on a 96 DPI screen, when we set 72 pt on Arial, we get a pixel size of 107.
    //We can reverse engineer this to figure out the dpi of ANY screen?

    function pt(p){
        //107, 72, 96 knowns
        return p/72 * (zabaatsConstant * ptText.paintedHeight);

        //        console.log("RES=",r)
//        return r;
    }
    property real zabaatsConstant : 96/107
    onZabaatsConstantChanged: console.log("zabaat's constant is =", zabaatsConstant);

    Text {
        id : ptText
        font.pointSize: 72  //paintedHeight of this will say this many pixels in an inch
        width         : paintedWidth
        height  : paintedHeight
        text    : "I"
        visible : false
        font.family: "Arial"
    }

    Row {
        anchors.centerIn: parent
        spacing : 30

        Text {
            font.pointSize: 72
            width : paintedWidth
            height : paintedHeight
            text : "Hello"
            Text {
                anchors.top: parent.bottom
                text : parent.paintedWidth + "," + parent.paintedHeight
            }
        }

        Text {
            font.pixelSize: pt(72)
            width  : paintedWidth
            height : paintedHeight
            text : "Hello"

            Text {
                anchors.top: parent.bottom
                text : parent.paintedWidth + "," + parent.paintedHeight
            }
        }

    }



//    function f1(time, arg){
////        console.log("f1")
//        if(!time || typeof time !== 'number')
//            time = 10

//        return Promises.promise(function(f,r) {
//          console.log("ARG:", arg);
//          Functions.time.setTimeOut(time, f, "happy")
//        })

//    }

//    //fails if first promise passed :P
//    function f2(fail){
////        console.log("f2",value)
//        return Promises.promise(function(f,r) {
//            if(fail) {
//                Functions.time.setTimeOut(50, r, "sadness")
//            }
//            else {
//                Functions.time.setTimeOut(500, f, "happiness")
//            }
//        })
//    }


//    Row {
//        anchors.centerIn: parent
//        Button {
//            text : 'standard'
//            onClicked : {
//                f1().then(f2).then(function(v) {
//                    console.log("success val:", v)
//                }).catch(function(r) {
//                    console.log("reason for failure:",r)
//                }).finally(function(f) {
//                    console.log("finally")
//                })
//            }
//        }

//        Button {
//            text : "all"
//            onClicked : {
//                var p1 = f1(100,'promise 1');
//                var p2 = f1(500,'promise 2');


//                Promises.all([p1,p2]).then(function() {
//                    console.log("herp")
//                }).catch(function(err){
//                    console.log("ERR REASON:", err)
//                }).finally(function(v) {
//                    console.log("finally")
//                })
//            }
//        }

//        Button {
//            text : "all succeed before"
//            onClicked : {
//                var p1 = Promises.promise(function(a,r) {
//                            a("1 true")  ;
//                         })

//                var p2 = Promises.promise(function(a,r) {
//                            a("2 true")  ;
//                         })


//                Promises.all([p1,p2]).then(function(val) {
//                    console.log("VALUE", JSON.stringify(val,null,2))
//                }).catch(function(err){
//                    console.log("ERR REASON:", err)
//                }).finally(function(v) {
//                    console.log("finally")
//                })
//            }
//        }

//        Button {
//            text : "all fail"
//            onClicked : {
//                var p1 = f1();
//                var p2 = f2(true);

//                Promises.all([p1,p2]).then(function(val) {
//                    console.log("VALUE", JSON.stringify(val,null,2))
//                }).catch(function(err){
//                    console.log("ERR REASON:", err)
//                }).finally(function(v) {
//                    console.log("finally")
//                })
//            }
//        }


//    }




}
