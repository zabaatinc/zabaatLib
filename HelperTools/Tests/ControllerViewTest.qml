import QtQuick 2.5
import Zabaat.Utility 1.0
import Zabaat.Controller 1.1 as C
import Zabaat.HelperTools 1.0
import QtQuick.Controls 1.4

Item {

    C.ZController {
        id : controller
        debugMode : false
    }

    function randPeople(){
        var p = []
//        var s = Chance.unique(Chance.state,50)
        for(var i =0; i < 2; ++i) {
            p.push({ id   : i.toString(),
                     name : Chance.first() + " " + Chance.last() ,
                     info : {
                           gender : Chance.gender() ,
                           prefix : Chance.prefix() ,
                       },
                     children : rollChildren(i === 0 ? 1 : null)
                   })
        }
        return p;
    }

    Component.onCompleted: {



var i =0;
//        for(var i = 0 ; i < 100; ++i){
//            controller.addModel('people', { id : i, name : "Shahan" });
//            controller.addModel('people', { id : i, children : randPeople() })
//            controller.addModel('people', { id : i, children : randPeople() })
//        }

        controller.addModel('people', { id : i, name : "Shahan" });
        controller.addModel('people', { id : i, children : randPeople() })


//        controller.addModel("people",p)

//        for(i = 0; i < s.length; ++i) {
//            s[i] = {id: i.toString(), name: s[i], info : {rating :0, herp : 0}}
//        }
//        controller.addModel("states",s)


        //console.log(JSON.stringify(p,null,2))




//        var first = controller.getById("people","0")
//        console.log(JSON.stringify(first,null,2))
//        console.log(first.info.children.toString() , toString.call(first.info.children), first.info.children.length)



//        console.log(controller.models, controller.models.length, controller.getModel("people"))
    }

    Button {
        text : 'print'
        onClicked : {
            var shahan = controller.getById('people', 0)
            console.log("-----------")
            for(var s in shahan){
                console.log(s, JSON.stringify(shahan[s] ))
            }
            console.log("-----------")
        }
        z : Number.MAX_VALUE
    }

    function rollChildren(num){
        if(num === null || num === undefined)
            num = Chance.integer({min:0, max:3})

        if(!num)
            return null;
        else {
            var children = []
            for(var i = 0; i < num; ++i){
                children.push({
                               id   : i.toString(),
                               name : Chance.first() + " " + Chance.last() ,
                               info : {
                                        gender : Chance.gender() ,
                                        prefix : Chance.prefix() ,

                                    },
                               children : null
                              })
            }
            return children;
        }
    }


    ControllerView {
        id : cv
        anchors.fill: parent
        controller: controller
    }

    Timer {
        id : updateChecker
        running : true
        interval : 100
        repeat : true
        onTriggered : {
            var m = controller.getById("people","0")
            if(m){
                m.children.get(0).name += "_";
//                console.log(m.children.get(0).name)
            }

            var s=  controller.getById('states','0')
            if(s){
                var r = s.info.rating + 1
                s.info = {rating : r , herp : s.info.herp }
//                console.log(s.info.rating)
            }
        }
    }







}
