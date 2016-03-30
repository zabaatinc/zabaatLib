import QtQuick 2.5
Item {
    id : rootObject
    anchors.fill: source

    property variant source             : null
    property real    dividerValue       : 1
    property alias   fragmentShaderName : logic.fragmentShaderName
    property alias   vertexShaderName   : logic.vertexShaderName
    property string  shaderDir          : "./shaders/"
    property var     chainPtr           : logic.effectObj

    QtObject {
        id : logic
        property string  fragmentShaderName
        property string  vertexShaderName
        property string fragSh : ""
        property string vertSh : ""
        property var effectObj : null
        property string fragmentShaderCommon: "
            #ifdef GL_ES
                precision mediump float;
            #else
            #   define lowp
            #   define mediump
            #   define highp
            #endif // GL_ES
        "
        property bool ready : {
            if(!rootObject.source)
                return false;

            if(fragmentShaderName !== "" && vertexShaderName !== "") {
                return fragSh !== "" && vertSh !== ""
            }
            else if(fragmentShaderName !== ""){
                return fragSh !== ""
            }
            else if(vertexShaderName !== ""){
                return vertSh !== ""
            }

            return false;
        }
        onReadyChanged: ready ? load() : unload()
        onFragmentShaderNameChanged: if(fragmentShaderName !== "") readFile(shaderDir + fragmentShaderName, init, "fragSh")
        onVertexShaderNameChanged  : if(vertexShaderName !== "")   readFile(shaderDir + vertexShaderName  , init, "vertSh")


        function init(text,propertyName){
            if(text && text.length > 0){
                if(propertyName === "fragSh")  logic[propertyName] = fragmentShaderCommon + text;
                else                           logic[propertyName] = text
            }
        }
        function readFile(source, callback, propertyName) {
            var xhr = new XMLHttpRequest;
            xhr.open("GET", source);
            xhr.onreadystatechange = function ()
            {
                if (xhr.readyState === XMLHttpRequest.DONE && callback)
                    callback(xhr.responseText, propertyName)
            }
            xhr.send();
        }

        function getValueStr(value){    //this grabs the extra properties!

            var rootProps = ["objectName",
            "parent",
            "data",
            "resources",
            "children",
            "x",
            "y",
            "z",
            "width",
            "height",
            "opacity",
            "enabled",
            "visible",
            "visibleChildren",
            "states",
            "transitions",
            "state",
            "childrenRect",
            "anchors",
            "left",
            "right",
            "horizontalCenter",
            "top",
            "bottom",
            "verticalCenter",
            "baseline",
            "baselineOffset",
            "clip",
            "focus",
            "activeFocus",
            "activeFocusOnTab",
            "rotation",
            "scale",
            "transformOrigin",
            "transformOriginPoint",
            "transform",
            "smooth",
            "antialiasing",
            "implicitWidth",
            "implicitHeight",
            "layer",
            "source",
            "dividerValue",
            "shaderDir",
            "fragmentShaderName",
            "vertexShaderName",
            "effectObj",
            "chainPtr",
            "objectNameChanged",
            "childrenRectChanged",
            "baselineOffsetChanged",
            "stateChanged",
            "focusChanged",
            "activeFocusChanged",
            "activeFocusOnTabChanged",
            "parentChanged",
            "transformOriginChanged",
            "smoothChanged",
            "antialiasingChanged",
            "clipChanged",
            "windowChanged",
            "childrenChanged",
            "opacityChanged",
            "enabledChanged",
            "visibleChanged",
            "visibleChildrenChanged",
            "rotationChanged",
            "scaleChanged",
            "xChanged",
            "yChanged",
            "widthChanged",
            "heightChanged",
            "zChanged",
            "implicitWidthChanged",
            "implicitHeightChanged",
            "update",
            "grabToImage",
            "grabToImage",
            "contains",
            "mapFromItem",
            "mapToItem",
            "forceActiveFocus",
            "forceActiveFocus",
            "nextItemInFocusChain",
            "nextItemInFocusChain",
            "childAt",
            "sourceChanged",
            "valueChanged",
            "dividerValueChanged",
            "shaderDirChanged",
            "fragmentShaderNameChanged",
            "vertexShaderNameChanged",
            "effectObjChanged",
            "chainPtrChanged"]

            function indexOf(k){
                for(var i = 0; i < rootProps.length; ++i){
                    if(rootProps[i] === k)
                        return i;
                }
                return -1
            }

            var extras = []
            for(var r in rootObject) {
                if(r.indexOf("Changed") === -1 && indexOf(r) === -1){
                    extras.push(r);
                }
            }

            var str = "";
            for(var i = 0; i < extras.length; ++i){
                var k  =extras[i]
                str += "\t\tproperty var " + k + " : rootObject." + k + "? rootObject." + k + " : 0;\n"
//                str += "\t\ton" + k.charAt(0).toUpperCase() + k.slice(1) + "Changed: console.log(" + k + ", this." + k + ");\n"

            }

//            console.log(str)
            return str;

        }

        function load(){
            var creationStr =
                'Item {\n' +
                        'anchors.fill : container;\n' +
                        '\tproperty ShaderEffectSource effectSource : ShaderEffectSource {\n' +
                            '\t\thideSource: true;\n' +
                            '\t\tsmooth : true;\n' +
                            '\t\trecursive: true;\n' +
                            '\t\tsourceItem : rootObject.source;\n' +
                            '\t\tanchors.fill : parent;\n' +
                        '\t}\n' +

                        '\tShaderEffect {\n' +
                            '\t\tproperty variant source : effectSource;\n' +
                            '\t\tanchors.fill : parent;\n' +
                            '\t\topacity : rootObject.opacity; \n' +
                            getValueStr() + '\n' +
                            '\t\tproperty real    dividerValue : 1;\n'+
                            '\t\tfragmentShader : "' + fragSh  + '"\n' +
                            '\t\tvertexShader   : "' + vertSh  + '"\n' +
                        '\t}\n' +
                '}'



            effectObj = getQmlObject("QtQuick 2.5", creationStr, rootObject)

            //test
//            effectObj.hChanged.connect(function() { console.log("new hue" , effectObj.h) } )

        }
        function unload(){
            if(effectObj)
                effectObj.destroy()
        }
        function getQmlObject(imports,qmlStr,parent) {
            var str = ""
            if(typeof imports !== 'string')
            {
                for(var i in imports)
                    str += "import " + imports[i] + ";\n"
            }
            else
                str = "import " + imports + ";"

            var obj = Qt.createQmlObject(str + qmlStr,parent,null)
            return obj
        }





    }
    Item {
        id : container
        anchors.fill: parent
    }

}



