import QtQuick 2.5
import "Lodash"
Item {
    property var queryObj
    onQueryObjChanged: refresh();

    function refresh() {
        lv.model = null

        if(!queryObj || typeof queryObj !== 'object')
            return;

        var a;
        if(_.isArray(queryObj)){
            a = _.cloneDeep(queryObj);
        }
        else {
            a = []
            _.each(queryObj, function(v,k){
                var obj = {}
                obj[k] = v;
                a.push(obj)
            })
        }
//        console.log("This is our object!", JSON.stringify(a,null,2));

        lv.model = a;
    }

    ListView {
        id : lv
        anchors.fill: parent
        delegate: QueryLine {
            width : lv.width
            height: lv.height * 0.1
            obj   : modelData
        }
    }


}
