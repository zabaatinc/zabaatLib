import QtQuick 2.5
import Zabaat.Utility 1.0 as U  //replace later
import "ZSubModel.js" as QueryHandler

ListModel {
    id: rootObject
    property var  sourceModel : rootObject.sourceModel
    property var  queryTerm   : rootObject.queryTerm
    property bool debug       : false
//    dynamicRoles : true

    onSourceModelChanged : QueryHandler.sendMessage({type:"sourceModel", data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm} }, debug)
    onQueryTermChanged   : QueryHandler.sendMessage({type:"queryTerm"  , data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm} }, debug)

//    property var queryQ      : []
//    property var execMsg     : null
//    function sendMessage(msg){
//        if(!queryQ)
//            queryQ = []

//        if(execMsg){
//            console.log("@@@@ Shoving cause script was busy!")
//            return queryQ.push(msg)
//        }
//        else {
//            execMsg    = msg
//            QueryHandler.sendMessage(msg)
//        }
////        sendMessage({type:"queryTerm"  , data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm} })
//    }
//    function finishedScriptTask(){  //this removes from the start of the q and executes it!
//        if(queryQ.length > 0){
//            console.log("remaining QueryQ", queryQ.length)
//            execMsg = queryQ[0]
//            queryQ.splice(0,1)  //remove the first thing
//            QueryHandler.QueryHandler.sendMessage(execMsg)
//        }
//        else {
//            execMsg = null;
//        }
////        console.log("finished",scriptBusy)
//    }


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
                                                           sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm} }, debug)
        }
        onRowsMoved      : {
            var start           = arguments[1]
            var end             = arguments[2]
            var count           = end - start +1
            var destinationEnd  = arguments[4] -1 //this is where the
            var startEnd        = destinationEnd - (end-start);

            QueryHandler.sendMessage({type:"rowsMoved", data:{start:start,end:end,startEnd:startEnd,destinationEnd:destinationEnd,count:count,
                                                              sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm}},debug )
        }
        onRowsRemoved    : {
            var start = arguments[1]
            var end   = arguments[2]
            var count = end - start + 1 //this is the amount of things that need it's indexes updated
            QueryHandler.sendMessage({type:"rowsRemoved", data:{start:start,end:end,count:count,
                                                                sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm} } , debug)
        }
        onDataChanged    : {
            var idx         = arguments[1].row
            QueryHandler.sendMessage({type:"dataChanged", data:{idx:idx, sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm}},debug)
        }
        onModelReset     : QueryHandler.sendMessage({type:"modelReset", data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm}},debug)
    }




}


