import QtQuick 2.5
import Zabaat.Utility 1.0
import Zabaat.Controller 1.0 as C

Item {

    C.ZController {
        id : controller
        debugMode : false
    }

    Component.onCompleted: {
        var p = []
        var s = Chance.unique(Chance.state,50)
        for(var i =0; i < 100; ++i)
            p.push({ id   : i.toString(),
                     name : Chance.first() + " " + Chance.last() ,
                     info : {
                           gender : Chance.gender() ,
                           prefix : Chance.prefix() ,
                           children : rollChildren(i === 0 ? 1 : null)
                       }

                   })
        controller.addModel("people",p)


        for(i = 0; i < s.length; ++i) {
            s[i] = {id: i.toString(), name: s[i]}
        }
        controller.addModel("states",s)

        //console.log(JSON.stringify(p,null,2))




//        var first = controller.getById("people","0")
//        console.log(JSON.stringify(first,null,2))
//        console.log(first.info.children.toString() , toString.call(first.info.children), first.info.children.length)



//        console.log(controller.models, controller.models.length, controller.getModel("people"))
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
                                        children : null
                                    }})
            }
            return children;
        }
    }


    C.ControllerView {
        id : cv
        anchors.fill: parent
        controller: controller

    }







}
