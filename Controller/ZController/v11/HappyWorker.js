function isArray(obj) {
    return toString.call(obj) === '[object Array]'
}

function getById(lm, id, giveIndex){
    for(var i = 0; i < lm.count; ++i)   {
        var item = lm.get(i);
        if(item.id === id){
            return giveIndex ? i : lm.get(i);
        }
    }
    return giveIndex ? -1 : null;
}

function isDef(val){
    return val === null || typeof val === 'undefined' ? false : true;
}


WorkerScript.onMessage = function(msg) {
    if(msg && msg.type) {
        switch(msg.type) {
            case "add" :
                var time = +(new Date().getTime())
                var count = msg.lm.count

                var requests = appendToModel(msg.lm, msg.data, msg.location);

                //update vars
                count = msg.lm.count - count;
                time = +(new Date().getTime()) - time

                console.log("@@@@ SYNC ON @@@@" , msg.name)
                msg.lm.sync();
                if(msg.syncModel)
                    msg.syncModel.sync();
                console.log('@@@@ SAFE @@@@')

                WorkerScript.sendMessage({type:'add',
                                            name         : msg.name,
                                            time         : time,
                                            count       : count,
                                            isNew       : msg.isNew,
                                            requests    : requests
                                            })

                break;
        }
    }
}


/*! fn: SHOULD be moved to private. do not USE! \hr */
function appendToModel(lm , data, location){  //returns new count
    var arr = isArray(data) ? data : [data]
    var requests = []
    for(var i = 0; i < arr.length; i++) {
        var r = addObjectToModel(lm,arr[i], location)
        if(r)
            requests.push(r);
    }
    return requests
}


function addObjectToModel(lm, obj, location) {
    if(obj && obj.id !== null && typeof obj.id !== 'undefined') {

        var existingIdx = getById(lm, obj.id, true);
        if(existingIdx === -1){  //data doesnt exist. append it.
//            console.log(lm, location, JSON.stringify(obj))
            lm.append(obj);
            return null;
        }
        else {              //update existing
            var existingItem = lm.get(existingIdx);
            return updateItem(existingItem, obj, location + "→" + existingIdx);
        }
    }
}

function updateItem(existingItem, obj, location){
    for(var o in obj)  {
        if(o !== 'id') {
            var oldValue  = existingItem[o]
            var newValue  = obj[o]


            if(typeof newValue !== 'object'){   //is a simple object

                if(oldValue !== newValue)
                     existingItem[o] = newValue
            }
            else if(!isDef(oldValue)){  //we dont have an old lm, create it and append obj[o] to it??


                return { location : location + "." + o, data : newValue }
//                if(isArray(newValue) ){
//                    if(newValue.length > 0){

//                        existingItem[o] = [] //newModelFunc('ZListModel.qml',existingItem)

////                        existingItem[o].dynamicRoles = true;
//                        existingItem[o].append(newValue)
//                    }
//                }
//                else {

//                    existingItem[o] = [] //newModelFunc('ZListModel.qml',existingItem)

////                    existingItem[o].dynamicRoles = true;
//                    existingItem[o].append(newValue)
//                }


            }
            else {
//                console.log('updateItem::deep copy::',debugName,obj.id, "_______")
                deepCopy(existingItem[o],obj[o], existingItem, o,o )
            }
        }
    }
}

function deepCopy(obj1, obj2, prev, lvl1, lvl2)  {

    if(typeof obj2 !== 'object')  {
        //do equality check
        if(obj1 !== obj2)
            obj1 = obj2

        return
    }

    //if we got an update such that obj2 is now empty, we should do that. //TODO, check the else.
    if(isArray(obj2) && obj2.length === 0){
        if(obj1.toString().toLowerCase().indexOf('model') !== -1)
            obj1.clear()
        else
            obj1 = []

        return;
    }

    for(var o in obj2) {
        var newVal = obj2[o]

        if(isDef(newVal) && isDef(newVal.id)) {

            var elem = getById(obj1, newVal.id)  //this is TE 0
            if(!elem) {

                for(var p in newVal) {
                    if(typeof newVal[p] !== 'object') {
                        if(elem[p] !== newVal[p])
                            elem[p] = newVal[p]
                    }
                    else  {
                        var ret = deepCopy(elem[p], newVal[p], elem, lvl1 + '/' + newVal.id + '/' + p, lvl2 + '/' + o + '/' + p)
                    }
                }
            }
            else {

                if(obj1.count !== null && typeof obj1.count !== 'undefined') {
                    obj1.append(newVal[o])
                }
                else {  //if the model doesn't even exist!!
                    obj1 = [] //newModelFunc('ZListModel.qml',existingItem)
                    obj1.append(obj2)

                    return
                }
            }
        }
        else {       //overwrite stuffs!
             if(obj1.count !== null && typeof obj1.count !== 'undefined')
             {
                 obj1.clear()
                 obj1.append(obj2)
                 return
             }
             else if(obj1.toString().toLowerCase().indexOf('modelobject') === -1 && !isArray(obj1) && typeof obj1 === 'object')
             {
                 if(prev && prev[lvl1]){
                     prev[lvl1] = obj2
                     return
                 }

             }
             else
             {
                 if(obj1[o] !== newVal[o])
                     obj1[o] = newVal[o]
             }
        }

    }

}





