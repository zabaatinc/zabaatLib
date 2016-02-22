import QtQuick 2.4
Item {
    property var    model                 : null
    property string stateName             : model ? model.state : ""
    property var    stateMachinePtr       : null
//    onStateNameChanged: console.log(this, stateName)

    //all this is just for intellisense!!
    readonly property string stateMachineName  : stateMachinePtr ? stateMachinePtr.logic.stateMachineName  : "<Error"
    readonly property string uid               : stateMachinePtr ? stateMachinePtr.logic.uid               : ""
    readonly property string currentState      : stateMachinePtr ? stateMachinePtr.logic.currentState      : ""
    readonly property var    allowedFunctions  : stateMachinePtr ? stateMachinePtr.logic.allowedFunctions  : null
    readonly property var    allowedTransitions: stateMachinePtr ? stateMachinePtr.logic.allowedTransitions: null

    //de most important
    readonly property var transitionFunc  : stateMachinePtr ? stateMachinePtr.transitionFunc          : null//id,state
    readonly property var methodCallFunc  : stateMachinePtr ? stateMachinePtr.methodCallFunc          : null//fnname,params
    readonly property var canTransition   : stateMachinePtr ? stateMachinePtr.logic.canTransition     : null//toSTate
    readonly property var canCall         : stateMachinePtr ? stateMachinePtr.logic.canCall           : null//fnName
    readonly property string defaultState : stateMachinePtr ? stateMachinePtr.logic.getDefaultState() : ""  //void
    readonly property var validate        : stateMachinePtr ? stateMachinePtr.logic.validate          : null//fnname,params
}
