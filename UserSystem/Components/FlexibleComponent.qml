import QtQuick 2.5
import "../Lodash"
//allows us to load components defined by ComponentInfo and also
//change their values that is abstracted away in the value property :)
Item {
    id : rootObject
    property var src    //must be ComponentInfo
    property var value
    onValueChanged : if(fl.item &&  src && src.valueProperty){
                        try {
                            fl.item[src.valueProperty] = value;
                        }catch(e) {}
                     }
    onSrcChanged :  {
        if(!src)
            return fl.src = null;
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
                    item[rootObject.src.valueProperty] = value;
                }catch(e){}
            }
            rootObject.loaded(item);
        }
    }

}
