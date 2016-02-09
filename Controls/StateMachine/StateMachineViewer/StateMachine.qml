import QtQuick 2.4
import QtQuick.Controls 1.4
import Zabaat.Material 1.0
Item {
    id : rootObject
    property string qmlDirectory       : ""
    property string stateMachinePath   : ""
    readonly property var currentState : logic.currentState && logic.currentState.name ? logic.currentState.name : ""
    property int cellHeight            : 40

    property var logicController : null //the object that is in charge of handling transitions and actions
    property var funcName        : ""

    function begin(id) {
        logic.uid = id  ? id : "";
        loader.setSource(qmlDirectory + "/" + logic.getFirstState().name + ".qml")
    }
    QtObject {
        id : logic

        property var currentState     : null
        property var model            : null
        property string uid           : ""
        property string name          : ""
        property var actions          : currentState ? currentState.actions     : null
        property var transitions      : currentState ? currentState.transitions : null


        function load(obj){
            name    = obj.name

//            for(var i = 0; i < obj.states; i++){
//                var state = obj.states[i]
//                fixTransitions(state)
//                fixActions(state)
//            }


            model        = obj.states
            currentState = getFirstState()
            begin()
        }

        function performTransition(name){
            var stateName = ""
            for(var t = 0; t < transitions.length; t++){
                var tr = transitions[t]
                if(name === tr.name){

                    loader.setSource(qmlDirectory + "/"  + tr.state + ".qml")
                    return currentState = getState(tr.state)
                }
            }
        }

        function fixTransitions(obj){
            for(var i = 0; i < obj.transitions.length; i++){
                var t = obj.transitions[i]
                t.text = t.name;
            }
        }
        function fixActions(obj){
            for(var i = 0; i < obj.transitions.length; i++){
                var a = obj.actions[i]
                a.text = a.name;
            }
        }

        function readFile(source, callback) {
            var xhr = new XMLHttpRequest;
            xhr.open("GET", source);
            xhr.onreadystatechange = function () {
                if (xhr.readyState === XMLHttpRequest.DONE && callback)
                    callback(xhr.responseText)
            }
            xhr.send();
        }
        function readJSONFile(source, callback) {
            readFile(source, function(jsData) {
                var a = JSON.parse(jsData);
                if(callback)
                    callback(a)
            })
        }

        function getState(name){
            for(var i = 0; i < model.length; i++){
                var state = model[i]
                if(state.name === name)
                    return state;
            }
            return null;
        }
        function getFirstState(){
            var def = model[0]
            for(var i = 0; i < model.length; i++){
                var state = model[i]
                if(state.isDefault)
                    return state;
            }
            return def;
        }



    }



    onStateMachinePathChanged        : logic.readJSONFile(stateMachinePath, logic.load);
    Loader {
        id : loader
        width : parent.width
        height : parent.height - menu.height
        onLoaded : if(item.hasOwnProperty("uid")) item.uid = logic.uid

    }
    Rectangle {
        id: menu
        width         : parent.width
        height        : parent.height * 0.2
        anchors.bottom: parent.bottom
        border.width: 1


        ListView {
            id : lv
            anchors.right: parent.right
            height : parent.height
            width  : parent.width * 0.4

            property alias transitionSrc : logic.transitions
            onTransitionSrcChanged: {
//                if(transitionSrc){
//                    lv.model.clear()
//                    for(var t = 0; t < transitionSrc.length; t++){
//                        var item = transitionSrc[t]
//                        console.log(JSON.stringify(item))
//                        lv.model.append(item)
//                    }
//                }
//                else {

//                }
            }

            model  : transitionSrc// ListModel { dynamicRoles : true }
            delegate : Button {
                text : lv.model && lv.model.length > index ? lv.model[index].name : null
                width  : lv.width
                height : cellHeight
                onClicked: logic.performTransition(text)
            }
        }

    }






}
