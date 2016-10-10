import QtTest 1.0
import QtQuick 2.0
import Zabaat.MVVM 1.0
import Zabaat.Utility 1.0
import Zabaat.Testing 1.0
ZabaatTest {
    id : rootObject
    objectName: "RestArrayCreator"
    testObj: Item{}

    function init(){

    }

    function cleanup(){
        RestArrayCreator.debugOptions.clearBatches();
    }

    function test_01_blankArray(){
        var arr = RestArrayCreator.create();
        compare(RestArrayCreator.debugOptions.batchBeforeCreateMsg.length, 0, "No properties were made!");
        compare(RestArrayCreator.debugOptions.batchCreateMsg.length      , 0, "No properties were made!");
        compare(RestArrayCreator.debugOptions.allCount()                 , 0);
    }



}
