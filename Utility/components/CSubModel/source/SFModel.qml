import QtQuick 2.5
import Wolf 1.0
SubModel {
    id : rootObject
    property var filterFunc: function(a) {
                                return true;
                             }
    property var sortFunc: null

    onSourceModelChanged: logic.filterAll()
    onFilterFuncChanged : logic.filterAll()

    onSource_rowsInserted: logic.handleRowsInserted(start,end,count);
    onSource_dataChanged: logic.handleDataChanged(idx, refIdx);
    onSource_modelReset: logic.filterAll();

    property QtObject __logic : QtObject {
        id : logic

        function handleRowsInserted(start,end,count){

        }

        function handleDataChanged(idx, refIdx) {

            //first lets see does this changed item still
            if(refIdx === -1){

            }

            for(var i = 0; i < rootModel.count; ++i){
                var item = rootModel.get(i)
                if(idx === item.__relatedIndex){
    //                debugMsg("remove @",i, JSON.stringify(changedItem,null,2))
    //                debugMsg("removed @",i)
                    rootModel.remove(i)
                    break;
                }
            }

            //if it matches, now add it.
            var changedItem = sourceModel.get(idx)
            var matchItem = filterFunc ? filterFunc(changedItem) : logic.match(changedItem)
            if(matchItem){
                rootModel.insert(i,changedItem)
                logic.setRelatedIdx(idx,i)
    //            debugMsg("insert @",i,"with relative idx", idx)
            }


        }

        function filterAll(){
            var arr = []
            if(sourceModel && filterFunc) {
                for(var i =0; i < sourceModel.count; ++i) {
                    var item = sourceModel.get(i)
                    if(filterFunc(item))
                        arr.push(i);
                }
            }
            console.log('new indexList', arr)
            indexList = arr;
        }

    }


}
