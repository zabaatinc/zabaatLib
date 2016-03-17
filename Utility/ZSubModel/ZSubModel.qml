import QtQuick 2.5
import Zabaat.Utility 1.0 as U  //replace later
import "ZSubModel.js" as QueryHandler

ListModel {
    id: rootObject
    property var  sourceModel : rootObject.sourceModel
    property var  queryTerm   : rootObject.queryTerm
    property bool debug       : false

    property var compareFunction : null
    property var sortRoles    : ["name"]

//    dynamicRoles : true

    onSourceModelChanged : { QueryHandler.sendMessage({type:"sourceModel", data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm},sort:{roles:sortRoles,fn:compareFunction} }, debug)
//        sortTimer.start()
    }
    onQueryTermChanged   : { QueryHandler.sendMessage({type:"queryTerm"  , data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm},sort:{roles:sortRoles,fn:compareFunction} }, debug)
//        sortTimer.start()
    }

    property Timer sortTimer : Timer{
        id : sortTimer
        interval : 100
        repeat : false
        running : false
        onTriggered : QueryHandler.sendMessage({type:"sort" , data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm},sort:{roles:sortRoles,fn:compareFunction} }, debug)
    }



    property Connections connections : Connections {
        target : sourceModel ? sourceModel : null
        onRowsInserted   : {
            var start = arguments[1]
            var end   = arguments[2]
            var count = end - start + 1

//            console.log("QML::",JSON.stringify(sourceModel.get(start),null,2) , sourceModel.count)
//            console.log("-------------------------------------------------------")
//            delayTimer.begin({type:"rowsInserted", data:{start:start,end:end,count:count,sourceModel:sourceModel} })
            QueryHandler.sendMessage({type:"rowsInserted", data:{start:start,end:end,count:count,
                                                           sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm},
                                                           sort:{roles:sortRoles,fn:compareFunction} }, debug)
//            sortTimer.start()
        }
        onRowsMoved      : {
            var start           = arguments[1]
            var end             = arguments[2]
            var count           = end - start +1
            var destinationEnd  = arguments[4] -1 //this is where the
            var startEnd        = destinationEnd - (end-start);

            QueryHandler.sendMessage({type:"rowsMoved", data:{start:start,end:end,startEnd:startEnd,destinationEnd:destinationEnd,count:count,
                                                              sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm},
                                                              sort:{roles:sortRoles,fn:compareFunction}},debug )
//            sortTimer.start()
        }
        onRowsRemoved    : {
            var start = arguments[1]
            var end   = arguments[2]
            var count = end - start + 1 //this is the amount of things that need it's indexes updated
            QueryHandler.sendMessage({type:"rowsRemoved", data:{start:start,end:end,count:count,
                                                                sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm},
                                                                sort:{roles:sortRoles,fn:compareFunction} } , debug)
//            sortTimer.start()
        }
        onDataChanged    : {
            var idx         = arguments[1].row
            QueryHandler.sendMessage({type:"dataChanged", data:{idx:idx, sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm},
                                                          sort:{roles:sortRoles,fn:compareFunction} },debug)
//            sortTimer.start()
        }
        onModelReset     :  {
            QueryHandler.sendMessage({type:"modelReset", data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm},
                                                         sort:{roles:sortRoles,fn:compareFunction}},debug)


//            sortTimer.start()
        }
    }




}


