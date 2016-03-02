import QtQuick 2.5
import Zabaat.Utility 1.0 as U  //replace later
Item {
    id: zSubModel
    property var  sourceModel : rootObject.sourceModel
    property var  queryTerm   : rootObject.queryTerm
    property alias model      : rootObject

    onSourceModelChanged : queryHandler.sendMessage({type:"sourceModel", data:sourceModel })
    onQueryTermChanged   : queryHandler.sendMessage({type:"queryTerm", data:queryTerm     })

    ListModel {
        id: rootObject
        dynamicRoles: true
    }

    WorkerScript{
        id : queryHandler
        source : "queryHandler.js"
        Component.onCompleted: {
            queryHandler.sendMessage({type:"model", data:rootObject  })
            queryHandler.sendMessage({type:"sourceModel", data:sourceModel })
            queryHandler.sendMessage({type:"queryTerm", data:queryTerm     })
        }
    }

    Connections {
        target : sourceModel ? sourceModel : null
        onRowsInserted   : {
            var start = arguments[1]
            var end   = arguments[2]
            var count = end - start + 1

            queryHandler.sendMessage({type:"rowsInserted", data:{start:start,end:end,count:count,sourceModel:sourceModel} })
        }
        onRowsMoved      : {
            var start           = arguments[1]
            var end             = arguments[2]
            var count           = end - start +1
            var destinationEnd  = arguments[4] -1 //this is where the
            var startEnd        = destinationEnd - (end-start);

            queryHandler.sendMessage({type:"rowsMoved", data:{start:start,end:end,startEnd:startEnd,destinationEnd:destinationEnd,count:count}} )
        }
        onRowsRemoved    : {
            var start = arguments[1]
            var end   = arguments[2]
            var count = end - start + 1 //this is the amount of things that need it's indexes updated
            queryHandler.sendMessage({type:"rowsRemoved", data:{start:start,end:end,count:count} })
        }
        onDataChanged    : {
            var idx         = arguments[1].row
            queryHandler.sendMessage({type:"dataChanged", data:{idx:idx}})
        }
        onModelReset: queryHandler.sendMessage({type:"modelReset", data:{}})
    }




}


