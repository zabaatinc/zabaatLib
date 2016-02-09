import QtQuick 2.4
import Zabaat.Misc.Global 1.0

Item{
    id : rootObject
    property var validationFunc : function(obj) { console.log(rootObject, 'validationFunc is the default blank one. Please replace.'); return null }

    signal ok()
    signal loading()
    signal error()
    signal errorsCleared()

    function validate(obj){
        if(validationFunc){
            var invalidity = validationFunc(obj)
            if(invalidity !== null){
                errorText.text     = invalidity
                rootObject.state   = 'error'
                error()
                return false
            }
        }
        return true
    }
    function errorMessage(msg){
        if(!ZGlobal.functions.isUndef(msg))            errorText.text = msg
        else                                           errorText.text = 'error message is not defined'

        rootObject.state = "error"
        error()
    }
    function clearError(){
        errorText.text = ""
        rootObject.state = "ok"
        errorsCleared()
    }

    property alias errorRectPtr       : errorRect
    property alias spinnyPtr          : spinny



    Rectangle {
        id     : errorRect
        width  : parent.width
        height : errorText.text.length > 0 ? 30 : 0
        color  : errorText.text.length > 0 ? ZGlobal.style.danger : "transparent"

        Text {
            id : errorText
            font : ZGlobal.style.text.normal
            text : ""
            color : text.length > 0 ?  "white" : "transparent"
            width : parent.width
            height: errorText.text.length > 0 ? parent.height : 0
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            Behavior on height {NumberAnimation{duration:350}}
        }
        MouseArea {
            anchors.fill: parent
            onClicked: {  errorText.text = "";  rootObject.state = "" ; errorsCleared() }
        }
    }


    Text  {
        id          : spinny
        font.family : "FontAwesome"
        text        : ""
        height      : paintedHeight
        width       : font.pixelSize

        font.pointSize: 32
        property bool doSpin : false
        transform : Rotation { origin.x : spinny.paintedWidth/2; origin.y : spinny.paintedHeight/2 }
        NumberAnimation {
            running  : spinny.doSpin
            target   : spinny
            property : "rotation"
            duration : 1000
            from     : 0
            to       : 360
            loops    : Animation.Infinite
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {  if(rootObject.state === 'error') { errorText.text = "";  rootObject.state = ""; errorsCleared()  } }
        }
   }

    states: [
        State { name : 'loading';  PropertyChanges { target: spinny; text : "\uf110"; color : ZGlobal.style.warning;  doSpin : true                } },
        State { name : 'ok';       PropertyChanges { target: spinny; text : "\uf00c"; color : ZGlobal.style.success;  doSpin : false; rotation : 0 } },
        State { name : 'error';    PropertyChanges { target: spinny; text : "\uf00d"; color : ZGlobal.style.danger ;  doSpin : false; rotation : 0 } }
    ]


}
