import QtQuick 2.5
Item {
    id : rootObject
    property variant source             : null
    property var     value              : null
    property real    dividerValue       : 1
    property alias   fragmentShaderName : logic.fragmentShaderName
    property alias   vertexShaderName   : logic.vertexShaderName
    property string  shaderDir          : "./shaders/"
    property alias   effectObj          : logic.effectObj

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
                return;

            if(fragmentShaderName !== "" && vertexShaderName !== "") {
                return fragSh !== "" && vertSh !== ""
            }
            else if(fragmentShaderName !== ""){
                return fragSh !== ""
            }
            else if(vertexShaderName !== ""){
                return vertSh !== ""
            }
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

        function getValueStr(value){
            function getType(obj){
                if(obj === null)
                    return null;
                var type = typeof obj
                if(type === 'object'){
                    if(toString.call(obj) === '[object Array]')
                        return "array"
                    var qName = qmlName(obj)
                    return qName === "" ? "object" : qName
                }
                else {
                    return type;
                }
            }

            if(getType(value) === "object"){
                var str = ""

                for(var v in value){
                    str = str + 'property var ' + v + ' : rootObject && rootObject.value.' + v + '? rootObject.value.' + v + ' : 0;\n'
                }

                return str
            }
            return ""
        }

        function load(){
            var creationStr =
                'Item {
                        anchors.fill : container;
                        \tproperty ShaderEffectSource effectSource : ShaderEffectSource {
                            \t\thideSource: true;
                            \t\tsmooth : true;
                            \t\trecursive: true;
                            \t\tsourceItem : rootObject.source;
                            \t\tanchors.fill : parent;
                        }' +

                        '\tShaderEffect {\n' +
                            '\t\tproperty variant source : effectSource;\n' +
                            '\t\tproperty var     value  : rootObject && rootObject.value  ? rootObject.value    : null;\n' +
                            '\t\tanchors.fill : parent;\n' +
                            '\t\tproperty real h  : value  ? value.h  : 3;\n' +
//                            '\t\tonHChanged : console.log("h changed", h); \n' +
                            '\t\tproperty real s  : value  ? value.s  : 1;\n' +
                            '\t\tproperty real v  : value  ? value.v  : 1;\n' +
                            '\t\topacity : rootObject.opacity; \n' +

        //                    + getValueStr(rootObject.value) +
                            '\t\tproperty real    dividerValue : 1;\n'+
                            '\t\tfragmentShader : "' + fragSh  + '"\n' +
                            '\t\tvertexShader   : "' + vertSh  + '"\n' +
                        '\t}' +
                '}'



//            console.log(creationStr)

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



