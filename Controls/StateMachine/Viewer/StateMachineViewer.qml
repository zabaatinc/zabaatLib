import QtQuick 2.4
import "Functions"
import "FancyLoader"
import Zabaat.Utility 1.0

/*!
   \brief The viewer for a statemachine. It will follow the rules of the statemachine.
   \inqmlmodule Zabaat.Controls.StateMachine 1.0 \hr
*/
Item {
    id : rootObject

    /*! this is the rootdirectory of state machine qmls. each statemachine should have it's own qml dir */
    property string qmlDirectory : Qt.resolvedUrl('example')

    /*! this is the statemachine object. The one whose rules should be followed! */
    property var stateMachine    : null

    /*! The object within the state machine. Should have a state property */
    property var    modelObject  : null

    /*! alias to logic */
    property alias logic         : logic

    /*! the animation to play when moving from one state to another. These are the options : \br
        fade        \br
        slideRight  \br
        slideLeft   \br
        slideUp     \br
        slideDown   \br
        scaleIn     \br
        rotateRight \br
        rotateLeft  \br
        \hr
    */
    property alias defaultTransitionAnimation: loader.transitionEffect

    /*!  the amount of ms it takes to transition from one state to the next */
    property alias defaultTransitionDuration : loader.transitionDuration

    /*!  The current state that modelObject is in */
    readonly property alias currentState : logic.currentState

    /*!  All the states that are available in this statemachine */
    readonly property alias allStates    : logic.states

    /*! \fn provide this function. inputs(string id, string dest). Should make modelObject change states. \br\b default: logic.defaultTransitionFunc */
    property var transitionFunc : logic.defaultTransitionFunc

    /*! \fn provide this function. inputs(string fnName, var params).Should change modeObject in someway. Should almost never change states!\br\b default : null */
    property var methodCallFunc : null

    /*! \fn uses methodCallFunc, if provided, to update the modelObject on the server. This should not really change the state. \br\b default : null */
    property var updateFunc : !methodCallFunc ? null : function(cb){
        var obj = {id:logic.uid, data:[logic.cleanClone()] }
//        console.log("Update", JSON.stringify(obj,null,2))
        methodCallFunc("update", obj, cb)
    }

    /*! Determines whether we should auto build the gui to show the options for adjacent states. Somewhat ugly but functional. */
    property bool usesDefaultNavigation : true
    property bool debug : true

//    onStateMachineChanged: console.log("stateMachine",JSON.stringify(stateMachine,null,2))
//    onModelObjectChanged: console.log("modelObject",JSON.stringify(modelObject,null,2))

    QtObject {
        id : logic
        readonly property string stateMachineName : stateMachine ? stateMachine.name : ""
        property string          currentState     : modelObject  ? modelObject.state : ""  //currentState
        property string          uid              : modelObject && modelObject.id ? modelObject.id  : ""
//        property int currentIndex : {
//            if(states && currentState !== "") {
//                for(var i = 0; i < states.count; ++i){
//                    var s = states.get(i)
//                    if(s.name === currentState)
//                        return i;
//                }
//            }
//            return -1
//        }
//         modelObject   ? currentState.id   : ""  //id of currentState
        property bool removeMutex : false
        onCurrentStateChanged  : if(!removeMutex){
//                                     console.log("currentState changed", currentState)
                                     if(!stack) {
                                          stack = [currentState]
//                                          console.log(stack)
                                      }
                                      else {
                                          stack.splice(0,0,currentState)
//                                          console.log(stack)
                                      }
//                                      console.log(removeMutex, stack)
                                 }



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

        property var stack : [] //this lets us go back states!
        onStackChanged: console.log(stack)

        function cleanClone(){
            return Functions.object.modelObjectToJs(modelObject)
        }
        function defaultTransitionFunc(id,state, cb){  modelObject.state = state; if(cb) cb() }
        function callFunction(fnName, params){
            if(!methodCallFunc)
                return console.error("StateMachine has not been provided with a methodCall function")

            if(!canCall(fnName))
                return console.error(currentState,"cannot call",fnName)

            var s = validate(fnName,params)
            if(s === null){
                if(arguments.length > 2)
                    methodCallFunc.apply(this,arguments)
                else
                    methodCallFunc(fnName,params)
            }
            else
                return console.error("rule validation fail:",s)
        }
        function performTransition(toState, cb){
            if(!transitionFunc){
                console.error("Statemachine has not been provided with a transition function")
                return false;
            }

            if(!canTransition(toState)){
                console.error(currentState,"cannot transition to",toState)
                return false;
            }

            transitionFunc(uid, toState, cb);
            return true;
        }
        function canCall(fnName){
            return logic.allowedFunctions ? GFuncs.getFromArray(allowedFunctions,fnName,"name",true) !== -1 : false
        }
        function canTransition(toState){
//            console.log(JSON.stringify(GFuncs.toArray(logic.allowedTransitions,null,2)))
            return logic.allowedTransitions ? GFuncs.getFromList(allowedTransitions,toState,"dest",true) !== -1 : false
        }
        function validate(fnName,params){   //null value means no error
            //TODO

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
        function getDefaultState(){
            var item = GFuncs.getFromList(logic.states, true, "isDefault")
            if(item) {
                return item.name
            }
            return ""
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
        function back(override){
            if(stack.length > 1){   //will always have the first state in it!
                var prev = stack[1]
                if(override){   //essentially dont follow the rules of the state machine!
                    logic.removeMutex = true;
                    stack.splice(0,1);
//                    stack[0]
                    transitionFunc(uid,prev);
                    logic.removeMutex = false;
                }
                else if(canTransition(prev)){
//                    console.log("FALLING IN HERE", stack)
                    logic.removeMutex = true;

                    stack.splice(0,1);
                    transitionFunc(uid,prev);
//                    console.log("FALLING IN HERE", stack)
                    logic.removeMutex = false;
                }
                console.log("back ended", stack)
            }
            else
                console.warn("cannot go back. Already at the base state")
        }
    }


    FancyLoader {   //This loads the STateITems!
        id          : loader
        objectName  : "FancyLoader"
//        Component.onCompleted: console.log(this)
        anchors.top : parent.top
        width       : parent.width
        height      : parent.height - defaultNavigationLoader.height
//        transitionEffect: "rotateLeft"
        onLoaded    : if(item){
                          if(item.hasOwnProperty('model'))              item.model           = modelObject;
                          if(item.hasOwnProperty("stateMachinePtr"))    item.stateMachinePtr = rootObject;
                      }
//                      else                   console.error(item,"has no model property")
        source                     : !logic.stateMachineName || curState === "" ? "" : rootObject.qmlDirectory + "/" + logic.stateMachineName + "/" +  curState + ".qml"
        property alias curState    : logic.currentState
        property alias modelObject : rootObject.modelObject
    }

    Text {
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        font.pixelSize: parent.height * 1/20
        text : currentState
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 5
        visible : debug
    }


    Loader {
        id : defaultNavigationLoader
        anchors.bottom: parent.bottom
        width         : parent.width
        height          : usesDefaultNavigation ?  parent.height * 0.05 : 0
        sourceComponent : usesDefaultNavigation ? defaultNavComponent   : null

        Component{
            id : defaultNavComponent
            DefaultNavigation {
                id            : defaultNavigation
                model         : logic.allowedTransitions
                onRequestTransition : logic.performTransition(name)
            }
        }
    }




}
