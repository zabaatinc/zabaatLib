import QtQuick 2.5
import Qt.labs.folderlistmodel 2.1
import Zabaat.Base 1.0
QtObject {
    id : rootObject
    function getUserModuleDir() { return _priv.dir;  }
    function setUserModuleDir(dir) {
        return Promises.timeoutPromise(2000, function(resolve,reject) {
            if(!dir)
                reject("no dir");

            if(typeof dir !== 'string')
                reject("dir is not a string:" , dir);

            var cleanDir = _priv.cleanPath(dir);
            var userTabs = {}
            Functions.connectUntilTruthy(flm.countChanged, function() {
                for(var i = 0; i < flm.count; ++i) {
                    var fileURL      = flm.get(i, 'fileURL').toString();
                    var fileBaseName = flm.get(i, 'fileBaseName');

                    //for our comparisons, we need to clean the paths first
                    if(_priv.cleanPath(fileURL).indexOf(cleanDir) !== 0)
                        return false;

                    userTabs[fileBaseName] = _priv.goodUrl(fileURL,dir);
                }

                resolve(userTabs);
                _priv.dir      = dir; //so getUserDirectory() works
                _priv.userTabs = userTabs;
                return true;
            })

            flm.folder = dir;
        })
    }

    readonly property alias moduleObj : _priv.userTabs
    property QtObject _priv : QtObject {
        id : _priv
        property string dir          : Qt.resolvedUrl(".")
        property var userTabs        : ({})
        property FolderListModel flm : FolderListModel{
            id : flm
            nameFilters: ["*.qml"]
            showDirs: false
            showDotAndDotDot: false
            showHidden: false
        }

        function cleanPath(str) {
            var idx = str.indexOf(":/")
            if(idx !== -1)
                return str.substring(idx,str.length);
            return str;
        }

        function goodUrl(str, original) {
            var thinger = "file:///"
            var idx = original.indexOf(":/")
            if(idx !== -1)
                thinger = original.substring(0,idx);

            return thinger + cleanPath(str)
        }


    }

//    Component.onCompleted:  {
//        var someDir = Qt.resolvedUrl(".")
//        console.log("look for qmls in", someDir);
//        setUserDirectory(someDir).then(function(res) {
//            console.log("HERES MY RESULT", JSON.stringify(res,null,2))
//        }).catch(function(err) {
//            console.log("OH NOES! ERROR", err);
//        })
//   }


}
