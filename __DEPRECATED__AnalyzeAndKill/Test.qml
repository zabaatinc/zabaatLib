import QtQuick 2.0
import Zabaat.Utility 1.0
import QtQuick.Controls 1.4
Item {
    id : rootObject

    function f1(time, arg){
//        console.log("f1")
        if(!time || typeof time !== 'number')
            time = 10

        return Promises.promise(function(f,r) {
          console.log("ARG:", arg);
          Functions.time.setTimeOut(time, f, "happy")
        })

    }

    //fails if first promise passed :P
    function f2(fail){
//        console.log("f2",value)
        return Promises.promise(function(f,r) {
            if(fail) {
                Functions.time.setTimeOut(50, r, "sadness")
            }
            else {
                Functions.time.setTimeOut(500, f, "happiness")
            }
        })
    }


    Row {
        anchors.centerIn: parent
        Button {
            text : 'standard'
            onClicked : {
                f1().then(f2).then(function(v) {
                    console.log("success val:", v)
                }).catch(function(r) {
                    console.log("reason for failure:",r)
                }).finally(function(f) {
                    console.log("finally")
                })
            }
        }

        Button {
            text : "all"
            onClicked : {
                var p1 = f1(100,'promise 1');
                var p2 = f1(500,'promise 2');


                Promises.all([p1,p2]).then(function() {
                    console.log("herp")
                }).catch(function(err){
                    console.log("ERR REASON:", err)
                }).finally(function(v) {
                    console.log("finally")
                })
            }
        }

        Button {
            text : "all succeed before"
            onClicked : {
                var p1 = Promises.promise(function(a,r) {
                            a("1 true")  ;
                         })

                var p2 = Promises.promise(function(a,r) {
                            a("2 true")  ;
                         })


                Promises.all([p1,p2]).then(function(val) {
                    console.log("VALUE", JSON.stringify(val,null,2))
                }).catch(function(err){
                    console.log("ERR REASON:", err)
                }).finally(function(v) {
                    console.log("finally")
                })
            }
        }

        Button {
            text : "all fail"
            onClicked : {
                var p1 = f1();
                var p2 = f2(true);

                Promises.all([p1,p2]).then(function(val) {
                    console.log("VALUE", JSON.stringify(val,null,2))
                }).catch(function(err){
                    console.log("ERR REASON:", err)
                }).finally(function(v) {
                    console.log("finally")
                })
            }
        }


    }




}