// /*! fn: SHOULD be moved to private. do not USE! \hr */
//function __addData(name, data, it)  {
//    if(data.id !== null && typeof data.id !== 'undefined'){  //this means that we got an object to append not an array of objects!!! hooray.
//        var modelPtr = priv.models[name]
//        var found    = false

////           console.log(tabStr + "\tZController.addModel -- model",name,"found. We wish to add id:",data.id,"to it...")
////        debug.debugMsg(tabStr + "\tZController.addModel -- model",name,"found. We wish to add id:",data.id,"to it...")
////           console.log(tabStr + "\tZController.addModel -- model",name,"found. We wish to add id:",data.id,"to it...")

//        //iterate over this model's list elements and change them according to the data?? or add to them according to the data!!
//        for(var i = 0; i < modelPtr.count; i++)  {
//            if( modelPtr.get(i).id !== null &&  modelPtr.get(i).id === data.id) {
//                debug.debugMsg(tabStr + "\tZController.addModel", name, " -- id",data.id,"already exists. Modifying it...")
//                var le = modelPtr.get(i)

//                for(var d in data)
//                {
//                    if(d !== 'id') {
//                        if(typeof data[d] !== 'object'){
//                            if(le[d] !== data[d])
//                                 le[d] = data[d]
//                        }
//                        else if(le[d] === null || typeof le[d] === 'undefined'){
////                               console.log(rootObject, 'making new listmodel at', d)
//                            le[d] = Functions.getNewObject('ZListModel.qml',le)
////                               console.log("FAT APPEND", data[d])

//                            if(data[d] !== null)       le[d].append(data[d])
//                            else                       le[d].append({})  //TODO DERP, investigate this change!!

//                        }
//                        else
//                        {
////                            debug.debugMsg("DEEP COPY", le[d], data[d], d, d, "", le)
//                            __deepCopy(le[d],data[d],d,d , "", le)
////                            debug.debugMsg("===================== deepCopy finished ========================")
//                        }
//                    }
//                }

//                found = true
//                break
//            }
//        }

//        if(!found) {
//            debug.debugMsg(tabStr + "\tZController.addModel -- Adding to existing list model...",name, data.id, "was not found. Adding it")
////               console.log(tabStr + "\tZController.addModel -- Adding to existing list model...",name, data.id, "was not found. Adding it")
//            modelPtr.append(data)
////               if(name === 'items')
////                  console.log('HEH appending this shit', priv.models[name].get(0), JSON.stringify(priv.models[name].get(0),null,2) )

//        }

//        //check if anything has requested this model!
////           priv.checkCallbacks(name,tabStr + "\t")
//    }


//}

////You have to do a SET EQUALS TO operation on a jsObject to get it to show updates in a model! dynamic linkages and such!
////This is because if you try to change inner things inside a jsObject, models won't let you do it by using get(0).propertyname = somevalue
////TODO, BRO PAL. If this gives you binding issues, perhaps investigate line 305 which is commented out.
//function __deepCopy(obj1, obj2, lvl1, lvl2, tabStr, prev)  {
//    if(!tabStr)
//        tabStr = ""

//    debug.debugMsg(tabStr,'deepCopy(' + lvl1, ',' + lvl2 + ')')

//    if(typeof obj2 !== 'object')
//    {
////           console.log(tabStr+ "\t", lvl1,'is no object. Updating')
//        debug.debugMsg(tabStr+ "\t", lvl1,'is no object. Updating')

//        //do equality check
//        if(obj1 !== obj2)
//            obj1 = obj2

//        return
//    }

//    //if we got an update such that obj2 is now empty, we should do that. //TODO, check the else.
//    if(isArray(obj2) && obj2.length === 0){
//        if(obj1.toString().toLowerCase().indexOf('model') !== -1)             obj1.clear()
//        else                                                                  obj1 = obj2
//    }
//    else{
//        for(var o in obj2) {
//            debug.debugMsg(tabStr + "\t",'examiming',lvl2,'/',o)

