import QtQuick 2.5
import Zabaat.Utility 1.1
import QtQuick.Controls 1.4

Item {
    ListModel {
        id : original
        Component.onCompleted: {
            append([{n:'apple' , color : 'red' } ,
                    {n:'mango' , color : 'yellow' } ,
                    {n:'grape' , color : 'green' } ,
                    {n:'banana', color : 'yellow' } ,
                   ])
        }
    }


    Row {
       anchors.fill: parent

       ListView {
           id : lv
           width : parent.width  * 0.475
           height : parent.height
           model : original
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
           model : ZSubModel {
               id : sub
               sourceModel : original
               filterFunc: function(a) {
                   return a.color === "yellow"
               }

               sortFunc  : null
   //            onCountChanged         : console.log("sub.count=",count)
   //            Component.onCompleted  : console.log("sub.count=",count)
           }
           delegate : Text {
               width         : flv.width
               height        : flv.height * 0.1
//               text : n
               property var m : sub.get(index)
               text          : m ? JSON.stringify(m) : ""
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



       }


    }


}
