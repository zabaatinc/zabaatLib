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

    property var defaultObj : [
        { id : "0", name : "Shahan", hobbies : [{id:100,name:'fencing'}] } ,
        { id : "1", name : "Fahad" , hobbies : [{id:101,name:'dancing'}] }
    ]


    function init() {
        ra.reset();
        clearSignals();
        defaultObj = [
                    { id : "0", name : "Shahan", hobbies : [{id:100,name:'fencing'}] } ,
                    { id : "1", name : "Fahad" , hobbies : [{id:101,name:'dancing'}] }
                ]

    }

    function reduceToMap(arr){
        return Lodash.reduce(arr, function(a,e){
                    a[e[0]] = true;
                    return a;
        },{})
    }


    function cleanup(){
        ra.priv.debug = false;
        clearSignals()
    }


    //test if runUpdate works as an init!
    function test_01_runUpdate_init(){
        ra.runUpdate(defaultObj)

        compare(ra.arr.length, 2 , "arr length should be 2")
        compare(ra.length, 2, "ra arr length should be 2")
        compare(ra.arr[0].id, "0", "first one should be 0")
        compare(ra.arr[1].id, "1", "first one should be 1")
        compare(ra.priv.idMap["0"] , defaultObj[0])
        compare(ra.priv.idMap["1"] , defaultObj[1])
        compare(toString.call(signals.created), '[object Array]' , "Should have generated created signals!")
        compare(signals.created.length, 2, "There should be 2 created signals")

    }

    //test if reset works after we have some items!
    function test_02_reset() {
        ra.runUpdate(defaultObj)
        clearSignals();

        ra.reset()
        compare(ra.arr, undefined, "arr length should be undefined")
        compare(ra.length, 0, "ra arr length should be 0")
        compare(toString.call(signals.deleted),'[object Array]', "Should have generated deleted signals!")
        compare(signals.deleted.length, 2, "There should be 2 created signals")
    }


    function test_03_getRoot_existing(){
        ra.runUpdate(defaultObj)

        var item = ra.get("0")
        compare(item, defaultObj[0])
        compare(item, ra.arr[0], "should be both pointers to the same object!")
    }

    function test_04_getRoot_nonexisting(){
        ra.runUpdate(defaultObj)

        var item = ra.get("2")
        compare(item, undefined)
    }

    function test_05_getInner_existing() {
        ra.runUpdate(defaultObj);

        compare(ra.get("0/name"), 'Shahan')
        compare(ra.get("1/name"), 'Fahad')
    }

    function test_06_getInner_existing_nonbasic() {
        ra.runUpdate(defaultObj);

        compare(ra.get("0/hobbies")    , defaultObj[0].hobbies   , "0/hobbies mismatch")
        compare(ra.get("0/hobbies/100"), defaultObj[0].hobbies[0], "0/hobbies/100 mismatch")
        compare(ra.get("0/hobbies/100/name"), "fencing", "0/hobbies/100/name mismatch")

        compare(ra.get("1/hobbies"), defaultObj[1].hobbies, "1/hobbies mismatch")
        compare(ra.get("1/hobbies/101"), defaultObj[1].hobbies[0] , "1/hobbies/101 mismatch")
        compare(ra.get("1/hobbies/101/name"), "dancing", "1/hobbies/101/name mismatch")
    }

    function test_07_getInner_nonexisting_nonbasic() {
        ra.runUpdate(defaultObj);

        compare(ra.get("0/hobbies/0"), undefined , "0/hobbies/0 mismatch")
        compare(ra.get("0/hobbies/1"), undefined , "0/hobbies/1 mismatch")
    }

    function test_08_setRoot_nonexisting() {
        var obj = { name : "Shahan" }
        ra.set("2" , obj)

        var item = ra.get("2")

        compare(ra.length, 1, "ra arr length should be 1")
        compare(ra.arr.length, 1 , "arr length should be 1")
        compare(ra.arr[0].id, "2", "first one's id should be 2")
        compare(ra.priv.idMap["2"], obj, "id 2 should be the same as obj!")
        compare(toString.call(signals.created), '[object Array]' , "Should have generated created signals!")
        compare(signals.created.length, 3, "There should be 3 created signals, [2,2/name,2/id]")

        var rc = reduceToMap(signals.created)

        compare(rc["2"]     , true)
        compare(rc["2/name"], true)
        compare(rc["2/id"]  , true)
        compare(item, obj);
    }

    function test_08b_setRoot_nonexisting() {
        ra.set("2/name" , "Wolf")

        var item = ra.get("2")


        compare(ra.length, 1, "ra arr length should be 1")
        compare(ra.arr.length, 1 , "arr length should be 1")
        compare(ra.arr[0].id, "2", "first one's id should be 2")
        compare(ra.priv.idMap["2"].name, "Wolf", "Should have name wolf!")
        compare(toString.call(signals.created), '[object Array]' , "Should have generated created signals!")
        compare(signals.created.length, 2, "There should be 2 created signals")

        var rc = reduceToMap(signals.created)

        compare(rc["2"] , true);
        compare(rc["2/name"],true);
    }

    function test_09_setRoot_existing() {
        ra.runUpdate(defaultObj);

        ra.set("0",{name : "Wolf"})
        compare(ra.get("0/name"), "Wolf")
        compare(ra.priv.idMap["0"].name , "Wolf")
    }

    function test_10_setDeeper_existingSimple(){
        ra.runUpdate(defaultObj);
        clearSignals();

        ra.set("0/hobbies/100/name", "cherping" )
        compare(ra.get("0/hobbies/100/name"), "cherping")


        var rc = reduceToMap(signals.updated)

        compare(rc['0/hobbies/100/name'], true, "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))
        compare(signals.updated.length , 1 , "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))

    }

    function test_10_setDeeper_existingComplex(){
        ra.runUpdate(defaultObj);
        clearSignals();

        ra.set("0/hobbies/100", { level : "9000+" } )
        compare(ra.get("0/hobbies/100/level"), "9000+" )
        compare(signals.created.length , 1, "ACTUAL SIGNALS : " + JSON.stringify(signals.created,null,2))
    }

    function test_11_deleteRoot() {
        ra.runUpdate(defaultObj);

        ra.del("0")
        compare(ra.length, 1);
        compare(ra.arr.length , 1);

        var ids = Lodash.keys(ra.priv.idMap)
        compare(ids.length, 1, 'there should only be one id:' + ids);

        var rc = reduceToMap(signals.deleted)

        compare(rc["0"], true)
        compare(rc["0/id"], true)
        compare(rc["0/name"], true)
        compare(rc["0/hobbies"], true)
        compare(rc["0/hobbies/100"], true)
        compare(rc["0/hobbies/100/id"], true)
        compare(rc["0/hobbies/100/name"], true)
        compare(signals.deleted.length, 7, "ACTUAL signals :" + JSON.stringify(signals.deleted,null,2));
    }

    function test_12_deleteExisting() {
        ra.runUpdate(defaultObj);
        ra.del("0/hobbies/100")

        var ids = Lodash.keys(ra.priv.idMap)
        compare(ids.length, 2, 'there should still be 2 ids:' + ids);

        compare(ra.length, 2);
        compare(ra.arr.length , 2);
        compare(ra.get("0/hobbies").length, 0)

        var rc = reduceToMap(signals.deleted)

        compare(rc["0/hobbies/100"], true)
        compare(rc["0/hobbies/100/id"], true)
        compare(rc["0/hobbies/100/name"], true)
        compare(signals.deleted.length, 3);
    }

    function test_13_deleteRootNonExisting() {
        ra.runUpdate(defaultObj);

        ra.del("2")

        var ids = Lodash.keys(ra.priv.idMap)
        compare(ids.length, 2, 'there should still be 2 ids:' + ids);

        compare(ra.length, 2);
        compare(ra.arr.length , 2);
        compare(signals.deleted.length, 0);
    }

    function test_14_deleteDeeper_NonExisting() {
        ra.runUpdate(defaultObj);

        var ids = Lodash.keys(ra.priv.idMap)
        compare(ids.length, 2, 'there should still be 2 ids:' + ids);

        ra.del("0/hobbies/0")
        compare(ra.length, 2);
        compare(ra.arr.length , 2);
        compare(ra.get("0/hobbies").length, 1)
        compare(signals.deleted.length, 0);
    }


    function test_15_runUpdate_simple(){
        ra.runUpdate(defaultObj);
        clearSignals();

        var upd2 = ra.priv.clone(defaultObj)
        upd2[0].name = "Wolfy"

        //SANITY CHECK!
        verify(defaultObj !== upd2)
        verify(upd2 !== ra.priv.arr)


        ra.runUpdate(upd2);
        var rc = reduceToMap(signals.updated)

        compare(rc['0/name'], true, "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))
        compare(signals.updated.length , 1 , "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))

    }

    function test_16_runUpdate_complex(){
        ra.runUpdate(defaultObj);
        clearSignals();

        var upd2 = ra.priv.clone(defaultObj)
        upd2[0]  = { id: "0", name : "Wolf", hobbies : [{id:100,name:'jumping',level:60}] }

        //SANITY CHECK!
        verify(defaultObj !== upd2)
        verify(upd2 !== ra.priv.arr)

        ra.runUpdate(upd2);
        var rc = reduceToMap(signals.updated)
        var cc = reduceToMap(signals.created)

        compare(Lodash.keys(ra.priv.idMap).length, 2 , "Should still be 2 ids!")

        compare(cc['0/hobbies/100/level'], true, "ACTUAL SIGNALS : " + JSON.stringify(signals.created,null,2))
        compare(signals.created.length , 1 , "ACTUAL SIGNALS : " + JSON.stringify(signals.created,null,2))

        compare(rc['0/name'], true, "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))
        compare(rc['0/hobbies/100/name'], true, "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))
        compare(signals.updated.length , 2 , "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))
    }

    function test_17_runUpdate_complex_deep(){
        ra.runUpdate(defaultObj);
        clearSignals();

        var upd2 = ra.priv.clone(defaultObj)
        upd2[0]  = { id: "0", name : "Wolf", hobbies : [{id:100,name:'jumping',level:60,medals:[{id:0,name:'gold' }]}] }

        //SANITY CHECK!
        verify(defaultObj !== upd2)
        verify(upd2 !== ra.priv.arr)

        ra.runUpdate(upd2);
        var rc = reduceToMap(signals.updated)
        var cc = reduceToMap(signals.created)

        compare(Lodash.keys(ra.priv.idMap).length, 2 , "Should still be 2 ids!")

        compare(cc['0/hobbies/100/level'], true, "ACTUAL SIGNALS : " + JSON.stringify(signals.created,null,2))
        compare(cc['0/hobbies/100/medals'], true, "ACTUAL SIGNALS : " + JSON.stringify(signals.created,null,2))
        compare(signals.created.length , 2 , "ACTUAL SIGNALS : " + JSON.stringify(signals.created,null,2))

        compare(rc['0/name'], true, "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))
        compare(rc['0/hobbies/100/name'], true, "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))
        compare(signals.updated.length , 2 , "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))
    }

    function test_18_create_unidedArray(){
        ra.runUpdate(defaultObj);
        clearSignals();

        var upd2 = ra.priv.clone(defaultObj)
        var aliases = ["Wolf","Wolfy","Bhalu"]
        upd2[0]  = { id : 0, hobbies : [{id:100, aliases : aliases }] }

        //SANITY CHECK!
        verify(defaultObj !== upd2)
        verify(upd2 !== ra.priv.arr)


        ra.runUpdate(upd2);
        var rc = reduceToMap(signals.updated)
        var cc = reduceToMap(signals.created)

        compare(Lodash.keys(ra.priv.idMap).length, 2 , "Should still be 2 ids!")

        compare(ra.get("0/hobbies/100/aliases") , aliases)

        compare(cc['0/hobbies/100/aliases'], true, "ACTUAL SIGNALS : " + JSON.stringify(signals.created,null,2))
        compare(signals.created.length , 1 , "ACTUAL SIGNALS : " + JSON.stringify(signals.created,null,2))

        compare(signals.updated.length , 0 , "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))
    }

    function test_19_replace_unidedArray(){
        var upd2 = ra.priv.clone(defaultObj)
        upd2[0]  = { id : 0, hobbies : [{id:100, aliases : ["Wolf","Wolfy","Bhalu"]}] }
        ra.runUpdate(upd2);
        clearSignals();

        var aliases = ["Wolferio","Wolfy"]
        upd2 = ra.priv.clone(defaultObj)
        upd2[0]  = { id : 0, hobbies : [{id:100, aliases : aliases}] }


        ra.runUpdate(upd2);

        var rc = reduceToMap(signals.updated)
        var cc = reduceToMap(signals.created)


        compare(Lodash.keys(ra.priv.idMap).length, 2 , "Should still be 2 ids!")

        compare(ra.get("0/hobbies/100/aliases") , aliases)

        compare(signals.created.length , 0 , "ACTUAL SIGNALS : " + JSON.stringify(signals.created,null,2))

        compare(rc['0/hobbies/100/aliases'], true, "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))
        compare(signals.updated.length , 1 , "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))
    }

    function test_20_deleteIn_unidedArray(){
        var upd2 = ra.priv.clone(defaultObj)
        upd2[0]  = { id : 0, hobbies : [{id:100, aliases : ["Wolf","Wolfy","Bhalu"]}] }
        ra.runUpdate(upd2);
        clearSignals();


//        ra.priv.debug = true;
        ra.del('0/hobbies/100/aliases/0')

        compare(Lodash.keys(ra.priv.idMap).length, 2 , "Should still be 2 ids!")

        var dc = reduceToMap(signals.deleted)
        compare(signals.created.length , 0 , "ACTUAL SIGNALS : " + JSON.stringify(signals.created,null,2))
        compare(signals.updated.length , 0 , "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))
        compare(signals.deleted.length , 1 , "ACTUAL SIGNALS : " + JSON.stringify(signals.deleted,null,2))

        compare(dc['0/hobbies/100/aliases/0'], true)

        compare(ra.get("0/hobbies/100/aliases/0") , "Wolfy")
        compare(ra.get("0/hobbies/100/aliases/1") , "Bhalu")
    }

    function test_21_set_unidedArray(){
        var upd2 = ra.priv.clone(defaultObj)
        upd2[0]  = { id : 0, hobbies : [{id:100, aliases : ["Wolf","Wolfy","Bhalu"]}] }
        ra.runUpdate(upd2);
        clearSignals();


        ra.priv.debug = true;
        var aliases = ["WolfMan","Wolfy","Bhalu"]
        ra.set('0/hobbies/100/aliases', aliases)

//        console.log(ra.get("0/hobbies/100/aliases"))

        compare(Lodash.keys(ra.priv.idMap).length, 2 , "Should still be 2 ids!")

        var rc = reduceToMap(signals.updated)
        compare(signals.created.length , 0 , "ACTUAL SIGNALS : " + JSON.stringify(signals.created,null,2))
        compare(signals.updated.length , 1 , "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))
        compare(signals.deleted.length , 0 , "ACTUAL SIGNALS : " + JSON.stringify(signals.deleted,null,2))

        compare(ra.get("0/hobbies/100/aliases") , aliases)
        compare(rc['0/hobbies/100/aliases'], true, "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))



    }

    function test_22_setIn_unidedArray(){
        var upd2 = ra.priv.clone(defaultObj)
        upd2[0]  = { id : 0, hobbies : [{id:100, aliases : ["Wolf","Wolfy","Bhalu"]}] }
        ra.runUpdate(upd2);
        clearSignals();


//        ra.priv.debug = true;
        ra.set('0/hobbies/100/aliases/0',"WolfMan")

//        console.log(ra.get("0/hobbies/100/aliases"))

        compare(Lodash.keys(ra.priv.idMap).length, 2 , "Should still be 2 ids!")

        var rc = reduceToMap(signals.updated)
        compare(signals.created.length , 0 , "ACTUAL SIGNALS : " + JSON.stringify(signals.created,null,2))
        compare(signals.updated.length , 1 , "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))
        compare(signals.deleted.length , 0 , "ACTUAL SIGNALS : " + JSON.stringify(signals.deleted,null,2))

        compare(ra.get("0/hobbies/100/aliases/0") , "WolfMan")
        compare(rc['0/hobbies/100/aliases/0'], true, "ACTUAL SIGNALS : " + JSON.stringify(signals.updated,null,2))



    }

    function test_23_weird() {
        var js = { id : 0, "names":[{"id":11,"val":"Shahan", list:[{id:10,derp:10}] }] }
        ra.runUpdate(js);
        clearSignals()

        var js2 = { id : 0, "names":[{"id":11,"val":"Shahan", list:[{id:10,derp:12},{id:11,derp:11}] }] }

        ra.priv.debug = true;
        ra.runUpdate(js2);

        var rc = reduceToMap(signals.updated)
        var cc = reduceToMap(signals.created)

        compare(signals.created.length, 1);
        compare(signals.updated.length, 1);
        compare(signals.deleted.length, 0);

        compare(ra.get("0/names/11/list/10/derp"), 12)
        compare(ra.get("0/names/11/list/11/derp"), 11)

        compare(rc['0/names/11/list/10/derp'] , true)
        compare(cc['0/names/11/list/11'] , true)

    }



}
