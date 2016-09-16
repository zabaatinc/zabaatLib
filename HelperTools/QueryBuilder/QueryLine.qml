import QtQuick 2.5
import "../ControllerView"
import "Lodash"
import "QueryLineComponents"
Item {
    property var obj
    property int depth :0

    onObjChanged : {
        instantiatedItems.clear();
        if(_.isObject(obj)) {
            var qe = logic.getElements(obj);
            if(qe.op) {

            }
            else {  //we know we have a key
                loader.doLoad(simpleEquality, {key : qe.key, val : qe.expr })
            }
        }
        else {

        }
    }

    QtObject {
        id : logic
        //returns the key, operator and value
        //there's always just supposed to be one elment in the obj!!
// obj1 ex:        {
//           "$or": [
//             {
//               "age": {
//                 "$lt": 30
//               }
//             },
//             {
//               "type": 1
//             }
//           ]
//         }
//obj2 ex:       {
//           "status": "A"
//         }

        function getElements(obj){
            for(var k in obj){
                var v = obj[k]
                var op  = getOperator(obj);
                return op ? { op : op, expr : v } :
                            { key : k, expr : v }
            }
        }


        function getOperator(obj){
            if(typeof obj !== 'object')
                return ;

            for(var k in obj) {
                if(k.charAt(0) === "$")
                    return k;
            }
        }

        function isSimple(obj){
            return !_.isObject(obj) && !_.isArray(obj) && !Qt.isQtObject(obj);
        }


    }


    Item {
        id : instantiatedItems
        function clear(){
            _.each(children, function(v,k){
                v.parent = null;
                v.destroy();
            })
            children = [];
        }
    }

    Loader {
        id : loader
        anchors.fill: parent
        property var args
        function doLoad(obj, args) {
            this.args = args;
            if(typeof obj === 'string'){
                loader.source = obj;
            }
            else{
                loader.sourceComponent = obj;
            }
        }
        onLoaded : {
            if(!args)
                return;

            _.each(args,function(v,k){
                if(item.hasOwnProperty(k)) {
                    item[k] =v;
                }
            })
            args = undefined;
        }
    }

    Component {
        id : simpleEquality
        SimpleEquality{ }
    }
}
