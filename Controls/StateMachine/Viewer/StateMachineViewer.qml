import QtQuick 2.4
import "Functions"
Item {
    id : rootObject

    //this is the rootdirectory of state machine qmls. each statemachine should have it's own qml dir.
    property string qmlDirectory : Qt.resolvedUrl('example')
    property var stateMachine    : null  //this is the statemachine
    property var    modelObject  : null  //the object that obeys or lives inside the statemachine
    property alias logic : logic

    readonly property alias currentState : logic.currentState
    property var transitionFunc : logic.defTransitionFunc //provide this function. inputs(string id, string dest). Should make modelObject change states
    property var methodCallFunc : null  //provide this function. inputs(string id, var params).Should change modeObject in someway
                                                                                               //(should rarely change state!)
    property var navController  : defaultNavigation

//    onStateMachineChanged: console.log("stateMachine",JSON.stringify(stateMachine,null,2))
//    onModelObjectChanged: console.log("modelObject",JSON.stringify(modelObject,null,2))

    QtObject {
        id : logic
        readonly property string stateMachineName : stateMachine ? stateMachine.name : ""
        property string          uid              : stateMachine ? stateMachine.id   : ""  //id of currentState
        property string          currentState     : modelObject  ? modelObject.state : ""  //currentState
//        onCurrentStateChanged : console.log(rootObject,"currentState",currentState)
        property var             functions        : stateMachine ? stateMachine.functions : null
        property var             states           : stateMachine ? stateMachine.states    : null

        property var             allowedFunctions   : getAllowedFunctions(currentState)      //allowed functions in the currentState
        property var             allowedTransitions : getAllowedTransitions(currentState)   //allowed transitions from currentState
        property var             alwaysAllowedFunctions : [ {
                id:"0",
                name : "stateChange",
                readOnly : true,
                rules    : [{ name : "id", type :"string", required:true, choices:"" } ,
                             { name : "dest", type:"string",required:true, choices:"" } ]
              } ,
              {
                 id       :"1",
                 name     : "update",
                 readOnly : true,
                 rules    : [{ name : "model", type :"object", required:true, choices:"" }]
               }
            ]

        function defTransitionFunc(id,state){  modelObject.state = state }


        function callFunction(fnName, params){
            if(!methodCallFunc)
                return console.error("StateMachine has not been provided with a methodCall function")

            if(!canCall(fnName))
                return console.error(currentState,"cannot call",fnName)

            var s = validate(fnName,params)
            if(s === null){
                methodCallFunc(fnName,params)
            }
            else
                return console.error("rule validation fail:",s)
        }
        function performTransition(toState){
            if(!transitionFunc)
                return console.error("Statemachine has not been provided with a transition function")

            if(!canTransition(toState))
                return console.error(currentState,"cannot transition to",toState)


            transitionFunc(uid, toState);
        }


        function canCall(fnName){
            return logic.allowedFunctions ? GFuncs.getFromArray(allowedFunctions,fnName,"name",true) !== -1 : false
        }
        function canTransition(toState){
//            console.log(JSON.stringify(GFuncs.toArray(logic.allowedTransitions,null,2)))
            return logic.allowedTransitions ? GFuncs.getFromList(allowedTransitions,toState,"dest",true) !== -1 : false
        }
        function validate(fnName,params){


            return null;
        }


        function getAllowedTransitions(stateName){
            if(stateMachine && currentState !== ""){
                var stateObj = GFuncs.getFromList(logic.states,stateName,"name")
                if(stateObj)
                    return stateObj.transitions
            }
            return null;
        }
        function getAllowedFunctions(stateName){
            var fArr = _.clone(alwaysAllowedFunctions)
            if(stateMachine && currentState !== "") {
                var stateObj = GFuncs.getFromList(logic.states,stateName,"name")
                var funcs    = stateObj ? stateObj.functions : null

                if(funcs) {
                    //iterate thru the funcs
                    for(var f = 0; f < funcs.count; ++f){
                        var fItem = funcs.get(f);
                        var rules = getRules(fItem.name, fItem.rules);
                        fArr.push({name : fItem.name, rules : rules})
                    }
                }
            }
            return fArr;
        }

        //get overrided rules or default rules!
        function getRules(name, localRules){
             if(localRules && localRules.count > 0) {
                return GFuncs.toArray(localRules);
             }
             else {
                var    f = GFuncs.getFromList(logic.functions,name,"name")
                return f ? GFuncs.toArray(f.rules) : []
             }
        }

    }


    Loader {
        id          : loader
        anchors.top : parent.top
        width       : parent.width
        height      : parent.height - defaultNavigation.height
        onLoaded    : item.model = modelObject

        source                     : !logic.stateMachineName || curState === "" ? "" : rootObject.qmlDirectory + "/" + logic.stateMachineName + "/" +  curState + ".qml"
        property alias curState    : logic.currentState
        property alias modelObject : rootObject.modelObject

        Text {
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: parent.height * 1/20
            text : currentState
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 5
        }

    }

    DefaultNavigation {
        id            : defaultNavigation
        anchors.bottom: parent.bottom
        width         : parent.width
        height        : parent.height * 0.1
        model         : logic.allowedTransitions
        onRequestTransition : logic.performTransition(name)
    }


}
