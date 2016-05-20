import QtQuick 2.0
import "Functions.js" as Functions

Item
{
    //We went with another implemention but if we did ever come back to this one, there are a few things missing from this. get() and set() methods missing or not yet complete.
    id : rootObject
    property var zModels  : []       //The array of zModels on which these bindVals are made!
    property var bindVals : []       //this contains the fullName of the bindValue, one that the UI does not need to see

    property var cbsOnce  : []      //These callbacks are deleted after one fetch

    //Refreshes all bindVals!
    function refresh()
    {
        bindVals = []
        for(var zmodel in zModels)
        {
            var model     = zModels[zmodel].model
            var modelName = zModels[zmodel].modelName

            priv.recursiveAdd(zModels[zmodel], modelName + "/", "", model)
        }
//        checkAllCallBacks()
    }

    function printAll()
    {
        for(var b in bindVals)
            console.log(b)
    }

    function killBindings(str)
    {
        var deletionArr = []
        for(var b in bindVals)
        {
            if(b.indexOf(str) !== -1)
                deletionArr.push(b)
        }

        for(var d in deletionArr)
        {
            bindVals[d].destroy()
            delete bindVals[d]
        }
    }


    Item
    {
        id : priv   //private functions that the outside world should never be able to call!

        function recursiveAdd(zModel,idStr,memStr, obj)
        {
            for(var key in obj)
            {
                var objType = Object.prototype.toString.call(obj[key])
                if(objType === '[object Array]'  ||  objType === '[object Object]')
                {
                    var mem = memStr.length > 0 ? memStr + "," + key : key

                    if(Number(key) !== NaN && obj[key].id)    recursiveAdd(zModel, idStr + obj[key].id + "/", mem,  obj[key])
                    else                                      recursiveAdd(zModel, idStr + key + "/"        , mem,  obj[key])
                }
                else if(key !== "id")
                {
                    var bindVal     = Functions.getNewObject("ZBindVal.qml",null)

                    bindVal.idStr   = idStr + key
                    bindVal.zModel  = zModel
                    bindVal.bindStr = memStr + "," + key
                    bindVal.bindingChanged.connect(handleValChange)
                    bindVal.doConnect()

                    bindVals[idStr + key] = bindVal
                }
            }
        }

        function handleValChange(idStr, val, type)
        {
            checkOnceCallBack(idStr)
        }

        function checkAllOnceCallBacks()
        {
           var deletionArr = []
           for(var c in cbsOnce)
           {
               checkOnceCallBack(c)

               if(cbsOnce[c].length === 0)
                   deletionArr.push(c)
           }

           for(var d in deletionArr)
               delete cbsOnce[d]
        }

        function checkOnceCallBack(c)
        {
            if(cbsOnce[c] && bindVals[c])
            {
                var deletionArr = []
                for(var l in cbsOnce[c])
                {
                    var myCb = cbsOnce[c][l]

                    myCb.obj[myCb.propName] = Qt.binding(function() { return rootObject.get(myCb.obj.bindingStr,myCb.propName,myCb.obj) })
                    deletionArr.push(l)
                }

                for(var d in deletionArr)
                    delete cbsOnce[c][d]
            }
        }


        function destroyCb(obj, cbArr)
        {
            var delStr = ""
            var delInd = -1
            for(var c in cbArr)
            {
                for(var l in cbArr[c])
                {
                    if(cbArr[c][l].obj == obj)
                    {
                        console.log("found me")
                        delStr = c
                        delInd = l
                        break
                    }
                }
            }

            if(delInd != -1)
            {
                delete cbArr[delStr][delInd]

                if(cbArr[delStr].length === 0)
                    delete cbArr[delStr]
            }

        }


        function handleGuiItemDestruction(obj)
        {
            destroyCb(obj,cbsOnce)
        }

    }



    function get(bindingStr, objPropertyName, thisObj)
    {
//        priv.handleGuiItemDestruction(thisObj)  //delete all current Callbacks referencing this object!
//        thisObj.isDying.connect(priv.handleGuiItemDestruction)
        if(bindVals[bindingStr])
           return bindVals[bindingStr].val
        else
        {
            //add a get request here



            var f = { obj : thisObj , propName : objPropertyName }

            //add to our Once callback queue
            if(cbsOnce[bindingStr])                cbsOnce[bindingStr].push(f)
            else                                   cbsOnce[bindingStr] = [f]

            return "Not yet available"
        }
    }







}
