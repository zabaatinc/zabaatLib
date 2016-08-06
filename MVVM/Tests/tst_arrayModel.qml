import QtTest 1.0
import QtQuick 2.0
import Zabaat.MVVM 1.0
import Zabaat.Utility 1.0

TestCase {
    id : rootObject
    name : "ArrayModel"
    property var sigsDeleted;
    property var sigsUpdated;
    property var sigsCreated;
    property var sigsMapsAdded;
    property var sigsMapsUpdated;
    property var sigsMapsDeleted;
    property var defaultData : [{ id :0, name: "Shahan" , hobbies : ['a','b'] } ,
                                { id :1, name: "Fahad"  , hobbies : ['a','b'] }]

    function clone(obj) {
        return JSON.parse(JSON.stringify(obj))
    }


    function groupSignalArrays(m) {
        var paths      = []
        var oldValues  = []
        var values     = []
        var mapNames   = []
        var groups     = []
        var indices    = []

        _.each(m, function(v,k){
            if(v.mapName  !== undefined)   mapNames.push(v.mapName);
            if(v.oldValue !== undefined)   oldValues.push(v.oldValue);
            if(v.value    !== undefined)   values.push(v.value);
            if(v.group    !== undefined)   groups.push(v.group);
            if(v.index    !== undefined)   indices.push(v.index);
            if(v.path     !== undefined)   paths.push(v.path);
        })

        return {
            paths     : paths,
            oldValues : oldValues,
            values    : values,
            mapNames  : mapNames,
            groups    : groups,
            indices   : indices
        }
    }


    ArrayModel {
        id : am
    }

    Connections {
        target : am ?  am : null
        onDeleted    : sigsDeleted.push({path    : path})
        onUpdated    : sigsUpdated.push({path    : path   , value : value , oldValue : oldValue})
        onCreated    : sigsCreated.push({path    : path   , value : value })
        onMapsUpdated: sigsMapsAdded.push({mapName : mapName, group : group, index : index })
        onMapsAdded  : sigsMapsAdded.push({mapName : mapName, group : group, index : index })
        onMapsDeleted: sigsMapsDeleted.push({mapName : mapName, group : group, index : index })
    }



    function init() { //TESTS BEGIN HERE ! runs before every test!
        am.init(clone(defaultData), "hobbies.0")

        sigsDeleted      = [];
        sigsUpdated      = [];
        sigsCreated      = [];
        sigsMapsAdded    = [];
        sigsMapsUpdated  = [];
        sigsMapsDeleted  = [];
    }

    //tests the init function. it is always called in init_data so this should work
    function test_01_init() {
        compare(am.length, 2, "length should be 2 after init")
        compare(am.priv.mapKeys.length, 2 , "mapKeys length mismatch!")
        compare(am.priv.mapKeys.indexOf("id") !== -1, true, "no id key found")
        compare(am.priv.mapKeys.indexOf("hobbies.0") !== -1, true, "no hobby key found")
        compare(sigsDeleted.length , 0);
        compare(sigsUpdated.length , 0);
        compare(sigsCreated.length , 0);
        compare(sigsMapsAdded.length , 0);
        compare(sigsMapsUpdated.length , 0);
        compare(sigsMapsDeleted.length , 0);
    }
    function test_02_reset() {
        am.reset();
        compare(am.priv.mapKeys, undefined , 'map hash keys should be undefined after reset');
        compare(am.arr, undefined , 'array should be undefined after reset')
        compare(am.length , -1, 'should be -1 after reset')
    }
    function test_03_mapNamesAfterInit() {
        if(!am.priv.maps)
            return fail("priv.maps should be defined at this point!");

        compare(typeof am.priv.maps.id === 'object', true, "should always have an id map")
        compare(typeof am.priv.maps['hobbies.0'] === 'object', true, "maps should also have a key of hobbies.0")
    }
    function test_04_idGet() {
        var shahan = am.getById(0);
        var fahad  = am.getById(1);

        if(shahan && fahad) {
            compare(shahan.name, "Shahan")
            compare(fahad.name, "Fahad")
        }
        else  {
            fail("getById(0) & getById(1) should both return objects!")
        }
    }
    function test_05a_findFirst_found() {
        var f = function(a) { return a.name === 'Fahad' }
        var item = am.findFirst(f)
        var index = am.findFirst(f,true)

        //test item
        compare(typeof item , 'object', "findFirst should have returned an object")
        compare(item.id, 1)
        compare(index , 1, "index should be 1")
    }
    function test_05b_findFirst_notfound() {
        var f = function(a) { return a.name === 'derp' }
        var item = am.findFirst(f)
        var index = am.findFirst(f,true);

        //test index
        compare(item === undefined || item === null, true, "findFirst should have returned nothing!")
        compare(index, -1, "should be -1. Not found you know")
    }
    function test_05c_findFirst_startIndex() {
        var f = function(a) { return a.name === 'Fahad' }
        var item = am.findFirst(f,false,1);
        var item2 = am.findFirst(f,false,2);

        //test index
        compare(typeof item, 'object', "item1 should be found!")
        compare(item2 === null || item === undefined, true, "item2 should be null cause we told it to start on index 2!")
    }
    function test_06a_find_found(){
        var f = function(a) { return a.hobbies.indexOf('a') !== -1 }
        var arr = am.find(f);
        var arrIndices = am.find(f,true);

        compare(toString.call(arr) === '[object Array]' , true, "result should be an array")
        compare(arr.length, 2 , "there should be 2 results")
        compare(typeof arr[0], "object", "result at idx 0 should have been an object" )
        compare(toString.call(arrIndices) === '[object Array]' , true, "result should be an array of indices")
        compare(arrIndices.length, 2 , "there should be 2 indices results")
        compare(typeof arrIndices[0] , "number" , "result at idx 0 of indices should be number")
    }
    function test_06b_find_startIndex(){
        var f = function(a) { return a.hobbies.indexOf('b') !== -1 }
        var arr = am.find(f,false,1);

        compare(arr.length, 1 , "there should be 1 result")
    }
    function test_06c_find_notfound(){
        var f = function(a) { return a.hobbies.indexOf('c') !== -1 }
        var arr = am.find(f);
        var arrIndices = am.find(f,true);

        compare(toString.call(arr) === '[object Array]' , true, "result should be an array")
        compare(arr.length, 0 , "there should be 0 results")
        compare(toString.call(arrIndices) === '[object Array]' , true, "result should be an array of indices")
        compare(arrIndices.length, 0 , "there should be 0 indices results")
    }
    function test_07a_setById_rootLevel_string() {
        am.setById(0,null,"Shahan");
        compare(am.arr[0], "Shahan");
    }
    function test_07b_setById_rootLevel_object() {
        am.setById(0,null, {name : "Wolf" })
        compare(am.arr[0].name , "Wolf")
    }
    function test_07c_setById_rootLevel_array() {
        am.setById(0,null, ["Wolf"])
        compare(am.arr[0][0] , "Wolf")
    }
    function test_07c_setById_notRootLevel() {
        am.setById(0,"hobbies.2", "c");
        compare(am.arr[0].hobbies[2] , "c")
    }
    function test_08_setById_invalidId() {
        am.setById(2,"hobbies.2", "c");
//        console.log(JSON.stringify(am.arr,null,2))
        compare(am.arr[2].hobbies[0] , undefined)
        compare(am.arr[2].hobbies[1] , undefined)
        compare(am.arr[2].hobbies[2] , "c")
        compare(am.length, 3);  //the length should have been updated to 3!!
    }
    function test_09a_signals_setId_nonexistent() {
        var obj = { hobbies : ["a"] }

        am.setById(2, obj)

        compare(am.length, 3)
        compare(sigsCreated.length  , 1 , "should have received a created signal!!" );
        compare(sigsCreated[0].path , '2')
        compare(sigsCreated[0].value, obj)
        compare(sigsMapsAdded.length, 2 , "should have received 2 mapsAdded signals. id & hobbies.0")

        var m  = groupSignalArrays(sigsMapsAdded)

        verify(m.mapNames.indexOf('id')        !== -1, "one of the mapNames should be id" )
        verify(m.mapNames.indexOf('hobbies.0') !== -1, "one of the mapNames should be hobbies.0" )
        verify(m.groups.indexOf('2')           !== -1, "id map should have group 2")
        verify(m.groups.indexOf('a')           !== -1, "hobbies.0 map should have group a")
        verify(m.indices.indexOf(0)            !== -1, "new item should have said that it was placed on index 0 in id,2")
        verify(m.indices.indexOf(2)            !== -1, "new item should have said that it was placed on index 2 in hobbies.0,a")
    }
    function test_09b_signals_setId_existent() {
        var obj = { loves : "herping" }

        //we should lose the hobbies map!!
        //we expect to hear map 0 was updated (mapUpdated)
        //we expect to hear that 0 was updated (updated)

        am.setById(0, obj)

        compare(sigsUpdated.length    , 1, "There should have been an update at path 0")
        compare(sigsMapsUpdated.length, 1, "There should have been a mapUpdate on id,0")
        compare(sigsMapsDeleted.length, 1, "There should have been a mapDelete on hobbies.0")
    }














}
