import QtQuick 2.5
import Zabaat.Utility 1.1
CSubModel {
    id : rootObject
    property var  filterFunc: null
    property var  sortFunc  : null
    property bool sortFuncAcceptsIndices : false



    onSourceModelChanged: logic.filterAll()
    onFilterFuncChanged : logic.filterAll()
    onSortFuncChanged   : if(sortFunc)  logic.doSort();
    onSource_rowsMoved   : if(sortFunc) logic.doSort();
    onSource_rowsRemoved : if(sortFunc) logic.doSort();
    onSource_rowsInserted: logic.handleRowsInserted(start,end,count);
    onSource_dataChanged : logic.handleDataChanged(idx, refIdx, roles);
    onSource_modelReset  : logic.filterAll();


    property QtObject __logic : QtObject {
        id : logic

        function handleRowsInserted(start,end,count){
            //first let's adjust the indices we already have cause they have moved!
            for(var i = 0; i < rootObject.count; ++i) {
                var r = indexList[i];
                if(r >= start)
                    indexList[i] += count;
            }

            //now let's see if the new things match our filterFunction and add them if necessary
            for(i = start; i <= end ; ++i){
                var newItem = sourceModel.get(i);
                var acceptable = filterFunc ? filterFunc(newItem) : true
                if(acceptable){
                    addToIndexList(i);
                }
            }


            if(sortFunc)
                doSort();
        }
        function handleDataChanged(idx, refIdx, roles) {

            //Idx is the actual index of the item (in the real model)
            //refIdx is the index of the element that points to that

            //if refIdx === -1 && is acceptable, add this item from indexList (list of references)
            //if refIdx !== -1 && is unacceptable, remove this item from indexList (list of references)
            var changedItem = sourceModel.get(idx)
            var acceptable = filterFunc ? filterFunc(changedItem) : true

            if(refIdx !== -1) {
                if(!acceptable){    //remove if this new data makes this thing unacceptable!!
                    removeFromIndexList(idx);
                }
                else {
                    //emit data changed!!
                    //gross way!
                    //var src = sourceModel;
                    //sourceModel= null;
                    //sourceModel = src;

//                    console.log("EMITING DATA CHANGED", refIdx, roles)
                    emitDataChanged(refIdx,refIdx, roles)
                }
            }
            else if(acceptable){
                addToIndexList(idx);
            }
        }
        function filterAll(){
            console.time("Filter")

            var arr = []
            if(sourceModel) {
                for(var i =0; i < sourceModel.count; ++i) {
                    var item = sourceModel.get(i)
                    var acceptable = filterFunc ? filterFunc(item) : true
                    if(acceptable)
                        arr.push(i);
                }
            }
//            console.log('new indexList', arr)
            indexList = arr;
            console.timeEnd("Filter")

            if(sortFunc)
                doSort()


//            console.log("ASSIGNED INDEX LIST")
        }
        function doSort(){
//            console.log("DOING SORT")
            console.time("sort Time")
            if(sortFuncAcceptsIndices){
                indexList.sort(sortFunc)
            }
            else {
                indexList.sort(function(a,b){
                    return sortFunc(sourceModel.get(a), sourceModel.get(b))
                })
            }
            console.timeEnd("sort Time")
        }

    }


}
