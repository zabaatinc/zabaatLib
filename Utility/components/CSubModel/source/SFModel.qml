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

    property QtObject __logic : QtObject {
        id : logic

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
