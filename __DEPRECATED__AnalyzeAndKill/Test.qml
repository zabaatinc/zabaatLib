import QtQuick 2.0
import Zabaat.Utility 1.0
import QtQuick.Controls 1.4
Item {
    id : rootObject

    Component.onCompleted: {
        Promises.promise(function(fulfill,reject){
           Functions.time.setTimeOut(10, fulfill, "happy")
        }).then(Promises.promise(function(fulfill, reject){
            Functions.time.setTimeOut(20, fulfill, "happiness")
        })).then(function(value){
            console.log("HURPERS", value)
        })
    }





}
