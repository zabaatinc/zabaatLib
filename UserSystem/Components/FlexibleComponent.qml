import QtQuick 2.5
import "../Lodash"
//allows us to load components defined by ComponentInfo and also
//change their values that is abstracted away in the value property :)
Item {
    id : rootObject
    property var src    //must be ComponentInfo
    property var value
    property var label
    onLabelChanged: if(fl.item && src && src.labelProperty) {
                        try {
                            fl.item[src.labelProperty] = label;
                        }catch(e) {}
                    }

    onValueChanged : if(fl.item &&  src && src.valueProperty){
                        try {
                            fl.item[src.valueProperty] = value;
                        }catch(e) {}
                     }
    onSrcChanged :  {
        if(!src)
            return fl.src = null;
        src.componentChanged.connect(function() {
            if(fl)
                fl.src = src ? src.component : null;
        })
        fl.src = src.component;
    }

    signal event(string name, var args);
    signal loaded(var item);
    FlexibleLoader {
        id : fl
        anchors.fill: parent
        onEvent : rootObject.event(name,args);
        onLoaded : {
            if(rootObject.src && rootObject.src.valueProperty){
                try {
                    var sigName = rootObject.src.valueProperty+"Changed"
                    if(typeof item[sigName] === 'function') {
                        item[sigName].connect(function() {
                            if(rootObject.value === item[rootObject.src.valueProperty])
                                return;

                            rootObject.value = item[rootObject.src.valueProperty];
//                            console.log("rootObject.val", rootObject.value )
                        })
                    }
                    else {
                        console.log("no", sigName, 'found on', item)
                    }

                    //assign val
                    item[rootObject.src.valueProperty] = rootObject.value;

                }catch(e){}
            }
            if(rootObject.label && rootObject.src.labelProperty)
                item[rootObject.src.labelProperty] = rootObject.label;

            rootObject.loaded(item);
        }



        function capFirst(str){
            return str.charAt(0).toUpperCase() + str.slice(1);
        }
    }

}
