import QtTest 1.0
import QtQuick 2.0
import Zabaat.MVVM 1.0
import Zabaat.Utility 1.0
import Zabaat.Testing 1.0
ZabaatTest {
    id : rootObject
    objectName: "RestArrayCreator"
    testObj: Item{}

    QtObject {
        id : helpers
        //returns true if all the before<signName> are before the <sigName> in the array
        //returns an error message if validation failed. Otherwise, returns true.
        function validateSignalOrder(arr){
            function firstToUpper(str){
                return str.charAt(0).toUpperCase() + str.slice(1);
            }

            for(var i in arr){
                var e = arr[i];
                if(e.indexOf('before'))
                    continue;

                var arrowIdx = e.indexOf('->');
                var varN     = e.slice(arrowIdx);
                var opName   = e.slice(0,arrowIdx);

                var idx = arrayContains(arr, 'before' + firstToUpper(opName));
                if(idx === -1)
                    return "No " + 'before' + firstToUpper(opName) + " for" + varN;
                if(idx > i)
                    return 'before' + firstToUpper(opName) + " for " + varN  + " is after the After!! "  + idx + ">" + i;
            }

            return true;
        }
    }



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

    function test_02_pushOne_ided(){
        var arr = RestArrayCreator.create();
        arr.push({ id : 0, name : "Wolf" })
        var allSignals = RestArrayCreator.debugOptions.all();
        var allSigsStr = "\n" + allSignals.join('\n')

//        console.log("@@@@@@")
//        console.log(allSigsStr)
//        console.log("@@@@@@")
        arrayContains(allSignals,'beforeCreate->0', allSigsStr);
        arrayContains(allSignals,'beforeCreate->0/name' , allSigsStr);
        arrayContains(allSignals,'create->0'            , allSigsStr);
        arrayContains(allSignals,'create->0/name'       , allSigsStr);
        compare(RestArrayCreator.debugOptions.allCount(), 4          , allSigsStr);

        var vso = helpers.validateSignalOrder(allSignals)
        verify(vso === true, vso);
    }

    function test_03_pushTwo_ided(){
        var arr = RestArrayCreator.create();
        arr.push({ id : 0, name : "Wolf" }  , { id : 1, name : "Zabaat" })
        var allSignals = RestArrayCreator.debugOptions.all();
        var allSigsStr = "\n" + allSignals.join('\n')

        arrayContains(allSignals,'beforeCreate->0'       , allSigsStr);
        arrayContains(allSignals,'beforeCreate->0/name'  , allSigsStr);
        arrayContains(allSignals,'create->0'             , allSigsStr);
        arrayContains(allSignals,'create->0/name'        , allSigsStr);
        arrayContains(allSignals,'beforeCreate->1'       , allSigsStr);
        arrayContains(allSignals,'beforeCreate->1/name'  , allSigsStr);
        arrayContains(allSignals,'create->1'             , allSigsStr);
        arrayContains(allSignals,'create->1/name'        , allSigsStr);
        compare(RestArrayCreator.debugOptions.allCount(), 8          , allSigsStr);

        var vso = helpers.validateSignalOrder(allSignals)
        verify(vso === true, vso);
    }

    function test_04_pushExisting_ided(){
        var arr = RestArrayCreator.create();
        arr.push({ id : 0, name : "Wolf" }, { id : 0, name : "WolfyMania!!" })
        var allSignals = RestArrayCreator.debugOptions.all();
        var allSigsStr = "\n" + allSignals.join('\n')

        arrayContains(allSignals,'beforeCreate->0'       , allSigsStr);
        arrayContains(allSignals,'beforeCreate->0/name'  , allSigsStr);
        arrayContains(allSignals,'create->0'             , allSigsStr);
        arrayContains(allSignals,'create->0/name'        , allSigsStr);
        arrayContains(allSignals,'beforeUpdate->0/name'  , allSigsStr);
        arrayContains(allSignals,'update->0/name'        , allSigsStr);
        compare(RestArrayCreator.debugOptions.allCount(), 6, allSigsStr);


        var vso = helpers.validateSignalOrder(allSignals)
        verify(vso === true, vso);
    }

    function test_05_splice_unIded(){
        var myFish = RestArrayCreator.create(['angel', 'clown', 'mandarin', 'surgeon']);

        function dispMsg(actual,expected){
            return "\nactual: ["  + actual + "]\nexpected: [" +  expected + "]\n";
        }

        // removes 0 elements from index 2, and inserts 'drum'
        var removed = myFish.splice(2, 0, 'drum');
        // myFish is ['angel', 'clown', 'drum', 'mandarin', 'surgeon']
        // removed is [], no elements removed
        compareArrays(myFish ,['angel', 'clown', 'drum', 'mandarin', 'surgeon'], dispMsg);
        compareArrays(removed,[] , dispMsg);

        // myFish is ['angel', 'clown', 'drum', 'mandarin', 'surgeon']
        // removes 1 element from index 3
        removed = myFish.splice(3, 1);
        // myFish is ['angel', 'clown', 'drum', 'surgeon']
        // removed is ['mandarin']
        compareArrays(myFish  , ['angel', 'clown', 'drum', 'surgeon'], dispMsg);
        compareArrays(removed , ['mandarin'], dispMsg);

        // myFish is ['angel', 'clown', 'drum', 'surgeon']
        // removes 1 element from index 2, and inserts 'trumpet'
        removed = myFish.splice(2, 1, 'trumpet');
        // myFish is ['angel', 'clown', 'trumpet', 'surgeon']
        // removed is ['drum']
        compareArrays(myFish     , ['angel', 'clown', 'trumpet', 'surgeon'], dispMsg);
        compareArrays(removed    , ['drum'], dispMsg);


        // myFish is ['angel', 'clown', 'trumpet', 'surgeon']
        // removes 2 elements from index 0, and inserts 'parrot', 'anemone' and 'blue'
        removed = myFish.splice(0, 2, 'parrot', 'anemone', 'blue');
        // myFish is ['parrot', 'anemone', 'blue', 'trumpet', 'surgeon']
        // removed is ['angel', 'clown']
        compareArrays(myFish     , ['parrot', 'anemone', 'blue', 'trumpet', 'surgeon'], dispMsg);
        compareArrays(removed    , ['angel', 'clown'], dispMsg);


        // myFish is ['parrot', 'anemone', 'blue', 'trumpet', 'surgeon']
        // removes 2 elements from index 2
        removed = myFish.splice(myFish.length -3, 2);
        // myFish is ['parrot', 'anemone', 'surgeon']
        // removed is ['blue', 'trumpet']
        compareArrays(myFish     ,['parrot', 'anemone', 'surgeon'], dispMsg);
        compareArrays(removed    ,['blue', 'trumpet'], dispMsg);
    }

    function test_06_splice_unIded_signals(){
        var myFish = RestArrayCreator.create(['angel', 'clown', 'mandarin', 'surgeon']);

        //INSERT
        RestArrayCreator.debugOptions.clearBatches();   //cause we only want to test the signals from splice, not create.
        myFish.splice(2, 0, 'drum');    //myFish= ['angel', 'clown', 'drum', 'mandarin', 'surgeon']

        var allSignals = RestArrayCreator.debugOptions.all();
        var allSigsStr = "\n" + allSignals.join('\n')

        arrayContains(allSignals,'beforeCreate->4 = "surgeon"' , allSigsStr);
        arrayContains(allSignals,'beforeUpdate->2'            , allSigsStr);
        arrayContains(allSignals,'beforeUpdate->3'            , allSigsStr);
        arrayContains(allSignals,'update->lenChanged'         , allSigsStr);
        compare(RestArrayCreator.debugOptions.allCount() , 7, allSigsStr);


        //REMOVE
        RestArrayCreator.debugOptions.clearBatches(); // myFish is ['angel', 'clown', 'drum', 'mandarin', 'surgeon']
        myFish.splice(3, 1);    //myFish = ['angel', 'clown', 'drum', 'surgeon']

        allSignals = RestArrayCreator.debugOptions.all();
        allSigsStr = "\n" + allSignals.join('\n');

        arrayContains(allSignals,'beforeDelete->4'   , allSigsStr);
        arrayContains(allSignals,'beforeUpdate->3'   , allSigsStr);
        arrayContains(allSignals,'update->lenChanged', allSigsStr);

        compare(RestArrayCreator.debugOptions.allCount() , 5, allSigsStr);


        RestArrayCreator.debugOptions.clearBatches(); // myFish is ['angel', 'clown', 'drum', 'surgeon']
        myFish.splice(2, 1, 'trumpet');     //['angel', 'clown', 'trumpet', 'surgeon']

        allSignals = RestArrayCreator.debugOptions.all();
        allSigsStr = "\n" + allSignals.join('\n');

        //delete related updates
        arrayContains(allSignals,'beforeUpdate->2'   , allSigsStr);
        arrayContains(allSignals,'beforeDelete->3'   , allSigsStr);

        //insert related updates
        arrayContains(allSignals,'beforeCreate->3'   , allSigsStr);
        arrayContains(allSignals,'beforeUpdate->2'   , allSigsStr);

        arrayContains(allSignals,'update->lenChanged',2, allSigsStr);
        compare(RestArrayCreator.debugOptions.allCount() , 10, allSigsStr);


        RestArrayCreator.debugOptions.clearBatches();
        myFish.splice(0, 2, 'parrot', 'amy', 'blue');   //['parrot', 'anemone', 'blue', 'trumpet', 'surgeon']

        allSignals = RestArrayCreator.debugOptions.all();
        allSigsStr = " \n" + allSignals.join(' \n');


        //Delete
        arrayContains(allSignals,'beforeUpdate->0' ,5, allSigsStr);
        arrayContains(allSignals,'beforeUpdate->1' ,5, allSigsStr);
        arrayContains(allSignals,'beforeUpdate->2' ,3, allSigsStr);
        arrayContains(allSignals,'beforeUpdate->3' ,1, allSigsStr);

        arrayContains(allSignals,'beforeDelete->2' ,1, allSigsStr);
        arrayContains(allSignals,'beforeDelete->3' ,1, allSigsStr);

        arrayContains(allSignals,'beforeCreate->2' ,1, allSigsStr);
        arrayContains(allSignals,'beforeCreate->3' ,1, allSigsStr);
        arrayContains(allSignals,'beforeCreate->4' ,1, allSigsStr);
        arrayContains(allSignals,'update->lenChanged', 5);
        compare(RestArrayCreator.debugOptions.allCount(), 43);


        RestArrayCreator.debugOptions.clearBatches();

        myFish.splice(myFish.length -3, 2); //['parrot', 'anemone', 'surgeon']
        allSignals = RestArrayCreator.debugOptions.all();
        allSigsStr = " \n" + allSignals.join(' \n');

//        RestArrayCreator.debugOptions.printAll();

        arrayContains(allSignals,'beforeUpdate->2' ,2);
        arrayContains(allSignals,'beforeUpdate->3' ,1);
        arrayContains(allSignals,'beforeDelete->3' ,1);
        arrayContains(allSignals,'beforeDelete->4' ,1);
        arrayContains(allSignals,'update->lenChanged', 2);

        compare(RestArrayCreator.debugOptions.allCount(), 12);
    }

    function test_07_insert_ided(){
        var arr = RestArrayCreator.create([{id:"10",name:"Shahan"}]);
        arr.insert(0, {id : "20", name : "Anam" })

        compare(arr.length,2);
        compareObjects(arr[0], {id : "20", name : "Anam" });
        compareObjects(arr[1], {id:"10",name:"Shahan"});

        arr.insert(1, {id : "20", name : "Anam Shahan" })
        compare(arr.length,2);
        compareObjects(arr[0], {id : "20", name : "Anam Shahan" });
        compareObjects(arr[1], {id:"10",name:"Shahan"});

        arr[0].id = "30";
        compare(arr[0].id, "20")
        compare(arr[0]._racgen, true);
        compare(arr[1]._racgen, true);
    }

    function test_08_insert_ided_signals(){
        var arr = RestArrayCreator.create([{id:"10",name:"Shahan"}]);
        var allSignals
        RestArrayCreator.debugOptions.clearBatches();
        arr.insert(0, {id : "20", name : "Anam" })
        allSignals = RestArrayCreator.debugOptions.all();
        arrayContains(allSignals,'lenChanged: 2' ,1);
        arrayContains(allSignals,'beforeCreate->20' ,2);
        arrayContains(allSignals,'beforeCreate->20/name' ,1);
        compare(RestArrayCreator.debugOptions.allCount(), 5);

        RestArrayCreator.debugOptions.clearBatches();
        arr.insert(1, {id : "20", name : "Anam Shahan" });
        allSignals = RestArrayCreator.debugOptions.all();
        arrayContains(allSignals,'beforeUpdate->20/name' ,1);
        compare(RestArrayCreator.debugOptions.allCount(), 2);

        RestArrayCreator.debugOptions.clearBatches();
        arr[0].name = "Anam Shahan Kazi";
        allSignals = RestArrayCreator.debugOptions.all();
        arrayContains(allSignals,'beforeUpdate->20/name' ,1);
        compare(RestArrayCreator.debugOptions.allCount(), 2);

        RestArrayCreator.debugOptions.clearBatches();
        arr[0] = { name : "Anam Shahan" };
        allSignals = RestArrayCreator.debugOptions.all();
        arrayContains(allSignals,'beforeUpdate->20/name' ,1);
        compare(RestArrayCreator.debugOptions.allCount(), 2);

        RestArrayCreator.debugOptions.clearBatches();
        arr[1].name = "Shahan Kazi";
        allSignals = RestArrayCreator.debugOptions.all();
        arrayContains(allSignals,'beforeUpdate->10/name' ,1);
        compare(RestArrayCreator.debugOptions.allCount(), 2);

        RestArrayCreator.debugOptions.clearBatches();
        arr[1] = { name : "Shahan" };
        allSignals = RestArrayCreator.debugOptions.all();
        arrayContains(allSignals,'beforeUpdate->10/name' ,1);
        compare(RestArrayCreator.debugOptions.allCount(), 2);
        //        RestArrayCreator.debugOptions.printAll();
    }

    function test_09_remove_ided(){
        var arr = RestArrayCreator.create([{id:"10",name:"Shahan"}, {id:"20",name: "Anam"}, {id:'30', name : "wolf"}]);
        arr.remove(0);
        compareArrays(arr, [{id:"20",name: "Anam"}, {id:'30', name : "wolf"}], JSON.stringify(arr));

        arr = RestArrayCreator.create([{id:"10",name:"Shahan"}, {id:"20",name: "Anam"}, {id:'30', name : "wolf"}]);
        arr.remove(1);
        compareArrays(arr, [{id:"10",name:"Shahan"}, {id:'30', name : "wolf"}]);

        arr = RestArrayCreator.create([{id:"10",name:"Shahan"}, {id:"20",name: "Anam"}, {id:'30', name : "wolf"}]);
        arr.remove(2);
        compareArrays(arr, [{id:"10",name:"Shahan"}, {id:"20",name: "Anam"}]);

        arr = RestArrayCreator.create([{id:"10",name:"Shahan"}, {id:"20",name: "Anam"}, {id:'30', name : "wolf"}]);
        arr.remove(3);
        compareArrays(arr, [{id:"10",name:"Shahan"}, {id:"20",name: "Anam"}, {id:'30', name : "wolf"}]);

        //start emptying out array
        arr.remove(1);
        compareArrays(arr, [{id:"10",name:"Shahan"}, {id:'30', name : "wolf"}]);

        arr.remove(0);
        compareArrays(arr, [{id:'30', name : "wolf"}]);

        arr.remove(0);
        compareArrays(arr, []);
    }

    function test_10_remove_ided_signals(){
        var arr = RestArrayCreator.create([{id:"10",name:"Shahan"}, {id:"20",name: "Anam"}, {id:'30', name : "wolf"}]);
        RestArrayCreator.debugOptions.clearBatches();
        arr.remove(0);
        var allSignals = RestArrayCreator.debugOptions.all();
        arrayContains(allSignals,'lenChanged: 2' ,1);
        compare(RestArrayCreator.debugOptions.allCount(), 3);

        arr = RestArrayCreator.create([{id:"10",name:"Shahan"}, {id:"20",name: "Anam"}, {id:'30', name : "wolf"}]);
        RestArrayCreator.debugOptions.clearBatches();
        arr.remove(1);
        allSignals = RestArrayCreator.debugOptions.all();
        arrayContains(allSignals,'lenChanged: 2' ,1);
        compare(RestArrayCreator.debugOptions.allCount(), 3);


        arr = RestArrayCreator.create([{id:"10",name:"Shahan"}, {id:"20",name: "Anam"}, {id:'30', name : "wolf"}]);
        RestArrayCreator.debugOptions.clearBatches();
        arr.remove(2);
        allSignals = RestArrayCreator.debugOptions.all();
        arrayContains(allSignals,'lenChanged: 2' ,1);
        compare(RestArrayCreator.debugOptions.allCount(), 3);



        arr = RestArrayCreator.create([{id:"10",name:"Shahan"}, {id:"20",name: "Anam"}, {id:'30', name : "wolf"}]);
        RestArrayCreator.debugOptions.clearBatches();
        arr.remove(3);
        allSignals = RestArrayCreator.debugOptions.all();
        compare(RestArrayCreator.debugOptions.allCount(), 0);

        //start emptying out array
        RestArrayCreator.debugOptions.clearBatches();
        arr.remove(1);
        allSignals = RestArrayCreator.debugOptions.all();
        arrayContains(allSignals,'lenChanged: 2' ,1);
        compare(RestArrayCreator.debugOptions.allCount(), 3);


        RestArrayCreator.debugOptions.clearBatches();
        arr.remove(0);
        allSignals = RestArrayCreator.debugOptions.all();
        arrayContains(allSignals,'lenChanged: 1' ,1);
        compare(RestArrayCreator.debugOptions.allCount(), 3);

        RestArrayCreator.debugOptions.clearBatches();
        arr.remove(0);
        allSignals = RestArrayCreator.debugOptions.all();
        arrayContains(allSignals,'lenChanged: 0' ,1);
        compare(RestArrayCreator.debugOptions.allCount(), 3);

    }

    function test_11_reverse(){
        var arr = RestArrayCreator.create([1,2,3,4]);
        RestArrayCreator.debugOptions.clearBatches();
        arr.reverse();

        var allSignals = RestArrayCreator.debugOptions.all();
        var allSigsStr = " \n" + allSignals.join(' \n');

        compare(RestArrayCreator.debugOptions.allCount(), 8);


        arr = RestArrayCreator.create([{id:"A",name:"A"},{id:"B",name:"B"},{id:"C",name:"C"},{id:"D",name:"D"}]);
        RestArrayCreator.debugOptions.clearBatches();
        arr.reverse();
        allSignals = RestArrayCreator.debugOptions.all();

        RestArrayCreator.debugOptions.printAll();
        compare(RestArrayCreator.debugOptions.allCount(), 0, JSON.stringify(arr,null,2));

//        arr[0].name = "Dylan";
//        allSignals = RestArrayCreator.debugOptions.all();
//        arrayContains(allSignals,'beforeUpdate->D/name' ,1));
//        compare(RestArrayCreator.debugOptions.allCount(), 2);
    }

    function test_12_sort_unided_simple(){
        var arr = RestArrayCreator.create([4,3,2,1]);
        RestArrayCreator.debugOptions.clearBatches();
        arr.sort();
        var allSignals = RestArrayCreator.debugOptions.all();

        compareArrays(arr,[1,2,3,4]);
        arrayContains(allSignals,'beforeUpdate->0' ,1);
        arrayContains(allSignals,'beforeUpdate->1' ,1);
        arrayContains(allSignals,'beforeUpdate->2' ,1);
        arrayContains(allSignals,'beforeUpdate->3' ,1);
        compare(RestArrayCreator.debugOptions.allCount(), 8);
    }

    function test_12_sort_unided_complex(){
        var arr = RestArrayCreator.create([{a:"4"}, {a:"3"}, {a:"2"} , {a:"1"}]);
        RestArrayCreator.debugOptions.clearBatches();
        arr.sort(function(a,b){
                    return parseInt(a.a) - parseInt(b.a);
                 });
        var allSignals = RestArrayCreator.debugOptions.all();
        compareArrays(arr,[{a:"1"}, {a:"2"}, {a:"3"} , {a:"4"}]);
        arrayContains(allSignals,'beforeUpdate->0' ,1);
        arrayContains(allSignals,'beforeUpdate->1' ,1);
        arrayContains(allSignals,'beforeUpdate->2' ,1);
        arrayContains(allSignals,'beforeUpdate->3' ,1);
        compare(RestArrayCreator.debugOptions.allCount(), 8);
    }

    function test_13_sort_ided(){
        var arr = RestArrayCreator.create([{id:"4"}, {id:"3"}, {id:"2"} , {id:"1"}]);
        RestArrayCreator.debugOptions.clearBatches();
        arr.sort(function(a,b){
                    return parseInt(a.id) - parseInt(b.id);
                 });
        var allSignals = RestArrayCreator.debugOptions.all();
        compareArrays(arr,[{id:"1"}, {id:"2"}, {id:"3"} , {id:"4"}]);
        compare(RestArrayCreator.debugOptions.allCount(), 0);
    }

    function test_14_get_unided(){
        var pets  = ["Pig","Clam","Shellie"]
        var arr = RestArrayCreator.create(pets)

        compare(arr.get('0'),"Pig")
        compare(arr.get('1'),"Clam")
        compare(arr.get('2'),"Shellie")
        compare(arr.get('3'),undefined)
    }

    function test_15_get_unided_complex(){
        var pets  = ["Pig","Clam","Shellie"]
        var pets2 = ["Drake","Sam"]
        var arr = RestArrayCreator.create([{name : "Wolf"  , pets : pets } ,
                                           {name : "Shahan", pets : pets2 }]);

        compareObjects(arr.get("0") , {name : "Wolf" , pets : pets })
        compareObjects(arr.get("1") , {name : "Shahan", pets : pets2 })
        compare(arr.get('0/name'),"Wolf")
        compare(arr.get('1/name'),"Shahan")
        compareObjects(arr.get("0/pets") , pets )
        compareObjects(arr.get("1/pets") , pets2 )

        compare(arr.get('2'),undefined)
        compare(arr.get('2/name'),undefined)
        compare(arr.get('2/pets'),undefined)
    }

    function test_16_get_ided(){
        var pets  = ["Pig","Clam","Shellie"]
        var pets2 = ["Drake","Sam"]
        var arr = RestArrayCreator.create([{id:"4", name : "Wolf"  , pets : pets } ,
                                           {id:"3", name : "Shahan", pets : pets2 }]);

        compareObjects(arr.get("3") , {id:"3", name : "Shahan", pets : pets2 })
        compareObjects(arr.get("4") , {id:"4", name : "Wolf" , pets : pets })
        compare(arr.get('3/name'),"Shahan")
        compare(arr.get('4/name'),"Wolf")
        compareObjects(arr.get("3/pets") , pets2 )
        compareObjects(arr.get("4/pets") , pets )

        compare(arr.get('0'),undefined)
        compare(arr.get('0/name'),undefined)
        compare(arr.get('0/pets'),undefined)
    }

    function test_17_set_unided() {
        var pets  = ["Pig","Clam","Shellie"]
        var arr = RestArrayCreator.create(pets);

        RestArrayCreator.debugOptions.clearBatches();
        arr.set("0","Piggy");
        var sigs = RestArrayCreator.debugOptions.all();
        compare(RestArrayCreator.debugOptions.allCount(), 2);
        arrayContains(sigs,"beforeUpdate->0",1);
        compareArrays(arr,["Piggy","Clam","Shellie"]);

        RestArrayCreator.debugOptions.clearBatches();
        arr.set("1","Clammy");
        sigs = RestArrayCreator.debugOptions.all();
        compare(RestArrayCreator.debugOptions.allCount(), 2);
        arrayContains(sigs,"beforeUpdate->1",1);
        compareArrays(arr,["Piggy","Clammy","Shellie"]);

        RestArrayCreator.debugOptions.clearBatches();
        arr.set("2","Shell");
        sigs = RestArrayCreator.debugOptions.all();
        compare(RestArrayCreator.debugOptions.allCount(), 2);
        arrayContains(sigs,"beforeUpdate->2",1);
        compareArrays(arr,["Piggy","Clammy","Shell"]);

        RestArrayCreator.debugOptions.clearBatches();
        arr.set('3','Helga');
        sigs = RestArrayCreator.debugOptions.all();
        compare(RestArrayCreator.debugOptions.allCount(), 2);
        arrayContains(sigs,"beforeCreate->3",1);
        compareArrays(arr,["Piggy","Clammy","Shell","Helga"]);

        RestArrayCreator.debugOptions.clearBatches();
        arr.set('3','Helgamoto');
        sigs = RestArrayCreator.debugOptions.all();
        compare(RestArrayCreator.debugOptions.allCount(), 2);
        arrayContains(sigs,"beforeUpdate->3",1);
        compareArrays(arr,["Piggy","Clammy","Shell","Helgamoto"]);
    }

    function test_18_set_unided_complex(){
        var pets  = ["Pig","Clam","Shellie"]
        var pets2 = ["Drake","Sam"]
        var arr = RestArrayCreator.create([{name : "Wolf"  , pets : pets } ,
                                           {name : "Shahan", pets : pets2 }]);

        RestArrayCreator.debugOptions.clearBatches();
        arr.set('0/name','Wolfy');
        var sigs = RestArrayCreator.debugOptions.all();
        compare(RestArrayCreator.debugOptions.allCount(), 2);
        compare(arr[0] , {name : "Wolfy"  , pets : pets })
        arrayContains(sigs,"beforeUpdate->0/name",1);

        RestArrayCreator.debugOptions.clearBatches();
        arr.set('1/name','Shahany');
        sigs = RestArrayCreator.debugOptions.all();
        compare(RestArrayCreator.debugOptions.allCount(), 2);
        compare(arr[1] , {name : "Shahany"  , pets : pets2 })
        arrayContains(sigs,"beforeUpdate->1/name",1);

        RestArrayCreator.debugOptions.clearBatches();
        arr.set('0/pets/0','Piggy');
        sigs = RestArrayCreator.debugOptions.all();
        compare(RestArrayCreator.debugOptions.allCount(), 2);
        compare(arr.get("0/pets") , ["Piggy","Clam","Shellie"])
        arrayContains(sigs,"beforeUpdate->0/pets/0",1);

        RestArrayCreator.debugOptions.clearBatches();
        arr.set('0/pets/1','Clamy');
        sigs = RestArrayCreator.debugOptions.all();
        compare(RestArrayCreator.debugOptions.allCount(), 2);
        compare(arr.get("0/pets") , ["Piggy","Clamy","Shellie"])
        arrayContains(sigs,"beforeUpdate->0/pets/1",1);


        RestArrayCreator.debugOptions.clearBatches();
        arr.set('0/pets/2','Shell');
        sigs = RestArrayCreator.debugOptions.all();
        compare(RestArrayCreator.debugOptions.allCount(), 2);
        compare(arr.get("0/pets") , ["Piggy","Clamy","Shell"])
        arrayContains(sigs,"beforeUpdate->0/pets/2",1);



        RestArrayCreator.debugOptions.clearBatches();
        arr.set('1/pets/0','Draco');
        sigs = RestArrayCreator.debugOptions.all();
        compare(RestArrayCreator.debugOptions.allCount(), 2);
        compare(arr.get("1/pets") , ["Draco","Sam"])
        arrayContains(sigs,"beforeUpdate->1/pets/0",1);


        RestArrayCreator.debugOptions.clearBatches();
        arr.set('1/pets/1','Sammy');
        sigs = RestArrayCreator.debugOptions.all();
        compare(RestArrayCreator.debugOptions.allCount(), 2);
        compare(arr.get("1/pets") , ["Draco","Sammy"])
        arrayContains(sigs,"beforeUpdate->1/pets/1",1);



        RestArrayCreator.debugOptions.clearBatches();
        arr.set('0/pets', ["Johny","Reed","Susie","Benny"]);
        sigs = RestArrayCreator.debugOptions.all();
        compare(RestArrayCreator.debugOptions.allCount(), 9);
        arrayContains(sigs,'beforeUpdate->0/pets/0',1)
        arrayContains(sigs,'beforeUpdate->0/pets/1',1)
        arrayContains(sigs,'beforeUpdate->0/pets/2',1)
        arrayContains(sigs,'beforeCreate->0/pets/3',1)
        compare(arr.get("0/pets") , ["Johny","Reed","Susie","Benny"])

        RestArrayCreator.debugOptions.clearBatches();
        arr.set('1/pets', ["Draxxis"]);
        sigs = RestArrayCreator.debugOptions.all();
        compare(RestArrayCreator.debugOptions.allCount(), 5);
        arrayContains(sigs,'beforeUpdate->1/pets/0',1)
        arrayContains(sigs,'beforeDelete->1/pets/1',1)
        compare(arr.get("1/pets") , ["Draxxis"])
    }

    function test_19_delete_unided(){
        var pets  = ["Pig","Clam","Shellie"]
        var arr = RestArrayCreator.create(pets);

        RestArrayCreator.debugOptions.clearBatches();
        arr.del('0')
        var sigs = RestArrayCreator.debugOptions.all();
        compare(arr.length, 2);
        arrayContains(sigs,"beforeUpdate->0",1);
        arrayContains(sigs,"beforeUpdate->1",1);
        arrayContains(sigs,"beforeDelete->2",1);
        compareArrays(arr,["Clam","Shellie"]);
        compare(RestArrayCreator.debugOptions.allCount() , 7);
    }

    function test_19_delete_unided_complex(){
        var pets  = ["Pig","Clam","Shellie"]
        var pets2 = ["Drake","Sam"]
        var arr = RestArrayCreator.create([{name : "Wolf"  , pets : pets } ,
                                           {name : "Shahan", pets : pets2 }]);
        RestArrayCreator.debugOptions.clearBatches();
        var arrPets = arr.get('0/pets');


        arrPets.del('1');
        var sigs    = RestArrayCreator.debugOptions.all();
        compare(arrPets.length,2);
        compareObjects(arr[0], {name: "Wolf", pets:["Pig", "Shellie"] })
        arrayContains(sigs, "beforeUpdate->0/pets/1");
        arrayContains(sigs,"beforeDelete->0/pets/2");
        compare(RestArrayCreator.debugOptions.allCount(), 5);
    }



    function test_99_speedTest(){
        var deepObject = {id : "10",
          name : "Shahan",
          hobbies : ["coding","gaming"],
          relatives : [ {id:"99",name :"Fahad", relation:"brother" } ,
                         {id:"100",name :"Anam", relation:"wife" }
                    ]
        }

        var n = 500;
        var d

        var createTimer = Functions.time.mstimer();
        Lodash.times(n, function(){
            d = RestArrayCreator.create([deepObject])
        })
        var totalCreateTime = createTimer.stop();

        var updateTimer = Functions.time.mstimer();
        Lodash.times(n, function(){
            d._updatePath('11');
        })
        var totalUpdateTime = updateTimer.stop();


        var avgCreate = totalCreateTime /n;
        var avgUpdate = totalUpdateTime /n;

        verify(avgCreate > avgUpdate);

        if(avgCreate > avgUpdate)
           console.log("\tavg update is", (avgCreate/avgUpdate * 100).toFixed(1) , "% faster" , avgCreate, avgUpdate)
        else if(avgCreate < avgUpdate)
           console.log("\tavg Create is", (avgUpdate/avgCreate * 100).toFixed(1) , "% faster" , avgUpdate, avgCreate)

    }






}
