import QtQuick 2.4
import QtQuick.Layouts 1.1
import "zBaseComponents/Functions.js" as Functions
import Zabaat.Misc.Global 1.0


/*!
   \brief ZDynamicForm - Dynamically creates ZButtons that open dynamically generated ZDynamicForms based on information provided. The forms created are highly customizable
                                  based on the properties provided here (which are passed onto the ZDynamicForm(s)
   \inqmlmodule Zabaat.UI.Wolf 1.0
   \relates ZDynamicFormButtons
   \code
   ZDynamicForm
    {
            func        : function(obj,cb) { some code that sends stuff to the server provided a completed form object }
            callBackFunc: function(obj,cb) { some code that takes in the response from server                          }
            validationFunc: function(obj)  { some code that validates the form object and returns an error msg if something is wrong/missing, null if validation succeeds }
            _displayFunctions : {
                                    firstName : function(obj) { some code that returns a string using the value of obj (so that the ZTextBox can render it)  },
                                    lastName  : function(obj) { some code that returns a string using the value of obj (so that the ZTextBox can render it)  }
                                }
            ordering : ['firstName,'lastName']  //Always show firstName and lastName first!

            _data : [ {field : 'firstName' , value : 'John'},
                      {field : 'lastName'  , value : 'Winchester'},
                      ...
                    ]
            title : 'Edit User'
            offsetX : win.x     //allows for positioning windows within this window accurately if this is in a non main window
            offsetY : win.y     //allows for positioning windows within this window accurately if this is in a non main window

            typeArr : {firstName : {type : 'ZTextBox'},     lastName : {type: 'ZTextBox', valueField: 'text', labelField : 'labelName', override { width : 200 }   }
            ordering : ["firstName", "lastName" ]
    }
    \endcode
*/
FocusScope
{
    id : rootObject
    width  : 550
    height : 400
    //spacing : 40



    signal error(string type, string code, string message, var errorObject)

    property int   objectWidth  : 200
    property int   objectHeight : 40
    property int   padding      : 0

    property alias applyBtn         : apply_Btn.visible
    property alias okBtn            : ok_Btn.visible
    property alias columnSpacing    : gridLayout.columnSpacing
    property alias rows             : gridLayout.rows
    property alias columns          : gridLayout.columns
    property alias flow             : gridLayout.flow
    property alias layoutDirection  : gridLayout.layoutDirection
    property alias rowSpacing       : gridLayout.rowSpacing
    property alias grid             : gridLayout
    property var   advancedGrid     : null              //lets you define how each child looks!
    readonly property var clickFunc : titleRow.clickFunc

    property bool autoInit          : false             //the form auto inits when data changes!
    property bool trackChanges      : true



    /*! An array of {field : <fieldName>, value : <value> } objects. The ZDynamicForm will read this,tyepArr and _displayFunctions to make the form. */

    property var _data             : []
    property bool hasInit          : false
    on_DataChanged: if(autoInit && _data && !hasInit) {
                        init()
                    }

    property bool ignoreIdField    : true
    property var  exclusionArr     : []
    property var  validArr         : []
    /*! Allows for custom handling of how certain fields look. This is useful if you don't want to use the typeArr property for these fields and want them to just appear in ZTextBox instead
        \code
        //The field value is passed in as obj to the functions defined on the respective functions defined on the field names (clockIn, clockOut in this case)
        displayFunctions:  { clockIn : function(obj) { return Qt.formatTime(obj, "hh:mm AP") } ,
                            clockOut : function(obj) { return Qt.formatTime(obj, "hh:mm AP") } }
        \endcode
    */
    property var _displayFunctions : []

    /*!
       Should be null or should point to a a function that accepts a JSObject as Input. The job of this function is to
       verify that all data is correct before running func.
       This function should accept a JsObject input. The object will be created by ZDynamicForm when the user hits
       'apply' or 'ok' and then passed to this function. The job of this function is to verify all data
       is valid. The function should return null in happy state!

       \code
       validationFunc : function (obj)
       {
           if(obj.clockIn > obj.clockOut)
               return "ClockIn cannot be greater than ClockOut Time"
           return null
       }
       \endcode
    */
    property var    validationFunc : null


    /*! Determines the order in which the fields will appear on the ZDynamicForm(s). If some fields are left out, there no guarantees in which order they will appear.
       \code
        //In this example, the ZDynamicForm guarantees that it will draw firstName and then lastName first. All the rest of the fields may be drawn at random.
        ordering : ["firstName", "lastName"]
       \endcode
    */
    property var ordering : []

    /*! The function to run when the user hits apply or ok button. This should accept a JsObject as input (which is automatically created by the ZDynamicForm) and a cb function (optional)
        \code
            func : function(obj,cb) { ZGlobal.client.controller.postReq('/employees/addNew',obj,cb, "employees") }
        \endcode
    */
    property var    func           : null

    /*! The function to run when the server/other process returns in response to calling func  */
    property var    callBackFunc   : null

    /*!
        Allows us to override the default ZTextBox type of the dynamic form for any field! Defaults to empty array.
        \code
        //The type object contains the following
        //<type>  is the QML type (found in Zabaat.UI.Wolf) . Should not contain .qml at the end. valid examples are ZTextBox, ZTimePicker, etc etc
        //<valueField> is the property where value should be shoved in (and read from!)
        //<labelField> is the name where labels should be shoved in (field names such as firstName, etc)
        //<override> lets us inject stuff into this component on the form and not populate it from the model! Essentially allows access to the object's qml properties such as width, height, color, etc.
        //<import>   lets us define import path to dir or plugin for this component!

        typeArr : ({
                    firstName : { type : 'ZButton' , valueField : 'text', labelField : 'labelName' }
                    lastName  : { type : null }     //makes this field invisible in the form
                    favFoods  : { type : 'ZComboBoxQt', override { derp : 'herp', slurp : 'jurp' } }
                  )}
        \endcode
    */
    property var    typeArr : []

    /*! For internal qml class use only. Do not mess with this.  */
    property var    objectMap : ({})    //gives us quick access to children in the columns! By their field names!!

//    /*! Focus map, we don't just use the grid.children cause we wan't the buttons to be focusable too!! */
//    property var    focusMap : []

    /*! Emitted when 'OK' button is pressed.  */
    signal closeWindow()

    /*! this is used to calculate the offset of the window this thing is in. It will make deeper window objects track properly!  */
    property int offsetX : 0

    /*! this is used to calculate the offset of the window this thing is in. It will make deeper window objects track properly!  */
    property int offsetY : 0


    /*! Tries to apply these to every single dynamically created object made!! */
    property var globalProperties :  ({})


    ZValidator{
        id : validator
        anchors.fill: parent
        validationFunc: rootObject.validationFunc
        spinnyPtr {
            x : btnRow.x - width
            y : (parent.height/2 - spinnyPtr.height/2)
        }
    }

    Item{
        id : mainthing
        width  : rootObject.width
        height : rootObject.height - (validator.errorRectPtr.height + titleRow.height)
        anchors.top: parent.top
        GridLayout{
            id : gridLayout
            width : parent.width - padding
            height : parent.height - padding
            anchors.centerIn: parent
        }
    }
    Item {
        id     : titleRow
        width  : parent.width
        height : 30
        anchors.bottom: rootObject.bottom
        anchors.margins: 5
        anchors.right  : rootObject.right

        function clickFunc(cb)  {
            if(func)
            {
                var obj      = formObject()
                if(validator.validate(obj)){
                    validator.state = 'loading'
                    if(trackChanges)
                    {
                        privates.requested = true
                        func(obj , function(msg) { cb(msg);     privates.requested = false  })
                    }
                    else
                        func(obj, cb)
                }
            }
        }

        Row {
            id : btnRow
            anchors.right: parent.right
            width        : !applyBtn || !okBtn ? Math.max(apply_Btn.width,ok_Btn.width) : apply_Btn.width + ok_Btn.width + spacing
            height       : parent.height
            spacing      : 15

            ZButton {
                id : apply_Btn
                text : "Apply"
                width : visible ? titleRow.width/8 : 0
                height : parent.height
                onBtnClicked: titleRow.clickFunc(cbFunc)
                enabled : visible && (validator.state === 'ok' || validator.state === '')
                activeFocusOnTab: visible
            }
            ZButton {
                id : ok_Btn
                text : "Ok"
                width : visible ? titleRow.width/8 : 0
                height : parent.height
                onBtnClicked: titleRow.clickFunc(closeFunc)
                activeFocusOnTab: visible
                enabled : visible && (validator.state === 'ok' || validator.state === '')
            }
        }
    }
    Rectangle{
        id : hoverBox
        border.width: 3
        z : 999999
        enabled : visible
        visible : trackChanges && message.length > 0
        property string message : ""
        property var messageFunc : function(msg){
            message = ZGlobal.functions.isUndef(msg) ? 'undefined' : msg
        }

        color           : ZGlobal.style._default
        anchors.top     : parent.top
        anchors.right   :  parent.right
        radius          : height/2
        width           : parent.width / 4
        height          : 80

        ZTextBox{
            enabled : false
            width : parent.width - parent.width/10
            height : parent.height - parent.height/10
            anchors.centerIn: parent
            text : parent.message
            outlineVisible: false
            labelName : 'Server Value'
            state : 'top'
            color : 'transparent'
            border.width : 0
        }

        MouseArea{
            anchors.fill: parent
            enabled     : parent.enabled
            onClicked   : parent.message = ""
        }

    }



    //Very similar functions! These will run the callback function (if provided after formObject() successfully passes validationFunc (if provided) and a callback from func() is received!)
    function cbFunc(msg)    {
        if(msg && msg[0])
        {
            if((msg[0].err || msg[0].error)  && ZGlobal.objects.getSailsErrObj){
                var err = ZGlobal.objects.getSailsErrObj(msg)
                err.origin = 'ZDynamicForm.cbFunc'
                error(err.type, err.code, err.message, err)
                validator.errorMessage(err.message)
            }
            else{
                validator.clearError()
                if(callBackFunc)
                    callBackFunc(msg)
            }

            apply_Btn.enabled = ok_Btn.enabled = true
        }
    }
    function closeFunc(msg) {
        if(msg)
        {
            if((msg[0].err || msg[0].error)  && ZGlobal.objects.getSailsErrObj){
                var err = ZGlobal.objects.getSailsErrObj(msg)
                err.origin = 'ZDynamicForm.cbFunc'
                error(err.type, err.code, err.message, err)
                validator.errorMessage(err.message)
            }
            else
            {
                validator.clearError()
                if(callBackFunc)
                    callBackFunc(msg)
                closeWindow()
            }

            apply_Btn.enabled = ok_Btn.enabled    = true
        }
    }

    //create the form object using _data. We do want to send the complete object out, not just the thing in the form i gather!
    function formObject(){
        var obj = {}
        var isArray = ZGlobal._.isArray(_data)

        if(isArray){
            for(var i = 0; i < _data.length; i++){
                var field       = _data[i].field
                var typeInfo    = getTypeInfo(field)

                var answerField = typeInfo && typeInfo.answerField ? typeInfo.answerField : "text"
                var child       = objectMap[field] //privates.getChild(field)

                if(child)       obj[field]  = child[answerField]
                else            obj[field]  = _data[i].value                //just to make sure we send the complete object out!! So we include stuff in _data that was not specced in validArr
            }
        }
        else{
            for(var k in _data){
                if (k === 'objectName' || k === 'objectNameChanged'  || k.indexOf("__") !== -1)
                     continue    //go one iteration forward

                field       = k
                typeInfo    = getTypeInfo(field)
                answerField = typeInfo && typeInfo.answerField ? typeInfo.answerField : "text"
                child       = objectMap[field]

                if(child)       obj[field]  = child[answerField]
                else            obj[field]  = _data[k]         //just to make sure we send the complete object out!! So we include stuff in _data that was not specced in validArr
            }
        }


        return obj

    }
    function init()  {  //occurs when _data is changed! make sure you set all the other properties first!!
        var properties  = privates.getProperties()  //gets us all the fieldNames either from validArr or _data(arr) or _data(obj)
        var isArray     = ZGlobal._.isArray(_data)

        privates.snapshot = trackChanges ? ZGlobal._.clone(_data) : null        //use this for tracer (outlines)
        privates.doExclude(properties)                                          //removes unwanted fields from properties

        if(properties.length > 0){
            clear()

//            console.log(rootObject, 'before ordering', properties)

            //we have to first handle ordering array and then the remaining left in properties (on _data)
            if(ordering && ordering.length > 0){
                for(var i = 0; i < ordering.length; i++){
                    //if this is an array, we need to look at the field property in properties!
                    var prop      = ordering[i]
                    var propIndex = ZGlobal._.indexOf(properties,prop,false)

                    if(propIndex !== -1){

                        if(isArray){
                            var index = privates.getIndexOf(prop, _data)
                            if(index !== -1){
                                if(trackChanges)                        privates.createObjectFunc(prop, index)
                                else                                    privates.createObjectFunc_Simple(prop,index)
                            }
                        }
                        else{
                            if(trackChanges)                            privates.createObjectFunc(prop, -1)
                            else                                        privates.createObjectFunc_Simple(prop, -1)
                        }

                        properties.splice(propIndex,1)
                    }

               }
            }

//            console.log(rootObject, 'after ordering', properties)

            //now lets do the remaining
            for(i = 0; i < properties.length; i++)
            {
                if(properties[i] !== null && typeof properties[i] !== 'undefined'){
                    index     = isArray ? privates.getIndexOf(properties[i],_data) : -1

                    if(trackChanges)              privates.createObjectFunc(properties[i], index)
                    else                          privates.createObjectFunc_Simple(properties[i], index)
                }
            }



            var count = 0;
            for(var o in objectMap)
            {
                var child = objectMap[o]
                if(count === 0)
                    child.forceActiveFocus()

                if(advancedGrid && advancedGrid[o])
                {
                    var props = advancedGrid[o]
                    child.Layout.maximumWidth = Number.POSITIVE_INFINITY
                    child.Layout.fillWidth    = true

                    for(var p in props)
                        child.Layout[p] =  props[p]
                }
                else
                {
                    child.Layout.maximumWidth  = Qt.binding(function() { return gridLayout.width  / (gridLayout.columns + 1)} )
                    child.Layout.maximumHeight = Qt.binding(function() { return gridLayout.height / (gridLayout.rows + 1)} )
                }

                count++
            }




        }


        hasInit = true
    }
    function getTypeInfo(key)  {
        for(var k in typeArr)
        {
            if(k === key)
                return typeArr[k]
        }
        return null
    }
    function clear(){
        for(var i = 0; i < gridLayout.children.length; i++)
        {
            var child =  gridLayout.children[i]

            if(child){
                child.parent = null
                child.destroy()
            }
        }
        gridLayout.children = []

        objectMap = {}
    }

    QtObject{
        id : privates

        property bool requested : false
        property var snapshot   : null

        function getProperties(){
            var arr = []

            if(validArr && validArr.length > 0)
            {
                for(var v in validArr){
                    arr.push(validArr[v])
                }
            }
            else if(typeof _data.length !== 'undefined' && _data.length > 0){
                for(var i = 0; i < _data.length; i++)
                    arr.push(_data[i].field)
            }
            else{
                for(var k in _data){
                    if ((k === "id" && ignoreIdField) ||  k === 'objectName' || k === 'objectNameChanged'  || k.indexOf("__") !== -1)
                         continue    //go one iteration forward

                    arr.push(k)
                }
            }

            return arr
        }
        function getIndexOf(fieldName, arr){

            if(arr){
                for(var i = 0; i < arr.length; i++){
                    if(arr[i].field && arr[i].field === fieldName)
                        return i
                }
            }
            return -1
        }
        function doExclude(arr){   //called upon init(). Removes stuff in arr that is stated in exclusionArr
            if(exclusionArr && exclusionArr.length > 0){

                for(var e in exclusionArr){
                    var exclude = exclusionArr[e]
                    var index   = ZGlobal._.indexOf(arr, e, false)
                    if(index !== -1)
                        arr.splice(index,1)
                }
            }
        }
        function moveAllToBack() {
            for(var i = 0; i < grid.children.length; i++)
                grid.children[i].z = 1
        }
        function createObjectFunc(field, arrayIndex){

            var par = gridLayout
            var typeInfo = getTypeInfo(field)

            var typeName    = 'ZTextBox'
            var valueField  = 'text'
            var labelField  = 'labelName'
            var override    = false
            var importArr   = ['QtQuick 2.4','Zabaat.UI.Wolf 1.1']

            if(typeInfo)
            {
                if(typeInfo.type)         typeName   = typeInfo.type
                if(typeInfo.valueField)   valueField = typeInfo.valueField
                if(typeInfo.labelField)   labelField = typeInfo.labelField

                override = typeInfo.override

                if(typeInfo.importArr)
                {
                    for(var t in typeInfo.importArr)
                        importArr.push(typeInfo.importArr[t])
                }
            }

//            console.log(rootObject, 'createObjectFunc', field, valueField)

            if(typeName)
            {
                var obj = Functions.getQmlObject(importArr, typeName + "{   id : root;
                                                                            activeFocusOnTab : enabled;
                                                                            property alias tracker : _tracker;
                                                                            property int index : 0;
                                                                            z : focus ?  9999 : 0;

                                                                            ZChangeTracker
                                                                            {
                                                                                id: _tracker;
                                                                                __trackObj : root;
                                                                                anchors.fill: parent;
                                                                                z : 99999
                                                                            }
                                                                        }", par)

                obj.index       = par.children.length - 1
//                obj.iWasClicked.connect(privates.setFocusTo)

                objectMap[field] = obj //gets us a nice and easy ptr for when we need to use create a big object out of this form to pass it out to postReq func (or whatever else)!

                if(objectWidth  != -1) {
                    obj.Layout.preferredWidth  = Qt.binding(function() { return objectWidth  } )
                    obj.Layout.maximumWidth    = Qt.binding(function() { return objectWidth  } )
                }
                if(objectHeight != -1) {
                    obj.Layout.preferredHeight = Qt.binding(function() { return objectHeight } )
                    obj.Layout.maximumHeight = Qt.binding(function() { return objectHeight } )
                }


                //lets read globalProperties here, if any exist!!
                if(globalProperties !== null && typeof globalProperties !== 'undefined'){
                    for(var g in globalProperties){
                        if     (g.toLowerCase() === 'valuefield')                       valueField = globalProperties[g]
                        else if(g.toLowerCase() === 'labelfield')                       labelField = globalProperties[g]
                        else if(typeof obj[g]   !== 'undefined' ){
                            try {
                                obj[g]     = globalProperties[g]
                            }
                            catch(e){
                                console.log(rootObject, "failed to assign value", g, globalProperties[g])
                            }

                        }
                    }
                }

                if(labelField && obj.hasOwnProperty(labelField))
                    obj[labelField] = field


                obj.tracker.__requested     = Qt.binding(function() { return privates.requested   })
                obj.tracker.__arrayIndex    = arrayIndex
                obj.tracker.__dispFunc      = _displayFunctions && typeof _displayFunctions[field] !== 'undefined' ? _displayFunctions[field] : null
                obj.tracker.__fieldName     = field
                obj.tracker.__model         = Qt.binding(function() { return _data             } )
                obj.tracker.__snapshot      = Qt.binding(function() { return privates.snapshot } )
                obj.tracker.__valueField    = valueField


                obj.tracker.__message   = hoverBox.messageFunc

                if(obj.hasOwnProperty(valueField)) {
                    var val = obj.tracker.__dispFunc ? obj.tracker.__dispFunc(obj.tracker.__val) : obj.tracker.__val
                    if(ZGlobal.functions.isUndef(val)){
                        obj[valueField] = obj.hasOwnProperty('defaultVal') ? obj.defaultVal : "N/A"
                    }
                    else
                        obj[valueField] = val
                }



                if(obj.hasOwnProperty('winOffsetX'))        obj.winOffsetX = Qt.binding(function() { return rootObject.offsetX  })
                if(obj.hasOwnProperty('winOffsetY'))        obj.winOffsetY = Qt.binding(function() { return rootObject.offsetY  })


                if(override)
                {
                    for(var o in override)
                        obj[o] = override[o]
                }
            }


        }
        function createObjectFunc_Simple(field, arrayIndex){    //no tracking in here
            var par = gridLayout
            var typeInfo = getTypeInfo(field)

            var typeName    = 'ZTextBox'
            var valueField  = 'text'
            var labelField  = 'labelName'
            var override    = false
            var importArr   = ['QtQuick 2.4','Zabaat.UI.Wolf 1.1']

            if(typeInfo)
            {
                if(typeInfo.type)         typeName   = typeInfo.type
                if(typeInfo.valueField)   valueField = typeInfo.valueField
                if(typeInfo.labelField)   labelField = typeInfo.labelField

                override = typeInfo.override

                if(typeInfo.importArr)
                {
                    for(var t in typeInfo.importArr)
                        importArr.push(typeInfo.importArr[t])
                }
            }

//            console.log(rootObject, 'createObjectFunc', field, valueField)

            if(typeName)
            {
                var obj = Functions.getQmlObject(importArr, typeName + "{   id : root;
                                                                            activeFocusOnTab : enabled;
                                                                            z : focus ?  9999 : 0;
                                                                            property int index : 0;
                                                                            property var __model : null;
                                                                            property int __arrayIndex : -1;
                                                                            property string __fieldName : '';
                                                                            property var __dispFunc : null;
                                                                            property var __val   : __model === null || typeof __model === 'undefined' ? undefined :
                                                                                                   __arrayIndex !== -1 && typeof __model[__arrayIndex] !== 'undefined' ? __model[__arrayIndex].value :
                                                                                                   __fieldName  !== '' && typeof __model[__fieldName] !== 'undefined'  ? __model[__fieldName] :
                                                                                                   undefined;

                                                                        }", par)

                obj.index       = par.children.length - 1
//                obj.iWasClicked.connect(privates.setFocusTo)




                objectMap[field] = obj //gets us a nice and easy ptr for when we need to use create a big object out of this form to pass it out to postReq func (or whatever else)!

                obj.Layout.alignment = Qt.AlignHCenter
                if(objectWidth  != -1) {
                    obj.Layout.preferredWidth  = Qt.binding(function() { return objectWidth  } )
                    obj.Layout.maximumWidth    = Qt.binding(function() { return objectWidth  } )
                }
                if(objectHeight != -1) {
                    obj.Layout.preferredHeight = Qt.binding(function() { return objectHeight } )
                    obj.Layout.maximumHeight = Qt.binding(function() { return objectHeight } )
                }


                //lets read globalProperties here, if any exist!!
                if(globalProperties !== null && typeof globalProperties !== 'undefined'){
                    for(var g in globalProperties){
                        if     (g.toLowerCase() === 'valuefield')                       valueField = globalProperties[g]
                        else if(g.toLowerCase() === 'labelfield')                       labelField = globalProperties[g]
                        else if(typeof obj[g]   !== 'undefined' )                       obj[g]     = globalProperties[g]
                    }
                }

                if(labelField && obj.hasOwnProperty(labelField))
                    obj[labelField] = field

                obj.__dispFunc      = _displayFunctions && typeof _displayFunctions[field] !== 'undefined' ? _displayFunctions[field] : null
                obj.__arrayIndex    = arrayIndex
                obj.__fieldName     = field
                obj.__model         = _data


                if(obj.hasOwnProperty(valueField))

//                    console.log(field, JSON.stringify(valueField))
                    obj[valueField] = Qt.binding(function() {   if(obj.__dispFunc){
                                                                    var ret = obj.__dispFunc(obj.__val)
                                                                    if(ret === null || typeof ret === 'undefined') return -1
                                                                    return ret
                                                                }
                                                                else if(obj.__val === null || typeof obj.__val === 'undefined')  return -1
                                                                return                                                           obj.__val
                                                             })


                if(obj.hasOwnProperty('winOffsetX'))        obj.winOffsetX = Qt.binding(function() { return rootObject.offsetX  })
                if(obj.hasOwnProperty('winOffsetY'))        obj.winOffsetY = Qt.binding(function() { return rootObject.offsetY  })


                if(override)
                {
                    for(var o in override)
                        obj[o] = override[o]
                }
            }

        }
    }



}

