import QtQuick 2.5
///WARNING!! USE AT OWN RISK!
///THIS THING IS SWEET AND FAST BUT REMEMBER, HOLDS ALL IMAGES UNCOMPRESSED IN RAM!
///THIS IS NOT A SOLUTION FOR CACHING TONS OF BIG IMAGES. THIS IS A SOLUTION FOR FEW SMALL IMAGES
///THAT YOU KNOW WE WILL KEEP USING.

///SACRIFICES TONS OF RAM FOR INSTANT IMAGE LOADING!!!
QtObject {
    id : rootObject
    signal imageReady(string src, string name);

    Component.onCompleted: {
        console.warn(rootObject, "WARNING!! USE AT OWN RISK! THIS THING IS SWEET AND FAST BUT REMEMBER, HOLDS ALL IMAGES UNCOMPRESSED IN RAM! THIS IS NOT A SOLUTION FOR CACHING TONS OF BIG IMAGES. THIS IS A SOLUTION FOR FEW SMALL IMAGES THAT YOU KNOW WE WILL KEEP USING. SACRIFICES TONS OF RAM FOR INSTANT IMAGE LOADING!!!")
    }

    function load(imgSource, object, prop) {    //convenience function of calling add and getBySourceWhenArrives!
        var src = srcMap[imgSource]
        if(!src) {
            getBySourceWhenArrives(imgSource,object,prop)
            add(imgSource)
            return ""
        }
        return src
    }

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

    function getMappedAndUnmapped(){
        var mapped   = []
        var unmapped = []

        function a(s){
            for(var n in nameMap){
                if(nameMap[n] === s ){
                    if(mapped.indexOf(s) === -1)
                        return mapped.push(s)
                    return
                }
            }
            if(unmapped.indexOf(s) === -1)
                unmapped.push(s)
        }

        for(var s in srcMap){
            a(s)
        }
        return { mapped : mapped , unmapped : unmapped }
    }

    property var srcMap   : ({})
    property var nameMap  : ({})
//    property var unmapped : []          //these sources are not nameMapped
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
                    var s = source.toString()

                    if(!srcMap)       srcMap = {}
                    if(!nameMap)      nameMap = {}

                    srcMap[s] = s
                    if(name) {
//                        if(nameMap[name] && unmapped.indexOf(s) === -1) { //if it already exists!
//                            unmapped.push(nameMap[name])
//                        }

                        nameMap[name] = s
                        imgContainer.checkReqs(s,name);
                        imageReady(s,name);
//                        console.log("added to imgCache", name , '=', nameMap[name], imgContainer.children.length)
                    }
                    else {
//                         if(unmapped.indexOf(s) === -1)
//                            unmapped.push(s)

                        imgContainer.checkReqs(s,null);
                        imageReady(s,"");
                    }
                }
                else if(status === Image.Error){
                    console.log("unable to load image!", source)
                    img.destroy();
                }
            }
        }
    }

}
