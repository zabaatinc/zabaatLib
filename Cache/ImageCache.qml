import QtQuick 2.5
QtObject {
    id : rootObject
    signal imageReady(string src, string name);

    function add(imgSource, nameOptional){
        if(!srcMap[imgSource]){
            var i = imgFactory.createObject(imgContainer)
            i.name = nameOptional
            i.source = imgSource;
        }
    }
    function getBySource(src){
        return srcMap[src]
    }
    function getByName(name){
        return nameMap[name]
    }
    function getBySourceWhenArrives(src,object,prop){
        var item = srcMap[src]
        if(item)
            return item;

        if(!imgContainer.reqSrc)
            imgContainer.reqSrc = {}

        if(!imgContainer.reqSrc[src])
            imgContainer.reqSrc[src] = [{obj:object,prop:prop}]
        else
            imgContainer.reqSrc[src].push({obj:object,prop:prop})

        return ""
    }
    function getByNameWhenArrives(name,object,prop){
        var item = nameMap[name]
        if(item)
            return item;

        if(!imgContainer.reqName)
            imgContainer.reqName = {}

        if(!imgContainer.reqName[name])
            imgContainer.reqName[name] = [{obj:object,prop:prop}]
        else
            imgContainer.reqName[name].push({obj:object,prop:prop})

        return ""
    }

    property var srcMap  : ({})
    property var nameMap : ({})
    property Item imgContainer : Item{
        id: imgContainer
        visible : false
        property var reqName : ({})
        property var reqSrc  : ({})

        function checkReqs(src,name){

            function runOver(arr){
                for(var i = arr.length - 1; i >=0 ; --i){
                    var item = arr[i]
                    if(item.obj && item.prop){
                        item.obj[item.prop] = src;
                        arr.splice(i,1)
                    }
                }
                if(arr.length === 0)
                    return true;
                return false;
            }


            var sArr = reqSrc[src]
            if(sArr){
                if(runOver(sArr))
                    delete reqSrc[name]
            }
            if(name){
                var nArr = reqName[name]
                if(nArr){
                    if(runOver(nArr))
                        delete reqName[name]
                }
            }
        }
    }
    property Component imgFactory : Component {
        Image {
            id : img
            property var name : null
            asynchronous: true
            onStatusChanged: {
                if(status === Image.Ready) {
                    if(!srcMap)       srcMap = {}
                    if(!nameMap)      nameMap = {}

                    srcMap[source] = source;
                    if(name) {
                        nameMap[name] = source;
                        imgContainer.checkReqs(source,name);
                        imageReady(source,name);
//                        console.log("added to imgCache", name , '=', nameMap[name], imgContainer.children.length)
                    }
                    else {
                        imgContainer.checkReqs(source,null);
                        imageReady(source,"");
                    }
                }
                else if(status === Image.Error){
                    console.log("unable to load image!")
                    destroy()   //kill self if unable to load image!
                }
            }
        }
    }

}
