import QtQuick 2.5
import Zabaat.Base 1.0
//allows us to load components defined by ComponentInfo and also
//change their values that is abstracted away in the value property :)
Item {
    id : rootObject
    property var src    //must be ComponentInfo
    property var value
    property var label
    onLabelChanged: {
        var labelProperty = src && src.labelProperty ? src.labelProperty : "label"
        if(fl.item) {
            try {
                fl.item[labelProperty] = label;
            }catch(e) {}
        }
    }
    onValueChanged : {
        var valProperty = src && src.valueProperty  ? src.valueProperty : "text"
        if(fl.item){
            try {
                fl.item[valProperty] = value;
            }catch(e) {}
        }
    }
    onSrcChanged :  {
        if(!src)
            return fl.src = null;

        var notComponentInfoObj = typeof src === 'string' || src.toString().toLowerCase().indexOf("qqmlcomponent") !== -1
        if(notComponentInfoObj)
            return fl.src = src;

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
            var valProperty   = rootObject.src && rootObject.src.valueProperty ? rootObject.src.valueProperty : "text"
            var labelProperty = rootObject.src && rootObject.src.labelProperty ? rootObject.src.labelProperty : "label"

            try {
                var sigName = valProperty+"Changed"
                if(typeof item[sigName] === 'function') {
                    item[sigName].connect(function() {
                        if(rootObject.value === item[valProperty])
                            return;

                        rootObject.value = item[valProperty];
//                            console.log("rootObject.val", rootObject.value )
                    })
                }
                else {
//                    console.log("no", sigName, 'found on', item)
                }

                //assign val
                item[valProperty] = rootObject.value;

            }catch(e){}

            try {
                sigName = labelProperty + "Changed";
                if(typeof item[sigName] === 'function') {
                    item[sigName].connect(function() {
                        if(rootObject.label === item[labelProperty])
                            return;

                        rootObject.label = item[labelProperty];
                    })
                }
                else {
//                    console.log("no", sigName, "found on", item);
                }

                //assign label
                if(item.hasOwnProperty(labelProperty))
                    item[labelProperty] = rootObject.label;

            }catch(e){}



            rootObject.loaded(item);
        }



        function capFirst(str){
            return str.charAt(0).toUpperCase() + str.slice(1);
        }
    }

}
