import QtQuick 2.5
import QtQuick.Window 2.2
import Wolf 1.0
import QtQuick.Controls 1.4

Window {
    visible: true
    width : Screen.width
    height : Screen.height - 300

//    ListModel {
//        id : original


//        Component.onCompleted: {
//            append([{n:'apple' , color : 'red' } ,
//                    {n:'mango' , color : 'yellow' } ,
//                    {n:'grape' , color : 'green' } ,
//                    {n:'banana', color : 'yellow' } ,
//                   ])
//        }
//    }

    property alias original : simData.model
    SimulatedData {
        id: simData
//        onReadyChanged : if(ready) {
//                             sub.sourceModel = simData.model
//                         }
        url : Qt.resolvedUrl("data.txt")
    }

    Text {
        text : flv.count
    }

    Row {
       anchors.fill: parent

       ListView {
           id : lv
           width : parent.width  * 0.475
           height : parent.height
//           model : original
           delegate : Text {
               width         : lv.width
               height        : lv.height * 0.1
               property var m : original.get(index)
               text          : m ? JSON.stringify(m) : ""
               font.pixelSize: height * 1/3
           }
       }
       ListView {
           id : flv
           width : parent.width * 0.475
           height : parent.height
           model : SFModel {
               id : sub
               sourceModel : original
               filterFunc: null
               sortFunc  : null
   //            onCountChanged         : console.log("sub.count=",count)
   //            Component.onCompleted  : console.log("sub.count=",count)
           }
           delegate : Text {
               width         : flv.width
               height        : flv.height * 0.1
               property var m : sub.get(index)
               text          : m ? m.sort + " " + m.state  : ""
               font.pixelSize: height * 1/3
           }
   //        onCountChanged: console.log("lv.count",lv.count)
       }



       Column {
           id : menu
           height : parent.height
           width : parent.width * 0.05

           function randIdx(){
               return Math.floor(Math.random() * original.count)
           }


           Button {
               width : parent.width
               height : width
               text : "Add"
               onClicked : {
                   var clr = randColor()
                   var obj = {}
                   obj.n     = clr + 'berry'
                   obj.color = clr
                   original.append(obj)
               }

               function randColor(){
                   var colors = ['red','blue','green','yellow','purple','orange','black','white','golden','brown']
                   return colors[Math.floor(Math.random() * colors.length)]
               }
           }

           Button {
               width : parent.width
               height : width
               text : 'Data Change'
               onClicked : {
                   lv.model = null

//                   var item = original.get(Math.floor(Math.random() * original.count))
//                   if(item){
//                       item.color += "1"
//                   }

//                   for(var i = 0; i < original.count; ++i) {
//                        original.get(i).n += '_'
//                   }
                   original.get(1).n += "_"

                   lv.model = original
               }
           }

           Button {
               width : parent.width
               height : width
               text : 'Delete'
               onClicked : {
                   if(original.count > 0)
                       original.remove(parent.randIdx())
               }
           }

           Button {
               width : parent.width
               height : width
               text : 'move'
               onClicked : {

               }
           }

           Button {
               width : parent.width
               height : width
               text : 'Attach filter'
               onClicked : {
                    sub.filterFunc = function(a) {
                        return a.state === "pickQueue"
                    }
               }
           }

           Button {
               width : parent.width
               height : width
               text : 'Attach sort'
               onClicked : {
                    sub.sortFunc = function(a, b) {
                        return a.sort - b.sort
                    }
               }
           }




       }
    }









}
