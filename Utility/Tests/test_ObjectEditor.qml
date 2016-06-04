import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Window 2.2
import Zabaat.Material 1.0
import Zabaat.Utility 1.0

Item {
    width : Screen.width
    height : Screen.height - 300

    property var jsObj : ({ firstName : "Cheyenne",
                            lastName  : "Thayer"  ,
                            username  : "cheyenneRosa",
                            aboutme   : "loves design",
                            location  : {

                                city : 'Eugene', state : 'Oregon'
                            },
                            age : 25,
                            dob : new Date() ,
                            hobbies : ['design','herping'],
                            logout : function() { console.log('derp') }

                          })

    property var lmObj : null



    ListModel {
        id : lm
//        dynamicRoles: true;
    }

    Text {
        id: text
        text : JSON.stringify(oeditor.obj,null,2)
        font.pixelSize: parent.height * 1/40
        Button {
            text : "update"
            onClicked : parent.text = JSON.stringify(oeditor.obj,null,2)
        }
    }



    ObjectEditor {
        id : oeditor
        anchors.centerIn: parent
        color : Colors.standard
        width : parent.width/2
        height : parent.height/2
        obj : jsObj
        margins : 0

        label.component  : Component { ZText    { state : 'f2-nobar' } }
        string.component : Component { ZTextBox { state : 'f2-nobar' } }
        button {
            component:  Component { ZButton { state : 'f2-accent' }}
            textDeeper: FAR.align_right
            textShallower :FAR.align_left
        }
        title : 'Designer'
        onChange : {
            text.text = JSON.stringify(oeditor.obj,null,2)
//            console.log(location,value)
        }



        border.width: 1

        ZTracer{}
    }





    Component.onCompleted: {
        lm.append(jsObj)


        var modelFactory = function(modelObj) {
            var excludeList = ['objectName', 'undefined', 'null', 'objectNameChanged','hasOwnProperty']
            var temp = {}


            _.forEach(modelObj,function(v,k){
                var idx = k.indexOf("__")
                if(_.indexOf(excludeList, k) === -1 &&  idx === -1  ) {

                    Object.defineProperty(temp , k, {

                                                get : function()  {
                                                    var derpo = k
                                                    return modelObj[derpo]
                                                },
                                                set : function(x) {
                                                        var derpo = k
                                                        console.log("trying to set",derpo)
                                                        if(derpo.indexOf("__") === -1)
                                                            modelObj[derpo] = x
                                                      }

                                            })
                }
            })

            return temp;
        }


        var factory = function(keys) {
            var temp = {}
            for(var k in keys){
                Object.defineProperty(temp, k, {
                                        get : function()  { return temp[k] },
                                        set : function(x) { temp[k] = x  } ,
                                        writable : true
//                                        enumerable : ture,
//                                          configurable : true
                                      })
            }
            return temp
        }


        var mo = jsObj //lm.get(0) ;
//        lm.setProperty(0,'location', { city : 'derp town' })
        mo.location.city = "Derp town"
//        console.log(JSON.stringify(mo,null,2), _.keys(mo), Functions.object.getProperties(mo))


        var o = modelFactory(mo)

//        console.log(o.location.hasOwnProperty('city'))
//        console.log(o.location.city)


        console.log(o.location.city, mo.location.city)
        o.aboutme = "IM a shiny man"

//        console.log(JSON.stringify(o.location), JSON.stringify(mo.location), o.location === mo.location)


    }




}
