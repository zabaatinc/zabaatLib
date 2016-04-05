import QtQuick 2.5
import Zabaat.Utility 1.0
import Zabaat.Material 1.0
Item {
    anchors.fill: parent

    ListModel {
        id : lm1
    }
    ListModel {
        id : lm2
    }

    ZTextBox {
        label : "Num Elements"
        text : "50"
        onAccepted : runTest(text);
        height : parent.height * 0.2
        width  : parent.width * 0.15
        anchors.centerIn: parent

        ZButton {
            anchors.left: parent.right
            anchors.leftMargin : width
            anchors.top: parent.top
            width : height
            height : parent.height
            text : FA.anchor
            onClicked : runTest(parent.text);
            state : "warning"
        }
    }

    function runTest(size) {
        size = +size
        console.log(size, typeof size)

        lm1.clear()
        lm2.clear()

        var unsortedArr = generateRandArray(size,0 ,1000)
        var clone  = _.clone(unsortedArr)
        var clone2 = _.clone(unsortedArr)
        var clone3 = _.clone(unsortedArr)
        var cmpFunc = function(a,b) { return a.num - b.num }


        for(var a = 0; a < unsortedArr.length; ++ a) {
            lm1.append({ num : unsortedArr[a] } )
            lm2.append({ num : unsortedArr[a] })
        }

        console.time("defaultSort")
        clone3.sort(function(a,b){ return a - b })
        console.timeEnd("defaultSort");

        console.time("quickSort")
        Functions.list.quickSort(clone);
        console.timeEnd("quickSort")

        console.time("heapSort")
        Functions.list.heapSort(clone2);
        console.timeEnd("heapSort");



        console.time("quickSort lm")
        Functions.list.quickSort(lm1, cmpFunc);
        console.timeEnd("quickSort lm")

        console.time("heapSort lm")
        Functions.list.heapSort(lm2, cmpFunc);
        console.timeEnd("heapSort lm");

        if(!verify(clone3)) console.log("defaultSort failed")
        if(!verify(clone)) console.log("quickSort failed")
        if(!verify(clone2)) console.log("heapSort failed")
        if(!verifyLm(lm1)) console.log("defaultSort LM failed")
        if(!verifyLm(lm2)) console.log("defaultSort LM failed")



        if(unsortedArr.length < 30){
            console.log(clone)
            console.log(clone2)
            console.log(clone3)
            console.log(_.map(Functions.object.listmodelToArray(lm1) , function (a){ return a.num}) )
            console.log(_.map(Functions.object.listmodelToArray(lm2) , function (a){ return a.num}))
        }
    }

    function verify(arr) {
        for(var i = 1; i < arr.length; ++i){
            if(arr[i - 1]  > arr[i])
                return false
        }
        return true;
    }
    function verifyLm(lm) {
        for(var i = 1 ; i < lm.count; ++i){
            if(lm.get(i - 1).num > lm.get(i).num)
                return false
        }
        return true;
    }



    function generateRandArray(size, min,max) {
        var arr = []
        for(var i = 0; i < size; ++i) {
            var r = Math.floor(Math.random() * (max - min) ) + min
            arr.push(r)

        }
        return arr;
    }



}