//            if(obj2[o] !== null && typeof obj2[o] !== 'undefined' && obj2[o].hasOwnProperty('id')) {
//                debug.debugMsg(tabStr + "\t\tFinding", lvl2 + "/" + obj2[o].id)
//                var elem = getById(obj1, obj2[o].id)  //this is TE 0
//                if(elem !== null) {
//                    debug.debugMsg(tabStr + "\t\t\tFound")
//                    for(var p in obj2[o]) {
//                        /*if(elem[p].toString().indexOf('ModelObject') === -1 && !isArray(elem[p]) && typeof elem[p] === 'object'){

// //                           console.log(p, 'is a normal Js Object')
// //                           console.log(JSON.stringify(elem[p],null,2))

//                            if(elem[p])
//                                 elem[p] = obj2[o][p]

//                        }
//                        else */if(typeof obj2[o][p] !== 'object')
//                        {
// //                           console.log(tabStr + "\t\t\t\t@@", lvl1,'/',obj2[o].id,'/',p,'=',obj2[o][p])
//                            debug.debugMsg(tabStr + "\t\t\t\t@@", lvl1,'/',obj2[o].id,'/',p,'=',obj2[o][p])

//                            //do equality check
//                            if(elem[p] !== obj2[o][p])      elem[p] = obj2[o][p]
// //                           else                            console.log('skipping', lvl1 +'/'+obj2[o].id, 'since value is same')
//                        }
//                        else
//                        {
// //                           console.log(tabStr + "\t\t\t\t", 'calling deepCpy on', lvl1 + '/' + obj2[o].id + '/' + p)
//                            debug.debugMsg(tabStr + "\t\t\t\t", 'calling deepCpy on', lvl1 + '/' + obj2[o].id + '/' + p)
//                            var ret = __deepCopy(elem[p], obj2[o][p], lvl1 + '/' + obj2[o].id + '/' + p, lvl2 + '/' + o + '/' + p, tabStr + "\t", elem)
//                        }
//                    }
//                }
//                else              {
// //                   console.log(tabStr + "\t\t\tNot Found")
//                    debug.debugMsg(tabStr + "\t\t\tNot Found")
//                    if(!obj1.hasOwnProperty('count')) //if the model doesn't even exist!!
//                    {
//                        debug.debugMsg(tabStr + '\t\t\t\t', lvl1,'=', JSON.stringify(obj1,null,2))
//                        debug.debugMsg(tabStr + "\t\t\t\tno model found at",lvl1,"...creating and copying",lvl1,"into it")

//                        //console.log(JSON.stringify(obj1,null,2))
//                        obj1 = Functions.getNewObject("ZListModel.qml",null)
//                        obj1.append(obj2)
//                        //console.log(JSON.stringify(obj1,null,2))

//                        debug.debugMsg(tabStr + "\t\t\t\t\t", '===== end =====')
//                        return
//                    }
//                    else
//                    {
//                         debug.debugMsg(tabStr + "\t\t\t\tappending",obj2[o].id,'to',lvl1)
//                         obj1.append(obj2[o])
//                    }
//                }
//            }
//            else {       //overwrite stuffs!
//                 debug.debugMsg(tabStr+ "\t\t\t",lvl2 + '/' + o, 'has no id.')
//                 if(obj1.hasOwnProperty('count'))
//                 {
// //                    console.log(tabStr + "\t\t\t\t\t", 'Overwriting model at', lvl1, 'with', lvl2)
//                     debug.debugMsg(tabStr + "\t\t\t\t\t", 'Overwriting model at', lvl1, 'with', lvl2)
//                     debug.debugMsg(tabStr + "\t\t\t\t\t", '===== end =====')
//                     obj1.clear()
//                     obj1.append(obj2)
//                     return
//                 }
//                 else if(obj1.toString().indexOf('ModelObject') === -1 && !isArray(obj1) && typeof obj1 === 'object')
//                 {
//                     if(prev && prev[lvl1]){

//                         //one level
// //                        for(o in obj2){
// //                            if(obj2[o] !==)
// //                        }

//                         prev[lvl1] = obj2
//                         return
//                     }
// //                    console.log(rootObject, "PUFF JS OBJECTS SURVIVED", lvl1)
//                     return
//                 }
//                 else
//                 {
// //                    console.log(tabStr + "\t\t\t\t\t", 'Setting', lvl1,'/',o,'=',obj2[o])
//                     debug.debugMsg(tabStr + "\t\t\t\t\t", 'Setting', lvl1,'/',o,'=',obj2[o])

//                     //equality check
//                     if(obj1[o] !== obj2[o])            obj1[o] = obj2[o]
// //                    else                               console.log(lvl1 + '/' + o , 'is the same, so skipping it')
//                 }
//            }

//        }
//    }
//}

