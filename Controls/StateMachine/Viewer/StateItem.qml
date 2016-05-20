import QtQuick 2.4
Item {
    id : rootObject
    property var    model                 : null
    property string stateName             : model ? model.state : ""
    property var    stateMachinePtr       : null

    property int status                   : Component.Loading

    signal ready()   //use this instead of Component.onCompleted!! The SMV will turn this on!
    onReady : status = Component.Ready

//    onStateNameChanged: console.log(this, stateName)

    //all this is just for intellisense!!
    readonly property string stateMachineName  : stateMachinePtr ? stateMachinePtr.logic.stateMachineName  : "<Error"
    readonly property string uid               : stateMachinePtr ? stateMachinePtr.logic.uid               : ""
    readonly property string currentState      : stateMachinePtr ? stateMachinePtr.logic.currentState      : ""
    readonly property var    allowedFunctions  : stateMachinePtr ? stateMachinePtr.logic.allowedFunctions  : null
    readonly property var    allowedTransitions: stateMachinePtr ? stateMachinePtr.logic.allowedTransitions: null

    //de most important
    readonly property var transitionFunc  : stateMachinePtr ? stateMachinePtr.transitionFunc          : getNewFn("transitionFunc")//id,state
    readonly property var methodCallFunc  : stateMachinePtr ? stateMachinePtr.methodCallFunc          : getNewFn("methodCall")//fnname,params
    readonly property var canTransition   : stateMachinePtr ? stateMachinePtr.logic.canTransition     : getNewFn("canTransition")
    readonly property var canCall         : stateMachinePtr ? stateMachinePtr.logic.canCall           : getNewFn("canCall")
    readonly property string defaultState : stateMachinePtr ? stateMachinePtr.logic.getDefaultState() : ""  //void
    readonly property var validate        : stateMachinePtr ? stateMachinePtr.logic.validate          : getNewFn("validate")
    readonly property var updateFunc      : stateMachinePtr ? stateMachinePtr.updateFunc              : getNewFn("updateFunc")
//    readonly property var updateFunc      : getNewFn("updateFunc")

    function getNewFn(name){
//        console.error(rootObject, "missing function:", name)
//        var b = BlankFunc(name);
//        return b;

        return function() { console.log(rootObject, "missing function:", name) }
    }

//    function BlankFunc(name){
//        console.log(rootObject, "missing function:", name)
//    }

//    function __blankFunc(name){
//        console.error(name)

//    }
}
