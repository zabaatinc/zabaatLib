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
    property alias lv : lv
    property alias section : lv.section


    signal clicked(int index, var object);

    function delegateAt(idx) {
        for(var i = 0; i < lv.contentItem.children.length; ++i) {
            var child = lv.contentItem.children[i]
            if(child.imADelegate && lv._index === idx)
                return child;
        }
        return null;
    }

    function emulateClick(index){
         if(lv.model && lv.model.count > index && index >= 0)
            rootObject.clicked(index, lv.model.get(index))
        else
            rootObject.clicked(-1,null)
    }


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
        delegate : MouseArea {
            width  : lv.width
            height : cellHeight
            onClicked : rootObject.clicked(index, lv.model.get(index))

            property bool imADelegate : true
            property int _index : index
            property alias loader : del

            Loader {
                id : del
                anchors.fill: parent
                source : logic.listDelegateSource()
                onLoaded : {
                    item.anchors.fill = del
                    if(item && item.hasOwnProperty("model")){
    //                    console.log("ADDING a thing to the list", lv.model)
                        item.model = lv.model.get(index);
                    }
                }
            }
        }


    }


}
