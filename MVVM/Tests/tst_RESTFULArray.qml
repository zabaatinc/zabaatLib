import QtTest 1.0
import QtQuick 2.0
import Zabaat.MVVM 1.0
import Zabaat.Utility 1.0
import Zabaat.Testing 1.0
ZabaatTest {
    id : rootObject
    objectName : "RESTFULArray"
    testObj : RESTFULArray{
        id : ra
    }

    function init() {
        clearSignals()
    }




//    function test_01derp(){
//        ra.derp();
//        wait(10);
//        console.log(JSON.stringify(signals.derp))
//        compare(signals.derp.length, 1)
//    }

//    function test_02derpderp(){
//        ra.derp();
//        ra.derp();
//        wait(10);
//        console.log(JSON.stringify(signals.derp))
//        compare(signals.derp.length, 2)
//    }

}
