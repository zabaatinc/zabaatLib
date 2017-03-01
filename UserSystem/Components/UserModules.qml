import QtQuick 2.5
import Qt.labs.folderlistmodel 2.1
import Zabaat.Base 1.0
QtObject {
    id : rootObject
    function getUserModuleDir() { return _priv.dir;  }
    function setUserModuleDir(dir) {
        dir = ":/src"
        Functions.log("OH IS THIS THE DIR IM LOOKING FER?" , dir);
        return Promises.timeoutPromise(1000, function(resolve,reject) {
            if(!dir)
                reject("no dir");

            if(typeof dir !== 'string')
                reject("dir is not a string:" , dir);

            var userTabs = {}
            Functions.connectUntilTruthy(flm.countChanged, function() {
                for(var i = 0; i < flm.count; ++i) {
                    var fileURL      = flm.get(i, 'fileURL').toString();
                    var fileBaseName = flm.get(i, 'fileBaseName');
                    if(fileURL.length <= dir || fileURL.indexOf(dir) !== 0)
                        return false;

                    userTabs[fileBaseName] = fileURL;
                }

                resolve(userTabs);
                Functions.log("RESOLVE setUserDirectory" , JSON.stringify(userTabs,null,2))
                _priv.dir     = dir; //so getUserDirectory() works
                _priv.userTabs = userTabs;
                return true;
            })

            flm.folder = dir;
        })
    }

    readonly property alias modules : _priv.userTabs

    property QtObject _priv : QtObject {
        id : _priv
        property string dir          : Qt.resolvedUrl(".")
        Component.onCompleted: Functions.log("@@@@@@@@@@@@@@", dir);
        onDirChanged: Functions.log("@@@@@@@@@@@@@@", dir);

        property var userTabs        : ({})
        property FolderListModel flm : FolderListModel{
            id : flm
//            nameFilters: ["*.qml"]
            showDirs: false
            showDotAndDotDot: false
            showHidden: false
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
