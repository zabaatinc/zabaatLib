import QtQuick 2.5
import Zabaat.Base 1.0
Item {
    id : rootObject

//EXAMPLE
//obj : ({
//    firstName : "Cheyenne",
//    lastName  : "Thayer"  ,
//    username  : "cheyenneRosa",
//    aboutme   : "loves design",
//    location  : {

//       city : 'Eugene', state : 'Oregon'
//    },
//    buddies : [ { first:"Brett",last:"Ansite",age:30, buddies : [{first:"Shahan",last:"Kazi",age:28},
//                                                               {first:"Cheyenne",last:"Thayer",age:25}  ]},
//               { first:"Shahan",last:"Kazi",age:28 , buddies : [{ first:"Brett",last:"Ansite",age:30} ,
//                                                                {first:"Cheyenne",last:"Thayer",age:25} ]}
//             ] ,
//    age : 25,
//    dob : new Date() ,
//    hobbies : ['design','herping'],
//    logout : function() { console.log('derp') }
//})

///Notice how the arrays are defined a bit differently. Special keyword "0" is used to determine all indices of the array!!
///And as in the example, they can be nested!!

//configJs : ({
//    firstName : { index : 0,
//                  displayFunc : function(a) { return a.toUpperCase() } ,
//                  setterFunc  : function(a) { return a.toLowerCase() }
//                } ,
//    lastName  : { index : 1 } ,
//    age       : { index : 2, component : customCmp } ,
//    location  : {
//        city : {
//              index : 0 , valueField : 'label'
//          }

//    },
//    buddies :  {
//        index : 4,
//        "0" :  {
//              first: {index : 0} ,
//              last: {index : 1} ,
//              age: {index : 2} ,
//              buddies: { index : 3,
//                         "0"   : {
//                            first: {index : 0} ,
//                            last: {index : 1} ,
//                            age:{index:3, component : customCmp}
//                         }
//                       }
//            }
//     }
//})



    property var obj        //the object to edit && walk thru!
    property var configJs   //to customize the way your object looks && force stuff!
    property color color          : "violet"
    property string title         : ""
    property real   margins       : 5
    property alias  logic         : logic
    property bool   centered      : false
    property int    animDuration  : 333
    property bool   hideTitle     : false

    property alias string : str
    property alias label  : label
    property alias number : number
    property alias bool   : bool
    property alias date   : date
    property alias image  : image
    property alias button : button
    property alias func   : func
    property alias border : border

    signal change(var obj, string location , var value)
    signal close()

    property real cellHeight : height * 0.1

    onConfigJsChanged: startInspectionTimer.start()
    onObjChanged     : startInspectionTimer.start()


    QtObject {
        id : logic

        property Timer startInspectionTimer: Timer { id : startInspectionTimer ; interval : 20; onTriggered: logic.inspect() }
        property BorderProps border        : BorderProps { id : border }
        property ListModel lm              : ListModel { id : lm ; dynamicRoles: true }
        property var excludeList           : ['objectName', 'undefined', 'null', 'objectNameChanged','hasOwnProperty']
        property string propStr            : ""

        property var  root                 //the subset of obj determined by propStr
        property var  rootType             //the type of root
        property var  thisConf             //the subset of configJs determined by propStr


        function sortFunc(a,b) {
           if(a.index === undefined)   return 1;
           if(b.index === undefined)   return -1;
           return a.index - b.index
        }

        function objToArr(obj, renameKeyTo, sortFunc) {
            var arr = []
            renameKeyTo = renameKeyTo || "name"

            for(var o in obj) {
                var item = Lodash.clone(obj[o])
                item[renameKeyTo] = o
                arr.push(item)
            }

            if(sortFunc)
                arr = arr.sort(sortFunc)
            return arr
        }


        function getArrayOfProperties(obj) {   //returns array of properties in order as determined by configJs (if exists)
            var props = []
            if(thisConf) {
                var cArr     = objToArr(thisConf, '_name', sortFunc)
                for(var i = 0; i < cArr.length; ++i){
                    var item = cArr[i]
                    props.push(item._name)
                }
            }
            for(var o in obj) { //only add stuff here that was not included from configJs's loop. so check in props!!
                if(indexOf(props,o) === -1)
                    props.push(o)
            }

            return props;
        }


        function set(key, value, setterFunc){
            var k = propStr === "" ? key : propStr + "." + key
            var nv = setterFunc ? setterFunc(value) : value
            if(Functions.object.deepSet(obj,k, nv)) {
                rootObject.change(obj, k, Functions.object.deepGet(obj,k));
            }
        }

        function get(key) {
//            console.log('key',key)
            if(!logic.rootType || logic.rootType === 'undefined')     return null;

//            console.log('key', logic.rootType.toLowerCase() , root)
            return Functions.object.deepGet(obj, propStr === "" ? key : propStr + "." + key)

//            var r = logic.rootType.toLowerCase()
//            if(r.indexOf('modelnode') !== -1 || r.indexOf('modelobject') !== -1)  return obj[key]
//            if(r.indexOf('model') !== -1)                                       	return obj.get(key)
//                                                                                	return obj[key]
        }

        function addObj(obj){

            var  propArr = getArrayOfProperties(obj);
            if(propStr !== ""){

//                console.log(JSON.stringify(obj,null,2) , propArr)

            }
            for(var i = 0; i < propArr.length; ++i){
                var p = propArr[i]
                if(indexOf(excludeList,p) !== -1 || p.indexOf("__") === 0)
                    continue

                var key  = p
                if(!existsInLm(lm, function(i){ return i && i.key === key ? true : false }))
                    lm.append({ key     : key ,
                                type    : Functions.object.getType(obj[key])
                              })
            }
        }

        function addArr(obj){

            for(var i = 0; i < obj.length ; ++i){
                var key = i
                var type = Functions.object.getType(obj[key])
//                console.log('addArr', key, type, JSON.stringify(obj[key]))
                lm.append({ key     : key ,
                            type    : type
                           })
            }
        }

        function addLm(obj){
            for(var i = 0; i < obj.count ; ++i){
//                var item = obj.get(i)
                var type = Functions.object.getType(obj.get(i))
//                console.log(i, 'adding', type, JSON.stringify(obj.get(i),null,2))
                lm.append({ key     : i ,
                            type    : type
                          })
            }
        }

        function indexOf(arr, val) {
            for(var a = 0; a < arr.length; ++a)
                if(arr[a] === val)
                    return a;
            return -1;
        }

        function existsInLm(lm, func) {
            if(lm){
                for(var i = 0; i < lm.count; ++i){
                    var item = lm.get(i)
                    if(func(item))
                        return true;
                }
            }
            return false;
        }

        function isStdJsType(obj){
            var t = typeof obj
            if(obj === null || t === 'undefined' || t === 'boolean' || t === 'number' || t === 'string' || toString.call(obj) === '[object Date]' || t === 'function' )
                return true;
            return false;
        }

        function addProperties() {
            if(root){
                var n = root.toString().toLowerCase()
                if(n.indexOf("modelnode") !== -1 || n.indexOf('modelobject') !== -1){
//                    console.log(rootObject.objectName , 'adding obj')
                    addObj(root)
                }
                else if(toString.call(root) === '[object Array]'){
//                    console.log(rootObject.objectName, "adding array at", obj.length)
                    addArr(root)
                }
                else if(n.indexOf("model") !== -1){
//                    console.log(rootObject.objectName, 'adding model')
                    addLm(root)
                }
                else if(typeof root === 'object'){
//                    console.log(rootObject.objectName, "adding object last")
                    addObj(root)
                }
                else {
//                    console.log(rootObject.objectName, 'adding nothing!!!!!!!', obj, typeof obj)
                }
            }
            else if(rootObject.objectName !== ""){   //not an empty thing but still null!
//                console.error(rootObject.objectName , "obj is null or undefined!!")
            }
        }

        function inspect() {
            lm.clear()

            root     = Functions.object.deepGet(obj,propStr)  //a subset of the obj based on propStr
            rootType = Functions.object.getType(root)

            //get config obj according to context!!
            if(configJs){
                if(!propStr || propStr === "")
                    thisConf = configJs
                else {
                    var p = propStr.split(".")

                    //check if last one is number!
                    if(!isNaN(p[p.length-1])) {
                        p[p.length - 1] = "0";
                    }
                    p = p.join(".")

                    thisConf = Lodash.at(configJs, p)
                    if(thisConf.length > 0)
                        thisConf = thisConf[0]
                    else
                        thisConf = null;
                }
            }
            else {
                thisConf = null;
            }
//            if(propStr !== "") {
//                console.log(propStr, JSON.stringify(thisConf,null,2))
//            }

            //now that we have everything set up! Let's start adding properties!!!
            logic.addProperties()
        }

        function copy(oe){
            //COPY ALL THE CMPS
            var arr = [ "string","label","number","bool","date","image","button","func"]
            for(var a in arr) {
                var k = arr[a]
                rootObject[k].component     = oe[k].component
                rootObject[k].valueProperty = oe[k].valueProperty
                if(k === 'button'){
                    rootObject[k].textDeeper    = oe[k].textDeeper
                    rootObject[k].textShallower = oe[k].textShallower
                }
            }

            rootObject.color        = oe.color
            rootObject.border.width = oe.border.width
            rootObject.border.color = oe.border.color
            rootObject.margins      = oe.margins
            rootObject.centered     = oe.centered


            rootObject.configJs  = oe.configJs
        }

    }
    QtObject  {
        id : components
        property ComponentInfo string : ComponentInfo { id:str     ; component : null           ; }
        property ComponentInfo label  : ComponentInfo { id:label   ; component : str.component ; }
        property ComponentInfo number : ComponentInfo { id:number  ; component : str.component ; }
        property ComponentInfo bool   : ComponentInfo { id:bool    ; component : str.component ; }
        property ComponentInfo date   : ComponentInfo { id:date    ; component : str.component ; }
        property ComponentInfo image  : ComponentInfo { id:image   ; component : str.component ; }
        property ComponentInfoButton button : ComponentInfoButton {
            id:button  ;
            component : btnCmp ;
        }
        property ComponentInfo func   : ComponentInfo { id:func    ; component : button.component ; }
    }






    Item {
        id : gui
        anchors.fill: parent

        Item {
            id : thisLevel
            anchors.fill: parent

            Item {
                id: titleRect
                width   : parent.width
                height  : !hideTitle ? cellHeight * 1.1 : 0
                visible : !hideTitle

                Loader {
                    anchors.fill    : parent
                    sourceComponent : label.component
                    onLoaded        : item[label.valueProperty] = title
                    property var ss : title
                    onSsChanged: if(item) item[label.valueProperty] = ss
                }
                Loader { //button
                    width : parent.height
                    height : parent.height
                    sourceComponent: button.component
                    onLoaded : {
                        item[button.valueProperty] = button.textShallower
                        item.clicked.connect(rootObject.close)
                    }
                    property var ss: button.textShallower
                    onSsChanged: if(item) {
                                     item[button.valueProperty] = ss;
                                 }
                }


                Rectangle {
                    anchors.fill: parent
                    color : 'transparent'
                    border.width: rootObject.border.width
                    border.color: rootObject.border.color
                }

                z : Number.MAX_VALUE
            }
            Item {
                width  : parent.width
                height : parent.height - titleRect.height
                anchors.bottom: parent.bottom

                ListView {
                    id : lv
                    width  : parent.width
                    property real c: contentItem.childrenRect.height
                    property real h : parent.height
                    property bool isCentered : c < h && centered

                    height                : isCentered ? c : h
                    anchors.bottom        : isCentered ? undefined : parent.bottom
                    anchors.verticalCenter: isCentered ? parent.verticalCenter : undefined
                    model : lm
                    delegate   : Rectangle {
                        id     : del
                        width  : lv.width
                        height : cellHeight
                        color  : rootObject.color

                        property var  m          : lv.model &&  lv.count > index ? lv.model.get(index) : null
                        property var  type       : m  ? m.type        : undefined
                        property var  key        : m  ? m.key         : undefined
                        property var stdType     : ready ? logic.isStdJsType(origValue) : null
                        property var origValue   : ready ? logic.get(key) : null
                        property string typeText : {
                            if(origValue === null)                              return "null"
                            if(origValue === undefined)                         return "undefined"
                            if(typeof origValue === 'string')                   return "string"
                            if(toString.call(origValue) === "[object Date]")    return "date"

//                            console.log(origValue,type)
                            return type;
                        }

                        property var mConf     : key && logic.thisConf && logic.thisConf[key] ? logic.thisConf[key] : null
                        property var component : {
                            if(mConf && mConf.component)
                                return mConf.component

                            var t = del.typeText
                            if(t === 'function')
                                t = 'func'
                            return components[t] ? components[t].component : null
                        }
                        property var valField  : {
                            if(mConf ) {
                                if(mConf.valueProperty)     return mConf.valueProperty
                                if(mConf.valueField)        return mConf.valueField
                            }
                            var t = del.typeText
                            if(t === 'function')
                                t = 'func'
                            return components[t] ? components[t].valueProperty : ""
                        }


                        property var  dispFunc  : mConf && mConf.displayFunc ? mConf.displayFunc : null
                        property var  setterFunc: mConf && mConf.setterFunc  ? mConf.setterFunc  : null

                        property bool ready : obj && type !== null && type !== undefined && key !== null && key !== undefined ? true : false
                        onReadyChanged: if(ready) {
                                            origValue = logic.get(key)
                                        }



                        Row {
                            anchors.fill: parent
                            //row of loaders!
                            property real w : (parent.width - delButton.width)/2
                            Item {
                                width  : del.type !== 'function' ? parent.w : 0
                                visible : width !== 0
                                height : parent.height
                                Loader {
                                    id : delLabel
                                    anchors.fill: parent
                                    anchors.margins: rootObject.margins
                                    sourceComponent: label.component
                                    onLoaded : {
                                        item.anchors.fill = delLabel
                                        item[label.valueProperty] = del.key
                                    }
                                }
                            }

                            Item {
                                width  : del.type !== 'function' ? parent.w : parent.width
                                height : parent.height
                                Loader {
                                    id : delValue
                                    anchors.fill: parent
                                    anchors.margins: rootObject.margins
                                    sourceComponent: del.valField !== "" ? del.component : null
                                    onLoaded : {
                                        item.anchors.fill = delValue
            //                            console.log("LOADED", item)
                                        connect()
                                    }

                                    function connect(){
                                        if(item) {
                                            del.origValue = Qt.binding(function() { return logic.get(del.key) })

                                            if(del.type === 'function') {
                                                item[del.valField] = del.key
                                                item.clicked.connect(del.origValue)
                                            }
                                            else {
                                                //WATCH THIS BINDING CLOSELY COMRADES!
                                                item[del.valField] = Qt.binding(function() { return del.dispFunc ? del.dispFunc(del.origValue) : del.origValue })

                                                //init it!, then connect it!
                                                item[del.valField + "Changed"].connect(valChanged)   //USER CHANGE!
                                            }


                                        }


                                    }

                                    function disconnect(){
                                        if(item)
                                            item[label.valueProperty + "Changed"].disconnect(valChanged)
                                    }

                                    function valChanged(){
                                        if(!item)
                                            return;

                                        disconnect()

                                        logic.set(del.key, item[del.valField] , del.setterFunc)

                                        connect()
                                    }
                                }
                            }

                            Item {
                                width  : del.type !== 'function' ? parent.height  : 0
                                height : parent.height
                                Loader {
                                    id : delButton
                                    anchors.fill: parent
                                    anchors.margins: rootObject.margins
                                    sourceComponent : button.component
                                    visible : !del.stdType
                                    onLoaded : {
                                        item.anchors.fill = delButton
                                        item[button.valueProperty] = ss
                                        item.clicked.connect(function() { nextLevelLoader.loadKey(del.key) })
                                    }
                                    property var ss: button.textDeeper
                                    onSsChanged: if(item) item[button.valueProperty] = ss;
                                }
                            }
                        }

//                        Text {
//                            anchors.fill: parent
//                            text : del.typeText
//                            visible  : rootObject.debugMode
//                        }
                        Rectangle {
                            anchors.fill: parent
                            color : 'transparent'
                            border.color: rootObject.border.color
                            border.width: rootObject.border.width
                            z : Number.MAX_VALUE
                        }

                    }
                }
            }
        }

        Loader {
            id     : nextLevelLoader
            width  : parent.width
            height : parent.height
            x      : width  //be outside!!


            property string key
            function loadKey(key){
//                console.log("CALLED")
                nextLevelLoader.key = key;
                source = "ObjectEditor.qml"
            }
            function unload(){
                source = ""
            }

            UIBlocker {
                anchors.fill: parent
                visible : nextLevelLoader.item
                enabled : visible
                solidBackGround: true
            }

            onLoaded : {
                if(item){
                    blockEverything.visible = true;

                    item.title = key
                    item.logic.propStr = logic.propStr === "" ? key : logic.propStr + "." + key
                    item.logic.copy(rootObject)   //copy the properties from root!

//                    console.log(item.logic.propStr, JSON.stringify(Functions.object.deepGet(obj,item.logic.propStr)) )
                    item.obj = obj

//                    console.log(Functions.object.deepGet(item.obj, item.logic.propStr) === obj[key] )
                    item.change.connect(rootObject.change)
                    item.close.connect(bringItOut.start)
                }
                bringItIn.start()
            }


            NumberAnimation {
                id: bringItIn
                from : nextLevelLoader ? nextLevelLoader.width : 0
                to   : 0;
                duration : rootObject.animDuration
                properties: "x"
                target: nextLevelLoader
                onStopped : blockEverything.visible = false;
            }

            NumberAnimation {
                id: bringItOut
                from   : 0;
                to  : nextLevelLoader ? nextLevelLoader.width : 0
                duration : rootObject.animDuration
                properties: "x"
                target: nextLevelLoader
                onStarted : blockEverything.visible =true;
                onStopped : nextLevelLoader.unload()
            }

            UIBlocker {
                id : blockEverything
                anchors.fill: parent
                visible : nextLevelLoader.item
                enabled : visible
                z : Number.MAX_VALUE
            }

        }

    }














    Item {
        id : container

        Component {
            id : btnCmp
            Rectangle {
                signal clicked()
                property alias text : btnCmpText.text
                border.width: 1
                color : 'aqua'
                radius: height/8
                Text {
                    id : btnCmpText
                    anchors.fill: parent
                    anchors.margins: 5
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    font.pixelSize: height * 1/3
                    scale : paintedWidth > width ? width / paintedWidth : 1
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked : parent.clicked()
                }
            }
        }

    }

















}
