import QtQuick 2.0
import "."
QtObject {
    id : logic
    objectName: "StateMachineEditor_Logic"

    signal modelUpdatedInternally(var obj, string json);     //triggred from internal changes!

    property var model             : null
    property string id             : model && model.id        ? model.id        : ""
    property string name           : model && model.name      ? model.name      : ""
    property var functions         : model && model.functions ? model.functions : null
    property var states            : model && model.states    ? model.states    : null
    property string localName      : ""
    property var    stateContainer : null

    property var defaultStateObject : ({ id : "", name : "", functions:[], transitions:[], isDefault: false })
    property var defaultTransObject : ({name: "", dest : "", rules:[]                                        })

    property int width             : 0
    property int height            : 0
    property int cellHeight        : 40

    //lets the outside world know the model changed. emits modelChanged signal
    function emitChange(){
        var obj  = getObj();
        var json = JSON.stringify(obj,null,2);
        modelUpdatedInternally(obj,json);
    }
    function getObj(){
        return {
            id        : logic.model.id,
            name      : localName,
            functions : GFuncs.toArray(logic.functions) ,
            states    : getStatesJSON() ,
            width     : width,
            height    : height
        }
    }
    function getJSON(){
        return JSON.stringify(getObj(),null,2)
    }


    //Related to states part of a statemachine (in root)
    function makeDefault(id){
        if(!model)
            return;

        var idx = indexOf(id)
        if(idx !== -1){
            for(var i = 0 ; i < logic.states.count; ++i){
                var item = logic.states.get(i)
                item.isDefault = idx === i ? true : false;
            }
            emitChange();
        }
    }
    function createStateBox(args, x,y){
        if(!logic.states)
            return;

        var obj = defaultStateObject
        obj.x   = x
        obj.y   = y
        obj.h   = cellHeight
        obj.w   = obj.h * 3
        obj.id  = (maxId(logic.states) + 1).toString()

        logic.states.append(Lodash.clone(obj))
        emitChange();
    }
    function deleteStateBox(item,x,y){
        var idx = indexOf(item.modelId)
        if(idx !== -1){
            logic.states.remove(idx)
            emitChange();
        }
    }
    function rename(id, name){
        function renameAllTransitions(oldName, newName){
            //iterate over all states, go into their transitions and change dest if it matches oldName
            if(logic.states){
                var numUpdated = 0;
                for(var i =0; i < logic.states.count; i++){
                    var sObj = logic.states.get(i);
                    var transitions = sObj.transitions
                    if(transitions){
                        for(var t = 0; t < transitions.count; t++){
                            var trans = transitions.get(t)
                            if(trans.dest === oldName){
                                trans.dest = newName
                                numUpdated++;
                            }
                        }
                    }
                }
                console.log("transitions updated as a result:", numUpdated)
            }
        }

        var idx = indexOf(id)
        if(idx !== -1){
            //rename all transitions too! that were going to this state!
            var item    = logic.states.get(idx)

            renameAllTransitions(item.name,name)
            item.name = name;
            emitChange();
        }
    }

    //Transitions of a state Object within the states arr
    function createTransition(source, destination){
//                console.log(source, destination)
        var sModel = getState(source);
        var dModel = getState(destination)
        if(sModel && dModel){
            var t = Lodash.clone(defaultTransObject)
            t.dest = destination;
            sModel.transitions.append(t)
            emitChange();
        }
        else {
            console.log("ERROR when creating transition",  source,":",sModel,"\t",destination,":",dModel )
        }
    }
    function deleteTransition(originName, destinationName, friendlyName){
        //find origin state
//        console.log(originName, destinationName, friendlyName)
        var sModel = getState(originName)
        var tIndex = getTransition(originName, destinationName, friendlyName, true)
//        console.log(sModel,tIndex)

        if(tIndex !== -1){
            sModel.transitions.remove(tIndex);
            emitChange();
        }
    }
    function editTransition(originName, destinationName, oldName, newName, rules){
//        console.log(originName,destinationName,oldName,newName,rules)
        var idx = getTransition(originName, destinationName, oldName, true)
        if(idx !== -1){
            var sModel = getState(originName)
            var t = Lodash.clone(defaultTransObject)
            t.name = newName ? newName : oldName ? oldName : ""
            t.dest = destinationName;
            t.rules = rules;
            sModel.transitions.set(idx,t);  //overwrite the thinger!
            emitChange();
        }
    }

    //Related to functions part of a statemachine (in root)
    function createFunction(name, rules){
        var idx = getFunction(name,true)
        if(idx === -1){  //does not exist!
            var mId = (maxId(logic.functions) + 1).toString()
            var fObj ={id : mId ,name : name, rules : rules , readOnly : false }
            logic.functions.append(fObj)
            emitChange();
        }
//                console.log("function", name, "alreay exists!")
    }
    function editFunction(id, rules, name){
        var idx = getFunctionById(id,true)
//                console.log("edit function called", id, name, JSON.stringify(rules,null,2))
//                console.log("in hurr, idx", idx)
//                console.log( JSON.stringify(GFuncs.toArray(logic.functions) ,null , 2))

        function updateAllStates(fId, oldName, newName){ //useful if the function was renamed!
            var updateCount = 0;
            for(var i =0; i < logic.states.count; ++i){
                var s = logic.states.get(i)
                var fList = s.functions;
                if(fList){
                    for(var f = 0; f < fList.count; ++f){
                        var fItem = fList.get(f)
                        if(typeof fItem === 'string' && fItem === oldName){
                            fList.set(f,newName)
                            updateCount++
                        }
                        else if(typeof fItem === 'object' && fItem.id === fId){
                            fItem.name = newName
                            updateCount++
                        }
                    }
                }
            }
        }

        if(idx !== -1){
            var f   = logic.functions.get(idx);

            var fObj ={id : id, name : name, rules : rules }
            if(name !== f.name){
                updateAllStates(id, f.name, name)  //update all states that were saying we allow this func
            }

            logic.functions.set(idx,fObj)
            emitChange();
        }
        else {
            console.log(id, name, "function not found. Sorry. Try again later.")
        }
    }
    function deleteFunction(id, name){
        var idx = getFunctionById(id, true)
        if(idx !== -1){
            logic.functions.remove(idx)
            emitChange();
        }
    }
    function addFunctionToState(id, fn){
        var idx = indexOf(id)
        if(idx !== -1){
            var s = logic.states.get(idx)
            if(fnIndexInState(s,fn) === -1){
//                        console.log('adding function')
                s.functions.append({name : fn , rules : []})
                emitChange();
            }
        }
    }
    function removeFunctionFromState(id, fn){
        var idx = indexOf(id)
        if(idx !== -1){
            var s = logic.states.get(idx)
            var fIndex = fnIndexInState(s,fn)
            console.log("removeFunctionFromState" , id, fn, s, fIndex)
            if(fIndex !== -1){
                s.functions.remove(fIndex)
                emitChange();
            }
        }
    }
    function editFunctionInState(id, fn, rules){
        var idx = indexOf(id)
        if(idx !== -1){
            var s = logic.states.get(idx)
            var fIndex = fnIndexInState(s,fn) !== -1
            if(fIndex !== -1){
                var fObj = { name : fn, rules : rules }
                s.functions.set(fIndex,fObj)
                emitChange();
            }
        }
    }

    //helpers
    function fnIndexInState(stateObj, fName){
        var functions = stateObj.functions
        for(var i = 0; i < functions.count; i++){
            var fItem = functions.get(i)
            if(typeof fItem === 'string' && fName === fItem)
                return i;
            else if(typeof fItem === 'object' && fItem.name === fName)
                return i
        }
        return -1
    }
    function getFunction(name, giveMeIndex){
        if(logic.functions){
            for(var i = 0; i < logic.functions.count; ++i){
                var f= logic.functions.get(i)
                if(f.name === name)
                    return giveMeIndex ? i : f;
            }
        }
        return giveMeIndex ? -1 : null
    }
    function getFunctionById(id, giveMeIndex){
        if(logic.functions){
            for(var i = 0; i < logic.functions.count; ++i){
                var f= logic.functions.get(i)
//                        console.log("comparing",id, "with", f.id)
                if(f.id === id)
                    return giveMeIndex ? i : f;
            }
        }
        return giveMeIndex ? -1 : null
    }
    function getTransition(originName, destinationName, friendlyName, giveMeIndex){
        var sModel = getState(originName)
//                var dModel = getState(dModel)
        if(sModel){
            var transitions = sModel.transitions
            for(var t = 0; t < transitions.count; ++t){
                var trans = transitions.get(t)
                if(trans.dest === destinationName){
                    if(Lodash.isUndefined(friendlyName) || friendlyName === ""){
                        return giveMeIndex ? t : trans
                    }
                    else if(trans.name === friendlyName){
                        return giveMeIndex ? t : trans
                    }
                }
            }
        }

        return giveMeIndex ? -1 : null;
    }
    function getState(name){
        if(logic.states){
            for(var i = 0; i < logic.states.count; i++){
                var item = logic.states.get(i)
//                        console.log(JSON.stringify(item,null,2))
                if(item.name == name)
                    return item
            }
        }
//                console.log("getState NOT FOUND")
        return null
    }
    function getStateById(id){
        var idx = indexOf(id)
        if(idx)
            return logic.states.get(idx)
    }
    function indexOf(id){
        if(logic.states){
            for(var i = 0; i < logic.states.count; i++){
                var item = logic.states.get(i)
                if(item && item.id == id)
                    return i
            }
        }
        return -1;
    }
    function maxId(lm){
        var max = -1;
        if(lm){
            for(var i = 0; i < lm.count; i++){
                max = Math.max(max, +  lm.get(i).id )
            }
        }
        return max;
    }

    //validtorization
    function funcNameValidation(name, oldText, self){
        if(name === self.name)
            return null;

        function nameExists(name){
            if(functions){
                for(var i = 0; i < functions.count; i++){
                    var item = functions.get(i)
                    if(item.name === name)
                        return true;
                }
            }
            return false;
        }

        if(name.length === 0 || name.trim().length === 0)
            return "too short"

        if(!isNaN(name))
            return "starts with digit"

        if(nameExists(name)){
            return "name already exists"
        }

//            console.log("RETurning null!")
        return null;
    }
    function nameValidation(name, oldText, self){
        if(name === self.name)
            return null;

        function nameExists(name){
            if(states){
                for(var i = 0; i < states.count; i++){
                    var item = states.get(i)
                    if(item.name === name)
                        return true;
                }
            }
            return false;
        }

        if(name.length === 0 || name.trim().length === 0)
            return "too short"

        if(!isNaN(name))
            return "starts with digit"

        if(nameExists(name)){
            return "name already exists"
        }

//            console.log("RETurning null!")
        return null;
    }

    function getStatesJSON(){
        var arr = []
        if(stateContainer) {
            if(!stateContainer.model)
                return {}
            for(var i = 0; i < stateContainer.model.count; ++i){
                var item = stateContainer.itemAt(i)
                if(item && item.getJSON){
                    arr.push(item.getJSON())
                }
            }
        }
        return arr;
    }



}
