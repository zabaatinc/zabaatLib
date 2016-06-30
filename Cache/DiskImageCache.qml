import QtQuick 2.5
import Zabaat.Utility.FileIO 1.0

QtObject{
    id : rootObject
    signal imageReady(string src, string name);
    signal cacheCleared()
    property string cacheLocation  : paths.cache


    Component.onCompleted: {
        console.log(rootObject, 'location @', cacheLocation)
        fileIO.createDirIfDoesNotExist(cacheLocation)
        logic.buildCache()
//        fileIO.deleteDirectory("C:/Users/SSK/AppData/Local/QtProject/QtQmlViewer/cache/delfolder");
    }

    //magical balloon of a function. Abstracts away a ton of stuff. usage:
    //image.source = load("http://amazeballs.png", "balls_amaze", image, "source");
    function load(imgSource, name, object, prop){
        var src = srcMap[imgSource]
        if(!src) {
            if(name !== "") {
                getByNameWhenArrives(name,object,prop)
                add(imgSource, name)
            }
            else if(imgSource !== "") {
                getBySourceWhenArrives(imgSource,object,prop)
                add(imgSource, name)
            }
            //http://pixdaus.com/files/items/pics/5/76/288576_3164f194309496100f35a7f731c90a92_large.jpg
            return ""
        }
        return src
    }
    function sanitizeName(src){
        if(src.indexOf(".") !== -1){
            var arr= src.split(".")
            arr.splice(arr.length - 1, 1)
            src = arr.join(".")
        }

        var re = new RegExp('/', "g")
        return src.replace(re, '_')
    }


    function add(imgSource, nameOptional, override){
        //let's see if we already have this thing!
        if(!logic.cacheLoaded && !override){ //we will do these requests once we have scraped the file system. no need to request yet cause we might already have data.
            if(!logic.addRequests)
                logic.addRequests = []

            logic.addRequests.push({imgSource : imgSource , nameOptional : nameOptional})
            return;
        }

        var orig = nameOptional
//        console.log('add @' , nameOptional)


        if(srcMap[imgSource])
            return srcMap[imgSource]

        if(nameMap[nameOptional]){
            //lets add an entry here for the imgSource cause we cheeky bastards:P

            srcMap[imgSource] = nameMap[nameOptional]
            imageReady(imgSource,nameOptional)
            return nameMap[nameOptional]
        }

        var arr  = imgSource.toString().split("/")
        var last = arr[arr.length-1]
        var ext  = "";

        if(!nameOptional){
            nameOptional = last
            console.warn('assigned nameOptional', nameOptional, "-- don't rely on the web")
            console.log("---------------"); console.trace(); console.log("---------------");
        }

//        if(nameOptional.indexOf('.') === -1) {

//            if(last.indexOf(".") !== -1){
//                var e = last.split(".")
//                ext = "." + e[e.length -1]
//            }
////            else{
////                ext = '.png'
////            }
//        }
//        else {
//            e = nameOptional.split(".")
//            ext = "." +  e[e.length -1];

//            e.splice(e.length -1, 1);
//            nameOptional = e.join("")
//        }

        //finally , lets remove any dumb shit like "/" from the filename!
        nameOptional = sanitizeName(nameOptional)


        console.log('ADD', nameOptional, " ", orig)
        downloader.download(imgSource, cacheLocation + "/" + nameOptional + ext )

//        downloader.download()

    }
    function getBySource(src){
        return srcMap[src]
    }
    function getByName(name){
        return nameMap[name]
    }
    function getBySourceWhenArrives(src, object, prop){
        var item = srcMap[src]
        if(item)
            return item;

        if(!logic.reqSrc)
            logic.reqSrc = {}

        if(!logic.reqSrc[src])
            logic.reqSrc[src] = [{obj:object,prop:prop}]
        else
            logic.reqSrc[src].push({obj:object,prop:prop})

        return ""

    }
    function getByNameWhenArrives(name, object, prop){
        var item = nameMap[name]
        if(item)
            return item;


        if(!logic.reqName)
            logic.reqName = {}

        if(!logic.reqName[name])
            logic.reqName[name] = [{obj:object,prop:prop}]
        else
            logic.reqName[name].push({obj:object,prop:prop})

        return ""
    }
    function getMappedAndUnmapped(){
        var mapped = []
        var unmapped = []

        function a(s, k){
            for(var n in nameMap){
                if(nameMap[n] === s ){
                    if(mapped.indexOf(k) === -1)
                        return mapped.push(k)
                    return
                }
            }
            if(unmapped.indexOf(k) === -1)
                unmapped.push(k)
        }

        for(var s in srcMap){
            a(srcMap[s], s)
        }

        return {mapped : mapped , unmapped : unmapped}
    }
    function clearCache(){
        fileIO.deleteAllFilesInFolder(cacheLocation,["*"]);
        srcMap = {}
        nameMap = {}
        sizeMap = {}
        logic.cacheSize = 0;

        cacheCleared();
    }

    function getSize(id){
        if(sizeMap[id]){
            return sizeMap[id]
        }

        //id might have been source so we have to do some lookups. kinda dumb but oh well.
        for(var s in srcMap){
            var loc = srcMap[s]
            for(var n in nameMap){
                var loc2 = nameMap[n]
                if(loc === loc2){
                    var sz = sizeMap[n]
                    return sz ? sz : -1;
                }
            }
        }

        return -1;
    }

    property var srcMap  : ({})
    property var nameMap : ({})
    property var sizeMap : ({})

    property QtObject logic : QtObject {
        id : logic

        property bool cacheLoaded : false
        property var  addRequests : []
        property int  cacheSize   : 0

        onCacheLoadedChanged: if(cacheLoaded){
                                    for(var i = addRequests.length - 1; i >= 0; --i){
                                        var r = addRequests[i]
                                        addRequests.splice(i,1);

                                        rootObject.add(r.imgSource , r.nameOptional )
                                    }
                              }


        property ZPaths paths               : ZPaths          { id : paths      }
        property ZFileOperations fileIO     : ZFileOperations { id : fileIO     }
        property ZFileDownloader downloader : ZFileDownloader {
            id : downloader
            onDownloadSaved: {
//                console.log("Downloaded @", fileName, "from", url, "bytes total", bytesTotal);
                url = url.toString()
                fileName = 'file:///' + fileName

                //url is the key in srcMap and the actual source is filename!!!
                srcMap[url] = fileName

                //now lets also add to nameMap!

                var arr  = fileName.split('/')
                var name = arr[arr.length-1]
                if(name.indexOf(".") !== -1){
                    arr = name.split(".")
                    arr.splice(arr.length-1,1);
                    name = arr.join(".")
                }


                nameMap[name] = fileName
                sizeMap[name] = bytesTotal
                logic.cacheSize += bytesTotal
//                console.log("ADDING TO NAME MAP" , name, bytesTotal)

                logic.checkReqs(url,name)
                imageReady(url,name)
            }
            onDownloadFailed: {
                console.log("FAILED AT", url, fileName)
            }


        }

        //Builds the nameMap given a cache location, the source will be the location on disk!
        function buildCache(){
            //adds a fileinfo file to nameMap!
            function addFile(src,name,size){
//                console.log('cache add @', name, '=', "file:///" + src)
                nameMap[name] = "file:///" + src;
                sizeMap[name] = size;
                cacheSize += size;

                imageReady("",name);
            }


            var arr = []
            try {
                arr = JSON.parse(fileIO.filesInFolderInfo(cacheLocation,["*"]))
            }
            catch(e){
                console.warn(rootObject, e, "WHEN BUILDING DISKIMAGECACHE");
            }

            console.log("Files found in cache", arr.length)

            for(var a in arr){
                var item = arr[a]
                addFile(item.absoluteFilePath, item.baseName, item.size);
            }

            cacheLoaded = true;
        }


        //Check reqs when image is received
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

        property var reqSrc  : ({})
        property var reqName : ({})
    }
}
