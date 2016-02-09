import QtQuick 2.0
ShaderEffect {
    id : rootObject
    property variant source
    property string  fragmentShaderName
    property string  vertexShaderName
    property var     value
    property real    dividerValue : 1
    property string  shaderDir : "./shaders/"

    QtObject {
        id: d
        property string fragmentShaderCommon: "
            #ifdef GL_ES
                precision mediump float;
            #else
            #   define lowp
            #   define mediump
            #   define highp
            #endif // GL_ES
        "
    }
    onFragmentShaderNameChanged: readFile(shaderDir + fragmentShaderName, init, "fragmentShader")
    onVertexShaderNameChanged  : readFile(shaderDir + vertexShaderName  , init, "vertexShader")


    function init(text,propertyName){
        if(text && text.length > 0){
//            console.log(text)
            rootObject[propertyName] = d.fragmentShaderCommon + text;
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
}

