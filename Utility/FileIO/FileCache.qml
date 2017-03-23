import QtQuick 2.5
import Zabaat.Utility.FileIO 1.0
import Zabaat.Base 1.0
Item {
    id : rootObject
    property string cacheLocation : "C:/tmp/cache";
    Component.onCompleted         : file.makeSureLocationExits(cacheLocation).then(logic.loadMap);
    onCacheLocationChanged        : file.makeSureLocationExits(cacheLocation).then(logic.loadMap);
    property int enforce_fileLimit      : 0 //0 means there's no limit
    property int enforce_removeNumFiles : 0 //0 means that we will just delete only the oldest files when we are over fileLimit.
    property bool logDownloads          : true

    //gets a url from an id. This will be used to figure out
    //where to download the file at <id> from. Must return a promise!
    property var fnUrlGetter : function(id) {
        return Promises.promise(function(resolve,reject){
            return resolve("C:/tmp/pikachu.png");
        })
    }

    //determines whether to re-download something . Must
    //return a promise as well. Resolve with boolean true
    //if update is required, resolve with boolean false if not.
    property var fnIsOutdated : function(id, mapEntry) {
        return Promises.promise(function(resolve,reject){
            resolve(false);
        })
    }


    property alias map         : logic.map
    property alias logic       : logic


    function load(id) {
        return Promises.promise(function(resolve,reject){

            if(logic.inProgressIds[id]) {
//                Functions.log('waiting because', id, 'is in progress')
                Functions.connectUntilTruthy(logic.finishedProcessingId, function(success, finishedId, fileLocation) {
                    if(id !== finishedId)
                        return false;

                    if(!success)
                        reject();
                    else
                        resolve(fileLocation);

                    return true;
                })
                return;
            }

            function doDownload() {
                if(!logDownloads)
                    return logic.downloadPromise(id).then(resolve).catch(reject)

                return logic.downloadPromise(id).then(function(url) {
                    logic.writeDownloadLog(id,true);
                    resolve(url);
                }).catch(function() {
                    logic.writeDownloadLog(id,false);
                    reject();
                })
            }


            logic.inProgressIds[id] = true;
            logic.mapGet(id).then(function(entry) {
                //fix this. It needs to do finally after do download. not parallel
                if(!entry) {
                    return doDownload();
                }

                fnIsOutdated(id,entry).then(function(needsUpdate) {
                    return !needsUpdate ? resolve(logic.getLocation(entry)) : doDownload();
                })

            }).catch(reject).finally(function() {
                logic.inProgressIds[id] = false;
            });

        })
    }

    QtObject {
        id : logic
        //when things are inserted into the map,
        //they are always of the type :
        //<id> : {
        //  location  : <file string>,
        //  createdAt : <date>
        //}
        //all the ids that are in progress of getting downloaded. Looking at this will stop multiple requests
        //for the same id while it is in progress. Though we need some way to trigger it.
        property var inProgressIds : ({})
        signal finishedProcessingId(bool success, string id, string fileLocation);

        property var map : ({ __fgen : 0, __count : 0 })    //the fGen is used to save files.



        function cacheId(id) { return cacheLocation + "/" + id; }   //convenience function!
        function mapGet(id)  { //resolves mapEntry at <cacheLocation>/<id> or false if it doesnt exist.
            return Promises.promise(function(resolve,reject) {
                id = cacheId(id);
                var entry = logic.map[id];
                return entry ? resolve(entry) : resolve(false);
            })
        }
        function saveMap()   { //saves logic.map to <cacheLocation>/fileCache.json
            return Promises.promise(function(resolve,reject) {
                var location = cacheLocation + "/fileCache.json";
                file.writeFile(cacheLocation, "fileCache.json", JSON.stringify(logic.map,null,2));
                resolve();
            })
        }
        function loadMap()   { //loads <cacheLocation>/fileCache.json into logic.map or { __fgen : 0, __count : 0 } if empty,no file or JSON.unparasable
            return Promises.promise(function(resolve,reject) {
                var location = cacheLocation + "/fileCache.json";
                var txt = file.readFile(location);
                var empty = { __fgen : 0, __count : 0 }
                if(!txt) {
                    logic.map = empty;
                    return resolve(empty);
                }
                try {
                    var map = JSON.parse(txt);
                    logic.map = map;
                    return resolve(map);
                }catch(e) {
                    logic.map = empty;
                    return resolve(empty);
                }
            })
        }
        function downloadPromise(id) { //downloads to <cacheLocation>/<map.__fgen++> , creates <cacheLocation>/<id> entry in map and saves it.
            return Promises.promise(function(resolve,reject) {
                fnUrlGetter(id).then(function(url) {
                    if(!url)
                        return reject();

                    //this makes it so the downloader's QHash map or urls never collides.
                    //even if we are requesting the same url over and over
                    url               = makeUrlUnique(url);
                    var cid           = cacheId(id);
                    var existingEntry = map[cid];
                    var fname         = existingEntry ? existingEntry.location : cacheLocation + "/" + (map.__fgen++)

                    var fnDownloadFinished, fnDownloadFailed

                    fnDownloadFinished = function(sigUrl,fileName,bytesReceived,bytesTotal) {
                        if(fileName !== fname)
                            return;

                        map[cid] = { createdAt : (new Date()).toISOString(), location  : fname }
                        if(!existingEntry){  //if this thing isn't present. then increment the count!
                            map.__count++;
                        }


                        downloader.downloadFailed.disconnect(fnDownloadFailed);
                        downloader.downloadSaved.disconnect(fnDownloadFinished);

                        //make sure , we haven't exceeded our fileLimit. Then save the map. Then resolve!
                        logic.enforceFileLimit().then(logic.saveMap).then(function() {
                            var location = getLocation(id)
                            logic.finishedProcessingId(true,id,location);
                            resolve(location);
                        }).catch(reject);

                    }
                    fnDownloadFailed = function(sigUrl,fileName,bytesReceived,bytesTotal,reason) {
                        if(fileName !== fname)
                            return;

                        var idx = reason.indexOf("http")
                        Functions.error("Download", id, "failed:", reason.slice(0,idx));
                        downloader.downloadFailed.disconnect(fnDownloadFailed);
                        downloader.downloadSaved.disconnect(fnDownloadFinished);

                        logic.finishedProcessingId(false,id,"");
                        logic.inProgressIds[id] = false;

                        return reject(reason);
                    }

                    downloader.downloadFailed.connect(fnDownloadFailed);
                    downloader.downloadSaved.connect(fnDownloadFinished);
                    downloader.download(url,fname);

                }).catch(reject);
            })
        }
        function deleteEntry(id, dontSave) { //deletes <cacheLocation>/<id> file and removes it from map. Saves if dontSave is not true.
            return Promises.promise(function(resolve, reject) {
                var mapEntry = logic.map[id];
                if(!mapEntry) {
                    Functions.log("cannot delete", id , "cause it doesnt exist");
                    return resolve(false);
                }

                file.deleteFile(mapEntry.location);
                delete map[id];
                map.__count--;

                if(dontSave)
                    return resolve(true);
                return saveMap().then(resolve).catch(reject);
            })
        }
        function clearMap() { //clears in map & deletes all the files. Reinitializes map to { __fgen : 0, __count : 0 }
            return Promises.promise(function(resolve,reject) {
                var delPromises = [];
                Lodash.each(logic.map, function(v,k) {
                    if(k === "__fgen" || k === "__count")
                        return;

                    delPromises.push(deleteEntry(k , true ))
                })

                Promises.all(delPromises).then(function() {
                    logic.map = { __fgen : 0, __count : 0 };
                    return saveMap().then(resolve).catch(reject);
                }).catch(reject)
            })
        }

        //Enforces enforce_fileLimit variable. Will try to delete enforce_removeNumFiles if provided.
        //Otherwise, it will delete however many entries are over the limit. Deletes oldest entries first.
        //Uses enforceInProgress bool as a mutex.
        property bool enforceInProgress: false;
        function enforceFileLimit() {
            return Promises.promise(function(resolve,reject){
                if(enforce_fileLimit <= 0 || map.__count < enforce_fileLimit || enforceInProgress)
                    return resolve();
                enforceInProgress = true;

                function getEntriesToDelete(numToDelete) {
                    var r = Lodash.reduce(map,function(a,v,k) {
                        a.push({  id        : k,
                                  createdAt : v.createdAt,
                                  location  : v.location
                               })
                        return a;
                    },[])

                    r.sort(function(a,b) {
                        var am = Moment.create(a.createdAt);
                        var bm = Moment.create(b.createdAt);
                        return am.diff(bm);
                    })

                    return r.slice(0,Math.min(numToDelete, r.length));
                }

                var numToDelete     = Math.max(enforce_removeNumFiles , map.__count - enforce_fileLimit);
                var entriesToDelete = getEntriesToDelete(numToDelete)


                var delPromises     = [];
                Lodash.each(entriesToDelete, function(v) { delPromises.push(deleteEntry(v.id)); })
                Promises.all(delPromises).then(resolve).catch(reject).finally(function() { enforceInProgress = false; });
            })
        }

        //HELPERS
        //Makes every url request unique by adding a timestamp to it. This makes it so there are no
        //collisions in the fileDownloader's hashmap.
        function makeUrlUnique(url) {
            var urlInfo = Functions.string.getUrlInfo(url,true);
            var t = new Date().getTime();
            if(!urlInfo.params) {
                url += "?__downloaderid=" + t;
            }
            else
                url += "&__downloaderid=" + t;
            return url;
        }

        //Returns the location of <entry> or <entryId> . Adds <createdAt> timestamp to the fileUrl
        //to tell Qt that it must allocate new memory. This is useful when a file is re-downloaded
        //because fnIsOutdated promise returned true;
        function getLocation(entryOrId) {
            var entry = typeof entryOrId === 'object' ? entryOrId : map[cacheId(entryOrId)];
            if(!entry || !entry.location || !entry.createdAt)
                return "";
//            Functions.log(entry.location + "?t=" + new Date(entry.createdAt).getTime());
            return entry.location + "?t=" + new Date(entry.createdAt).getTime();
        }


        property var downloadLog : ({ count : 0 })
        function writeDownloadLog(id,success,next) {
            if(!downloadLog[id])
                downloadLog[id] = { count : 1, fails : success ? 0 : 1 }
            else {
                downloadLog[id].count++
                if(!success)
                    downloadLog[id].fails++;
            }
            downloadLog.count++;
            file.writeFile(cacheLocation,"downloadLog.json",JSON.stringify(downloadLog,null,2));
        }
    }




    ZPaths          { id : paths      }
    ZFileDownloader { id : downloader }
    ZFileOperations {
        id : file
        function makeSureLocationExits(location) {
            return Promises.promise(function(resolve,reject) {
                var arr = location.split("/");
                //create all the folders to the cacheLocation if it don't exist!
                for(var i = 1; i < arr.length; ++i){
                    var dir = arr.slice(0, i+1).join('/');
                    createDirIfDoesNotExist(dir);
                }
                resolve();
            })
        }
    }

}
