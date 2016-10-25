import QtQuick 2.5
import Zabaat.Base 1.0
//Able to load qmlFiles , images as well as components.
//If src is a string, it will determine whether to load an image
//or a qml file. If it's a component, it will obviously load the component.
//Will attach all signals of the loaded item to the "event(name,args)" signal.
//Name will be the name of the signal the loaded item has emitted and args will be
//the array of params that the signal sent out.
Item {
    id : rootObject
    property alias source : rootObject.src
    property var src
    property alias item : loader.item
    onSrcChanged : {
        loader.source = "";
        loader.sourceComponent = null;

        if(typeof src === 'string') {
            var ext = Lodash.last(src.split('.'));
            if(ext.toLowerCase() === 'qml')
                loader.source = src;
            else {  //assume it's an image and try to load that!
                loader.loadImg(src);
            }
        }
        else {
            loader.sourceComponent = src;
        }
    }
    signal event(string name, var args);
    signal loaded(var item);

    function loadWithArgs(src, args) {
        loader.args = args;
        rootObject.src = src;
    }

    function loadArgsOnNext(args){
        loader.args = args;
    }

    Loader {
        id : loader
        anchors.fill: parent
        onLoaded : {
            //load args
            Lodash.each(args,function(v,k) {
                if(item.hasOwnProperty(k)){
                    try {
                        item[k] = v;
                    } catch(e){}
                }
            })
            args = null;

            //connect sigs
            Lodash.each(item, function(v,k){
                //skip all properties that are not functions
                if(typeof v !== 'function')
                    return;

                //try to connect to functions, only signals will succeed!
                try {
                    var f = function() {
                        if(!Array || !rootObject || !rootObject.event)
                            return;
                        var args = Array.prototype.slice.call(arguments);
                        event(k,args);
                    }
                    v.connect(f)
                }
                catch(e){
//                    console.log("Unable to connect to", k, "Cause it ain't a signal")
                }
            })

            rootObject.loaded(loader.item);
        }

        property var args : ({})
        function loadImg(src) {
            args = { source : src };
            sourceComponent = imgComponent;
        }

        Component {
            id : imgComponent
            Image {
                id: imgInstance
                fillMode: Image.PreserveAspectFit
            }
        }
    }
}
