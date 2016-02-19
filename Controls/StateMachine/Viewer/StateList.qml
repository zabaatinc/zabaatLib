import Zabaat.Controls.StateMachine 1.0
import QtQuick 2.5
Item{   //Essentially a list of loaders
	id : rootObject
	objectName : "StateList"
    property string qmlDirectory : ""
    property var    stateMachine : null
    property alias  model        : lv.model
    property int    cellHeight   : 40
    property string  defaultDelegateFilename : "ListDelegate.qml"

    signal clicked(int index, var object);

    QtObject {
        id : logic
        property string smName : {
            if(stateMachine){
                return (typeof stateMachine === "object") ? stateMachine.name : stateMachine
            }
            return ""
        }

        function listDelegateSource(){
            if(qmlDirectory === "" || smName === "")
                return "";

            var dir = qmlDirectory.toString();
            var name = smName.toString();
            if(dir.charAt(dir.length -1 ) === "/" )
                dir = dir.splice(0,-1)

            if(name.charAt(name.length -1 ) === "/" )
                name = name.splice(0,-1)

            if(name.charAt(0) === "/" )
                name = name.splice(1)

            return dir + "/" + name + "/" + defaultDelegateFilename;
        }
    }

    ListView {
        id : lv
        anchors.fill: parent
//        model : rootObject.model
        delegate : Loader {
            id : del
            width  : lv.width
            height : cellHeight
            source : logic.listDelegateSource()
            onLoaded : {
                item.anchors.fill = del
                if(item && item.hasOwnProperty("model")){
//                    console.log("ADDING a thing to the list", lv.model)
                    item.model = lv.model.get(index);
                }
            }
            MouseArea {
                anchors.fill: parent
                propagateComposedEvents: true
                onClicked : rootObject.clicked(index, lv.model.get(index))
            }
        }
    }


}
