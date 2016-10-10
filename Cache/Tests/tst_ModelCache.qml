import QtQuick 2.0
import QtTest 1.0
import Zabaat.Utility.FileIO 1.0 as U
import Zabaat.Utility 1.0
import Zabaat.Cache 1.0
import Zabaat.Testing 1.0
ZabaatTest {
    id : rootObject
    objectName : "ModelCache"
    testObj: ModelCache{
        id : mc
    }

    U.ZFileOperations{ id: zfo;  }
    ListModel { id : lm;  dynamicRoles: true;   }

    property var arr
    property var newArr

    function init(){
        lm.clear()
        //green is the newest! Others are old!
        arr    = [{id:0,color:'red'  ,updatedAt:new Date(2016,7,21,15)},
                  {id:1,color:'blue' ,updatedAt:new Date(2016,7,21,30)},
                  {id:2,color:"green",updatedAt:new Date()}]

        //everything other then id:2 is the newest
        newArr = [{id:0,color:'black'   ,updatedAt:new Date()},
                  {id:1,color:'white'  ,updatedAt:new Date()},
                  {id:2,color:"gray" ,updatedAt:new Date()},
                  {id:3,color:"purple",updatedAt:new Date(2016,7,24,45)}
                ]

        lm.append(arr);
    }
    function cleanup(){
        lm.clear();
        arr = newArr = null;
    }

    function test_01_cacheArray(){
        mc.cacheModel("test1",arr);
        var merm = zfo.readFile(mc.cacheDir + "/test1");
        try {
            var js = JSON.parse(merm);
            compare(js.length, arr.length, "Both lengths should be equal")
            compare(js[0].color, 'red')
            compare(js[1].color, 'blue')
            compare(js[2].color, 'green')
        }catch(e){
            fail("Unable to read file", mc.cacheDir + "/mermaid")
        }
    }
    function test_02_cacheModel(){
        mc.cacheModel("test2",lm);
        var merm = zfo.readFile(mc.cacheDir + "/test2");
        try {
            var js = JSON.parse(merm);
            compare(js.length, lm.count, "Both lengths should be equal")
            compare(js[0].color, 'red')
            compare(js[1].color, 'blue')
            compare(js[2].color, 'green')
        }catch(e){
            fail("Unable to read file", mc.cacheDir + "/mermaid")
        }
    }
    function test_03_syncArray(){
        mc.cacheModel("test3",newArr);
        if(!mc.loadCache("test3",arr))
            fail("Unable to read file: " + mc.cacheDir + "/test3")

        compare(arr.length, 4);
        compare(arr[0].color, 'black')
        compare(arr[1].color, 'white')
        compare(arr[2].color, 'green')
        compare(arr[3].color, 'purple')
    }
    function test_04_syncModel(){
        mc.cacheModel("test4",newArr);
        if(!mc.loadCache("test4",lm))
            fail("Unable to read file:" + mc.cacheDir + "/test4")

        compare(lm.count, 4);
        compare(lm.get(0).color, 'black')
        compare(lm.get(1).color, 'white')
        compare(lm.get(2).color, 'green')
        compare(lm.get(3).color, 'purple')
    }
    function test_05_syncArrayDelete(){
        newArr[0].deleted = true;
        mc.cacheModel("test5",newArr);
        if(!mc.loadCache("test5",arr))
            fail("Unable to read file: " + mc.cacheDir + "/test5")

        var disp = Lodash.reduce(arr, function(a,e){ a.push(e.id + ":" + e.color); return a }, []);

        compare(arr.length, 3);
        compare(arr[0].color, 'white' , disp)
        compare(arr[1].color, 'green' , disp)
        compare(arr[2].color, 'purple', disp)
    }
    function test_06_syncModelDelete(){
        newArr[0].deleted = true;
        mc.cacheModel("test6",newArr);
        if(!mc.loadCache("test6",lm))
            fail("Unable to read file:" + mc.cacheDir + "/test6")

        var disp = Lodash.reduce(arr, function(a,e){ a.push(e.id + ":" + e.color); return a }, []);
        compare(lm.count, 3);
        compare(lm.get(0).color, 'white' , disp)
        compare(lm.get(1).color, 'green' , disp)
        compare(lm.get(2).color, 'purple', disp)
    }
    function test_07_syncArrayDeleteIgnore(){
        newArr[2].deleted = true;
        mc.cacheModel("test7",newArr);
        if(!mc.loadCache("test7",arr))
            fail("Unable to read file: " + mc.cacheDir + "/test7")

        compare(arr.length, 4);
        compare(arr[0].color, 'black')
        compare(arr[1].color, 'white')
        compare(arr[2].color, 'green')
        compare(arr[3].color, 'purple')
    }
    function test_08_syncModelDeleteIgnore(){
        newArr[2].deleted = true;
        mc.cacheModel("test8",newArr);
        if(!mc.loadCache("test8",lm))
            fail("Unable to read file: " + mc.cacheDir + "/test8")

        compare(lm.count, 4);
        compare(lm.get(0).color, 'black')
        compare(lm.get(1).color, 'white')
        compare(lm.get(2).color, 'green')
        compare(lm.get(3).color, 'purple')
    }


}
