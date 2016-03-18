import QtQuick 2.5
import Zabaat.Utility 1.0 as U  //replace later
import "ZSubModel.js" as QueryHandler

ListModel {
    id: rootObject
    property var  sourceModel : rootObject.sourceModel
    property var  queryTerm   : null
    property bool debug       : false

    property var compareFunction : null
    property var sortRoles    : []

//    dynamicRoles : true

    onSourceModelChanged : { QueryHandler.sendMessage({type:"sourceModel", data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm},sort:{roles:sortRoles,fn:compareFunction} }, debug)
//
    }
    onQueryTermChanged   : { QueryHandler.sendMessage({type:"queryTerm"  , data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm},sort:{roles:sortRoles,fn:compareFunction} }, debug)
//
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
//
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
//
        }
        onRowsRemoved    : {
            var start = arguments[1]
            var end   = arguments[2]
            var count = end - start + 1 //this is the amount of things that need it's indexes updated
            QueryHandler.sendMessage({type:"rowsRemoved", data:{start:start,end:end,count:count,
                                                                sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm},
                                                                sort:{roles:sortRoles,fn:compareFunction} } , debug)
//
        }
        onDataChanged    : {
            var idx         = arguments[1].row
            QueryHandler.sendMessage({type:"dataChanged", data:{idx:idx, sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm},
                                                          sort:{roles:sortRoles,fn:compareFunction} },debug)
//
        }
        onModelReset     :  {
            QueryHandler.sendMessage({type:"modelReset", data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm},
                                                         sort:{roles:sortRoles,fn:compareFunction}},debug)


//
        }
    }




}


