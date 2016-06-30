import QtQuick 2.5
import QtQuick.Controls 1.4
import Zabaat.Utility.SubModel 1.1
//import Zabaat.Material 1.0
//import Zabaat.Cache 1.0
Item {
    property var cachePtr : null
    onCachePtrChanged: if(cachePtr){
                           logic.clear()
                           logic.refresh()

                           if(typeof cachePtr.cacheCleared === 'function'){
//                                cachePtr.cacheCleared.connect(logic.clear)
                           }

                       }

    property string groupSeparator : "/"


//    ImageCache { id : ic }

    QtObject {
        id : logic
        property var models : []

        function clear(){
            orig.clear()
            logic.models = []
        }


        property ListModel original : ListModel { id : orig; /*onCountChanged : logic.printLm(orig) */}
        property ZSubModel sub      : ZSubModel { id : sub  ; sourceModel : orig }

        function indexOfM(lm, vals, props, giveMeIndex){
            if(toString.call(vals) !== '[object Array]' || toString.call(props) !== '[object Array]' || vals.length !== props.length)
                return indexOf(lm,vals,props,giveMeIndex)

            for(var i = lm.count - 1; i >= 0; i--){
                var item     = lm.get(i)
                var success  = true;
//                console.log('iterating', i)

                for(var v = 0; v < vals.length ; ++v){
                    var val  = vals[v]
                    var prop = props[v]

                    if(item[prop] !== val){
                        success = false;
                        break
                    }
                }

                if(success)
                    return giveMeIndex ? i : item
            }

            return giveMeIndex ? -1 : null
        }

        function indexOf(lm, val, prop, giveMeIndex) {
            for(var i = lm.count - 1; i >= 0; i--){
                var item = lm.get(i)
                if(item[prop] === val)
                    return giveMeIndex ? i : item;
            }
            return giveMeIndex ? -1 : null
        }

        function getProps(obj){
            var arr = []
            for(var o in obj)
                arr.push(o)
            return arr;
        }

        function refresh() {
            refreshModels()

            var mm = cachePtr.getMappedAndUnmapped()
            var mapped = mm.mapped
            var unmapped = mm.unmapped


            for(var c in cachePtr.srcMap){
                var a  = cachePtr.srcMap[c].toString()
                var item = indexOf(orig,a,'url')
//                console.log('indexof', a, 'is' , idx)
                if(!item){
                    orig.append({ url : a, name : "", modelName : "", isMapped : mapped.indexOf(a) !== -1 })
                }
                else
                    item.isMapped = mapped.indexOf(a) !== -1
            }

            for(var n in cachePtr.nameMap) {
                var a = cachePtr.nameMap[n].toString()
                var item = indexOf(orig , a, 'url' , false)
                if(item) {
                    var em = extractModelName(n)
                    item.name = em.name
                    item.modelName = em.mName
                }
            }

            rightView.refresh()
        }

        function handleNew(src,name){
            refreshModels()
            var em       = extractModelName(name)
            var sz = cachePtr.getSize ? cachePtr.getSize(name) : -1
            if(src === ""){
                orig.append({ url: src, name : em.name, modelName : em.mName, isMapped : false, size : sz  })
            }
            else {
                //lets see if we have a name but not a src!
                var mm       = cachePtr.getMappedAndUnmapped()
                var mapped   = mm.mapped
                var unmapped = mm.unmapped

                var item = indexOf(orig,src,'url')
                var older = indexOfM(orig, [em.name, em.mName], ['name','modelName'])
                if(older){
                    if(older.url === "") {  //WOAh, we have older and there was no url found on it. So update our records.
                        rightView.refresh()
                        older.isMapped = true;  //DUh, we just got the src now, we already had the name.
                        return older.url = src; //we dont need to go any fursther
                    }

                    older.isMapped = mapped.indexOf(older.url) !== -1
                }

                if(!item){
                    orig.append({ url: src, name : em.name, modelName : em.mName, isMapped : mapped.indexOf(src) !== -1, size :sz })
                }
                else  { //we got name now , look for size?
                    item.name = em.name
                    item.modelName = em.mName
                    item.isMapped = mapped.indexOf(src) !== -1
                    item.size =sz
                }
            }



            rightView.refresh()
        }


        function extractModelName(c){
            if(typeof c === 'string' && c.indexOf(groupSeparator) !== -1) {
                var arr = c.split(groupSeparator)
                var mName = arr[0]

                arr.splice(0,1)
                var name = arr.join(groupSeparator)
                return  { mName : mName , name : name}
            }
            return  { mName : "" , name : "" }
        }


        function refreshModels(){   //read nameMap
            var arr = ["ALL"]
            for(var c in cachePtr.nameMap){
                var em = extractModelName(c)
                if(em.mName !== "" && arr.indexOf(em.mName) === -1)
                    arr.push(em.mName)
            }
            models = arr;
        }

        function filter(group, mapFilter) {
            var m = mapFilter === "Mapped" ? true : false
            if(group === "ALL" && mapFilter === "ALL"){
                sub.filterFunc = null;
            }
            else if(group !== "ALL" && mapFilter === "ALL"){
                sub.filterFunc = function(a){ var derpo = group ; return a.modelName === derpo }
            }
            else if(group === "ALL" && mapFilter !== "ALL"){
                sub.filterFunc = function(a){ var derpo = m ; return a.isMapped === derpo }
            }
            else {
                sub.filterFunc = function(a){ var d1 = group, d2 = m; return a.modelName === d1 && a.isMapped === d2 }
            }
        }

        function printLm(lm){
            for(var i = 0; i < lm.count; ++i){
                var item = lm.get(i)
                console.log("---------------" , i , "---------------")
                console.log(JSON.stringify(item,null,2))
                console.log("---------------------------------")
            }
        }

        property Connections conn : Connections {
            target : cachePtr ? cachePtr : null
            onImageReady: {
//                console.log('imgready' , src, name)
                logic.handleNew(src,name)
            }
        }
    }

    Item {
        id : gui
        anchors.fill: parent

        Row {
            width : parent.width
            height : parent.height * 0.1

            Row {
                width : parent.width/2
                height : parent.height
                SimpleTextBox {
                    id : groupBox
                    width : parent.width/2
                    height : parent.height
                    label : "Group"
                    onAccepted: nameBox.forceActiveFocus()
                }

                SimpleTextBox {
                    id : nameBox
                    width : parent.width / 2
                    height : parent.height
                    label : "Name"
                    onAccepted: urlBox.forceActiveFocus()
                }
            }
            SimpleTextBox {
                id : urlBox
                width : parent.width / 2
                height : parent.height
                label  : "Url"
                onAccepted: {
                    var g = groupBox.text
                    var u = urlBox.text
                    var n = g !== "" ? g + groupSeparator + nameBox.text : nameBox.text

                    urlBox.text = nameBox.text = ""

                    cachePtr.add(u,n);
                    nameBox.forceActiveFocus()
                }
            }
        }


        SplitView {
            id : sv
            width : parent.width
            height : parent.height * 0.9
            anchors.bottom: parent.bottom
            Item {
                id : leftView
                width : parent.width * 0.3
                height : parent.height

                Row {
                    width : parent.width
                    height : parent.height * 0.1
                    ComboBox {
                        id : comboGROUP
                        width : parent.width/2
                        height : parent.height
                        model : logic.models
                        onCurrentTextChanged: logic.filter(currentText , comboMAP.currentText)
                    }

                    ComboBox {
                        id : comboMAP
                        width : parent.width/2
                        height : parent.height
                        model : ["ALL", "Mapped", "Unmapped"]
                        onCurrentTextChanged: logic.filter(comboGROUP.currentText , currentText)
                    }
                }



                ListView {
                    id : lv
                    width : parent.width
                    height : parent.height * 0.9
                    model : sub
                    anchors.bottom: parent.bottom
                    delegate : SimpleButton {
                        id : del
                        width : lv.width
                        height : lv.height * 0.1
                        property var m : lv.model && lv.model.count > index ? lv.model.get(index) : null
                        property string name : m ? m.name : ""
                        property string url  : m ? m.url  : ""
                        property string modelName : m ? m.modelName : ""
                        property bool isMapped: m ? m.isMapped : false
                        property int size     : m && m.size ? m.size : -1

                        property var str : del.size !== -1 ? del.modelName + '\t' + del.name + "<br>" + del.url + "<br>" + beautify(del.size) :
                                                         del.modelName + '\t' + del.name + "<br>" + del.url

                        text : str
                        onClicked: lv.currentIndex = index
                        color : lv.currentIndex === index ? "orange" : "white"
                        clip  : true
                        textColor: del.isMapped ? "black" : "red"

                        function beautify(bytes){
                            var k = 1024 //kilobytes
                            var m = 1048576 //1024 * 1024 megabytes
                            var g = 1073741824 //1024 * 1024 * 1024 gigabyes
                            var t = 1099511627776 //1024 * 1024 * 1024 * 1024   terabytes

                            if(bytes >= t)  return (bytes/t).toFixed(2) + " TB"
                            if(bytes >= g)  return (bytes/g).toFixed(2) + " GB"
                            if(bytes >= m)  return (bytes/m).toFixed(2) + " MB"
                            if(bytes >= k)  return (bytes/k).toFixed(2) + " KB"

                            return bytes + " Bytes"
                        }

                    }
                    Rectangle  {
                        color : 'transparent'
                        anchors.fill: parent
                        border.width: 3
                    }

                }

            }
            Item {
                width  : parent.width * 0.5
                height : parent.height

                Image {
                    id : midImg
                    anchors.centerIn: parent
                    width : parent.width * 0.75
                    height : parent.height * 0.75
                    fillMode : Image.PreserveAspectFit

                    Connections {
                        target : lv
                        onCurrentIndexChanged : a()
                        onCurrentItemChanged : a()

                        function a(){
                            if(lv.currentIndex  !== -1){
                                var item = lv.model.get(lv.currentIndex)
                                var s = item.modelName ? item.modelName + groupSeparator + item.name : item.name
                                midImg.source = cachePtr.load(item.url,s, midImg, 'source')
//                                console.log(JSON.stringify(item,null,2))

                            }
                        }
                    }




                }
            }
            Rectangle {
                id : rightView
                width : parent.width * 0.2
                height : parent.height
                border.width: 3

                function refresh(){
                    jsonViewText.text = " nameMap : " + JSON.stringify(cachePtr.nameMap , null , 2) + "\n srcMap : " + JSON.stringify(cachePtr.srcMap, null ,2)
                }

                ScrollView {
                    anchors.fill: parent
                    Text {
                        id : jsonViewText
                        width : parent.width
                        height : paintedHeight
                        font.pixelSize: rightView.height * 1/40
                        horizontalAlignment: Text.AlignLeft
                    }
                }





            }
        }


    }

}
