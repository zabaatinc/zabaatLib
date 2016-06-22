import QtQuick 2.5
import Zabaat.Utility 1.0 as U  //replace later
import "ZSubModel.js" as QueryHandler

ListModel {
    id: rootObject
    property var  sourceModel : rootObject.sourceModel
    property var  queryTerm   : null
    property bool debug       : true

    property var filterFunction  : null //uses queryTerm is this is null to filter!!
    property var compareFunction : null
    property var sortRoles       : []



//    dynamicRoles : true

    property Timer initTimer : Timer {
        id       : initTimer
        interval : 10
        repeat   : false
        running  : false
        onTriggered : {
//            console.time("begin")
            QueryHandler.sendMessage({type:"begin"  , data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm,filterFunction:filterFunction},sort:{roles:sortRoles,fn:compareFunction} }, debug)
//            console.timeEnd("begin")
        }
    }

    onFilterFunctionChanged: {
        if(!initTimer.running) {
//            console.log("FILTER FUNC CHANGED")
//            console.time(rootObject + "filterFunc" )
            QueryHandler.sendMessage({type:"queryTerm", data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm,filterFunction:filterFunction},sort:{roles:sortRoles,fn:compareFunction} }, debug)
//            console.timeEnd(rootObject + "filterFunc")
        }
    }


    onSourceModelChanged : {
        if(!initTimer.running) {
//            console.time("sourceModel")
            QueryHandler.sendMessage({type:"sourceModel", data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm,filterFunction:filterFunction},sort:{roles:sortRoles,fn:compareFunction} }, debug)
//            console.timeEnd("sourceModel")
        }
    }
    onQueryTermChanged   : {
        if(!initTimer.running) {
//            console.time(rootObject + "queryTerm")
            QueryHandler.sendMessage({type:"queryTerm"  , data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm,filterFunction:filterFunction},sort:{roles:sortRoles,fn:compareFunction} }, debug)
//            console.timeEnd(rootObject + "queryTerm")
        }
    }



    property Connections connections : Connections {
        target : sourceModel ? sourceModel : null
        onRowsInserted   : {
            if(initTimer.running)
                return

            var start = arguments[1]
            var end   = arguments[2]
            var count = end - start + 1

//            console.log("QML::",JSON.stringify(sourceModel.get(start),null,2) , sourceModel.count)
//            console.log("-------------------------------------------------------")
//            delayTimer.begin({type:"rowsInserted", data:{start:start,end:end,count:count,sourceModel:sourceModel} })
            QueryHandler.sendMessage({type:"rowsInserted", data:{start:start,end:end,count:count,
                                                           sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm,filterFunction:filterFunction},
                                                           sort:{roles:sortRoles,fn:compareFunction} }, debug)
//
        }
        onRowsMoved      : {
            if(initTimer.running)
                return
//            console.log("onRowsMoved::arguments", arguments[1], arguments[2],  arguments[4])

            var arg4 = arguments[4] //this is weird behavior in qt. it apparently adds
                                    //the count if stuff is being moved down.

            var start           = arguments[1]
            var end             = arguments[2]
            var count           = end - start +1

            var startEnd, destinationEnd
            if(arg4 < start){
                startEnd        = arg4
            }
            else if(arg4 > end){
                startEnd = arg4 - count
            }

            destinationEnd  = startEnd + count - 1



//            var destinationEnd  = arguments[4] -1 //this is where the
  //          var startEnd        = destinationEnd - (end-start);

            QueryHandler.sendMessage({type:"rowsMoved", data:{start:start,end:end,startEnd:startEnd,destinationEnd:destinationEnd,count:count,
                                                              sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm,filterFunction:filterFunction},
                                                              sort:{roles:sortRoles,fn:compareFunction}},debug )
//
        }
        onRowsRemoved    : {
            if(initTimer.running)
                return

            var start = arguments[1]
            var end   = arguments[2]
            var count = end - start + 1 //this is the amount of things that need it's indexes updated
            QueryHandler.sendMessage({type:"rowsRemoved", data:{start:start,end:end,count:count,
                                                                sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm,filterFunction:filterFunction},
                                                                sort:{roles:sortRoles,fn:compareFunction} } , debug)
//
        }
        onDataChanged    : {
            if(initTimer.running)
                return

            var idx         = arguments[1].row
            QueryHandler.sendMessage({type:"dataChanged", data:{idx:idx, sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm,filterFunction:filterFunction},
                                                          sort:{roles:sortRoles,fn:compareFunction} },debug)
//
        }
        onModelReset     :  {
            if(initTimer.running)
                return

            QueryHandler.sendMessage({type:"modelReset", data:{sourceModel:sourceModel,model:rootObject,queryTerm:queryTerm,filterFunction:filterFunction},
                                                         sort:{roles:sortRoles,fn:compareFunction}},debug)

        }
    }




}


