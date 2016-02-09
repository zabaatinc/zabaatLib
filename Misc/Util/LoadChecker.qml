import QtQuick 2.4

// USAGE:    add to SIBLING objects   ----->          property bool waitForLoad:true
//     (optional friendly name for debugging)       property string loadName:  "componentName"
//
//     define the loaderName property below so it will tell you it's name when it completes
Item {
    signal allReady()

    property string loaderName : "*** :(  ***"

    property string debugTitle: "LOADER " + loaderName + ": "
    property alias checkInterval: loadCheck.interval

    property int totalObjects : loadContainer.count
    property int readyObjects : 0
    property int scans : 1     //set this to negative if you want rescan until ready
    property bool overrideWaitForLoad : false
    property var scanObject : null

    ListModel{//container that stores the items that are waiting to be loaded
        id:loadContainer
    }

    Timer
    {
        id: loadCheck
        interval: 100
        running: false
        repeat: true

        onTriggered:
        {
            if(scans < 0 || scans > 0)
            {
                siblingLoad()
                scans--
            }

            siblingCheck()
        }
    }

    Component.onCompleted: loadCheck.start()

    function siblingLoad()
    {  //scan all sibling in parent QML that are compatible with checker and shove refs to them in list model

        if(!scanObject)
            scanObject = parent

        var tempName = "noname"
        for (var i=0;i<scanObject.children.length;i++)
        {
//            console.log('waitForLoad'     , typeof scanObject.children[i].data[0].waitForLoad)
//            console.log('Name'     , scanObject.children[i].data[0].loadName)
//            console.log('data[0].waitForLoad', typeof scanObject.children[i].data.waitForLoad)

            if (!overrideWaitForLoad && scanObject.children[i].waitForLoad)
            {
                if (scanObject.children[i].loadName) tempName = scanObject.children[i].loadName

                if(!objectExists(scanObject.children[i]))
                    loadContainer.append({obj:scanObject.children[i],name:tempName,hasLoaded:false})
            }
            else if(scanObject.children[i].hasOwnProperty('status'))
            {
                if (scanObject.children[i].loadName) tempName = scanObject.children[i].loadName

                if(!objectExists(scanObject.children[i]))
                    loadContainer.append({obj:scanObject.children[i],name:tempName,hasLoaded:false})
            }

        }
//        console.log(debugTitle,"found", loadContainer.count+"/"+scanObject.children.length,"compatible objects")

    }

    function objectExists(obj)
    {
        for(var i = 0; i < loadContainer.count; i++)
        {
            var item = loadContainer.get(i).obj
            if(obj === item)
                return true
        }
        return false
    }


    function siblingCheck()
    {
        //scan all stored siblings to see if they are in a ready state, each time we find one ready store in totalReady. at end eval if all are ready and if so send signal, if not start timer again
        for (var i=0;i<loadContainer.count;i++)
        {
            var ref = loadContainer.get(i)
            var refObj = ref.obj

            if (refObj.status == Component.Ready && !ref.hasLoaded)
            {
                ref.hasLoaded = true  //used to store so we don't iterate our ready objects
//                console.log(debugTitle, refObj.loadName,"READY")
                readyObjects++
            }
            else if (refObj.status == Component.Error) console.log(debugTitle,"error in component",refObj.loadName,refObj.errorString())
            else if (refObj.status == Component.Ready && ref.hasLoaded) {} //hurp
            else
            {
//                console.log(debugTitle, refObj.loadName,"not ready. ", (refObj.progress*100).toFixed(0),"%" );
                ref.hasLoaded = false;
            }
        }

        if (readyObjects == loadContainer.count )
        {
            if(loadContainer.count != 0 && scans < 0)
            {
//                console.log(debugTitle," COMPLETE");
                allReady();
                loadCheck.stop()
            }
            else if(scans == 0)
            {
//                console.log(debugTitle," COMPLETE");
                allReady();
                loadCheck.stop()
            }
        }
        else
        {
//            console.log(debugTitle,readyObjects,"/",loadContainer.count,"objects ready");
        }
    }

}

